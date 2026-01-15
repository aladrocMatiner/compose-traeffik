#!/bin/bash
# File: tests/smoke/test_hosts_subdomains.sh
#
# Smoke test: Ensures hosts-subdomains.sh can apply and remove a managed block
# without requiring sudo by using a temporary hosts file.
#
# Usage: ./tests/smoke/test_hosts_subdomains.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

ENV_FILE="$TMP_DIR/env"
HOSTS_FILE="$TMP_DIR/hosts"

cat > "$ENV_FILE" << 'ENV'
BASE_DOMAIN=local.test
LOOPBACK_X=10
ENDPOINTS=whoami,traefik
ENV

echo "127.0.0.1 localhost" > "$HOSTS_FILE"

SCRIPT_PATH="$SCRIPT_DIR/../../scripts/hosts-subdomains.sh"

log_info "Applying managed hosts block to temporary file..."
"$SCRIPT_PATH" --env-file "$ENV_FILE" --hosts-file "$HOSTS_FILE" apply

grep -q "# BEGIN edge-stack HOSTS" "$HOSTS_FILE"
grep -q "127.0.10.1 whoami.local.test" "$HOSTS_FILE"
grep -q "127.0.10.2 traefik.local.test" "$HOSTS_FILE"

log_info "Removing managed hosts block from temporary file..."
"$SCRIPT_PATH" --env-file "$ENV_FILE" --hosts-file "$HOSTS_FILE" remove

if grep -q "# BEGIN edge-stack HOSTS" "$HOSTS_FILE"; then
    log_error "Managed block was not removed from temporary hosts file."
fi

log_success "Hosts subdomain mapper apply/remove test passed."
