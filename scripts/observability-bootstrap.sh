#!/bin/bash
# Generate/persist observability (Grafana) secrets in an env file.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${REPO_ROOT}/.env"
FORCE=false

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

usage() {
    cat <<'USAGE'
Usage: scripts/observability-bootstrap.sh [--env-file <path>] [--force]

Generates missing Grafana admin credentials/secrets in the env file and preserves existing values by default.
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

set_default_if_empty "GRAFANA_HOSTNAME" "grafana"
set_default_if_empty "GRAFANA_ADMIN_USER" "admin"
set_default_if_empty "GRAFANA_IMAGE" "grafana/grafana:12.3.2"
set_default_if_empty "PROMETHEUS_IMAGE" "prom/prometheus:v3.5.1"
set_default_if_empty "LOKI_IMAGE" "grafana/loki:3.6.3"
set_default_if_empty "ALLOY_IMAGE" "grafana/alloy:v1.11.2"
set_default_if_empty "TEMPO_IMAGE" "grafana/tempo:2.6.1"
set_default_if_empty "PYROSCOPE_IMAGE" "grafana/pyroscope:1.12.0"
set_default_if_empty "K6_IMAGE" "grafana/k6:0.49.0"
set_default_if_empty "PROMETHEUS_RETENTION_TIME" "7d"
set_default_if_empty "LOKI_RETENTION_PERIOD" "168h"
set_default_if_empty "TEMPO_RETENTION_PERIOD" "168h"
set_default_if_empty "PYROSCOPE_RETENTION_PERIOD" "168h"
set_default_if_empty "K6_TARGET_URL" "https://whoami.local.test"
set_default_if_empty "K6_ITERATIONS" "10"
set_default_if_empty "K6_SLEEP_SECONDS" "1"
set_default_if_empty "K6_OUT" "experimental-prometheus-rw"
set_default_if_empty "K6_PROMETHEUS_RW_SERVER_URL" "http://prometheus:9090/api/v1/write"
set_default_if_empty "K6_PROMETHEUS_RW_TREND_STATS" "p(50),p(90),p(95),p(99),min,max,avg"

set_secret "GRAFANA_ADMIN_PASSWORD" 32
set_secret "GRAFANA_SECRET_KEY" 64

log_success "Observability bootstrap complete (${ENV_FILE})."
