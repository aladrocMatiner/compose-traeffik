#!/bin/bash
# File: tests/smoke/test_bind_zone_generation.sh
#
# Smoke test: Validate BIND zone generation in dry-run mode.
#
# Usage: ./tests/smoke/test_bind_zone_generation.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command "mktemp"
check_command "awk"
check_command "grep"

TMP_ENV=$(mktemp)
trap 'rm -f "$TMP_ENV"' EXIT

cat > "$TMP_ENV" << 'EOF'
BASE_DOMAIN=bind-smoke.local.test
LOOPBACK_X=42
ENDPOINTS=whoami,traefik,bind,whoami,docs
EOF

ZONE_OUTPUT=$("$SCRIPT_DIR/../../scripts/bind-provision.sh" --env-file "$TMP_ENV" --dry-run)

echo "$ZONE_OUTPUT" | grep -q "ns1.bind-smoke.local.test."
echo "$ZONE_OUTPUT" | grep -Eq '^bind IN  A  127\.0\.42\.254$'
echo "$ZONE_OUTPUT" | grep -Eq '^whoami IN  A   127\.0\.42\.1$'
echo "$ZONE_OUTPUT" | grep -Eq '^traefik IN  A   127\.0\.42\.2$'
echo "$ZONE_OUTPUT" | grep -Eq '^docs IN  A   127\.0\.42\.3$'

# 'bind' from ENDPOINTS must be ignored and duplicates deduplicated.
if echo "$ZONE_OUTPUT" | grep -Eq '^bind IN  A   127\.0\.42\.[0-9]+$'; then
    log_error "Unexpected endpoint record for 'bind' found in generated zone."
fi
if [ "$(echo "$ZONE_OUTPUT" | grep -c '^whoami IN  A')" -ne 1 ]; then
    log_error "Duplicate endpoint records detected for 'whoami'."
fi

log_success "BIND zone generation dry-run test passed."
