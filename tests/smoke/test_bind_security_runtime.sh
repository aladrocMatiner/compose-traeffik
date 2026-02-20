#!/bin/bash
# File: tests/smoke/test_bind_security_runtime.sh
#
# Smoke test: Validate BIND runtime security behavior.
#
# Usage: ./tests/smoke/test_bind_security_runtime.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

load_env
check_env_var "BASE_DOMAIN"
check_command "dig"
check_command "docker"
check_command "make"

TEST_BIND_ADDRESS="${BIND_SECURITY_TEST_ADDRESS:-127.0.10.53}"

if [[ ! "$TEST_BIND_ADDRESS" =~ ^127\. ]]; then
    log_error "BIND_SECURITY_TEST_ADDRESS must use loopback for smoke tests. Got: ${TEST_BIND_ADDRESS}"
fi

cleanup() {
    BIND_BIND_ADDRESS="${TEST_BIND_ADDRESS}" make bind-down >/dev/null 2>&1 || true
}
trap cleanup EXIT

log_info "Preparing BIND runtime security checks on ${TEST_BIND_ADDRESS}..."
BIND_BIND_ADDRESS="${TEST_BIND_ADDRESS}" make bind-provision >/dev/null
BIND_BIND_ADDRESS="${TEST_BIND_ADDRESS}" make bind-up >/dev/null

ready=false
for _ in 1 2 3 4 5; do
    if dig @"${TEST_BIND_ADDRESS}" "bind.${BASE_DOMAIN}" +short +time=2 +tries=1 | grep -q .; then
        ready=true
        break
    fi
    sleep 1
done
if [ "$ready" != "true" ]; then
    log_error "BIND did not become query-ready on ${TEST_BIND_ADDRESS}."
fi

log_info "Checking recursion is disabled..."
RECURSION_OUTPUT=$(dig @"${TEST_BIND_ADDRESS}" example.com A +time=2 +tries=1 2>&1 || true)
if ! echo "${RECURSION_OUTPUT}" | grep -Eq "recursion requested but not available|status: REFUSED|status: SERVFAIL"; then
    log_error "Expected recursion to be disabled, but query looked permissive."
fi

log_info "Checking AXFR is denied..."
AXFR_OUTPUT=$(dig @"${TEST_BIND_ADDRESS}" "${BASE_DOMAIN}" AXFR +time=2 +tries=1 2>&1 || true)
if echo "${AXFR_OUTPUT}" | grep -q "XFR size:"; then
    log_error "AXFR succeeded unexpectedly for ${BASE_DOMAIN}."
fi
if ! echo "${AXFR_OUTPUT}" | grep -Eq "Transfer failed|status: REFUSED|status: SERVFAIL"; then
    log_error "AXFR denial signal not detected."
fi

log_info "Checking CHAOS metadata is hidden..."
for qname in version.bind hostname.bind id.server; do
    CHAOS_OUTPUT=$(dig @"${TEST_BIND_ADDRESS}" "${qname}" TXT CH +short +time=2 +tries=1 || true)
    if [ -n "${CHAOS_OUTPUT}" ] && ! echo "${CHAOS_OUTPUT}" | grep -Eiq "not currently available|none"; then
        log_error "Unexpected CHAOS metadata disclosure for ${qname}: ${CHAOS_OUTPUT}"
    fi
done

log_info "Checking listener scope..."
PORT_OUTPUT=$(docker port bind 53/tcp 2>/dev/null || true)
if ! echo "${PORT_OUTPUT}" | grep -q "^${TEST_BIND_ADDRESS}:53$"; then
    log_error "BIND is not bound to expected test listener ${TEST_BIND_ADDRESS}:53. Got: ${PORT_OUTPUT}"
fi

log_success "BIND runtime security test passed."
