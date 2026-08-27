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

BACKUP_FILE="${1:-}"
TARGET_DATABASE="${2:-}"

if [[ -z "${BACKUP_FILE}" || -z "${TARGET_DATABASE}" ]]; then
  echo "Usage: $0 <backup_file> <target_database>"
  exit 1
fi

if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

if [[ ! "${TARGET_DATABASE}" =~ ^[a-zA-Z0-9_]+$ ]]; then
  echo "Invalid target database name: ${TARGET_DATABASE}"
  exit 1
fi

"$(dirname "$0")/create-database.sh" "${TARGET_DATABASE}"
echo "Restoring ${BACKUP_FILE} -> ${TARGET_DATABASE}"
cat "${BACKUP_FILE}" | docker exec -i "${POSTGRES_CONTAINER}" pg_restore -U "${POSTGRES_USER}" -d "${TARGET_DATABASE}" --clean --if-exists --no-owner --no-privileges
echo "Restore complete: ${TARGET_DATABASE}"
