#!/bin/bash
# File: scripts/traefik-render-dynamic.sh
#
# Render Traefik dynamic config templates using env values.
#
# Usage:
#   ./scripts/traefik-render-dynamic.sh
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

TEMPLATE_DIR="${REPO_ROOT}/traefik/dynamic"
OUTPUT_DIR="${REPO_ROOT}/traefik/dynamic-rendered"

if [ -f "${REPO_ROOT}/.env" ]; then
    # shellcheck disable=SC1091
    set -a
    . "${REPO_ROOT}/.env"
    set +a
elif [ -f "${REPO_ROOT}/.env.example" ]; then
    # shellcheck disable=SC1091
    set -a
    . "${REPO_ROOT}/.env.example"
    set +a
fi

if [ -z "${DEV_DOMAIN:-}" ]; then
    echo "ERROR: DEV_DOMAIN is not set. Update .env or .env.example." >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

for file in "$TEMPLATE_DIR"/*.yml; do
    filename=$(basename "$file")
    sed "s/__DEV_DOMAIN__/${DEV_DOMAIN}/g" "$file" > "${OUTPUT_DIR}/${filename}"
done
