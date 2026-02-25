#!/bin/bash
# Smoke test: Validate Semaphore UI OIDC wiring in compose and bootstrap script.

set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
COMPOSE_FILE="$SCRIPT_DIR/../../services/semaphoreui/compose.yml"
BOOTSTRAP_SCRIPT="$SCRIPT_DIR/../../scripts/semaphoreui-bootstrap.sh"

[ -f "$COMPOSE_FILE" ] || log_error "Missing Semaphore UI compose file."
[ -f "$BOOTSTRAP_SCRIPT" ] || log_error "Missing Semaphore UI bootstrap script."

grep -Fq 'SEMAPHORE_OIDC_PROVIDERS=${SEMAPHOREUI_OIDC_PROVIDERS_JSON:-{}}' "$COMPOSE_FILE" || log_error "Compose file missing OIDC providers env mapping."
grep -Fq 'SEMAPHORE_PASSWORD_LOGIN_DISABLED=${SEMAPHOREUI_PASSWORD_LOGIN_DISABLED:-false}' "$COMPOSE_FILE" || log_error "Compose file missing password login toggle mapping."

grep -Eq 'SEMAPHOREUI_OIDC_(ENABLED|PROVIDER_URL|CLIENT_ID|CLIENT_SECRET)' "$BOOTSTRAP_SCRIPT" || log_error "Bootstrap script missing OIDC bootstrap variables."
grep -Fq 'SEMAPHOREUI_OIDC_PROVIDERS_JSON' "$BOOTSTRAP_SCRIPT" || log_error "Bootstrap script missing OIDC JSON output var."

echo "SUCCESS: Semaphore UI OIDC wiring test passed."
