#!/bin/bash
# Smoke test: Validate Grafana provisioning for observability datasources/dashboards.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

DS="$SCRIPT_DIR/../../services/observability/grafana/provisioning/datasources/datasources.yml"
DB="$SCRIPT_DIR/../../services/observability/grafana/provisioning/dashboards/dashboards.yml"
CORE="$SCRIPT_DIR/../../services/observability/grafana/dashboards/core/traefik-overview.json"
TRACING="$SCRIPT_DIR/../../services/observability/grafana/dashboards/tracing/tempo-traces-overview.json"
PROFILING="$SCRIPT_DIR/../../services/observability/grafana/dashboards/profiling/pyroscope-profiles-overview.json"

for f in "$DS" "$DB" "$CORE" "$TRACING" "$PROFILING"; do
    [ -f "$f" ] || log_error "Missing Grafana provisioning asset: $f"
done

grep -Fq 'type: prometheus' "$DS"
grep -Fq 'url: http://prometheus:9090' "$DS"
grep -Fq 'type: loki' "$DS"
grep -Fq 'url: http://loki:3100' "$DS"
grep -Fq 'type: tempo' "$DS"
grep -Fq 'url: http://tempo:3200' "$DS"
grep -Fq 'type: grafana-pyroscope-datasource' "$DS"
grep -Fq 'url: http://pyroscope:4040' "$DS"

grep -Fq '/var/lib/grafana/dashboards/core' "$DB"
grep -Fq '/var/lib/grafana/dashboards/tracing' "$DB"
grep -Fq '/var/lib/grafana/dashboards/profiling' "$DB"

grep -Fq 'traefik_entrypoint_requests_total' "$CORE"
grep -Fq 'container' "$CORE"
grep -Fq 'traefik' "$CORE"
grep -Fq 'Tempo' "$TRACING"
grep -Fq 'Pyroscope' "$PROFILING"

log_success "Observability Grafana provisioning test passed."
