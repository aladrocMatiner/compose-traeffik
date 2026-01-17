#!/bin/bash
# File: scripts/down.sh
#
# Stops and removes the Docker Compose stack.
#
# Usage: ./scripts/down.sh
#
# Arguments are passed directly to `docker compose down`.
# Example: ./scripts/down.sh --volumes
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env

log_info "Checking for docker and docker compose..."
check_docker_compose

log_info "Stopping and removing Docker Compose stack..."
log_info "Executing layered compose teardown..."
compose_args=()
down_args=()
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
            down_args+=("$1")
            shift
            ;;
    esac
done

cmd=(./scripts/compose.sh)
if [ "${#compose_args[@]}" -gt 0 ]; then
    cmd+=("${compose_args[@]}")
fi
cmd+=(down)
if [ "${#down_args[@]}" -gt 0 ]; then
    cmd+=("${down_args[@]}")
fi
"${cmd[@]}"

log_success "Docker Compose stack stopped and removed."
