#!/bin/bash
# File: scripts/local-ca-trust-verify.sh
#
# Verify that the Mode A local CA certificate is trusted by Ubuntu 24.04.
#
# Usage: ./scripts/local-ca-trust-verify.sh
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_command "openssl"

check_ubuntu_24_04() {
    if [ ! -f /etc/os-release ]; then
        log_error "Cannot detect OS. /etc/os-release not found."
    fi
    # shellcheck disable=SC1091
    . /etc/os-release
    if [ "${ID:-}" != "ubuntu" ] || [ "${VERSION_ID:-}" != "24.04" ]; then
        log_error "Unsupported OS: ${ID:-unknown} ${VERSION_ID:-unknown}. Only Ubuntu 24.04 is supported."
    fi
}

CA_CERT_PATH="${LOCAL_CA_CERT_PATH:-./shared/certs/local-ca/ca.crt}"
INSTALL_CERT_NAME="local-ca-root.crt"
INSTALL_CERT_PATH="/usr/local/share/ca-certificates/${INSTALL_CERT_NAME}"
SYSTEM_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

check_ubuntu_24_04

if [ ! -f "$INSTALL_CERT_PATH" ]; then
    log_error "Installed local CA certificate not found at '$INSTALL_CERT_PATH'. Run local-ca-trust-install first."
fi

if ! openssl verify -CAfile "$SYSTEM_CA_BUNDLE" "$INSTALL_CERT_PATH" >/dev/null 2>&1; then
    log_error "System trust does not include the local CA certificate."
fi

if [ -f "$CA_CERT_PATH" ]; then
    src_fp=$(openssl x509 -in "$CA_CERT_PATH" -noout -fingerprint -sha256 2>/dev/null | cut -d= -f2)
    inst_fp=$(openssl x509 -in "$INSTALL_CERT_PATH" -noout -fingerprint -sha256 2>/dev/null | cut -d= -f2)
    if [ -n "$src_fp" ] && [ -n "$inst_fp" ] && [ "$src_fp" != "$inst_fp" ]; then
        log_warn "Installed certificate does not match '$CA_CERT_PATH'."
    fi
fi

log_success "Local CA certificate is trusted by the OS."
