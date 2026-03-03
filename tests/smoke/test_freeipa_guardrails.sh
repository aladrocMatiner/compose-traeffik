#!/bin/bash
# Smoke test: Validate FreeIPA preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

log_info "Checking FreeIPA guardrails reject missing core secrets..."
if COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted freeipa profile with missing secrets."
fi

log_info "Checking FreeIPA guardrails reject invalid hostname label..."
if COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME='Bad.Host' FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid FREEIPA_HOSTNAME."
fi

log_info "Checking FreeIPA guardrails pass with valid FreeIPA-only values..."
if ! COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid FreeIPA settings."
fi

log_success "FreeIPA guardrails test passed."
