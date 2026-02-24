#!/bin/bash
# File: scripts/healthcheck.sh
#
# Runs smoke tests to check Traefik readiness, routing, and TLS handshake.
#
# Usage: ./scripts/healthcheck.sh
#
# Returns 0 on success, 1 on failure.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "DEV_DOMAIN"

if [ -n "${HTTP_TO_HTTPS_MIDDLEWARE:-}" ]; then
    if [ "${HTTP_TO_HTTPS_MIDDLEWARE}" = "redirect-to-https@file" ]; then
        REDIRECT_ENABLED=true
    elif [ "${HTTP_TO_HTTPS_MIDDLEWARE}" = "noop@file" ]; then
        REDIRECT_ENABLED=false
    else
        log_error "Unknown HTTP_TO_HTTPS_MIDDLEWARE value: ${HTTP_TO_HTTPS_MIDDLEWARE}"
    fi
else
    check_env_var "HTTP_TO_HTTPS_REDIRECT"
    if [ "${HTTP_TO_HTTPS_REDIRECT}" = "true" ]; then
        REDIRECT_ENABLED=true
    else
        REDIRECT_ENABLED=false
    fi
fi

log_info "Running smoke tests for Traefik and demo service..."

check_command "curl"
check_command "openssl" # For TLS handshake test

TEST_RESULTS=0
TEST_DIR="${SCRIPT_DIR}/../tests/smoke"

# --- Test 1: Traefik Readiness ---
log_info "Running test_traefik_ready.sh..."
if "$TEST_DIR/test_traefik_ready.sh"; then
    log_success "Test: Traefik Readiness"
else
    log_warn "Test failed: Traefik Readiness"
    TEST_RESULTS=1
fi

# --- Test 2: Routing to whoami service ---
log_info "Running test_routing.sh..."
if "$TEST_DIR/test_routing.sh"; then
    log_success "Test: Whoami Service Routing"
else
    log_warn "Test failed: Whoami Service Routing"
    TEST_RESULTS=1
fi

# --- Test 3: TLS Handshake for whoami service ---
log_info "Running test_tls_handshake.sh..."
if "$TEST_DIR/test_tls_handshake.sh"; then
    log_success "Test: TLS Handshake"
else
    log_warn "Test failed: TLS Handshake"
    TEST_RESULTS=1
fi

# --- Test 4: HTTP to HTTPS Redirect (conditional) ---
if [ "${REDIRECT_ENABLED}" = "true" ]; then
    log_info "Running test_http_redirect.sh (HTTP redirect enabled)..."
    if "$TEST_DIR/test_http_redirect.sh"; then
        log_success "Test: HTTP to HTTPS Redirect"
    else
        log_warn "Test failed: HTTP to HTTPS Redirect"
        TEST_RESULTS=1
    fi
else
    log_warn "Skipping HTTP to HTTPS Redirect test (HTTP redirect disabled)."
fi

# --- Test 5: Hosts Subdomain Mapper (no sudo) ---
log_info "Running test_hosts_subdomains.sh..."
if "$TEST_DIR/test_hosts_subdomains.sh"; then
    log_success "Test: Hosts Subdomain Mapper"
else
    log_warn "Test failed: Hosts Subdomain Mapper"
    TEST_RESULTS=1
fi

# --- Test 6: BIND Service Config (no sudo) ---
log_info "Running test_bind_service_config.sh..."
if "$TEST_DIR/test_bind_service_config.sh"; then
    log_success "Test: BIND Service Config"
else
    log_warn "Test failed: BIND Service Config"
    TEST_RESULTS=1
fi

# --- Test 7: BIND Zone Generation (no sudo) ---
log_info "Running test_bind_zone_generation.sh..."
if "$TEST_DIR/test_bind_zone_generation.sh"; then
    log_success "Test: BIND Zone Generation"
else
    log_warn "Test failed: BIND Zone Generation"
    TEST_RESULTS=1
fi

# --- Test 8: BIND Make Target Wiring (no sudo) ---
log_info "Running test_bind_make_targets.sh..."
if "$TEST_DIR/test_bind_make_targets.sh"; then
    log_success "Test: BIND Make Target Wiring"
else
    log_warn "Test failed: BIND Make Target Wiring"
    TEST_RESULTS=1
fi

# --- Test 9: BIND Guardrails (no sudo) ---
log_info "Running test_bind_guardrails.sh..."
if "$TEST_DIR/test_bind_guardrails.sh"; then
    log_success "Test: BIND Guardrails"
else
    log_warn "Test failed: BIND Guardrails"
    TEST_RESULTS=1
fi

# --- Test 10: BIND File Permissions (no sudo) ---
log_info "Running test_bind_file_permissions.sh..."
if "$TEST_DIR/test_bind_file_permissions.sh"; then
    log_success "Test: BIND File Permissions"
