# Quickstart: Local Self-Signed TLS (Mode A)

**Role: DevOps UX Engineer / Documentation Lead**
*Mission: Provide a clear and executable quickstart for running the stack with self-signed certificates.*

This guide provides a rapid setup process for getting the Traefik edge stack running with locally generated self-signed TLS certificates. This mode is ideal for local development and testing, as it does not require a public domain or exposure to the internet.

## Prerequisites

Before starting, ensure you have completed the general [Requirements and Host Configuration](../requirements.md). Specifically:

*   You have Docker and Docker Compose installed.
*   You have `make`, `curl`, and `openssl` installed.
*   You have cloned the repository.
*   You have copied `.env.example` to `.env` and configured `DEV_DOMAIN`.
*   Your host system's `/etc/hosts` file (or equivalent) is configured to map `whoami.<DEV_DOMAIN>` and `traefik.<DEV_DOMAIN>` to `127.0.0.1`.

## Steps

1.  **Clone the repository:**
    (This step should be done as part of the overall setup, but included here for completeness of the quickstart flow.)
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Copy the example environment file:**
    ```bash
    cp .env.example .env
    # Open .env and adjust DEV_DOMAIN if desired, then save.
    ```
    > **Note:** Ensure your `/etc/hosts` file is updated according to the `DEV_DOMAIN` set in `.env`. Refer to [Requirements and Host Configuration](../requirements.md) for details.

3.  **Generate local self-signed certificates:**
    ```bash
    make certs-local
    ```
    This command will:
    *   Create a local Certificate Authority (CA) in `certs/local-ca/`.
    *   Generate a self-signed certificate for `whoami.<DEV_DOMAIN>`, `traefik.<DEV_DOMAIN>`, and `step-ca.<DEV_DOMAIN>` in the `certs/local/` directory, signed by your local CA.

4.  **Trust the Local CA (One-Time Setup):**
    For your browser and `curl` to trust the self-signed certificates, you *must* manually add the generated CA certificate (`certs/local-ca/ca.crt`) to your operating system's trust store. This is a one-time setup.

    *   **macOS**: Open `certs/local-ca/ca.crt`, add it to Keychain Access, and set it to "Always Trust".
    *   **Linux (Debian/Ubuntu)**:
        ```bash
        sudo cp certs/local-ca/ca.crt /usr/local/share/ca-certificates/custom_ca.crt
        sudo update-ca-certificates
        ```
    *   **Windows**: Double-click `certs/local-ca/ca.crt`, select "Install Certificate", choose "Local Machine", and place it in the "Trusted Root Certification Authorities" store.

    > **Warning:** Skipping this step will result in browser warnings (e.g., `NET::ERR_CERT_AUTHORITY_INVALID`) and `curl` errors regarding untrusted certificates.

5.  **Start the Docker Compose stack:**
    ```bash
    make up
    ```
    This command brings up Traefik and the `whoami` demo service, configured to use the certificates generated in the previous step.

## Expected Result

Upon successful execution of `make up`, you should see output indicating that Traefik and the `whoami` services have started without errors. The `docker ps` command should show both `traefik` and `whoami` containers running.

## Verification

1.  **Check running containers:**
    ```bash
    docker ps
    ```
    You should see `traefik_traefik_1` and `traefik_whoami_1` (or similar names) in the `Up` state.

2.  **Run smoke tests:**
    ```bash
    make test
    ```
    This will execute a series of tests to verify Traefik is ready, routing to `whoami` works over HTTPS, and the TLS handshake is successful. All tests should pass.

3.  **Access the demo service via browser:**
    Open your web browser and navigate to `https://whoami.<DEV_DOMAIN>`. You should see the `whoami` service's output (details about the request and container), served securely over HTTPS without any certificate warnings (assuming you trusted the CA).

4.  **Access the Traefik Dashboard (Optional):**
    Navigate to `https://traefik.<DEV_DOMAIN>/dashboard/`. You should see the Traefik dashboard displaying the configured routers, services, and middlewares. This confirms Traefik's own certificate is also trusted and routing is functional.

## Common Pitfalls

*   **`SSL_ERROR_BAD_CERT_DOMAIN` or `NET::ERR_CERT_AUTHORITY_INVALID` in browser / `curl` errors**: You likely have not trusted the local CA certificate (`certs/local-ca/ca.crt`) in your operating system's trust store. Refer to Step 4.
*   **`whoami.<DEV_DOMAIN>` does not resolve**: Check your `/etc/hosts` file and ensure it correctly maps `whoami.<DEV_DOMAIN>` and `traefik.<DEV_DOMAIN>` to `127.0.0.1`.
*   **`Error: DEV_DOMAIN not set` or similar from `make` commands**: Ensure you have copied `.env.example` to `.env` and set the `DEV_DOMAIN` variable within it.
*   **`make test` failures**: Review the output of the failing tests. Common issues are incorrect `DEV_DOMAIN` in `.env` or `/etc/hosts`, or the CA not being trusted.