#!/bin/bash
# File: tests/smoke/test_dns_configure_ubuntu.sh
#
# Smoke test: Validate dns-configure-ubuntu.sh dry-run output.
#
# Usage: ./tests/smoke/test_dns_configure_ubuntu.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

load_env
check_env_var "BASE_DOMAIN"

TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

ENV_FILE="$TMP_DIR/env"
cat > "$ENV_FILE" << 'ENV'
BASE_DOMAIN=${BASE_DOMAIN}
ENV

SCRIPT_PATH="$SCRIPT_DIR/../../scripts/dns-configure-ubuntu.sh"

output=$("$SCRIPT_PATH" --env-file "$ENV_FILE" --dry-run apply)

echo "$output" | grep -q "resolvectl dns"
echo "$output" | grep -q "resolvectl domain"

echo "$output" | grep -Fq "~${BASE_DOMAIN}"

log_success "DNS configure Ubuntu dry-run output test passed."
