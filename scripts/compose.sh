#!/bin/bash
# File: scripts/compose.sh
# Wrapper around docker compose that always loads the layered compose files.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

COMPOSE_FILES=(
  -f "${REPO_ROOT}/compose/base.yml"
  -f "${REPO_ROOT}/services/traefik/compose.yml"
  -f "${REPO_ROOT}/services/whoami/compose.yml"
  -f "${REPO_ROOT}/services/dns/compose.yml"
  -f "${REPO_ROOT}/services/certbot/compose.yml"
  -f "${REPO_ROOT}/services/step-ca/compose.yml"
)

COMPOSE_CMD=(docker compose --env-file "${REPO_ROOT}/.env" "${COMPOSE_FILES[@]}")

log() {
  echo "INFO: Executing: ${COMPOSE_CMD[*]} $*"
}

if [ $# -eq 0 ]; then
  log "running without arguments"
else
  log "$*"
fi

"${COMPOSE_CMD[@]}" "$@"
