#!/bin/bash
# File: deployment/tests/smoke/test_deployment_keycloak_oidc_idempotency_contract.sh
#
# Smoke test: Validate Keycloak bootstrap and per-project OIDC client idempotency contract.
#
# Usage: ./deployment/tests/smoke/test_deployment_keycloak_oidc_idempotency_contract.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../../scripts/common.sh"

TASKS_FILE="$SCRIPT_DIR/../../ansible/roles/project_deploy/tasks/main.yml"

check_command "grep"

if [ ! -f "$TASKS_FILE" ]; then
    log_error "Required Ansible tasks file not found: $TASKS_FILE"
fi

# Keycloak realm/user bootstrap must be idempotent (create-or-update semantics).
if ! grep -q "Bootstrap shared Keycloak realm and initial user (traefik-keycloak)" "$TASKS_FILE"; then
    log_error "Keycloak bootstrap task is missing for traefik-keycloak"
fi
if ! grep -qF 'kcadm.sh get "realms/${realm}"' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must query realm existence before create/update"
fi
if ! grep -qF 'kcadm.sh create realms -s realm="${realm}" -s enabled=true' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must create realm when missing"
fi
if ! grep -qF 'kcadm.sh update "realms/${realm}" -s enabled=true' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must update/reconcile realm when present"
fi
if ! grep -qF 'kcadm.sh create users -r "${realm}"' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must attempt user create in target realm"
fi
if ! grep -Eq 'already exists\|User exists' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must tolerate pre-existing bootstrap user"
fi
if ! grep -qF 'kcadm.sh set-password' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must reconcile bootstrap user password"
fi
if ! grep -qF 'kcadm.sh update "users/${user_id}" -r "${realm}"' "$TASKS_FILE"; then
    log_error "Keycloak bootstrap must reconcile bootstrap user attributes"
fi

assert_oidc_project_flow() {
    local label="$1"
    local auth_task="$2"
    local lookup_task="$3"
    local create_task="$4"
    local refresh_task="$5"
    local update_task="$6"
    local existing_var="$7"

    if ! grep -q "$auth_task" "$TASKS_FILE"; then
        log_error "Missing admin auth guardrail task for ${label}"
    fi
    if ! grep -q "$lookup_task" "$TASKS_FILE"; then
        log_error "Missing OIDC client lookup task for ${label}"
    fi
    if ! grep -q "$create_task" "$TASKS_FILE"; then
        log_error "Missing OIDC client create task for ${label}"
    fi
    if ! grep -q "$refresh_task" "$TASKS_FILE"; then
        log_error "Missing OIDC client refresh task for ${label}"
    fi
    if ! grep -q "$update_task" "$TASKS_FILE"; then
        log_error "Missing OIDC client update task for ${label}"
    fi
    if ! grep -q "${existing_var} == {}" "$TASKS_FILE"; then
        log_error "OIDC create path for ${label} must be gated by empty existing-client lookup"
    fi
}

assert_oidc_project_flow \
    "observability" \
    "Ensure Keycloak admin authentication works before OIDC provisioning" \
    "Query Keycloak client by client_id in target realm" \
    "Create OIDC client in Keycloak when missing" \
    "Refresh OIDC client lookup after create" \
    "Update OIDC client contract in Keycloak" \
    "deployment_project_keycloak_existing_client"

assert_oidc_project_flow \
    "wikijs" \
    "Ensure Keycloak admin authentication works before Wiki.js OIDC provisioning" \
    "Query Keycloak client by client_id in target realm (wikijs)" \
    "Create OIDC client in Keycloak when missing (wikijs)" \
    "Refresh OIDC client lookup after create (wikijs)" \
    "Update OIDC client contract in Keycloak (wikijs)" \
    "deployment_project_wikijs_keycloak_existing_client"

assert_oidc_project_flow \
    "semaphoreui" \
    "Ensure Keycloak admin authentication works before Semaphore UI OIDC provisioning" \
    "Query Keycloak client by client_id in target realm (semaphoreui)" \
    "Create OIDC client in Keycloak when missing (semaphoreui)" \
    "Refresh OIDC client lookup after create (semaphoreui)" \
    "Update OIDC client contract in Keycloak (semaphoreui)" \
    "deployment_project_semaphoreui_keycloak_existing_client"

assert_oidc_project_flow \
    "rocketchat" \
    "Ensure Keycloak admin authentication works before Rocket.Chat OIDC provisioning" \
    "Query Keycloak client by client_id in target realm (rocketchat)" \
    "Create OIDC client in Keycloak when missing (rocketchat)" \
    "Refresh OIDC client lookup after create (rocketchat)" \
    "Update OIDC client contract in Keycloak (rocketchat)" \
    "deployment_project_rocketchat_keycloak_existing_client"

assert_oidc_project_flow \
    "gitlab" \
    "Ensure Keycloak admin authentication works before GitLab OIDC provisioning" \
    "Query Keycloak client by client_id in target realm (gitlab)" \
    "Create OIDC client in Keycloak when missing (gitlab)" \
    "Refresh OIDC client lookup after create (gitlab)" \
    "Update OIDC client contract in Keycloak (gitlab)" \
    "deployment_project_gitlab_keycloak_existing_client"

log_success "Keycloak bootstrap/OIDC idempotency contract test passed."
