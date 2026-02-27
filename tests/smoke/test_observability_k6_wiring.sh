#!/bin/bash
# Smoke test: Validate observability k6 wiring (Make target + script path).

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
K6_SCRIPT="$SCRIPT_DIR/../../services/observability/k6/smoke.js"
COMPOSE_FILE="$SCRIPT_DIR/../../services/observability/compose.yml"

[ -f "$MAKEFILE" ] || log_error "Makefile not found."
[ -f "$K6_SCRIPT" ] || log_error "Missing k6 script: $K6_SCRIPT"
[ -f "$COMPOSE_FILE" ] || log_error "Missing compose file: $COMPOSE_FILE"

grep -q '^observability-k6:' "$MAKEFILE" || log_error "Missing Make target: observability-k6"
grep -q 'run --rm k6' "$MAKEFILE" || log_error "observability-k6 target must run k6 via compose."
grep -q -- '--profile observability' "$MAKEFILE" || log_error "observability-k6 target must use observability profile."

grep -Fq '  k6:' "$COMPOSE_FILE"
grep -Fq './services/observability/k6:/scripts:ro' "$COMPOSE_FILE"
grep -Fq '/scripts/smoke.js' "$COMPOSE_FILE"

log_success "Observability k6 wiring test passed."
