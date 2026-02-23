#!/bin/bash
# File: scripts/wg-bootstrap.sh
#
# Populate wg-easy bootstrap admin variables in .env.
#
# Usage:
#   ./scripts/wg-bootstrap.sh
#   ./scripts/wg-bootstrap.sh --force
#   ./scripts/wg-bootstrap.sh --env-file .env.tmp

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

ENV_FILE="${REPO_ROOT}/.env"
FORCE=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --env-file)
            if [ -z "${2:-}" ]; then
                log_error "Missing value for --env-file."
            fi
            ENV_FILE="$2"
            shift 2
            ;;
        --env-file=*)
            ENV_FILE="${1#--env-file=}"
            shift
            ;;
        *)
            log_error "Unknown argument: $1"
            ;;
    esac
done

if [ ! -f "${ENV_FILE}" ]; then
    log_error "Missing env file '${ENV_FILE}'. Run 'make bootstrap' first (or pass --env-file <path>)."
fi

random_string() {
    local length="${1:-32}"
    if command -v python3 >/dev/null 2>&1; then
        LENGTH="$length" python3 - <<'PY'
import os
import secrets
import string

alphabet = string.ascii_letters + string.digits
length = int(os.environ.get("LENGTH", "32"))
print("".join(secrets.choice(alphabet) for _ in range(length)))
PY
        return
    fi
    if command -v openssl >/dev/null 2>&1; then
        local out
        out=$(openssl rand -base64 64 | tr -dc 'A-Za-z0-9' | head -c "$length")
        if [ "${#out}" -lt "$length" ]; then
            log_error "Failed to generate random string with openssl."
        fi
        printf "%s" "$out"
        return
    fi
    log_error "Neither python3 nor openssl is available to generate secrets."
}

trim_quotes() {
    local val="$1"
    val="${val#\"}"
    val="${val%\"}"
    val="${val#\'}"
    val="${val%\'}"
    printf "%s" "$val"
}

get_env_value() {
    local key="$1"
    local line
    line=$(grep -E "^${key}=" "${ENV_FILE}" | tail -n 1 || true)
    if [ -z "$line" ]; then
        printf ""
        return
    fi
    printf "%s" "${line#*=}"
}

set_env_value() {
    local key="$1"
    local value="$2"
    awk -v k="$key" -v v="$value" '
        BEGIN { found=0 }
        $0 ~ "^"k"=" { print k"="v; found=1; next }
        { print }
        END { if (!found) print k"="v }
    ' "${ENV_FILE}" > "${ENV_FILE}.tmp" && mv "${ENV_FILE}.tmp" "${ENV_FILE}"
}

set_default_if_empty() {
    local key="$1"
    local value="$2"
    local current
    current=$(trim_quotes "$(get_env_value "$key")")
    if [ -z "$current" ]; then
        set_env_value "$key" "$value"
        log_info "Set ${key}."
    fi
}

set_secret_if_needed() {
    local key="$1"
    local length="${2:-32}"
    local current
    current=$(trim_quotes "$(get_env_value "$key")")
    if [ -z "$current" ] || [ "${FORCE}" = true ]; then
        set_env_value "$key" "$(random_string "$length")"
        if [ "${FORCE}" = true ] && [ -n "$current" ]; then
            log_info "Rotated ${key}."
        else
            log_info "Generated ${key}."
        fi
    fi
}

set_default_if_empty "WG_INIT_ENABLED" "true"
set_default_if_empty "WG_INIT_USERNAME" "admin"
set_secret_if_needed "WG_INIT_PASSWORD" 32

if [ "${FORCE}" = true ]; then
    log_warn "wg-easy bootstrap password was rotated. Review and update stored admin access if needed."
fi

log_success "wg-easy bootstrap variables are present in ${ENV_FILE}."
