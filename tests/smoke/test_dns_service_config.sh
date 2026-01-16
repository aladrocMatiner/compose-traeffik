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
if ! rg -q "^  dns:" "$COMPOSE_FILE"; then
    log_error "dns service not found in services/dns/compose.yml"
fi

dns_block=$(awk '
    $0 ~ /^  dns:/ { in_block=1 }
    in_block { print }
    in_block && $0 ~ /^  [a-zA-Z0-9_-]+:/ && $0 !~ /^  dns:/ { exit }
' "$COMPOSE_FILE")

echo "$dns_block" | rg -q "profiles:"
echo "$dns_block" | rg -q "^\\s+- dns"

# Validate localhost-only port 53 bindings
rg -Fq '${DNS_BIND_ADDRESS:-127.0.0.1}:53:53/udp' "$COMPOSE_FILE"
rg -Fq '${DNS_BIND_ADDRESS:-127.0.0.1}:53:53/tcp' "$COMPOSE_FILE"

# Ensure DNS UI port is not published directly
if rg -n "5380:5380" "$COMPOSE_FILE"; then
    log_error "DNS UI port 5380 should not be published directly."
fi

# Validate Traefik router rule
rg -Fq 'Host(`dns.${BASE_DOMAIN}`)' "$COMPOSE_FILE"

# Validate BasicAuth middleware exists
rg -q "dns-ui-auth:" "$MIDDLEWARE_FILE"
rg -q "usersFile: /etc/traefik/auth/dns-ui.htpasswd" "$MIDDLEWARE_FILE"

log_success "DNS service configuration test passed."
