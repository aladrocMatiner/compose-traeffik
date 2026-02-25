#!/bin/bash
# Smoke test: Validate GitLab preflight guardrails.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command "bash"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

RENDERED_FILE="$TMPDIR/gitlab.rb"
printf '# test\n' > "$RENDERED_FILE"

BASE_ENV=(
    COMPOSE_PROFILES=gitlab
    TRAEFIK_DASHBOARD=false
    GITLAB_ROOT_PASSWORD=testpassword123
    GITLAB_RENDERED_CONFIG_PATH="$RENDERED_FILE"
    GITLAB_HOSTNAME=gitlab
    GITLAB_SSH_HOST_PORT=2424
)

log_info "Checking invalid SSH port is rejected..."
if env "${BASE_ENV[@]}" GITLAB_SSH_HOST_PORT=70000 \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted invalid GITLAB_SSH_HOST_PORT."
fi

log_info "Checking missing rendered gitlab.rb is rejected..."
if env COMPOSE_PROFILES=gitlab TRAEFIK_DASHBOARD=false GITLAB_ROOT_PASSWORD=testpassword123 \
    GITLAB_RENDERED_CONFIG_PATH="$TMPDIR/missing.rb" GITLAB_HOSTNAME=gitlab GITLAB_SSH_HOST_PORT=2424 \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted missing rendered GitLab config."
fi

log_info "Checking OIDC missing vars are rejected..."
if env "${BASE_ENV[@]}" GITLAB_OIDC_ENABLED=true \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted OIDC enabled without required vars."
fi

log_info "Checking OIDC issuer must be HTTPS..."
if env "${BASE_ENV[@]}" GITLAB_OIDC_ENABLED=true \
    GITLAB_OIDC_ISSUER=http://keycloak.local.test/realms/main \
    GITLAB_OIDC_CLIENT_ID=gitlab GITLAB_OIDC_CLIENT_SECRET=secret \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env accepted non-HTTPS GITLAB_OIDC_ISSUER."
fi

log_info "Checking valid OIDC config passes..."
if ! env "${BASE_ENV[@]}" GITLAB_OIDC_ENABLED=true \
    GITLAB_OIDC_ISSUER=https://keycloak.local.test/realms/main \
    GITLAB_OIDC_CLIENT_ID=gitlab GITLAB_OIDC_CLIENT_SECRET=secret \
    "$SCRIPT_DIR/../../scripts/validate-env.sh" >/dev/null 2>&1; then
    log_error "validate-env rejected valid OIDC configuration."
fi

log_success "GitLab guardrails test passed."
