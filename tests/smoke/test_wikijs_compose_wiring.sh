#!/bin/bash
# Smoke test: Validate Wiki.js compose fragment wiring and Traefik routing labels.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/wikijs/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Wiki.js compose file not found."

for pattern in \
    '^\s+profiles:' \
    'wikijs-db:' \
    'traefik\.http\.routers\.wikijs-websecure\.rule=Host\(`\$\{WIKIJS_HOSTNAME:-wiki\}\.\$\{DEV_DOMAIN\}`\)' \
    'traefik\.http\.services\.wikijs-service\.loadbalancer\.server\.port=\$\{WIKIJS_PORT:-3000\}' \
    'services/wikijs/config/wikijs\.env\.example' \
    'services/wikijs/rendered/wikijs\.env' \
    'stepca-root-ca\.crt' \
    'wikijs-internal' \
    'pg_isready'; do
    grep -Eq "$pattern" "$COMPOSE_FILE" || log_error "Missing expected compose wiring pattern: $pattern"
done

log_success "Wiki.js compose wiring test passed."
