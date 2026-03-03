#!/bin/bash
# Smoke test: Validate Plane Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in plane-bootstrap plane-up plane-down plane-restart plane-logs plane-status; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

grep -q '^test-plane:' "$MAKEFILE" || log_error "Missing Make target: test-plane"

for target in plane-up plane-down plane-logs plane-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile plane/ &&
          ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile plane."
    fi
done

grep -q 'plane-bootstrap' "$MAKEFILE" || log_error "plane-bootstrap help/wiring missing"
grep -q 'plane/compose.yml' "$MAKEFILE" || log_error "Plane compose fragment missing from COMPOSE_FILES"

log_success "Plane Make target wiring test passed."
