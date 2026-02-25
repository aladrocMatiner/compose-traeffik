#!/bin/bash
# Smoke test: Validate GitLab observability hooks and secure defaults.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

COMPOSE_FILE="$SCRIPT_DIR/../../services/gitlab/compose.yml"
[ -f "$COMPOSE_FILE" ] || log_error "GitLab compose fragment not found."

# No telemetry/exporter host ports by default.
if grep -Eq ':[0-9]+:(9090|9187|9168|9236|8081)($|/)' "$COMPOSE_FILE"; then
    log_error "Unexpected exporter/telemetry host port published in GitLab compose file."
fi

# No Traefik telemetry routers by default.
if grep -Eq 'traefik\.http\.routers\..*(metrics|monitor)' "$COMPOSE_FILE"; then
    log_error "Unexpected telemetry router label found in GitLab compose file."
fi

grep -Fq 'com.compose-traeffik.observability.enabled=${GITLAB_OBSERVABILITY_ENABLED:-false}' "$COMPOSE_FILE"
grep -Fq 'com.compose-traeffik.observability.health=/-/health' "$COMPOSE_FILE"
grep -Fq 'com.compose-traeffik.observability.metrics=internal-only' "$COMPOSE_FILE"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
ENV_FILE="$TMPDIR/test.env"
OUT_FILE="$TMPDIR/gitlab.rb"

cat > "$ENV_FILE" <<'EOF'
DEV_DOMAIN=local.test
GITLAB_HOSTNAME=gitlab
GITLAB_SSH_HOST_PORT=2424
GITLAB_ROOT_PASSWORD=testpassword123
GITLAB_OIDC_ENABLED=false
GITLAB_OBSERVABILITY_ENABLED=false
EOF

"$SCRIPT_DIR/../../scripts/gitlab-render-config.sh" --env-file "$ENV_FILE" --output-file "$OUT_FILE" >/dev/null
grep -Fq "prometheus_monitoring['enable'] = false" "$OUT_FILE"

cat > "$ENV_FILE" <<'EOF'
DEV_DOMAIN=local.test
GITLAB_HOSTNAME=gitlab
GITLAB_SSH_HOST_PORT=2424
GITLAB_ROOT_PASSWORD=testpassword123
GITLAB_OIDC_ENABLED=false
GITLAB_OBSERVABILITY_ENABLED=true
EOF

"$SCRIPT_DIR/../../scripts/gitlab-render-config.sh" --env-file "$ENV_FILE" --output-file "$OUT_FILE" >/dev/null
if grep -Fq "prometheus_monitoring['enable'] = false" "$OUT_FILE"; then
    log_error "Observability-enabled config should not force-disable Prometheus."
fi

log_success "GitLab observability wiring test passed."
