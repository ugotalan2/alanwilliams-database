#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${PROJECT_DIR}/.env" ]]; then
    set -a
    source "${PROJECT_DIR}/.env"
    set +a
fi

POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-alanwilliams-postgres}"
POSTGRES_USER="${POSTGRES_USER:-postgres_admin}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
BACKUP_DATABASES="${BACKUP_DATABASES:-}"

if [[ -z "${BACKUP_DATABASES}" ]]; then
  echo "BACKUP_DATABASES is required."
  echo 'Example: BACKUP_DATABASES="agenda_prod platform_prod" ./scripts/backup.sh'
  exit 1
fi

mkdir -p "${BACKUP_DIR}"
timestamp="$(date +%Y%m%d-%H%M%S)"

for database in ${BACKUP_DATABASES}; do
  if [[ ! "${database}" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid database name: ${database}"
    exit 1
  fi

  output="${BACKUP_DIR}/${database}-${timestamp}.dump"
  echo "Backing up ${database} -> ${output}"
  docker exec "${POSTGRES_CONTAINER}" pg_dump -U "${POSTGRES_USER}" -d "${database}" -Fc --no-owner --no-privileges > "${output}"
  echo "Backup complete: ${output}"
done
