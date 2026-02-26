#!/bin/bash
# Smoke test: Validate Wiki.js Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in wikijs-bootstrap wikijs-up wikijs-down wikijs-restart wikijs-logs wikijs-status test-wikijs; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

for target in wikijs-up wikijs-down wikijs-logs wikijs-status; do
    awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) && $0 ~ /--profile wikijs/ { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE" || log_error "Target ${target} is not wired through scripts/compose.sh with profile wikijs."
done

awk '
    /^wikijs-up:/ { if ($0 ~ /wikijs-bootstrap/) found=1 }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE" || log_error "wikijs-up should depend on wikijs-bootstrap."

log_success "Wiki.js Make target wiring test passed."
