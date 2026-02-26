#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
READY_FILE=$(mktemp)
STALE_FILE=$(mktemp)
CA_FILE=$(mktemp)
trap 'rm -f "$READY_FILE" "$STALE_FILE" "$CA_FILE"' EXIT
printf 'N8N_RENDER_STATUS=ready\n' > "$READY_FILE"
printf 'N8N_RENDER_STATUS=placeholder\n' > "$STALE_FILE"
printf 'ca\n' > "$CA_FILE"
if COMPOSE_PROFILES=n8n TRAEFIK_DASHBOARD=false N8N_RENDERED_ENV_PATH=/nope "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted missing n8n rendered env."
fi
if COMPOSE_PROFILES=n8n TRAEFIK_DASHBOARD=false N8N_RENDERED_ENV_PATH="$STALE_FILE" "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted stale n8n rendered env."
fi
if COMPOSE_PROFILES=n8n TRAEFIK_DASHBOARD=false N8N_RENDERED_ENV_PATH="$READY_FILE" N8N_KEYCLOAK_ENABLE=true N8N_KEYCLOAK_DISCOVERY_URL=http://kc.local/.well-known/openid-configuration N8N_KEYCLOAK_CLIENT_ID=n8n N8N_KEYCLOAK_CLIENT_SECRET=s "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted non-HTTPS Keycloak discovery URL."
fi
if COMPOSE_PROFILES=n8n TRAEFIK_DASHBOARD=false N8N_RENDERED_ENV_PATH="$READY_FILE" N8N_STEPCA_TRUST_ENABLE=true N8N_STEPCA_TRUST_SOURCE_PATH=/no/ca.crt "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted missing step-ca trust source file."
fi
if ! COMPOSE_PROFILES=n8n TRAEFIK_DASHBOARD=false N8N_RENDERED_ENV_PATH="$READY_FILE" N8N_KEYCLOAK_ENABLE=true N8N_KEYCLOAK_DISCOVERY_URL=https://kc.local/realms/dev/.well-known/openid-configuration N8N_KEYCLOAK_CLIENT_ID=n8n N8N_KEYCLOAK_CLIENT_SECRET=s N8N_OBSERVABILITY_ENABLE=true N8N_OBSERVABILITY_MODE=metrics N8N_STEPCA_TRUST_ENABLE=true N8N_STEPCA_TRUST_SOURCE_PATH="$CA_FILE" "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env rejected valid n8n optional integration inputs."
fi
log_success "n8n guardrails test passed."
