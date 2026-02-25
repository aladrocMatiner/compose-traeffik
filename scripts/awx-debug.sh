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
bundle_dir="${AWX_DEBUG_LOCAL_DIR}/awx-debug-${stamp}"
mkdir -p "${bundle_dir}"

log_info "Writing AWX debug bundle to ${bundle_dir}"

awx_kubectl -n "${AWX_NAMESPACE}" get awx,awxbackup,awxrestore,deploy,sts,job,pods,svc,secret,configmap -o wide > "${bundle_dir}/resources.txt" 2>&1 || true
awx_kubectl -n "${AWX_NAMESPACE}" get awx "${AWX_INSTANCE_NAME}" -o yaml > "${bundle_dir}/awx-cr.yaml" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" describe awx "${AWX_INSTANCE_NAME}" > "${bundle_dir}/awx-cr.describe.txt" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" get events --sort-by=.metadata.creationTimestamp > "${bundle_dir}/events.txt" 2>/dev/null || true
awx_kubectl -n "${AWX_NAMESPACE}" get pods -o yaml > "${bundle_dir}/pods.yaml" 2>/dev/null || true

# Operator logs
operator_pod=$(awx_kubectl -n "${AWX_OPERATOR_NAMESPACE}" get pod -l control-plane=controller-manager -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -n "${operator_pod}" ]; then
    awx_kubectl -n "${AWX_OPERATOR_NAMESPACE}" logs "${operator_pod}" -c awx-manager --tail=300 > "${bundle_dir}/operator.log" 2>/dev/null || true
fi

# AWX pod logs (best effort)
web_pod=$(awx_kubectl -n "${AWX_NAMESPACE}" get pod -l app.kubernetes.io/name=awx,app.kubernetes.io/component=web -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
task_pod=$(awx_kubectl -n "${AWX_NAMESPACE}" get pod -l app.kubernetes.io/name=awx,app.kubernetes.io/component=task -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [ -n "${web_pod}" ]; then
    awx_kubectl -n "${AWX_NAMESPACE}" logs "${web_pod}" --all-containers --tail=300 > "${bundle_dir}/awx-web.log" 2>/dev/null || true
    awx_kubectl -n "${AWX_NAMESPACE}" describe pod "${web_pod}" > "${bundle_dir}/awx-web.describe.txt" 2>/dev/null || true
fi

if [ -n "${task_pod}" ]; then
    awx_kubectl -n "${AWX_NAMESPACE}" logs "${task_pod}" --all-containers --tail=300 > "${bundle_dir}/awx-task.log" 2>/dev/null || true
    awx_kubectl -n "${AWX_NAMESPACE}" describe pod "${task_pod}" > "${bundle_dir}/awx-task.describe.txt" 2>/dev/null || true
fi

cat > "${bundle_dir}/README.txt" <<EOF
AWX debug bundle
Generated: ${stamp}
Namespace: ${AWX_NAMESPACE}
Instance: ${AWX_INSTANCE_NAME}
Operator namespace: ${AWX_OPERATOR_NAMESPACE}
Kubeconfig: ${AWX_KUBECONFIG_PATH}

Contains cluster snapshots and recent logs only (no full backup payload).
Secrets are listed in resources snapshots but not individually exported here.
EOF

log_success "AWX debug bundle created: ${bundle_dir}"
