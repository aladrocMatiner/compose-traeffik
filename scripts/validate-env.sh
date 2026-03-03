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
AWX_ENABLED_ENV="${AWX_ENABLED:-}"
CTFD_HOSTNAME_ENV="${CTFD_HOSTNAME:-}"
GRAFANA_HOSTNAME_ENV="${GRAFANA_HOSTNAME:-}"
PLANE_HOSTNAME_ENV="${PLANE_HOSTNAME:-}"
PLANE_OIDC_ENABLED_ENV="${PLANE_OIDC_ENABLED:-}"
PLANE_KEYCLOAK_MODE_ENV="${PLANE_KEYCLOAK_MODE:-}"
PLANE_KEYCLOAK_INTERNAL_URL_ENV="${PLANE_KEYCLOAK_INTERNAL_URL:-}"
PLANE_KEYCLOAK_EXTERNAL_URL_ENV="${PLANE_KEYCLOAK_EXTERNAL_URL:-}"
PLANE_OIDC_ISSUER_ENV="${PLANE_OIDC_ISSUER:-}"
PLANE_OIDC_CLIENT_ID_ENV="${PLANE_OIDC_CLIENT_ID:-}"
PLANE_OIDC_CLIENT_SECRET_ENV="${PLANE_OIDC_CLIENT_SECRET:-}"
PLANE_OIDC_REDIRECT_URI_ENV="${PLANE_OIDC_REDIRECT_URI:-}"
PLANE_OBSERVABILITY_ENABLED_ENV="${PLANE_OBSERVABILITY_ENABLED:-}"
PLANE_OBSERVABILITY_METRICS_PATH_ENV="${PLANE_OBSERVABILITY_METRICS_PATH:-}"
PLANE_OTEL_EXPORTER_OTLP_ENDPOINT_ENV="${PLANE_OTEL_EXPORTER_OTLP_ENDPOINT:-}"
DOCLING_HOSTNAME_ENV="${DOCLING_HOSTNAME:-}"
DOCLING_AUTH_MODE_ENV="${DOCLING_AUTH_MODE:-}"
DOCLING_API_KEY_ENV="${DOCLING_API_KEY:-}"
DOCLING_REDIS_PASSWORD_ENV="${DOCLING_REDIS_PASSWORD:-}"
DOCLING_ENGINE_KIND_ENV="${DOCLING_ENGINE_KIND:-}"
DOCLING_KEYCLOAK_ENABLED_ENV="${DOCLING_KEYCLOAK_ENABLED:-}"
DOCLING_KEYCLOAK_MODE_ENV="${DOCLING_KEYCLOAK_MODE:-}"
DOCLING_KEYCLOAK_INTERNAL_URL_ENV="${DOCLING_KEYCLOAK_INTERNAL_URL:-}"
DOCLING_KEYCLOAK_EXTERNAL_URL_ENV="${DOCLING_KEYCLOAK_EXTERNAL_URL:-}"
DOCLING_KEYCLOAK_CLIENT_ID_ENV="${DOCLING_KEYCLOAK_CLIENT_ID:-}"
DOCLING_KEYCLOAK_CLIENT_SECRET_ENV="${DOCLING_KEYCLOAK_CLIENT_SECRET:-}"
DOCLING_KEYCLOAK_ISSUER_ENV="${DOCLING_KEYCLOAK_ISSUER:-}"
DOCLING_OBSERVABILITY_ENABLED_ENV="${DOCLING_OBSERVABILITY_ENABLED:-}"
DOCLING_SERVE_OTEL_ENABLE_TRACES_ENV="${DOCLING_SERVE_OTEL_ENABLE_TRACES:-}"
DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT_ENV="${DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT:-}"
DOCLING_PROMETHEUS_METRICS_PATH_ENV="${DOCLING_PROMETHEUS_METRICS_PATH:-}"
DOCLING_TRAEFIK_MIDDLEWARES_ENV="${DOCLING_TRAEFIK_MIDDLEWARES:-}"
FREEIPA_HOSTNAME_ENV="${FREEIPA_HOSTNAME:-}"
FREEIPA_SERVER_HOSTNAME_ENV="${FREEIPA_SERVER_HOSTNAME:-}"
FREEIPA_REALM_ENV="${FREEIPA_REALM:-}"
FREEIPA_DOMAIN_ENV="${FREEIPA_DOMAIN:-}"
FREEIPA_ADMIN_PASSWORD_ENV="${FREEIPA_ADMIN_PASSWORD:-}"
FREEIPA_DM_PASSWORD_ENV="${FREEIPA_DM_PASSWORD:-}"
FREEIPA_TLS_MODE_ENV="${FREEIPA_TLS_MODE:-}"
FREEIPA_TRAEFIK_MIDDLEWARES_ENV="${FREEIPA_TRAEFIK_MIDDLEWARES:-}"
FREEIPA_KEYCLOAK_ENABLED_ENV="${FREEIPA_KEYCLOAK_ENABLED:-}"
FREEIPA_KEYCLOAK_MODE_ENV="${FREEIPA_KEYCLOAK_MODE:-}"
FREEIPA_KEYCLOAK_INTERNAL_URL_ENV="${FREEIPA_KEYCLOAK_INTERNAL_URL:-}"
FREEIPA_KEYCLOAK_EXTERNAL_URL_ENV="${FREEIPA_KEYCLOAK_EXTERNAL_URL:-}"
FREEIPA_KEYCLOAK_CLIENT_ID_ENV="${FREEIPA_KEYCLOAK_CLIENT_ID:-}"
FREEIPA_KEYCLOAK_CLIENT_SECRET_ENV="${FREEIPA_KEYCLOAK_CLIENT_SECRET:-}"
FREEIPA_KEYCLOAK_ISSUER_ENV="${FREEIPA_KEYCLOAK_ISSUER:-}"
FREEIPA_OBSERVABILITY_ENABLED_ENV="${FREEIPA_OBSERVABILITY_ENABLED:-}"
FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT_ENV="${FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT:-}"
FREEIPA_PROMETHEUS_METRICS_PATH_ENV="${FREEIPA_PROMETHEUS_METRICS_PATH:-}"

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
if [ -n "${AWX_ENABLED_ENV}" ]; then
    AWX_ENABLED="${AWX_ENABLED_ENV}"
