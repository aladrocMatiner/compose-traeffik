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
SEMAPHOREUI_HOSTNAME_ENV="${SEMAPHOREUI_HOSTNAME:-}"
SEMAPHOREUI_ADMIN_PASSWORD_ENV="${SEMAPHOREUI_ADMIN_PASSWORD:-}"
SEMAPHOREUI_DB_PASSWORD_ENV="${SEMAPHOREUI_DB_PASSWORD:-}"
SEMAPHOREUI_COOKIE_HASH_ENV="${SEMAPHOREUI_COOKIE_HASH:-}"
SEMAPHOREUI_COOKIE_ENCRYPTION_ENV="${SEMAPHOREUI_COOKIE_ENCRYPTION:-}"
SEMAPHOREUI_ACCESS_KEY_ENCRYPTION_ENV="${SEMAPHOREUI_ACCESS_KEY_ENCRYPTION:-}"
SEMAPHOREUI_OIDC_ENABLED_ENV="${SEMAPHOREUI_OIDC_ENABLED:-}"
SEMAPHOREUI_OIDC_PROVIDER_URL_ENV="${SEMAPHOREUI_OIDC_PROVIDER_URL:-}"
SEMAPHOREUI_OIDC_CLIENT_ID_ENV="${SEMAPHOREUI_OIDC_CLIENT_ID:-}"
SEMAPHOREUI_OIDC_CLIENT_SECRET_ENV="${SEMAPHOREUI_OIDC_CLIENT_SECRET:-}"
SEMAPHOREUI_PASSWORD_LOGIN_DISABLED_ENV="${SEMAPHOREUI_PASSWORD_LOGIN_DISABLED:-}"
SEMAPHOREUI_OBSERVABILITY_ENABLED_ENV="${SEMAPHOREUI_OBSERVABILITY_ENABLED:-}"
SEMAPHOREUI_OBSERVABILITY_DISCOVERY_ENV="${SEMAPHOREUI_OBSERVABILITY_DISCOVERY:-}"
SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS_ENV="${SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS:-}"

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
for var_name in \
    SEMAPHOREUI_HOSTNAME \
    SEMAPHOREUI_ADMIN_PASSWORD \
    SEMAPHOREUI_DB_PASSWORD \
    SEMAPHOREUI_COOKIE_HASH \
    SEMAPHOREUI_COOKIE_ENCRYPTION \
    SEMAPHOREUI_ACCESS_KEY_ENCRYPTION \
    SEMAPHOREUI_OIDC_ENABLED \
    SEMAPHOREUI_OIDC_PROVIDER_URL \
    SEMAPHOREUI_OIDC_CLIENT_ID \
    SEMAPHOREUI_OIDC_CLIENT_SECRET \
    SEMAPHOREUI_PASSWORD_LOGIN_DISABLED \
    SEMAPHOREUI_OBSERVABILITY_ENABLED \
    SEMAPHOREUI_OBSERVABILITY_DISCOVERY \
    SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS; do
    env_shadow="${var_name}_ENV"
    if [ -n "${!env_shadow:-}" ]; then
        printf -v "$var_name" '%s' "${!env_shadow}"
    fi
done

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

is_semaphoreui_profile_enabled() {
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" semaphoreui "*) return 0 ;;
        *) return 1 ;;
    esac
}

is_ipv4_loopback() {
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
    [ "$a" -eq 127 ]
}

