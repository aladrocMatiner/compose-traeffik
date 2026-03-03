#!/bin/bash
# Smoke test: Validate FreeIPA optional integration contract behavior.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/freeipa/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "FreeIPA compose fragment not found."

grep -Fq 'FREEIPA_KEYCLOAK_ENABLED=${FREEIPA_KEYCLOAK_ENABLED:-false}' "$COMPOSE_FILE" || log_error "FreeIPA compose must expose Keycloak toggle env."
grep -Fq 'FREEIPA_OBSERVABILITY_ENABLED=${FREEIPA_OBSERVABILITY_ENABLED:-false}' "$COMPOSE_FILE" || log_error "FreeIPA compose must expose observability toggle env."
grep -Fq 'FREEIPA_TLS_MODE=${FREEIPA_TLS_MODE:-stepca-acme}' "$COMPOSE_FILE" || log_error "FreeIPA compose must expose TLS mode env."

log_info "Checking optional integrations disabled mode passes..."
if ! COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected FreeIPA with optional integrations disabled."
fi

log_info "Checking Keycloak enabled mode requires complete external contract..."
if COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=true FREEIPA_KEYCLOAK_MODE=external FREEIPA_OBSERVABILITY_ENABLED=false \
    FREEIPA_TRAEFIK_MIDDLEWARES=security-headers@file \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted Keycloak enabled with incomplete contract."
fi

log_info "Checking Keycloak external mode passes with complete values..."
if ! COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=true FREEIPA_KEYCLOAK_MODE=external FREEIPA_OBSERVABILITY_ENABLED=false \
    FREEIPA_TRAEFIK_MIDDLEWARES=keycloak-forward-auth@file,security-headers@file \
    FREEIPA_KEYCLOAK_EXTERNAL_URL=https://keycloak.example.test \
    FREEIPA_KEYCLOAK_ISSUER=https://keycloak.example.test/realms/freeipa \
    FREEIPA_KEYCLOAK_CLIENT_ID=freeipa-client FREEIPA_KEYCLOAK_CLIENT_SECRET=super-secret \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid Keycloak external contract."
fi

log_info "Checking unsupported TLS mode fails..."
if COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=invalid FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted unsupported FREEIPA_TLS_MODE value."
fi

log_info "Checking StepCA TLS mode requires resolver contract..."
if COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=stepca-acme FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted stepca-acme mode without resolver contract."
fi

if ! COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false TLS_CERT_RESOLVER=stepca-resolver \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=stepca-acme FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=false \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid stepca-acme resolver contract."
fi

log_info "Checking observability enabled mode requires OTLP endpoint..."
if COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=true \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted observability enabled without OTLP endpoint."
fi

if ! COMPOSE_PROFILES=freeipa TRAEFIK_DASHBOARD=false \
    FREEIPA_HOSTNAME=freeipa FREEIPA_TLS_MODE=local-ca FREEIPA_ADMIN_PASSWORD=a123 FREEIPA_DM_PASSWORD=b123 \
    FREEIPA_KEYCLOAK_ENABLED=false FREEIPA_OBSERVABILITY_ENABLED=true \
    FREEIPA_OTEL_EXPORTER_OTLP_ENDPOINT=http://alloy:4317 \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid observability contract."
fi

log_success "FreeIPA optional integrations test passed."