fi
if [ -n "${CTFD_HOSTNAME_ENV}" ]; then
    CTFD_HOSTNAME="${CTFD_HOSTNAME_ENV}"
fi
if [ -n "${GRAFANA_HOSTNAME_ENV}" ]; then
    GRAFANA_HOSTNAME="${GRAFANA_HOSTNAME_ENV}"
fi
if [ -n "${PLANE_HOSTNAME_ENV}" ]; then
    PLANE_HOSTNAME="${PLANE_HOSTNAME_ENV}"
fi
if [ -n "${PLANE_OIDC_ENABLED_ENV}" ]; then
    PLANE_OIDC_ENABLED="${PLANE_OIDC_ENABLED_ENV}"
fi
if [ -n "${PLANE_KEYCLOAK_MODE_ENV}" ]; then
    PLANE_KEYCLOAK_MODE="${PLANE_KEYCLOAK_MODE_ENV}"
fi
if [ -n "${PLANE_KEYCLOAK_INTERNAL_URL_ENV}" ]; then
    PLANE_KEYCLOAK_INTERNAL_URL="${PLANE_KEYCLOAK_INTERNAL_URL_ENV}"
fi
if [ -n "${PLANE_KEYCLOAK_EXTERNAL_URL_ENV}" ]; then
    PLANE_KEYCLOAK_EXTERNAL_URL="${PLANE_KEYCLOAK_EXTERNAL_URL_ENV}"
fi
if [ -n "${PLANE_OIDC_ISSUER_ENV}" ]; then
    PLANE_OIDC_ISSUER="${PLANE_OIDC_ISSUER_ENV}"
