#!/bin/bash
# File: tests/smoke/test_tls_handshake.sh
#
# Smoke test: Verifies TLS handshake and certificate details for whoami service.
#
# Usage: ./scripts/tests/smoke/test_tls_handshake.sh
#
# Returns 0 on success, 1 on failure.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh" # Adjust path to common.sh

load_env
check_env_var "DEV_DOMAIN"
check_command "openssl"

TARGET_HOST="whoami.${DEV_DOMAIN}"
TARGET_PORT="443"
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

log_info "Verifying TLS handshake for ${TARGET_HOST}:${TARGET_PORT}..."

# Use openssl s_client to connect and capture certificate details.
# Verification is performed separately with openssl verify to avoid
# s_client CA loading inconsistencies across OpenSSL versions.

CERTS_DIR="${CERTS_DIR:-shared/certs}"
CA_FILE="${CERTS_DIR}/local-ca/ca.crt"

if [ ! -f "${CA_FILE}" ]; then
    log_error "Local CA certificate not found at ${CA_FILE}. Run: make certs-local"
fi

TARGET_IP=$(resolve_target_ip "$TARGET_HOST" || true)
if [ -z "$TARGET_IP" ]; then
    log_error "Unable to resolve ${TARGET_HOST}. Apply hosts or DNS (e.g., sudo make hosts-apply)."
fi

TLS_OUTPUT=$(echo | openssl s_client -connect "${TARGET_IP}:${TARGET_PORT}" \
    -servername "${TARGET_HOST}" -showcerts 2>&1)

if ! echo "${TLS_OUTPUT}" | grep -Fq "CONNECTED"; then
    log_error "TLS handshake failed for ${TARGET_HOST}:${TARGET_PORT}."
fi

TMP_CERT=$(mktemp)
trap 'rm -f "${TMP_CERT}"' EXIT
echo "${TLS_OUTPUT}" | awk '/BEGIN CERTIFICATE/{flag=1} flag{print} /END CERTIFICATE/{exit}' > "${TMP_CERT}"

if ! openssl verify -CAfile "${CA_FILE}" "${TMP_CERT}" >/dev/null 2>&1; then
    log_error "TLS certificate did not verify against local CA at ${CA_FILE}."
fi

if ! openssl x509 -in "${TMP_CERT}" -noout -subject | grep -Fq "CN = *.${DEV_DOMAIN}"; then
    log_error "TLS certificate CN does not match expected wildcard for ${DEV_DOMAIN}."
fi

log_success "TLS handshake successful and certificate matches expected domains."
