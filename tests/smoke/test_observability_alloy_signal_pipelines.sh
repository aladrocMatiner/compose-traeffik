#!/bin/bash
# Smoke test: Validate Alloy multi-signal pipelines (logs + traces + profiles).

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

ALLOY_CFG="$SCRIPT_DIR/../../services/observability/alloy/config.alloy"
[ -f "$ALLOY_CFG" ] || log_error "Alloy config missing."

# Existing logs pipeline to Loki.
grep -Fq 'loki.source.docker "docker_logs"' "$ALLOY_CFG"
grep -Fq 'url = "http://loki:3100/loki/api/v1/push"' "$ALLOY_CFG"

# Trace pipeline via OTLP receiver.
grep -Fq 'otelcol.receiver.otlp "default"' "$ALLOY_CFG"
grep -Fq 'endpoint = "0.0.0.0:4317"' "$ALLOY_CFG"
grep -Fq 'endpoint = "0.0.0.0:4318"' "$ALLOY_CFG"
grep -Fq 'otelcol.exporter.otlp "tempo"' "$ALLOY_CFG"
grep -Fq 'endpoint = "tempo:4317"' "$ALLOY_CFG"

# Profile pipeline via Pyroscope receive_http/write components.
grep -Fq 'pyroscope.receive_http "default"' "$ALLOY_CFG"
grep -Fq 'listen_port    = 9999' "$ALLOY_CFG"
grep -Fq 'pyroscope.write "default"' "$ALLOY_CFG"
grep -Fq 'url = "http://pyroscope:4040"' "$ALLOY_CFG"

log_success "Observability Alloy signal pipeline test passed."
