#!/bin/bash
# Smoke test: Validate Plane optional integration contract behavior.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/plane/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Plane compose fragment not found."

grep -Fq 'PLANE_OIDC_ENABLED=${PLANE_OIDC_ENABLED:-false}' "$COMPOSE_FILE" || log_error "Plane compose must expose OIDC toggle env."
grep -Fq 'PLANE_KEYCLOAK_MODE=${PLANE_KEYCLOAK_MODE:-external}' "$COMPOSE_FILE" || log_error "Plane compose must expose Keycloak mode env."
grep -Fq 'PLANE_OBSERVABILITY_ENABLED=${PLANE_OBSERVABILITY_ENABLED:-false}' "$COMPOSE_FILE" || log_error "Plane compose must expose observability toggle env."

log_info "Checking OIDC disabled mode does not require Keycloak/OIDC values..."
if ! COMPOSE_PROFILES=plane TRAEFIK_DASHBOARD=false \
    PLANE_SECRET_KEY=a123 PLANE_LIVE_SERVER_SECRET_KEY=b123 PLANE_POSTGRES_PASSWORD=c123 PLANE_RABBITMQ_PASSWORD=d123 PLANE_AWS_SECRET_ACCESS_KEY=e123 \
    PLANE_HOSTNAME=plane PLANE_OIDC_ENABLED=false PLANE_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected Plane with optional integrations disabled."
fi

log_info "Checking OIDC enabled mode requires full contract..."
if COMPOSE_PROFILES=plane TRAEFIK_DASHBOARD=false \
    PLANE_SECRET_KEY=a123 PLANE_LIVE_SERVER_SECRET_KEY=b123 PLANE_POSTGRES_PASSWORD=c123 PLANE_RABBITMQ_PASSWORD=d123 PLANE_AWS_SECRET_ACCESS_KEY=e123 \
    PLANE_HOSTNAME=plane PLANE_OIDC_ENABLED=true PLANE_KEYCLOAK_MODE=external PLANE_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted OIDC enabled with incomplete contract."
fi

log_info "Checking OIDC external mode passes with complete values..."
if ! COMPOSE_PROFILES=plane TRAEFIK_DASHBOARD=false \
    PLANE_SECRET_KEY=a123 PLANE_LIVE_SERVER_SECRET_KEY=b123 PLANE_POSTGRES_PASSWORD=c123 PLANE_RABBITMQ_PASSWORD=d123 PLANE_AWS_SECRET_ACCESS_KEY=e123 \
    PLANE_HOSTNAME=plane PLANE_OIDC_ENABLED=true PLANE_KEYCLOAK_MODE=external \
    PLANE_KEYCLOAK_EXTERNAL_URL=https://keycloak.example.test \
    PLANE_OIDC_ISSUER=https://keycloak.example.test/realms/plane \
    PLANE_OIDC_CLIENT_ID=plane-client PLANE_OIDC_CLIENT_SECRET=super-secret \
    PLANE_OIDC_REDIRECT_URI=https://plane.local.test/auth/callback \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid OIDC external contract."
fi

log_success "Plane optional integrations test passed."