validate_domain_name() {
    local domain="$1"
    if [ -z "$domain" ]; then
        log_error "BASE_DOMAIN is required when bind profile is enabled."
    fi
    if [ "${#domain}" -gt 253 ]; then
        log_error "BASE_DOMAIN is too long: ${domain}"
    fi
    if [[ ! "$domain" =~ ^[a-z0-9.-]+$ ]]; then
        log_error "BASE_DOMAIN contains invalid characters: ${domain}"
    fi
    if [[ "$domain" == .* || "$domain" == *. || "$domain" == *..* ]]; then
        log_error "BASE_DOMAIN has invalid dot placement: ${domain}"
    fi
    IFS='.' read -r -a labels <<< "$domain"
    local label
    for label in "${labels[@]}"; do
        if [ -z "$label" ] || [ "${#label}" -gt 63 ]; then
            log_error "BASE_DOMAIN label is invalid: ${domain}"
        fi
        if [[ ! "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
            log_error "BASE_DOMAIN label has invalid format: ${label}"
        fi
    done
}

validate_hostname_label() {
    local label="$1"
    local var_name="$2"
    if [ -z "$label" ]; then
        log_error "${var_name} is required when semaphoreui profile is enabled."
    fi
    if [[ ! "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        log_error "${var_name} must be a valid DNS label: ${label}"
    fi
}

is_true_or_false() {
    case "$1" in
        true|false) return 0 ;;
        *) return 1 ;;
    esac
}

require_non_placeholder_secret() {
    local var_name="$1"
    local value="$2"
    if [ -z "$value" ]; then
        log_error "${var_name} is required when semaphoreui profile is enabled."
    fi
    case "$value" in
        changeme|change-me|replace-me|example|example-password)
            log_error "${var_name} uses a placeholder value."
            ;;
    esac
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

if is_semaphoreui_profile_enabled; then
    validate_hostname_label "${SEMAPHOREUI_HOSTNAME:-}" "SEMAPHOREUI_HOSTNAME"

    require_non_placeholder_secret "SEMAPHOREUI_ADMIN_PASSWORD" "${SEMAPHOREUI_ADMIN_PASSWORD:-}"
    require_non_placeholder_secret "SEMAPHOREUI_DB_PASSWORD" "${SEMAPHOREUI_DB_PASSWORD:-}"
    require_non_placeholder_secret "SEMAPHOREUI_COOKIE_HASH" "${SEMAPHOREUI_COOKIE_HASH:-}"
    require_non_placeholder_secret "SEMAPHOREUI_COOKIE_ENCRYPTION" "${SEMAPHOREUI_COOKIE_ENCRYPTION:-}"
    require_non_placeholder_secret "SEMAPHOREUI_ACCESS_KEY_ENCRYPTION" "${SEMAPHOREUI_ACCESS_KEY_ENCRYPTION:-}"

    for bool_var in SEMAPHOREUI_OIDC_ENABLED SEMAPHOREUI_PASSWORD_LOGIN_DISABLED SEMAPHOREUI_OBSERVABILITY_ENABLED SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS; do
        if ! is_true_or_false "${!bool_var:-false}"; then
            log_error "${bool_var} must be 'true' or 'false'."
        fi
    done

    case "${SEMAPHOREUI_OBSERVABILITY_DISCOVERY:-labels}" in
        labels|names) ;;
        *) log_error "SEMAPHOREUI_OBSERVABILITY_DISCOVERY must be 'labels' or 'names'." ;;
    esac

    if [ "${SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS:-false}" = "true" ]; then
        log_error "SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS=true is not supported by default. Keep telemetry internal-only."
    fi

    if [ "${SEMAPHOREUI_OIDC_ENABLED:-false}" = "true" ]; then
        if [ -z "${SEMAPHOREUI_OIDC_PROVIDER_URL:-}" ]; then
            log_error "SEMAPHOREUI_OIDC_PROVIDER_URL is required when SEMAPHOREUI_OIDC_ENABLED=true."
        fi
        if [[ ! "${SEMAPHOREUI_OIDC_PROVIDER_URL}" =~ ^https?:// ]]; then
            log_error "SEMAPHOREUI_OIDC_PROVIDER_URL must be an http(s) URL."
        fi
        require_non_placeholder_secret "SEMAPHOREUI_OIDC_CLIENT_ID" "${SEMAPHOREUI_OIDC_CLIENT_ID:-}"
        require_non_placeholder_secret "SEMAPHOREUI_OIDC_CLIENT_SECRET" "${SEMAPHOREUI_OIDC_CLIENT_SECRET:-}"
    fi
fi
