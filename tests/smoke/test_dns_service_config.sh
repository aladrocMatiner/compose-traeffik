#!/bin/bash
# File: tests/smoke/test_dns_service_config.sh
#
# Smoke test: Validate DNS service configuration in services/dns/compose.yml.
#
# Usage: ./tests/smoke/test_dns_service_config.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/dns/compose.yml"
MIDDLEWARE_FILE="$SCRIPT_DIR/../../services/traefik/dynamic/middlewares.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "DNS compose fragment not found."
fi

if [ ! -f "$MIDDLEWARE_FILE" ]; then
    log_error "traefik/dynamic/middlewares.yml not found."
fi

# Validate dns service and profile inside dns block
if ! grep -q "^  dns:" "$COMPOSE_FILE"; then
    log_error "dns service not found in services/dns/compose.yml"
fi

dns_block=$(awk '
    $0 ~ /^  dns:/ { in_block=1 }
    in_block { print }
    in_block && $0 ~ /^  [a-zA-Z0-9_-]+:/ && $0 !~ /^  dns:/ { exit }
' "$COMPOSE_FILE")

echo "$dns_block" | grep -q "profiles:"
echo "$dns_block" | grep -Eq "^[[:space:]]*- dns"

# Validate localhost-only port 53 bindings
grep -Fq '${DNS_BIND_ADDRESS:-127.0.0.1}:53:53/udp' "$COMPOSE_FILE"
grep -Fq '${DNS_BIND_ADDRESS:-127.0.0.1}:53:53/tcp' "$COMPOSE_FILE"

# Ensure DNS UI port is not published directly
if grep -n "5380:5380" "$COMPOSE_FILE"; then
    log_error "DNS UI port 5380 should not be published directly."
fi

# Validate Traefik router rule
grep -Fq 'Host(`dns.${BASE_DOMAIN}`)' "$COMPOSE_FILE"

# Validate BasicAuth middleware exists
grep -q "dns-ui-auth:" "$MIDDLEWARE_FILE"
grep -q "usersFile: __DNS_UI_BASIC_AUTH_HTPASSWD_PATH__" "$MIDDLEWARE_FILE"

log_success "DNS service configuration test passed."
