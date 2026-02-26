#!/bin/bash
# Smoke test: Validate Rocket.Chat Make targets and compose profile wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"

[ -f "$MAKEFILE" ] || log_error "Makefile not found."
check_command grep
check_command awk

for target in rocketchat-bootstrap rocketchat-up rocketchat-down rocketchat-restart rocketchat-logs rocketchat-status test-rocketchat; do
  if ! grep -q "^${target}:" "$MAKEFILE"; then
    log_error "Missing Make target: ${target}"
  fi
done

for target in rocketchat-up rocketchat-down rocketchat-logs rocketchat-status; do
  if ! awk -v t="$target" '
    $0 ~ "^" t ":" { in_target=1; next }
    in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && $0 ~ /--profile rocketchat/ &&
      ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
    END { exit(found ? 0 : 1) }
  ' "$MAKEFILE"; then
    log_error "Target ${target} is not wired through scripts/compose.sh with profile rocketchat."
  fi
done

if ! awk '
  /^rocketchat-up:/ { found = ($0 ~ /rocketchat-bootstrap/); exit(found ? 0 : 1) }
  END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
  log_error "rocketchat-up should depend on rocketchat-bootstrap."
fi

log_success "Rocket.Chat Make target wiring test passed."
