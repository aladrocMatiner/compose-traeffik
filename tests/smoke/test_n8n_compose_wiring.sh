#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
COMPOSE_FILE="$SCRIPT_DIR/../../services/n8n/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "n8n compose file not found."
for pattern in \
  'n8n-db:' \
  'traefik\.http\.routers\.n8n-websecure\.rule=Host\(`\$\{N8N_HOSTNAME:-n8n\}\.\$\{DEV_DOMAIN\}`\)' \
  'traefik\.http\.services\.n8n-service\.loadbalancer\.server\.port=\$\{N8N_PORT:-5678\}' \
  'services/n8n/config/n8n\.env\.example' \
  'services/n8n/rendered/n8n\.env' \
  'N8N_POSTGRES_IMAGE' \
  'stepca-root-ca\.crt' \
  'n8n-internal' \
  'pg_isready'; do
  grep -Eq "$pattern" "$COMPOSE_FILE" || log_error "Missing expected compose wiring pattern: $pattern"
done
log_success "n8n compose wiring test passed."
