import json
import os
import sqlite3
from contextlib import closing
from datetime import datetime, timedelta, timezone
from typing import Any
from fastapi.middleware.cors import CORSMiddleware

import jwt
from pwdlib import PasswordHash
from fastapi import (
    FastAPI,
    HTTPException,
    Response,
    status,
    Depends,
)
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt.exceptions import InvalidTokenError
from pydantic import BaseModel, ConfigDict, Field


# Configuration
DB_PATH = os.getenv("DATABASE_PATH", "/data/fittrack.db")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")

if not JWT_SECRET_KEY:
    raise RuntimeError("JWT_SECRET_KEY is not configured")

JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_MINUTES = 30

password_hash = PasswordHash.recommended()
bearer_scheme = HTTPBearer(auto_error=False)

app = FastAPI(
    title="FitTrack Cloud API",
    description="Multi-user cloud backend for FitTrack Pro.",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request models
class RegisterRequest(BaseModel):
    email: str = Field(min_length=5, max_length=254)
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: str = Field(min_length=5, max_length=254)
    password: str = Field(min_length=1, max_length=128)


class WorkoutPayload(BaseModel):
    model_config = ConfigDict(extra="allow")

    day: str = Field(min_length=1, max_length=80)
    date: datetime
    startTime: datetime | None = None
    endTime: datetime | None = None
    completed: bool = True
    caloriesBurned: int = Field(default=0, ge=0)
    exercises: list[dict[str, Any]] = Field(default_factory=list)


# Database
def get_connection() -> sqlite3.Connection:
    os.makedirs(os.path.dirname(DB_PATH) or ".", exist_ok=True)
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def initialise_database() -> None:
    with closing(get_connection()) as connection:
        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )

        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS workouts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                workout_json TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )

        # Migrate the existing workouts table without deleting records.
        columns = {
            row["name"]
            for row in connection.execute(
                "PRAGMA table_info(workouts)"
            ).fetchall()
        }

        if "user_id" not in columns:
            connection.execute(
                "ALTER TABLE workouts ADD COLUMN user_id INTEGER"
            )

        connection.execute(
            """
            CREATE INDEX IF NOT EXISTS idx_workouts_user_id
            ON workouts(user_id)
            """
        )

        connection.commit()


@app.on_event("startup")
def startup() -> None:
    initialise_database()


# Authentication helpers
def create_access_token(user_id: int) -> str:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=ACCESS_TOKEN_MINUTES
    )

    payload = {
        "sub": str(user_id),
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM,
    )


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(
        bearer_scheme
    ),
) -> dict[str, Any]:
    if credentials is None:
        raise HTTPException(
            status_code=401,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = jwt.decode(
            credentials.credentials,
            JWT_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
        )
        user_id = int(payload["sub"])
    except (InvalidTokenError, KeyError, TypeError, ValueError):
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired access token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    with closing(get_connection()) as connection:
        user = connection.execute(
            "SELECT id, email FROM users WHERE id = ?",
            (user_id,),
        ).fetchone()

    if user is None:
        raise HTTPException(
            status_code=401,
            detail="User no longer exists",
        )

    return {"id": user["id"], "email": user["email"]}


def token_response(user: sqlite3.Row) -> dict[str, Any]:
    return {
        "access_token": create_access_token(user["id"]),
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_MINUTES * 60,
        "user": {
            "id": user["id"],
            "email": user["email"],
        },
    }


# Public endpoints
@app.get("/")
def home() -> dict[str, str]:
    return {
        "message": "FitTrack Cloud API is running",
        "docs": "/docs",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "healthy"}


# Account registration
@app.post("/auth/register", status_code=status.HTTP_201_CREATED)
def register(
    request: RegisterRequest,
) -> dict[str, Any]:
    email = request.email.strip().lower()

    if "@" not in email or "." not in email.rsplit("@", 1)[-1]:
        raise HTTPException(
            status_code=400,
            detail="Please provide a valid email address",
        )

    hashed_password = password_hash.hash(request.password)
    created_at = datetime.now(timezone.utc).isoformat()

    with closing(get_connection()) as connection:
        try:
            # Keep account creation and legacy workout assignment atomic.
            connection.execute("BEGIN IMMEDIATE")

            cursor = connection.execute(
                """
                INSERT INTO users (email, password_hash, created_at)
                VALUES (?, ?, ?)
                """,
                (email, hashed_password, created_at),
            )

            user_id = cursor.lastrowid

            # Assign old, unowned workouts to the first account
            # without changing their workout JSON or IDs.
            connection.execute(
                """
                UPDATE workouts
                SET user_id = ?
                WHERE user_id IS NULL
                """,
                (user_id,),
            )

            connection.commit()

        except sqlite3.IntegrityError:
            connection.rollback()
            raise HTTPException(
                status_code=409,
                detail="An account with this email already exists",
            )

        user = connection.execute(
            "SELECT id, email FROM users WHERE id = ?",
            (user_id,),
        ).fetchone()

    return token_response(user)


# Account login
@app.post("/auth/login")
def login(
    request: LoginRequest,
) -> dict[str, Any]:
    email = request.email.strip().lower()

    with closing(get_connection()) as connection:
        user = connection.execute(
            """
            SELECT id, email, password_hash
            FROM users
            WHERE email = ?
            """,
            (email,),
        ).fetchone()

    if user is None or not password_hash.verify(
        request.password,
        user["password_hash"],
    ):
        raise HTTPException(
            status_code=401,
            detail="Incorrect email or password",
        )

    return token_response(user)


# Protected workout endpoints
@app.post("/workouts", status_code=status.HTTP_201_CREATED)
def create_workout(
    workout: WorkoutPayload,
    current_user: dict[str, Any] = Depends(get_current_user),
) -> dict[str, Any]:
    payload = workout.model_dump(mode="json")
    created_at = datetime.now(timezone.utc).isoformat()

    with closing(get_connection()) as connection:
        cursor = connection.execute(
            """
            INSERT INTO workouts
                (workout_json, created_at, user_id)
            VALUES (?, ?, ?)
            """,
            (
                json.dumps(payload),
                created_at,
                current_user["id"],
            ),
        )
        connection.commit()
        workout_id = cursor.lastrowid

    return {
        "id": workout_id,
        "createdAt": created_at,
        **payload,
    }


@app.get("/workouts")
def list_workouts(
    current_user: dict[str, Any] = Depends(get_current_user),
) -> list[dict[str, Any]]:
    with closing(get_connection()) as connection:
        rows = connection.execute(
            """
            SELECT id, workout_json, created_at
            FROM workouts
            WHERE user_id = ?
            ORDER BY id DESC
            """,
            (current_user["id"],),
        ).fetchall()

    result: list[dict[str, Any]] = []

    for row in rows:
        payload = json.loads(row["workout_json"])
        result.append(
            {
                "id": row["id"],
                "createdAt": row["created_at"],
                **payload,
            }
        )

    return result


@app.delete(
    "/workouts/{workout_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_workout(
    workout_id: int,
    current_user: dict[str, Any] = Depends(get_current_user),
) -> Response:
    with closing(get_connection()) as connection:
        cursor = connection.execute(
            """
            DELETE FROM workouts
            WHERE id = ? AND user_id = ?
            """,
            (workout_id, current_user["id"]),
        )
        connection.commit()

    if cursor.rowcount == 0:
        raise HTTPException(
            status_code=404,
            detail="Workout not found",
        )

    return Response(status_code=status.HTTP_204_NO_CONTENT)