#!/bin/bash
# File: scripts/up.sh
#
# Starts the Docker Compose stack.
#
# Usage: ./scripts/up.sh
#
# Arguments are passed directly to `docker compose up`.
# Example: ./scripts/up.sh -d --build
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
./scripts/validate-env.sh

log_info "Checking for docker and docker compose..."
check_docker_compose

log_info "Rendering Traefik dynamic config..."
"$SCRIPT_DIR/traefik-render-dynamic.sh"

log_info "Starting Docker Compose stack..."
log_info "Executing layered compose stack..."
compose_args=()
up_args=()
while [ "$#" -gt 0 ]; do
    case "$1" in
        --profile)
            if [ -n "${2:-}" ]; then
                compose_args+=("$1" "$2")
                shift 2
            else
                log_error "Missing value for --profile."
            fi
            ;;
        *)
            up_args+=("$1")
            shift
            ;;
    esac
done

cmd=(./scripts/compose.sh)
if [ "${#compose_args[@]}" -gt 0 ]; then
    cmd+=("${compose_args[@]}")
fi
cmd+=(up -d)
if [ "${#up_args[@]}" -gt 0 ]; then
    cmd+=("${up_args[@]}")
fi
"${cmd[@]}"

log_success "Docker Compose stack started."
log_info "Run 'make logs' to view service logs."
log_info "Run 'make test' to verify the setup."
