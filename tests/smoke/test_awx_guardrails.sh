#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
TMP_ENV=$(mktemp)
trap 'rm -f "$TMP_ENV"' EXIT
cp "$SCRIPT_DIR/../../.env.example" "$TMP_ENV"

set_tmp_env() {
  local key="$1" value="$2"
  awk -v k="$key" -v v="$value" '
    BEGIN { found=0 }
    $0 ~ "^"k"=" { print k"="v; found=1; next }
    { print }
    END { if (!found) print k"="v }
  ' "$TMP_ENV" > "${TMP_ENV}.tmp" && mv "${TMP_ENV}.tmp" "$TMP_ENV"
}

log_info "Checking AWX validation rejects placeholder secrets..."
set_tmp_env AWX_ADMIN_PASSWORD change-me
set_tmp_env AWX_SECRET_KEY example
if "$SCRIPT_DIR/../../scripts/validate-awx-env.sh" --env-file "$TMP_ENV" >/dev/null 2>&1; then
  log_error "Expected validate-awx-env to fail on placeholder secrets."
fi

log_info "Checking AWX validation rejects invalid NodePort..."
set_tmp_env AWX_ADMIN_PASSWORD Abc123safe
set_tmp_env AWX_SECRET_KEY Abc123SafeSecretKey
set_tmp_env AWX_NODEPORT_HTTP 29999
if "$SCRIPT_DIR/../../scripts/validate-awx-env.sh" --env-file "$TMP_ENV" >/dev/null 2>&1; then
  log_error "Expected validate-awx-env to fail on invalid AWX_NODEPORT_HTTP."
fi

log_info "Checking AWX validation passes with valid values..."
set_tmp_env AWX_ADMIN_PASSWORD Abc123safe
set_tmp_env AWX_SECRET_KEY Abc123SafeSecretKey123
set_tmp_env AWX_NODEPORT_HTTP 30080
set_tmp_env AWX_HOST_PORT_HTTP 30080
"$SCRIPT_DIR/../../scripts/validate-awx-env.sh" --env-file "$TMP_ENV" >/dev/null

log_success "AWX guardrails test passed."
