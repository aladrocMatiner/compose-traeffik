#!/bin/bash
# Smoke test: Validate FreeIPA module compose configuration.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/freeipa/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "FreeIPA compose fragment not found."

grep -q '^  freeipa:$' "$COMPOSE_FILE" || log_error "Missing service block: freeipa"
grep -Fq 'profiles:' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- freeipa$' "$COMPOSE_FILE"

if awk '
    /^services:/ { in_services=1; next }
    in_services && /^networks:|^volumes:/ { exit }
    in_services && /^[[:space:]]+ports:/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "FreeIPA module should not publish host ports directly."
fi

grep -Fq 'traefik.http.routers.freeipa-web.rule=Host(`${FREEIPA_HOSTNAME:-freeipa}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.freeipa-websecure.middlewares=${FREEIPA_TRAEFIK_MIDDLEWARES:-security-headers@file}' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.freeipa-service.loadbalancer.server.port=80' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.freeipa-websecure.tls.certresolver=${TLS_CERT_RESOLVER:-}' "$COMPOSE_FILE"

grep -Fq 'FREEIPA_TLS_MODE=${FREEIPA_TLS_MODE:-stepca-acme}' "$COMPOSE_FILE"
grep -Fq 'FREEIPA_KEYCLOAK_ENABLED=${FREEIPA_KEYCLOAK_ENABLED:-false}' "$COMPOSE_FILE"
grep -Fq 'FREEIPA_OBSERVABILITY_ENABLED=${FREEIPA_OBSERVABILITY_ENABLED:-false}' "$COMPOSE_FILE"

grep -Fq 'freeipa-internal:' "$COMPOSE_FILE"
grep -Fq 'internal: true' "$COMPOSE_FILE"
grep -Fq 'freeipa-data:' "$COMPOSE_FILE"

log_success "FreeIPA service configuration test passed."
