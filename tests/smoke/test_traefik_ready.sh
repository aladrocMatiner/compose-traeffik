# File: tests/smoke/test_traefik_ready.sh
#
# Smoke test: Checks Traefik container status and docker provider configuration.
#
# Usage: ./scripts/tests/smoke/test_traefik_ready.sh
#
# Returns 0 on success, 1 on failure.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh" # Adjust path to common.sh

load_env
check_command "docker"

COMPOSE_CMD="$SCRIPT_DIR/../../scripts/compose.sh"
TRAEFIK_CONFIG="$SCRIPT_DIR/../../services/traefik/traefik.yml"

log_info "Checking Traefik container is running..."
if ! "$COMPOSE_CMD" ps -q traefik | grep -q .; then
    log_error "Traefik container is not running."
fi

log_info "Checking Traefik docker provider configuration..."
if ! grep -q "^  docker:" "$TRAEFIK_CONFIG"; then
    log_error "Traefik docker provider is not configured in services/traefik/traefik.yml."
fi
if ! grep -q "exposedByDefault: false" "$TRAEFIK_CONFIG"; then
    log_error "Traefik docker provider should set exposedByDefault=false."
fi
if ! grep -q "network: traefik-proxy" "$TRAEFIK_CONFIG"; then
    log_error "Traefik docker provider should use network=traefik-proxy."
fi

log_success "Traefik readiness and provider configuration checks passed."
