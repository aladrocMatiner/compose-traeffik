#!/bin/bash
# File: scripts/validate-env.sh
#
# Preflight checks for environment variables used by profiles and UI auth.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_ENV="${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH:-}"
COMPOSE_PROFILES_ENV="${COMPOSE_PROFILES:-}"
TRAEFIK_DASHBOARD_ENV="${TRAEFIK_DASHBOARD:-}"
BIND_BIND_ADDRESS_ENV="${BIND_BIND_ADDRESS:-}"
BIND_ALLOW_NONLOCAL_BIND_ENV="${BIND_ALLOW_NONLOCAL_BIND:-}"
WG_SERVER_PORT_ENV="${WG_SERVER_PORT:-}"
WG_BIND_ADDRESS_ENV="${WG_BIND_ADDRESS:-}"
WG_ALLOW_NONLOCAL_BIND_ENV="${WG_ALLOW_NONLOCAL_BIND:-}"
WG_UI_HOSTNAME_ENV="${WG_UI_HOSTNAME:-}"
WG_SERVER_ENDPOINT_ENV="${WG_SERVER_ENDPOINT:-}"
WG_INSECURE_ENV="${WG_INSECURE:-}"

load_env

if [ -n "${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_ENV}" ]; then
    TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH="${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_ENV}"
fi
if [ -n "${COMPOSE_PROFILES_ENV}" ]; then
    COMPOSE_PROFILES="${COMPOSE_PROFILES_ENV}"
fi
if [ -n "${TRAEFIK_DASHBOARD_ENV}" ]; then
    TRAEFIK_DASHBOARD="${TRAEFIK_DASHBOARD_ENV}"
fi
if [ -n "${BIND_BIND_ADDRESS_ENV}" ]; then
    BIND_BIND_ADDRESS="${BIND_BIND_ADDRESS_ENV}"
fi
if [ -n "${BIND_ALLOW_NONLOCAL_BIND_ENV}" ]; then
    BIND_ALLOW_NONLOCAL_BIND="${BIND_ALLOW_NONLOCAL_BIND_ENV}"
fi
if [ -n "${WG_SERVER_PORT_ENV}" ]; then
    WG_SERVER_PORT="${WG_SERVER_PORT_ENV}"
fi
if [ -n "${WG_BIND_ADDRESS_ENV}" ]; then
    WG_BIND_ADDRESS="${WG_BIND_ADDRESS_ENV}"
fi
if [ -n "${WG_ALLOW_NONLOCAL_BIND_ENV}" ]; then
    WG_ALLOW_NONLOCAL_BIND="${WG_ALLOW_NONLOCAL_BIND_ENV}"
fi
if [ -n "${WG_UI_HOSTNAME_ENV}" ]; then
    WG_UI_HOSTNAME="${WG_UI_HOSTNAME_ENV}"
fi
if [ -n "${WG_SERVER_ENDPOINT_ENV}" ]; then
    WG_SERVER_ENDPOINT="${WG_SERVER_ENDPOINT_ENV}"
fi
if [ -n "${WG_INSECURE_ENV}" ]; then
    WG_INSECURE="${WG_INSECURE_ENV}"
fi

