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
if [ -z "${HTTP_TO_HTTPS_MIDDLEWARE:-}" ]; then
    check_env_var "HTTP_TO_HTTPS_REDIRECT"
fi
check_command "curl"

TARGET_HTTP_URL="http://whoami.${DEV_DOMAIN}"
TARGET_HTTPS_URL="https://whoami.${DEV_DOMAIN}"
TARGET_HOST="whoami.${DEV_DOMAIN}"
HOSTS_SCRIPT="${SCRIPT_DIR}/../../scripts/hosts-subdomains.sh"

resolve_target_ip() {
    local host="$1"
    local ip

    ip=$(getent hosts "$host" | awk '{print $1; exit}')
    if [ -n "$ip" ]; then
        printf '%s' "$ip"
        return 0
    fi

    if [ -z "${BASE_DOMAIN:-}" ]; then
        return 1
    fi

    if [ "${DEV_DOMAIN}" != "${BASE_DOMAIN}" ]; then
        log_error "DNS resolution failed for ${host} and DEV_DOMAIN (${DEV_DOMAIN}) != BASE_DOMAIN (${BASE_DOMAIN})."
    fi

    ip=$("$HOSTS_SCRIPT" --env-file .env generate | awk -v host="whoami.${BASE_DOMAIN}" '$2==host {print $1; exit}')
    if [ -n "$ip" ]; then
        printf '%s' "$ip"
        return 0
    fi

    return 1
}

log_info "Checking HTTP to HTTPS redirect for ${TARGET_HTTP_URL}..."

TARGET_IP=$(resolve_target_ip "$TARGET_HOST" || true)
if [ -z "$TARGET_IP" ]; then
    log_error "Unable to resolve ${TARGET_HOST}. Apply hosts or DNS (e.g., sudo make hosts-apply)."
fi

EXPECTED_REDIRECT="false"
if [ -n "${HTTP_TO_HTTPS_MIDDLEWARE:-}" ]; then
    if [ "${HTTP_TO_HTTPS_MIDDLEWARE}" = "redirect-to-https@file" ]; then
        EXPECTED_REDIRECT="true"
    elif [ "${HTTP_TO_HTTPS_MIDDLEWARE}" = "noop@file" ]; then
        EXPECTED_REDIRECT="false"
    else
        log_error "Unknown HTTP_TO_HTTPS_MIDDLEWARE value: ${HTTP_TO_HTTPS_MIDDLEWARE}"
    fi
else
    if [ "${HTTP_TO_HTTPS_REDIRECT}" = "true" ]; then
        EXPECTED_REDIRECT="true"
    fi
fi

if [ "${EXPECTED_REDIRECT}" = "true" ]; then
    # Use curl to follow redirects and check the final URL.
    # -k: Insecure, allows self-signed certs.
    # -s: Silent.
    # -L: Follow redirects.
    # -o /dev/null: Discard body output.
    # -w %{url_effective}: Print the final URL after redirects.
    FINAL_URL=$(curl -k -s -L -o /dev/null -w "%{url_effective}" \
        --resolve "${TARGET_HOST}:80:${TARGET_IP}" \
        --resolve "${TARGET_HOST}:443:${TARGET_IP}" \
        "${TARGET_HTTP_URL}")
    FINAL_URL_STRIPPED="${FINAL_URL%/}"
    TARGET_HTTPS_URL_STRIPPED="${TARGET_HTTPS_URL%/}"

    if [ "$FINAL_URL_STRIPPED" = "${TARGET_HTTPS_URL_STRIPPED}" ]; then
        log_success "HTTP to HTTPS redirect successful. Final URL: ${FINAL_URL}"
        exit 0
    fi

    log_error "HTTP to HTTPS redirect FAILED."
    log_error "Expected final URL: ${TARGET_HTTPS_URL}"
    log_error "Actual final URL: ${FINAL_URL}"
    log_error "Ensure 'HTTP_TO_HTTPS_REDIRECT=true' in .env and Traefik is configured correctly."
    exit 1
fi

# Redirect disabled: ensure HTTP does not redirect.
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    --resolve "${TARGET_HOST}:80:${TARGET_IP}" \
    "${TARGET_HTTP_URL}")
REDIRECT_URL=$(curl -s -o /dev/null -w "%{redirect_url}" \
    --resolve "${TARGET_HOST}:80:${TARGET_IP}" \
    "${TARGET_HTTP_URL}")

if [ "$HTTP_CODE" -eq 200 ] && [ -z "$REDIRECT_URL" ]; then
    log_success "HTTP redirect disabled as expected."
    exit 0
fi

log_error "HTTP redirect was expected to be disabled but a redirect was detected."
log_error "HTTP status: ${HTTP_CODE}"
log_error "Redirect URL: ${REDIRECT_URL}"
exit 1
