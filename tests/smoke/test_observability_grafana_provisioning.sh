#!/bin/bash
# Smoke test: Validate Grafana provisioning for observability datasources/dashboards.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

DS="$SCRIPT_DIR/../../services/observability/grafana/provisioning/datasources/datasources.yml"
DB="$SCRIPT_DIR/../../services/observability/grafana/provisioning/dashboards/dashboards.yml"
CORE="$SCRIPT_DIR/../../services/observability/grafana/dashboards/core/traefik-overview.json"
CTFD="$SCRIPT_DIR/../../services/observability/grafana/dashboards/ctfd/ctfd-logs.json"

for f in "$DS" "$DB" "$CORE" "$CTFD"; do
    [ -f "$f" ] || log_error "Missing Grafana provisioning asset: $f"
done

grep -Fq 'type: prometheus' "$DS"
grep -Fq 'url: http://prometheus:9090' "$DS"
grep -Fq 'type: loki' "$DS"
grep -Fq 'url: http://loki:3100' "$DS"

grep -Fq '/var/lib/grafana/dashboards/core' "$DB"
grep -Fq '/var/lib/grafana/dashboards/ctfd' "$DB"

grep -Fq 'traefik_entrypoint_requests_total' "$CORE"
grep -Fq 'container' "$CORE"
grep -Fq 'traefik' "$CORE"
grep -Fq 'ctfd' "$CTFD"

log_success "Observability Grafana provisioning test passed."
