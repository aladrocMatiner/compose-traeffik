#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found"
for target in awx-bootstrap awx-k3d-up awx-k3d-down awx-up awx-down awx-status awx-logs awx-admin-password test-awx; do
  grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done
log_success "AWX Make target wiring test passed."
