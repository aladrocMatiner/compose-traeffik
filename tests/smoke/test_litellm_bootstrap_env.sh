#!/bin/bash
# File: tests/smoke/test_litellm_bootstrap_env.sh
#
# Smoke test: Validate scripts/litellm-bootstrap.sh env generation, idempotency and force rotation.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

BOOTSTRAP_SCRIPT="$SCRIPT_DIR/../../scripts/litellm-bootstrap.sh"
TMP_DIR=$(mktemp -d)
ENV_FILE="$TMP_DIR/test.env"
HTPASSWD_FILE="$SCRIPT_DIR/../../services/traefik/auth/litellm-ui.bootstrap-test.htpasswd"
cleanup() { rm -rf "$TMP_DIR"; rm -f "$HTPASSWD_FILE"; }
trap cleanup EXIT

cat > "$ENV_FILE" <<'ENV'
PROJECT_NAME=compose-traeffik
LITELLM_HOSTNAME=llm
LITELLM_UI_HOSTNAME=llm-admin
LITELLM_MASTER_KEY=
LITELLM_SALT_KEY=
LITELLM_UI_BASIC_AUTH_USER=admin
LITELLM_UI_BASIC_AUTH_PASSWORD=
LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/litellm-ui.bootstrap-test.htpasswd
ENV

"$BOOTSTRAP_SCRIPT" --env-file "$ENV_FILE" >/dev/null

master1=$(grep '^LITELLM_MASTER_KEY=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
salt1=$(grep '^LITELLM_SALT_KEY=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
ui_pass1=$(grep '^LITELLM_UI_BASIC_AUTH_PASSWORD=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)

[[ "$master1" == sk-* ]] || log_error "Expected generated LITELLM_MASTER_KEY to start with sk-"
[[ "$salt1" == sk-* ]] || log_error "Expected generated LITELLM_SALT_KEY to start with sk-"
[ -n "$ui_pass1" ] || log_error "Expected generated LITELLM_UI_BASIC_AUTH_PASSWORD."
[ -f "$HTPASSWD_FILE" ] || log_error "Expected LiteLLM UI htpasswd file to be generated."
grep -q '^admin:' "$HTPASSWD_FILE" || log_error "Expected LiteLLM UI htpasswd file to contain admin entry."

"$BOOTSTRAP_SCRIPT" --env-file "$ENV_FILE" >/dev/null
master2=$(grep '^LITELLM_MASTER_KEY=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
salt2=$(grep '^LITELLM_SALT_KEY=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
ui_pass2=$(grep '^LITELLM_UI_BASIC_AUTH_PASSWORD=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
htpasswd_before=$(cat "$HTPASSWD_FILE")

[ "$master1" = "$master2" ] || log_error "LiteLLM bootstrap should be idempotent without --force (master key changed)."
[ "$salt1" = "$salt2" ] || log_error "LiteLLM bootstrap should be idempotent without --force (salt key changed)."
[ "$ui_pass1" = "$ui_pass2" ] || log_error "LiteLLM bootstrap should be idempotent without --force (UI password changed)."
[ "$htpasswd_before" = "$(cat "$HTPASSWD_FILE")" ] || log_error "LiteLLM UI htpasswd file should be preserved without --force."

"$BOOTSTRAP_SCRIPT" --env-file "$ENV_FILE" --force >/dev/null
master3=$(grep '^LITELLM_MASTER_KEY=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
salt3=$(grep '^LITELLM_SALT_KEY=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
ui_pass3=$(grep '^LITELLM_UI_BASIC_AUTH_PASSWORD=' "$ENV_FILE" | tail -n1 | cut -d= -f2-)
htpasswd_after=$(cat "$HTPASSWD_FILE")

[ "$master1" != "$master3" ] || log_error "Expected --force to rotate LITELLM_MASTER_KEY."
[ "$salt1" != "$salt3" ] || log_error "Expected --force to rotate LITELLM_SALT_KEY."
[ "$ui_pass1" != "$ui_pass3" ] || log_error "Expected --force to rotate LITELLM_UI_BASIC_AUTH_PASSWORD."
[ "$htpasswd_before" != "$htpasswd_after" ] || log_error "Expected --force to rotate LiteLLM UI htpasswd file."

log_success "LiteLLM bootstrap env smoke test passed."
