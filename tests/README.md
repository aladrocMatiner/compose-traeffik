# File: tests/README.md
#
# Smoke Tests for Traefik Edge Stack
#
# This directory contains basic smoke tests to quickly verify the functionality
# of the Traefik Docker Compose edge stack. These tests are designed to be fast
# and provide immediate feedback on the health and routing of the services.
#
# How to Run Tests:
#
# 1.  **Ensure the stack is running:**
#     The tests expect the Traefik and `whoami` services to be up and accessible.
#     For Mode A (local self-signed), run:
#     ```bash
#     make up
#     ```
#
# 2.  **Run all smoke tests via Makefile:**
#     ```bash
#     make test
#     ```
#     This will execute `scripts/healthcheck.sh`, which in turn runs all individual
#     test scripts in this `tests/smoke/` directory.
#
# 3.  **Run individual tests:**
#     You can also execute individual test scripts directly from the `scripts/healthcheck.sh`
#     script, or by calling them if they don't require specific `Makefile` context.
#     However, `make test` is the recommended way as it handles environment setup.
#
# Test Descriptions:
#
# *   **`test_traefik_ready.sh`**: Checks if Traefik's ping endpoint is reachable and returns a success status.
# *   **`test_routing.sh`**: Verifies that requests to `https://whoami.<DEV_DOMAIN>` are correctly routed to the `whoami` service.
# *   **`test_tls_handshake.sh`**: Ensures that a TLS handshake can be successfully established with `https://whoami.<DEV_DOMAIN>` and checks the certificate details (e.g., subject, SANs).
# *   **`test_http_redirect.sh`**: (Conditional) If `HTTP_TO_HTTPS_REDIRECT` is enabled in `.env`, this test verifies that HTTP requests are automatically redirected to HTTPS.
# *   **`test_hosts_subdomains.sh`**: Verifies the hosts subdomain mapper can apply and remove a managed block using a temporary hosts file (no sudo).
#
# Environment Variables:
#
# The tests rely on environment variables defined in `.env` (like `DEV_DOMAIN`,
# `HTTP_TO_HTTPS_REDIRECT`). Ensure your `.env` file is configured correctly
# before running tests.
#
# Test Output:
#
# Each test script will print whether it passed or failed. The `make test` command
# will provide an overall summary.
#