resolve_auth_path() {
    local path="$1"
    if [[ "$path" != /etc/traefik/auth/* ]]; then
        log_error "Auth file must be under /etc/traefik/auth/. Got: ${path}"
    fi
    local relative="${path#/etc/traefik/auth/}"
    if [ -z "$relative" ]; then
        log_error "Auth file path must include a filename under /etc/traefik/auth/."
    fi
    if [[ "$relative" == *".."* ]]; then
        log_error "Auth file path must not contain '..': ${path}"
    fi
    echo "${REPO_ROOT}/services/traefik/auth/${relative}"
}

require_auth_file() {
    local label="$1"
    local path="$2"
    if [ -z "$path" ]; then
        log_error "${label} htpasswd path is not set."
    fi
    if [[ "$path" == *.example ]]; then
        log_error "${label} htpasswd path points to an example file. Generate a real htpasswd first."
    fi
    local resolved
    resolved=$(resolve_auth_path "$path")
    if [ ! -f "$resolved" ]; then
        log_error "${label} htpasswd file not found: ${resolved}"
    fi
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

normalize_profiles() {
    local raw="${COMPOSE_PROFILES:-}"
    if [ -z "$raw" ]; then
        COMPOSE_PROFILES_NORMALIZED=""
        return
    fi

    local -a parts=()
    local -a cleaned=()
    local part
    local trimmed

    IFS=',' read -r -a parts <<< "$raw"
    for part in "${parts[@]}"; do
        trimmed=$(trim "$part")
        if [ -z "$trimmed" ]; then
            log_error "COMPOSE_PROFILES contains an empty entry. Remove leading/trailing/double commas."
        fi
        cleaned+=("$trimmed")
    done

    COMPOSE_PROFILES_NORMALIZED="${cleaned[*]}"
}

is_bind_profile_enabled() {
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" bind "*) return 0 ;;
        *) return 1 ;;
    esac
}

is_wg_profile_enabled() {
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" wg "*) return 0 ;;
        *) return 1 ;;
    esac
}

is_ipv4_address() {
    local value="$1"
    if [[ ! "$value" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1
    fi
    IFS='.' read -r a b c d <<< "$value"
    for octet in "$a" "$b" "$c" "$d"; do
        if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
            return 1
        fi
    done
    return 0
}

is_ipv4_loopback() {
    local value="$1"
    if ! is_ipv4_address "$value"; then
        return 1
    fi
    IFS='.' read -r a _ _ _ <<< "$value"
    [ "$a" -eq 127 ]
}

validate_domain_name() {
    local domain="$1"
    local var_name="${2:-BASE_DOMAIN}"
    if [ -z "$domain" ]; then
        log_error "${var_name} is required."
    fi
    if [ "${#domain}" -gt 253 ]; then
        log_error "${var_name} is too long: ${domain}"
    fi
    if [[ ! "$domain" =~ ^[a-z0-9.-]+$ ]]; then
        log_error "${var_name} contains invalid characters: ${domain}"
    fi
    if [[ "$domain" == .* || "$domain" == *. || "$domain" == *..* ]]; then
        log_error "${var_name} has invalid dot placement: ${domain}"
    fi
    IFS='.' read -r -a labels <<< "$domain"
    local label
    for label in "${labels[@]}"; do
        if [ -z "$label" ] || [ "${#label}" -gt 63 ]; then
            log_error "${var_name} label is invalid: ${domain}"
        fi
        if [[ ! "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
            log_error "${var_name} label has invalid format: ${label}"
        fi
    done
}

validate_dns_label() {
    local label="$1"
    if [ -z "$label" ]; then
        log_error "WG_UI_HOSTNAME is required when wg profile is enabled."
    fi
    if [[ "$label" =~ [[:space:]] ]]; then
        log_error "WG_UI_HOSTNAME must not contain spaces: ${label}"
    fi
    if [[ "$label" =~ [A-Z] ]]; then
        log_error "WG_UI_HOSTNAME must be lowercase: ${label}"
    fi
    if [ "${#label}" -gt 63 ]; then
        log_error "WG_UI_HOSTNAME is too long: ${label}"
    fi
    if [[ ! "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        log_error "WG_UI_HOSTNAME must be a valid DNS label: ${label}"
    fi
}

validate_port_number() {
    local name="$1"
    local value="$2"
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        log_error "${name} must be an integer between 1 and 65535. Got: ${value}"
    fi
    if [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
        log_error "${name} must be between 1 and 65535. Got: ${value}"
    fi
}

validate_hostname_or_ipv4() {
    local name="$1"
    local value="$2"
    if [ -z "$value" ]; then
        log_error "${name} is required when wg profile is enabled."
    fi
    if [[ "$value" == *:* || "$value" == */* || "$value" == *" "* ]]; then
        log_error "${name} must be a host/IP only (no port/path/spaces). Got: ${value}"
    fi
    if is_ipv4_address "$value"; then
        return
    fi
    validate_domain_name "$value" "$name"
}

if [ "${TRAEFIK_DASHBOARD:-false}" = "true" ]; then
    require_auth_file "Traefik dashboard" "${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH:-}"
fi

normalize_profiles

if is_bind_profile_enabled; then
    BIND_BIND_ADDRESS_VALUE="${BIND_BIND_ADDRESS:-127.0.0.1}"
    BIND_ALLOW_NONLOCAL_BIND_VALUE="${BIND_ALLOW_NONLOCAL_BIND:-false}"
    validate_domain_name "${BASE_DOMAIN:-}"

    if ! is_ipv4_loopback "${BIND_BIND_ADDRESS_VALUE}"; then
        if [ "${BIND_ALLOW_NONLOCAL_BIND_VALUE}" != "true" ]; then
            log_error "BIND_BIND_ADDRESS must be loopback by default. Set BIND_ALLOW_NONLOCAL_BIND=true for intentional non-local exposure."
        fi
    fi
fi

if is_wg_profile_enabled; then
    WG_SERVER_PORT_VALUE="${WG_SERVER_PORT:-51820}"
    WG_BIND_ADDRESS_VALUE="${WG_BIND_ADDRESS:-127.0.0.1}"
    WG_ALLOW_NONLOCAL_BIND_VALUE="${WG_ALLOW_NONLOCAL_BIND:-false}"
    WG_UI_HOSTNAME_VALUE="${WG_UI_HOSTNAME:-wg}"
    WG_SERVER_ENDPOINT_VALUE="${WG_SERVER_ENDPOINT:-}"
    WG_INSECURE_VALUE="${WG_INSECURE:-false}"

    validate_port_number "WG_SERVER_PORT" "${WG_SERVER_PORT_VALUE}"
    validate_dns_label "${WG_UI_HOSTNAME_VALUE}"
    validate_hostname_or_ipv4 "WG_SERVER_ENDPOINT" "${WG_SERVER_ENDPOINT_VALUE}"

    if ! is_ipv4_address "${WG_BIND_ADDRESS_VALUE}"; then
        log_error "WG_BIND_ADDRESS must be a valid IPv4 address. Got: ${WG_BIND_ADDRESS_VALUE}"
    fi
    if ! is_ipv4_loopback "${WG_BIND_ADDRESS_VALUE}"; then
        if [ "${WG_ALLOW_NONLOCAL_BIND_VALUE}" != "true" ]; then
            log_error "WG_BIND_ADDRESS must be loopback by default. Set WG_ALLOW_NONLOCAL_BIND=true for intentional non-local WireGuard exposure."
        fi
    fi

    if [ "${WG_INSECURE_VALUE}" = "true" ]; then
        log_error "WG_INSECURE=true is not allowed in this Traefik/TLS integration. Keep the wg-easy UI behind Traefik."
    fi
fi
