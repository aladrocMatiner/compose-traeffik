# Traefik Docker Compose Edge Stack

This repository provides a flexible and easily extensible Docker Compose-based "edge stack" centered on [Traefik Proxy](https://traefik.io/) (latest stable version). It's designed for local development environments, making it easy to add new services, manage TLS certificates, and validate routing.

## Table of Contents

-   [Features](#features)
-   [Requirements](#requirements)
-   [Quickstart (Mode A: Local Self-Signed TLS)](#quickstart-mode-a-local-self-signed-tls)
-   [How to Add a New Service](#how-to-add-a-new-service)
-   [TLS Modes](#tls-modes)
    -   [Mode A: Local Self-Signed CA + Certificates](#mode-a-local-self-signed-ca--certificates)
    -   [Mode B: Let's Encrypt via Certbot](#mode-b-lets-encrypt-via-certbot)
    -   [Mode C: Smallstep `step-ca` as Internal ACME Server](#mode-c-smallstep-step-ca-as-internal-acme-server)
-   [Troubleshooting](#troubleshooting)
-   [Makefile Reference](#makefile-reference)

## Features

*   **Traefik Proxy**: Configured as a reverse proxy for Docker services.
*   **Demo Service (`whoami`)**: A simple service to validate Traefik routing.
*   **Dedicated Proxy Network**: Isolates Traefik and routed services on a `traefik-proxy` network.
*   **Three TLS Modes**:
    *   **Mode A (Default)**: Local self-signed certificates for development.
    *   **Mode B (Optional)**: Let's Encrypt integration via Certbot.
    *   **Mode C (Optional)**: Internal ACME server using Smallstep `step-ca`.
*   **Developer-Friendly**: `Makefile` and helper scripts for common operations.
*   **Security-by-Default**: Traefik dashboard disabled by default, no accidental public port exposures.
*   **Modular Configuration**: Traefik static and dynamic configurations are separated.
*   **Testing**: Smoke tests to quickly verify stack health, routing, and TLS.

## Requirements

Before you begin, ensure you have the following installed:

*   **Docker**: [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine.
*   **Docker Compose**: Typically bundled with Docker Desktop or installed separately.
*   **`make`**: Usually available on Linux/macOS.
*   **`curl`**: For testing HTTP/HTTPS endpoints.
*   **`openssl`**: For generating local certificates and testing TLS handshakes.

**Important Host Configuration:**

For local development, you'll need to map your chosen `DEV_DOMAIN` (defined in `.env`) to `127.0.0.1` in your operating system's hosts file.

**Linux/macOS:**
Edit `/etc/hosts` (you'll need `sudo`):
```bash
sudo nano /etc/hosts
# Add the following line (replace DEV_DOMAIN with your configured value from .env)
# 127.0.0.1 whoami.<DEV_DOMAIN> traefik.<DEV_DOMAIN> step-ca.<DEV_DOMAIN>
# Example:
# 127.0.0.1 whoami.local.test traefik.local.test step-ca.local.test
```

**Windows:**
Edit `C:\Windows\System32\drivers\etc\hosts` as Administrator.

## Quickstart (Mode A: Local Self-Signed TLS)

This quickstart guides you through setting up the stack with locally generated self-signed certificates.

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Copy the example environment file:**
    ```bash
    cp .env.example .env
    # Open .env and adjust DEV_DOMAIN if desired, then save.
    # Make sure to update your /etc/hosts file as described in Requirements.
    ```

3.  **Generate local self-signed certificates:**
    ```bash
    make certs-local
    ```
    This will create a local CA and issue a certificate for `whoami.<DEV_DOMAIN>` (and other domains needed for the stack) in the `certs/local/` directory.

4.  **Start the Docker Compose stack:**
    ```bash
    make up
    ```
    This will bring up Traefik and the `whoami` demo service.

5.  **Run smoke tests:**
    ```bash
    make test
    ```
    You should see output indicating that Traefik is ready, routing works, and the TLS handshake is successful.

6.  **Access the demo service:**
    Open your browser to `https://whoami.<DEV_DOMAIN>`. You should see the `whoami` service's output, served over HTTPS.

## How to Add a New Service

To add a new service to the stack and expose it via Traefik:

1.  **Add your service to `docker-compose.yml`:**
    ```yaml
    # Example snippet for a new service
    my-new-service:
      image: your/service-image
      container_name: my-new-service
      restart: unless-stopped
      networks:
        - proxy # Crucial: connect to the shared proxy network
      labels:
        - "traefik.enable=true"
        # Optional: HTTP to HTTPS redirect
        - "traefik.http.routers.my-new-service-http.rule=Host(`my-new-service.${DEV_DOMAIN}`)"
        - "traefik.http.routers.my-new-service-http.entrypoints=web"
        - "traefik.http.routers.my-new-service-http.middlewares=redirect-to-https@file"
        # HTTPS router
        - "traefik.http.routers.my-new-service-https.rule=Host(`my-new-service.${DEV_DOMAIN}`)"
        - "traefik.http.routers.my-new-service-https.entrypoints=websecure"
        - "traefik.http.routers.my-new-service-https.service=my-new-service-service"
        - "traefik.http.routers.my-new-service-https.tls=true"
        # Apply the correct certificate resolver based on active profile (or leave empty for Mode A)
        - "traefik.http.routers.my-new-service-https.tls.certresolver=${TLS_CERT_RESOLVER:-}"
        # Service definition (replace 80 with your service's internal port)
        - "traefik.http.services.my-new-service-service.loadbalancer.server.port=80"
        # Apply security headers middleware
        - "traefik.http.routers.my-new-service-https.middlewares=security-headers@file"
    ```

2.  **Update `.env` and `/etc/hosts`**:
    Add `my-new-service.<DEV_DOMAIN>` to your `/etc/hosts` file.

3.  **Restart the stack:**
    ```bash
    make restart
    ```

## TLS Modes

This stack supports three distinct TLS certificate management modes, activated using Docker Compose profiles.

### Mode A: Local Self-Signed CA + Certificates (Default)

This mode is ideal for local development as it doesn't require a public domain or exposing ports to the internet.

**How it works:**
The `certs-selfsigned-generate.sh` script creates a root Certificate Authority (CA) and then uses it to issue a leaf certificate for `whoami.<DEV_DOMAIN>`, `traefik.<DEV_DOMAIN>`, and `step-ca.<DEV_DOMAIN>`. These certificates are mounted into Traefik, which then uses them to serve HTTPS.

**To use:**
1.  Ensure `DEV_DOMAIN` is configured in `.env` and `/etc/hosts` is updated.
2.  Run `make certs-local`.
3.  Run `make up`.
4.  **Trust the CA**: Since these are self-signed, your browser won't trust them by default. You'll need to manually trust the generated `certs/local-ca/ca.crt` file in your operating system's trust store. Refer to your OS documentation for exact steps (e.g., Keychain Access on macOS, Certificate Manager on Windows, `update-ca-certificates` on Linux).

### Mode B: Let's Encrypt via Certbot

This mode allows you to obtain publicly trusted certificates using Let's Encrypt. It requires a publicly accessible domain and open ports 80/443 to the internet.

**How it works:**
The `le` Docker Compose profile adds a `certbot` service. This service uses the HTTP-01 challenge to prove domain ownership. Once verified, Certbot obtains the certificates and stores them in `certbot/conf/`. Traefik is then configured to use these certificates via its file provider or directly via ACME.

**To enable:**

1.  **Configure `.env`**:
    ```ini
    ACME_EMAIL=your_email@example.com
    LETSENCRYPT_STAGING=true # Set to false for production certs
    # Set TLS_CERT_RESOLVER to tell Traefik to use its ACME resolver
    TLS_CERT_RESOLVER=le-resolver
    ```
2.  **Bring up the stack with the `le` profile**:
    ```bash
    COMPOSE_PROFILES=le make up
    ```
3.  **Issue certificates:**
    ```bash
    make certs-le-issue
    ```
    Follow any prompts from Certbot. Traefik should then pick up the new certificates.

4.  **Renew certificates:**
    Let's Encrypt certificates are short-lived. Set up a cron job or similar automation to run:
    ```bash
    COMPOSE_PROFILES=le make certs-le-renew
    ```
    This command can typically be run without stopping the main stack. Traefik will automatically pick up renewed certificates.

**Important Considerations for Mode B:**
*   You must own and control the `DEV_DOMAIN` and `step-ca.<DEV_DOMAIN>` domain names and point them to your server's public IP.
*   Ports 80 and 443 must be open to the internet for Certbot to complete the HTTP-01 challenge.
*   Start with `LETSENCRYPT_STAGING=true` to avoid hitting rate limits while testing.

### Mode C: Smallstep `step-ca` as Internal ACME Server

This mode provides a private Certificate Authority using [Smallstep `step-ca`](https://smallstep.com/docs/step-ca/) that acts as an ACME server. It's useful for internal services, private networks, or scenarios where public trust isn't required, but automated certificate management is desired.

**How it works:**
The `stepca` Docker Compose profile brings up a `step-ca` service. This service is bootstrapped to create a private CA and an ACME provisioner. Traefik is then configured to use its ACME client, but instead of talking to Let's Encrypt, it talks to the internal `step-ca` service's ACME endpoint to issue certificates.

**To enable:**

1.  **Configure `.env`**:
    ```ini
    # Set the passwords for bootstrapping (these are only used during bootstrap, not by the running CA)
    STEP_CA_ADMIN_PROVISIONER_PASSWORD="your_admin_password"
    STEP_CA_PASSWORD="your_ca_password"
    # Set TLS_CERT_RESOLVER to tell Traefik to use its ACME resolver
    TLS_CERT_RESOLVER=stepca-resolver
    ```
2.  **Bring up and bootstrap the `step-ca` service:**
    ```bash
    COMPOSE_PROFILES=stepca make up step-ca # Start the step-ca service first
    make stepca-bootstrap                   # Then bootstrap it
    # Note: `make stepca-bootstrap` will also start the CA if not already running.
    ```
    This script will initialize the CA, create an ACME provisioner, and print out important information, including the ACME Directory URL and instructions to trust the `step-ca` root certificate.

3.  **Bring up the full stack with the `stepca` profile:**
    ```bash
    COMPOSE_PROFILES=stepca make up
    ```
    Traefik will now attempt to obtain certificates for `whoami.<DEV_DOMAIN>`, `traefik.<DEV_DOMAIN>`, and `step-ca.<DEV_DOMAIN>` from your internal `step-ca` server.

4.  **Trust the `step-ca` Root Certificate**:
    Similar to Mode A, your system/browser won't trust the `step-ca` root by default. You will need to trust `step-ca/config/ca.crt` on your local machine. The `stepca-bootstrap.sh` script will guide you on where to find this file.

**Important Considerations for Mode C:**
*   `step-ca` runs on an internal Docker network, and Traefik acts as a reverse proxy for it.
*   The `stepca-bootstrap.sh` script is critical for initial setup. If you lose the `step-ca/secrets` volume, you'll need to re-bootstrap.

## Troubleshooting

*   **`Error: DEV_DOMAIN not set`**: Ensure you have copied `.env.example` to `.env` and set `DEV_DOMAIN`.
*   **`SSL_ERROR_BAD_CERT_DOMAIN` or `NET::ERR_CERT_AUTHORITY_INVALID`**:
    *   For Mode A or C: You likely haven't trusted the generated CA certificate on your local machine. Follow the instructions under "Trust the CA" for each mode.
    *   For Mode B: Check if your domain is correctly pointing to your server's IP, and if ports 80/443 are open. Ensure `ACME_EMAIL` is set.
*   **`whoami.<DEV_DOMAIN>` does not resolve**: Check your `/etc/hosts` file (or Windows equivalent) and ensure it contains the correct mapping for `whoami.<DEV_DOMAIN>` and other stack domains to `127.0.0.1`.
*   **Service not reachable**:
    *   Check `make logs` for Traefik and your service containers for errors.
    *   Verify Traefik labels on your service in `docker-compose.yml`.
    *   Ensure your service is connected to the `proxy` network.
*   **`make certs-le-issue` fails**: Check `certbot` logs (`COMPOSE_PROFILES=le make logs certbot`). Common issues: firewall, incorrect DNS, rate limits (use staging).
*   **`stepca-bootstrap.sh` fails**: Check `step-ca` logs (`COMPOSE_PROFILES=stepca make logs step-ca`). Ensure passwords are set in `.env` for bootstrap.

## Makefile Reference

Refer to `make help` for an up-to-date list of all available commands and their descriptions.

```bash
make help
```