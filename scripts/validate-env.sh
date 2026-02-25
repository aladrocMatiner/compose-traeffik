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
GITLAB_HOSTNAME_ENV="${GITLAB_HOSTNAME:-}"
GITLAB_SSH_HOST_PORT_ENV="${GITLAB_SSH_HOST_PORT:-}"
GITLAB_ROOT_PASSWORD_ENV="${GITLAB_ROOT_PASSWORD:-}"
GITLAB_OIDC_ENABLED_ENV="${GITLAB_OIDC_ENABLED:-}"
GITLAB_OIDC_ISSUER_ENV="${GITLAB_OIDC_ISSUER:-}"
GITLAB_OIDC_CLIENT_ID_ENV="${GITLAB_OIDC_CLIENT_ID:-}"
GITLAB_OIDC_CLIENT_SECRET_ENV="${GITLAB_OIDC_CLIENT_SECRET:-}"
GITLAB_RENDERED_CONFIG_PATH_ENV="${GITLAB_RENDERED_CONFIG_PATH:-}"
GITLAB_VERSION_ENV="${GITLAB_VERSION:-}"
GITLAB_OBSERVABILITY_ENABLED_ENV="${GITLAB_OBSERVABILITY_ENABLED:-}"

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
if [ -n "${GITLAB_HOSTNAME_ENV}" ]; then
    GITLAB_HOSTNAME="${GITLAB_HOSTNAME_ENV}"
fi
if [ -n "${GITLAB_SSH_HOST_PORT_ENV}" ]; then
    GITLAB_SSH_HOST_PORT="${GITLAB_SSH_HOST_PORT_ENV}"
fi
if [ -n "${GITLAB_ROOT_PASSWORD_ENV}" ]; then
    GITLAB_ROOT_PASSWORD="${GITLAB_ROOT_PASSWORD_ENV}"
fi
if [ -n "${GITLAB_OIDC_ENABLED_ENV}" ]; then
    GITLAB_OIDC_ENABLED="${GITLAB_OIDC_ENABLED_ENV}"
fi
if [ -n "${GITLAB_OIDC_ISSUER_ENV}" ]; then
    GITLAB_OIDC_ISSUER="${GITLAB_OIDC_ISSUER_ENV}"
fi
if [ -n "${GITLAB_OIDC_CLIENT_ID_ENV}" ]; then
    GITLAB_OIDC_CLIENT_ID="${GITLAB_OIDC_CLIENT_ID_ENV}"
fi
if [ -n "${GITLAB_OIDC_CLIENT_SECRET_ENV}" ]; then
    GITLAB_OIDC_CLIENT_SECRET="${GITLAB_OIDC_CLIENT_SECRET_ENV}"
fi
if [ -n "${GITLAB_RENDERED_CONFIG_PATH_ENV}" ]; then
    GITLAB_RENDERED_CONFIG_PATH="${GITLAB_RENDERED_CONFIG_PATH_ENV}"
fi
if [ -n "${GITLAB_VERSION_ENV}" ]; then
    GITLAB_VERSION="${GITLAB_VERSION_ENV}"
fi
if [ -n "${GITLAB_OBSERVABILITY_ENABLED_ENV}" ]; then
    GITLAB_OBSERVABILITY_ENABLED="${GITLAB_OBSERVABILITY_ENABLED_ENV}"
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

is_gitlab_profile_enabled() {
    case " ${COMPOSE_PROFILES_NORMALIZED:-} " in
        *" gitlab "*) return 0 ;;
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

