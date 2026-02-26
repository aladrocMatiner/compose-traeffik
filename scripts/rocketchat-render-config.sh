#!/bin/bash
# Render Rocket.Chat runtime env and optional Keycloak setup checklist from .env.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

ENV_FILE="${REPO_ROOT}/.env"
OUTPUT_FILE="${REPO_ROOT}/services/rocketchat/rendered/rocketchat.env"
KEYCLOAK_GUIDE_FILE="${REPO_ROOT}/services/rocketchat/rendered/keycloak-custom-oauth.md"
OUTPUT_FILE_EXPLICIT=false
KEYCLOAK_GUIDE_FILE_EXPLICIT=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --output-file)
      OUTPUT_FILE="$2"
      OUTPUT_FILE_EXPLICIT=true
      shift 2
      ;;
    --keycloak-output-file)
      KEYCLOAK_GUIDE_FILE="$2"
      KEYCLOAK_GUIDE_FILE_EXPLICIT=true
      shift 2
      ;;
    *)
      log_error "Unknown argument: $1"
      ;;
  esac
done

if [[ "$ENV_FILE" != /* ]]; then
  ENV_FILE="${REPO_ROOT}/${ENV_FILE}"
fi

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
else
  log_error "Environment file not found: ${ENV_FILE}"
fi

if [ "$OUTPUT_FILE_EXPLICIT" != true ] && [ -n "${ROCKETCHAT_RENDERED_ENV_PATH:-}" ]; then
  OUTPUT_FILE="${ROCKETCHAT_RENDERED_ENV_PATH}"
fi
if [ "$KEYCLOAK_GUIDE_FILE_EXPLICIT" != true ] && [ -n "${ROCKETCHAT_KEYCLOAK_GUIDE_PATH:-}" ]; then
  KEYCLOAK_GUIDE_FILE="${ROCKETCHAT_KEYCLOAK_GUIDE_PATH}"
fi

if [[ "$OUTPUT_FILE" != /* ]]; then
  OUTPUT_FILE="${REPO_ROOT}/${OUTPUT_FILE}"
fi
if [[ "$KEYCLOAK_GUIDE_FILE" != /* ]]; then
  KEYCLOAK_GUIDE_FILE="${REPO_ROOT}/${KEYCLOAK_GUIDE_FILE}"
fi

trim_trailing_slash() {
  local v="$1"
  while [[ "$v" == */ ]]; do
    v="${v%/}"
  done
  printf '%s' "$v"
}

validate_bool() {
  local value="$1"
  local name="$2"
  case "$value" in
    true|false) ;;
    *) log_error "${name} must be 'true' or 'false' (got: ${value})" ;;
  esac
}

