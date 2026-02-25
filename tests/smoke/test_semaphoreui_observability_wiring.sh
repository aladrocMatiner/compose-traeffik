#!/bin/bash
# Smoke test: Validate Semaphore UI observability wiring (static only).

set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
COMPOSE_FILE="$SCRIPT_DIR/../../services/semaphoreui/compose.yml"

[ -f "$COMPOSE_FILE" ] || log_error "Missing Semaphore UI compose file."

for needle in \
  'com.aladroc.observability.enabled=${SEMAPHOREUI_OBSERVABILITY_ENABLED:-false}' \
  'com.aladroc.observability.discovery=${SEMAPHOREUI_OBSERVABILITY_DISCOVERY:-labels}' \
  'com.aladroc.observability.logs=true' \
  'com.aladroc.observability.metrics=false'; do
  grep -Fq "$needle" "$COMPOSE_FILE" || log_error "Missing observability wiring label: $needle"
done

if grep -Eq 'traefik\.http\.routers\..*(metrics|telemetry)' "$COMPOSE_FILE"; then
  log_error "Unexpected public telemetry router found in Semaphore UI compose labels."
fi

echo "SUCCESS: Semaphore UI observability wiring test passed."
