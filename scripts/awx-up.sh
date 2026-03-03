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
awx_require_command helm
awx_require_command docker

awx_render_templates
awx_ensure_context

log_info "Applying namespaces..."
awx_kubectl apply -f "${REPO_ROOT}/services/awx/k8s/rendered/namespace.yaml"
awx_kubectl create namespace "$AWX_OPERATOR_NAMESPACE" --dry-run=client -o yaml | awx_kubectl apply -f -

log_info "Installing/upgrading AWX Operator (Helm)..."
awx_helm repo add "$AWX_OPERATOR_HELM_REPO_NAME" "$AWX_OPERATOR_HELM_REPO_URL" >/dev/null 2>&1 || true
awx_helm repo update >/dev/null
awx_helm upgrade --install "$AWX_OPERATOR_RELEASE_NAME" "$AWX_OPERATOR_HELM_REPO_NAME/awx-operator" \
  --namespace "$AWX_OPERATOR_NAMESPACE" \
  --version "$AWX_OPERATOR_CHART_VERSION" \
  -f "${REPO_ROOT}/services/awx/k8s/rendered/operator-values.yaml" \
  --wait --timeout 10m

log_info "Creating/updating AWX secrets..."
awx_kubectl -n "$AWX_NAMESPACE" create secret generic "$AWX_ADMIN_PASSWORD_SECRET_NAME" \
  --from-literal=password="$AWX_ADMIN_PASSWORD" --dry-run=client -o yaml | awx_kubectl apply -f -
awx_kubectl -n "$AWX_NAMESPACE" create secret generic "$AWX_SECRET_KEY_SECRET_NAME" \
  --from-literal=secret_key="$AWX_SECRET_KEY" --dry-run=client -o yaml | awx_kubectl apply -f -

log_info "Applying AWX custom resource..."
awx_kubectl apply -f "${REPO_ROOT}/services/awx/k8s/rendered/awx.yaml"

log_info "Rendering Traefik dynamic config for AWX route..."
AWX_ENABLED=true "${SCRIPT_DIR}/traefik-render-dynamic.sh"

log_success "AWX apply submitted. Use 'make awx-status' to monitor readiness."
