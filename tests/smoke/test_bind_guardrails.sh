#!/bin/bash
# File: tests/smoke/test_bind_guardrails.sh
#
# Smoke test: Validate DNS bind-address guardrails in preflight checks.
#
# Usage: ./tests/smoke/test_bind_guardrails.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command "bash"

log_info "Checking non-local BIND_BIND_ADDRESS is rejected by default..."
if COMPOSE_PROFILES=bind TRAEFIK_DASHBOARD=false BIND_BIND_ADDRESS=0.0.0.0 BIND_ALLOW_NONLOCAL_BIND=false \
    "${SCRIPT_DIR}/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted non-local BIND bind address without explicit override."
fi

log_info "Checking explicit override allows non-local BIND_BIND_ADDRESS..."
if ! COMPOSE_PROFILES=bind TRAEFIK_DASHBOARD=false BIND_BIND_ADDRESS=0.0.0.0 BIND_ALLOW_NONLOCAL_BIND=true \
    "${SCRIPT_DIR}/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected non-local BIND bind address with explicit override."
fi

log_success "BIND guardrails test passed."
