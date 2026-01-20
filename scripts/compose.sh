#!/bin/bash
# File: scripts/compose.sh
# Wrapper around docker compose that always loads the layered compose files.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${REPO_ROOT}/.env"

COMPOSE_FILES=(
  -f "${REPO_ROOT}/compose/base.yml"
  -f "${REPO_ROOT}/services/traefik/compose.yml"
  -f "${REPO_ROOT}/services/whoami/compose.yml"
  -f "${REPO_ROOT}/services/dns/compose.yml"
  -f "${REPO_ROOT}/services/certbot/compose.yml"
  -f "${REPO_ROOT}/services/step-ca/compose.yml"
)

run_preflight() {
  (cd "${REPO_ROOT}" && "${SCRIPT_DIR}/validate-env.sh")
}

run_preflight

if [ -f "${ENV_FILE}" ]; then
  set +u
  set -a
  # shellcheck disable=SC1090
  . "${ENV_FILE}"
  set +a
  set -u
fi

if [ -z "${ENV_FILE:-}" ]; then
  ENV_FILE="${REPO_ROOT}/.env"
fi

COMPOSE_PROJECT_NAME_VALUE="${COMPOSE_PROJECT_NAME:-}"
if [ -z "${COMPOSE_PROJECT_NAME_VALUE}" ]; then
  COMPOSE_PROJECT_NAME_VALUE="${PROJECT_NAME:-}"
fi
if [ -z "${COMPOSE_PROJECT_NAME_VALUE}" ]; then
  COMPOSE_PROJECT_NAME_VALUE="$(basename "${REPO_ROOT}")"
fi

COMPOSE_CMD=(docker compose --env-file "${ENV_FILE}" --project-directory "${REPO_ROOT}" --project-name "${COMPOSE_PROJECT_NAME_VALUE}" "${COMPOSE_FILES[@]}")

log() {
  echo "INFO: Executing: ${COMPOSE_CMD[*]} $*"
}

if [ $# -eq 0 ]; then
  log "running without arguments"
else
  log "$*"
fi

"${COMPOSE_CMD[@]}" "$@"
