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

docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d postgres -c "\l"
