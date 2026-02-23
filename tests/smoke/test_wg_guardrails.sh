#!/bin/bash
# File: tests/smoke/test_wg_guardrails.sh
#
# Smoke test: Validate WireGuard guardrails in preflight checks.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

VALIDATE_SCRIPT="$SCRIPT_DIR/../../scripts/validate-env.sh"

check_command "bash"

base_env=(COMPOSE_PROFILES=wg TRAEFIK_DASHBOARD=false WG_UI_HOSTNAME=wg WG_SERVER_ENDPOINT=wg.local.test WG_BIND_ADDRESS=127.0.0.1 WG_ALLOW_NONLOCAL_BIND=false WG_SERVER_PORT=51820 WG_INSECURE=false)

log_info "Checking invalid WG_SERVER_PORT is rejected..."
if env "${base_env[@]}" WG_SERVER_PORT=not-a-port "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid WG_SERVER_PORT."
fi

log_info "Checking non-local WG_BIND_ADDRESS is rejected by default..."
if env "${base_env[@]}" WG_BIND_ADDRESS=0.0.0.0 WG_ALLOW_NONLOCAL_BIND=false "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env accepted non-local WG_BIND_ADDRESS without explicit override."
fi

log_info "Checking explicit override allows non-local WG_BIND_ADDRESS..."
if ! env "${base_env[@]}" WG_BIND_ADDRESS=0.0.0.0 WG_ALLOW_NONLOCAL_BIND=true "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env rejected non-local WG_BIND_ADDRESS with explicit override."
fi

log_info "Checking invalid WG_UI_HOSTNAME is rejected..."
if env "${base_env[@]}" WG_UI_HOSTNAME='Bad Host' "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid WG_UI_HOSTNAME."
fi

log_info "Checking invalid WG_SERVER_ENDPOINT is rejected..."
if env "${base_env[@]}" WG_SERVER_ENDPOINT='wg.local.test:51820' "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid WG_SERVER_ENDPOINT host with port."
fi

log_info "Checking WG_INSECURE=true is rejected..."
if env "${base_env[@]}" WG_INSECURE=true "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env accepted WG_INSECURE=true."
fi

log_info "Checking valid WireGuard guardrail config passes..."
if ! env "${base_env[@]}" WG_BIND_ADDRESS=127.0.0.1 WG_ALLOW_NONLOCAL_BIND=false "$VALIDATE_SCRIPT" >/dev/null 2>&1; then
    log_error "validate-env rejected a valid WireGuard configuration."
fi

log_success "WireGuard guardrails test passed."
