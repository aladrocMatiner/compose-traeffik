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

awx_kubectl -n "$AWX_NAMESPACE" delete awx "$AWX_INSTANCE_NAME" --ignore-not-found
log_success "AWX instance delete requested (${AWX_NAMESPACE}/${AWX_INSTANCE_NAME})."
