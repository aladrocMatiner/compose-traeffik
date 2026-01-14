# Testing & Troubleshooting

**Role: QA / Test Engineer**
*Mission: Ensure documentation includes verification and diagnostic steps, providing clear troubleshooting guidance.*

This section details how to verify the health and functionality of your Traefik edge stack using automated tests and provides guidance for diagnosing and resolving common issues.

<h2>Smoke Tests</h2>

The repository includes a suite of smoke tests designed to quickly verify the core functionality of the Traefik edge stack. These tests are critical for confirming that Traefik is running, routing correctly, and handling TLS as expected.

<h3>What They Test</h3>

The smoke tests cover:

*   **Traefik Readiness**: Confirms that Traefik's API is accessible and responsive.
*   **HTTP to HTTPS Redirect**: Verifies that HTTP requests to services are correctly redirected to HTTPS.
*   **TLS Handshake**: Ensures that TLS connections to services are successfully established and that valid certificates are presented.
*   **Basic Routing**: Validates that requests to `whoami.<DEV_DOMAIN>` are correctly routed to the `whoami` demo service.

<h3>How to Run Smoke Tests</h3>

1.  **Ensure the stack is up**: The tests require the Traefik and demo services to be running.
    ```bash
    make up
    ```
    (Or `COMPOSE_PROFILES=le make up` for Mode B, `COMPOSE_PROFILES=stepca make up` for Mode C, ensuring appropriate TLS setup first).

2.  **Execute the tests**:
    ```bash
    make test
    ```

<h3>Expected Result</h3>

Upon successful execution, the `make test` command will output a series of `PASSED` messages for each test script.

```
Running smoke tests...
./tests/smoke/test_traefik_ready.sh PASSED
./tests/smoke/test_http_redirect.sh PASSED
./tests/smoke/test_tls_handshake.sh PASSED
./tests/smoke/test_routing.sh PASSED
All smoke tests passed successfully!
```

<h3>Meaning of Failures</h3>

*   **`test_traefik_ready.sh` FAILED**: Traefik container might not be running, or its API is inaccessible. Check `make logs traefik`.
*   **`test_http_redirect.sh` FAILED**: The HTTP to HTTPS middleware might be misconfigured, or Traefik is not correctly receiving HTTP traffic.
*   **`test_tls_handshake.sh` FAILED**: Problems with TLS certificates (e.g., not generated, not trusted, incorrect `DEV_DOMAIN`), or Traefik is not listening on HTTPS.
*   **`test_routing.sh` FAILED**: Traefik is not correctly routing requests to the `whoami` service. Check Traefik labels on the `whoami` service and Traefik logs.

<h2>Troubleshooting Guide</h2>

This section provides common symptoms and their diagnostic steps.

<h3>Symptom: `Error: DEV_DOMAIN not set`</h3>

*   **Cause**: The `.env` file is missing or the `DEV_DOMAIN` variable is not defined within it.
*   **Diagnose**: Check for the presence of `.env` and its content.
*   **Fix**:
    1.  Copy the example environment file: `cp .env.example .env`
    2.  Open `.env` and set `DEV_DOMAIN=your.domain.test`.
    3.  Save the file.

<h3>Symptom: Browser displays `SSL_ERROR_BAD_CERT_DOMAIN`, `NET::ERR_CERT_AUTHORITY_INVALID`, or `curl` reports untrusted certificate.</h3>

*   **Cause**: The certificate presented by Traefik is not trusted by your system or browser. This is common for self-signed certificates (Mode A and C) if the root CA is not installed. For Let's Encrypt (Mode B), it could indicate a certificate issuance failure or domain mismatch.
*   **Diagnose**:
    *   **Mode A/C**: Have you followed the steps to trust the local CA certificate? (Refer to [Quickstart: Local Self-Signed TLS (Mode A)](quickstart-mode-a.md) or [TLS Mode C: Smallstep `step-ca`](tls-mode-c-stepca.md)).
    *   **Mode B**: Check if `LETSENCRYPT_STAGING=true` is still set (staging certs are not trusted by default). Verify domain ownership and open ports. Check `make logs traefik` for ACME errors.
*   **Fix**:
    *   **Mode A/C**: Install the respective `ca.crt` file into your operating system's trusted root certificates store.
    *   **Mode B**: Ensure `LETSENCRYPT_STAGING=false` for production, verify public DNS and firewall, and check Traefik logs for specific ACME errors.

<h3>Symptom: `whoami.<DEV_DOMAIN>` (or any service domain) does not resolve to `127.0.0.1`.</h3>

