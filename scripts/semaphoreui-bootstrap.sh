#!/bin/bash
# Bootstrap Semaphore UI env defaults and secrets in .env

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
      FORCE=true; shift ;;
    --env-file)
      ENV_FILE="$2"; shift 2 ;;
    --env-file=*)
      ENV_FILE="${1#--env-file=}"; shift ;;
    *)
      log_error "Unknown argument: $1" ;;
  esac
done

if [ ! -f "$ENV_FILE" ]; then
  if [ -f "${REPO_ROOT}/.env.example" ]; then
    cp "${REPO_ROOT}/.env.example" "$ENV_FILE"
    log_info "Created ${ENV_FILE} from .env.example"
  else
    log_error "Env file not found and .env.example missing: ${ENV_FILE}"
  fi
fi

random_string() {
  local length="${1:-48}"
  if command -v python3 >/dev/null 2>&1; then
    LENGTH="$length" python3 - <<'PY'
import os, secrets, string
alphabet = string.ascii_letters + string.digits
n = int(os.environ.get('LENGTH', '48'))
print(''.join(secrets.choice(alphabet) for _ in range(n)))
PY
    return
  fi
  if command -v openssl >/dev/null 2>&1; then
    local out
    out=$(openssl rand -base64 128 | tr -dc 'A-Za-z0-9' | head -c "$length")
    [ "${#out}" -ge "$length" ] || log_error "Failed to generate random string"
    printf '%s' "$out"
    return
  fi
  log_error "Need python3 or openssl to generate secrets"
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
  line=$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 || true)
  [ -n "$line" ] || { printf ''; return; }
  printf '%s' "${line#*=}"
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

set_if_empty() {
  local key="$1" value="$2"
  local cur
  cur=$(trim_quotes "$(get_env_value "$key")")
  if [ -z "$cur" ]; then
    set_env_value "$key" "$value"
    log_info "Set default ${key}."
  fi
}

set_secret_if_needed() {
  local key="$1" len="${2:-48}"
  local cur
  cur=$(trim_quotes "$(get_env_value "$key")")
  if [ "$FORCE" = true ] || [ -z "$cur" ] || [ "$cur" = "changeme" ] || [ "$cur" = "replace-me" ]; then
    set_env_value "$key" "$(random_string "$len")"
    log_info "Generated ${key}."
  fi
}

json_escape() {
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import json, sys
print(json.dumps(sys.stdin.read())[1:-1])
PY
    return
  fi
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

build_oidc_json() {
  local enabled provider_name provider_url client_id client_secret display_name web_root username_claim name_claim email_claim scopes_csv disable_pw
  enabled=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_ENABLED)")
  if [ "${enabled:-false}" != "true" ]; then
    printf ''
    return
  fi

  provider_name=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_PROVIDER_NAME)")
  provider_url=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_PROVIDER_URL)")
  client_id=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_CLIENT_ID)")
  client_secret=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_CLIENT_SECRET)")
  display_name=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_DISPLAY_NAME)")
  web_root=$(trim_quotes "$(get_env_value SEMAPHOREUI_WEB_ROOT)")
  username_claim=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_USERNAME_CLAIM)")
  name_claim=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_NAME_CLAIM)")
  email_claim=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_EMAIL_CLAIM)")
  scopes_csv=$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_SCOPES)")
  disable_pw=$(trim_quotes "$(get_env_value SEMAPHOREUI_PASSWORD_LOGIN_DISABLED)")

  [ -n "$provider_name" ] || provider_name="keycloak"
  [ -n "$display_name" ] || display_name="Keycloak"
  if [ -z "$web_root" ]; then
    web_root="https://semaphore.local.test"
  fi
  if [[ "$web_root" == *'${SEMAPHOREUI_HOSTNAME}'* ]]; then
    local semaphore_hostname
    semaphore_hostname=$(trim_quotes "$(get_env_value SEMAPHOREUI_HOSTNAME)")
    [ -n "$semaphore_hostname" ] || semaphore_hostname="semaphore"
    web_root="${web_root//'${SEMAPHOREUI_HOSTNAME}'/$semaphore_hostname}"
  fi
  if [[ "$web_root" == *'${DEV_DOMAIN}'* ]]; then
    local dev_domain
    dev_domain=$(trim_quotes "$(get_env_value DEV_DOMAIN)")
    [ -n "$dev_domain" ] || dev_domain="local.test"
    web_root="${web_root//'${DEV_DOMAIN}'/$dev_domain}"
  fi
  [ -n "$username_claim" ] || username_claim="preferred_username"
  [ -n "$name_claim" ] || name_claim="name"
  [ -n "$email_claim" ] || email_claim="email"
  [ -n "$scopes_csv" ] || scopes_csv="openid,profile,email"
  [ -n "$disable_pw" ] || disable_pw="false"

  if [ -z "$provider_url" ] || [ -z "$client_id" ] || [ -z "$client_secret" ]; then
    printf ''
    return
  fi

  OIDC_PROVIDER_NAME="$provider_name" \
  OIDC_PROVIDER_URL="$provider_url" \
  OIDC_CLIENT_ID="$client_id" \
  OIDC_CLIENT_SECRET="$client_secret" \
  OIDC_DISPLAY_NAME="$display_name" \
  OIDC_REDIRECT_URL="${web_root%/}/api/auth/oidc/${provider_name}/redirect" \
  OIDC_USERNAME_CLAIM="$username_claim" \
  OIDC_NAME_CLAIM="$name_claim" \
  OIDC_EMAIL_CLAIM="$email_claim" \
  OIDC_SCOPES_CSV="$scopes_csv" \
  python3 - <<'PY'
