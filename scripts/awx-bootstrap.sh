#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/awx-common.sh
. "${SCRIPT_DIR}/awx-common.sh"

awx_parse_common_args "$@"
awx_load_env
awx_ensure_repo_dirs
awx_defaults

ensure_secret() {
    local key="$1" len="$2"
    local raw current
    raw=$(awx_get_env_value "$key")
    current=$(awx_trim_quotes "$raw")
    if [ -n "$current" ] && [ "$AWX_FORCE" != "true" ]; then
        log_info "Keeping existing ${key}."
        return
    fi
    awx_set_env_value "$key" "$(random_string_awx "$len")"
    if [ -n "$current" ] && [ "$AWX_FORCE" = "true" ]; then
        log_warn "Rotated ${key} due to --force."
    else
        log_info "Generated ${key}."
    fi
}

ensure_default() {
    local key="$1" value="$2"
    local raw current
    raw=$(awx_get_env_value "$key")
    current=$(awx_trim_quotes "$raw")
    if [ -z "$current" ]; then
        awx_set_env_value "$key" "$value"
        log_info "Set ${key} default."
    fi
}

ensure_default AWX_HOSTNAME "$AWX_HOSTNAME"
ensure_default AWX_NAMESPACE "$AWX_NAMESPACE"
ensure_default AWX_INSTANCE_NAME "$AWX_INSTANCE_NAME"
ensure_default AWX_ADMIN_USER "$AWX_ADMIN_USER"
ensure_default AWX_NODEPORT_HTTP "$AWX_NODEPORT_HTTP"
ensure_default AWX_HOST_PORT_HTTP "$AWX_HOST_PORT_HTTP"
ensure_default AWX_K3D_CLUSTER_NAME "$AWX_K3D_CLUSTER_NAME"
ensure_default AWX_KUBECONFIG_PATH "$AWX_KUBECONFIG_PATH"
ensure_default K3D_K3S_IMAGE "$K3D_K3S_IMAGE"
ensure_default AWX_OPERATOR_CHART_VERSION "$AWX_OPERATOR_CHART_VERSION"
ensure_default AWX_OPERATOR_VERSION_TARGET "$AWX_OPERATOR_VERSION_TARGET"
ensure_default AWX_VERSION_TARGET "$AWX_VERSION_TARGET"
ensure_default AWX_OPERATOR_HELM_REPO_NAME "$AWX_OPERATOR_HELM_REPO_NAME"
ensure_default AWX_OPERATOR_HELM_REPO_URL "$AWX_OPERATOR_HELM_REPO_URL"
ensure_default AWX_OPERATOR_RELEASE_NAME "$AWX_OPERATOR_RELEASE_NAME"
ensure_default AWX_OPERATOR_NAMESPACE "$AWX_OPERATOR_NAMESPACE"
ensure_default AWX_SECRET_KEY_SECRET_NAME "$AWX_SECRET_KEY_SECRET_NAME"
ensure_default AWX_ADMIN_PASSWORD_SECRET_NAME "$AWX_ADMIN_PASSWORD_SECRET_NAME"
ensure_default AWX_PROJECTS_PERSISTENCE "$AWX_PROJECTS_PERSISTENCE"
ensure_default AWX_ENABLED "true"

ensure_secret AWX_ADMIN_PASSWORD 32
ensure_secret AWX_SECRET_KEY 64

log_success "AWX bootstrap complete (${AWX_ENV_FILE})."
