#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
TMP_DIR=$(mktemp -d)
TMP_ENV=$(mktemp)
TMP_CA=$(mktemp)
trap 'rm -rf "$TMP_DIR"; rm -f "$TMP_ENV" "$TMP_CA"' EXIT
printf 'ca\n' > "$TMP_CA"
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
RENDER_DIR="$REPO_ROOT/services/n8n/rendered"
mkdir -p "$RENDER_DIR"
(
  cd "$TMP_DIR"
  DEV_DOMAIN=local.test \
  N8N_DB_PASSWORD=dbpass \
  N8N_ENCRYPTION_KEY=encryptionkey123 \
  N8N_OWNER_BOOTSTRAP_PASSWORD=ownerpass \
  N8N_KEYCLOAK_ENABLE=true \
  N8N_KEYCLOAK_DISCOVERY_URL=https://kc.local/realms/dev/.well-known/openid-configuration \
  N8N_KEYCLOAK_CLIENT_ID=n8n \
  N8N_KEYCLOAK_CLIENT_SECRET=secret \
  N8N_OBSERVABILITY_ENABLE=true \
  N8N_OBSERVABILITY_MODE=metrics \
  N8N_STEPCA_TRUST_ENABLE=true \
  N8N_STEPCA_TRUST_SOURCE_PATH="$TMP_CA" \
  N8N_RENDERED_ENV_PATH="$TMP_ENV" \
  "$REPO_ROOT/scripts/n8n-render-config.sh" >/dev/null
)
grep -q '^N8N_RENDER_STATUS=ready$' "$TMP_ENV" || log_error "Rendered n8n env missing ready marker."
grep -q '^DB_TYPE=postgresdb$' "$TMP_ENV" || log_error "Rendered n8n env missing DB_TYPE=postgresdb."
grep -q '^N8N_METRICS=true$' "$TMP_ENV" || log_error "Rendered n8n env missing N8N_METRICS=true for metrics mode."
grep -q '^NODE_EXTRA_CA_CERTS=/home/node/.n8n/certs/stepca-root-ca.crt$' "$TMP_ENV" || log_error "Rendered n8n env missing NODE_EXTRA_CA_CERTS setting."
[ -f "$RENDER_DIR/keycloak-oidc-checklist.md" ] || log_error "Keycloak OIDC checklist was not rendered."
[ -f "$RENDER_DIR/observability.md" ] || log_error "Observability notes were not rendered."
[ -s "$RENDER_DIR/stepca-root-ca.crt" ] || log_error "stepca-root-ca.crt was not rendered/copied."
grep -q 'Client secret: \[configured in \.env; not printed\]' "$RENDER_DIR/keycloak-oidc-checklist.md" || log_error "Keycloak checklist should not print the client secret."
log_success "n8n render config test passed."
