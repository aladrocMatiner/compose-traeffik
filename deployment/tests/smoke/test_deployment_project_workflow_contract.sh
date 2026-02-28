#!/bin/bash
# File: deployment/tests/smoke/test_deployment_project_workflow_contract.sh
#
# Smoke test: Validate deployment-project CLI guardrails and workflow ordering contract.
#
# Usage: ./deployment/tests/smoke/test_deployment_project_workflow_contract.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../../scripts/common.sh"

REPO_ROOT="$SCRIPT_DIR/../../.."
RUNNER="$REPO_ROOT/deployment/scripts/deployment-project.sh"

check_command "grep"
check_command "awk"

if [ ! -x "$RUNNER" ]; then
    log_error "deployment-project runner not found or not executable: $RUNNER"
fi

set +e
missing_out="$(make -s -C "$REPO_ROOT" deployment-project 2>&1)"
missing_rc=$?
set -e
if [ "$missing_rc" -eq 0 ]; then
    log_error "deployment-project without project selector must fail"
fi
if ! printf '%s' "$missing_out" | grep -q "Missing required selector"; then
    log_error "Missing project selector error is not explicit"
fi

set +e
unsupported_out="$($RUNNER run --project does-not-exist 2>&1)"
unsupported_rc=$?
set -e
if [ "$unsupported_rc" -eq 0 ]; then
    log_error "deployment-project must fail for unsupported project id"
fi
if ! printf '%s' "$unsupported_out" | grep -q "Unsupported project"; then
    log_error "Unsupported project error is not explicit"
fi

if ! awk '
  /run_stage provision/ { p=NR }
  /run_stage wait/ { w=NR }
  /run_stage system_bootstrap/ { b=NR }
  /run_stage project_deploy/ { d=NR }
  END { exit((p>0 && w>p && b>w && d>b) ? 0 : 1) }
' "$RUNNER"; then
  log_error "deployment-project workflow order must be provision -> wait -> system_bootstrap -> project_deploy"
fi

if ! grep -q "Destroy manually if needed" "$RUNNER"; then
    log_error "deployment-project must provide explicit recovery guidance on failure"
fi

if ! grep -q -- "--tls-mode" "$RUNNER"; then
    log_error "deployment-project runner must expose --tls-mode override option"
fi

if ! grep -q "tf_state_path_for_vm" "$RUNNER"; then
    log_error "deployment-project runner must isolate terraform state per VM/project"
fi

if ! grep -q "check_dependencies_registry" "$RUNNER"; then
    log_error "deployment-project runner must validate dependencies from controller registry"
fi

log_success "Deployment project workflow contract test passed."
