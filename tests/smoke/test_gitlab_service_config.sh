#!/bin/bash
# Smoke test: Validate GitLab service compose fragment and Traefik wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/gitlab/compose.yml"

[ -f "$COMPOSE_FILE" ] || log_error "GitLab compose fragment not found."

grep -q "^  gitlab:" "$COMPOSE_FILE" || log_error "gitlab service not found."
grep -q "profiles:" "$COMPOSE_FILE"
grep -Eq "^[[:space:]]*- gitlab$" "$COMPOSE_FILE"

grep -Fq "gitlab/gitlab-ee" "$COMPOSE_FILE"
grep -Fq "18.8.2-ee.0" "$COMPOSE_FILE"
grep -Fq "shm_size: \${GITLAB_SHM_SIZE:-256m}" "$COMPOSE_FILE"
grep -Fq "\${GITLAB_SSH_BIND_ADDRESS:-0.0.0.0}:\${GITLAB_SSH_HOST_PORT:-2424}:22" "$COMPOSE_FILE"

# Ensure no direct HTTP/HTTPS host publishes.
if grep -Eq ':[0-9]+:80($|/)|:[0-9]+:443($|/)' "$COMPOSE_FILE"; then
    log_error "GitLab compose file should not publish HTTP/HTTPS ports directly."
fi

# Traefik routing labels.
grep -Fq 'traefik.http.routers.gitlab-websecure.rule=Host(`${GITLAB_HOSTNAME:-gitlab}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.gitlab-service.loadbalancer.server.port=80' "$COMPOSE_FILE"
grep -Fq 'security-headers@file' "$COMPOSE_FILE"

# Rendered config + data mounts.
grep -Fq './services/gitlab/rendered:/etc/gitlab' "$COMPOSE_FILE"
grep -Fq 'gitlab-logs:/var/log/gitlab' "$COMPOSE_FILE"
grep -Fq 'gitlab-data:/var/opt/gitlab' "$COMPOSE_FILE"

log_success "GitLab service configuration test passed."
