#!/bin/bash
# Generate/persist Docling secrets in an env file.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${REPO_ROOT}/.env"
FORCE=false

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

usage() {
    cat <<'USAGE'
Usage: scripts/docling-bootstrap.sh [--env-file <path>] [--force]

Generates missing Docling secrets in the env file and preserves existing values by default.
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

set_default_if_empty() {
    local key="$1" value="$2"
    local current
    current=$(trim_quotes "$(get_env_value "$key")")
    if [ -z "$current" ]; then
        set_env_value "$key" "$value"
        log_info "Set default ${key}."
    fi
}

set_default_if_empty "DOCLING_HOSTNAME" "docling"
set_default_if_empty "DOCLING_IMAGE" "ghcr.io/docling-project/docling-serve-cpu"
set_default_if_empty "DOCLING_IMAGE_TAG" "main"
set_default_if_empty "DOCLING_REDIS_IMAGE" "redis:7.2.11-alpine"
set_default_if_empty "DOCLING_ENABLE_UI" "true"
set_default_if_empty "DOCLING_LOG_LEVEL" "WARNING"
set_default_if_empty "DOCLING_ENGINE_KIND" "local"
set_default_if_empty "DOCLING_AUTH_MODE" "api-key"
set_default_if_empty "DOCLING_TRAEFIK_MIDDLEWARES" "security-headers@file"
set_default_if_empty "DOCLING_UVICORN_ROOT_PATH" ""
set_default_if_empty "DOCLING_MAX_SYNC_WAIT" "120"
set_default_if_empty "DOCLING_LOAD_MODELS_AT_BOOT" "true"
set_default_if_empty "DOCLING_ARTIFACTS_PATH" "/var/lib/docling/artifacts"
set_default_if_empty "DOCLING_SCRATCH_PATH" "/var/lib/docling/scratch"
set_default_if_empty "DOCLING_KEYCLOAK_ENABLED" "false"
set_default_if_empty "DOCLING_KEYCLOAK_MODE" "external"
set_default_if_empty "DOCLING_KEYCLOAK_INTERNAL_URL" "http://keycloak:8080"
set_default_if_empty "DOCLING_OBSERVABILITY_ENABLED" "false"
set_default_if_empty "DOCLING_SERVE_OTEL_ENABLE_METRICS" "false"
set_default_if_empty "DOCLING_SERVE_OTEL_ENABLE_TRACES" "false"
set_default_if_empty "DOCLING_SERVE_OTEL_ENABLE_PROMETHEUS" "false"
set_default_if_empty "DOCLING_SERVE_OTEL_SERVICE_NAME" "docling-serve"
set_default_if_empty "DOCLING_PROMETHEUS_METRICS_PATH" "/metrics"

set_secret "DOCLING_API_KEY" 48
set_secret "DOCLING_REDIS_PASSWORD" 40
if [ "$FORCE" = "true" ]; then
    set_secret "DOCLING_KEYCLOAK_CLIENT_SECRET" 40
fi

log_success "Docling bootstrap complete (${ENV_FILE})."
