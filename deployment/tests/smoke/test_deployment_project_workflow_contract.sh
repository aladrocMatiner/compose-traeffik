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

set +e
docling_out="$($RUNNER run --project traefik-docling 2>&1)"
docling_rc=$?
set -e
if [ "$docling_rc" -eq 0 ]; then
    log_error "traefik-docling must fail while runtime service implementation is pending"
fi
if ! printf '%s' "$docling_out" | grep -q "deployment-contract only"; then
    log_error "traefik-docling guardrail must declare deployment-only contract status"
fi
if ! printf '%s' "$docling_out" | grep -q "No compose apply was attempted"; then
    log_error "traefik-docling guardrail must confirm compose apply was skipped"
fi
if ! printf '%s' "$docling_out" | grep -q "Transition path"; then
    log_error "traefik-docling guardrail must provide explicit transition guidance"
fi

set +e
awx_out="$($RUNNER run --project traefik-awx 2>&1)"
awx_rc=$?
set -e
if [ "$awx_rc" -eq 0 ]; then
    log_error "traefik-awx must fail while runtime hybrid implementation is pending in deployment-project"
fi
if ! printf '%s' "$awx_out" | grep -q "deployment-contract only"; then
    log_error "traefik-awx guardrail must declare deployment-only contract status"
fi
if ! printf '%s' "$awx_out" | grep -q "No compose apply was attempted"; then
    log_error "traefik-awx guardrail must confirm compose apply was skipped"
fi
if ! printf '%s' "$awx_out" | grep -q "k3d+AWX operator project workflow"; then
    log_error "traefik-awx guardrail must provide explicit transition guidance"
fi

set +e
freeipa_out="$($RUNNER run --project traefik-freeipa 2>&1)"
freeipa_rc=$?
set -e
if [ "$freeipa_rc" -eq 0 ]; then
    log_error "traefik-freeipa must fail while runtime service implementation is pending"
fi
if ! printf '%s' "$freeipa_out" | grep -q "deployment-contract only"; then
    log_error "traefik-freeipa guardrail must declare deployment-only contract status"
fi
if ! printf '%s' "$freeipa_out" | grep -q "No compose apply was attempted"; then
    log_error "traefik-freeipa guardrail must confirm compose apply was skipped"
fi
if ! printf '%s' "$freeipa_out" | grep -q "Transition path"; then
    log_error "traefik-freeipa guardrail must provide explicit transition guidance"
fi

set +e
plane_out="$($RUNNER run --project traefik-plane 2>&1)"
plane_rc=$?
set -e
if [ "$plane_rc" -eq 0 ]; then
    log_error "traefik-plane must fail fast when pinned repo_ref lacks services/plane assets"
fi
if ! printf '%s' "$plane_out" | grep -q "preflight failed"; then
    log_error "traefik-plane preflight must report missing module assets explicitly"
fi
if ! printf '%s' "$plane_out" | grep -q "services/plane/compose.yml"; then
    log_error "traefik-plane preflight must include missing services/plane path"
fi
if ! printf '%s' "$plane_out" | grep -q "No compose apply was attempted"; then
    log_error "traefik-plane preflight must confirm compose apply was skipped"
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

if ! grep -q "auto_reconcile_keycloak_dependents" "$RUNNER"; then
    log_error "deployment-project runner must expose keycloak dependent auto-reconciliation helper"
fi

if ! grep -q "auto_reconcile_stepca_dependents" "$RUNNER"; then
    log_error "deployment-project runner must expose stepca dependent auto-reconciliation helper"
fi

if ! grep -q "DEPLOYMENT_PROJECT_AUTO_RECONCILE_KEYCLOAK_DEPENDENTS" "$RUNNER"; then
    log_error "deployment-project runner must expose env toggle for keycloak dependent auto-reconciliation"
fi

if ! grep -q "DEPLOYMENT_PROJECT_AUTO_RECONCILE_STEPCA_DEPENDENTS" "$RUNNER"; then
    log_error "deployment-project runner must expose env toggle for stepca dependent auto-reconciliation"
fi

