#!/bin/bash
# File: scripts/validate-env.sh
#
# Preflight checks for environment variables used by profiles and UI auth.
#
# Validates:
# - Traefik dashboard BasicAuth file safety
# - COMPOSE_PROFILES syntax
# - BIND profile bind-address guardrails
# - Rocket.Chat profile rendered-config and optional integration guardrails

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
ROCKETCHAT_HOSTNAME_ENV="${ROCKETCHAT_HOSTNAME:-}"
ROCKETCHAT_PORT_ENV="${ROCKETCHAT_PORT:-}"
ROCKETCHAT_METRICS_PORT_ENV="${ROCKETCHAT_METRICS_PORT:-}"
ROCKETCHAT_RENDERED_ENV_PATH_ENV="${ROCKETCHAT_RENDERED_ENV_PATH:-}"
ROCKETCHAT_OBSERVABILITY_ENABLED_ENV="${ROCKETCHAT_OBSERVABILITY_ENABLED:-}"
ROCKETCHAT_KEYCLOAK_ENABLED_ENV="${ROCKETCHAT_KEYCLOAK_ENABLED:-}"
ROCKETCHAT_KEYCLOAK_OAUTH_ID_ENV="${ROCKETCHAT_KEYCLOAK_OAUTH_ID:-}"
ROCKETCHAT_KEYCLOAK_ISSUER_ENV="${ROCKETCHAT_KEYCLOAK_ISSUER:-}"
ROCKETCHAT_KEYCLOAK_CLIENT_ID_ENV="${ROCKETCHAT_KEYCLOAK_CLIENT_ID:-}"
ROCKETCHAT_KEYCLOAK_CLIENT_SECRET_ENV="${ROCKETCHAT_KEYCLOAK_CLIENT_SECRET:-}"
ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK_ENV="${ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK:-}"

load_env

# Re-apply explicit environment overrides captured before load_env.
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
if [ -n "${ROCKETCHAT_HOSTNAME_ENV}" ]; then
    ROCKETCHAT_HOSTNAME="${ROCKETCHAT_HOSTNAME_ENV}"
fi
if [ -n "${ROCKETCHAT_PORT_ENV}" ]; then
    ROCKETCHAT_PORT="${ROCKETCHAT_PORT_ENV}"
fi
if [ -n "${ROCKETCHAT_METRICS_PORT_ENV}" ]; then
    ROCKETCHAT_METRICS_PORT="${ROCKETCHAT_METRICS_PORT_ENV}"
fi
if [ -n "${ROCKETCHAT_RENDERED_ENV_PATH_ENV}" ]; then
    ROCKETCHAT_RENDERED_ENV_PATH="${ROCKETCHAT_RENDERED_ENV_PATH_ENV}"
fi
if [ -n "${ROCKETCHAT_OBSERVABILITY_ENABLED_ENV}" ]; then
    ROCKETCHAT_OBSERVABILITY_ENABLED="${ROCKETCHAT_OBSERVABILITY_ENABLED_ENV}"
fi
if [ -n "${ROCKETCHAT_KEYCLOAK_ENABLED_ENV}" ]; then
    ROCKETCHAT_KEYCLOAK_ENABLED="${ROCKETCHAT_KEYCLOAK_ENABLED_ENV}"
fi
if [ -n "${ROCKETCHAT_KEYCLOAK_OAUTH_ID_ENV}" ]; then
    ROCKETCHAT_KEYCLOAK_OAUTH_ID="${ROCKETCHAT_KEYCLOAK_OAUTH_ID_ENV}"
fi
if [ -n "${ROCKETCHAT_KEYCLOAK_ISSUER_ENV}" ]; then
    ROCKETCHAT_KEYCLOAK_ISSUER="${ROCKETCHAT_KEYCLOAK_ISSUER_ENV}"
fi
if [ -n "${ROCKETCHAT_KEYCLOAK_CLIENT_ID_ENV}" ]; then
    ROCKETCHAT_KEYCLOAK_CLIENT_ID="${ROCKETCHAT_KEYCLOAK_CLIENT_ID_ENV}"
fi
if [ -n "${ROCKETCHAT_KEYCLOAK_CLIENT_SECRET_ENV}" ]; then
    ROCKETCHAT_KEYCLOAK_CLIENT_SECRET="${ROCKETCHAT_KEYCLOAK_CLIENT_SECRET_ENV}"
fi
if [ -n "${ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK_ENV}" ]; then
    ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK="${ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK_ENV}"
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

profile_enabled() {
    local profile="$1"
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" ${profile} "*) return 0 ;;
        *) return 1 ;;
    esac
}

is_bind_profile_enabled() {
    profile_enabled bind
}

