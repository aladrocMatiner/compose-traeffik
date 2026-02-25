#!/bin/bash
# Smoke test: Validate GitLab OIDC render wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

check_command "python3"
check_command "mktemp"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

ENV_FILE="$TMPDIR/test.env"
OUT_FILE="$TMPDIR/gitlab.rb"

cat > "$ENV_FILE" <<'EOF'
DEV_DOMAIN=local.test
GITLAB_HOSTNAME=gitlab
GITLAB_SSH_HOST_PORT=2424
GITLAB_ROOT_PASSWORD=testpassword123
GITLAB_ROOT_EMAIL=root@local.test
GITLAB_OIDC_ENABLED=false
GITLAB_OBSERVABILITY_ENABLED=false
EOF

"$SCRIPT_DIR/../../scripts/gitlab-render-config.sh" --env-file "$ENV_FILE" --output-file "$OUT_FILE" >/dev/null

grep -Fq "external_url 'https://gitlab.local.test'" "$OUT_FILE"
grep -Fq "gitlab_rails['gitlab_shell_ssh_port'] = 2424" "$OUT_FILE"
if grep -Fq "gitlab_rails['omniauth_enabled'] = true" "$OUT_FILE"; then
    log_error "OIDC block rendered while disabled."
fi

cat >> "$ENV_FILE" <<'EOF'
GITLAB_OIDC_ENABLED=true
GITLAB_OIDC_PROVIDER_NAME=Keycloak
GITLAB_OIDC_ISSUER=https://keycloak.local.test/realms/main
GITLAB_OIDC_CLIENT_ID=gitlab
GITLAB_OIDC_CLIENT_SECRET=supersecret
GITLAB_OIDC_SCOPES="openid profile email"
EOF

"$SCRIPT_DIR/../../scripts/gitlab-render-config.sh" --env-file "$ENV_FILE" --output-file "$OUT_FILE" >/dev/null

grep -Fq "gitlab_rails['omniauth_enabled'] = true" "$OUT_FILE"
grep -Fq "issuer: 'https://keycloak.local.test/realms/main'" "$OUT_FILE"
grep -Fq "/users/auth/openid_connect/callback" "$OUT_FILE"
grep -Fq "identifier: 'gitlab'" "$OUT_FILE"

log_success "GitLab OIDC render wiring test passed."
