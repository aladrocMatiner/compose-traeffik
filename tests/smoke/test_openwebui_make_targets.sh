#!/bin/bash
# Smoke test: Validate OpenWebUI Make targets and compose wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

for target in webui-up webui-down webui-restart webui-logs webui-status; do
    grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

grep -q '^test-webui:' "$MAKEFILE" || log_error "Missing Make target: test-webui"

for target in webui-up webui-down webui-logs webui-status; do
    if ! awk -v t="$target" '
        $0 ~ "^" t ":" { in_target=1; next }
        in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
        in_target && $0 ~ /--profile webui/ &&
          ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
        END { exit(found ? 0 : 1) }
    ' "$MAKEFILE"; then
        log_error "Target ${target} is not wired through scripts/compose.sh with profile webui."
    fi
done

grep -q 'services/openwebui/compose.yml' "$MAKEFILE" || log_error "OpenWebUI compose fragment missing from COMPOSE_FILES"

log_success "OpenWebUI Make target wiring test passed."
