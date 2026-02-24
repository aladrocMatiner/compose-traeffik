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

NAMESPACE="${AWX_NAMESPACE}"
SELECTOR=""
FOLLOW="-f"
if [ "${#AWX_REMAINING_ARGS[@]}" -gt 0 ]; then
  case "${AWX_REMAINING_ARGS[0]}" in
    operator)
      NAMESPACE="${AWX_OPERATOR_NAMESPACE}"
      SELECTOR="app.kubernetes.io/name=awx-operator"
      ;;
    web)
      SELECTOR="app.kubernetes.io/component=web"
      ;;
    task)
      SELECTOR="app.kubernetes.io/component=task"
      ;;
  esac
fi

if [ -z "$SELECTOR" ]; then
  awx_kubectl -n "$NAMESPACE" get pods
  exit 0
fi

pod=$(awx_kubectl -n "$NAMESPACE" get pods -l "$SELECTOR" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
[ -n "$pod" ] || log_error "No pod found for selector ${SELECTOR} in namespace ${NAMESPACE}"
awx_kubectl -n "$NAMESPACE" logs $FOLLOW "$pod"
