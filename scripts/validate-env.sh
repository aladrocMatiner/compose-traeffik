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
CTFD_HOSTNAME_ENV="${CTFD_HOSTNAME:-}"
GRAFANA_HOSTNAME_ENV="${GRAFANA_HOSTNAME:-}"

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
if [ -n "${CTFD_HOSTNAME_ENV}" ]; then
    CTFD_HOSTNAME="${CTFD_HOSTNAME_ENV}"
fi
if [ -n "${GRAFANA_HOSTNAME_ENV}" ]; then
    GRAFANA_HOSTNAME="${GRAFANA_HOSTNAME_ENV}"
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
    is_profile_enabled "bind"
}

is_profile_enabled() {
    local profile="$1"
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" ${profile} "*) return 0 ;;
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

validate_subdomain_label() {
    local label="$1"
    local var_name="$2"
    if [ -z "$label" ]; then
        log_error "${var_name} is required."
    fi
    if [ "${#label}" -gt 63 ]; then
        log_error "${var_name} is too long: ${label}"
    fi
    if [[ ! "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        log_error "${var_name} must be a lowercase DNS label (a-z, 0-9, hyphen; no leading/trailing hyphen). Got: ${label}"
    fi
}

is_placeholder_secret() {
    local value="$1"
    case "$value" in
        ""|"changeme"|"change-me"|"example"|"example123"|"password"|"admin"|"REPLACE_ME")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

require_non_placeholder() {
    local label="$1"
    local value="$2"
    local bootstrap_hint="${3:-}"
    if [ -z "$value" ] || is_placeholder_secret "$value"; then
        if [ -n "$bootstrap_hint" ]; then
            log_error "${label} is missing or placeholder. Run ${bootstrap_hint}."
        else
            log_error "${label} is missing or placeholder."
        fi
    fi
}

validate_duration_token() {
    local value="$1"
    local var_name="$2"
    if [ -z "$value" ]; then
        log_error "${var_name} is required."
    fi
    if [[ ! "$value" =~ ^[0-9]+[smhdw]$ ]]; then
        log_error "${var_name} must match <integer><unit> where unit is one of s,m,h,d,w. Got: ${value}"
    fi
}

validate_positive_int() {
    local value="$1"
    local var_name="$2"
    if [[ ! "$value" =~ ^[0-9]+$ ]] || [ "$value" -le 0 ]; then
        log_error "${var_name} must be a positive integer. Got: ${value}"
    fi
}

validate_http_url() {
    local value="$1"
    local var_name="$2"
    if [[ ! "$value" =~ ^https?:// ]]; then
        log_error "${var_name} must start with http:// or https://. Got: ${value}"
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

if is_profile_enabled "ctfd"; then
    validate_subdomain_label "${CTFD_HOSTNAME:-ctfd}" "CTFD_HOSTNAME"
    require_non_placeholder "CTFD_SECRET_KEY" "${CTFD_SECRET_KEY:-}" "make ctfd-bootstrap"
    require_non_placeholder "CTFD_DB_PASSWORD" "${CTFD_DB_PASSWORD:-}" "make ctfd-bootstrap"
    require_non_placeholder "CTFD_DB_ROOT_PASSWORD" "${CTFD_DB_ROOT_PASSWORD:-}" "make ctfd-bootstrap"
fi

if is_profile_enabled "observability"; then
    validate_subdomain_label "${GRAFANA_HOSTNAME:-grafana}" "GRAFANA_HOSTNAME"
    require_non_placeholder "GRAFANA_ADMIN_PASSWORD" "${GRAFANA_ADMIN_PASSWORD:-}" "make observability-bootstrap"
    validate_duration_token "${PROMETHEUS_RETENTION_TIME:-7d}" "PROMETHEUS_RETENTION_TIME"
    validate_duration_token "${LOKI_RETENTION_PERIOD:-168h}" "LOKI_RETENTION_PERIOD"
    validate_duration_token "${TEMPO_RETENTION_PERIOD:-168h}" "TEMPO_RETENTION_PERIOD"
    validate_duration_token "${PYROSCOPE_RETENTION_PERIOD:-168h}" "PYROSCOPE_RETENTION_PERIOD"
fi

if [ -n "${K6_TARGET_URL:-}" ] || [ -n "${K6_ITERATIONS:-}" ] || [ -n "${K6_SLEEP_SECONDS:-}" ]; then
    validate_http_url "${K6_TARGET_URL:-}" "K6_TARGET_URL"
    validate_positive_int "${K6_ITERATIONS:-0}" "K6_ITERATIONS"
    validate_positive_int "${K6_SLEEP_SECONDS:-0}" "K6_SLEEP_SECONDS"
fi
