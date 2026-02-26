#!/bin/bash
# Smoke test: Validate Rocket.Chat compose fragment wiring and labels.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/rocketchat/compose.yml"

[ -f "$COMPOSE_FILE" ] || log_error "Rocket.Chat compose file not found."
check_command grep

required_patterns=(
  'profiles:'
  'rocketchat-mongodb-init'
  'rocketchat-nats'
  'traefik.http.routers.rocketchat-websecure.rule=Host(`rocketchat.${DEV_DOMAIN}`)'
  'env_file:'
  'ROCKETCHAT_RENDERED_ENV_PATH'
  'prometheus.io/scrape=${ROCKETCHAT_OBSERVABILITY_ENABLED:-false}'
  'rocketchat-internal:'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Fq "$pattern" "$COMPOSE_FILE"; then
    log_error "Rocket.Chat compose wiring missing pattern: $pattern"
  fi
done

# App service should not publish host ports directly (Traefik fronting expected).
if awk '
  /^  rocketchat:/ { in_service=1; next }
  in_service && /^  [a-zA-Z0-9_.-]+:/ { exit }
  in_service && /^    ports:/ { found=1 }
  END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
  log_error "Rocket.Chat app service should not publish host ports directly."
fi

log_success "Rocket.Chat compose wiring test passed."
