#!/bin/bash
# File: tests/smoke/test_wg_make_targets.sh
#
# Smoke test: Validate wg-easy Make targets and compose wrapper wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
COMPOSE_WRAPPER="$SCRIPT_DIR/../../scripts/compose.sh"

if [ ! -f "$MAKEFILE" ]; then
    log_error "Makefile not found."
fi
if [ ! -f "$COMPOSE_WRAPPER" ]; then
    log_error "scripts/compose.sh not found."
fi

check_command "grep"
check_command "awk"

for target in wg-up wg-down wg-restart wg-logs wg-status wg-bootstrap; do
    if ! grep -q "^${target}:" "$MAKEFILE"; then
        log_error "Missing Make target: ${target}"
    fi
done

for target in wg-up wg-down wg-logs wg-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile wg/ && ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile wg."
    fi
done

if ! awk '
    /^wg-restart:/ { if ($0 ~ /wg-down wg-up/) found=1 }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "wg-restart target should delegate to wg-down wg-up."
fi

if ! awk '
    /^wg-bootstrap:/ { in_target=1; next }
    in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && /scripts\/wg-bootstrap\.sh/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "wg-bootstrap target is not wired to scripts/wg-bootstrap.sh."
fi

for help_line in 'wg-bootstrap' 'wg-up' 'wg-status'; do
    if ! grep -q "$help_line" "$MAKEFILE"; then
        log_error "Missing help text for ${help_line} in Makefile."
    fi
done

if ! grep -q 'services/wg-easy/compose.yml' "$MAKEFILE"; then
    log_error "Makefile COMPOSE_FILES is missing services/wg-easy/compose.yml."
fi
if ! grep -q 'services/wg-easy/compose.yml' "$COMPOSE_WRAPPER"; then
    log_error "scripts/compose.sh is missing services/wg-easy/compose.yml."
fi

log_success "WireGuard Make target wiring test passed."
