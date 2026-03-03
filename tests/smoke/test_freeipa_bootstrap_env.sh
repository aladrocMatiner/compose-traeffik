#!/bin/bash
# Smoke test: Validate FreeIPA bootstrap secret generation and idempotency.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
ENV_FILE="$TMPDIR/.env"
cp "$SCRIPT_DIR/../../.env.example" "$ENV_FILE"

"$SCRIPT_DIR/../../scripts/freeipa-bootstrap.sh" --env-file "$ENV_FILE" >/dev/null

for key in FREEIPA_ADMIN_PASSWORD FREEIPA_DM_PASSWORD; do
    value=$(grep -E "^${key}=" "$ENV_FILE" | tail -n1 | cut -d= -f2-)
    [ -n "$value" ] || log_error "${key} was not generated."
done

before=$(grep -E '^FREEIPA_ADMIN_PASSWORD=' "$ENV_FILE" | tail -n1)
"$SCRIPT_DIR/../../scripts/freeipa-bootstrap.sh" --env-file "$ENV_FILE" >/dev/null
after=$(grep -E '^FREEIPA_ADMIN_PASSWORD=' "$ENV_FILE" | tail -n1)
[ "$before" = "$after" ] || log_error "FreeIPA bootstrap should be idempotent without --force."

log_success "FreeIPA bootstrap env test passed."
