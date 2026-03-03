#!/bin/bash
# Smoke test: Validate Plane module compose configuration.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/plane/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Plane compose fragment not found."

for svc in "  plane-web:" "  plane-api:" "  plane-worker:" "  plane-db:" "  plane-redis:" "  plane-mq:" "  plane-minio:"; do
    grep -q "^${svc}$" "$COMPOSE_FILE" || log_error "Missing service block: ${svc}"
done

grep -Fq 'profiles:' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- plane$' "$COMPOSE_FILE"

# No direct host ports for Plane module services/dependencies.
if awk '
    /^services:/ { in_services=1; next }
    in_services && /^networks:|^volumes:/ { exit }
    in_services && /^[[:space:]]+ports:/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "Plane module should not publish host ports directly."
fi

# Traefik labels and service port wiring.
grep -Fq 'traefik.http.routers.plane-web.rule=Host(`${PLANE_HOSTNAME:-plane}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.plane-websecure.middlewares=security-headers@file' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.plane-web-service.loadbalancer.server.port=3000' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.plane-websecure.tls.certresolver=${TLS_CERT_RESOLVER:-}' "$COMPOSE_FILE"

# Internal network and persistence.
grep -Fq 'plane-internal:' "$COMPOSE_FILE"
grep -Fq 'internal: true' "$COMPOSE_FILE"
grep -Fq 'plane-pgdata:' "$COMPOSE_FILE"
grep -Fq 'plane-redisdata:' "$COMPOSE_FILE"
grep -Fq 'plane-rabbitmq-data:' "$COMPOSE_FILE"
grep -Fq 'plane-uploads:' "$COMPOSE_FILE"

# Startup coordination and healthchecks.
grep -Fq 'condition: service_healthy' "$COMPOSE_FILE"
grep -Fq 'healthcheck:' "$COMPOSE_FILE"
grep -Fq 'pg_isready' "$COMPOSE_FILE"
grep -Fq 'redis-cli", "ping"' "$COMPOSE_FILE"
grep -Fq 'rabbitmq-diagnostics", "ping"' "$COMPOSE_FILE"

log_success "Plane service configuration test passed."
