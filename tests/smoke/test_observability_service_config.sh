#!/bin/bash
# Smoke test: Validate observability module compose configuration.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/observability/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "Observability compose fragment not found."

for svc in "  grafana:" "  prometheus:" "  loki:" "  alloy:"; do
    grep -q "^${svc}$" "$COMPOSE_FILE" || log_error "Missing service block: ${svc}"
done

grep -Fq 'profile' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- observability$' "$COMPOSE_FILE"

# Grafana routed via Traefik
grep -Fq 'traefik.http.routers.grafana-web.rule=Host(`${GRAFANA_HOSTNAME:-grafana}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.grafana-service.loadbalancer.server.port=3000' "$COMPOSE_FILE"

# Prometheus and Loki remain internal-only (no traefik labels / no host ports)
if grep -nE 'traefik\\.' "$COMPOSE_FILE" | grep -qE 'prometheus|loki'; then
    log_error "Prometheus/Loki should not have Traefik labels by default."
fi
if awk '
  /^  prometheus:|^  loki:/ { in_svc=1 }
  in_svc && /^  [a-zA-Z0-9_-]+:/ && $0 !~ /^  prometheus:|^  loki:/ { in_svc=0 }
  in_svc && /^[[:space:]]+ports:/ { found=1 }
  END { exit(found ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "Prometheus/Loki should not publish host ports."
fi

# Prometheus needs proxy network reachability to Traefik but stays non-public
prom_block=$(awk '
  /^  prometheus:/ { in_block=1 }
  in_block { print }
  in_block && /^  [a-zA-Z0-9_-]+:/ && $0 !~ /^  prometheus:/ { exit }
' "$COMPOSE_FILE")
echo "$prom_block" | grep -Eq '^[[:space:]]+- proxy$' || log_error "prometheus must join proxy network for internal Traefik scraping."
echo "$prom_block" | grep -Eq '^[[:space:]]+- observability-internal$' || log_error "prometheus must join observability-internal."

# Alloy trust-boundary mounts are read-only
grep -Fq '/var/run/docker.sock:/var/run/docker.sock:ro' "$COMPOSE_FILE"
grep -Fq '/var/lib/docker/containers:/var/lib/docker/containers:ro' "$COMPOSE_FILE"

# Retention defaults wired
grep -Fq 'PROMETHEUS_RETENTION_TIME' "$COMPOSE_FILE"
grep -Fq 'LOKI_RETENTION_PERIOD' "$COMPOSE_FILE"

log_success "Observability service configuration test passed."
