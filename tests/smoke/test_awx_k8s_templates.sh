#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"
for f in \
  "$SCRIPT_DIR/../../services/awx/k8s/namespaces/namespace.yaml.tmpl" \
  "$SCRIPT_DIR/../../services/awx/k8s/operator/values.yaml.tmpl" \
  "$SCRIPT_DIR/../../services/awx/k8s/awx/awx.yaml.tmpl" \
  "$SCRIPT_DIR/../../services/awx/k8s/secrets/awx-admin-password.secret.yaml.tmpl" \
  "$SCRIPT_DIR/../../services/awx/k8s/secrets/awx-secret-key.secret.yaml.tmpl"; do
  [ -f "$f" ] || log_error "Missing template: $f"
done

grep -q 'kind: AWX' "$SCRIPT_DIR/../../services/awx/k8s/awx/awx.yaml.tmpl" || log_error "AWX CR template missing kind: AWX"
grep -q 'service_type: NodePort' "$SCRIPT_DIR/../../services/awx/k8s/awx/awx.yaml.tmpl" || log_error "AWX CR template missing NodePort service_type"
grep -q '__AWX_NODEPORT_HTTP__' "$SCRIPT_DIR/../../services/awx/k8s/awx/awx.yaml.tmpl" || log_error "AWX CR template missing NodePort placeholder"
grep -q 'enabled: false' "$SCRIPT_DIR/../../services/awx/k8s/operator/values.yaml.tmpl" || log_error "Operator values template should keep AWX.enabled=false"
grep -q '__AWX_ADMIN_PASSWORD_SECRET_NAME__' "$SCRIPT_DIR/../../services/awx/k8s/secrets/awx-admin-password.secret.yaml.tmpl" || log_error "Admin password secret template missing name placeholder"
grep -q '__AWX_SECRET_KEY_SECRET_NAME__' "$SCRIPT_DIR/../../services/awx/k8s/secrets/awx-secret-key.secret.yaml.tmpl" || log_error "Secret key template missing name placeholder"

log_success "AWX k8s templates test passed."
