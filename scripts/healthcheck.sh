#!/bin/bash
# File: scripts/healthcheck.sh
#
# Runs smoke tests to check Traefik readiness, routing, TLS handshake, and
# module-specific wiring/guardrails. The default mode is service-aware:
# service groups are only tested when their containers are running.
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

log_info "Running smoke tests for the stack (service-aware suites)..."

check_command "curl"
check_command "openssl" # For TLS handshake test

TEST_RESULTS=0
TEST_DIR="${SCRIPT_DIR}/../tests/smoke"
RUNNING_SERVICES=()

detect_running_services() {
    if ! command -v docker >/dev/null 2>&1; then
        log_warn "docker not found; service-aware smoke selection disabled (running common tests only)."
        return 0
    fi

    mapfile -t RUNNING_SERVICES < <(
        "${SCRIPT_DIR}/compose.sh" ps --services --status running 2>/dev/null \
            | grep -v '^INFO:' || true
    )

    if [ "${#RUNNING_SERVICES[@]}" -gt 0 ]; then
        log_info "Running services detected: ${RUNNING_SERVICES[*]}"
    else
        log_warn "No running services detected via docker compose; service-specific suites will be skipped."
    fi
}

service_running() {
    local candidate="$1"
    local running_service
    for running_service in "${RUNNING_SERVICES[@]}"; do
        if [ "${running_service}" = "${candidate}" ]; then
            return 0
        fi
    done
    return 1
}

# --- Test 1: Traefik Readiness ---
detect_running_services

RUN_CORE_TESTS=false
RUN_BIND_TESTS=false
RUN_CTFD_TESTS=false
RUN_OBSERVABILITY_TESTS=false
RUN_PLANE_TESTS=false

if service_running "traefik" && service_running "whoami"; then
    RUN_CORE_TESTS=true
fi
if service_running "bind" || service_running "dns"; then
    RUN_BIND_TESTS=true
fi
if service_running "ctfd"; then
    RUN_CTFD_TESTS=true
fi
if service_running "grafana" || service_running "prometheus" || service_running "loki" || service_running "tempo" || service_running "pyroscope" || service_running "alloy"; then
    RUN_OBSERVABILITY_TESTS=true
fi
if service_running "plane-web" || service_running "plane-api"; then
    RUN_PLANE_TESTS=true
fi

# --- Test 1: Traefik Readiness ---
if [ "${RUN_CORE_TESTS}" = "true" ]; then
    log_info "Running test_traefik_ready.sh..."
    if "$TEST_DIR/test_traefik_ready.sh"; then
        log_success "Test: Traefik Readiness"
    else
        log_warn "Test failed: Traefik Readiness"
        TEST_RESULTS=1
    fi
else
    log_warn "Skipping core Traefik/whoami smoke suite (traefik+whoami not both running)."
fi

# --- Test 2: Routing to whoami service ---
if [ "${RUN_CORE_TESTS}" = "true" ]; then
    log_info "Running test_routing.sh..."
    if "$TEST_DIR/test_routing.sh"; then
        log_success "Test: Whoami Service Routing"
    else
        log_warn "Test failed: Whoami Service Routing"
        TEST_RESULTS=1
    fi
fi

# --- Test 3: TLS Handshake for whoami service ---
if [ "${RUN_CORE_TESTS}" = "true" ]; then
    log_info "Running test_tls_handshake.sh..."
    if "$TEST_DIR/test_tls_handshake.sh"; then
        log_success "Test: TLS Handshake"
    else
        log_warn "Test failed: TLS Handshake"
        TEST_RESULTS=1
    fi
fi

# --- Test 4: HTTP to HTTPS Redirect (conditional) ---
if [ "${RUN_CORE_TESTS}" = "true" ]; then
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
if [ "${RUN_BIND_TESTS}" = "true" ]; then
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
else
    log_warn "Skipping BIND smoke suite (service 'bind'/'dns' not running)."
fi

# --- Test 13: CTFd Service Config (no sudo) ---
if [ "${RUN_CTFD_TESTS}" = "true" ]; then
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
else
    log_warn "Skipping CTFd smoke suite (service 'ctfd' not running)."
fi

