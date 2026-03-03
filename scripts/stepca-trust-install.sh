#!/bin/bash
# File: scripts/stepca-trust-install.sh
#
# Install the Step-CA root certificate into the Ubuntu 24.04 system trust store.
#
# Usage: sudo ./scripts/stepca-trust-install.sh
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
        log_error "This script must be run as root. Try: sudo ./scripts/stepca-trust-install.sh"
    fi
}

resolve_trust_user() {
    if [ -n "${STEPCA_TRUST_USER:-}" ]; then
        printf '%s\n' "${STEPCA_TRUST_USER}"
        return
    fi
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        printf '%s\n' "${SUDO_USER}"
        return
    fi
    printf '%s\n' "root"
}

resolve_user_home() {
    local user="$1"
    getent passwd "$user" | cut -d: -f6
}

install_nss_trust() {
    local cert_path="$1"
    local trust_user="$2"
    local user_home
    user_home="$(resolve_user_home "$trust_user")"

    if [ -z "$user_home" ] || [ ! -d "$user_home" ]; then
        log_warn "Skipping NSS trust: cannot resolve home for user '$trust_user'."
        return
    fi

    if ! command -v certutil >/dev/null 2>&1; then
        log_warn "Skipping NSS trust: 'certutil' not found. Install with: sudo apt-get install -y libnss3-tools"
        return
    fi

    local db
    local dbs=(
        "${user_home}/.pki/nssdb"
        "${user_home}/snap/chromium/current/.pki/nssdb"
        "${user_home}/snap/chrome/current/.pki/nssdb"
    )

    for db in "${dbs[@]}"; do
        if [ ! -d "$db" ]; then
            continue
        fi
        if [ ! -f "$db/cert9.db" ]; then
            sudo -u "$trust_user" certutil -d "sql:${db}" -N --empty-password >/dev/null 2>&1 || true
        fi
        sudo -u "$trust_user" certutil -d "sql:${db}" -D -n "stepca-root-local" >/dev/null 2>&1 || true
        sudo -u "$trust_user" certutil -d "sql:${db}" -A -t "CT,C,C" -n "stepca-root-local" -i "$cert_path" >/dev/null
        log_info "Installed NSS trust in ${db} (user: ${trust_user})"
    done
}

CA_CERT_PATH="${STEPCA_CA_CERT_PATH:-./services/step-ca/config/ca.crt}"
INSTALL_CERT_NAME="step-ca-root.crt"
INSTALL_CERT_PATH="/usr/local/share/ca-certificates/${INSTALL_CERT_NAME}"

check_ubuntu_24_04
check_root

if [ ! -f "$CA_CERT_PATH" ]; then
    log_error "Step-CA root certificate not found at '$CA_CERT_PATH'.\nRun: ./scripts/compose.sh --profile stepca cp step-ca:/home/step/config/ca.crt services/step-ca/config/ca.crt"
fi

case "$CA_CERT_PATH" in
    */secrets/*|*services/step-ca/secrets*)
        log_error "Refusing to read from secrets directory. Use the public CA cert only."
        ;;
esac

if grep -q "PRIVATE KEY" "$CA_CERT_PATH"; then
    log_error "Refusing to use private key material from '$CA_CERT_PATH'."
fi

if ! openssl x509 -in "$CA_CERT_PATH" -noout >/dev/null 2>&1; then
    log_error "File at '$CA_CERT_PATH' is not a valid X.509 certificate."
fi

log_info "Installing Step-CA root certificate to system trust store..."
install -m 0644 "$CA_CERT_PATH" "$INSTALL_CERT_PATH"
update-ca-certificates >/dev/null
install_nss_trust "$CA_CERT_PATH" "$(resolve_trust_user)"

log_success "Installed Step-CA root certificate at '$INSTALL_CERT_PATH'."
