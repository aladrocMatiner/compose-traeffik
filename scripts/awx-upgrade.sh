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
awx_require_confirm "AWX upgrade modifies operator/AWX target versions and reapplies the instance."

awx_require_command kubectl
awx_require_command helm
awx_ensure_context

old_chart="${AWX_OPERATOR_CHART_VERSION}"
old_awx_target="${AWX_VERSION_TARGET}"

if [ -n "${AWX_OPERATOR_CHART_VERSION_NEW}" ]; then
    AWX_OPERATOR_CHART_VERSION="${AWX_OPERATOR_CHART_VERSION_NEW}"
    awx_set_env_value "AWX_OPERATOR_CHART_VERSION" "${AWX_OPERATOR_CHART_VERSION}"
fi
if [ -n "${AWX_AWX_VERSION_TARGET_NEW}" ]; then
    AWX_VERSION_TARGET="${AWX_AWX_VERSION_TARGET_NEW}"
    awx_set_env_value "AWX_VERSION_TARGET" "${AWX_VERSION_TARGET}"
fi

log_info "Upgrade plan:"
log_info "  Operator chart: ${old_chart} -> ${AWX_OPERATOR_CHART_VERSION}"
log_info "  AWX target (documented pin): ${old_awx_target} -> ${AWX_VERSION_TARGET}"
log_warn "Run 'make awx-backup' before upgrades if you need a restore point."

"${SCRIPT_DIR}/awx-up.sh" --env-file "${AWX_ENV_FILE}"

stamp=$(awx_now_utc)
artifact_dir="${AWX_DEBUG_LOCAL_DIR}/awx-upgrade-${stamp}"
mkdir -p "${artifact_dir}"
awx_kubectl -n "${AWX_NAMESPACE}" get awx "${AWX_INSTANCE_NAME}" -o yaml > "${artifact_dir}/awx-post-upgrade.yaml" 2>/dev/null || true
awx_kubectl -n "${AWX_OPERATOR_NAMESPACE}" get deploy "${AWX_OPERATOR_RELEASE_NAME}-controller-manager" -o yaml > "${artifact_dir}/operator-post-upgrade.yaml" 2>/dev/null || true

cat > "${artifact_dir}/UPGRADE-METADATA.txt" <<EOF
AWX upgrade invocation metadata
Timestamp: ${stamp}
Operator chart: ${old_chart} -> ${AWX_OPERATOR_CHART_VERSION}
AWX version target (repo pin): ${old_awx_target} -> ${AWX_VERSION_TARGET}

Post-upgrade checks:
- make awx-status
- make awx-admin-password (sanity check secret readability)
- curl -skI --resolve awx.<DEV_DOMAIN>:443:127.0.0.1 https://awx.<DEV_DOMAIN>/
EOF

log_success "AWX upgrade apply finished. Validate pod rollout with 'make awx-status'."
