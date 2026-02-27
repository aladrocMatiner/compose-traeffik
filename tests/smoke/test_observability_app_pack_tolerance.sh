#!/bin/bash
# Smoke test: Verify observability assets stay generic and avoid app-specific coupling.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

ALLOY_CFG="$SCRIPT_DIR/../../services/observability/alloy/config.alloy"
GUARDRAIL="$SCRIPT_DIR/../../scripts/validate-env.sh"

[ -f "$ALLOY_CFG" ] || log_error "Alloy config missing."

# Targeting should remain generic (no app-specific coupling in core observability).
grep -Fq 'discovery.docker "containers"' "$ALLOY_CFG"
grep -Fq 'regex         = "/(traefik)"' "$ALLOY_CFG"
if grep -Eq 'regex[[:space:]]*=.*/\(traefik\|.+\)' "$ALLOY_CFG"; then
    log_error "Alloy config should not include extra app selectors in core observability."
fi

tmp_output=$(mktemp)
trap 'rm -f "$tmp_output"' EXIT

# Guardrails support observability-only mode without unrelated warnings.
if ! COMPOSE_PROFILES=observability TRAEFIK_DASHBOARD=false GRAFANA_HOSTNAME=grafana GRAFANA_ADMIN_PASSWORD=secret123 \
    PROMETHEUS_RETENTION_TIME=7d LOKI_RETENTION_PERIOD=168h TEMPO_RETENTION_PERIOD=168h PYROSCOPE_RETENTION_PERIOD=168h \
    "$GUARDRAIL" >"$tmp_output" 2>&1; then
    log_error "observability-only mode should pass preflight validation."
fi
if grep -Eqi 'dashboards/log queries may be empty|without .* profile' "$tmp_output"; then
    log_error "observability-only guardrails should not emit app-profile warnings."
fi

log_success "Observability app-pack tolerance test passed."
