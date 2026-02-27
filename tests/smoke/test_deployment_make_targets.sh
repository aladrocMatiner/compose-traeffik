#!/bin/bash
# File: tests/smoke/test_deployment_make_targets.sh
#
# Smoke test: Validate deployment selector Make target wiring.
#
# Usage: ./tests/smoke/test_deployment_make_targets.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"

if [ ! -f "$MAKEFILE" ]; then
    log_error "Makefile not found."
fi

check_command "grep"
check_command "awk"

for target in deployment deployment-plan deployment-output deployment-ssh deployment-list deployment-validate deployment-destroy; do
    if ! grep -q "^${target}:" "$MAKEFILE"; then
        log_error "Missing Make target: ${target}"
    fi
done

# deployment-list must route through deployment-access list selector.
if ! awk '
    /^deployment-list:/ { in_target=1; next }
    in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && /deployment-access\.sh/ && / list / { found=1 }
    END { exit(found ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "deployment-list is not wired through deployment/scripts/deployment-access.sh list"
fi

# deployment-ssh must keep selector path for qemu/name and fallback path to infra-provision.
if ! awk '
    /^deployment-ssh:/ { in_target=1; next }
    in_target && /^[a-zA-Z0-9_.-]+:/ { exit }
    in_target && /\$\(DEPLOYMENT_TARGET\)" == "qemu"/ { has_qemu_cond=1 }
    in_target && /\-n "\$\(DEPLOYMENT_NAME\)"/ { has_name_cond=1 }
    in_target && /deployment-access\.sh/ && / ssh / { has_selector_path=1 }
    in_target && /infra-provision\.sh/ && / ssh / { has_fallback_path=1 }
    END { exit(has_qemu_cond && has_name_cond && has_selector_path && has_fallback_path ? 0 : 1) }
' "$MAKEFILE"; then
    log_error "deployment-ssh wiring is missing selector/fallback branches"
fi

log_success "Deployment Make target wiring test passed."
