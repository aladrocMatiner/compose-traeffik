#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/awx-common.sh
. "${SCRIPT_DIR}/awx-common.sh"

awx_parse_common_args "$@"
awx_load_env
awx_defaults
awx_require_command kubectl
awx_ensure_context

log_info "Context: $(KUBECONFIG="$AWX_KUBECONFIG_PATH" kubectl config current-context)"
echo
awx_kubectl get ns "$AWX_NAMESPACE" "$AWX_OPERATOR_NAMESPACE" 2>/dev/null || true
echo
awx_kubectl -n "$AWX_OPERATOR_NAMESPACE" get pods 2>/dev/null || true
echo
awx_kubectl -n "$AWX_NAMESPACE" get awx,pods,svc 2>/dev/null || true
