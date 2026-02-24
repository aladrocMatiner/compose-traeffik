#!/bin/bash
# Smoke test: Verify app-specific observability assets do not create a hard CTFd dependency.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

ALLOY_CFG="$SCRIPT_DIR/../../services/observability/alloy/config.alloy"
GUARDRAIL="$SCRIPT_DIR/../../scripts/validate-env.sh"

[ -f "$ALLOY_CFG" ] || log_error "Alloy config missing."

# App-specific targeting should use discovery/filtering rather than static hardcoded endpoints.
grep -Fq 'discovery.docker "containers"' "$ALLOY_CFG"
grep -Fq 'regex         = "/(traefik|ctfd.*)"' "$ALLOY_CFG"
if grep -Fq 'ctfd:8000' "$ALLOY_CFG"; then
    log_error "Alloy config should not hardcode CTFd network endpoints for log collection."
fi

# Guardrails support observability-only mode (warn, not fail).
if ! COMPOSE_PROFILES=observability TRAEFIK_DASHBOARD=false GRAFANA_HOSTNAME=grafana GRAFANA_ADMIN_PASSWORD=secret123 \
    "$GUARDRAIL" >/dev/null 2>&1; then
    log_error "observability-only mode should pass preflight validation."
fi

log_success "Observability app-pack tolerance test passed."
