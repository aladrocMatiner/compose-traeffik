#!/bin/bash
# File: tests/smoke/test_wg_easy_service_config.sh
#
# Smoke test: Validate wg-easy compose service configuration and Traefik wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/wg-easy/compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "wg-easy compose file not found: $COMPOSE_FILE"
fi

check_command "grep"
check_command "awk"

for needle in \
    "profiles:" \
    "- wg" \
    "container_name: wg-easy" \
    '/dev/net/tun:/dev/net/tun' \
    'net.ipv4.ip_forward=1' \
    'WG_BIND_ADDRESS' \
    'WG_SERVER_PORT' \
    'traefik.enable=true' \
    'wg-easy-websecure' \
    'entrypoints=websecure' \
    'tls=true' \
    'tls.certresolver=${TLS_CERT_RESOLVER:-}' \
    'middlewares=${WG_UI_MIDDLEWARES:-security-headers@file}' \
    'loadbalancer.server.port=51821'; do
    if ! grep -Fq -- "$needle" "$COMPOSE_FILE"; then
        log_error "Missing expected wg-easy compose config: $needle"
    fi
done

if ! grep -Fq '51820/udp' "$COMPOSE_FILE"; then
    log_error "wg-easy compose should publish WireGuard UDP port 51820/udp."
fi

if grep -Eq '^[[:space:]]*-[[:space:]]*"?[0-9.]*:?[0-9]+:51821(/tcp)?"?' "$COMPOSE_FILE"; then
    log_error "wg-easy compose must not publish the UI TCP port to the host."
fi

if grep -q '^[[:space:]]*privileged:[[:space:]]*true' "$COMPOSE_FILE"; then
    log_error "wg-easy compose should not use privileged: true by default."
fi

if ! awk '
    /labels:/ {in_labels=1; next}
    in_labels && /^[^[:space:]-]/ {exit}
    in_labels && /wg-easy-websecure\.entrypoints=websecure/ {entry=1}
    in_labels && /wg-easy-websecure\.tls=true/ {tls=1}
    END { exit(entry && tls ? 0 : 1) }
' "$COMPOSE_FILE"; then
    log_error "wg-easy Traefik labels are missing expected websecure/tls wiring."
fi

log_success "wg-easy service config smoke test passed."
