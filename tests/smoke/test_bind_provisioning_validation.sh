#!/bin/bash
# File: tests/smoke/test_bind_provisioning_validation.sh
#
# Smoke test: Validate bind-provision rejects invalid domain/endpoint inputs.
#
# Usage: ./tests/smoke/test_bind_provisioning_validation.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command "mktemp"

TMP_ENV_DOMAIN=$(mktemp)
TMP_ENV_ENDPOINT=$(mktemp)
trap 'rm -f "$TMP_ENV_DOMAIN" "$TMP_ENV_ENDPOINT"' EXIT

cat > "$TMP_ENV_DOMAIN" << 'EOF'
BASE_DOMAIN=Bad.Domain
LOOPBACK_X=42
ENDPOINTS=whoami,traefik
EOF

cat > "$TMP_ENV_ENDPOINT" << 'EOF'
BASE_DOMAIN=secure.local.test
LOOPBACK_X=42
ENDPOINTS=whoami,bad_endpoint
EOF

if "$SCRIPT_DIR/../../scripts/bind-provision.sh" --env-file "$TMP_ENV_DOMAIN" --dry-run >/dev/null 2>&1; then
    log_error "bind-provision accepted an invalid BASE_DOMAIN."
fi

if "$SCRIPT_DIR/../../scripts/bind-provision.sh" --env-file "$TMP_ENV_ENDPOINT" --dry-run >/dev/null 2>&1; then
    log_error "bind-provision accepted an invalid ENDPOINT label."
fi

log_success "BIND provisioning validation test passed."
