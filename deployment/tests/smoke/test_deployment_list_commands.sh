#!/bin/bash
# File: deployment/tests/smoke/test_deployment_list_commands.sh
#
# Smoke test: Validate deployment list command outputs.
#
# Usage: ./deployment/tests/smoke/test_deployment_list_commands.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../../scripts/common.sh"

REPO_ROOT="$SCRIPT_DIR/../../.."

check_command "make"
check_command "grep"

os_output="$(make -s -C "$REPO_ROOT" deployment-list-os)"
target_output="$(make -s -C "$REPO_ROOT" deployment-list-targets)"

expected_os=$'ubuntu\ndebian12\ndebian13\ndebian\ngentoo\nopensuse-leap\nalmalinux9\nrockylinux9\nfedora-cloud'
if [ "$os_output" != "$expected_os" ]; then
    log_error "deployment-list-os output drifted.\nExpected:\n${expected_os}\nGot:\n${os_output}"
fi

if [ "$target_output" != "qemu" ]; then
    log_error "deployment-list-targets must currently return only 'qemu'. Got: ${target_output}"
fi

log_success "Deployment list command output test passed."
