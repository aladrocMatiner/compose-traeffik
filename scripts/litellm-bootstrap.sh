#!/bin/bash
# File: scripts/litellm-bootstrap.sh
#
# Generate LiteLLM secrets and admin UI BasicAuth assets in an env file.
#
# Usage:
#   ./scripts/litellm-bootstrap.sh [--env-file <path>] [--force]
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

ENV_FILE_FLAG=""
FORCE=false

print_usage() {
    cat <<'USAGE'
Usage:
  ./scripts/litellm-bootstrap.sh [--env-file <path>] [--force]

Options:
  --env-file <path>  Path to env file (default: ENV_FILE or ./.env)
  --force            Rotate/overwrite existing LiteLLM secrets and UI auth assets
USAGE
}

log() {
    echo "$1"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

trim_quotes() {
    local val="$1"
    val="${val#\"}"
    val="${val%\"}"
    val="${val#\'}"
    val="${val%\'}"
    printf "%s" "$val"
}

random_alnum() {
    local length="${1:-48}"
    if command -v python3 >/dev/null 2>&1; then
        LENGTH="$length" python3 - <<'PY'
import os
import secrets
import string
alphabet = string.ascii_letters + string.digits
length = int(os.environ.get('LENGTH', '48'))
print(''.join(secrets.choice(alphabet) for _ in range(length)))
PY
        return
    fi
    if command -v openssl >/dev/null 2>&1; then
        local out
        out=$(openssl rand -base64 128 | tr -dc 'A-Za-z0-9' | head -c "$length")
        [ "${#out}" -eq "$length" ] || fail "Failed to generate random value."
        printf "%s" "$out"
        return
    fi
    fail "python3 or openssl is required to generate secrets."
}

resolve_env_file() {
    if [ -n "$ENV_FILE_FLAG" ]; then
        printf '%s' "$ENV_FILE_FLAG"
        return
    fi
    if [ -n "${ENV_FILE:-}" ]; then
        printf '%s' "$ENV_FILE"
        return
    fi
    printf '%s' "${REPO_ROOT}/.env"
}

ensure_env_file_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        return
    fi
    if [ "$file" = "${REPO_ROOT}/.env" ] && [ -f "${REPO_ROOT}/.env.example" ]; then
        cp "${REPO_ROOT}/.env.example" "$file"
        log "INFO: Created ${file} from .env.example"
        return
    fi
    fail "Env file not found: ${file}"
}

get_env_value() {
    local file="$1"
    local key="$2"
    local line
    line=$(grep -E "^${key}=" "$file" | tail -n 1 || true)
    [ -n "$line" ] || { printf ""; return; }
    printf '%s' "${line#*=}"
}

