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

awx_kubectl -n "$AWX_NAMESPACE" get secret "$AWX_ADMIN_PASSWORD_SECRET_NAME" -o jsonpath='{.data.password}' | base64 -d && echo
