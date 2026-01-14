# File: tests/smoke/test_http_redirect.sh
#
# Smoke test: Checks for HTTP to HTTPS redirection if enabled.
#
# Usage: ./scripts/tests/smoke/test_http_redirect.sh
#
# Returns 0 on success, 1 on failure.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh" # Adjust path to common.sh

load_env
check_env_var "DEV_DOMAIN"
check_env_var "HTTP_TO_HTTPS_REDIRECT"
check_command "curl"

TARGET_HTTP_URL="http://whoami.${DEV_DOMAIN}"
TARGET_HTTPS_URL="https://whoami.${DEV_DOMAIN}"

# This test is only relevant if HTTP_TO_HTTPS_REDIRECT is true
if [ "${HTTP_TO_HTTPS_REDIRECT}" != "true" ]; then
    log_warn "HTTP to HTTPS redirect test skipped (HTTP_TO_HTTPS_REDIRECT is not 'true')."
    exit 0
fi

log_info "Checking HTTP to HTTPS redirect for ${TARGET_HTTP_URL}..."

# Use curl to follow redirects and check the final URL.
# -k: Insecure, allows self-signed certs.
# -s: Silent.
# -L: Follow redirects.
# -o /dev/null: Discard body output.
# -w %{url_effective}: Print the final URL after redirects.

FINAL_URL=$(curl -k -s -L -o /dev/null -w "%{url_effective}" "${TARGET_HTTP_URL}")

if [ "$FINAL_URL" = "${TARGET_HTTPS_URL}" ]; then
    log_success "HTTP to HTTPS redirect successful. Final URL: ${FINAL_URL}"
    exit 0
else
    log_error "HTTP to HTTPS redirect FAILED."
    log_error "Expected final URL: ${TARGET_HTTPS_URL}"
    log_error "Actual final URL: ${FINAL_URL}"
    log_error "Ensure 'HTTP_TO_HTTPS_REDIRECT=true' in .env and Traefik is configured correctly."
    exit 1
fi
