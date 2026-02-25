#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

ENV_FILE="${REPO_ROOT}/.env"
FORCE=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --env-file)
      [ -n "${2:-}" ] || log_error "Missing value for --env-file"
      ENV_FILE="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      log_error "Unknown argument: $1"
      ;;
  esac
done

case "$ENV_FILE" in
  /*) ;;
  *) ENV_FILE="${REPO_ROOT}/${ENV_FILE}" ;;
esac

[ -f "$ENV_FILE" ] || log_error "Env file not found: $ENV_FILE"

random_string() {
  local length="${1:-48}"
  if command -v python3 >/dev/null 2>&1; then
    LENGTH="$length" python3 - <<'PY'
import os, secrets, string
alphabet = string.ascii_letters + string.digits
print(''.join(secrets.choice(alphabet) for _ in range(int(os.environ.get('LENGTH','48')))))
PY
    return
  fi
  if command -v openssl >/dev/null 2>&1; then
    local out
    out=$(openssl rand -base64 96 | tr -dc 'A-Za-z0-9' | head -c "$length")
    [ "${#out}" -ge "$length" ] || log_error "Failed to generate random string with openssl."
    printf '%s' "$out"
    return
  fi
  log_error "Neither python3 nor openssl is available for secret generation."
}

trim_quotes() {
  local v="$1"
  v="${v#\"}"; v="${v%\"}"
  v="${v#\'}"; v="${v%\'}"
  printf '%s' "$v"
}

get_env_value() {
  local key="$1"
  local line
  line=$(grep -E "^${key}=" "$ENV_FILE" | tail -n1 || true)
  [ -n "$line" ] || { printf ''; return; }
  printf '%s' "${line#*=}"
}

set_env_value() {
  local key="$1" value="$2"
  awk -v k="$key" -v v="$value" '
    BEGIN { found=0 }
    $0 ~ "^"k"=" { print k"="v; found=1; next }
    { print }
    END { if (!found) print k"="v }
  ' "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"
}

set_default_if_empty() {
  local key="$1" value="$2"
  local cur
  cur=$(trim_quotes "$(get_env_value "$key")")
  if [ -z "$cur" ]; then
    set_env_value "$key" "$value"
    log_info "Set default ${key}."
  fi
}

ensure_secret() {
  local key="$1" length="$2"
  local cur
  cur=$(trim_quotes "$(get_env_value "$key")")
  if [ -z "$cur" ] || [ "$FORCE" = true ]; then
    set_env_value "$key" "$(random_string "$length")"
    if [ "$FORCE" = true ] && [ -n "$cur" ]; then
      log_warn "Rotated ${key} due to --force."
    else
      log_info "Generated ${key}."
    fi
  fi
}

set_default_if_empty "KEYCLOAK_HOSTNAME" "keycloak"
set_default_if_empty "KEYCLOAK_IMAGE" "quay.io/keycloak/keycloak:26.5.3"
set_default_if_empty "KEYCLOAK_ADMIN_USER" "admin"
set_default_if_empty "KEYCLOAK_DB_NAME" "keycloak"
set_default_if_empty "KEYCLOAK_DB_USER" "keycloak"
set_default_if_empty "KEYCLOAK_DB_PORT" "5432"
set_default_if_empty "KEYCLOAK_PROXY_HEADERS" "xforwarded"
set_default_if_empty "KEYCLOAK_HEALTH_ENABLED" "true"
set_default_if_empty "KEYCLOAK_OBSERVABILITY_ENABLED" "false"
set_default_if_empty "KEYCLOAK_OBSERVABILITY_DISCOVERY" "labels"
set_default_if_empty "KEYCLOAK_MANAGEMENT_PORT" "9000"
set_default_if_empty "KEYCLOAK_HTTP_ACCESS_LOG_ENABLED" "true"
set_default_if_empty "KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS" "false"

ensure_secret "KEYCLOAK_ADMIN_PASSWORD" 32
ensure_secret "KEYCLOAK_DB_PASSWORD" 32

log_success "Keycloak bootstrap complete (${ENV_FILE})."