if ! grep -q "DEPLOYMENT_PROJECT_STEPCA_RECONCILE_RUNNING_ONLY" "$RUNNER"; then
    log_error "deployment-project runner must expose running-only toggle for stepca dependent auto-reconciliation"
fi

if ! grep -q "DEPLOYMENT_PROJECT_STEPCA_RECONCILE_EXCLUDE" "$RUNNER"; then
    log_error "deployment-project runner must expose exclusion list for stepca dependent auto-reconciliation"
fi

if ! grep -q "Auto-reconciling Keycloak dependent project" "$RUNNER"; then
    log_error "deployment-project runner must emit explicit logs for keycloak dependent auto-reconciliation"
fi

if ! grep -q "Auto-reconciling StepCA dependent project" "$RUNNER"; then
    log_error "deployment-project runner must emit explicit logs for stepca dependent auto-reconciliation"
fi

if ! grep -q "Missing required project dependencies in local registry" "$RUNNER"; then
    log_error "dependency preflight must emit explicit missing dependency message"
fi

if ! grep -q "deploy dependencies first" "$RUNNER"; then
    log_error "dependency preflight must provide explicit recovery guidance"
fi

if ! grep -q "if \[\[ \"\${#deps\[@\]}\" -gt 0 \]\]; then" "$RUNNER"; then
    log_error "dependency preflight guard must only evaluate registry checks when dependencies are declared"
fi

if ! grep -q "if \[\[ \"\${#deps\[@\]}\" -eq 0 \]\]; then" "$RUNNER"; then
    log_error "dependency preflight function must explicitly allow empty dependency sets"
fi

deps_line="$(grep -n 'mapfile -t deps' "$RUNNER" | head -n1 | cut -d: -f1)"
check_line="$(grep -n 'check_dependencies_registry "${deps\[@\]}"' "$RUNNER" | head -n1 | cut -d: -f1)"
bootstrap_line="$(grep -n 'run_stage system_bootstrap' "$RUNNER" | head -n1 | cut -d: -f1)"
if [ -z "$deps_line" ] || [ -z "$check_line" ] || [ -z "$bootstrap_line" ]; then
    log_error "dependency preflight ordering markers are missing in deployment-project runner"
fi
if [ "$check_line" -le "$deps_line" ] || [ "$check_line" -ge "$bootstrap_line" ]; then
    log_error "dependency preflight must run after manifest dependency resolution and before system_bootstrap"
fi

docling_guard_line="$(grep -n 'check_project_runtime_implementation \"\${PROJECT_ID}\" \"\${manifest_path}\"' "$RUNNER" | head -n1 | cut -d: -f1)"
provision_line="$(grep -n 'run_stage provision' "$RUNNER" | head -n1 | cut -d: -f1)"
if [ -z "$docling_guard_line" ] || [ -z "$provision_line" ]; then
    log_error "docling pre-compose guardrail ordering markers are missing in deployment-project runner"
fi
if [ "$docling_guard_line" -ge "$provision_line" ]; then
    log_error "docling pre-compose guardrail must execute before provision stage"
fi

record_line="$(grep -n 'record_project_deployment' "$RUNNER" | head -n1 | cut -d: -f1)"
reconcile_line="$(grep -n 'auto_reconcile_keycloak_dependents' "$RUNNER" | tail -n1 | cut -d: -f1)"
if [ -z "$record_line" ] || [ -z "$reconcile_line" ]; then
    log_error "keycloak dependent auto-reconciliation ordering markers are missing in deployment-project runner"
fi
if [ "$reconcile_line" -le "$record_line" ]; then
    log_error "keycloak dependent auto-reconciliation must run after deployment state is recorded"
fi

stepca_reconcile_line="$(grep -n 'auto_reconcile_stepca_dependents' "$RUNNER" | tail -n1 | cut -d: -f1)"
if [ -z "$record_line" ] || [ -z "$stepca_reconcile_line" ]; then
    log_error "stepca dependent auto-reconciliation ordering markers are missing in deployment-project runner"
fi
if [ "$stepca_reconcile_line" -le "$record_line" ]; then
    log_error "stepca dependent auto-reconciliation must run after deployment state is recorded"
fi

log_success "Deployment project workflow contract test passed."
