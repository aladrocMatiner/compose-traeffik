#!/bin/bash
# Smoke test: Validate Traefik observability static config (metrics + access logs).

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

CFG="$SCRIPT_DIR/../../services/traefik/traefik.yml"
[ -f "$CFG" ] || log_error "Traefik static config not found."

grep -Fq 'accessLog:' "$CFG"
grep -Fq 'format: json' "$CFG"
grep -Fq 'headers:' "$CFG"
grep -Fq 'defaultMode: drop' "$CFG"
grep -Fq 'Authorization: drop' "$CFG"
grep -Fq 'Cookie: drop' "$CFG"
grep -Fq 'Set-Cookie: drop' "$CFG"

grep -Fq 'metrics:' "$CFG"
grep -Fq 'prometheus:' "$CFG"
grep -Fq 'addEntryPointsLabels: true' "$CFG"
grep -Fq 'addRoutersLabels: true' "$CFG"
grep -Fq 'addServicesLabels: true' "$CFG"

log_success "Observability Traefik config test passed."
