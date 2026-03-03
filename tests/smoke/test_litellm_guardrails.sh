#!/bin/bash
# File: tests/smoke/test_litellm_guardrails.sh
#
# Smoke test: Validate LiteLLM guardrails in scripts/validate-env.sh.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

VALIDATE_SCRIPT="$SCRIPT_DIR/../../scripts/validate-env.sh"
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT
mkdir -p "$SCRIPT_DIR/../../services/traefik/auth"
LITELLM_UI_TEST_AUTH="$SCRIPT_DIR/../../services/traefik/auth/litellm-ui.guardrail-test.htpasswd"
printf 'admin:$apr1$dummy$dummyhash\n' > "$LITELLM_UI_TEST_AUTH"
trap 'rm -rf "$TMP_DIR"; rm -f "$LITELLM_UI_TEST_AUTH"' EXIT

run_in_clean_cwd() {
  local cmd="$1"
  (cd "$TMP_DIR" && bash -c "$cmd")
}

# Profile disabled: LiteLLM checks must not fail by themselves.
run_in_clean_cwd "COMPOSE_PROFILES='' TRAEFIK_DASHBOARD=false '$VALIDATE_SCRIPT'" >/dev/null

# Missing secrets should fail with bootstrap guidance.
set +e
missing_output=$(run_in_clean_cwd "COMPOSE_PROFILES=litellm TRAEFIK_DASHBOARD=false LITELLM_HOSTNAME=llm '$VALIDATE_SCRIPT'" 2>&1)
missing_rc=$?
set -e
[ "$missing_rc" -ne 0 ] || log_error "Expected missing LiteLLM secrets to fail preflight."
echo "$missing_output" | grep -q 'make litellm-bootstrap'

# Invalid hostname should fail.
set +e
invalid_host_output=$(run_in_clean_cwd "COMPOSE_PROFILES=litellm TRAEFIK_DASHBOARD=false LITELLM_MASTER_KEY=sk-test LITELLM_SALT_KEY=sk-test LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/litellm-ui.guardrail-test.htpasswd LITELLM_LOCAL_API_BASE=http://host.docker.internal:11434 LITELLM_HOSTNAME='Bad_Host' '$VALIDATE_SCRIPT'" 2>&1)
invalid_host_rc=$?
set -e
[ "$invalid_host_rc" -ne 0 ] || log_error "Expected invalid LITELLM_HOSTNAME to fail preflight."
echo "$invalid_host_output" | grep -q 'LITELLM_HOSTNAME'

# Invalid UI hostname should fail.
set +e
invalid_ui_host_output=$(run_in_clean_cwd "COMPOSE_PROFILES=litellm TRAEFIK_DASHBOARD=false LITELLM_HOSTNAME=llm LITELLM_UI_HOSTNAME='Bad_Host' LITELLM_MASTER_KEY=sk-test123 LITELLM_SALT_KEY=sk-salt123 LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/litellm-ui.guardrail-test.htpasswd LITELLM_LOCAL_API_BASE=http://host.docker.internal:11434 '$VALIDATE_SCRIPT'" 2>&1)
invalid_ui_host_rc=$?
set -e
[ "$invalid_ui_host_rc" -ne 0 ] || log_error "Expected invalid LITELLM_UI_HOSTNAME to fail preflight."
echo "$invalid_ui_host_output" | grep -q 'LITELLM_UI_HOSTNAME'

# Missing LiteLLM UI auth file should fail.
set +e
missing_ui_auth_output=$(run_in_clean_cwd "COMPOSE_PROFILES=litellm TRAEFIK_DASHBOARD=false LITELLM_HOSTNAME=llm LITELLM_UI_HOSTNAME=llm-admin LITELLM_MASTER_KEY=sk-test123 LITELLM_SALT_KEY=sk-salt123 LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/does-not-exist.htpasswd LITELLM_LOCAL_API_BASE=http://host.docker.internal:11434 '$VALIDATE_SCRIPT'" 2>&1)
missing_ui_auth_rc=$?
set -e
[ "$missing_ui_auth_rc" -ne 0 ] || log_error "Expected missing LiteLLM UI htpasswd file to fail preflight."
echo "$missing_ui_auth_output" | grep -q 'LiteLLM UI'
echo "$missing_ui_auth_output" | grep -q 'htpasswd'

# Malformed local API base should fail.
set +e
invalid_local_url_output=$(run_in_clean_cwd "COMPOSE_PROFILES=litellm TRAEFIK_DASHBOARD=false LITELLM_HOSTNAME=llm LITELLM_UI_HOSTNAME=llm-admin LITELLM_MASTER_KEY=sk-test123 LITELLM_SALT_KEY=sk-salt123 LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/litellm-ui.guardrail-test.htpasswd LITELLM_LOCAL_API_BASE=not-a-url '$VALIDATE_SCRIPT'" 2>&1)
invalid_local_url_rc=$?
set -e
[ "$invalid_local_url_rc" -ne 0 ] || log_error "Expected malformed LITELLM_LOCAL_API_BASE to fail preflight."
echo "$invalid_local_url_output" | grep -q 'LITELLM_LOCAL_API_BASE'

# Valid minimal LiteLLM settings should pass without provider keys and without checking runtime local backend reachability.
run_in_clean_cwd "COMPOSE_PROFILES=litellm TRAEFIK_DASHBOARD=false LITELLM_HOSTNAME=llm LITELLM_UI_HOSTNAME=llm-admin LITELLM_MASTER_KEY=sk-test123 LITELLM_SALT_KEY=sk-salt123 LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/litellm-ui.guardrail-test.htpasswd LITELLM_LOCAL_API_BASE=http://host.docker.internal:11434 '$VALIDATE_SCRIPT'" >/dev/null

log_success "LiteLLM guardrails smoke test passed."
