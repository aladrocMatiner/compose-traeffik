#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command "bash"

log_info "Checking Keycloak guardrails reject placeholder secrets..."
if COMPOSE_PROFILES=keycloak TRAEFIK_DASHBOARD=false KEYCLOAK_HOSTNAME=keycloak KEYCLOAK_ADMIN_PASSWORD=changeme KEYCLOAK_DB_PASSWORD=changeme \
  "${SCRIPT_DIR}/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted placeholder Keycloak secrets."
fi

log_info "Checking Keycloak guardrails reject invalid proxy headers..."
if COMPOSE_PROFILES=keycloak TRAEFIK_DASHBOARD=false KEYCLOAK_HOSTNAME=keycloak KEYCLOAK_ADMIN_PASSWORD=s3cret KEYCLOAK_DB_PASSWORD=dbs3cret KEYCLOAK_PROXY_HEADERS=invalid \
  "${SCRIPT_DIR}/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted invalid KEYCLOAK_PROXY_HEADERS."
fi

log_info "Checking Keycloak guardrails reject public metrics exposure by default..."
if COMPOSE_PROFILES=keycloak TRAEFIK_DASHBOARD=false KEYCLOAK_HOSTNAME=keycloak KEYCLOAK_ADMIN_PASSWORD=s3cret KEYCLOAK_DB_PASSWORD=dbs3cret KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS=true \
  "${SCRIPT_DIR}/../../scripts/validate-env.sh" >/dev/null 2>&1; then
  log_error "validate-env accepted KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS=true."
fi

log_info "Checking Keycloak guardrails pass for valid config..."
COMPOSE_PROFILES=keycloak TRAEFIK_DASHBOARD=false KEYCLOAK_HOSTNAME=keycloak KEYCLOAK_ADMIN_PASSWORD=s3cret KEYCLOAK_DB_PASSWORD=dbs3cret KEYCLOAK_PROXY_HEADERS=xforwarded KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS=false \
  "${SCRIPT_DIR}/../../scripts/validate-env.sh" >/dev/null 2>&1 || log_error "validate-env rejected valid Keycloak config."

log_success "Keycloak guardrails test passed."
