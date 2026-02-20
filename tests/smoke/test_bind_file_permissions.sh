#!/bin/bash
# File: tests/smoke/test_bind_file_permissions.sh
#
# Smoke test: Validate BIND config/zone file permissions are not over-permissive.
#
# Usage: ./tests/smoke/test_bind_file_permissions.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

load_env
check_env_var "BASE_DOMAIN"
check_command "stat"

ZONE_FILE="${SCRIPT_DIR}/../../services/dns-bind/zones/db.${BASE_DOMAIN}"
ZONE_DIR="${SCRIPT_DIR}/../../services/dns-bind/zones"
CONFIG_TEMPLATE="${SCRIPT_DIR}/../../services/dns-bind/config/named.conf.template"

if [ ! -f "${ZONE_FILE}" ]; then
    log_info "Zone file not found; generating via bind-provision..."
    "${SCRIPT_DIR}/../../scripts/bind-provision.sh" >/dev/null
fi

is_world_writable() {
    local mode="$1"
    local other=$((mode % 10))
    [ $((other & 2)) -ne 0 ]
}

zone_mode=$(stat -c '%a' "${ZONE_FILE}")
zone_dir_mode=$(stat -c '%a' "${ZONE_DIR}")
template_mode=$(stat -c '%a' "${CONFIG_TEMPLATE}")

if is_world_writable "${zone_mode}"; then
    log_error "Zone file is world-writable (${zone_mode}): ${ZONE_FILE}"
fi
if is_world_writable "${zone_dir_mode}"; then
    log_error "Zone directory is world-writable (${zone_dir_mode}): ${ZONE_DIR}"
fi
if is_world_writable "${template_mode}"; then
    log_error "named.conf.template is world-writable (${template_mode}): ${CONFIG_TEMPLATE}"
fi

log_success "BIND file permission test passed."
