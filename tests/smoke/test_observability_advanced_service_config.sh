#!/bin/bash
# Smoke test: Validate advanced observability service wiring (tempo/pyroscope/k6).

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/observability/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Observability compose fragment not found."

for svc in "  tempo:" "  pyroscope:" "  k6:"; do
    grep -q "^${svc}$" "$COMPOSE_FILE" || log_error "Missing service block: ${svc}"
done

# Tempo and Pyroscope are internal-only by default.
if grep -nE 'traefik\\.' "$COMPOSE_FILE" | grep -qE 'tempo|pyroscope'; then
    log_error "Tempo/Pyroscope should not have Traefik labels by default."
fi

if awk '
  /^  tempo:|^  pyroscope:/ { in_svc=1 }
  in_svc && /^  [a-zA-Z0-9_-]+:/ && $0 !~ /^  tempo:|^  pyroscope:/ { in_svc=0 }
  in_svc && /^[[:space:]]+ports:/ { found=1 }
  END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "Tempo/Pyroscope should not publish host ports."
fi

grep -Fq 'TEMPO_RETENTION_PERIOD' "$COMPOSE_FILE"
grep -Fq 'PYROSCOPE_RETENTION_PERIOD' "$COMPOSE_FILE"
grep -Fq 'K6_PROMETHEUS_RW_SERVER_URL' "$COMPOSE_FILE"

log_success "Observability advanced service configuration test passed."
