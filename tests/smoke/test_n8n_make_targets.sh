#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."
for target in n8n-bootstrap n8n-up n8n-down n8n-restart n8n-logs n8n-status test-n8n; do
  grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done
for target in n8n-up n8n-down n8n-logs n8n-status; do
  awk -v t="$target" '
    $0 ~ "^" t ":" { in_target=1; next }
    in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) && $0 ~ /--profile n8n/ { found=1 }
    END { exit(found ? 0 : 1) }
  ' "$MAKEFILE" || log_error "Target ${target} is not wired through scripts/compose.sh with profile n8n."
done
awk '/^n8n-up:/ { if ($0 ~ /n8n-bootstrap/) found=1 } END { exit(found ? 0 : 1) }' "$MAKEFILE" || log_error "n8n-up should depend on n8n-bootstrap."
log_success "n8n Make target wiring test passed."
