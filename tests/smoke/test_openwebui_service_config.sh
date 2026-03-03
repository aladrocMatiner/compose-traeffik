#!/bin/bash
# Smoke test: Validate OpenWebUI module compose configuration.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/openwebui/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "OpenWebUI compose fragment not found."

grep -q '^  openwebui:$' "$COMPOSE_FILE" || log_error "Missing service block: openwebui"
grep -Fq 'profiles:' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- webui$' "$COMPOSE_FILE"

if awk '
    /^services:/ { in_services=1; next }
    in_services && /^volumes:|^networks:/ { exit }
    in_services && /^[[:space:]]+ports:/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "OpenWebUI module should not publish host ports directly."
fi

grep -Fq 'traefik.http.routers.openwebui-web.rule=Host(`${OPENWEBUI_HOSTNAME:-openwebui}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.openwebui-service.loadbalancer.server.port=8080' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.openwebui-websecure.tls.certresolver=${TLS_CERT_RESOLVER:-}' "$COMPOSE_FILE"
grep -Fq 'openwebui-data:/app/backend/data' "$COMPOSE_FILE"

log_success "OpenWebUI service configuration test passed."