is_rocketchat_profile_enabled() {
    profile_enabled rocketchat
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

validate_dns_label() {
    local value="$1"
    local name="$2"
    if [[ ! "$value" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        log_error "${name} must be a lowercase DNS label (got: ${value})"
    fi
}

validate_bool_value() {
    local value="$1"
    local name="$2"
    case "$value" in
        true|false) ;;
        *) log_error "${name} must be 'true' or 'false'. Got: ${value}" ;;
    esac
}

validate_port_value() {
    local value="$1"
    local name="$2"
    if [[ ! "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
        log_error "${name} must be an integer between 1 and 65535. Got: ${value}"
    fi
}

to_abs_repo_path() {
    local path="$1"
    if [ -z "$path" ]; then
        printf '%s' ""
        return
    fi
    if [[ "$path" = /* ]]; then
        printf '%s' "$path"
    else
        printf '%s' "${REPO_ROOT}/${path}"
    fi
}

require_non_empty() {
    local value="$1"
    local name="$2"
    if [ -z "$value" ]; then
        log_error "${name} is required."
    fi
}

require_non_placeholder_secret() {
    local value="$1"
    local name="$2"
    if [ -z "$value" ]; then
        log_error "${name} must not be empty."
    fi
    case "$value" in
        change-me|changeme|ChangeMe|example|your-secret|your_secret|replace-me|replace_me)
            log_error "${name} appears to use a placeholder value."
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

ROCKETCHAT_OBSERVABILITY_ENABLED_VALUE="${ROCKETCHAT_OBSERVABILITY_ENABLED:-false}"
ROCKETCHAT_KEYCLOAK_ENABLED_VALUE="${ROCKETCHAT_KEYCLOAK_ENABLED:-false}"
if is_rocketchat_profile_enabled || [ "${ROCKETCHAT_OBSERVABILITY_ENABLED_VALUE}" = "true" ] || [ "${ROCKETCHAT_KEYCLOAK_ENABLED_VALUE}" = "true" ]; then
    validate_bool_value "${ROCKETCHAT_OBSERVABILITY_ENABLED_VALUE}" "ROCKETCHAT_OBSERVABILITY_ENABLED"
    validate_bool_value "${ROCKETCHAT_KEYCLOAK_ENABLED_VALUE}" "ROCKETCHAT_KEYCLOAK_ENABLED"

    validate_dns_label "${ROCKETCHAT_HOSTNAME:-rocketchat}" "ROCKETCHAT_HOSTNAME"
    validate_port_value "${ROCKETCHAT_PORT:-3000}" "ROCKETCHAT_PORT"
    validate_port_value "${ROCKETCHAT_METRICS_PORT:-9458}" "ROCKETCHAT_METRICS_PORT"
    validate_dns_label "${ROCKETCHAT_KEYCLOAK_OAUTH_ID:-keycloak}" "ROCKETCHAT_KEYCLOAK_OAUTH_ID"

    if is_rocketchat_profile_enabled; then
        SKIP_RENDERED_CHECK_VALUE="${ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK:-false}"
        validate_bool_value "${SKIP_RENDERED_CHECK_VALUE}" "ROCKETCHAT_SKIP_RENDERED_CONFIG_CHECK"
        if [ "${SKIP_RENDERED_CHECK_VALUE}" != "true" ]; then
            ROCKETCHAT_RENDERED_ENV_PATH_VALUE="${ROCKETCHAT_RENDERED_ENV_PATH:-services/rocketchat/rendered/rocketchat.env}"
            ROCKETCHAT_RENDERED_ENV_ABS=$(to_abs_repo_path "${ROCKETCHAT_RENDERED_ENV_PATH_VALUE}")
            if [ ! -f "${ROCKETCHAT_RENDERED_ENV_ABS}" ]; then
                log_error "Rocket.Chat rendered env file not found: ${ROCKETCHAT_RENDERED_ENV_ABS}. Run 'make rocketchat-bootstrap' first."
            fi
        fi
    fi

    if [ "${ROCKETCHAT_KEYCLOAK_ENABLED_VALUE}" = "true" ]; then
        require_non_empty "${ROCKETCHAT_KEYCLOAK_ISSUER:-}" "ROCKETCHAT_KEYCLOAK_ISSUER"
        require_non_empty "${ROCKETCHAT_KEYCLOAK_CLIENT_ID:-}" "ROCKETCHAT_KEYCLOAK_CLIENT_ID"
        require_non_placeholder_secret "${ROCKETCHAT_KEYCLOAK_CLIENT_SECRET:-}" "ROCKETCHAT_KEYCLOAK_CLIENT_SECRET"
        if [[ ! "${ROCKETCHAT_KEYCLOAK_ISSUER}" =~ ^https:// ]]; then
            log_error "ROCKETCHAT_KEYCLOAK_ISSUER should use HTTPS (for example Keycloak behind TLS)."
        fi
    fi
fi
