#!/bin/bash
# Smoke test: Validate Plane preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

log_info "Checking Plane guardrails reject missing core secrets..."
if COMPOSE_PROFILES=plane TRAEFIK_DASHBOARD=false PLANE_HOSTNAME=plane \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted plane profile with missing secrets."
fi

log_info "Checking Plane guardrails reject invalid hostname label..."
if COMPOSE_PROFILES=plane TRAEFIK_DASHBOARD=false \
    PLANE_SECRET_KEY=a PLANE_LIVE_SERVER_SECRET_KEY=b PLANE_POSTGRES_PASSWORD=c PLANE_RABBITMQ_PASSWORD=d PLANE_AWS_SECRET_ACCESS_KEY=e \
    PLANE_HOSTNAME='Bad.Host' \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid PLANE_HOSTNAME."
fi

log_info "Checking Plane guardrails pass with valid Plane-only values..."
if ! COMPOSE_PROFILES=plane TRAEFIK_DASHBOARD=false \
    PLANE_SECRET_KEY=a123 PLANE_LIVE_SERVER_SECRET_KEY=b123 PLANE_POSTGRES_PASSWORD=c123 PLANE_RABBITMQ_PASSWORD=d123 PLANE_AWS_SECRET_ACCESS_KEY=e123 \
    PLANE_HOSTNAME=plane PLANE_OIDC_ENABLED=false PLANE_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid Plane-only settings."
fi

log_success "Plane guardrails test passed."
