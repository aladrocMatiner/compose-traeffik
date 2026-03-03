#!/bin/bash
# File: scripts/traefik-render-static.sh
#
# Render Traefik static config placeholders using env values.
#
# Usage:
#   ./scripts/traefik-render-static.sh
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

TEMPLATE_FILE="${REPO_ROOT}/services/traefik/traefik.yml"
OUTPUT_FILE="${REPO_ROOT}/services/traefik/traefik-rendered.yml"

if [ -f "${REPO_ROOT}/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/.env"
    set +a
elif [ -f "${REPO_ROOT}/.env.example" ]; then
    set -a
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/.env.example"
    set +a
fi

: "${ACME_EMAIL:=}"
: "${LETSENCRYPT_CA_SERVER:=}"
: "${STEP_CA_CA_SERVER:=}"

escape_sed() {
    printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

acme_email_escaped=$(escape_sed "${ACME_EMAIL}")
le_ca_server_escaped=$(escape_sed "${LETSENCRYPT_CA_SERVER}")
stepca_ca_server_escaped=$(escape_sed "${STEP_CA_CA_SERVER}")

sed \
    -e "s|\${ACME_EMAIL}|${acme_email_escaped}|g" \
    -e "s|\${LETSENCRYPT_CA_SERVER}|${le_ca_server_escaped}|g" \
    -e "s|\${STEP_CA_CA_SERVER}|${stepca_ca_server_escaped}|g" \
    "${TEMPLATE_FILE}" > "${OUTPUT_FILE}"
