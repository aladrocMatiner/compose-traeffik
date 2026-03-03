#!/bin/bash
# Smoke test: Validate Plane bootstrap secret generation and idempotency.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
ENV_FILE="$TMPDIR/.env"
cp "$SCRIPT_DIR/../../.env.example" "$ENV_FILE"

"$SCRIPT_DIR/../../scripts/plane-bootstrap.sh" --env-file "$ENV_FILE" >/dev/null

for key in PLANE_SECRET_KEY PLANE_LIVE_SERVER_SECRET_KEY PLANE_POSTGRES_PASSWORD PLANE_RABBITMQ_PASSWORD PLANE_AWS_SECRET_ACCESS_KEY PLANE_MACHINE_SIGNATURE; do
    value=$(grep -E "^${key}=" "$ENV_FILE" | tail -n1 | cut -d= -f2-)
    [ -n "$value" ] || log_error "${key} was not generated."
done

before=$(grep -E '^PLANE_SECRET_KEY=' "$ENV_FILE" | tail -n1)
"$SCRIPT_DIR/../../scripts/plane-bootstrap.sh" --env-file "$ENV_FILE" >/dev/null
after=$(grep -E '^PLANE_SECRET_KEY=' "$ENV_FILE" | tail -n1)
[ "$before" = "$after" ] || log_error "Plane bootstrap should be idempotent without --force."

log_success "Plane bootstrap env test passed."
