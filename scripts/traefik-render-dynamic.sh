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

TEMPLATE_DIR="${REPO_ROOT}/services/traefik/dynamic"
OUTPUT_DIR="${REPO_ROOT}/services/traefik/dynamic-rendered"

COMPOSE_PROFILES_ENV="${COMPOSE_PROFILES:-}"
TRAEFIK_DASHBOARD_ENV="${TRAEFIK_DASHBOARD:-}"

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

if [ -n "${COMPOSE_PROFILES_ENV}" ]; then
    COMPOSE_PROFILES="${COMPOSE_PROFILES_ENV}"
fi
if [ -n "${TRAEFIK_DASHBOARD_ENV}" ]; then
    TRAEFIK_DASHBOARD="${TRAEFIK_DASHBOARD_ENV}"
fi

if [ -z "${DEV_DOMAIN:-}" ]; then
    echo "ERROR: DEV_DOMAIN is not set. Update .env or .env.example." >&2
    exit 1
fi

DNS_UI_BASIC_AUTH_HTPASSWD_PATH="${DNS_UI_BASIC_AUTH_HTPASSWD_PATH:-/etc/traefik/auth/dns-ui.htpasswd.example}"
TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH="${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH:-/etc/traefik/auth/traefik-dashboard.htpasswd.example}"

escape_sed() {
    printf '%s' "$1" | sed 's/[&/]/\\&/g'
}

dns_ui_auth_path_escaped=$(escape_sed "$DNS_UI_BASIC_AUTH_HTPASSWD_PATH")
dashboard_auth_path_escaped=$(escape_sed "$TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH")

mkdir -p "$OUTPUT_DIR"

RENDER_CERTBOT_TLS=false
if [[ ",${COMPOSE_PROFILES:-}," == *",le,"* ]]; then
    RENDER_CERTBOT_TLS=true
fi

RENDER_DASHBOARD=true
if [ "${TRAEFIK_DASHBOARD:-true}" = "false" ]; then
    RENDER_DASHBOARD=false
fi

for file in "$TEMPLATE_DIR"/*.yml; do
    filename=$(basename "$file")
    if [ "$filename" = "tls-certbot.yml" ] && [ "$RENDER_CERTBOT_TLS" != "true" ]; then
        rm -f "${OUTPUT_DIR}/${filename}"
        continue
    fi
    if [ "$filename" = "dashboard.yml" ] && [ "$RENDER_DASHBOARD" != "true" ]; then
        rm -f "${OUTPUT_DIR}/${filename}"
        continue
    fi
    sed \
        -e "s/__DEV_DOMAIN__/${DEV_DOMAIN}/g" \
        -e "s/__DNS_UI_BASIC_AUTH_HTPASSWD_PATH__/${dns_ui_auth_path_escaped}/g" \
        -e "s/__TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH__/${dashboard_auth_path_escaped}/g" \
        "$file" > "${OUTPUT_DIR}/${filename}"
done
