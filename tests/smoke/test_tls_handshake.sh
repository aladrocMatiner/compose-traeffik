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

# Use openssl s_client to connect and get certificate details.
# -connect: Host and port to connect to.
# -servername: SNI hostname.
# -showcerts: Show all certificates in the chain.
# -verify_return_code: Print 0 on success, non-zero on failure.
# -no_verify: Do not attempt to verify the certificate chain (useful for self-signed).
# -prexit: Exit immediately after processing handshake.
# We then grep for the subject (CN) and Subject Alternative Names (SANs)
# in the certificate output.

TLS_OUTPUT=$(echo | openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" \
    -servername "${TARGET_HOST}" -showcerts -verify_return_code -prexit -quiet 2>&1)

if echo "${TLS_OUTPUT}" | grep -q "verify return code: 0 (ok)"; then
    log_info "TLS handshake successful."

    # Now, check certificate subject and SANs
    # In Mode A, we expect CN=*.${DEV_DOMAIN} and SANs including whoami.${DEV_DOMAIN}
    if echo "${TLS_OUTPUT}" | grep -q "subject=CN = *.${DEV_DOMAIN}"; then
        log_success "Certificate Subject CN matches expected wildcard domain."
    else
        log_error "Certificate Subject CN does NOT match expected wildcard domain."
        log_info "Actual output:\n${TLS_OUTPUT}"
        exit 1
    fi

    if echo "${TLS_OUTPUT}" | grep -q "DNS:whoami.${DEV_DOMAIN}"; then
        log_success "Certificate SANs include whoami.${DEV_DOMAIN}."
    else
        log_error "Certificate SANs do NOT include whoami.${DEV_DOMAIN}."
        log_info "Actual output:\n${TLS_OUTPUT}"
        exit 1
    fi

    exit 0
else
    log_error "TLS handshake FAILED for ${TARGET_HOST}:${TARGET_PORT}."
    log_error "Check 'make logs' for Traefik and your certificate setup."
    log_info "OpenSSL output:\n${TLS_OUTPUT}"
    exit 1
fi
