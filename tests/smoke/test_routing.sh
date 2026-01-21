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
HOSTS_SCRIPT="${SCRIPT_DIR}/../../scripts/hosts-subdomains.sh"
TARGET_HOST="whoami.${DEV_DOMAIN}"

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

log_info "Checking routing to whoami service at ${WHOAMI_URL}..."

TARGET_IP=$(resolve_target_ip "$TARGET_HOST" || true)
if [ -z "$TARGET_IP" ]; then
    log_error "Unable to resolve ${TARGET_HOST}. Apply hosts or DNS (e.g., sudo make hosts-apply)."
fi

# Use curl to access the whoami service via Traefik.
# -k: Insecure, allows self-signed certs.
# -s: Silent.
# Check for a specific string "Hostname" in the whoami output.
# The whoami service typically returns JSON or plain text with "Hostname" and container details.
if curl -k -s --resolve "${TARGET_HOST}:443:${TARGET_IP}" "${WHOAMI_URL}" | grep -q "Hostname"; then
    log_success "Routing to whoami service successful."
    exit 0
else
    log_error "Routing to whoami service FAILED."
    log_error "Could not find 'Hostname' in the response from ${WHOAMI_URL}."
    log_error "Ensure 'whoami.${DEV_DOMAIN}' is correctly mapped in /etc/hosts and services are up."
    exit 1
fi
