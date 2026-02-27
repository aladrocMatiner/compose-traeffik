#!/bin/bash
# Smoke test: Validate observability preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

log_info "Checking observability guardrails reject missing Grafana admin password..."
if COMPOSE_PROFILES=observability TRAEFIK_DASHBOARD=false GRAFANA_HOSTNAME=grafana \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted observability profile with missing GRAFANA_ADMIN_PASSWORD."
fi

log_info "Checking observability guardrails pass without ctfd (warn-only)..."
if ! output=$(COMPOSE_PROFILES=observability TRAEFIK_DASHBOARD=false \
    GRAFANA_HOSTNAME=grafana GRAFANA_ADMIN_PASSWORD=secret123 \
    PROMETHEUS_RETENTION_TIME=7d LOKI_RETENTION_PERIOD=168h TEMPO_RETENTION_PERIOD=168h PYROSCOPE_RETENTION_PERIOD=168h \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" 2>&1 >/dev/null); then
    log_error "validate-env rejected observability-only mode."
fi

echo "$output" | grep -qi 'ctfd' || log_error "Expected warn-only guidance about missing ctfd profile."

log_info "Checking observability guardrails reject invalid k6 URL..."
if COMPOSE_PROFILES=observability TRAEFIK_DASHBOARD=false \
    GRAFANA_HOSTNAME=grafana GRAFANA_ADMIN_PASSWORD=secret123 \
    PROMETHEUS_RETENTION_TIME=7d LOKI_RETENTION_PERIOD=168h TEMPO_RETENTION_PERIOD=168h PYROSCOPE_RETENTION_PERIOD=168h \
    K6_TARGET_URL=whoami.local.test K6_ITERATIONS=10 K6_SLEEP_SECONDS=1 \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid K6_TARGET_URL without http/https scheme."
fi

log_success "Observability guardrails test passed."
