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

log_info "Verifying TLS handshake for ${TARGET_HOST}:${TARGET_PORT}..."

# Use openssl s_client to connect and capture certificate details.
# Verification is performed separately with openssl verify to avoid
# s_client CA loading inconsistencies across OpenSSL versions.

CERTS_DIR="${CERTS_DIR:-shared/certs}"
CA_FILE="${CERTS_DIR}/local-ca/ca.crt"

if [ ! -f "${CA_FILE}" ]; then
    log_error "Local CA certificate not found at ${CA_FILE}. Run: make certs-local"
fi

TLS_OUTPUT=$(echo | openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" \
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
