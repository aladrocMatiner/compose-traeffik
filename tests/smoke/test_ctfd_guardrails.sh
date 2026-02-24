#!/bin/bash
# Smoke test: Validate CTFd preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

log_info "Checking CTFd guardrails reject missing secrets..."
if COMPOSE_PROFILES=ctfd TRAEFIK_DASHBOARD=false CTFD_HOSTNAME=ctfd \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted ctfd profile with missing secrets."
fi

log_info "Checking CTFd guardrails reject invalid hostname label..."
if COMPOSE_PROFILES=ctfd TRAEFIK_DASHBOARD=false \
    CTFD_SECRET_KEY=x CTFD_DB_PASSWORD=y CTFD_DB_ROOT_PASSWORD=z CTFD_HOSTNAME='Bad.Host' \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid CTFD_HOSTNAME."
fi

log_info "Checking CTFd guardrails pass with valid values..."
if ! COMPOSE_PROFILES=ctfd TRAEFIK_DASHBOARD=false \
    CTFD_SECRET_KEY=abc123 CTFD_DB_PASSWORD=def456 CTFD_DB_ROOT_PASSWORD=ghi789 CTFD_HOSTNAME=ctfd \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid CTFd settings."
fi

log_success "CTFd guardrails test passed."