validate_port() {
  local value="$1"
  local name="$2"
  if [[ ! "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
    log_error "${name} must be an integer between 1 and 65535 (got: ${value})"
  fi
}

validate_dns_label() {
  local value="$1"
  local name="$2"
  if [[ ! "$value" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
    log_error "${name} must be a lowercase DNS label (got: ${value})"
  fi
}

require_non_empty() {
  local value="$1"
  local name="$2"
  if [ -z "$value" ]; then
    log_error "${name} is required"
  fi
}

require_https_url() {
  local value="$1"
  local name="$2"
  if [[ ! "$value" =~ ^https:// ]]; then
    log_error "${name} must use https:// (got: ${value})"
  fi
}

DEV_DOMAIN_VALUE="${DEV_DOMAIN:-}"
ROCKETCHAT_HOSTNAME_VALUE="${ROCKETCHAT_HOSTNAME:-rocketchat}"
ROCKETCHAT_PORT_VALUE="${ROCKETCHAT_PORT:-3000}"
ROCKETCHAT_METRICS_PORT_VALUE="${ROCKETCHAT_METRICS_PORT:-9458}"
ROCKETCHAT_MONGODB_REPLICA_SET_NAME_VALUE="${ROCKETCHAT_MONGODB_REPLICA_SET_NAME:-rs0}"
ROCKETCHAT_REG_TOKEN_VALUE="${ROCKETCHAT_REG_TOKEN:-}"
ROCKETCHAT_OBSERVABILITY_ENABLED_VALUE="${ROCKETCHAT_OBSERVABILITY_ENABLED:-false}"
ROCKETCHAT_KEYCLOAK_ENABLED_VALUE="${ROCKETCHAT_KEYCLOAK_ENABLED:-false}"
ROCKETCHAT_KEYCLOAK_OAUTH_ID_VALUE="${ROCKETCHAT_KEYCLOAK_OAUTH_ID:-keycloak}"
ROCKETCHAT_KEYCLOAK_DISPLAY_NAME_VALUE="${ROCKETCHAT_KEYCLOAK_DISPLAY_NAME:-Keycloak}"
ROCKETCHAT_KEYCLOAK_ISSUER_VALUE="${ROCKETCHAT_KEYCLOAK_ISSUER:-}"
ROCKETCHAT_KEYCLOAK_CLIENT_ID_VALUE="${ROCKETCHAT_KEYCLOAK_CLIENT_ID:-}"
ROCKETCHAT_KEYCLOAK_CLIENT_SECRET_VALUE="${ROCKETCHAT_KEYCLOAK_CLIENT_SECRET:-}"
ROCKETCHAT_KEYCLOAK_SCOPES_VALUE="${ROCKETCHAT_KEYCLOAK_SCOPES:-openid profile email}"

require_non_empty "$DEV_DOMAIN_VALUE" "DEV_DOMAIN"
validate_dns_label "$ROCKETCHAT_HOSTNAME_VALUE" "ROCKETCHAT_HOSTNAME"
validate_port "$ROCKETCHAT_PORT_VALUE" "ROCKETCHAT_PORT"
validate_port "$ROCKETCHAT_METRICS_PORT_VALUE" "ROCKETCHAT_METRICS_PORT"
validate_bool "$ROCKETCHAT_OBSERVABILITY_ENABLED_VALUE" "ROCKETCHAT_OBSERVABILITY_ENABLED"
validate_bool "$ROCKETCHAT_KEYCLOAK_ENABLED_VALUE" "ROCKETCHAT_KEYCLOAK_ENABLED"
validate_dns_label "$ROCKETCHAT_KEYCLOAK_OAUTH_ID_VALUE" "ROCKETCHAT_KEYCLOAK_OAUTH_ID"

ROOT_URL_VALUE="https://${ROCKETCHAT_HOSTNAME_VALUE}.${DEV_DOMAIN_VALUE}"
MONGO_URL_VALUE="mongodb://rocketchat-mongodb:27017/rocketchat?replicaSet=${ROCKETCHAT_MONGODB_REPLICA_SET_NAME_VALUE}"
MONGO_OPLOG_URL_VALUE="mongodb://rocketchat-mongodb:27017/local?replicaSet=${ROCKETCHAT_MONGODB_REPLICA_SET_NAME_VALUE}"
TRANSPORTER_VALUE="monolith+nats://rocketchat-nats:4222"
PROM_ENABLED_VALUE="$ROCKETCHAT_OBSERVABILITY_ENABLED_VALUE"

mkdir -p "$(dirname "$OUTPUT_FILE")"
mkdir -p "$(dirname "$KEYCLOAK_GUIDE_FILE")"

if [ "$ROCKETCHAT_KEYCLOAK_ENABLED_VALUE" = "true" ]; then
  require_non_empty "$ROCKETCHAT_KEYCLOAK_ISSUER_VALUE" "ROCKETCHAT_KEYCLOAK_ISSUER"
  require_non_empty "$ROCKETCHAT_KEYCLOAK_CLIENT_ID_VALUE" "ROCKETCHAT_KEYCLOAK_CLIENT_ID"
  require_non_empty "$ROCKETCHAT_KEYCLOAK_CLIENT_SECRET_VALUE" "ROCKETCHAT_KEYCLOAK_CLIENT_SECRET"
  require_https_url "$ROCKETCHAT_KEYCLOAK_ISSUER_VALUE" "ROCKETCHAT_KEYCLOAK_ISSUER"
fi

cat > "$OUTPUT_FILE" <<ENVOUT
# Rendered by scripts/rocketchat-render-config.sh. Do not edit manually.
ROOT_URL=${ROOT_URL_VALUE}
PORT=${ROCKETCHAT_PORT_VALUE}
DEPLOY_METHOD=docker
DEPLOY_PLATFORM=compose-traeffik
REG_TOKEN=${ROCKETCHAT_REG_TOKEN_VALUE}
MONGO_URL=${MONGO_URL_VALUE}
MONGO_OPLOG_URL=${MONGO_OPLOG_URL_VALUE}
TRANSPORTER=${TRANSPORTER_VALUE}
INSTANCE_IP=
OVERWRITE_SETTING_Site_Url=${ROOT_URL_VALUE}
OVERWRITE_SETTING_Prometheus_Enabled=${PROM_ENABLED_VALUE}
OVERWRITE_SETTING_Prometheus_Port=${ROCKETCHAT_METRICS_PORT_VALUE}
ENVOUT

KEYCLOAK_ISSUER_TRIMMED=$(trim_trailing_slash "$ROCKETCHAT_KEYCLOAK_ISSUER_VALUE")
KEYCLOAK_CALLBACK_URL="${ROOT_URL_VALUE}/_oauth/${ROCKETCHAT_KEYCLOAK_OAUTH_ID_VALUE}"
KEYCLOAK_AUTH_URL=""
KEYCLOAK_TOKEN_URL=""
KEYCLOAK_USERINFO_URL=""
KEYCLOAK_WELLKNOWN_URL=""
if [ -n "$KEYCLOAK_ISSUER_TRIMMED" ]; then
  KEYCLOAK_AUTH_URL="${KEYCLOAK_ISSUER_TRIMMED}/protocol/openid-connect/auth"
  KEYCLOAK_TOKEN_URL="${KEYCLOAK_ISSUER_TRIMMED}/protocol/openid-connect/token"
  KEYCLOAK_USERINFO_URL="${KEYCLOAK_ISSUER_TRIMMED}/protocol/openid-connect/userinfo"
  KEYCLOAK_WELLKNOWN_URL="${KEYCLOAK_ISSUER_TRIMMED}/.well-known/openid-configuration"
fi

cat > "$KEYCLOAK_GUIDE_FILE" <<GUIDE
# Rocket.Chat Keycloak Custom OAuth Checklist

Generated from: ${ENV_FILE}
Service URL: ${ROOT_URL_VALUE}
Enabled: ${ROCKETCHAT_KEYCLOAK_ENABLED_VALUE}

## Callback URL (Custom OAuth Unique ID = ${ROCKETCHAT_KEYCLOAK_OAUTH_ID_VALUE})

${KEYCLOAK_CALLBACK_URL}

## Suggested Rocket.Chat Custom OAuth fields (manual UI setup)

- Provider display name: ${ROCKETCHAT_KEYCLOAK_DISPLAY_NAME_VALUE}
- Custom OAuth Unique ID: ${ROCKETCHAT_KEYCLOAK_OAUTH_ID_VALUE}
- Enabled: ${ROCKETCHAT_KEYCLOAK_ENABLED_VALUE}
- Scope: ${ROCKETCHAT_KEYCLOAK_SCOPES_VALUE}
- Issuer (reference): ${ROCKETCHAT_KEYCLOAK_ISSUER_VALUE}
- Well-known (reference): ${KEYCLOAK_WELLKNOWN_URL}
- Authorize URL: ${KEYCLOAK_AUTH_URL}
- Token URL: ${KEYCLOAK_TOKEN_URL}
- Userinfo URL: ${KEYCLOAK_USERINFO_URL}
- Client ID: ${ROCKETCHAT_KEYCLOAK_CLIENT_ID_VALUE}
- Client Secret: (use ROCKETCHAT_KEYCLOAK_CLIENT_SECRET from .env; not rendered here)

## Notes

- Rocket.Chat custom OAuth/Keycloak setup is intentionally documented as a manual UI step in this repo.
- This file is a generated checklist to keep callback URLs and endpoint paths reproducible.
- If Keycloak is disabled, the callback URL is still rendered for planning and documentation.
GUIDE

log_success "Rendered Rocket.Chat env: ${OUTPUT_FILE}"
log_success "Rendered Keycloak checklist: ${KEYCLOAK_GUIDE_FILE}"
