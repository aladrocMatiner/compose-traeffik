#!/bin/bash
# File: scripts/env-generate.sh
#
# Generate a .env file from .env.example and fill empty secrets with random values.
#
# Usage:
#   ./scripts/env-generate.sh
#   ./scripts/env-generate.sh --mode=prod
#   ./scripts/env-generate.sh --mode=full
#   ./scripts/env-generate.sh --mode=full --force
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"
FORCE=false
MODE="prod"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --mode=*)
            MODE="${1#--mode=}"
            shift
            ;;
        --mode)
            if [ -n "${2:-}" ]; then
                MODE="$2"
                shift 2
            else
                log_error "Missing value for --mode."
            fi
            ;;
        *)
            log_error "Unknown argument: $1"
            ;;
    esac
done

case "$MODE" in
    prod|full)
        ;;
    *)
        log_error "Invalid mode: ${MODE}. Use --mode=prod or --mode=full."
        ;;
esac

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

DEFAULT_ENDPOINTS_FULL="whoami,traefik,stepca,dns"
DEFAULT_COMPOSE_PROFILES_FULL="dns,le,stepca"
DEFAULT_TRAEFIK_DASHBOARD_FULL="true"
DEFAULT_DNS_UI_BASIC_AUTH_HTPASSWD_PATH_FULL="/etc/traefik/auth/dns-ui.htpasswd"
DEFAULT_TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_FULL="/etc/traefik/auth/traefik-dashboard.htpasswd"

for var in "${SECRET_VARS[@]}"; do
    current_raw=$(get_env_value "$var")
    current=$(trim_quotes "$current_raw")
    if [ -z "$current" ]; then
        new_value=$(random_string 48)
        set_env_value "$var" "$new_value"
        log_info "Generated ${var}."
    fi
done

set_default_if_empty() {
    local key="$1"
    local value="$2"
    local current_raw
    local current
    current_raw=$(get_env_value "$key")
    current=$(trim_quotes "$current_raw")
    if [ -z "$current" ]; then
        set_env_value "$key" "$value"
        log_info "Set ${key} default."
    fi
}

set_default_if_example() {
    local key="$1"
    local value="$2"
    local current_raw
    local current
    current_raw=$(get_env_value "$key")
    current=$(trim_quotes "$current_raw")
    if [ -z "$current" ] || [[ "$current" == *.example ]]; then
        set_env_value "$key" "$value"
        log_info "Set ${key} default."
    fi
}

ensure_endpoint_in_list() {
    local list="$1"
    local endpoint="$2"
    local trimmed
    local part
    local -a parts=()
    local -a unique=()
    local found=false

    IFS=',' read -r -a parts <<< "$list"
    for part in "${parts[@]}"; do
        trimmed=$(trim_quotes "$part")
        trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        if [ -z "$trimmed" ]; then
            continue
        fi
        if [ "$trimmed" = "$endpoint" ]; then
            found=true
        fi
        if [[ " ${unique[*]} " == *" ${trimmed} "* ]]; then
            continue
        fi
        unique+=("$trimmed")
    done

    if [ "$found" = false ]; then
        unique+=("$endpoint")
    fi

    (IFS=','; echo "${unique[*]}")
}

if [ "$MODE" = "full" ]; then
    set_default_if_empty "TRAEFIK_DASHBOARD" "$DEFAULT_TRAEFIK_DASHBOARD_FULL"
    set_default_if_empty "COMPOSE_PROFILES" "$DEFAULT_COMPOSE_PROFILES_FULL"
    set_default_if_example "DNS_UI_BASIC_AUTH_HTPASSWD_PATH" "$DEFAULT_DNS_UI_BASIC_AUTH_HTPASSWD_PATH_FULL"
    set_default_if_example "TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH" "$DEFAULT_TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH_FULL"
    endpoints_raw=$(get_env_value "ENDPOINTS")
    endpoints_trimmed=$(trim_quotes "$endpoints_raw")
    if [ -z "$endpoints_trimmed" ]; then
        set_env_value "ENDPOINTS" "$DEFAULT_ENDPOINTS_FULL"
        log_info "Set ENDPOINTS default for full mode."
    else
        endpoints_updated=$(ensure_endpoint_in_list "$endpoints_trimmed" "dns")
        if [ "$endpoints_updated" != "$endpoints_trimmed" ]; then
            set_env_value "ENDPOINTS" "$endpoints_updated"
            log_info "Added dns to ENDPOINTS for full mode."
        fi
    fi
else
    set_env_value "TRAEFIK_DASHBOARD" "false"
    set_env_value "COMPOSE_PROFILES" ""
    set_env_value "DNS_UI_BASIC_AUTH_HTPASSWD_PATH" ""
    set_env_value "TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH" ""
fi

ensure_htpasswd_file() {
    local container_path="$1"
    local label="$2"
    if [[ "$container_path" != /etc/traefik/auth/* ]]; then
        log_warn "${label} auth path is not under /etc/traefik/auth/: ${container_path}"
        return
    fi
    local relative="${container_path#/etc/traefik/auth/}"
    local host_path="${REPO_ROOT}/services/traefik/auth/${relative}"
    local example_path="${host_path}.example"

    if [ -f "$host_path" ]; then
        return
    fi

    mkdir -p "$(dirname "$host_path")"

    if [ -f "$example_path" ]; then
        cp "$example_path" "$host_path"
        log_info "Created ${label} htpasswd from example."
        return
    fi

    log_error "Missing example htpasswd for ${label}: ${example_path}"
}

if [ "$MODE" = "full" ]; then
    dns_auth_path=$(trim_quotes "$(get_env_value "DNS_UI_BASIC_AUTH_HTPASSWD_PATH")")
    dashboard_auth_path=$(trim_quotes "$(get_env_value "TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH")")

    ensure_htpasswd_file "$dns_auth_path" "DNS UI"
    ensure_htpasswd_file "$dashboard_auth_path" "Traefik dashboard"
fi

log_success "Environment bootstrap complete."
