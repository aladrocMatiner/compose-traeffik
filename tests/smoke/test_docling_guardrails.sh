#!/bin/bash
# Smoke test: Validate Docling preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

log_info "Checking Docling guardrails reject missing core settings..."
if COMPOSE_PROFILES=docling TRAEFIK_DASHBOARD=false DOCLING_HOSTNAME=docling \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted docling profile with missing required values."
fi

log_info "Checking Docling guardrails reject invalid hostname label..."
if COMPOSE_PROFILES=docling TRAEFIK_DASHBOARD=false \
    DOCLING_AUTH_MODE=open DOCLING_REDIS_PASSWORD=redispass DOCLING_HOSTNAME='Bad.Host' \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid DOCLING_HOSTNAME."
fi

log_info "Checking Docling guardrails pass with valid Docling-only values..."
if ! COMPOSE_PROFILES=docling TRAEFIK_DASHBOARD=false \
    DOCLING_AUTH_MODE=api-key DOCLING_API_KEY=abc123 DOCLING_REDIS_PASSWORD=redispass DOCLING_HOSTNAME=docling \
    DOCLING_KEYCLOAK_ENABLED=false DOCLING_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid Docling settings."
fi

log_success "Docling guardrails test passed."
