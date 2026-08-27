#!/usr/bin/env bash
set -euo pipefail
POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-alanwilliams-postgres}"
POSTGRES_USER="${POSTGRES_USER:-alanwilliams}"
docker exec "${POSTGRES_CONTAINER}" psql -U "${POSTGRES_USER}" -d postgres -c "\l"
