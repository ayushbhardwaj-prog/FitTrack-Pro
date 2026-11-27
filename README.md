# FitTrack Pro – Cloud Fitness Tracking System

## 1. Project Overview

FitTrack Pro is a cloud-based fitness tracking system. Users can register,
log in and store workout history through a FastAPI backend connected to
a Flutter application.

The system demonstrates cloud computing concepts including virtual
machines, Docker containers, networking, persistent storage, load
balancing, orchestration, event-driven processing, security and backups.

## 2. Architecture

Flutter Mobile Application
        |
        | HTTPS
        v
DuckDNS Domain + Caddy Reverse Proxy
        |
        v
Google Cloud Compute Engine VM
        |
        +---- API Instance 1
        |
        +---- API Instance 2
        |
        +---- Redis Event Queue
        |          |
        |          v
        |     Background Worker
        |
        +---- SQLite Database
                   |
                   v
             Persistent Docker Volume

## 3. Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| Cloud infrastructure | Google Compute Engine | Hosts the application |
| Operating system | Ubuntu 24.04 | VM operating system |
| Backend | FastAPI | REST API |
| API containers | Docker | Isolated API instances |
| Container management | Docker Compose | Starts and manages services |
| Reverse proxy | Caddy | HTTPS and load balancing |
| DNS | DuckDNS | Domain name |
| TLS | Let's Encrypt via Caddy | HTTPS encryption |
| Database | SQLite | Workout and user data |
| Cache and queue | Redis 7 | Event queue |
| Background processing | Python worker | Processes workout events |

## 4. Running the System

Requirements:
- Docker
- Docker Compose
- Environment configuration in .env

Start the complete system:

    docker compose up -d --build

Check services:

    docker compose ps

Check API health locally:

    curl http://127.0.0.1:8001/health

Check public HTTPS endpoint:

    curl https://fittrackcloud.duckdns.org/health

API documentation:

    https://fittrackcloud.duckdns.org/docs

## 5. Authentication and API

The backend provides:
- POST /auth/register
- POST /auth/login
- GET /workouts
- POST /workouts
- DELETE /workouts/{workout_id}
- GET /health

Authentication uses JWT bearer tokens. Passwords are stored as
password hashes rather than plaintext.

Workout endpoints require authentication.

## 6. Storage and Persistence

Workout data is stored in SQLite at:

    /data/fittrack.db

The database is mounted through the persistent Docker volume
fittrack_data.

Redis uses a separate persistent volume named redis_data.

The database volume survives API container recreation. The two API
instances share the same SQLite database file on the VM.

SQLite was selected for this small prototype. A managed database
such as Google Cloud SQL would be a future alternative for larger
production workloads.

## 7. Load Balancing and Orchestration

Two FastAPI containers run as separate API instances.

Caddy reverse proxies requests to both instances and performs
health checks.

Failover was tested by stopping one API container while sending
repeated requests to the HTTPS health endpoint. Requests continued
to succeed through the remaining instance.

Docker Compose manages service startup, dependencies and restart
policies.

## 8. Event-Driven Processing

When a workout is completed, an event is published to the Redis
queue:

    fittrack:workout_events

A separate Python worker consumes events and generates workout
summaries.

The worker includes:
- Event processing
- Duplicate event detection
- Retry handling
- Dead-letter queue for failed events

A managed alternative would be a cloud message queue with a
serverless function.

## 9. Security

- JWT bearer-token authentication.
- Password hashing.
- HTTPS through Caddy and TLS certificates.
- Environment variables loaded from .env.
- .env excluded from Git through .gitignore.
- API containers are accessed through localhost ports.
- Public HTTP/HTTPS traffic enters through Caddy.
- SSH access is used for server administration.
- Docker and application logs support troubleshooting.

Never commit passwords, tokens or private keys.

## 10. Backup and Recovery

The SQLite database is backed up using:

    /usr/local/bin/fittrack-backup.sh

Backups are stored under:

    /var/backups/fittrack/

A cron job runs the backup script daily at 02:00 UTC.
The script retains the latest seven days of local backups.

A backup was manually tested and restored to a separate SQLite
database file. The restored database passed PRAGMA integrity_check.

Recovery objectives for this prototype:

- Target RPO: up to 24 hours, based on daily backups.
- Target RTO: approximately 1 hour for manual restoration.

These are project targets, not measured service guarantees.

Current limitation: backups are stored on the same VM. Off-site
backup storage is a future improvement.

A replica is not a backup: replication helps availability, while
backups provide recovery from accidental deletion or corruption.

## 11. Cost Considerations

The project uses a Google Cloud Compute Engine VM and supporting
services.

Potential costs include:
- VM compute time
- Persistent disk storage
- Network egress
- External IP address
- Backup storage
- Domain and TLS renewal services where applicable

DuckDNS and Let's Encrypt provide free services under their
respective usage terms. Docker, FastAPI, Redis and SQLite are
open-source software.

Actual cloud costs depend on region, machine type, disk size,
network traffic and billing configuration. Check Google Cloud
Billing for the real project cost.

## 12. Limitations and Future Improvements

- Move SQLite to a managed database such as Cloud SQL.
- Store backups off-site in cloud object storage.
- Consider managed messaging and serverless functions.
- Add monitoring and alerting.
- Improve automated recovery and deployment.
- Evaluate Kubernetes for larger-scale orchestration.
