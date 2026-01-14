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

COMPOSE_PROFILES_ARG="${1:-}" # Accept COMPOSE_PROFILES_ARG as the first argument, default to empty if not provided

log_info "Checking for docker and docker compose..."
check_command "docker"
check_command "docker compose"

log_info "Stopping and removing Docker Compose stack..."
DOCKER_COMPOSE_COMMAND="docker compose --env-file .env ${COMPOSE_PROFILES_ARG} down"
log_info "Executing: ${DOCKER_COMPOSE_COMMAND}"
eval "${DOCKER_COMPOSE_COMMAND}"

log_success "Docker Compose stack stopped and removed."
