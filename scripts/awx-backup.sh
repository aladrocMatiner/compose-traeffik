#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/awx-common.sh
. "${SCRIPT_DIR}/awx-common.sh"

awx_parse_common_args "$@"
awx_load_env
awx_ensure_repo_dirs
awx_defaults
awx_validate_env
awx_require_command kubectl

awx_ensure_context

stamp=$(awx_now_utc)
backup_cr="${AWX_BACKUP_NAME:-${AWX_INSTANCE_NAME}-backup-${stamp,,}}"
artifact_dir="${AWX_BACKUP_LOCAL_DIR}/${backup_cr}"
mkdir -p "${artifact_dir}"

log_info "Creating AWXBackup CR '${backup_cr}' in namespace '${AWX_NAMESPACE}'"

cat > "${artifact_dir}/awxbackup.yaml" <<EOF
apiVersion: awx.ansible.com/v1beta1
kind: AWXBackup
metadata:
  name: ${backup_cr}
  namespace: ${AWX_NAMESPACE}
spec:
  deployment_name: ${AWX_INSTANCE_NAME}
EOF

awx_kubectl apply -f "${artifact_dir}/awxbackup.yaml"

log_info "Waiting for AWXBackup status fields (backupClaim/backupDirectory)..."
backup_status=$(awx_backup_wait_complete "${backup_cr}")
backup_claim="${backup_status%;*}"
backup_dir="${backup_status#*;}"

awx_kubectl -n "${AWX_NAMESPACE}" get awxbackup "${backup_cr}" -o yaml > "${artifact_dir}/awxbackup.status.yaml"
awx_kubectl -n "${AWX_NAMESPACE}" get awx "${AWX_INSTANCE_NAME}" -o yaml > "${artifact_dir}/awx.yaml" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" get secret "${AWX_ADMIN_PASSWORD_SECRET_NAME}" -o yaml > "${artifact_dir}/awx-admin-password.secret.yaml" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" get secret "${AWX_SECRET_KEY_SECRET_NAME}" -o yaml > "${artifact_dir}/awx-secret-key.secret.yaml" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" get secret "${AWX_INSTANCE_NAME}-postgres-configuration" -o yaml > "${artifact_dir}/awx-postgres-configuration.secret.yaml" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" get pods,svc,job -o wide > "${artifact_dir}/cluster-snapshot.txt" 2>/dev/null || true

cat > "${artifact_dir}/BACKUP-METADATA.txt" <<EOF
AWX backup metadata bundle (operator-managed backup)
Generated: ${stamp}
Namespace: ${AWX_NAMESPACE}
Instance: ${AWX_INSTANCE_NAME}
AWXBackup CR: ${backup_cr}
Backup PVC claim (operator-managed): ${backup_claim}
Backup directory on PVC: ${backup_dir}
Kubeconfig: ${AWX_KUBECONFIG_PATH}

Coverage:
- Operator-managed AWXBackup payload stored in-cluster on the backup PVC above
- Local metadata bundle (this directory): AWXBackup CR/status, AWX CR, selected secret YAMLs, cluster snapshot

Not covered by local metadata bundle:
- Raw backup payload files copied out of the cluster (not exported by this script)
- Any external integrations outside Kubernetes (DNS, certs, external SCM, etc.)
- Extra PVC content beyond what operator backup captures
EOF

log_success "AWX backup created. CR=${backup_cr} PVC=${backup_claim} DIR=${backup_dir}"
log_success "Local metadata bundle: ${artifact_dir}"
