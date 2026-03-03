#!/bin/bash
# File: deployment/tests/smoke/test_deployment_project_catalog.sh
#
# Smoke test: Validate deployment project catalog and manifest contracts.
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
KEY_MANIFEST="$REPO_ROOT/deployment/projects/traefik-keycloak/manifest.json"
OBS_MANIFEST="$REPO_ROOT/deployment/projects/traefik-observability/manifest.json"
WIKI_MANIFEST="$REPO_ROOT/deployment/projects/traefik-wikijs/manifest.json"
SEMAPHOREUI_MANIFEST="$REPO_ROOT/deployment/projects/traefik-semaphoreui/manifest.json"
ROCKETCHAT_MANIFEST="$REPO_ROOT/deployment/projects/traefik-rocketchat/manifest.json"
GITLAB_MANIFEST="$REPO_ROOT/deployment/projects/traefik-gitlab/manifest.json"
DNS_BIND_MANIFEST="$REPO_ROOT/deployment/projects/traefik-dns-bind/manifest.json"
LITELLM_MANIFEST="$REPO_ROOT/deployment/projects/traefik-litellm/manifest.json"
DOCLING_MANIFEST="$REPO_ROOT/deployment/projects/traefik-docling/manifest.json"
WEBUI_MANIFEST="$REPO_ROOT/deployment/projects/traefik-webui/manifest.json"

check_command "jq"
check_command "make"
check_command "grep"

if [ ! -f "$CATALOG" ]; then
    log_error "Missing deployment project catalog: $CATALOG"
fi

if [ ! -f "$MANIFEST" ]; then
    log_error "Missing traefik-stepca manifest: $MANIFEST"
fi
if [ ! -f "$KEY_MANIFEST" ]; then
    log_error "Missing traefik-keycloak manifest: $KEY_MANIFEST"
fi
if [ ! -f "$OBS_MANIFEST" ]; then
    log_error "Missing traefik-observability manifest: $OBS_MANIFEST"
fi
if [ ! -f "$WIKI_MANIFEST" ]; then
    log_error "Missing traefik-wikijs manifest: $WIKI_MANIFEST"
fi
if [ ! -f "$SEMAPHOREUI_MANIFEST" ]; then
    log_error "Missing traefik-semaphoreui manifest: $SEMAPHOREUI_MANIFEST"
fi
if [ ! -f "$ROCKETCHAT_MANIFEST" ]; then
    log_error "Missing traefik-rocketchat manifest: $ROCKETCHAT_MANIFEST"
fi
if [ ! -f "$GITLAB_MANIFEST" ]; then
    log_error "Missing traefik-gitlab manifest: $GITLAB_MANIFEST"
fi
if [ ! -f "$DNS_BIND_MANIFEST" ]; then
    log_error "Missing traefik-dns-bind manifest: $DNS_BIND_MANIFEST"
fi
if [ ! -f "$LITELLM_MANIFEST" ]; then
    log_error "Missing traefik-litellm manifest: $LITELLM_MANIFEST"
fi
if [ ! -f "$DOCLING_MANIFEST" ]; then
    log_error "Missing traefik-docling manifest: $DOCLING_MANIFEST"
fi
if [ ! -f "$WEBUI_MANIFEST" ]; then
    log_error "Missing traefik-webui manifest: $WEBUI_MANIFEST"
fi
list_output="$(make -s -C "$REPO_ROOT" deployment-project-list)"
expected_list=$'traefik-stepca\ntraefik-keycloak\ntraefik-observability\ntraefik-wikijs\ntraefik-semaphoreui\ntraefik-rocketchat\ntraefik-gitlab\ntraefik-dns-bind\ntraefik-litellm\ntraefik-docling\ntraefik-webui'
if [ "$list_output" != "$expected_list" ]; then
    log_error "deployment-project-list output drifted. Expected:\n${expected_list}\nGot:\n${list_output}"
fi

if ! jq -e '.projects | type == "array" and length > 0' "$CATALOG" >/dev/null; then
    log_error "Invalid project catalog schema: projects must be a non-empty array"
fi

if ! jq -e '.projects[] | select(.id=="traefik-stepca") | .manifest == "deployment/projects/traefik-stepca/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-stepca is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-observability") | .manifest == "deployment/projects/traefik-observability/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-observability is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-keycloak") | .manifest == "deployment/projects/traefik-keycloak/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-keycloak is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-wikijs") | .manifest == "deployment/projects/traefik-wikijs/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-wikijs is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-semaphoreui") | .manifest == "deployment/projects/traefik-semaphoreui/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-semaphoreui is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-rocketchat") | .manifest == "deployment/projects/traefik-rocketchat/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-rocketchat is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-gitlab") | .manifest == "deployment/projects/traefik-gitlab/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-gitlab is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-dns-bind") | .manifest == "deployment/projects/traefik-dns-bind/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-dns-bind is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-litellm") | .manifest == "deployment/projects/traefik-litellm/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-litellm is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-docling") | .manifest == "deployment/projects/traefik-docling/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-docling is missing or points to an unexpected manifest path"
fi
if ! jq -e '.projects[] | select(.id=="traefik-webui") | .manifest == "deployment/projects/traefik-webui/manifest.json"' "$CATALOG" >/dev/null; then
    log_error "Catalog entry for traefik-webui is missing or points to an unexpected manifest path"
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
    (.depends_on_projects | type == "array") and
    .public_host == "traefik-stepca.local.test"
