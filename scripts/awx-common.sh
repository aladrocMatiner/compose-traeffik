#!/bin/bash
# Shared helpers for AWX + k3d lifecycle scripts.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

AWX_ENV_FILE="${REPO_ROOT}/.env"
AWX_FORCE=false

random_string_awx() {
    local length="${1:-48}"
    if command -v python3 >/dev/null 2>&1; then
        LENGTH="$length" python3 - <<'PY'
import os, secrets, string
alphabet = string.ascii_letters + string.digits
length = int(os.environ.get("LENGTH", "48"))
print("".join(secrets.choice(alphabet) for _ in range(length)))
PY
        return
    fi
    if command -v openssl >/dev/null 2>&1; then
        local out
        out=$(openssl rand -base64 96 | tr -dc 'A-Za-z0-9' | head -c "$length")
        [ "${#out}" -ge "$length" ] || log_error "Failed to generate random string with openssl."
        printf '%s' "$out"
        return
    fi
    log_error "Neither python3 nor openssl is available for secret generation."
}

awx_parse_common_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --env-file)
                [ -n "${2:-}" ] || log_error "Missing value for --env-file"
                AWX_ENV_FILE="$2"
                shift 2
                ;;
            --force)
                AWX_FORCE=true
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done
    AWX_REMAINING_ARGS=("$@")
}

