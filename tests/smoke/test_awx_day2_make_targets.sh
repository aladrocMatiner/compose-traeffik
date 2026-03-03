#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found"

for target in awx-debug awx-backup awx-restore awx-upgrade; do
  grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done

grep -q 'AWX_RESTORE_ARGS' "$MAKEFILE" || log_error "awx-restore target should support AWX_RESTORE_ARGS"
grep -q 'AWX_UPGRADE_ARGS' "$MAKEFILE" || log_error "awx-upgrade target should support AWX_UPGRADE_ARGS"

log_success "AWX day-2 Make targets test passed."
