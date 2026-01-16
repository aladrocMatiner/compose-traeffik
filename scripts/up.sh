# File: scripts/up.sh
#
# Starts the Docker Compose stack.
#
# Usage: ./scripts/up.sh
#
# Arguments are passed directly to `docker compose up`.
# Example: ./scripts/up.sh -d --build
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env

log_info "Checking for docker and docker compose..."
check_docker_compose

log_info "Rendering Traefik dynamic config..."
"$SCRIPT_DIR/traefik-render-dynamic.sh"

log_info "Starting Docker Compose stack..."
log_info "Executing layered compose stack..."
./scripts/compose.sh up -d "$@"

log_success "Docker Compose stack started."
log_info "Run 'make logs' to view service logs."
log_info "Run 'make test' to verify the setup."
