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
N8N_KEYCLOAK_ENABLE_ENV="${N8N_KEYCLOAK_ENABLE:-}"
N8N_KEYCLOAK_DISCOVERY_URL_ENV="${N8N_KEYCLOAK_DISCOVERY_URL:-}"
N8N_KEYCLOAK_CLIENT_ID_ENV="${N8N_KEYCLOAK_CLIENT_ID:-}"
N8N_KEYCLOAK_CLIENT_SECRET_ENV="${N8N_KEYCLOAK_CLIENT_SECRET:-}"
N8N_OBSERVABILITY_ENABLE_ENV="${N8N_OBSERVABILITY_ENABLE:-}"
N8N_OBSERVABILITY_MODE_ENV="${N8N_OBSERVABILITY_MODE:-}"
N8N_METRICS_CUSTOM_ENABLE_ENV="${N8N_METRICS_CUSTOM_ENABLE:-}"
N8N_STEPCA_TRUST_ENABLE_ENV="${N8N_STEPCA_TRUST_ENABLE:-}"
N8N_STEPCA_TRUST_SOURCE_PATH_ENV="${N8N_STEPCA_TRUST_SOURCE_PATH:-}"
N8N_RENDERED_ENV_PATH_ENV="${N8N_RENDERED_ENV_PATH:-}"

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
if [ -n "${N8N_KEYCLOAK_ENABLE_ENV}" ]; then
    N8N_KEYCLOAK_ENABLE="${N8N_KEYCLOAK_ENABLE_ENV}"
fi
if [ -n "${N8N_KEYCLOAK_DISCOVERY_URL_ENV}" ]; then
    N8N_KEYCLOAK_DISCOVERY_URL="${N8N_KEYCLOAK_DISCOVERY_URL_ENV}"
fi
if [ -n "${N8N_KEYCLOAK_CLIENT_ID_ENV}" ]; then
    N8N_KEYCLOAK_CLIENT_ID="${N8N_KEYCLOAK_CLIENT_ID_ENV}"
fi
if [ -n "${N8N_KEYCLOAK_CLIENT_SECRET_ENV}" ]; then
    N8N_KEYCLOAK_CLIENT_SECRET="${N8N_KEYCLOAK_CLIENT_SECRET_ENV}"
fi
if [ -n "${N8N_OBSERVABILITY_ENABLE_ENV}" ]; then
    N8N_OBSERVABILITY_ENABLE="${N8N_OBSERVABILITY_ENABLE_ENV}"
fi
if [ -n "${N8N_OBSERVABILITY_MODE_ENV}" ]; then
    N8N_OBSERVABILITY_MODE="${N8N_OBSERVABILITY_MODE_ENV}"
fi
if [ -n "${N8N_METRICS_CUSTOM_ENABLE_ENV}" ]; then
    N8N_METRICS_CUSTOM_ENABLE="${N8N_METRICS_CUSTOM_ENABLE_ENV}"
fi
if [ -n "${N8N_STEPCA_TRUST_ENABLE_ENV}" ]; then
    N8N_STEPCA_TRUST_ENABLE="${N8N_STEPCA_TRUST_ENABLE_ENV}"
fi
if [ -n "${N8N_STEPCA_TRUST_SOURCE_PATH_ENV}" ]; then
    N8N_STEPCA_TRUST_SOURCE_PATH="${N8N_STEPCA_TRUST_SOURCE_PATH_ENV}"
fi
if [ -n "${N8N_RENDERED_ENV_PATH_ENV}" ]; then
    N8N_RENDERED_ENV_PATH="${N8N_RENDERED_ENV_PATH_ENV}"
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

is_n8n_profile_enabled() {
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" n8n "*) return 0 ;;
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

validate_path_fragment() {
    local label="$1"
    local value="$2"
    if [ -z "$value" ]; then
        log_error "${label} is required."
    fi
    if [[ "$value" =~ [[:space:]] ]]; then
        log_error "${label} must not contain whitespace. Got: ${value}"
    fi
    if [[ "$value" == /* || "$value" == */* ]]; then
        log_error "${label} must be a single path segment without '/'. Got: ${value}"
    fi
}

validate_n8n_rendered_env() {
    local path="${N8N_RENDERED_ENV_PATH:-${REPO_ROOT}/services/n8n/rendered/n8n.env}"
    local resolved="$path"
    if [[ "$resolved" != /* ]]; then
        resolved="${REPO_ROOT}/${resolved}"
    fi
    if [ ! -f "$resolved" ]; then
        log_error "n8n rendered env not found: ${resolved}. Run 'make n8n-bootstrap'."
    fi
    if ! grep -Eq '^N8N_RENDER_STATUS=ready$' "$resolved"; then
        log_error "n8n rendered env is missing or stale (${resolved}). Run 'make n8n-bootstrap'."
    fi
}

validate_n8n_optional_integrations() {
    local keycloak_enabled="${N8N_KEYCLOAK_ENABLE:-false}"
    local observability_enabled="${N8N_OBSERVABILITY_ENABLE:-false}"
    local metrics_custom="${N8N_METRICS_CUSTOM_ENABLE:-false}"
    local stepca_trust_enabled="${N8N_STEPCA_TRUST_ENABLE:-false}"
    local observability_mode="${N8N_OBSERVABILITY_MODE:-health}"
    local health_endpoint="${N8N_ENDPOINT_HEALTH:-healthz}"

    validate_bool "N8N_KEYCLOAK_ENABLE" "$keycloak_enabled"
    validate_bool "N8N_OBSERVABILITY_ENABLE" "$observability_enabled"
    validate_bool "N8N_METRICS_CUSTOM_ENABLE" "$metrics_custom"
    validate_bool "N8N_STEPCA_TRUST_ENABLE" "$stepca_trust_enabled"
    validate_path_fragment "N8N_ENDPOINT_HEALTH" "$health_endpoint"

    if [ "$keycloak_enabled" = "true" ]; then
        validate_https_url "N8N_KEYCLOAK_DISCOVERY_URL" "${N8N_KEYCLOAK_DISCOVERY_URL:-}"
        [ -n "${N8N_KEYCLOAK_CLIENT_ID:-}" ] || log_error "N8N_KEYCLOAK_CLIENT_ID is required when N8N_KEYCLOAK_ENABLE=true."
        [ -n "${N8N_KEYCLOAK_CLIENT_SECRET:-}" ] || log_error "N8N_KEYCLOAK_CLIENT_SECRET is required when N8N_KEYCLOAK_ENABLE=true."
    fi

    if [ "$observability_enabled" = "true" ]; then
        case "$observability_mode" in
            health|metrics|full|custom) ;;
            *) log_error "N8N_OBSERVABILITY_MODE must be one of: health, metrics, full, custom. Got: ${observability_mode}" ;;
        esac
    fi

    if [ "$stepca_trust_enabled" = "true" ]; then
        local source_path="${N8N_STEPCA_TRUST_SOURCE_PATH:-}"
        [ -n "$source_path" ] || log_error "N8N_STEPCA_TRUST_SOURCE_PATH is required when N8N_STEPCA_TRUST_ENABLE=true."
        local resolved="$source_path"
        if [[ "$resolved" != /* ]]; then
            resolved="${REPO_ROOT}/${resolved}"
        fi
        [ -f "$resolved" ] || log_error "N8N_STEPCA_TRUST_SOURCE_PATH file not found: ${resolved}"
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

if is_n8n_profile_enabled; then
    validate_n8n_rendered_env
    validate_n8n_optional_integrations
fi
