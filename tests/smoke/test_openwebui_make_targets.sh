#!/bin/bash
# Smoke test: Validate OpenWebUI Make target wiring.

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

for target in webui-up webui-down webui-restart webui-logs webui-status; do
    if ! grep -q "^${target}:" "$MAKEFILE"; then
        log_error "Missing OpenWebUI Make target: ${target}"
    fi
done

if ! awk '
    /^webui-up:/ { in_target=1; next }
    in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && /compose\.sh/ && /--profile webui/ && /up -d openwebui/ { found=1 }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "webui-up must route through scripts/compose.sh with --profile webui"
fi

if ! awk '
    /^webui-down:/ { in_target=1; next }
    in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && /stop openwebui/ { has_stop=1 }
    in_target && /rm -f openwebui/ { has_rm=1 }
    END { exit(has_stop && has_rm ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "webui-down must stop and remove openwebui container"
fi

log_success "OpenWebUI Make target wiring smoke test passed."
