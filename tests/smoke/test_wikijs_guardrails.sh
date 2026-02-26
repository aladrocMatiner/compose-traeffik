#!/bin/bash
# Smoke test: Validate Wiki.js preflight guardrails in scripts/validate-env.sh.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

READY_FILE=$(mktemp)
STALE_FILE=$(mktemp)
CA_FILE=$(mktemp)
trap 'rm -f "$READY_FILE" "$STALE_FILE" "$CA_FILE"' EXIT

printf 'WIKIJS_RENDER_STATUS=ready\n' > "$READY_FILE"
printf 'WIKIJS_RENDER_STATUS=placeholder\n' > "$STALE_FILE"
printf 'dummy-ca\n' > "$CA_FILE"

log_info "Checking missing/stale Wiki.js rendered env is rejected..."
if COMPOSE_PROFILES=wikijs TRAEFIK_DASHBOARD=false WIKIJS_RENDERED_ENV_PATH=/no/such/file \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted missing Wiki.js rendered env."
fi
if COMPOSE_PROFILES=wikijs TRAEFIK_DASHBOARD=false WIKIJS_RENDERED_ENV_PATH="$STALE_FILE" \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted stale Wiki.js rendered env."
fi

log_info "Checking Keycloak invalid issuer is rejected when enabled..."
if COMPOSE_PROFILES=wikijs TRAEFIK_DASHBOARD=false WIKIJS_RENDERED_ENV_PATH="$READY_FILE" \
    WIKIJS_KEYCLOAK_ENABLE=true WIKIJS_KEYCLOAK_ISSUER_URL=http://keycloak.local \
    WIKIJS_KEYCLOAK_CLIENT_ID=wiki WIKIJS_KEYCLOAK_CLIENT_SECRET=secret \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted non-HTTPS Keycloak issuer URL."
fi

log_info "Checking step-ca trust source path validation..."
if COMPOSE_PROFILES=wikijs TRAEFIK_DASHBOARD=false WIKIJS_RENDERED_ENV_PATH="$READY_FILE" \
    WIKIJS_STEPCA_TRUST_ENABLE=true WIKIJS_STEPCA_TRUST_SOURCE_PATH=/no/such/ca.crt \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted missing step-ca trust source file."
fi

if ! COMPOSE_PROFILES=wikijs TRAEFIK_DASHBOARD=false WIKIJS_RENDERED_ENV_PATH="$READY_FILE" \
    WIKIJS_KEYCLOAK_ENABLE=true WIKIJS_KEYCLOAK_ISSUER_URL=https://keycloak.local/realms/dev \
    WIKIJS_KEYCLOAK_CLIENT_ID=wiki WIKIJS_KEYCLOAK_CLIENT_SECRET=secret \
    WIKIJS_OBSERVABILITY_ENABLE=true WIKIJS_OBSERVABILITY_MODE=telemetry \
    WIKIJS_STEPCA_TRUST_ENABLE=true WIKIJS_STEPCA_TRUST_SOURCE_PATH="$CA_FILE" \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid Wiki.js optional integration inputs."
fi

log_success "Wiki.js guardrails test passed."
