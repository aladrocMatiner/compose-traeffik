#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
COMPOSE_FILE="$SCRIPT_DIR/../../services/keycloak/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Keycloak compose fragment not found."
for needle in \
  'keycloak-db:' \
  'keycloak:' \
  'profiles: ["keycloak"]' \
  'quay.io/keycloak/keycloak:26.5.3' \
  'KC_BOOTSTRAP_ADMIN_USERNAME' \
  'KC_BOOTSTRAP_ADMIN_PASSWORD' \
  'KC_PROXY_HEADERS' \
  'KC_HEALTH_ENABLED' \
  'KC_METRICS_ENABLED' \
  'traefik.http.routers.keycloak-websecure.rule=Host(`' \
  'traefik.http.routers.keycloak-websecure.middlewares=security-headers@file' \
  'traefik.http.services.keycloak-service.loadbalancer.server.port=8080' \
  'keycloak-internal:' \
  'internal: true' \
  'keycloak-db-data:'; do
  grep -Fq "$needle" "$COMPOSE_FILE" || log_error "Missing expected config: $needle"
done
if grep -Eq '^[[:space:]]+ports:' "$COMPOSE_FILE"; then
  log_error "Keycloak compose fragment should not publish host ports by default."
fi
log_success "Keycloak service configuration test passed."
