# Documentation Index

Welcome to the documentation for the **Traefik Docker Compose Edge Stack**!

This documentation provides comprehensive guides for setting up, configuring, and extending your local development environment with Traefik Proxy, various TLS certificate management modes, and helper scripts.

---

## Getting Started

### Start Here: Quickstart (Mode A - Local Self-Signed TLS)

To get your stack up and running quickly with locally generated self-signed certificates, follow these steps:

1.  **Copy the example environment file:**
    ```bash
    cp .env.example .env
    ```
    *Ensure you update your `/etc/hosts` file as described in the `Requirements` section of the main `README.md`.*
2.  **Generate local self-signed certificates:**
    ```bash
    make certs-local
    ```
3.  **Start the Docker Compose stack:**
    ```bash
    make up
    ```
4.  **Run smoke tests to verify:**
    ```bash
    make test
    ```
    You should see output indicating that Traefik is ready, routing works, and the TLS handshake is successful.
5.  **Access the demo service:**
    Open your browser to `https://whoami.local.test`. You should see the `whoami` service's output, served over HTTPS.

    > **Warning about Traefik Dashboard:**
    > If you enable the Traefik dashboard by setting `TRAEFIK_DASHBOARD=true` in your `.env` file, it becomes accessible at `https://traefik.local.test/dashboard/`. Be aware that for local development convenience, the dashboard API is configured with `insecure: true`, meaning it has **no authentication**. Do not expose this publicly.

---

## Table of Contents

This is an overview of the documentation available and what's coming next.

### Foundational Guides
*   [Repo Facts (Source of Truth)](90-facts.md)
*   [Documentation Quality Checklist](98-doc-qa.md)
*   [Style Guide](99-style-guide.md) - How to write consistent and high-quality documentation.
*   [Glossary](99-glossary.md) - Definitions for key terms and concepts used in this repository.

### Core Documentation (Planned)
*   Architecture Overview (planned: 01-architecture.md)
*   Compose Usage & Profiles (planned: 02-compose-usage.md)
*   Makefile & Scripts Operations (planned: 03-make-and-scripts.md)
*   Service Documentation
    *   Traefik (planned: 04-services/traefik.md)
    *   Whoami (planned: 04-services/whoami.md)
    *   Certbot (planned: 04-services/certbot.md)
    *   Step-CA (planned: 04-services/step-ca.md)
*   TLS Mode Guides
    *   Mode A: Local Self-Signed CA + Certificates (planned: 05-tls/mode-a-selfsigned.md)
    *   Mode B: Let's Encrypt via Certbot (planned: 05-tls/mode-b-letsencrypt-certbot.md)
    *   Mode C: Smallstep `step-ca` as Internal ACME Server (planned: 05-tls/mode-c-stepca-acme.md)
*   How-to: Add a New Service (planned: 06-howto/add-a-service.md)
*   Testing & Troubleshooting (planned: 07-testing.md)
*   Troubleshooting (planned: 08-troubleshooting.md)