fi
if [ -n "${PLANE_OIDC_CLIENT_ID_ENV}" ]; then
    PLANE_OIDC_CLIENT_ID="${PLANE_OIDC_CLIENT_ID_ENV}"
fi
if [ -n "${PLANE_OIDC_CLIENT_SECRET_ENV}" ]; then
    PLANE_OIDC_CLIENT_SECRET="${PLANE_OIDC_CLIENT_SECRET_ENV}"
fi
if [ -n "${PLANE_OIDC_REDIRECT_URI_ENV}" ]; then
    PLANE_OIDC_REDIRECT_URI="${PLANE_OIDC_REDIRECT_URI_ENV}"
fi
if [ -n "${PLANE_OBSERVABILITY_ENABLED_ENV}" ]; then
    PLANE_OBSERVABILITY_ENABLED="${PLANE_OBSERVABILITY_ENABLED_ENV}"
fi
if [ -n "${PLANE_OBSERVABILITY_METRICS_PATH_ENV}" ]; then
    PLANE_OBSERVABILITY_METRICS_PATH="${PLANE_OBSERVABILITY_METRICS_PATH_ENV}"
fi
if [ -n "${PLANE_OTEL_EXPORTER_OTLP_ENDPOINT_ENV}" ]; then
    PLANE_OTEL_EXPORTER_OTLP_ENDPOINT="${PLANE_OTEL_EXPORTER_OTLP_ENDPOINT_ENV}"
fi
if [ -n "${DOCLING_HOSTNAME_ENV}" ]; then
    DOCLING_HOSTNAME="${DOCLING_HOSTNAME_ENV}"
fi
if [ -n "${DOCLING_AUTH_MODE_ENV}" ]; then
    DOCLING_AUTH_MODE="${DOCLING_AUTH_MODE_ENV}"
fi
if [ -n "${DOCLING_API_KEY_ENV}" ]; then
    DOCLING_API_KEY="${DOCLING_API_KEY_ENV}"
fi
if [ -n "${DOCLING_REDIS_PASSWORD_ENV}" ]; then
    DOCLING_REDIS_PASSWORD="${DOCLING_REDIS_PASSWORD_ENV}"
fi
if [ -n "${DOCLING_ENGINE_KIND_ENV}" ]; then
    DOCLING_ENGINE_KIND="${DOCLING_ENGINE_KIND_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_ENABLED_ENV}" ]; then
    DOCLING_KEYCLOAK_ENABLED="${DOCLING_KEYCLOAK_ENABLED_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_MODE_ENV}" ]; then
    DOCLING_KEYCLOAK_MODE="${DOCLING_KEYCLOAK_MODE_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_INTERNAL_URL_ENV}" ]; then
    DOCLING_KEYCLOAK_INTERNAL_URL="${DOCLING_KEYCLOAK_INTERNAL_URL_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_EXTERNAL_URL_ENV}" ]; then
    DOCLING_KEYCLOAK_EXTERNAL_URL="${DOCLING_KEYCLOAK_EXTERNAL_URL_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_CLIENT_ID_ENV}" ]; then
    DOCLING_KEYCLOAK_CLIENT_ID="${DOCLING_KEYCLOAK_CLIENT_ID_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_CLIENT_SECRET_ENV}" ]; then
    DOCLING_KEYCLOAK_CLIENT_SECRET="${DOCLING_KEYCLOAK_CLIENT_SECRET_ENV}"
fi
if [ -n "${DOCLING_KEYCLOAK_ISSUER_ENV}" ]; then
    DOCLING_KEYCLOAK_ISSUER="${DOCLING_KEYCLOAK_ISSUER_ENV}"
fi
if [ -n "${DOCLING_OBSERVABILITY_ENABLED_ENV}" ]; then
    DOCLING_OBSERVABILITY_ENABLED="${DOCLING_OBSERVABILITY_ENABLED_ENV}"