# --- Test 17: Observability Service Config (no sudo) ---
if [ "${RUN_OBSERVABILITY_TESTS}" = "true" ]; then
    log_info "Running test_observability_service_config.sh..."
    if "$TEST_DIR/test_observability_service_config.sh"; then
        log_success "Test: Observability Service Config"
    else
        log_warn "Test failed: Observability Service Config"
        TEST_RESULTS=1
    fi

    # --- Test 18: Observability Advanced Service Config (no sudo) ---
    log_info "Running test_observability_advanced_service_config.sh..."
    if "$TEST_DIR/test_observability_advanced_service_config.sh"; then
        log_success "Test: Observability Advanced Service Config"
    else
        log_warn "Test failed: Observability Advanced Service Config"
        TEST_RESULTS=1
    fi

    # --- Test 19: Observability Alloy Signal Pipelines (no sudo) ---
    log_info "Running test_observability_alloy_signal_pipelines.sh..."
    if "$TEST_DIR/test_observability_alloy_signal_pipelines.sh"; then
        log_success "Test: Observability Alloy Signal Pipelines"
    else
        log_warn "Test failed: Observability Alloy Signal Pipelines"
        TEST_RESULTS=1
    fi

    # --- Test 20: Observability Traefik Config (no sudo) ---
    log_info "Running test_observability_traefik_config.sh..."
    if "$TEST_DIR/test_observability_traefik_config.sh"; then
        log_success "Test: Observability Traefik Config"
    else
        log_warn "Test failed: Observability Traefik Config"
        TEST_RESULTS=1
    fi

    # --- Test 21: Observability Guardrails (no sudo) ---
    log_info "Running test_observability_guardrails.sh..."
    if "$TEST_DIR/test_observability_guardrails.sh"; then
        log_success "Test: Observability Guardrails"
    else
        log_warn "Test failed: Observability Guardrails"
        TEST_RESULTS=1
    fi

    # --- Test 22: Observability Make Targets (no sudo) ---
    log_info "Running test_observability_make_targets.sh..."
    if "$TEST_DIR/test_observability_make_targets.sh"; then
        log_success "Test: Observability Make Targets"
    else
        log_warn "Test failed: Observability Make Targets"
        TEST_RESULTS=1
    fi

    # --- Test 23: Observability Bootstrap Env (no sudo) ---
    log_info "Running test_observability_bootstrap_env.sh..."
    if "$TEST_DIR/test_observability_bootstrap_env.sh"; then
        log_success "Test: Observability Bootstrap Env"
    else
        log_warn "Test failed: Observability Bootstrap Env"
        TEST_RESULTS=1
    fi

    # --- Test 24: Observability Grafana Provisioning (no sudo) ---
    log_info "Running test_observability_grafana_provisioning.sh..."
    if "$TEST_DIR/test_observability_grafana_provisioning.sh"; then
        log_success "Test: Observability Grafana Provisioning"
    else
        log_warn "Test failed: Observability Grafana Provisioning"
        TEST_RESULTS=1
    fi

    # --- Test 25: Observability k6 Wiring (no sudo) ---
    log_info "Running test_observability_k6_wiring.sh..."
    if "$TEST_DIR/test_observability_k6_wiring.sh"; then
        log_success "Test: Observability k6 Wiring"
    else
        log_warn "Test failed: Observability k6 Wiring"
        TEST_RESULTS=1
    fi

    # --- Test 26: Observability App-Pack Tolerance (no sudo) ---
    log_info "Running test_observability_app_pack_tolerance.sh..."
    if "$TEST_DIR/test_observability_app_pack_tolerance.sh"; then
        log_success "Test: Observability App-Pack Tolerance"
    else
        log_warn "Test failed: Observability App-Pack Tolerance"
        TEST_RESULTS=1
    fi
else
    log_warn "Skipping observability smoke suite (none of grafana/prometheus/loki/tempo/pyroscope/alloy running)."
fi

# --- Test 27: Plane Service Config (no sudo) ---
if [ "${RUN_PLANE_TESTS}" = "true" ]; then
    log_info "Running test_plane_service_config.sh..."
    if "$TEST_DIR/test_plane_service_config.sh"; then
        log_success "Test: Plane Service Config"
    else
        log_warn "Test failed: Plane Service Config"
        TEST_RESULTS=1
    fi

    # --- Test 28: Plane Guardrails (no sudo) ---
    log_info "Running test_plane_guardrails.sh..."
    if "$TEST_DIR/test_plane_guardrails.sh"; then
        log_success "Test: Plane Guardrails"
    else
        log_warn "Test failed: Plane Guardrails"
        TEST_RESULTS=1
    fi

    # --- Test 29: Plane Make Targets (no sudo) ---
    log_info "Running test_plane_make_targets.sh..."
    if "$TEST_DIR/test_plane_make_targets.sh"; then
        log_success "Test: Plane Make Targets"
    else
        log_warn "Test failed: Plane Make Targets"
        TEST_RESULTS=1
    fi

    # --- Test 30: Plane Bootstrap Env (no sudo) ---
    log_info "Running test_plane_bootstrap_env.sh..."
    if "$TEST_DIR/test_plane_bootstrap_env.sh"; then
        log_success "Test: Plane Bootstrap Env"
    else
        log_warn "Test failed: Plane Bootstrap Env"
        TEST_RESULTS=1
    fi

    # --- Test 31: Plane Optional Integrations (no sudo) ---
    log_info "Running test_plane_optional_integrations.sh..."
    if "$TEST_DIR/test_plane_optional_integrations.sh"; then
        log_success "Test: Plane Optional Integrations"
    else
        log_warn "Test failed: Plane Optional Integrations"
        TEST_RESULTS=1
    fi
else
    log_warn "Skipping Plane smoke suite (service 'plane-web'/'plane-api' not running)."
fi

if [ "$TEST_RESULTS" -eq 0 ]; then
    log_success "All smoke tests passed!"
else
    log_error "One or more smoke tests failed."
fi

exit "$TEST_RESULTS"
