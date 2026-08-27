#!/bin/bash

set -euo pipefail

CONTAINER="alanwilliams-postgres"
POSTGRES_USER="postgres_admin"

BACKUP_ROOT="/mnt/server-backups/postgres"
GDRIVE_ROOT="gdrive:ServerBackups/postgres"

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <database> <daily|weekly> <retention>"
    exit 1
fi

DATABASE="$1"
FREQUENCY="$2"
RETENTION="$3"

if [[ "$FREQUENCY" != "daily" && "$FREQUENCY" != "weekly" ]]; then
    echo "ERROR: Frequency must be daily or weekly."
    exit 1
fi

if ! [[ "$RETENTION" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: Retention must be a positive integer."
    exit 1
fi

BACKUP_DIR="${BACKUP_ROOT}/${DATABASE}/${FREQUENCY}"
GDRIVE_DIR="${GDRIVE_ROOT}/${DATABASE}/${FREQUENCY}"

DATE=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="${BACKUP_DIR}/${DATABASE}_${DATE}.dump"

if ! mountpoint -q /mnt/server-backups; then
    echo "ERROR: ServerBackups drive is not mounted."
    exit 1
fi

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL container '$CONTAINER' does not exist."
    exit 1
fi

if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" != "true" ]; then
    echo "ERROR: PostgreSQL container '$CONTAINER' is not running."
    exit 1
fi

if ! docker exec "$CONTAINER" \
    psql -U "$POSTGRES_USER" -d postgres -tAc \
    "SELECT 1 FROM pg_database WHERE datname='$DATABASE'" \
    | grep -q 1; then
    echo "ERROR: Database '$DATABASE' does not exist."
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting ${FREQUENCY} backup of ${DATABASE}..."

docker exec "$CONTAINER" pg_dump \
    -U "$POSTGRES_USER" \
    -d "$DATABASE" \
    -Fc > "$BACKUP_FILE"

if [ ! -s "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file is empty."
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "Local backup created:"
ls -lh "$BACKUP_FILE"

echo "Uploading to Google Drive..."

rclone copyto \
    "$BACKUP_FILE" \
    "${GDRIVE_DIR}/$(basename "$BACKUP_FILE")"

echo "Google Drive upload complete."

# Local retention.
ls -1t "$BACKUP_DIR"/"${DATABASE}"_*.dump 2>/dev/null \
    | tail -n +"$((RETENTION + 1))" \
    | xargs -r rm -f

# Google Drive retention.
rclone lsf "$GDRIVE_DIR" \
    --files-only \
    --include "${DATABASE}_*.dump" \
    | sort -r \
    | tail -n +"$((RETENTION + 1))" \
    | while read -r old_backup; do
        [ -n "$old_backup" ] &&
            rclone deletefile "${GDRIVE_DIR}/${old_backup}"
    done

echo "[$(date)] ${DATABASE} ${FREQUENCY} backup completed successfully."