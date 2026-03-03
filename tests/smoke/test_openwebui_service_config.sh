#!/bin/bash
# Smoke test: Validate OpenWebUI compose fragment contract.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/openwebui/compose.yml"

check_command "grep"

if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "OpenWebUI compose file not found: $COMPOSE_FILE"
fi

if ! grep -q "profiles:" "$COMPOSE_FILE" || ! grep -q -- "- webui" "$COMPOSE_FILE"; then
    log_error "OpenWebUI compose must define profile 'webui'"
fi

if ! grep -q "traefik.http.routers.openwebui-websecure.rule=Host" "$COMPOSE_FILE"; then
    log_error "OpenWebUI secure router host rule is missing"
fi

if ! grep -q "traefik.http.routers.openwebui-websecure.tls.certresolver" "$COMPOSE_FILE"; then
    log_error "OpenWebUI TLS certresolver label is missing"
fi

if ! grep -q "openwebui-data:/app/backend/data" "$COMPOSE_FILE"; then
    log_error "OpenWebUI persistent data volume mapping is missing"
fi

log_success "OpenWebUI service config smoke test passed."
