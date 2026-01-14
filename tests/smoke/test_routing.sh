# File: tests/smoke/test_routing.sh
#
# Smoke test: Checks if requests to whoami.${DEV_DOMAIN} are correctly routed.
#
# Usage: ./scripts/tests/smoke/test_routing.sh
#
# Returns 0 on success, 1 on failure.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh" # Adjust path to common.sh

load_env
check_env_var "DEV_DOMAIN"
check_command "curl"

WHOAMI_URL="https://whoami.${DEV_DOMAIN}"

log_info "Checking routing to whoami service at ${WHOAMI_URL}..."

# Use curl to access the whoami service via Traefik.
# -k: Insecure, allows self-signed certs.
# -s: Silent.
# Check for a specific string "Hostname" in the whoami output.
# The whoami service typically returns JSON or plain text with "Hostname" and container details.
if curl -k -s "${WHOAMI_URL}" | grep -q "Hostname"; then
    log_success "Routing to whoami service successful."
    exit 0
else
    log_error "Routing to whoami service FAILED."
    log_error "Could not find 'Hostname' in the response from ${WHOAMI_URL}."
    log_error "Ensure 'whoami.${DEV_DOMAIN}' is correctly mapped in /etc/hosts and services are up."
    exit 1
fi
