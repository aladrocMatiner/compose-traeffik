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
AWX_ENABLED_ENV="${AWX_ENABLED:-}"
AWX_HOSTNAME_ENV="${AWX_HOSTNAME:-}"
AWX_HOST_PORT_HTTP_ENV="${AWX_HOST_PORT_HTTP:-}"
LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH_ENV="${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH:-}"

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
if [ -n "${AWX_ENABLED_ENV}" ]; then
    AWX_ENABLED="${AWX_ENABLED_ENV}"
fi
if [ -n "${AWX_HOSTNAME_ENV}" ]; then
    AWX_HOSTNAME="${AWX_HOSTNAME_ENV}"
fi
if [ -n "${AWX_HOST_PORT_HTTP_ENV}" ]; then
    AWX_HOST_PORT_HTTP="${AWX_HOST_PORT_HTTP_ENV}"
fi
if [ -n "${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH_ENV}" ]; then
    LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH="${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH_ENV}"
fi

if [ -z "${DEV_DOMAIN:-}" ]; then
    echo "ERROR: DEV_DOMAIN is not set. Update .env or .env.example." >&2
    exit 1
fi

TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH="${TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH:-/etc/traefik/auth/traefik-dashboard.htpasswd.example}"
LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH="${LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH:-/etc/traefik/auth/litellm-ui.htpasswd.example}"
AWX_HOSTNAME="${AWX_HOSTNAME:-awx}"
AWX_HOST_PORT_HTTP="${AWX_HOST_PORT_HTTP:-30080}"

escape_sed() {
    printf '%s' "$1" | sed 's/[&/]/\\&/g'
}

dashboard_auth_path_escaped=$(escape_sed "$TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH")
litellm_ui_auth_path_escaped=$(escape_sed "$LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH")
awx_hostname_escaped=$(escape_sed "$AWX_HOSTNAME")
awx_host_port_http_escaped=$(escape_sed "$AWX_HOST_PORT_HTTP")

mkdir -p "$OUTPUT_DIR"

RENDER_CERTBOT_TLS=false
if [[ ",${COMPOSE_PROFILES:-}," == *",le,"* ]]; then
    RENDER_CERTBOT_TLS=true
fi

RENDER_DASHBOARD=true
if [ "${TRAEFIK_DASHBOARD:-true}" = "false" ]; then
    RENDER_DASHBOARD=false
fi

RENDER_AWX=false
if [ "${AWX_ENABLED:-false}" = "true" ]; then
    RENDER_AWX=true
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
    if [ "$filename" = "awx.yml" ] && [ "$RENDER_AWX" != "true" ]; then
        rm -f "${OUTPUT_DIR}/${filename}"
        continue
    fi
    sed \
        -e "s/__DEV_DOMAIN__/${DEV_DOMAIN}/g" \
        -e "s/__TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH__/${dashboard_auth_path_escaped}/g" \
        -e "s/__LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH__/${litellm_ui_auth_path_escaped}/g" \
        -e "s/__AWX_HOSTNAME__/${awx_hostname_escaped}/g" \
        -e "s/__AWX_HOST_PORT_HTTP__/${awx_host_port_http_escaped}/g" \
        "$file" > "${OUTPUT_DIR}/${filename}"
done
