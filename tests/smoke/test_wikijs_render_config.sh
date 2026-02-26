#!/bin/bash
# Smoke test: Validate Wiki.js render script output and optional runbooks.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

TMP_DIR=$(mktemp -d)
TMP_ENV=$(mktemp)
TMP_CA=$(mktemp)
trap 'rm -rf "$TMP_DIR"; rm -f "$TMP_ENV" "$TMP_CA"' EXIT
printf 'dummy-ca\n' > "$TMP_CA"

REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
RENDER_DIR="$REPO_ROOT/services/wikijs/rendered"
mkdir -p "$RENDER_DIR"

(
    cd "$TMP_DIR"
    DEV_DOMAIN=local.test \
    WIKIJS_HOSTNAME=wiki \
    WIKIJS_PORT=3000 \
    WIKIJS_DB_NAME=wiki \
    WIKIJS_DB_USER=wikijs \
    WIKIJS_DB_PASSWORD=testpass \
    WIKIJS_DB_SSL=false \
    WIKIJS_HA_ACTIVE=false \
    WIKIJS_LOG_LEVEL=info \
    WIKIJS_KEYCLOAK_ENABLE=true \
    WIKIJS_KEYCLOAK_ISSUER_URL=https://keycloak.local/realms/dev \
    WIKIJS_KEYCLOAK_CLIENT_ID=wiki \
    WIKIJS_KEYCLOAK_CLIENT_SECRET=supersecret \
    WIKIJS_OBSERVABILITY_ENABLE=true \
    WIKIJS_OBSERVABILITY_MODE=telemetry \
    WIKIJS_STEPCA_TRUST_ENABLE=true \
    WIKIJS_STEPCA_TRUST_SOURCE_PATH="$TMP_CA" \
    WIKIJS_RENDERED_ENV_PATH="$TMP_ENV" \
    "$REPO_ROOT/scripts/wikijs-render-config.sh" >/dev/null
)

grep -q '^WIKIJS_RENDER_STATUS=ready$' "$TMP_ENV" || log_error "Rendered Wiki.js env missing ready marker."
grep -q '^DB_TYPE=postgres$' "$TMP_ENV" || log_error "Rendered Wiki.js env missing DB_TYPE=postgres."
grep -q '^NODE_EXTRA_CA_CERTS=/wiki/certs/stepca-root-ca.crt$' "$TMP_ENV" || log_error "Rendered Wiki.js env missing NODE_EXTRA_CA_CERTS setting."
[ -f "$RENDER_DIR/keycloak-checklist.md" ] || log_error "Keycloak checklist was not rendered."
[ -f "$RENDER_DIR/observability.md" ] || log_error "Observability notes were not rendered."
[ -s "$RENDER_DIR/stepca-root-ca.crt" ] || log_error "stepca-root-ca.crt was not rendered/copied."

grep -q 'Client secret: \[configured in \.env; not printed\]' "$RENDER_DIR/keycloak-checklist.md" || log_error "Keycloak checklist should not print the client secret."

log_success "Wiki.js render config test passed."
