#!/bin/bash
# File: tests/smoke/test_litellm_service_config.sh
#
# Smoke test: Validate LiteLLM service configuration in services/litellm/compose.yml.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/litellm/compose.yml"
MIDDLEWARE_FILE="$SCRIPT_DIR/../../services/traefik/dynamic/middlewares.yml"

[ -f "$COMPOSE_FILE" ] || log_error "LiteLLM compose fragment not found."
[ -f "$MIDDLEWARE_FILE" ] || log_error "Traefik middleware template not found."

grep -q '^  litellm:' "$COMPOSE_FILE" || log_error "litellm service not found in compose fragment."

grep -Fq 'profiles:' "$COMPOSE_FILE"
grep -Eq '^[[:space:]]*- litellm' "$COMPOSE_FILE"
grep -Fq 'Host(`${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'Host(`${LITELLM_UI_HOSTNAME:-llm-admin}.${DEV_DOMAIN}`)' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.litellm-websecure.middlewares=${LITELLM_MIDDLEWARES:-security-headers@file}' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.litellm-admin-websecure.middlewares=${LITELLM_UI_MIDDLEWARES:-security-headers@file,litellm-ui-auth@file}' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.litellm-websecure.tls.certresolver=${TLS_CERT_RESOLVER:-}' "$COMPOSE_FILE"
grep -Fq 'traefik.http.routers.litellm-admin-websecure.tls.certresolver=${TLS_CERT_RESOLVER:-}' "$COMPOSE_FILE"
grep -Fq 'traefik.http.services.litellm-service.loadbalancer.server.port=${LITELLM_PORT:-4000}' "$COMPOSE_FILE"
grep -Fq './services/litellm/config.yaml:/app/config.yaml:ro' "$COMPOSE_FILE"
grep -Fq 'host.docker.internal:host-gateway' "$COMPOSE_FILE"
grep -Fq 'LITELLM_MASTER_KEY=${LITELLM_MASTER_KEY}' "$COMPOSE_FILE"
grep -Fq 'LITELLM_SALT_KEY=${LITELLM_SALT_KEY}' "$COMPOSE_FILE"
grep -Fq 'LITELLM_LOCAL_API_BASE=${LITELLM_LOCAL_API_BASE:-http://host.docker.internal:11434}' "$COMPOSE_FILE"
grep -q 'litellm-ui-auth:' "$MIDDLEWARE_FILE"
grep -q 'usersFile: __LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH__' "$MIDDLEWARE_FILE"

# Ensure no direct host port publish exists for LiteLLM.
if awk '
  $0 ~ /^  litellm:/ {in_block=1; next}
  in_block && $0 ~ /^  [a-zA-Z0-9_-]+:/ {exit}
  in_block {print}
' "$COMPOSE_FILE" | grep -q '^[[:space:]]*ports:'; then
  log_error "LiteLLM service should not publish ports directly on the host."
fi

log_success "LiteLLM service configuration test passed."
