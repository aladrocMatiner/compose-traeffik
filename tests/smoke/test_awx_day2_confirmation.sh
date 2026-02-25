#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

tmp_env=$(mktemp)
trap 'rm -f "$tmp_env"' EXIT

cat > "$tmp_env" <<'EOF'
DEV_DOMAIN=local.test
AWX_HOSTNAME=awx
AWX_NAMESPACE=awx
AWX_INSTANCE_NAME=awx
AWX_K3D_CLUSTER_NAME=awx
AWX_KUBECONFIG_PATH=.local/kubeconfigs/awx-k3d.yaml
AWX_NODEPORT_HTTP=30080
AWX_HOST_PORT_HTTP=30080
AWX_ADMIN_USER=admin
AWX_ADMIN_PASSWORD=secret123
AWX_SECRET_KEY=secretkey123
AWX_OPERATOR_NAMESPACE=awx
AWX_OPERATOR_CHART_VERSION=3.2.0
AWX_OPERATOR_VERSION_TARGET=2.19.1
AWX_VERSION_TARGET=24.6.1
K3D_K3S_IMAGE=rancher/k3s:v1.31.5-k3s1
AWX_PROJECTS_PERSISTENCE=false
AWX_BACKUP_LOCAL_DIR=.local/awx/backups
AWX_DEBUG_LOCAL_DIR=.local/awx/debug
AWX_DAY2_WAIT_TIMEOUT=60
EOF

set +e
out_restore=$("$SCRIPT_DIR/../../scripts/awx-restore.sh" --env-file "$tmp_env" --backup-name dummy-backup 2>&1)
rc_restore=$?
out_upgrade=$("$SCRIPT_DIR/../../scripts/awx-upgrade.sh" --env-file "$tmp_env" 2>&1)
rc_upgrade=$?
set -e

[ "$rc_restore" -ne 0 ] || log_error "awx-restore.sh should require --confirm"
[ "$rc_upgrade" -ne 0 ] || log_error "awx-upgrade.sh should require --confirm"
printf '%s' "$out_restore" | grep -q -- '--confirm' || log_error "awx-restore.sh error should mention --confirm"
printf '%s' "$out_upgrade" | grep -q -- '--confirm' || log_error "awx-upgrade.sh error should mention --confirm"

log_success "AWX day-2 confirmation guardrails test passed."
