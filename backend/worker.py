import json
import logging
import time
import hashlib

import redis

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)

logger = logging.getLogger("fittrack-worker")

client = redis.Redis.from_url(
    "redis://redis:6379/0",
    decode_responses=True,
)

QUEUE = "fittrack:workout_events"
DEAD_QUEUE = "fittrack:failed_events"
PROCESSED_SET = "fittrack:processed_events"
MAX_ATTEMPTS = 3


def get_event_id(event):
    raw_id = (
        f'{event.get("event_type")}:{event.get("user_id")}:'
        f'{event.get("workout_id")}'
    )
    return hashlib.sha256(raw_id.encode()).hexdigest()


def process_event(event):
    workout = event["workout"]

    summary = {
        "workout_id": event["workout_id"],
        "user_id": event["user_id"],
        "workout_name": workout.get("day", "Workout"),
        "exercise_count": len(workout.get("exercises", [])),
        "calories": workout.get("caloriesBurned", 0),
    }

    logger.info("Processed workout summary: %s", summary)


logger.info("FitTrack background worker started")

while True:
    try:
        result = client.blpop(QUEUE, timeout=5)

        if not result:
            continue

        _, message = result
        event = json.loads(message)

        if event.get("event_type") != "workout_completed":
            logger.warning("Ignoring unknown event type")
            continue

        event_id = get_event_id(event)

        if client.sismember(PROCESSED_SET, event_id):
            logger.info("Duplicate event skipped: %s", event_id)
            continue

        attempts_key = f"fittrack:attempts:{event_id}"
        attempts = int(client.get(attempts_key) or 0) + 1
        client.set(attempts_key, attempts)

        try:
            process_event(event)

            client.sadd(PROCESSED_SET, event_id)
            client.delete(attempts_key)

            logger.info("Event completed successfully: %s", event_id)

        except Exception:
            logger.exception("Event processing failed")

            if attempts < MAX_ATTEMPTS:
                client.rpush(QUEUE, message)
                logger.warning(
                    "Retrying event (%s/%s): %s",
                    attempts, MAX_ATTEMPTS, event_id
                )
            else:
                client.rpush(DEAD_QUEUE, message)
                client.delete(attempts_key)
                logger.error("Event moved to dead-letter queue: %s", event_id)

    except redis.RedisError:
        logger.exception("Redis connection error")
        time.sleep(3)

    except Exception:
        logger.exception("Failed to handle event")
