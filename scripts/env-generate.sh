#!/bin/bash
# File: scripts/env-generate.sh
#
# Generate a .env file from .env.example and fill empty secrets with random values.
#
# Usage:
#   ./scripts/env-generate.sh
#   ./scripts/env-generate.sh --force
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"
FORCE=false

if [ "${1:-}" = "--force" ]; then
    FORCE=true
fi

if [ ! -f "$ENV_EXAMPLE" ]; then
    log_error "Missing $ENV_EXAMPLE. Cannot bootstrap environment."
fi

if [ ! -f "$ENV_FILE" ] || [ "$FORCE" = true ]; then
    if [ -f "$ENV_FILE" ] && [ "$FORCE" = true ]; then
        log_warn "Overwriting existing $ENV_FILE due to --force."
    fi
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    log_success "Created $ENV_FILE from $ENV_EXAMPLE."
fi

random_string() {
    local length="${1:-48}"
    if command -v python3 >/dev/null 2>&1; then
        LENGTH="$length" python3 - <<'PY'
import secrets
import string
import os

alphabet = string.ascii_letters + string.digits
length = int(os.environ.get("LENGTH", "48"))
print("".join(secrets.choice(alphabet) for _ in range(length)))
PY
        return
    fi
    if command -v openssl >/dev/null 2>&1; then
        local out
        out=$(openssl rand -base64 96 | tr -dc 'A-Za-z0-9' | head -c "$length")
        if [ "${#out}" -lt "$length" ]; then
            log_error "Failed to generate a random string with openssl."
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

set_env_value() {
    local key="$1"
    local value="$2"
    awk -v k="$key" -v v="$value" '
        BEGIN { found=0 }
        $0 ~ "^"k"=" { print k"="v; found=1; next }
        { print }
        END { if (!found) print k"="v }
    ' "$ENV_FILE" > "${ENV_FILE}.tmp" && mv "${ENV_FILE}.tmp" "$ENV_FILE"
}

get_env_value() {
    local key="$1"
    local line
    line=$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 || true)
    if [ -z "$line" ]; then
        printf ""
        return
    fi
    printf "%s" "${line#*=}"
}

SECRET_VARS=(
    "DNS_ADMIN_PASSWORD"
    "STEP_CA_ADMIN_PROVISIONER_PASSWORD"
    "STEP_CA_PASSWORD"
)

for var in "${SECRET_VARS[@]}"; do
    current_raw=$(get_env_value "$var")
    current=$(trim_quotes "$current_raw")
    if [ -z "$current" ]; then
        new_value=$(random_string 48)
        set_env_value "$var" "$new_value"
        log_info "Generated ${var}."
    fi
done

log_success "Environment bootstrap complete."
