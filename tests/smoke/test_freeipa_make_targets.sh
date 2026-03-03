#!/bin/bash
# Smoke test: Validate FreeIPA Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in freeipa-bootstrap freeipa-up freeipa-down freeipa-restart freeipa-logs freeipa-status; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

grep -q '^test-freeipa:' "$MAKEFILE" || log_error "Missing Make target: test-freeipa"

for target in freeipa-up freeipa-down freeipa-logs freeipa-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile freeipa/ &&
          ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile freeipa."
    fi
done

grep -q 'services/freeipa/compose.yml' "$MAKEFILE" || log_error "FreeIPA compose fragment missing from COMPOSE_FILES"

grep -q 'freeipa-bootstrap' "$MAKEFILE" || log_error "freeipa-bootstrap help/wiring missing"

log_success "FreeIPA Make target wiring test passed."
