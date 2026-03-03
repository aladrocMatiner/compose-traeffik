#!/bin/bash
# Generate/persist Plane secrets in an env file.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${REPO_ROOT}/.env"
FORCE=false

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

usage() {
    cat <<'USAGE'
Usage: scripts/plane-bootstrap.sh [--env-file <path>] [--force]

Generates missing Plane secrets in the env file and preserves existing values by default.
Use --force to rotate already-present secrets.
USAGE
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            ;;
    esac
done

if [ ! -f "${ENV_FILE}" ]; then
    log_error "Env file not found: ${ENV_FILE}. Run make bootstrap first."
fi

random_string() {
    local length="${1:-48}"
    if command -v python3 >/dev/null 2>&1; then
        python3 - <<PY
import secrets, string
alphabet = string.ascii_letters + string.digits
print("".join(secrets.choice(alphabet) for _ in range(${length})))
PY
        return
    fi

    if command -v openssl >/dev/null 2>&1; then
        local out
        out=$(openssl rand -base64 96 | tr -dc 'A-Za-z0-9' | head -c "$length")
        if [ "${#out}" -lt "$length" ]; then
            log_error "Failed to generate random string with openssl."
        fi
        printf "%s" "$out"
        return
    fi

    log_error "Neither python3 nor openssl is available to generate secrets."
}

random_hex() {
    local bytes="${1:-16}"
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex "$bytes"
        return
    fi
    if command -v python3 >/dev/null 2>&1; then
        python3 - <<PY
import secrets
print(secrets.token_hex(${bytes}))
PY
        return
    fi
    log_error "Neither openssl nor python3 is available to generate hex values."
}

trim_quotes() {
    local v="$1"
    v="${v#\"}"
    v="${v%\"}"
    v="${v#\'}"
    v="${v%\'}"
    printf "%s" "$v"
}

get_env_value() {
    local key="$1"
    local line
    line=$(grep -E "^${key}=" "${ENV_FILE}" | tail -n 1 || true)
    [ -n "${line}" ] && printf "%s" "${line#*=}" || printf ""
}

set_env_value() {
    local key="$1"
    local value="$2"
    awk -v k="$key" -v v="$value" '
      BEGIN { found=0 }
      $0 ~ "^" k "=" { print k "=" v; found=1; next }
      { print }
      END { if (!found) print k "=" v }
    ' "${ENV_FILE}" > "${ENV_FILE}.tmp"
    mv "${ENV_FILE}.tmp" "${ENV_FILE}"
}

set_secret() {
    local key="$1"
    local length="${2:-48}"
    local current_raw current
    current_raw=$(get_env_value "$key")
    current=$(trim_quotes "$current_raw")
    if [ -n "$current" ] && [ "$FORCE" != "true" ]; then
        log_info "Keeping existing ${key}."
        return
    fi
    set_env_value "$key" "$(random_string "$length")"
    if [ "$FORCE" = "true" ] && [ -n "$current" ]; then
        log_info "Rotated ${key}."
    else
        log_info "Generated ${key}."
    fi
}

set_hex_secret() {
    local key="$1"
    local bytes="${2:-16}"
    local current_raw current
    current_raw=$(get_env_value "$key")
    current=$(trim_quotes "$current_raw")
    if [ -n "$current" ] && [ "$FORCE" != "true" ]; then
        log_info "Keeping existing ${key}."
        return
    fi
    set_env_value "$key" "$(random_hex "$bytes")"
    if [ "$FORCE" = "true" ] && [ -n "$current" ]; then
        log_info "Rotated ${key}."
    else
        log_info "Generated ${key}."
    fi
}

set_default_if_empty() {
    local key="$1" value="$2"
    local current
    current=$(trim_quotes "$(get_env_value "$key")")
    if [ -z "$current" ]; then
        set_env_value "$key" "$value"
        log_info "Set default ${key}."
    fi
}

set_default_if_empty "PLANE_HOSTNAME" "plane"
set_default_if_empty "PLANE_APP_RELEASE" "stable"
set_default_if_empty "PLANE_POSTGRES_IMAGE" "postgres:15.7-alpine"
set_default_if_empty "PLANE_REDIS_IMAGE" "valkey/valkey:7.2.11-alpine"
set_default_if_empty "PLANE_RABBITMQ_IMAGE" "rabbitmq:3.13.6-management-alpine"
set_default_if_empty "PLANE_MINIO_IMAGE" "minio/minio:RELEASE.2025-09-07T16-13-09Z"
set_default_if_empty "PLANE_POSTGRES_USER" "plane"
set_default_if_empty "PLANE_POSTGRES_DB" "plane"
set_default_if_empty "PLANE_POSTGRES_PGDATA" "/var/lib/postgresql/data"
set_default_if_empty "PLANE_RABBITMQ_USER" "plane"
set_default_if_empty "PLANE_RABBITMQ_VHOST" "plane"
set_default_if_empty "PLANE_USE_MINIO" "1"
set_default_if_empty "PLANE_AWS_ACCESS_KEY_ID" "access-key"
set_default_if_empty "PLANE_AWS_S3_ENDPOINT_URL" "http://plane-minio:9000"
set_default_if_empty "PLANE_AWS_S3_BUCKET_NAME" "uploads"
set_default_if_empty "PLANE_FILE_SIZE_LIMIT" "5242880"
set_default_if_empty "PLANE_API_KEY_RATE_LIMIT" "60/minute"
set_default_if_empty "PLANE_MINIO_ENDPOINT_SSL" "0"
set_default_if_empty "PLANE_TRUSTED_PROXIES" "0.0.0.0/0"
set_default_if_empty "PLANE_OIDC_ENABLED" "false"
set_default_if_empty "PLANE_KEYCLOAK_MODE" "external"
set_default_if_empty "PLANE_KEYCLOAK_INTERNAL_URL" "http://keycloak:8080"
set_default_if_empty "PLANE_OBSERVABILITY_ENABLED" "false"
set_default_if_empty "PLANE_OBSERVABILITY_METRICS_PATH" "/metrics"

set_secret "PLANE_SECRET_KEY" 64
set_secret "PLANE_LIVE_SERVER_SECRET_KEY" 48
set_secret "PLANE_POSTGRES_PASSWORD" 40
set_secret "PLANE_RABBITMQ_PASSWORD" 40
set_secret "PLANE_AWS_SECRET_ACCESS_KEY" 40
set_hex_secret "PLANE_MACHINE_SIGNATURE" 16

if [ "$FORCE" = "true" ]; then
    set_secret "PLANE_OIDC_CLIENT_SECRET" 40
fi

log_success "Plane bootstrap complete (${ENV_FILE})."
