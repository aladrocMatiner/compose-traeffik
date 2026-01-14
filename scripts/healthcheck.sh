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
check_env_var "HTTP_TO_HTTPS_REDIRECT"

log_info "Running smoke tests for Traefik and demo service..."

check_command "curl"
check_command "openssl" # For TLS handshake test

TEST_RESULTS=0

# --- Test 1: Traefik Readiness ---
log_info "Running test_traefik_ready.sh..."
if "$SCRIPT_DIR/tests/smoke/test_traefik_ready.sh"; then
    log_success "Test: Traefik Readiness"
else
    log_error "Test failed: Traefik Readiness"
    TEST_RESULTS=1
fi

# --- Test 2: Routing to whoami service ---
log_info "Running test_routing.sh..."
if "$SCRIPT_DIR/tests/smoke/test_routing.sh"; then
    log_success "Test: Whoami Service Routing"
else
    log_error "Test failed: Whoami Service Routing"
    TEST_RESULTS=1
fi

# --- Test 3: TLS Handshake for whoami service ---
log_info "Running test_tls_handshake.sh..."
if "$SCRIPT_DIR/tests/smoke/test_tls_handshake.sh"; then
    log_success "Test: TLS Handshake"
else
    log_error "Test failed: TLS Handshake"
    TEST_RESULTS=1
fi

# --- Test 4: HTTP to HTTPS Redirect (conditional) ---
if [ "${HTTP_TO_HTTPS_REDIRECT}" = "true" ]; then
    log_info "Running test_http_redirect.sh (HTTP_TO_HTTPS_REDIRECT is true)..."
    if "$SCRIPT_DIR/tests/smoke/test_http_redirect.sh"; then
        log_success "Test: HTTP to HTTPS Redirect"
    else
        log_error "Test failed: HTTP to HTTPS Redirect"
        TEST_RESULTS=1
    fi
else
    log_warn "Skipping HTTP to HTTPS Redirect test (HTTP_TO_HTTPS_REDIRECT is false)."
fi

if [ "$TEST_RESULTS" -eq 0 ]; then
    log_success "All smoke tests passed!"
else
    log_error "One or more smoke tests failed."
fi

exit "$TEST_RESULTS"
