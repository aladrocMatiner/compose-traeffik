# File: scripts/logs.sh
#
# Shows real-time logs for the Docker Compose stack.
#
# Usage: ./scripts/logs.sh
#
# Arguments are passed directly to `docker compose logs`.
# Example: ./scripts/logs.sh traefik
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env

log_info "Checking for docker and docker compose..."
check_command "docker"
check_command "docker compose"

log_info "Showing logs for Docker Compose stack..."
# Ensure COMPOSE_PROFILES_ARG is respected from Makefile or env
DOCKER_COMPOSE_COMMAND="docker compose --env-file .env ${COMPOSE_PROFILES_ARG:-} logs -f"
log_info "Executing: ${DOCKER_COMPOSE_COMMAND} $*"
eval "${DOCKER_COMPOSE_COMMAND} $*"