#!/bin/bash
# File: scripts/local-ca-trust-install.sh
#
# Install the Mode A local CA certificate into the Ubuntu 24.04 system trust store.
#
# Usage: sudo ./scripts/local-ca-trust-install.sh
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

check_root() {
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        log_error "This script must be run as root. Try: sudo ./scripts/local-ca-trust-install.sh"
    fi
}

CA_CERT_PATH="${LOCAL_CA_CERT_PATH:-./shared/certs/local-ca/ca.crt}"
INSTALL_CERT_NAME="local-ca-root.crt"
INSTALL_CERT_PATH="/usr/local/share/ca-certificates/${INSTALL_CERT_NAME}"

check_ubuntu_24_04
check_root

if [ ! -f "$CA_CERT_PATH" ]; then
    log_error "Local CA certificate not found at '$CA_CERT_PATH'. Run: make certs-local"
fi

if grep -q "PRIVATE KEY" "$CA_CERT_PATH"; then
    log_error "Refusing to use private key material from '$CA_CERT_PATH'."
fi

if ! openssl x509 -in "$CA_CERT_PATH" -noout >/dev/null 2>&1; then
    log_error "File at '$CA_CERT_PATH' is not a valid X.509 certificate."
fi

log_info "Installing local CA certificate to system trust store..."
install -m 0644 "$CA_CERT_PATH" "$INSTALL_CERT_PATH"
update-ca-certificates >/dev/null

log_success "Installed local CA certificate at '$INSTALL_CERT_PATH'."