fi
if [ -n "${DOCLING_SERVE_OTEL_ENABLE_TRACES_ENV}" ]; then
    DOCLING_SERVE_OTEL_ENABLE_TRACES="${DOCLING_SERVE_OTEL_ENABLE_TRACES_ENV}"
fi
if [ -n "${DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT_ENV}" ]; then
    DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT="${DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT_ENV}"
fi
if [ -n "${DOCLING_PROMETHEUS_METRICS_PATH_ENV}" ]; then
    DOCLING_PROMETHEUS_METRICS_PATH="${DOCLING_PROMETHEUS_METRICS_PATH_ENV}"
fi
if [ -n "${DOCLING_TRAEFIK_MIDDLEWARES_ENV}" ]; then
    DOCLING_TRAEFIK_MIDDLEWARES="${DOCLING_TRAEFIK_MIDDLEWARES_ENV}"
fi
if [ -n "${FREEIPA_HOSTNAME_ENV}" ]; then
    FREEIPA_HOSTNAME="${FREEIPA_HOSTNAME_ENV}"
fi
if [ -n "${FREEIPA_SERVER_HOSTNAME_ENV}" ]; then
    FREEIPA_SERVER_HOSTNAME="${FREEIPA_SERVER_HOSTNAME_ENV}"
fi
if [ -n "${FREEIPA_REALM_ENV}" ]; then
    FREEIPA_REALM="${FREEIPA_REALM_ENV}"
fi
if [ -n "${FREEIPA_DOMAIN_ENV}" ]; then
    FREEIPA_DOMAIN="${FREEIPA_DOMAIN_ENV}"
fi
if [ -n "${FREEIPA_ADMIN_PASSWORD_ENV}" ]; then
    FREEIPA_ADMIN_PASSWORD="${FREEIPA_ADMIN_PASSWORD_ENV}"
fi
if [ -n "${FREEIPA_DM_PASSWORD_ENV}" ]; then
    FREEIPA_DM_PASSWORD="${FREEIPA_DM_PASSWORD_ENV}"
fi
if [ -n "${FREEIPA_TLS_MODE_ENV}" ]; then
    FREEIPA_TLS_MODE="${FREEIPA_TLS_MODE_ENV}"
fi
if [ -n "${FREEIPA_TRAEFIK_MIDDLEWARES_ENV}" ]; then
    FREEIPA_TRAEFIK_MIDDLEWARES="${FREEIPA_TRAEFIK_MIDDLEWARES_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_ENABLED_ENV}" ]; then
    FREEIPA_KEYCLOAK_ENABLED="${FREEIPA_KEYCLOAK_ENABLED_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_MODE_ENV}" ]; then
    FREEIPA_KEYCLOAK_MODE="${FREEIPA_KEYCLOAK_MODE_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_INTERNAL_URL_ENV}" ]; then
    FREEIPA_KEYCLOAK_INTERNAL_URL="${FREEIPA_KEYCLOAK_INTERNAL_URL_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_EXTERNAL_URL_ENV}" ]; then
    FREEIPA_KEYCLOAK_EXTERNAL_URL="${FREEIPA_KEYCLOAK_EXTERNAL_URL_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_CLIENT_ID_ENV}" ]; then
    FREEIPA_KEYCLOAK_CLIENT_ID="${FREEIPA_KEYCLOAK_CLIENT_ID_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_CLIENT_SECRET_ENV}" ]; then
    FREEIPA_KEYCLOAK_CLIENT_SECRET="${FREEIPA_KEYCLOAK_CLIENT_SECRET_ENV}"
fi
if [ -n "${FREEIPA_KEYCLOAK_ISSUER_ENV}" ]; then
    FREEIPA_KEYCLOAK_ISSUER="${FREEIPA_KEYCLOAK_ISSUER_ENV}"
fi
if [ -n "${FREEIPA_OBSERVABILITY_ENABLED_ENV}" ]; then
    FREEIPA_OBSERVABILITY_ENABLED="${FREEIPA_OBSERVABILITY_ENABLED_ENV}"
