#!/bin/bash
# File: scripts/logs.sh
#
# Shows real-time logs for the Docker Compose stack.
#
# Usage: ./scripts/logs.sh
#
# Arguments are passed directly to `docker compose logs`.
# Example: ./scripts/logs.sh traefik
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env

log_info "Checking for docker and docker compose..."
check_docker_compose

log_info "Showing logs for Docker Compose stack..."
compose_args=()
service_args=()
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
            service_args+=("$1")
            shift
            ;;
    esac
done

log_info "Executing layered compose logs..."
cmd=(./scripts/compose.sh)
if [ "${#compose_args[@]}" -gt 0 ]; then
    cmd+=("${compose_args[@]}")
fi
cmd+=(logs -f)
if [ "${#service_args[@]}" -gt 0 ]; then
    cmd+=("${service_args[@]}")
fi
"${cmd[@]}"
