#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/awx-common.sh
. "${SCRIPT_DIR}/awx-common.sh"

awx_parse_common_args "$@"
awx_load_env
awx_defaults
awx_require_command k3d

if k3d cluster list | awk '{print $1}' | grep -qx "$AWX_K3D_CLUSTER_NAME"; then
    k3d cluster delete "$AWX_K3D_CLUSTER_NAME"
    log_success "Deleted k3d cluster ${AWX_K3D_CLUSTER_NAME}."
else
    log_warn "k3d cluster '${AWX_K3D_CLUSTER_NAME}' not found."
fi
