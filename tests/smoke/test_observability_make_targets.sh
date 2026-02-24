#!/bin/bash
# Smoke test: Validate observability Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in observability-bootstrap observability-up observability-down observability-restart observability-logs observability-status; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

grep -q '^test-observability:' "$MAKEFILE" || log_error "Missing Make target: test-observability"

for target in observability-up observability-down observability-logs observability-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile observability/ &&
          ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile observability."
    fi
done

grep -q 'services/observability/compose.yml' "$MAKEFILE" || log_error "Observability compose fragment missing from COMPOSE_FILES"

log_success "Observability Make target wiring test passed."
