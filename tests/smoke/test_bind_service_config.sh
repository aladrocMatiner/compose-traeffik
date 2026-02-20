#!/bin/bash
# File: tests/smoke/test_bind_service_config.sh
#
# Smoke test: Validate BIND service configuration in services/dns-bind/compose.yml.
#
# Usage: ./tests/smoke/test_bind_service_config.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/dns-bind/compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "BIND compose fragment not found."
fi

# Validate bind service and profile inside bind block
if ! grep -q "^  bind:" "$COMPOSE_FILE"; then
    log_error "bind service not found in services/dns-bind/compose.yml"
fi

bind_block=$(awk '
    $0 ~ /^  bind:/ { in_block=1 }
    in_block { print }
    in_block && $0 ~ /^  [a-zA-Z0-9_-]+:/ && $0 !~ /^  bind:/ { exit }
' "$COMPOSE_FILE")

echo "$bind_block" | grep -q "profiles:"
echo "$bind_block" | grep -Eq "^[[:space:]]*- bind"

echo "$bind_block" | grep -q "networks:"
echo "$bind_block" | grep -Eq "^[[:space:]]*- proxy"

# Validate localhost-only port 53 bindings
grep -Fq '${BIND_BIND_ADDRESS:-127.0.0.1}:53:53/udp' "$COMPOSE_FILE"
grep -Fq '${BIND_BIND_ADDRESS:-127.0.0.1}:53:53/tcp' "$COMPOSE_FILE"

# Validate container hardening
grep -Fq 'no-new-privileges:true' "$COMPOSE_FILE"
grep -Fq 'cap_drop:' "$COMPOSE_FILE"
grep -Fq 'cap_add:' "$COMPOSE_FILE"
grep -Fq 'NET_BIND_SERVICE' "$COMPOSE_FILE"
grep -Fq '/etc/bind:ro' "$COMPOSE_FILE"
grep -Fq '/etc/bind/zones:ro' "$COMPOSE_FILE"

# Validate pinned image tag
grep -Fq 'internetsystemsconsortium/bind9:9.20' "$COMPOSE_FILE"

# Validate config + zones mounts
grep -Fq './services/dns-bind/config:/etc/bind' "$COMPOSE_FILE"
grep -Fq './services/dns-bind/zones:/etc/bind/zones' "$COMPOSE_FILE"

# Validate template rendering command
grep -Fq 'named.conf.template' "$COMPOSE_FILE"
grep -Fq 'named -g -c /tmp/named.conf' "$COMPOSE_FILE"
grep -Fq 'named-checkconf /tmp/named.conf' "$COMPOSE_FILE"
grep -Fq 'named-checkzone "${BASE_DOMAIN}" "/etc/bind/zones/db.${BASE_DOMAIN}"' "$COMPOSE_FILE"

log_success "BIND service configuration test passed."