import json, os
name = os.environ['OIDC_PROVIDER_NAME']
scopes = [s.strip() for s in os.environ.get('OIDC_SCOPES_CSV','').split(',') if s.strip()]
provider = {
  "client_id": os.environ["OIDC_CLIENT_ID"],
  "client_secret": os.environ["OIDC_CLIENT_SECRET"],
  "provider_url": os.environ["OIDC_PROVIDER_URL"],
  "display_name": os.environ["OIDC_DISPLAY_NAME"],
  "redirect_url": os.environ["OIDC_REDIRECT_URL"],
  "username_claim": os.environ.get("OIDC_USERNAME_CLAIM", "preferred_username"),
  "name_claim": os.environ.get("OIDC_NAME_CLAIM", "name"),
  "email_claim": os.environ.get("OIDC_EMAIL_CLAIM", "email")
}
if scopes:
  provider["scopes"] = scopes
print(json.dumps({name: provider}, separators=(",",":")))
PY
}

# Defaults
set_if_empty "SEMAPHOREUI_IMAGE" "semaphoreui/semaphore:v2.17.14"
set_if_empty "SEMAPHOREUI_HOSTNAME" "semaphore"
set_if_empty "SEMAPHOREUI_WEB_ROOT" 'https://semaphore.${DEV_DOMAIN}'
set_if_empty "SEMAPHOREUI_DB_IMAGE" "postgres:16.8-alpine"
set_if_empty "SEMAPHOREUI_DB_NAME" "semaphore"
set_if_empty "SEMAPHOREUI_DB_USER" "semaphore"
set_if_empty "SEMAPHOREUI_ADMIN_LOGIN" "admin"
set_if_empty "SEMAPHOREUI_ADMIN_NAME" "Admin"
set_if_empty "SEMAPHOREUI_ADMIN_EMAIL" "admin@localhost"
set_if_empty "SEMAPHOREUI_LOG_LEVEL" "info"
set_if_empty "SEMAPHOREUI_OIDC_ENABLED" "false"
set_if_empty "SEMAPHOREUI_OIDC_PROVIDER_NAME" "keycloak"
set_if_empty "SEMAPHOREUI_OIDC_DISPLAY_NAME" "Keycloak"
set_if_empty "SEMAPHOREUI_OIDC_PROVIDER_URL" ""
set_if_empty "SEMAPHOREUI_OIDC_CLIENT_ID" ""
set_if_empty "SEMAPHOREUI_OIDC_CLIENT_SECRET" ""
set_if_empty "SEMAPHOREUI_OIDC_SCOPES" "openid,profile,email"
set_if_empty "SEMAPHOREUI_OIDC_USERNAME_CLAIM" "preferred_username"
set_if_empty "SEMAPHOREUI_OIDC_NAME_CLAIM" "name"
set_if_empty "SEMAPHOREUI_OIDC_EMAIL_CLAIM" "email"
set_if_empty "SEMAPHOREUI_PASSWORD_LOGIN_DISABLED" "false"
set_if_empty "SEMAPHOREUI_OBSERVABILITY_ENABLED" "false"
set_if_empty "SEMAPHOREUI_OBSERVABILITY_DISCOVERY" "labels"
set_if_empty "SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS" "false"

# Secrets
set_secret_if_needed "SEMAPHOREUI_ADMIN_PASSWORD" 32
set_secret_if_needed "SEMAPHOREUI_DB_PASSWORD" 32
set_secret_if_needed "SEMAPHOREUI_COOKIE_HASH" 64
set_secret_if_needed "SEMAPHOREUI_COOKIE_ENCRYPTION" 32
set_secret_if_needed "SEMAPHOREUI_ACCESS_KEY_ENCRYPTION" 32

OIDC_JSON=$(build_oidc_json || true)
if [ -n "$OIDC_JSON" ]; then
  set_env_value "SEMAPHOREUI_OIDC_PROVIDERS_JSON" "'$OIDC_JSON'"
  log_info "Generated SEMAPHOREUI_OIDC_PROVIDERS_JSON from OIDC settings."
else
  set_if_empty "SEMAPHOREUI_OIDC_PROVIDERS_JSON" "{}"
  if [ "$(trim_quotes "$(get_env_value SEMAPHOREUI_OIDC_ENABLED)")" = "true" ]; then
    log_warn "OIDC enabled but provider URL/client credentials incomplete; SEMAPHOREUI_OIDC_PROVIDERS_JSON left empty."
  fi
fi

log_success "Semaphore UI bootstrap complete (${ENV_FILE})."
