VIBE CODING WIP

# Traefik Docker Compose Edge Stack

This repository provides a flexible and easily extensible Docker Compose-based "edge stack" centered on [Traefik Proxy](https://traefik.io/) (latest stable version). It's designed for local development environments, making it easy to add new services, manage TLS certificates, and validate routing.

## Goal

The goal of this documentation is to enable a developer to:
- understand the architecture (networks, profiles, routing, TLS flow)
- run the stack successfully (Mode A quickstart)
- enable/operate TLS modes B/C safely
- integrate new services via labels and the proxy network
- diagnose common failures using documented commands and tests

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

For detailed requirements and host configuration, refer to the [Requirements documentation](docs/requirements.md).

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
    # Open .env and set DEV_DOMAIN, BASE_DOMAIN, LOOPBACK_X, ENDPOINTS as needed, then save.
    ```

3.  **Generate local self-signed certificates:**
    ```bash
    make certs-local
    ```

4.  **Map local subdomains to loopback (recommended):**
    ```bash
    make hosts-generate
    sudo make hosts-apply
    make hosts-status
    ```
    This uses `BASE_DOMAIN`, `LOOPBACK_X`, and `ENDPOINTS` from `.env` to generate a managed block in `/etc/hosts`.
    Keep `BASE_DOMAIN` aligned with `DEV_DOMAIN` unless you intentionally separate them.

5.  **Start the Docker Compose stack:**
    ```bash
    make up
    ```
    This automatically renders Traefik dynamic configuration based on `DEV_DOMAIN`.

6.  **Run smoke tests:**
    ```bash
    make test
    ```
    You should see output indicating that Traefik is ready, routing works, and the TLS handshake is successful.

7.  **Access the demo service:**
    Open your browser to `https://whoami.$DEV_DOMAIN`. You should see the `whoami` service's output, served over HTTPS.

## DNS Service (Technitium)

This stack includes an optional DNS service that becomes the single source of truth for project hostnames. It runs under the `dns` profile and exposes its UI only through Traefik at `https://dns.$BASE_DOMAIN`.

### Setup

1.  **Configure domain defaults in `.env`:**
    - `PROJECT_NAME` sets the default domain convention.
    - `BASE_DOMAIN` should be `${PROJECT_NAME}.aladroc.io`.
    - Keep `DEV_DOMAIN` aligned with `BASE_DOMAIN` unless you intentionally separate them.

2.  **Create BasicAuth credentials for the DNS UI:**
    ```bash
    cp services/traefik/auth/dns-ui.htpasswd.example services/traefik/auth/dns-ui.htpasswd
    # Replace with your own credentials:
    # htpasswd -nbB admin 'change-me' > services/traefik/auth/dns-ui.htpasswd
    ```

3.  **Start the DNS service:**
    ```bash
    make dns-up
    ```

4.  **Provision DNS records:**
    ```bash
    make dns-provision
    ```

5.  **Configure Ubuntu 24.04 split-DNS (requires sudo):**
    ```bash
    sudo make dns-config-apply
    ```
    To remove the configuration later:
    ```bash
    sudo make dns-config-remove
    ```

### Verification

```bash
resolvectl status
dig @127.0.0.1 dns.$BASE_DOMAIN
getent hosts whoami.$BASE_DOMAIN
curl -vk "https://dns.$BASE_DOMAIN/"
```

### Security Notes

- The DNS UI is exposed only via Traefik HTTPS and protected by BasicAuth.
- Port 53 is bound to localhost by default (`DNS_BIND_ADDRESS=127.0.0.1`). If another service uses port 53, change or stop it before enabling the DNS profile.
- To enable an IP allowlist, add `dns-ui-allowlist@docker` to `DNS_UI_MIDDLEWARES` and set `DNS_UI_ALLOWLIST_SOURCE_RANGES` in `.env`.

For a more detailed Quickstart, including host configuration and CA trust instructions, see [Quickstart: Local Self-Signed TLS](docs/quickstart-mode-a.md).

## Table of Contents

*   [**Documentation Index**](docs/00-index.md)
*   [**Repo Facts (Source of Truth)**](docs/90-facts.md)
*   [**Documentation Quality Checklist**](docs/98-doc-qa.md)
*   [**Style Guide**](docs/99-style-guide.md)
*   [**Glossary**](docs/99-glossary.md)

---

### Planned Documentation (Coming Soon)
*   Architecture Overview (planned)
*   Compose Usage & Profiles (planned)
*   Makefile & Scripts Operations (planned)
*   Service Documentation (planned)
    *   Traefik (planned)
    *   Whoami (planned)
    *   Certbot (planned)
    *   Step-CA (planned)
*   TLS Mode Guides (planned)
    *   Mode A: Local Self-Signed CA + Certificates (planned)
    *   Mode B: Let's Encrypt via Certbot (planned)
    *   Mode C: Smallstep `step-ca` as Internal ACME Server (planned)
*   How-to: Add a New Service (planned)
*   Testing & Troubleshooting (planned)
*   Troubleshooting (planned)

## Documentation

For comprehensive documentation, including detailed architecture, service configurations, TLS mode guides, and troubleshooting, please refer to the [Documentation Index](docs/00-index.md).

## Operating Principles

This documentation set adheres to the following principles:

1.  **“Explain then do”**: Brief concept, then exact steps.
2.  **Copy/paste first**: Commands and snippets must be runnable.
3.  **Secure-by-default**: Highlight safety decisions (dashboard, exposed ports, secrets).
4.  **Consistency**: Paths, variable names, commands, and terminology must match the repo.
5.  **Outcome-driven**: Every procedure includes “Expected result” and “How to verify”.
6.  **Troubleshooting embedded**: Each major guide ends with common pitfalls.
