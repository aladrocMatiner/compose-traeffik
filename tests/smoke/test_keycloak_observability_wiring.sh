#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
COMPOSE_FILE="$SCRIPT_DIR/../../services/keycloak/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Keycloak compose fragment not found."
for needle in \
  'KC_METRICS_ENABLED: ${KEYCLOAK_OBSERVABILITY_ENABLED:-false}' \
  'KC_HTTP_MANAGEMENT_PORT: ${KEYCLOAK_MANAGEMENT_PORT:-9000}' \
  'com.compose-traeffik.observability.discovery=${KEYCLOAK_OBSERVABILITY_DISCOVERY:-labels}' \
  'com.compose-traeffik.observability.metrics.path=/metrics' \
  'com.compose-traeffik.observability.service=keycloak'; do
  grep -Fq "$needle" "$COMPOSE_FILE" || log_error "Missing observability wiring marker: $needle"
done
if grep -Fq 'traefik.http.routers.keycloak-metrics' "$COMPOSE_FILE"; then
  log_error "Keycloak metrics router should not be publicly exposed by default."
fi
log_success "Keycloak observability wiring test passed."
