#!/bin/bash
# Smoke test: Validate Docling module compose configuration.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/docling/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Docling compose fragment not found."

for svc in "  docling:" "  docling-redis:"; do
    grep -q "^${svc}$" "$COMPOSE_FILE" || log_error "Missing service block: ${svc}"
done

grep -Fq 'profiles:' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- docling$' "$COMPOSE_FILE"

if awk '
    /^services:/ { in_services=1; next }
    in_services && /^networks:|^volumes:/ { exit }
    in_services && /^[[:space:]]+ports:/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "Docling module should not publish host ports directly."
fi

grep -Fq 'traefik.http.routers.docling-web.rule=Host(`${DOCLING_HOSTNAME:-docling}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.docling-websecure.middlewares=${DOCLING_TRAEFIK_MIDDLEWARES:-security-headers@file}' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.docling-service.loadbalancer.server.port=5001' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.docling-websecure.tls.certresolver=${TLS_CERT_RESOLVER:-}' "$COMPOSE_FILE"

grep -Fq 'docling-internal:' "$COMPOSE_FILE"
grep -Fq 'internal: true' "$COMPOSE_FILE"
grep -Fq 'docling-artifacts:' "$COMPOSE_FILE"
grep -Fq 'docling-scratch:' "$COMPOSE_FILE"
grep -Fq 'docling-model-cache:' "$COMPOSE_FILE"
grep -Fq 'docling-redis-data:' "$COMPOSE_FILE"

grep -Fq 'condition: service_healthy' "$COMPOSE_FILE"
grep -Fq 'healthcheck:' "$COMPOSE_FILE"
grep -Fq 'redis-cli -a' "$COMPOSE_FILE"

log_success "Docling service configuration test passed."
