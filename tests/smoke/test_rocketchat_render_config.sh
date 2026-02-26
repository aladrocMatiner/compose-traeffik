#!/bin/bash
# Smoke test: Validate Rocket.Chat render/bootstrap output.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command mktemp
check_command grep
check_command bash

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
ENV_FILE="$TMP_DIR/test.env"
OUTPUT_FILE="$TMP_DIR/rocketchat.env"
GUIDE_FILE="$TMP_DIR/keycloak.md"

cat > "$ENV_FILE" <<ENV
DEV_DOMAIN=local.test
ROCKETCHAT_HOSTNAME=rocketchat
ROCKETCHAT_PORT=3000
ROCKETCHAT_METRICS_PORT=9458
ROCKETCHAT_MONGODB_REPLICA_SET_NAME=rs0
ROCKETCHAT_OBSERVABILITY_ENABLED=false
ROCKETCHAT_KEYCLOAK_ENABLED=false
ROCKETCHAT_KEYCLOAK_OAUTH_ID=keycloak
ROCKETCHAT_KEYCLOAK_DISPLAY_NAME=Keycloak
ENV

"$SCRIPT_DIR/../../scripts/rocketchat-bootstrap.sh" --env-file "$ENV_FILE" --output-file "$OUTPUT_FILE" --keycloak-output-file "$GUIDE_FILE" >/dev/null

for pattern in \
  'ROOT_URL=https://rocketchat.local.test' \
  'MONGO_URL=mongodb://rocketchat-mongodb:27017/rocketchat?replicaSet=rs0' \
  'MONGO_OPLOG_URL=mongodb://rocketchat-mongodb:27017/local?replicaSet=rs0' \
  'OVERWRITE_SETTING_Prometheus_Enabled=false' \
  'TRANSPORTER=monolith+nats://rocketchat-nats:4222'; do
  if ! grep -Fq "$pattern" "$OUTPUT_FILE"; then
    log_error "Rendered Rocket.Chat env missing pattern: $pattern"
  fi
done

if ! grep -Fq 'Enabled: false' "$GUIDE_FILE"; then
  log_error "Keycloak guide should reflect disabled state."
fi

cat > "$ENV_FILE" <<ENV
DEV_DOMAIN=local.test
ROCKETCHAT_HOSTNAME=chat
ROCKETCHAT_OBSERVABILITY_ENABLED=true
ROCKETCHAT_KEYCLOAK_ENABLED=true
ROCKETCHAT_KEYCLOAK_OAUTH_ID=keycloak
ROCKETCHAT_KEYCLOAK_DISPLAY_NAME=Keycloak
ROCKETCHAT_KEYCLOAK_ISSUER=https://keycloak.local/realms/dev
ROCKETCHAT_KEYCLOAK_CLIENT_ID=rocketchat
ROCKETCHAT_KEYCLOAK_CLIENT_SECRET=supersecret
ROCKETCHAT_KEYCLOAK_SCOPES="openid profile email"
ENV

"$SCRIPT_DIR/../../scripts/rocketchat-render-config.sh" --env-file "$ENV_FILE" --output-file "$OUTPUT_FILE" --keycloak-output-file "$GUIDE_FILE" >/dev/null

for pattern in \
  'ROOT_URL=https://chat.local.test' \
  'OVERWRITE_SETTING_Prometheus_Enabled=true'; do
  if ! grep -Fq "$pattern" "$OUTPUT_FILE"; then
    log_error "Rendered Rocket.Chat env missing enabled pattern: $pattern"
  fi
done

for pattern in \
  'Enabled: true' \
  'https://chat.local.test/_oauth/keycloak' \
  'https://keycloak.local/realms/dev/protocol/openid-connect/auth' \
  'https://keycloak.local/realms/dev/.well-known/openid-configuration'; do
  if ! grep -Fq "$pattern" "$GUIDE_FILE"; then
    log_error "Rendered Keycloak guide missing pattern: $pattern"
  fi
done

if grep -Fq 'supersecret' "$GUIDE_FILE"; then
  log_error "Rendered Keycloak guide should not leak client secret."
fi

log_success "Rocket.Chat render config test passed."