awx_load_env() {
    case "${AWX_ENV_FILE}" in
        /*) ;;
        *) AWX_ENV_FILE="${REPO_ROOT}/${AWX_ENV_FILE}" ;;
    esac
    if [ ! -f "${AWX_ENV_FILE}" ]; then
        log_error "Env file not found: ${AWX_ENV_FILE}"
    fi
    set -a
    # shellcheck disable=SC1090
    . "${AWX_ENV_FILE}"
    set +a
}

awx_trim_quotes() {
    local val="$1"
    val="${val#\"}"
    val="${val%\"}"
    val="${val#\'}"
    val="${val%\'}"
    printf '%s' "$val"
}

awx_get_env_value() {
    local key="$1"
    local line
    line=$(grep -E "^${key}=" "${AWX_ENV_FILE}" | tail -n 1 || true)
    [ -n "$line" ] || { printf ''; return; }
    printf '%s' "${line#*=}"
}

awx_set_env_value() {
    local key="$1"
    local value="$2"
    awk -v k="$key" -v v="$value" '
        BEGIN { found=0 }
        $0 ~ "^"k"=" { print k"="v; found=1; next }
        { print }
        END { if (!found) print k"="v }
    ' "${AWX_ENV_FILE}" > "${AWX_ENV_FILE}.tmp" && mv "${AWX_ENV_FILE}.tmp" "${AWX_ENV_FILE}"
}

awx_require_command() {
    command -v "$1" >/dev/null 2>&1 || log_error "Missing required command: $1"
}

awx_ensure_repo_dirs() {
    mkdir -p "${REPO_ROOT}/services/awx/k8s/rendered" "${REPO_ROOT}/.local/kubeconfigs" "${REPO_ROOT}/.local/awx"
}

awx_validate_hostname_label() {
    local label="$1"
    [[ "$label" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || log_error "Invalid AWX hostname label: ${label}"
}

awx_validate_nodeport() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || log_error "AWX node port must be numeric: ${port}"
    [ "$port" -ge 30000 ] && [ "$port" -le 32767 ] || log_error "AWX node port must be in 30000-32767: ${port}"
}

awx_validate_host_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || log_error "AWX host port must be numeric: ${port}"
    [ "$port" -ge 1024 ] && [ "$port" -le 65535 ] || log_error "AWX host port must be in 1024-65535: ${port}"
}

awx_require_non_placeholder() {
    local key="$1"
    local value="$2"
    local trimmed
    trimmed=$(awx_trim_quotes "$value")
    [ -n "$trimmed" ] || log_error "${key} is required"
    case "$trimmed" in
        changeme|change-me|example|example123|REPLACE_ME|replace-me)
            log_error "${key} appears to be a placeholder value"
            ;;
    esac
}

awx_defaults() {
    : "${AWX_HOSTNAME:=awx}"
    : "${AWX_NAMESPACE:=awx}"
    : "${AWX_INSTANCE_NAME:=awx}"
    : "${AWX_ADMIN_USER:=admin}"
    : "${AWX_NODEPORT_HTTP:=30080}"
    : "${AWX_HOST_PORT_HTTP:=${AWX_NODEPORT_HTTP}}"
    : "${AWX_K3D_CLUSTER_NAME:=awx}"
    : "${AWX_KUBECONFIG_PATH:=${REPO_ROOT}/.local/kubeconfigs/awx-k3d.yaml}"
    : "${K3D_K3S_IMAGE:=rancher/k3s:v1.31.5-k3s1}"
    : "${AWX_OPERATOR_CHART_VERSION:=3.2.0}"
    : "${AWX_OPERATOR_VERSION_TARGET:=2.19.1}"
    : "${AWX_VERSION_TARGET:=24.6.1}"
    : "${AWX_OPERATOR_HELM_REPO_NAME:=awx-operator}"
    : "${AWX_OPERATOR_HELM_REPO_URL:=https://ansible-community.github.io/awx-operator-helm/}"
    : "${AWX_OPERATOR_RELEASE_NAME:=awx-operator}"
    : "${AWX_OPERATOR_NAMESPACE:=${AWX_NAMESPACE}}"
    : "${AWX_SECRET_KEY_SECRET_NAME:=awx-secret-key}"
    : "${AWX_ADMIN_PASSWORD_SECRET_NAME:=awx-admin-password}"
    : "${AWX_PROJECTS_PERSISTENCE:=false}"
    : "${AWX_ENABLED:=false}"
    case "${AWX_KUBECONFIG_PATH}" in
        /*) ;;
        *) AWX_KUBECONFIG_PATH="${REPO_ROOT}/${AWX_KUBECONFIG_PATH}" ;;
    esac
}

awx_validate_env() {
    awx_defaults
    awx_validate_hostname_label "$AWX_HOSTNAME"
    awx_validate_nodeport "$AWX_NODEPORT_HTTP"
    awx_validate_host_port "$AWX_HOST_PORT_HTTP"
    [ -n "$AWX_NAMESPACE" ] || log_error "AWX_NAMESPACE is required"
    [ -n "$AWX_INSTANCE_NAME" ] || log_error "AWX_INSTANCE_NAME is required"
    [ "$AWX_OPERATOR_NAMESPACE" = "$AWX_NAMESPACE" ] || log_error "AWX_OPERATOR_NAMESPACE must equal AWX_NAMESPACE in the current Helm chart-based flow (operator watches only its release namespace)"
    awx_require_non_placeholder "AWX_ADMIN_PASSWORD" "${AWX_ADMIN_PASSWORD:-}"
    awx_require_non_placeholder "AWX_SECRET_KEY" "${AWX_SECRET_KEY:-}"
    case "$AWX_KUBECONFIG_PATH" in
        "${REPO_ROOT}/.local/"*) ;;
        *) log_error "AWX_KUBECONFIG_PATH must default under ${REPO_ROOT}/.local/ (override only if intentional)" ;;
    esac
}

awx_kubectl() {
    KUBECONFIG="$AWX_KUBECONFIG_PATH" kubectl "$@"
}

awx_helm() {
    KUBECONFIG="$AWX_KUBECONFIG_PATH" helm "$@"
}

awx_ensure_context() {
    local cluster_name="k3d-${AWX_K3D_CLUSTER_NAME}"
    local current
    current=$(KUBECONFIG="$AWX_KUBECONFIG_PATH" kubectl config current-context 2>/dev/null || true)
    [ "$current" = "$cluster_name" ] || log_error "KUBECONFIG context mismatch. Expected ${cluster_name}, got '${current:-<none>}'"
}

awx_render_templates() {
    local rendered_dir="${REPO_ROOT}/services/awx/k8s/rendered"
    mkdir -p "$rendered_dir"
    sed \
        -e "s/__AWX_NAMESPACE__/${AWX_NAMESPACE}/g" \
        "${REPO_ROOT}/services/awx/k8s/namespaces/namespace.yaml.tmpl" > "${rendered_dir}/namespace.yaml"

    sed \
        -e "s/__AWX_NAMESPACE__/${AWX_NAMESPACE}/g" \
        -e "s/__AWX_INSTANCE_NAME__/${AWX_INSTANCE_NAME}/g" \
        -e "s/__AWX_NODEPORT_HTTP__/${AWX_NODEPORT_HTTP}/g" \
        -e "s/__AWX_ADMIN_USER__/${AWX_ADMIN_USER}/g" \
        -e "s/__AWX_ADMIN_PASSWORD_SECRET_NAME__/${AWX_ADMIN_PASSWORD_SECRET_NAME}/g" \
        -e "s/__AWX_SECRET_KEY_SECRET_NAME__/${AWX_SECRET_KEY_SECRET_NAME}/g" \
        -e "s/__DEV_DOMAIN__/${DEV_DOMAIN}/g" \
        -e "s/__AWX_PROJECTS_PERSISTENCE__/${AWX_PROJECTS_PERSISTENCE}/g" \
        "${REPO_ROOT}/services/awx/k8s/awx/awx.yaml.tmpl" > "${rendered_dir}/awx.yaml"

    cp "${REPO_ROOT}/services/awx/k8s/operator/values.yaml.tmpl" "${rendered_dir}/operator-values.yaml"
}
