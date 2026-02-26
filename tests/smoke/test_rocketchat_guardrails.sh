#!/bin/bash
# Smoke test: Validate Rocket.Chat preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command bash
check_command mktemp

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
RENDERED_FILE="$TMP_DIR/rocketchat.env"
printf 'ROOT_URL=https://rocketchat.local.test\n' > "$RENDERED_FILE"

log_info "Checking Rocket.Chat profile rejects missing rendered env..."
if COMPOSE_PROFILES=rocketchat TRAEFIK_DASHBOARD=false ROCKETCHAT_RENDERED_ENV_PATH="$TMP_DIR/missing.env" \
  "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted Rocket.Chat profile without rendered config file."
fi

log_info "Checking Rocket.Chat profile accepts valid rendered env path..."
if ! COMPOSE_PROFILES=rocketchat TRAEFIK_DASHBOARD=false ROCKETCHAT_RENDERED_ENV_PATH="$RENDERED_FILE" \
  "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env rejected Rocket.Chat profile with rendered config file present."
fi

log_info "Checking Keycloak issuer must be HTTPS..."
if COMPOSE_PROFILES=rocketchat TRAEFIK_DASHBOARD=false ROCKETCHAT_RENDERED_ENV_PATH="$RENDERED_FILE" \
  ROCKETCHAT_KEYCLOAK_ENABLED=true ROCKETCHAT_KEYCLOAK_ISSUER=http://keycloak.local/realms/dev \
  ROCKETCHAT_KEYCLOAK_CLIENT_ID=rocketchat ROCKETCHAT_KEYCLOAK_CLIENT_SECRET=secret \
  "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted non-HTTPS Rocket.Chat Keycloak issuer."
fi

log_info "Checking Keycloak required vars are enforced when enabled..."
if COMPOSE_PROFILES=rocketchat TRAEFIK_DASHBOARD=false ROCKETCHAT_RENDERED_ENV_PATH="$RENDERED_FILE" \
  ROCKETCHAT_KEYCLOAK_ENABLED=true ROCKETCHAT_KEYCLOAK_ISSUER=https://keycloak.local/realms/dev \
  ROCKETCHAT_KEYCLOAK_CLIENT_ID=rocketchat ROCKETCHAT_KEYCLOAK_CLIENT_SECRET=change-me \
  "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted placeholder Rocket.Chat Keycloak client secret."
fi

log_info "Checking observability metrics port validation..."
if COMPOSE_PROFILES=rocketchat TRAEFIK_DASHBOARD=false ROCKETCHAT_RENDERED_ENV_PATH="$RENDERED_FILE" \
  ROCKETCHAT_OBSERVABILITY_ENABLED=true ROCKETCHAT_METRICS_PORT=70000 \
  "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted invalid Rocket.Chat metrics port."
fi

log_info "Checking valid Keycloak + observability values pass..."
if ! COMPOSE_PROFILES=rocketchat TRAEFIK_DASHBOARD=false ROCKETCHAT_RENDERED_ENV_PATH="$RENDERED_FILE" \
  ROCKETCHAT_OBSERVABILITY_ENABLED=true ROCKETCHAT_METRICS_PORT=9458 \
  ROCKETCHAT_KEYCLOAK_ENABLED=true ROCKETCHAT_KEYCLOAK_ISSUER=https://keycloak.local/realms/dev \
  ROCKETCHAT_KEYCLOAK_CLIENT_ID=rocketchat ROCKETCHAT_KEYCLOAK_CLIENT_SECRET=secret \
  "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env rejected valid Rocket.Chat Keycloak/observability configuration."
fi

log_success "Rocket.Chat guardrails test passed."
