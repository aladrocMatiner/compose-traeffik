#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

TRAEFIK_TEMPLATE="$SCRIPT_DIR/../../services/traefik/dynamic/awx.yml"
[ -f "$TRAEFIK_TEMPLATE" ] || log_error "Missing Traefik AWX template"

grep -q 'Host(`__AWX_HOSTNAME__.__DEV_DOMAIN__`)' "$TRAEFIK_TEMPLATE" || log_error "AWX Traefik template missing host rule placeholder"
grep -q 'host.docker.internal:__AWX_HOST_PORT_HTTP__' "$TRAEFIK_TEMPLATE" || log_error "AWX Traefik template missing host.docker.internal upstream placeholder"

grep -q 'host.docker.internal:host-gateway' "$SCRIPT_DIR/../../services/traefik/compose.yml" || log_error "Traefik compose missing host-gateway extra_hosts entry"

grep -q 'AWX_ENABLED' "$SCRIPT_DIR/../../scripts/traefik-render-dynamic.sh" || log_error "traefik-render-dynamic missing AWX gating support"

log_success "AWX Traefik routing config test passed."
