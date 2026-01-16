# File: scripts/down.sh
#
# Stops and removes the Docker Compose stack.
#
# Usage: ./scripts/down.sh
#
# Arguments are passed directly to `docker compose down`.
# Example: ./scripts/down.sh --volumes
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env

log_info "Checking for docker and docker compose..."
check_docker_compose

log_info "Stopping and removing Docker Compose stack..."
log_info "Executing layered compose teardown..."
./scripts/compose.sh down "$@"

log_success "Docker Compose stack stopped and removed."