validate_dns_label() {
    local label="$1"
    if [ -z "$label" ]; then
        log_error "GitLab hostname label is required when gitlab profile is enabled."
    fi
    if [ "${#label}" -gt 63 ]; then
        log_error "GITLAB_HOSTNAME is too long: ${label}"
    fi
    if [[ ! "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        log_error "GITLAB_HOSTNAME must be a valid DNS label (lowercase letters, digits, hyphen): ${label}"
    fi
}

validate_port() {
    local value="$1"
    local varname="$2"
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        log_error "${varname} must be a numeric TCP port. Got: ${value}"
    fi
    if [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
        log_error "${varname} must be in range 1-65535. Got: ${value}"
    fi
}

validate_bool_value() {
    local value="$1"
    local varname="$2"
    case "$value" in
        true|false) ;;
        *) log_error "${varname} must be 'true' or 'false'. Got: ${value}" ;;
    esac
}

require_non_placeholder_secret() {
    local value="$1"
    local varname="$2"
    local trimmed_value
    trimmed_value=$(trim "$value")
    case "${trimmed_value}" in
        ""|changeme|change-me|example|password|replace-me|REPLACE_ME)
            log_error "${varname} must be set to a non-placeholder value. Run the bootstrap target or update .env."
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

if is_gitlab_profile_enabled; then
    GITLAB_HOSTNAME_VALUE="${GITLAB_HOSTNAME:-gitlab}"
    GITLAB_SSH_HOST_PORT_VALUE="${GITLAB_SSH_HOST_PORT:-2424}"
    GITLAB_ROOT_PASSWORD_VALUE="${GITLAB_ROOT_PASSWORD:-}"
    GITLAB_RENDERED_CONFIG_PATH_VALUE="${GITLAB_RENDERED_CONFIG_PATH:-${REPO_ROOT}/services/gitlab/rendered/gitlab.rb}"
    GITLAB_OIDC_ENABLED_VALUE="${GITLAB_OIDC_ENABLED:-false}"
    GITLAB_OBSERVABILITY_ENABLED_VALUE="${GITLAB_OBSERVABILITY_ENABLED:-false}"
    GITLAB_VERSION_VALUE="${GITLAB_VERSION:-}"

    validate_dns_label "${GITLAB_HOSTNAME_VALUE}"
    validate_port "${GITLAB_SSH_HOST_PORT_VALUE}" "GITLAB_SSH_HOST_PORT"
    require_non_placeholder_secret "${GITLAB_ROOT_PASSWORD_VALUE}" "GITLAB_ROOT_PASSWORD"
    validate_bool_value "${GITLAB_OIDC_ENABLED_VALUE}" "GITLAB_OIDC_ENABLED"
    validate_bool_value "${GITLAB_OBSERVABILITY_ENABLED_VALUE}" "GITLAB_OBSERVABILITY_ENABLED"

    if [ -n "${GITLAB_VERSION_VALUE}" ]; then
        case "${GITLAB_VERSION_VALUE}" in
            latest|nightly|*rc*|*beta*)
                log_error "GITLAB_VERSION must be pinned to a stable release (not latest/rc/beta/nightly)."
                ;;
        esac
    fi

    if [ ! -f "${GITLAB_RENDERED_CONFIG_PATH_VALUE}" ]; then
        log_error "Rendered GitLab config not found: ${GITLAB_RENDERED_CONFIG_PATH_VALUE}. Run 'make gitlab-bootstrap'."
    fi

    if [ "${GITLAB_OIDC_ENABLED_VALUE}" = "true" ]; then
        if [ -z "${GITLAB_OIDC_ISSUER:-}" ] || [ -z "${GITLAB_OIDC_CLIENT_ID:-}" ] || [ -z "${GITLAB_OIDC_CLIENT_SECRET:-}" ]; then
            log_error "GITLAB_OIDC_ENABLED=true requires GITLAB_OIDC_ISSUER, GITLAB_OIDC_CLIENT_ID, and GITLAB_OIDC_CLIENT_SECRET."
        fi
        if [[ "${GITLAB_OIDC_ISSUER}" != https://* ]]; then
            log_error "GITLAB_OIDC_ISSUER should use HTTPS (for example Keycloak behind TLS)."
        fi
    fi
fi
