#!/bin/bash
# File: scripts/validate-env.sh
#
# Preflight checks for environment variables used by profiles and UI auth.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

DNS_UI_BASIC_AUTH_HTPASSWD_PATH_ENV="${DNS_UI_BASIC_AUTH_HTPASSWD_PATH:-}"
TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_ENV="${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH:-}"
DNS_ADMIN_PASSWORD_ENV="${DNS_ADMIN_PASSWORD:-}"
COMPOSE_PROFILES_ENV="${COMPOSE_PROFILES:-}"
TRAEFIK_DASHBOARD_ENV="${TRAEFIK_DASHBOARD:-}"
LITELLM_HOSTNAME_ENV="${LITELLM_HOSTNAME:-}"
LITELLM_UI_HOSTNAME_ENV="${LITELLM_UI_HOSTNAME:-}"
LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH_ENV="${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH:-}"
LITELLM_MASTER_KEY_ENV="${LITELLM_MASTER_KEY:-}"
LITELLM_SALT_KEY_ENV="${LITELLM_SALT_KEY:-}"
LITELLM_LOCAL_API_BASE_ENV="${LITELLM_LOCAL_API_BASE:-}"

load_env

if [ -n "${DNS_UI_BASIC_AUTH_HTPASSWD_PATH_ENV}" ]; then
    DNS_UI_BASIC_AUTH_HTPASSWD_PATH="${DNS_UI_BASIC_AUTH_HTPASSWD_PATH_ENV}"
fi
if [ -n "${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_ENV}" ]; then
    TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH="${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_ENV}"
fi
if [ -n "${DNS_ADMIN_PASSWORD_ENV}" ]; then
    DNS_ADMIN_PASSWORD="${DNS_ADMIN_PASSWORD_ENV}"
fi
if [ -n "${COMPOSE_PROFILES_ENV}" ]; then
    COMPOSE_PROFILES="${COMPOSE_PROFILES_ENV}"
fi
if [ -n "${TRAEFIK_DASHBOARD_ENV}" ]; then
    TRAEFIK_DASHBOARD="${TRAEFIK_DASHBOARD_ENV}"
fi
if [ -n "${LITELLM_HOSTNAME_ENV}" ]; then
    LITELLM_HOSTNAME="${LITELLM_HOSTNAME_ENV}"
fi
if [ -n "${LITELLM_UI_HOSTNAME_ENV}" ]; then
    LITELLM_UI_HOSTNAME="${LITELLM_UI_HOSTNAME_ENV}"
fi
if [ -n "${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH_ENV}" ]; then
    LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH="${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH_ENV}"
fi
if [ -n "${LITELLM_MASTER_KEY_ENV}" ]; then
    LITELLM_MASTER_KEY="${LITELLM_MASTER_KEY_ENV}"
fi
if [ -n "${LITELLM_SALT_KEY_ENV}" ]; then
    LITELLM_SALT_KEY="${LITELLM_SALT_KEY_ENV}"
fi
if [ -n "${LITELLM_LOCAL_API_BASE_ENV}" ]; then
    LITELLM_LOCAL_API_BASE="${LITELLM_LOCAL_API_BASE_ENV}"
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

is_placeholder_secret() {
    local value
    value=$(trim "$1")
    if [ -z "$value" ]; then
        return 0
    fi
    case "$value" in
        change-me|changeme|example|example-key|replace-me|replace_with_real_value)
            return 0
            ;;
    esac
    return 1
}

is_valid_hostname_label() {
    local value="$1"
    [[ "$value" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]
}

is_valid_http_url() {
    local value="$1"
    [[ "$value" =~ ^https?://[^[:space:]]+$ ]]
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

normalize_profiles
profiles="${COMPOSE_PROFILES_NORMALIZED:-}"
dns_enabled=false
litellm_enabled=false
for profile in $profiles; do
    if [ "$profile" = "dns" ]; then
        dns_enabled=true
    fi
    if [ "$profile" = "litellm" ]; then
        litellm_enabled=true
    fi
done

if [ "$dns_enabled" = "true" ]; then
    dns_password=$(trim "${DNS_ADMIN_PASSWORD:-}")
    if [ -z "$dns_password" ]; then
        log_error "DNS_ADMIN_PASSWORD is not set. Set it before enabling the dns profile."
    fi
    if [ "$dns_password" = "change-me" ]; then
        log_error "DNS_ADMIN_PASSWORD must not be the placeholder value 'change-me'. Set a real password."
    fi
    require_auth_file "DNS UI" "${DNS_UI_BASIC_AUTH_HTPASSWD_PATH:-}"
fi

if [ "${TRAEFIK_DASHBOARD:-false}" = "true" ]; then
    require_auth_file "Traefik dashboard" "${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH:-}"
fi

if [ "$litellm_enabled" = "true" ]; then
    litellm_hostname=$(trim "${LITELLM_HOSTNAME:-llm}")
    litellm_ui_hostname=$(trim "${LITELLM_UI_HOSTNAME:-llm-admin}")
    litellm_local_api_base=$(trim "${LITELLM_LOCAL_API_BASE:-http://host.docker.internal:11434}")
    if ! is_valid_hostname_label "$litellm_hostname"; then
        log_error "LITELLM_HOSTNAME must be a valid DNS label (lowercase letters, digits, hyphens). Got: ${litellm_hostname}"
    fi
    if ! is_valid_hostname_label "$litellm_ui_hostname"; then
        log_error "LITELLM_UI_HOSTNAME must be a valid DNS label (lowercase letters, digits, hyphens). Got: ${litellm_ui_hostname}"
    fi
    if ! is_valid_http_url "$litellm_local_api_base"; then
        log_error "LITELLM_LOCAL_API_BASE must be a valid http(s) URL. Got: ${litellm_local_api_base}"
    fi

    litellm_master_key=$(trim "${LITELLM_MASTER_KEY:-}")
    litellm_salt_key=$(trim "${LITELLM_SALT_KEY:-}")

    if is_placeholder_secret "$litellm_master_key"; then
        log_error "LITELLM_MASTER_KEY is missing or placeholder. Run 'make litellm-bootstrap' before enabling the litellm profile."
    fi
    if is_placeholder_secret "$litellm_salt_key"; then
        log_error "LITELLM_SALT_KEY is missing or placeholder. Run 'make litellm-bootstrap' before enabling the litellm profile."
    fi
    if [[ "$litellm_master_key" != sk-* ]]; then
        log_error "LITELLM_MASTER_KEY must start with 'sk-'. Run 'make litellm-bootstrap' to generate a valid key."
    fi
    litellm_ui_auth_path=$(trim "${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH:-}")
    if [ -z "$litellm_ui_auth_path" ]; then
        log_error "LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH is not set. Run 'make litellm-bootstrap' before enabling the litellm profile."
    fi
    if [[ "$litellm_ui_auth_path" == *.example ]]; then
        log_error "LiteLLM UI htpasswd path points to an example file. Run 'make litellm-bootstrap' to generate a real htpasswd."
    fi
    litellm_ui_auth_resolved=$(resolve_auth_path "$litellm_ui_auth_path")
    if [ ! -f "$litellm_ui_auth_resolved" ]; then
        log_error "LiteLLM UI htpasswd file not found: ${litellm_ui_auth_resolved}. Run 'make litellm-bootstrap' to generate it."
    fi
fi
