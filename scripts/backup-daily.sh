#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/backup-database.sh" platform_prod daily 7

# Add when Budget goes live:
# "$SCRIPT_DIR/backup-database.sh" budget_prod daily 7