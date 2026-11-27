#!/bin/bash
set -e

BACKUP_DIR="/var/backups/fittrack"
TIMESTAMP=$(date +%F_%H-%M-%S)
TEMP_FILE="/tmp/fittrack-backup.db"
BUCKET="gs://fittrack-backups-941747335029"

mkdir -p "$BACKUP_DIR"

# Create SQLite backup
docker exec fittrack-api-1 python -c \
'import sqlite3; s=sqlite3.connect("/data/fittrack.db"); d=sqlite3.connect("/tmp/fittrack-backup.db"); s.backup(d); d.close(); s.close()'

# Copy backup from container
docker cp "fittrack-api-1:$TEMP_FILE" "$BACKUP_DIR/fittrack-$TIMESTAMP.db"
docker exec fittrack-api-1 rm -f "$TEMP_FILE"

# Upload to Google Cloud Storage
/snap/bin/gcloud storage cp \
"$BACKUP_DIR/fittrack-$TIMESTAMP.db" "$BUCKET/"

# Keep only seven days of local backups
find "$BACKUP_DIR" -type f -name 'fittrack-*.db' -mtime +7 -delete

echo "Backup and cloud upload completed: fittrack-$TIMESTAMP.db"