' "$MANIFEST" >/dev/null; then
    log_error "traefik-stepca manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-keycloak" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | type == "string" and length > 0) and
    .compose_profile == "keycloak" and
    (.services == ["traefik", "whoami", "keycloak"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("KEYCLOAK_ADMIN")) and
    (.required_env | index("KEYCLOAK_ADMIN_PASSWORD")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca"])
' "$KEY_MANIFEST" >/dev/null; then
    log_error "traefik-keycloak manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-observability" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "observability" and
    (.services | type == "array" and length > 0) and
    (.services | index("traefik")) and
    (.services | index("grafana")) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca", "traefik-keycloak"]) and
    (.oidc.enabled == true) and
    (.oidc.realm == "local.test") and
    (.oidc.client_id == "grafana")
' "$OBS_MANIFEST" >/dev/null; then
  log_error "traefik-observability manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-wikijs" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "wikijs" and
    (.services | type == "array" and length > 0) and
    (.services | index("traefik")) and
    (.services | index("whoami")) and
    (.services | index("wikijs")) and
    (.services | index("wikijs-db")) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca", "traefik-keycloak"]) and
    (.oidc.enabled == true) and
    (.oidc.realm == "local.test") and
    (.oidc.client_id == "wikijs") and
    .public_host == "wikijs.local.test"
' "$WIKI_MANIFEST" >/dev/null; then
  log_error "traefik-wikijs manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-semaphoreui" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "semaphoreui" and
    (.services == ["traefik", "whoami", "semaphoreui-db", "semaphoreui"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca", "traefik-keycloak"]) and
    (.oidc.enabled == true) and
    (.oidc.realm == "local.test") and
    (.oidc.client_id == "semaphoreui") and
    .public_host == "semaphoreui.local.test"
' "$SEMAPHOREUI_MANIFEST" >/dev/null; then
  log_error "traefik-semaphoreui manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-rocketchat" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "rocketchat" and
    (.services == ["traefik", "whoami", "rocketchat-mongodb", "rocketchat-mongodb-init-replica", "rocketchat"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca", "traefik-keycloak"]) and
    (.oidc.enabled == true) and
    (.oidc.realm == "local.test") and
    (.oidc.client_id == "rocketchat") and
    .public_host == "rocketchat.local.test"
' "$ROCKETCHAT_MANIFEST" >/dev/null; then
  log_error "traefik-rocketchat manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-gitlab" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "gitlab" and
    (.services == ["traefik", "whoami", "gitlab"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca", "traefik-keycloak"]) and
    (.oidc.enabled == true) and
    (.oidc.realm == "local.test") and
    (.oidc.client_id == "gitlab") and
    .public_host == "gitlab.local.test"
' "$GITLAB_MANIFEST" >/dev/null; then
  log_error "traefik-gitlab manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-dns-bind" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "bind" and
    (.services == ["traefik", "bind"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca"]) and
    .public_host == "traefik-dns-bind.local.test"
' "$DNS_BIND_MANIFEST" >/dev/null; then
  log_error "traefik-dns-bind manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-litellm" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "litellm" and
    (.services == ["traefik", "litellm-db", "litellm"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    (.required_env | index("OPENAI_API_KEY")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca", "traefik-keycloak"]) and
    (.oidc.enabled == true) and
    (.oidc.realm == "local.test") and
    (.oidc.client_id == "litellm") and
    .public_host == "litellm.local.test"
' "$LITELLM_MANIFEST" >/dev/null; then
  log_error "traefik-litellm manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-docling" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "docling" and
    (.services == ["traefik", "docling"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca"]) and
    .public_host == "docling.local.test"
' "$DOCLING_MANIFEST" >/dev/null; then
  log_error "traefik-docling manifest contract is invalid"
fi

if ! jq -e '
    .id == "traefik-webui" and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | test("^[0-9a-f]{40}$")) and
    .compose_profile == "webui" and
    (.services == ["traefik", "openwebui"]) and
    .deploy_playbook == "deployment/ansible/playbooks/project_deploy.yml" and
    (.required_env | index("BASE_DOMAIN")) and
    (.required_env | index("DEV_DOMAIN")) and
    .tls_mode == "stepca-acme" and
    (.depends_on_projects == ["traefik-stepca"]) and
    .public_host == "openwebui.local.test"
' "$WEBUI_MANIFEST" >/dev/null; then
  log_error "traefik-webui manifest contract is invalid"
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