else
    log_warn "Test failed: BIND File Permissions"
    TEST_RESULTS=1
fi

# --- Test 11: BIND Provisioning Validation (no sudo) ---
log_info "Running test_bind_provisioning_validation.sh..."
if "$TEST_DIR/test_bind_provisioning_validation.sh"; then
    log_success "Test: BIND Provisioning Validation"
else
    log_warn "Test failed: BIND Provisioning Validation"
    TEST_RESULTS=1
fi

# --- Test 12: BIND Runtime Security (no sudo) ---
log_info "Running test_bind_security_runtime.sh..."
if "$TEST_DIR/test_bind_security_runtime.sh"; then
    log_success "Test: BIND Runtime Security"
else
    log_warn "Test failed: BIND Runtime Security"
    TEST_RESULTS=1
fi

# --- Test 13: CTFd Service Config (no sudo) ---
log_info "Running test_ctfd_service_config.sh..."
if "$TEST_DIR/test_ctfd_service_config.sh"; then
    log_success "Test: CTFd Service Config"
else
    log_warn "Test failed: CTFd Service Config"
    TEST_RESULTS=1
fi

# --- Test 14: CTFd Guardrails (no sudo) ---
log_info "Running test_ctfd_guardrails.sh..."
if "$TEST_DIR/test_ctfd_guardrails.sh"; then
    log_success "Test: CTFd Guardrails"
else
    log_warn "Test failed: CTFd Guardrails"
    TEST_RESULTS=1
fi

# --- Test 15: CTFd Make Targets (no sudo) ---
log_info "Running test_ctfd_make_targets.sh..."
if "$TEST_DIR/test_ctfd_make_targets.sh"; then
    log_success "Test: CTFd Make Target Wiring"
else
    log_warn "Test failed: CTFd Make Target Wiring"
    TEST_RESULTS=1
fi

# --- Test 16: CTFd Bootstrap Env (no sudo) ---
log_info "Running test_ctfd_bootstrap_env.sh..."
if "$TEST_DIR/test_ctfd_bootstrap_env.sh"; then
    log_success "Test: CTFd Bootstrap Env"
else
    log_warn "Test failed: CTFd Bootstrap Env"
    TEST_RESULTS=1
fi

# --- Test 17: Observability Service Config (no sudo) ---
log_info "Running test_observability_service_config.sh..."
if "$TEST_DIR/test_observability_service_config.sh"; then
    log_success "Test: Observability Service Config"
else
    log_warn "Test failed: Observability Service Config"
    TEST_RESULTS=1
fi

# --- Test 18: Observability Traefik Config (no sudo) ---
log_info "Running test_observability_traefik_config.sh..."
if "$TEST_DIR/test_observability_traefik_config.sh"; then
    log_success "Test: Observability Traefik Config"
else
    log_warn "Test failed: Observability Traefik Config"
    TEST_RESULTS=1
fi

# --- Test 19: Observability Guardrails (no sudo) ---
log_info "Running test_observability_guardrails.sh..."
if "$TEST_DIR/test_observability_guardrails.sh"; then
    log_success "Test: Observability Guardrails"
else
    log_warn "Test failed: Observability Guardrails"
    TEST_RESULTS=1
fi

# --- Test 20: Observability Make Targets (no sudo) ---
log_info "Running test_observability_make_targets.sh..."
if "$TEST_DIR/test_observability_make_targets.sh"; then
    log_success "Test: Observability Make Targets"
else
    log_warn "Test failed: Observability Make Targets"
    TEST_RESULTS=1
fi

# --- Test 21: Observability Bootstrap Env (no sudo) ---
log_info "Running test_observability_bootstrap_env.sh..."
if "$TEST_DIR/test_observability_bootstrap_env.sh"; then
    log_success "Test: Observability Bootstrap Env"
else
    log_warn "Test failed: Observability Bootstrap Env"
    TEST_RESULTS=1
fi

# --- Test 22: Observability Grafana Provisioning (no sudo) ---
log_info "Running test_observability_grafana_provisioning.sh..."
if "$TEST_DIR/test_observability_grafana_provisioning.sh"; then
    log_success "Test: Observability Grafana Provisioning"
else
    log_warn "Test failed: Observability Grafana Provisioning"
    TEST_RESULTS=1
fi

# --- Test 23: Observability App-Pack Tolerance (no sudo) ---
log_info "Running test_observability_app_pack_tolerance.sh..."
if "$TEST_DIR/test_observability_app_pack_tolerance.sh"; then
    log_success "Test: Observability App-Pack Tolerance"
else
    log_warn "Test failed: Observability App-Pack Tolerance"
    TEST_RESULTS=1
fi

if [ "$TEST_RESULTS" -eq 0 ]; then
    log_success "All smoke tests passed!"
else
    log_error "One or more smoke tests failed."
fi

exit "$TEST_RESULTS"
