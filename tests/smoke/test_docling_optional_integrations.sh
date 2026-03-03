#!/bin/bash
# Smoke test: Validate Docling optional integration contract behavior.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/docling/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Docling compose fragment not found."

grep -Fq 'DOCLING_KEYCLOAK_ENABLED=${DOCLING_KEYCLOAK_ENABLED:-false}' "$COMPOSE_FILE" || log_error "Docling compose must expose Keycloak toggle env."
grep -Fq 'DOCLING_OBSERVABILITY_ENABLED=${DOCLING_OBSERVABILITY_ENABLED:-false}' "$COMPOSE_FILE" || log_error "Docling compose must expose observability toggle env."

log_info "Checking Keycloak disabled mode does not require Keycloak values..."
if ! COMPOSE_PROFILES=docling TRAEFIK_DASHBOARD=false \
    DOCLING_AUTH_MODE=api-key DOCLING_API_KEY=abc123 DOCLING_REDIS_PASSWORD=redispass DOCLING_HOSTNAME=docling \
    DOCLING_KEYCLOAK_ENABLED=false DOCLING_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected Docling with optional integrations disabled."
fi

log_info "Checking Keycloak enabled mode requires full contract..."
if COMPOSE_PROFILES=docling TRAEFIK_DASHBOARD=false \
    DOCLING_AUTH_MODE=keycloak DOCLING_REDIS_PASSWORD=redispass DOCLING_HOSTNAME=docling \
    DOCLING_KEYCLOAK_ENABLED=true DOCLING_KEYCLOAK_MODE=external DOCLING_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted Keycloak enabled with incomplete contract."
fi

log_info "Checking Keycloak external mode passes with complete values..."
if ! COMPOSE_PROFILES=docling TRAEFIK_DASHBOARD=false \
    DOCLING_AUTH_MODE=keycloak DOCLING_REDIS_PASSWORD=redispass DOCLING_HOSTNAME=docling \
    DOCLING_KEYCLOAK_ENABLED=true DOCLING_KEYCLOAK_MODE=external \
    DOCLING_TRAEFIK_MIDDLEWARES=keycloak-forward-auth@file,security-headers@file \
    DOCLING_KEYCLOAK_EXTERNAL_URL=https://keycloak.example.test \
    DOCLING_KEYCLOAK_ISSUER=https://keycloak.example.test/realms/docling \
    DOCLING_KEYCLOAK_CLIENT_ID=docling-client DOCLING_KEYCLOAK_CLIENT_SECRET=super-secret \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid Keycloak external contract."
fi

log_success "Docling optional integrations test passed."
