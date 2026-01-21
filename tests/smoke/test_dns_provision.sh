#!/bin/bash
# File: tests/smoke/test_dns_provision.sh
#
# Smoke test: Validate dns-provision.sh dry-run output.
#
# Usage: ./tests/smoke/test_dns_provision.sh
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
LOOPBACK_X=10
ENDPOINTS=whoami,traefik
DNS_UI_HOSTNAME=dns
ENV

SCRIPT_PATH="$SCRIPT_DIR/../../scripts/dns-provision.sh"

output=$("$SCRIPT_PATH" --env-file "$ENV_FILE" --dry-run)

echo "$output" | grep -Fq "whoami.${BASE_DOMAIN} -> 127.0.10.1"
echo "$output" | grep -Fq "traefik.${BASE_DOMAIN} -> 127.0.10.2"
echo "$output" | grep -Fq "dns.${BASE_DOMAIN} -> 127.0.10.254"

log_success "DNS provision dry-run output test passed."
