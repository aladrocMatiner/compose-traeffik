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

if [ -z "${AWX_BACKUP_NAME}" ] && [ -z "${AWX_BACKUP_SOURCE}" ]; then
    log_error "Provide --backup-name <awxbackup-cr> or --from <local-backup-metadata-dir>"
fi

if [ -n "${AWX_BACKUP_SOURCE}" ]; then
    case "${AWX_BACKUP_SOURCE}" in
        /*) ;;
        *) AWX_BACKUP_SOURCE="${REPO_ROOT}/${AWX_BACKUP_SOURCE}" ;;
    esac
    [ -d "${AWX_BACKUP_SOURCE}" ] || log_error "Backup metadata directory not found: ${AWX_BACKUP_SOURCE}"
    [ -f "${AWX_BACKUP_SOURCE}/awxbackup.status.yaml" ] || log_error "Missing awxbackup.status.yaml in ${AWX_BACKUP_SOURCE}"
    if [ -z "${AWX_BACKUP_NAME}" ]; then
        AWX_BACKUP_NAME=$(awk '/^  name: / {print $2; exit}' "${AWX_BACKUP_SOURCE}/awxbackup.status.yaml")
    fi
fi

[ -n "${AWX_BACKUP_NAME}" ] || log_error "Could not resolve AWX backup name"
AWX_TARGET_DEPLOYMENT_NAME="${AWX_TARGET_DEPLOYMENT_NAME:-${AWX_INSTANCE_NAME}-restore}"
awx_validate_hostname_label "$(printf '%s' "${AWX_TARGET_DEPLOYMENT_NAME}" | tr '[:upper:]' '[:lower:]' | cut -d- -f1)" >/dev/null 2>&1 || true

if [ "${AWX_TARGET_DEPLOYMENT_NAME}" = "${AWX_INSTANCE_NAME}" ]; then
    awx_require_confirm "Restore target matches live deployment (${AWX_INSTANCE_NAME}) and may be destructive."
else
    awx_require_confirm "AWX restore will create/update deployment '${AWX_TARGET_DEPLOYMENT_NAME}' from backup '${AWX_BACKUP_NAME}'."
fi

awx_require_command kubectl
awx_ensure_context

stamp=$(awx_now_utc)
restore_cr="${AWX_TARGET_DEPLOYMENT_NAME}-restore-${stamp,,}"
artifact_dir="${AWX_BACKUP_LOCAL_DIR}/${restore_cr}"
mkdir -p "${artifact_dir}"

cat > "${artifact_dir}/awxrestore.yaml" <<EOF
apiVersion: awx.ansible.com/v1beta1
kind: AWXRestore
metadata:
  name: ${restore_cr}
  namespace: ${AWX_NAMESPACE}
spec:
  backup_name: ${AWX_BACKUP_NAME}
  backup_source: "Backup CR"
  deployment_name: ${AWX_TARGET_DEPLOYMENT_NAME}
EOF

log_info "Applying AWXRestore CR '${restore_cr}' (target deployment: ${AWX_TARGET_DEPLOYMENT_NAME})"
awx_kubectl apply -f "${artifact_dir}/awxrestore.yaml"

log_info "Waiting for AWXRestore completion..."
awx_restore_wait_complete "${restore_cr}"
awx_kubectl -n "${AWX_NAMESPACE}" get awxrestore "${restore_cr}" -o yaml > "${artifact_dir}/awxrestore.status.yaml"

cat > "${artifact_dir}/RESTORE-METADATA.txt" <<EOF
AWX restore metadata
Generated: ${stamp}
Namespace: ${AWX_NAMESPACE}
Backup source (AWXBackup CR): ${AWX_BACKUP_NAME}
Restore CR: ${restore_cr}
Target deployment: ${AWX_TARGET_DEPLOYMENT_NAME}

Post-restore checks:
- kubectl get pods -n ${AWX_NAMESPACE}
- Verify restored AWX web/task pods become Running
- Access restored AWX via the configured exposure path (NodePort/Traefik if routed)
EOF

log_success "AWX restore completed: ${restore_cr} (target: ${AWX_TARGET_DEPLOYMENT_NAME})"
log_success "Local restore metadata bundle: ${artifact_dir}"
