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
# -CAfile: Use the local CA so verification succeeds for self-signed certs.
# -verify_return_error: Fail verification on error.
# -prexit: Exit immediately after processing handshake.
# We then grep for the subject (CN) and Subject Alternative Names (SANs)
# in the certificate output.

CA_FILE="certs/local-ca/ca.crt"

TLS_OUTPUT=$(echo | openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" \
    -servername "${TARGET_HOST}" -showcerts -CAfile "${CA_FILE}" -verify_return_error -prexit 2>&1)

# Check certificate subject and SANs from the output to confirm handshake and cert content.
if echo "${TLS_OUTPUT}" | grep -Fq "Verify return code: 0 (ok)" \
    && echo "${TLS_OUTPUT}" | grep -Fq "CN = *.${DEV_DOMAIN}"; then
    log_success "TLS handshake successful and certificate matches expected domains."
    exit 0
else
    log_error "TLS handshake or certificate validation failed for ${TARGET_HOST}:${TARGET_PORT}."
    log_error "Check 'make logs' for Traefik and your certificate setup."
    log_info "OpenSSL output:\n${TLS_OUTPUT}"
    exit 1
fi
