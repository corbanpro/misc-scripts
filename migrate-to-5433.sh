#!/bin/bash
# Migrate local databases to pgvector on port 5433 (Tilt).
# Requires copydb.sh in the same directory. Uses -f to overwrite existing 5433 targets.
#
# Source summary:
#   5432 (data-fetch db): app databases from legacy docker-compose
#   5431: data-miner / MAS memory databases
#   5433: target (pgvector) — names must not change
#
# Skipped: llm-eval-dev (no legacy source on 5432/5431; keep existing 5433 data)
#
# Warning: 5432 is Postgres 17, 5433 is Postgres 14. Cross-version dumps may fail;
# if one fails, try pg_dump with --no-sync or upgrade the pgvector image.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPYDB="${SCRIPT_DIR}/copydb.sh"

if [[ ! -x "$COPYDB" ]]; then
	echo "❌ Expected executable copydb.sh at $COPYDB"
	exit 1
fi

run() {
	echo ""
	echo "==> $*"
	"$COPYDB" "$@"
}

# --- From 5432 ---

run -s credentials-service-dev -t creds-dev -P 5432 -T 5433 -f
run -s integration-crm-dev -t crm-dev -P 5432 -T 5433 -f
run -s data-enrichment-dev -t enrichment-dev -P 5432 -T 5433 -f
run -s channel_manager -t channel-manager-dev -P 5432 -T 5433 -f
run -s datafetch2 -t data-fetch-dev -P 5432 -T 5433 -f
run -s toolservice -t toolservice-dev -P 5432 -T 5433 -f

# --- From 5431 ---

run -s miner_db -t data-miner-dev -P 5431 -T 5433 -f
run -s crewai_memory -t mas-dev -P 5431 -T 5433 -f

echo ""
echo "✅ All migrations finished."
