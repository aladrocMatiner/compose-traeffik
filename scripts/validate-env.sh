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
WIKIJS_KEYCLOAK_ENABLE_ENV="${WIKIJS_KEYCLOAK_ENABLE:-}"
WIKIJS_KEYCLOAK_ISSUER_URL_ENV="${WIKIJS_KEYCLOAK_ISSUER_URL:-}"
WIKIJS_KEYCLOAK_CLIENT_ID_ENV="${WIKIJS_KEYCLOAK_CLIENT_ID:-}"
WIKIJS_KEYCLOAK_CLIENT_SECRET_ENV="${WIKIJS_KEYCLOAK_CLIENT_SECRET:-}"
WIKIJS_OBSERVABILITY_ENABLE_ENV="${WIKIJS_OBSERVABILITY_ENABLE:-}"
WIKIJS_OBSERVABILITY_MODE_ENV="${WIKIJS_OBSERVABILITY_MODE:-}"
WIKIJS_STEPCA_TRUST_ENABLE_ENV="${WIKIJS_STEPCA_TRUST_ENABLE:-}"
WIKIJS_STEPCA_TRUST_SOURCE_PATH_ENV="${WIKIJS_STEPCA_TRUST_SOURCE_PATH:-}"
WIKIJS_RENDERED_ENV_PATH_ENV="${WIKIJS_RENDERED_ENV_PATH:-}"

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
if [ -n "${WIKIJS_KEYCLOAK_ENABLE_ENV}" ]; then
    WIKIJS_KEYCLOAK_ENABLE="${WIKIJS_KEYCLOAK_ENABLE_ENV}"
fi
if [ -n "${WIKIJS_KEYCLOAK_ISSUER_URL_ENV}" ]; then
    WIKIJS_KEYCLOAK_ISSUER_URL="${WIKIJS_KEYCLOAK_ISSUER_URL_ENV}"
fi
if [ -n "${WIKIJS_KEYCLOAK_CLIENT_ID_ENV}" ]; then
    WIKIJS_KEYCLOAK_CLIENT_ID="${WIKIJS_KEYCLOAK_CLIENT_ID_ENV}"
fi
if [ -n "${WIKIJS_KEYCLOAK_CLIENT_SECRET_ENV}" ]; then
    WIKIJS_KEYCLOAK_CLIENT_SECRET="${WIKIJS_KEYCLOAK_CLIENT_SECRET_ENV}"
fi
if [ -n "${WIKIJS_OBSERVABILITY_ENABLE_ENV}" ]; then
    WIKIJS_OBSERVABILITY_ENABLE="${WIKIJS_OBSERVABILITY_ENABLE_ENV}"
fi
if [ -n "${WIKIJS_OBSERVABILITY_MODE_ENV}" ]; then
    WIKIJS_OBSERVABILITY_MODE="${WIKIJS_OBSERVABILITY_MODE_ENV}"
fi
if [ -n "${WIKIJS_STEPCA_TRUST_ENABLE_ENV}" ]; then
    WIKIJS_STEPCA_TRUST_ENABLE="${WIKIJS_STEPCA_TRUST_ENABLE_ENV}"
fi
if [ -n "${WIKIJS_STEPCA_TRUST_SOURCE_PATH_ENV}" ]; then
    WIKIJS_STEPCA_TRUST_SOURCE_PATH="${WIKIJS_STEPCA_TRUST_SOURCE_PATH_ENV}"
fi
if [ -n "${WIKIJS_RENDERED_ENV_PATH_ENV}" ]; then
    WIKIJS_RENDERED_ENV_PATH="${WIKIJS_RENDERED_ENV_PATH_ENV}"
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

is_wikijs_profile_enabled() {
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" wikijs "*) return 0 ;;
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

validate_bool() {
    local label="$1"
    local value="$2"
    case "$value" in
        true|false) ;;
        *) log_error "${label} must be 'true' or 'false'. Got: ${value}" ;;
    esac
}

validate_https_url() {
    local label="$1"
    local value="$2"
    if [ -z "$value" ]; then
        log_error "${label} is required."
    fi
    if [[ ! "$value" =~ ^https://[^[:space:]]+$ ]]; then
        log_error "${label} must be an https:// URL. Got: ${value}"
    fi
}

validate_wikijs_rendered_env() {
    local path="${WIKIJS_RENDERED_ENV_PATH:-${REPO_ROOT}/services/wikijs/rendered/wikijs.env}"
    local resolved="$path"
    if [[ "$resolved" != /* ]]; then
        resolved="${REPO_ROOT}/${resolved}"
    fi

    if [ ! -f "$resolved" ]; then
        log_error "Wiki.js rendered env not found: ${resolved}. Run 'make wikijs-bootstrap'."
    fi
    if ! grep -Eq '^WIKIJS_RENDER_STATUS=ready$' "$resolved"; then
        log_error "Wiki.js rendered env is missing or stale (${resolved}). Run 'make wikijs-bootstrap'."
    fi
}

validate_wikijs_optional_integrations() {
    local keycloak_enabled="${WIKIJS_KEYCLOAK_ENABLE:-false}"
    local observability_enabled="${WIKIJS_OBSERVABILITY_ENABLE:-false}"
    local stepca_trust_enabled="${WIKIJS_STEPCA_TRUST_ENABLE:-false}"
    local observability_mode="${WIKIJS_OBSERVABILITY_MODE:-telemetry}"

    validate_bool "WIKIJS_KEYCLOAK_ENABLE" "$keycloak_enabled"
    validate_bool "WIKIJS_OBSERVABILITY_ENABLE" "$observability_enabled"
    validate_bool "WIKIJS_STEPCA_TRUST_ENABLE" "$stepca_trust_enabled"

    if [ "$keycloak_enabled" = "true" ]; then
        validate_https_url "WIKIJS_KEYCLOAK_ISSUER_URL" "${WIKIJS_KEYCLOAK_ISSUER_URL:-}"
        if [ -z "${WIKIJS_KEYCLOAK_CLIENT_ID:-}" ]; then
            log_error "WIKIJS_KEYCLOAK_CLIENT_ID is required when WIKIJS_KEYCLOAK_ENABLE=true."
        fi
        if [ -z "${WIKIJS_KEYCLOAK_CLIENT_SECRET:-}" ]; then
            log_error "WIKIJS_KEYCLOAK_CLIENT_SECRET is required when WIKIJS_KEYCLOAK_ENABLE=true."
        fi
    fi

    if [ "$observability_enabled" = "true" ]; then
        case "$observability_mode" in
            telemetry|full|custom) ;;
            *) log_error "WIKIJS_OBSERVABILITY_MODE must be one of: telemetry, full, custom. Got: ${observability_mode}" ;;
        esac
    fi

    if [ "$stepca_trust_enabled" = "true" ]; then
        local source_path="${WIKIJS_STEPCA_TRUST_SOURCE_PATH:-}"
        if [ -z "$source_path" ]; then
            log_error "WIKIJS_STEPCA_TRUST_SOURCE_PATH is required when WIKIJS_STEPCA_TRUST_ENABLE=true."
        fi
        local resolved="$source_path"
        if [[ "$resolved" != /* ]]; then
            resolved="${REPO_ROOT}/${resolved}"
        fi
        if [ ! -f "$resolved" ]; then
            log_error "WIKIJS_STEPCA_TRUST_SOURCE_PATH file not found: ${resolved}"
        fi
    fi
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

if is_wikijs_profile_enabled; then
    validate_wikijs_rendered_env
    validate_wikijs_optional_integrations
fi
