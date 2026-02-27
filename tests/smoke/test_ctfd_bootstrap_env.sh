#!/bin/bash
# Smoke test: Validate CTFd bootstrap secret generation and idempotency.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
ENV_FILE="$TMPDIR/.env"
cp "$SCRIPT_DIR/../../.env.example" "$ENV_FILE"

"$SCRIPT_DIR/../../scripts/ctfd-bootstrap.sh" --env-file "$ENV_FILE" >/dev/null

for key in CTFD_SECRET_KEY CTFD_DB_PASSWORD CTFD_DB_ROOT_PASSWORD; do
    value=$(grep -E "^${key}=" "$ENV_FILE" | tail -n1 | cut -d= -f2-)
    [ -n "$value" ] || log_error "${key} was not generated."
done

before=$(grep -E '^CTFD_SECRET_KEY=' "$ENV_FILE" | tail -n1)
"$SCRIPT_DIR/../../scripts/ctfd-bootstrap.sh" --env-file "$ENV_FILE" >/dev/null
after=$(grep -E '^CTFD_SECRET_KEY=' "$ENV_FILE" | tail -n1)
[ "$before" = "$after" ] || log_error "CTFd bootstrap should be idempotent without --force."

log_success "CTFd bootstrap env test passed."
