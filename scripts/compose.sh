#!/bin/bash
# File: scripts/compose.sh
# Wrapper around docker compose that always loads the layered compose files.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${REPO_ROOT}/.env"

run_preflight() {
  (
    cd "${REPO_ROOT}"
    "${SCRIPT_DIR}/validate-env.sh"
    "${SCRIPT_DIR}/traefik-render-static.sh"
    "${SCRIPT_DIR}/traefik-render-dynamic.sh"
  )
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

COMPOSE_FILES=(
  -f "${REPO_ROOT}/compose/base.yml"
)

append_compose_file_if_exists() {
  local compose_file="$1"
  if [ -f "${compose_file}" ]; then
    COMPOSE_FILES+=(-f "${compose_file}")
  fi
}

append_compose_file_if_exists "${REPO_ROOT}/services/traefik/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/whoami/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/dns-bind/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/certbot/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/keycloak/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/observability/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/wikijs/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/semaphoreui/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/rocketchat/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/gitlab/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/wg-easy/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/litellm/compose.yml"
append_compose_file_if_exists "${REPO_ROOT}/services/openwebui/compose.yml"

COMPOSE_INCLUDE_STEPCA="${COMPOSE_INCLUDE_STEPCA:-true}"
if [ "${COMPOSE_INCLUDE_STEPCA}" = "true" ]; then
  append_compose_file_if_exists "${REPO_ROOT}/services/step-ca/compose.yml"
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
