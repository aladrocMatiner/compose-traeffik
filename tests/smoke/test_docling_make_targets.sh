#!/bin/bash
# Smoke test: Validate Docling Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in docling-bootstrap docling-up docling-down docling-restart docling-logs docling-status; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

grep -q '^test-docling:' "$MAKEFILE" || log_error "Missing Make target: test-docling"

for target in docling-up docling-down docling-logs docling-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile docling/ &&
          ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile docling."
    fi
done

grep -q 'docling-bootstrap' "$MAKEFILE" || log_error "docling-bootstrap help/wiring missing"
grep -q 'docling/compose.yml' "$MAKEFILE" || log_error "Docling compose fragment missing from COMPOSE_FILES"

log_success "Docling Make target wiring test passed."
