#!/bin/bash
# Smoke test: Validate Semaphore UI compose fragment.

set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
COMPOSE_FILE="$SCRIPT_DIR/../../services/semaphoreui/compose.yml"

[ -f "$COMPOSE_FILE" ] || log_error "Semaphore UI compose file not found."

for needle in \
  'container_name: semaphoreui' \
  'container_name: semaphoreui-db' \
  'profiles:' \
  '- semaphoreui' \
  'SEMAPHORE_DB_DIALECT=postgres' \
  'SEMAPHORE_WEB_ROOT=https://${SEMAPHOREUI_HOSTNAME:-semaphore}.${DEV_DOMAIN}' \
  'SEMAPHORE_OIDC_PROVIDERS=${SEMAPHOREUI_OIDC_PROVIDERS_JSON:-{}}' \
  'SEMAPHORE_PASSWORD_LOGIN_DISABLED=${SEMAPHOREUI_PASSWORD_LOGIN_DISABLED:-false}' \
  'traefik.http.routers.semaphoreui-websecure.rule=Host(`${SEMAPHOREUI_HOSTNAME:-semaphore}.${DEV_DOMAIN}`)' \
  'traefik.http.services.semaphoreui-service.loadbalancer.server.port=3000' \
  'semaphoreui-internal:' \
  'internal: true' \
  'semaphoreui-db-data:'; do
  grep -Fq -- "$needle" "$COMPOSE_FILE" || log_error "Missing expected compose config: $needle"
done

if grep -Eq '^\s+ports:' "$COMPOSE_FILE"; then
  log_error "Semaphore UI compose fragment should not publish host ports by default."
fi

log_success "Semaphore UI service configuration test passed."
