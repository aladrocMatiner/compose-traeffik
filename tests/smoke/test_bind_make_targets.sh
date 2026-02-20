#!/bin/bash
# File: tests/smoke/test_bind_make_targets.sh
#
# Smoke test: Validate BIND Make targets and compose wiring.
#
# Usage: ./tests/smoke/test_bind_make_targets.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"

if [ ! -f "$MAKEFILE" ]; then
    log_error "Makefile not found."
fi

check_command "grep"
check_command "awk"

for target in bind-up bind-down bind-restart bind-logs bind-status bind-provision bind-provision-dry; do
    if ! grep -q "^${target}:" "$MAKEFILE"; then
        log_error "Missing Make target: ${target}"
    fi
done

# Lifecycle targets must route through compose wrapper with bind profile.
for target in bind-up bind-down bind-logs bind-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile bind/ &&
          ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile bind."
    fi
done

if ! awk '
    /^bind-restart:/ { in_target=1; if ($0 ~ /bind-down bind-up/) found=1; next }
    in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "bind-restart target should delegate to bind-down bind-up."
fi

log_success "BIND Make target wiring test passed."
