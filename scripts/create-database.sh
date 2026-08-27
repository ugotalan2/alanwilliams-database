#!/usr/bin/env bash
set -euo pipefail

DATABASE_NAME="${1:-}"
POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-alanwilliams-postgres}"
POSTGRES_USER="${POSTGRES_USER:-alanwilliams}"

if [[ -z "${DATABASE_NAME}" ]]; then
  echo "Usage: $0 <database_name>"
  exit 1
fi

if [[ ! "${DATABASE_NAME}" =~ ^[a-zA-Z0-9_]+$ ]]; then
  echo "Invalid database name: ${DATABASE_NAME}"
  exit 1
fi

exists="$(docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DATABASE_NAME}'")"

if [[ "${exists}" == "1" ]]; then
  echo "Database already exists: ${DATABASE_NAME}"
  exit 0
fi

docker exec "${POSTGRES_CONTAINER}" createdb -U "${POSTGRES_USER}" "${DATABASE_NAME}"
echo "Created database: ${DATABASE_NAME}"
