# File: tests/smoke/test_traefik_ready.sh
#
# Smoke test: Checks if Traefik's API/health endpoint is reachable.
#
# Usage: ./scripts/tests/smoke/test_traefik_ready.sh
#
# Returns 0 on success, 1 on failure.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh" # Adjust path to common.sh

load_env
check_env_var "DEV_DOMAIN"
check_command "curl"

TRAEFIK_HEALTH_URL="https://traefik.${DEV_DOMAIN}/api/health"

log_info "Checking Traefik readiness at ${TRAEFIK_HEALTH_URL}..."

# Use curl to hit Traefik's health endpoint.
# -k: Insecure, allows self-signed certs (useful for local dev until CA is trusted).
# -s: Silent, doesn't show progress meter.
# -o /dev/null: Discard output.
# -w %{http_code}: Print HTTP status code.
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" "${TRAEFIK_HEALTH_URL}")

if [ "$HTTP_CODE" -eq 200 ]; then
    log_success "Traefik is ready (HTTP 200 from health endpoint)."
    exit 0
else
    log_error "Traefik is NOT ready. Received HTTP status code: ${HTTP_CODE}."
    log_error "Check 'make logs' for Traefik service for details."
    exit 1
fi
