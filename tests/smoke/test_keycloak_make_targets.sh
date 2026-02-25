#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../../scripts/common.sh"
MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."
for target in keycloak-bootstrap keycloak-up keycloak-down keycloak-restart keycloak-logs keycloak-status test-keycloak; do
  grep -q "^${target}:" "$MAKEFILE" || log_error "Missing Make target: ${target}"
done
for target in keycloak-up keycloak-down keycloak-logs keycloak-status; do
  awk -v t="$target" '
    $0 ~ "^" t ":" { in_target=1; next }
    in_target && $0 ~ /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && $0 ~ /--profile keycloak/ &&
      ($0 ~ /scripts\/compose\.sh/ || $0 ~ /\$\(SCRIPTS_DIR\)\/compose\.sh/) { found=1 }
    END { exit(found ? 0 : 1) }
  ' "$MAKEFILE" || log_error "Target ${target} is not wired through compose wrapper with profile keycloak."
done
log_success "Keycloak Make target wiring test passed."
