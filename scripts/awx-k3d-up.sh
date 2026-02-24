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
awx_require_command docker
awx_require_command k3d
awx_require_command kubectl

if k3d cluster list | awk '{print $1}' | grep -qx "$AWX_K3D_CLUSTER_NAME"; then
    log_info "k3d cluster '${AWX_K3D_CLUSTER_NAME}' already exists."
else
    if command -v ss >/dev/null 2>&1; then
        if ss -ltn "( sport = :${AWX_HOST_PORT_HTTP} )" 2>/dev/null | grep -q LISTEN; then
            log_error "Host port ${AWX_HOST_PORT_HTTP} is already in use. Free it or change AWX_HOST_PORT_HTTP."
        fi
    elif command -v lsof >/dev/null 2>&1; then
        if lsof -nP -iTCP:"${AWX_HOST_PORT_HTTP}" -sTCP:LISTEN >/dev/null 2>&1; then
            log_error "Host port ${AWX_HOST_PORT_HTTP} is already in use. Free it or change AWX_HOST_PORT_HTTP."
        fi
    fi

    log_info "Creating k3d cluster '${AWX_K3D_CLUSTER_NAME}'..."
    k3d cluster create "$AWX_K3D_CLUSTER_NAME" \
        --k3s-arg "--disable=traefik@server:0" \
        --image "$K3D_K3S_IMAGE" \
        --wait \
        --timeout 180s \
        -p "${AWX_HOST_PORT_HTTP}:${AWX_NODEPORT_HTTP}@server:0"
fi

k3d kubeconfig get "$AWX_K3D_CLUSTER_NAME" > "$AWX_KUBECONFIG_PATH"
chmod 600 "$AWX_KUBECONFIG_PATH"
awx_ensure_context
log_success "k3d cluster ready. KUBECONFIG=${AWX_KUBECONFIG_PATH}"