set_env_value() {
    local file="$1"
    local key="$2"
    local value="$3"
    awk -v k="$key" -v v="$value" '
        BEGIN { found=0 }
        $0 ~ "^" k "=" { print k "=" v; found=1; next }
        { print }
        END { if (!found) print k "=" v }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

generate_master_key() {
    printf 'sk-%s' "$(random_alnum 48)"
}

generate_salt_key() {
    printf 'sk-%s' "$(random_alnum 48)"
}

generate_ui_password() {
    random_alnum 32
}

resolve_auth_path() {
    local path="$1"
    [[ "$path" == /etc/traefik/auth/* ]] || fail "Auth file must be under /etc/traefik/auth/. Got: ${path}"
    local relative="${path#/etc/traefik/auth/}"
    [ -n "$relative" ] || fail "Auth file path must include a filename under /etc/traefik/auth/."
    [[ "$relative" != *..* ]] || fail "Auth file path must not contain '..': ${path}"
    printf '%s' "${REPO_ROOT}/services/traefik/auth/${relative}"
}

generate_htpasswd_entry() {
    local user="$1"
    local pass="$2"

    if command -v htpasswd >/dev/null 2>&1; then
        htpasswd -nbB "$user" "$pass" | head -n 1
        return
    fi
    if command -v openssl >/dev/null 2>&1; then
        local hash
        hash=$(openssl passwd -apr1 "$pass")
        printf '%s:%s\n' "$user" "$hash"
        return
    fi
    fail "Missing htpasswd or openssl to generate BasicAuth credentials."
}

ensure_litellm_ui_htpasswd() {
    local env_file="$1"
    local user_raw pass_raw path_raw
    local user pass container_path local_path

    user_raw=$(get_env_value "$env_file" "LITELLM_UI_BASIC_AUTH_USER")
    pass_raw=$(get_env_value "$env_file" "LITELLM_UI_BASIC_AUTH_PASSWORD")
    path_raw=$(get_env_value "$env_file" "LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH")

    user=$(trim_quotes "$user_raw")
    pass=$(trim_quotes "$pass_raw")
    container_path=$(trim_quotes "$path_raw")

    [ -n "$user" ] || { user="admin"; set_env_value "$env_file" "LITELLM_UI_BASIC_AUTH_USER" "$user"; log "INFO: Set LITELLM_UI_BASIC_AUTH_USER default."; }
    [ -n "$container_path" ] || { container_path="/etc/traefik/auth/litellm-ui.htpasswd"; set_env_value "$env_file" "LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH" "$container_path"; log "INFO: Set LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH default."; }
    [ -n "$pass" ] || fail "LITELLM_UI_BASIC_AUTH_PASSWORD is empty after bootstrap generation."

    local_path=$(resolve_auth_path "$container_path")
    mkdir -p "$(dirname "$local_path")"

    if [ -f "$local_path" ] && [ "$FORCE" = false ]; then
        log "INFO: Keeping existing LiteLLM UI htpasswd file."
        return
    fi

    generate_htpasswd_entry "$user" "$pass" > "$local_path"
    chmod 600 "$local_path" 2>/dev/null || true
    if [ "$FORCE" = true ] && [ -f "$local_path" ]; then
        log "INFO: Wrote LiteLLM UI htpasswd file (${local_path})."
    else
        log "INFO: Generated LiteLLM UI htpasswd file (${local_path})."
    fi
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --env-file)
            [ -n "${2:-}" ] || fail "Missing value for --env-file"
            ENV_FILE_FLAG="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            fail "Unknown argument: $1"
            ;;
    esac
done

ENV_TARGET=$(resolve_env_file)
ensure_env_file_exists "$ENV_TARGET"

update_secret_var() {
    local key="$1"
    local generator="$2"
    local current_raw current
    current_raw=$(get_env_value "$ENV_TARGET" "$key")
    current=$(trim_quotes "$current_raw")

    if [ "$FORCE" = false ] && [ -n "$current" ]; then
        log "INFO: Keeping existing ${key}."
        return
    fi

    local new_value
    new_value=$($generator)
    set_env_value "$ENV_TARGET" "$key" "$new_value"
    if [ -n "$current" ]; then
        log "INFO: Rotated ${key}."
    else
        log "INFO: Generated ${key}."
    fi
}

update_default_if_empty() {
    local key="$1"
    local value="$2"
    local current_raw current
    current_raw=$(get_env_value "$ENV_TARGET" "$key")
    current=$(trim_quotes "$current_raw")
    if [ -z "$current" ]; then
        set_env_value "$ENV_TARGET" "$key" "$value"
        log "INFO: Set ${key} default."
    fi
}

update_secret_var "LITELLM_MASTER_KEY" generate_master_key
update_secret_var "LITELLM_SALT_KEY" generate_salt_key
update_default_if_empty "LITELLM_UI_BASIC_AUTH_USER" "admin"
update_default_if_empty "LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH" "/etc/traefik/auth/litellm-ui.htpasswd"
update_secret_var "LITELLM_UI_BASIC_AUTH_PASSWORD" generate_ui_password
ensure_litellm_ui_htpasswd "$ENV_TARGET"

log "SUCCESS: LiteLLM bootstrap complete (${ENV_TARGET})."
