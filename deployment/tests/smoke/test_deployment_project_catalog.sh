#!/bin/bash
# File: deployment/tests/smoke/test_deployment_project_catalog.sh
#
# Smoke test: Validate deployment project catalog and traefik-stepca manifest contract.
#
# Usage: ./deployment/tests/smoke/test_deployment_project_catalog.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../../scripts/common.sh"

REPO_ROOT="$SCRIPT_DIR/../../.."
CATALOG="$REPO_ROOT/deployment/projects/catalog.json"
MANIFEST="$REPO_ROOT/deployment/projects/traefik-stepca/manifest.json"

check_command "jq"
check_command "make"
check_command "grep"

if [ ! -f "$CATALOG" ]; then
    log_error "Missing deployment project catalog: $CATALOG"
fi

if [ ! -f "$MANIFEST" ]; then
    log_error "Missing traefik-stepca manifest: $MANIFEST"
fi

list_output="$(make -s -C "$REPO_ROOT" deployment-project-list)"
if [ "$list_output" != "traefik-stepca" ]; then
    log_error "deployment-project-list output drifted. Expected 'traefik-stepca', got: $list_output"
fi

if ! jq -e '.projects | type == "array" and length > 0' "$CATALOG" >/dev/null; then
    log_error "Invalid project catalog schema: projects must be a non-empty array"
fi

if ! jq -e '.projects[] | select(.id=="traefik-stepca") | .manifest == "deployment/projects/traefik-stepca/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-stepca is missing or points to an unexpected manifest path"
fi

if ! jq -e '
    .id == "traefik-stepca" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "stepca" and
    (.services == ["traefik", "step-ca", "whoami"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | type == "array" and length > 0) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects | type == "array")
' "$MANIFEST" >/dev/null; then
    log_error "traefik-stepca manifest contract is invalid"
fi

set +e
override_out="$("$REPO_ROOT/deployment/scripts/deployment-project.sh" run --project traefik-stepca --services whoami 2>&1)"
override_rc=$?
set -e
if [ "$override_rc" -eq 0 ]; then
    log_error "deployment-project runner must reject ad-hoc service override arguments"
fi
if ! printf '%s' "$override_out" | grep -q "Unknown argument: --services"; then
    log_error "Expected explicit rejection for unsupported --services override"
fi

log_success "Deployment project catalog smoke test passed."
