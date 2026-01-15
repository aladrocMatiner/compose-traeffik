#!/bin/bash
# File: scripts/stepca-trust-uninstall.sh
#
# Remove the Step-CA root certificate from the Ubuntu 24.04 system trust store.
#
# Usage: sudo ./scripts/stepca-trust-uninstall.sh
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env

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
        log_error "This script must be run as root. Try: sudo ./scripts/stepca-trust-uninstall.sh"
    fi
}

INSTALL_CERT_NAME="step-ca-root.crt"
INSTALL_CERT_PATH="/usr/local/share/ca-certificates/${INSTALL_CERT_NAME}"

check_ubuntu_24_04
check_root

if [ ! -f "$INSTALL_CERT_PATH" ]; then
    log_info "No installed Step-CA certificate found at '$INSTALL_CERT_PATH'. Nothing to remove."
    exit 0
fi

log_info "Removing Step-CA root certificate from system trust store..."
rm -f "$INSTALL_CERT_PATH"
update-ca-certificates >/dev/null

log_success "Removed Step-CA root certificate from '$INSTALL_CERT_PATH'."
