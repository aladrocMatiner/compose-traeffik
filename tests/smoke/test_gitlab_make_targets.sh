#!/bin/bash
# Smoke test: Validate GitLab Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"

[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in gitlab-bootstrap gitlab-up gitlab-down gitlab-restart gitlab-logs gitlab-status test-gitlab; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

for target in gitlab-up gitlab-down gitlab-logs gitlab-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) && $0 ~ /--profile gitlab/ { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile gitlab."
    fi
done

if ! awk '
    /^gitlab-restart:/ { if ($0 ~ /gitlab-down gitlab-up/) found=1 }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "gitlab-restart target should delegate to gitlab-down gitlab-up."
fi

log_success "GitLab Make target wiring test passed."