*   **Cause**: Your host system's `/etc/hosts` file is incorrectly configured or not updated.
*   **Diagnose**:
    1.  Run `ping -c 1 whoami.<DEV_DOMAIN>` (replace with your domain).
    2.  Check the contents of your `/etc/hosts` file (or `C:\Windows\System32\drivers\etc\hosts` on Windows).
*   **Fix**:
    1.  Refer to [Requirements and Host Configuration](requirements.md) for detailed steps on editing your hosts file.
    2.  Ensure `whoami.<DEV_DOMAIN>`, `traefik.<DEV_DOMAIN>`, and `step-ca.<DEV_DOMAIN>` (if applicable) are mapped to `127.0.0.1`.
    3.  Flush your operating system's DNS cache if changes don't take effect immediately.

<h3>Symptom: Service not reachable, `404 Not Found`, or `Bad Gateway`</h3>

*   **Cause**: Traefik is not correctly routing requests to your service, or the service itself is not running/accessible from Traefik.
*   **Diagnose**:
    1.  **Check container status**: Run `docker ps` to ensure your service container is running.
    2.  **Check service logs**: Run `make logs <service_name>` (e.g., `make logs whoami`) for any application-level errors.
    3.  **Inspect Traefik logs**: Run `make logs traefik` for any routing errors, such as "router not found" or "no healthy upstream."
    4.  **Verify Traefik labels**: Review the `labels` section for your service in `docker-compose.yml`.
        *   Is `traefik.enable=true` present?
        *   Does the `traefik.http.routers.<service_name>.rule` (e.g., `Host(\`whoami.${DEV_DOMAIN}\`)"`) match your expected domain?
        *   Does `traefik.http.services.<service_name>.loadbalancer.server.port` match the internal port your application listens on?
        *   Is your service connected to the `proxy` network? (e.g., `networks: - proxy`)
    5.  **Check Traefik Dashboard**: If accessible, the dashboard (`https://traefik.<DEV_DOMAIN>/dashboard/`) provides a visual representation of routers and services, which can help pinpoint configuration issues.
*   **Fix**: Correct any discrepancies found in the diagnostic steps. After making changes to `docker-compose.yml`, always run `make restart`.

<h3>Symptom: `make certs-le-issue` (Mode B) fails.</h3>

*   **Cause**: Certbot could not obtain certificates from Let's Encrypt.
*   **Diagnose**:
    1.  Check `certbot` logs: `COMPOSE_PROFILES=le make logs certbot`.
    2.  Verify `ACME_EMAIL` is set in `.env`.
    3.  Ensure your domain's public DNS records point to your server's public IP.
    4.  Confirm ports 80 and 443 are open to the internet on your server.
    5.  Check for Let's Encrypt rate limits (use `LETSENCRYPT_STAGING=true` for testing).
*   **Fix**: Address the specific error reported in the `certbot` logs. Ensure network connectivity and correct DNS configuration.

<h3>Symptom: `make stepca-bootstrap` (Mode C) fails or `step-ca` is not working.</h3>

*   **Cause**: `step-ca` initialization issues, incorrect passwords, or missing files.
*   **Diagnose**:
    1.  Check `step-ca` logs: `COMPOSE_PROFILES=stepca make logs step-ca`.
    2.  Ensure `STEP_CA_ADMIN_PROVISIONER_PASSWORD` and `STEP_CA_PASSWORD` are set in `.env`.
    3.  Verify that the `step-ca` container starts successfully.
*   **Fix**: Review log messages for specific errors. Ensure passwords are correct and the `step-ca` volume (`step-ca/secrets`) is not corrupted. If persistent issues, try `make down` (with `stepca` profile), remove `step-ca/secrets` and `step-ca/config` directories, and re-bootstrap.

<h3>How to Reset/Rollback</h3>

If you encounter severe issues or wish to start fresh:

1.  **Stop and remove the stack**:
    ```bash
    make down
    COMPOSE_PROFILES=le make down # If using Let's Encrypt profile
    COMPOSE_PROFILES=stepca make down # If using step-ca profile
    ```
2.  **Clean generated certificates/data**:
    ```bash
    rm -rf certs/local/ certs/local-ca/
    rm -rf certbot/conf/ # If using Certbot
    rm -rf step-ca/config/ step-ca/data/ step-ca/secrets/ # If using step-ca
    ```
3.  **Remove `.env` (optional)**: If you want to reconfigure from scratch.
    ```bash
    rm .env
    ```
4.  **Clear DNS cache (if needed)**: Refer to "Common Pitfalls" in [Requirements and Host Configuration](requirements.md).

This will bring your repository back to a clean state, allowing you to follow the quickstart or other setup guides from the beginning.
