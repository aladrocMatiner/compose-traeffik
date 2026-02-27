#!/bin/bash
# File: tests/smoke/test_deployment_access_cli.sh
#
# Smoke test: Validate deployment-access CLI guardrails.
#
# Usage: ./tests/smoke/test_deployment_access_cli.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

ACCESS_SCRIPT="$SCRIPT_DIR/../../scripts/deployment-access.sh"

if [ ! -x "$ACCESS_SCRIPT" ]; then
    log_error "deployment-access script not found or not executable."
fi

check_command "grep"

# Help path should succeed.
if ! "$ACCESS_SCRIPT" --help >/dev/null 2>&1; then
    log_error "deployment-access --help should exit successfully."
fi

# Invalid target should fail with a clear message.
set +e
invalid_out="$("$ACCESS_SCRIPT" list --target invalid 2>&1)"
invalid_rc=$?
set -e
if [ "$invalid_rc" -eq 0 ]; then
    log_error "deployment-access list --target invalid must fail."
fi
if ! printf '%s' "$invalid_out" | grep -q "Unsupported target"; then
    log_error "Expected unsupported target error message."
fi

# Proxmox list without credentials should fail clearly before making assumptions.
set +e
proxmox_out="$("$ACCESS_SCRIPT" list --target proxmox 2>&1)"
proxmox_rc=$?
set -e
if [ "$proxmox_rc" -eq 0 ]; then
    log_error "deployment-access list --target proxmox without credentials must fail."
fi
if ! printf '%s' "$proxmox_out" | grep -q "Missing Proxmox API URL"; then
    log_error "Expected missing Proxmox API URL guidance."
fi

log_success "Deployment access CLI guardrails test passed."