fi
if [ -n "${FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT_ENV}" ]; then
    FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT="${FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT_ENV}"
fi
if [ -n "${FREEIPA_PROMETHEUS_METRICS_PATH_ENV}" ]; then
    FREEIPA_PROMETHEUS_METRICS_PATH="${FREEIPA_PROMETHEUS_METRICS_PATH_ENV}"
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

is_true() {
    local value="${1:-}"
    [ "$value" = "true" ] || [ "$value" = "1" ] || [ "$value" = "yes" ]
}

csv_contains_token() {
    local csv="${1:-}"
    local token="$2"
    local normalized="${csv// /}"
    case ",${normalized}," in
        *",${token},"*) return 0 ;;
        *) return 1 ;;
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

if [ "${AWX_ENABLED:-false}" = "true" ]; then
    "${SCRIPT_DIR}/validate-awx-env.sh" >/dev/null
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

if is_profile_enabled "plane"; then
    validate_subdomain_label "${PLANE_HOSTNAME:-plane}" "PLANE_HOSTNAME"
    require_non_placeholder "PLANE_SECRET_KEY" "${PLANE_SECRET_KEY:-}" "make plane-bootstrap"
    require_non_placeholder "PLANE_LIVE_SERVER_SECRET_KEY" "${PLANE_LIVE_SERVER_SECRET_KEY:-}" "make plane-bootstrap"
    require_non_placeholder "PLANE_POSTGRES_PASSWORD" "${PLANE_POSTGRES_PASSWORD:-}" "make plane-bootstrap"
    require_non_placeholder "PLANE_RABBITMQ_PASSWORD" "${PLANE_RABBITMQ_PASSWORD:-}" "make plane-bootstrap"
    require_non_placeholder "PLANE_AWS_SECRET_ACCESS_KEY" "${PLANE_AWS_SECRET_ACCESS_KEY:-}" "make plane-bootstrap"

    if is_true "${PLANE_OIDC_ENABLED:-false}"; then
        require_non_placeholder "PLANE_OIDC_ISSUER" "${PLANE_OIDC_ISSUER:-}"
        require_non_placeholder "PLANE_OIDC_CLIENT_ID" "${PLANE_OIDC_CLIENT_ID:-}"
        require_non_placeholder "PLANE_OIDC_CLIENT_SECRET" "${PLANE_OIDC_CLIENT_SECRET:-}"
        require_non_placeholder "PLANE_OIDC_REDIRECT_URI" "${PLANE_OIDC_REDIRECT_URI:-}"
        validate_http_url "${PLANE_OIDC_ISSUER:-}" "PLANE_OIDC_ISSUER"
        validate_http_url "${PLANE_OIDC_REDIRECT_URI:-}" "PLANE_OIDC_REDIRECT_URI"

        case "${PLANE_KEYCLOAK_MODE:-external}" in
            local)
                validate_http_url "${PLANE_KEYCLOAK_INTERNAL_URL:-http://keycloak:8080}" "PLANE_KEYCLOAK_INTERNAL_URL"
                ;;
            external)
                require_non_placeholder "PLANE_KEYCLOAK_EXTERNAL_URL" "${PLANE_KEYCLOAK_EXTERNAL_URL:-}"
                validate_http_url "${PLANE_KEYCLOAK_EXTERNAL_URL:-}" "PLANE_KEYCLOAK_EXTERNAL_URL"
                ;;
            *)
                log_error "PLANE_KEYCLOAK_MODE must be one of: local, external."
                ;;
        esac
    fi

    if is_true "${PLANE_OBSERVABILITY_ENABLED:-false}"; then
        if [ -n "${PLANE_OTEL_EXPORTER_OTLP_ENDPOINT:-}" ]; then
            validate_http_url "${PLANE_OTEL_EXPORTER_OTLP_ENDPOINT:-}" "PLANE_OTEL_EXPORTER_OTLP_ENDPOINT"
        fi
        if [ -n "${PLANE_OBSERVABILITY_METRICS_PATH:-}" ] && [[ "${PLANE_OBSERVABILITY_METRICS_PATH}" != /* ]]; then
            log_error "PLANE_OBSERVABILITY_METRICS_PATH must start with '/'. Got: ${PLANE_OBSERVABILITY_METRICS_PATH}"
        fi
    fi
fi

if is_profile_enabled "docling"; then
    validate_subdomain_label "${DOCLING_HOSTNAME:-docling}" "DOCLING_HOSTNAME"
    require_non_placeholder "DOCLING_REDIS_PASSWORD" "${DOCLING_REDIS_PASSWORD:-}" "make docling-bootstrap"

    case "${DOCLING_AUTH_MODE:-api-key}" in
        open)
            ;;
        api-key)
            require_non_placeholder "DOCLING_API_KEY" "${DOCLING_API_KEY:-}" "make docling-bootstrap"
            ;;
        keycloak)
            ;;
        *)
            log_error "DOCLING_AUTH_MODE must be one of: open, api-key, keycloak."
            ;;
    esac

    case "${DOCLING_ENGINE_KIND:-local}" in
        local|rq|kfp)
            ;;
        *)
            log_error "DOCLING_ENGINE_KIND must be one of: local, rq, kfp."
            ;;
    esac

    if is_true "${DOCLING_KEYCLOAK_ENABLED:-false}" || [ "${DOCLING_AUTH_MODE:-api-key}" = "keycloak" ]; then
        require_non_placeholder "DOCLING_TRAEFIK_MIDDLEWARES" "${DOCLING_TRAEFIK_MIDDLEWARES:-}"
        require_non_placeholder "DOCLING_KEYCLOAK_CLIENT_ID" "${DOCLING_KEYCLOAK_CLIENT_ID:-}"
        require_non_placeholder "DOCLING_KEYCLOAK_CLIENT_SECRET" "${DOCLING_KEYCLOAK_CLIENT_SECRET:-}"
        require_non_placeholder "DOCLING_KEYCLOAK_ISSUER" "${DOCLING_KEYCLOAK_ISSUER:-}"
        validate_http_url "${DOCLING_KEYCLOAK_ISSUER:-}" "DOCLING_KEYCLOAK_ISSUER"
        case "${DOCLING_KEYCLOAK_MODE:-external}" in
            local)
                validate_http_url "${DOCLING_KEYCLOAK_INTERNAL_URL:-http://keycloak:8080}" "DOCLING_KEYCLOAK_INTERNAL_URL"
                ;;
            external)
                require_non_placeholder "DOCLING_KEYCLOAK_EXTERNAL_URL" "${DOCLING_KEYCLOAK_EXTERNAL_URL:-}"
                validate_http_url "${DOCLING_KEYCLOAK_EXTERNAL_URL:-}" "DOCLING_KEYCLOAK_EXTERNAL_URL"
                ;;
            *)
                log_error "DOCLING_KEYCLOAK_MODE must be one of: local, external."
                ;;
        esac
    fi

    if is_true "${DOCLING_OBSERVABILITY_ENABLED:-false}"; then
        if is_true "${DOCLING_SERVE_OTEL_ENABLE_TRACES:-false}"; then
            require_non_placeholder "DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT" "${DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT:-}"
            validate_http_url "${DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT:-}" "DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT"
        fi
        if [ -n "${DOCLING_PROMETHEUS_METRICS_PATH:-}" ] && [[ "${DOCLING_PROMETHEUS_METRICS_PATH}" != /* ]]; then
            log_error "DOCLING_PROMETHEUS_METRICS_PATH must start with '/'. Got: ${DOCLING_PROMETHEUS_METRICS_PATH}"
        fi
    fi
fi

if is_profile_enabled "freeipa"; then
    validate_subdomain_label "${FREEIPA_HOSTNAME:-freeipa}" "FREEIPA_HOSTNAME"
    require_non_placeholder "FREEIPA_ADMIN_PASSWORD" "${FREEIPA_ADMIN_PASSWORD:-}" "make freeipa-bootstrap"
    require_non_placeholder "FREEIPA_DM_PASSWORD" "${FREEIPA_DM_PASSWORD:-}" "make freeipa-bootstrap"

    case "${FREEIPA_TLS_MODE:-stepca-acme}" in
        local-ca)
            ;;
        letsencrypt)
            if ! is_profile_enabled "le" && [ "${TLS_CERT_RESOLVER:-}" != "le-resolver" ]; then
                log_error "FREEIPA_TLS_MODE=letsencrypt requires profile 'le' or TLS_CERT_RESOLVER=le-resolver."
            fi
            ;;
        stepca-acme)
            if ! is_profile_enabled "stepca" && [ "${TLS_CERT_RESOLVER:-}" != "stepca-resolver" ]; then
                log_error "FREEIPA_TLS_MODE=stepca-acme requires profile 'stepca' or TLS_CERT_RESOLVER=stepca-resolver."
            fi
            ;;
        *)
            log_error "FREEIPA_TLS_MODE must be one of: local-ca, letsencrypt, stepca-acme."
            ;;
    esac

    if is_true "${FREEIPA_KEYCLOAK_ENABLED:-false}"; then
        require_non_placeholder "FREEIPA_TRAEFIK_MIDDLEWARES" "${FREEIPA_TRAEFIK_MIDDLEWARES:-}"
        if ! csv_contains_token "${FREEIPA_TRAEFIK_MIDDLEWARES:-}" "keycloak-forward-auth@file"; then
            log_error "FREEIPA_TRAEFIK_MIDDLEWARES must include keycloak-forward-auth@file when FREEIPA_KEYCLOAK_ENABLED=true."
        fi

        require_non_placeholder "FREEIPA_KEYCLOAK_CLIENT_ID" "${FREEIPA_KEYCLOAK_CLIENT_ID:-}"
        require_non_placeholder "FREEIPA_KEYCLOAK_CLIENT_SECRET" "${FREEIPA_KEYCLOAK_CLIENT_SECRET:-}"
        require_non_placeholder "FREEIPA_KEYCLOAK_ISSUER" "${FREEIPA_KEYCLOAK_ISSUER:-}"
        validate_http_url "${FREEIPA_KEYCLOAK_ISSUER:-}" "FREEIPA_KEYCLOAK_ISSUER"

        case "${FREEIPA_KEYCLOAK_MODE:-external}" in
            local)
                validate_http_url "${FREEIPA_KEYCLOAK_INTERNAL_URL:-http://keycloak:8080}" "FREEIPA_KEYCLOAK_INTERNAL_URL"
                ;;
            external)
                require_non_placeholder "FREEIPA_KEYCLOAK_EXTERNAL_URL" "${FREEIPA_KEYCLOAK_EXTERNAL_URL:-}"
                validate_http_url "${FREEIPA_KEYCLOAK_EXTERNAL_URL:-}" "FREEIPA_KEYCLOAK_EXTERNAL_URL"
                ;;
            *)
                log_error "FREEIPA_KEYCLOAK_MODE must be one of: local, external."
                ;;
        esac
    fi

    if is_true "${FREEIPA_OBSERVABILITY_ENABLED:-false}"; then
        require_non_placeholder "FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT" "${FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT:-}"
        validate_http_url "${FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT:-}" "FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT"
        if [ -n "${FREEIPA_PROMETHEUS_METRICS_PATH:-}" ] && [[ "${FREEIPA_PROMETHEUS_METRICS_PATH}" != /* ]]; then
            log_error "FREEIPA_PROMETHEUS_METRICS_PATH must start with '/'. Got: ${FREEIPA_PROMETHEUS_METRICS_PATH}"
        fi
    fi
fi
