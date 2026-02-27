#!/bin/bash
# Smoke test: Validate CTFd module compose configuration.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/ctfd/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "CTFd compose fragment not found."

for svc in "  ctfd:" "  ctfd-db:" "  ctfd-redis:"; do
    grep -q "^${svc}$" "$COMPOSE_FILE" || log_error "Missing service block: ${svc}"
done

grep -Fq 'profiles:' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- ctfd$' "$COMPOSE_FILE"

# No direct host ports for app/db/cache
if awk '
    /^services:/ { in_services=1; next }
    in_services && /^networks:|^volumes:/ { exit }
    in_services && /^[[:space:]]+ports:/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "CTFd module should not publish host ports directly."
fi

# Traefik labels and service port wiring
grep -Fq 'traefik.http.routers.ctfd-web.rule=Host(`${CTFD_HOSTNAME:-ctfd}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.ctfd-websecure.middlewares=security-headers@file' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.ctfd-service.loadbalancer.server.port=8000' "$COMPOSE_FILE"

# Internal network and persistence
grep -Fq 'ctfd-internal:' "$COMPOSE_FILE"
grep -Fq 'internal: true' "$COMPOSE_FILE"
grep -Fq 'ctfd-db-data:' "$COMPOSE_FILE"
grep -Fq 'ctfd-redis-data:' "$COMPOSE_FILE"
grep -Fq 'ctfd-uploads:' "$COMPOSE_FILE"
grep -Fq 'ctfd-logs:' "$COMPOSE_FILE"

# Startup coordination and healthchecks
grep -Fq 'condition: service_healthy' "$COMPOSE_FILE"
grep -Fq 'healthcheck:' "$COMPOSE_FILE"
grep -Fq 'mariadb-admin ping' "$COMPOSE_FILE"
grep -Fq 'redis-cli", "ping"' "$COMPOSE_FILE"

log_success "CTFd service configuration test passed."
