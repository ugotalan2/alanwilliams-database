#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/backup-database.sh" agenda_prod weekly 4
"$SCRIPT_DIR/backup-database.sh" platform_prod weekly 4

# Add as each app goes live:
# "$SCRIPT_DIR/backup-database.sh" fitness_prod weekly 4
# "$SCRIPT_DIR/backup-database.sh" chores_prod weekly 4
# "$SCRIPT_DIR/backup-database.sh" budget_prod weekly 4