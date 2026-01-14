# Compose, Make & Scripts Usage

**Role: DevOps UX Engineer**
*Mission: Document how to operate the repository via Makefile and helper scripts, including environment variables and Docker Compose profiles.*

This guide explains the operational aspects of the Traefik edge stack, focusing on the `Makefile` targets, environment variables, and helper scripts that simplify common workflows.

<h2>Environment Variables</h2>

The `.env` file at the root of the repository is crucial for configuring the stack. It contains variables that customize domain names, email addresses for ACME, and passwords for `step-ca`.

<h3>Key Environment Variables</h3>

*   **`DEV_DOMAIN`**: The base domain used for all services in your local development environment (e.g., `local.test`). This variable is referenced throughout `docker-compose.yml` and by various scripts.
*   **`ACME_EMAIL`**: (Used in TLS Mode B) The email address for Let's Encrypt registration.
*   **`LETSENCRYPT_STAGING`**: (Used in TLS Mode B) Set to `true` for testing with Let's Encrypt's staging environment, `false` for production certificates.
*   **`TLS_CERT_RESOLVER`**: Determines which Traefik ACME resolver to use (`le-resolver` for Let's Encrypt or `stepca-resolver` for `step-ca`). If empty, Traefik will rely on file-based certificates (Mode A).
*   **`STEP_CA_ADMIN_PROVISIONER_PASSWORD`**, **`STEP_CA_PASSWORD`**: (Used in TLS Mode C) Passwords required for bootstrapping the `step-ca` service.

<h2>Docker Compose Profiles (`COMPOSE_PROFILES`)</h2>

Docker Compose profiles allow you to selectively enable services based on your operational needs. This repository uses profiles to activate different TLS modes or specific tools.

To activate a profile, you typically prefix your `make` command with `COMPOSE_PROFILES=<profile_name>`.

<h3>Common Profiles</h3>

*   **`le`**: Activates services related to Let's Encrypt integration (e.g., the `certbot` container if used). Used with TLS Mode B.
    *   Example: `COMPOSE_PROFILES=le make up`
*   **`stepca`**: Activates services related to Smallstep `step-ca` (e.g., the `step-ca` container). Used with TLS Mode C.
    *   Example: `COMPOSE_PROFILES=stepca make up`

You can combine profiles by separating them with commas (e.g., `COMPOSE_PROFILES=le,monitoring make up`).

<h2>Makefile Reference</h2>

The `Makefile` provides a convenient interface for managing the Docker Compose stack. It orchestrates Docker Compose commands and executes helper scripts.

<h3>Accessing Help</h3>

To see a list of all available `make` targets and their descriptions, run:

```bash
make help
```

<h3>Common Make Targets and Workflows</h3>

Here are some frequently used `make` targets:

*   **`make up`**:
    *   **Description**: Starts the Docker Compose stack in detached mode. By default, it brings up Traefik and the `whoami` demo service.
    *   **Example**: `make up`
    *   **Idempotency**: Can be run multiple times; it will only create/start services that are not already running.

*   **`make down`**:
    *   **Description**: Stops and removes all containers, networks, and volumes defined in `docker-compose.yml` for the default services.
    *   **Example**: `make down`
    *   **Idempotency**: Safe to run even if services are not running.

*   **`make restart`**:
    *   **Description**: Restarts all services in the stack. Useful after making changes to `docker-compose.yml` or `.env`.
    *   **Example**: `make restart`

*   **`make logs [service_name]`**:
    *   **Description**: Displays aggregated logs from all running services, or logs for a specific service if `service_name` is provided.
    *   **Example (all logs)**: `make logs`
    *   **Example (Traefik logs)**: `make logs traefik`

*   **`make test`**:
    *   **Description**: Runs the smoke tests located in the `tests/smoke/` directory to verify stack health, routing, and TLS.
    *   **Example**: `make test`
    *   **Expected Outcome**: All tests pass if the stack is correctly configured.

*   **`make certs-local`**:
    *   **Description**: Generates local self-signed certificates and a CA for TLS Mode A.
    *   **Example**: `make certs-local`
    *   **Script**: Internally calls `scripts/certs-selfsigned-generate.sh`.

*   **`make certs-le-issue`**:
    *   **Description**: (TLS Mode B) Issues certificates via Certbot for Let's Encrypt.
    *   **Example**: `COMPOSE_PROFILES=le make certs-le-issue`
    *   **Script**: Internally calls `scripts/certbot-issue.sh`.

*   **`make certs-le-renew`**:
    *   **Description**: (TLS Mode B) Renews Let's Encrypt certificates via Certbot.
    *   **Example**: `COMPOSE_PROFILES=le make certs-le-renew`
    *   **Script**: Internally calls `scripts/certbot-renew.sh`.

*   **`make stepca-bootstrap`**:
    *   **Description**: (TLS Mode C) Bootstraps the Smallstep `step-ca` service, initializing its CA and ACME provisioner.
    *   **Example**: `COMPOSE_PROFILES=stepca make stepca-bootstrap`
    *   **Script**: Internally calls `scripts/stepca-bootstrap.sh`.

<h2>Helper Scripts</h2>

The `scripts/` directory contains various bash scripts that automate complex tasks. These scripts are typically invoked by `make` targets but can also be run directly if needed.

*   `scripts/certs-selfsigned-generate.sh`: Automates the creation of self-signed certificates.
*   `scripts/certbot-issue.sh`: Handles the issuance of certificates using Certbot.
*   `scripts/certbot-renew.sh`: Manages the renewal process for Certbot certificates.
*   `scripts/stepca-bootstrap.sh`: Initializes the Smallstep `step-ca` instance.
*   `scripts/common.sh`: Contains common functions and variables used by other scripts.
*   `scripts/up.sh`, `scripts/down.sh`, `scripts/logs.sh`: Wrappers around Docker Compose commands, sometimes adding extra logic.
*   `scripts/healthcheck.sh`: Used by `make test` to verify service health.

<h2>Idempotency and Safe Defaults</h2>

*   **Idempotency**: Most `make` targets and scripts are designed to be idempotent, meaning you can run them multiple times without causing unintended side effects (e.g., `make up` will only start services that are not running).
*   **Safe Defaults**: The repository is configured with security in mind:
    *   Traefik dashboard is disabled by default.
    *   No accidental public port exposures beyond standard HTTP/HTTPS.
    *   Local certificates for development are isolated.

<h2>Common Pitfalls</h2>

*   **Missing `.env` file**: Ensure you have copied `.env.example` to `.env` and populated necessary variables.
*   **Incorrect `COMPOSE_PROFILES`**: If a service isn't starting, verify that you are activating the correct Docker Compose profile.
*   **Permissions issues with scripts**: Ensure the scripts have execute permissions (`chmod +x scripts/*.sh`).
*   **`make` command not found**: Ensure `make` is installed and in your system's PATH.
