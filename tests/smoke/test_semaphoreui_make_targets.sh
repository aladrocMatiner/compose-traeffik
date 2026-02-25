#!/bin/bash
# Smoke test: Validate Semaphore UI Make targets and compose wrapper wiring.

set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
MAKEFILE="$SCRIPT_DIR/../../Makefile"

[ -f "$MAKEFILE" ] || log_error "Makefile not found."
check_command grep
check_command awk

for target in semaphoreui-bootstrap semaphoreui-up semaphoreui-down semaphoreui-restart semaphoreui-logs semaphoreui-status test-semaphoreui; do
  grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

for target in semaphoreui-up semaphoreui-down semaphoreui-logs semaphoreui-status; do
  awk -v t="$target" '
    $0 ~ "^" t ":" { in_target=1; next }
    in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && $0 ~ /--profile semaphoreui/ && ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
    END { exit(found ? 0 : 1) }
  ' "$MAKEFILE" || log_error "Target ${target} is not wired through scripts/compose.sh with profile semaphoreui."
done

awk '
  /^semaphoreui-restart:/ { if ($0 ~ /semaphoreui-down semaphoreui-up/) found=1 }
  END { exit(found ? 0 : 1) }
' "$MAKEFILE" || log_error "semaphoreui-restart should delegate to semaphoreui-down semaphoreui-up."

awk '
  /^test-semaphoreui:/ { in_target=1; next }
  in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
  in_target && /test_semaphoreui_.*\.sh/ { found=1 }
  END { exit(found ? 0 : 1) }
' "$MAKEFILE" || log_error "test-semaphoreui target does not execute Semaphore UI smoke tests."

log_success "Semaphore UI Make target wiring test passed."
