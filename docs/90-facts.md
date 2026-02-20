# Repo Facts (Source of Truth)

This document provides a concise, factual overview of the current state of the repository, serving as a single source of truth for documentation efforts. It is grounded in the latest repository discovery.

---

## Overview

This repository sets up a Docker Compose-based Traefik edge stack, integrating a demo service, local self-signed TLS, and optional Let's Encrypt (Certbot) and Smallstep `step-ca` configurations.

## Directory Map (Key Directories)

*   `./`: Repository root, containing main configuration files.
*   `./docs/`: Main documentation directory.
*   `./scripts/`: Contains helper bash scripts for various operations.
*   `./tests/smoke/`: Houses executable smoke test scripts.
*   `./shared/certs/local-ca/`: Stores local self-signed CA certificate and key.
*   `./shared/certs/local/`: Stores local self-signed leaf certificate and key.
*   `./services/certbot/conf/`: Used by Certbot for storing certificates and configurations.
*   `./services/certbot/www/`: Webroot for Certbot's HTTP-01 challenges.
*   `./services/step-ca/config/`: Configuration files for the Smallstep `step-ca` service.
*   `./services/step-ca/secrets/`: Sensitive keys and secrets for `step-ca`.
*   `stepca-data/`: Persistent data for `step-ca` (e.g., issued certificates database, stored in a named volume).
*   `./services/traefik/`: Traefik's main static configuration files.
*   `./services/traefik/dynamic/`: Traefik's dynamic configuration files (middlewares, TLS).
*   `./services/dns-bind/config/`: BIND configuration templates.
*   `./services/dns-bind/zones/`: BIND zone files.

## Docker Compose

*   **Compose file(s) found**: `compose/base.yml` plus `services/<service>/compose.yml` fragments (layered via `scripts/compose.sh` or `docker compose -f compose/base.yml -f services/...`).
*   **Profiles found**:
    *   `le`: Enables the `certbot` service.
    *   `stepca`: Enables the `step-ca` service.
    *   `bind`: Enables the BIND DNS service.
*   **Networks**:
    *   `traefik-proxy`: The main proxy network to which Traefik and exposed services connect. This is the "proxy" network.
    *   `stepca-internal`: An internal network for the `step-ca` service, isolating it from other services.

## Environment Variables (.env.example)

*   `PROJECT_NAME=compose-traeffik`: Project name used for default domain convention.
*   `DEV_DOMAIN=local.test`: Base domain for local development.
*   `BASE_DOMAIN=local.test`: Base domain for loopback subdomain mappings.
*   `LOOPBACK_X=10`: Loopback X octet for 127.0.X.Y assignments.
*   `ENDPOINTS=whoami,traefik,stepca`: Optional list of endpoints for mapping.
*   `TRAEFIK_IMAGE=traefik:v3.6.7`: Docker image tag for Traefik.
*   `TRAEFIK_DASHBOARD=true`: Toggle to enable/disable Traefik dashboard.
*   `HTTP_TO_HTTPS_REDIRECT=true`: Toggle for global HTTP to HTTPS redirection.
*   `ACME_EMAIL=you@example.com`: Email for ACME registrations (Let's Encrypt, step-ca).
*   `LETSENCRYPT_STAGING=true`: Toggle for Let's Encrypt staging environment (Certbot only).
*   `LETSENCRYPT_CA_SERVER=https://acme-staging-v02.api.letsencrypt.org/directory`: ACME directory URL for Traefik.
*   `CA_NAME="Local Dev CA"`: Shared CA name (used by Mode A and Mode C).
*   `CA_SUBJECT_*`: Shared CA subject fields (Mode A).
*   `CA_DNS`/`CA_IPS`: Shared CA DNS/IP list (Mode C, and Mode A defaults).
*   `LEAF_*`: Shared leaf subject/SAN overrides (Mode A).
*   `STEP_CA_NAME="Local Dev CA"`: Legacy name for the Smallstep CA (used if `CA_NAME` is unset).
*   `STEP_CA_ADMIN_PROVISIONER_PASSWORD="adminpassword"`: Password for `step-ca` admin provisioner (bootstrap only).
*   `STEP_CA_PASSWORD="capassword"`: Password for `step-ca` CA key (bootstrap only).
*   `BIND_BIND_ADDRESS=127.0.0.1`: Bind address for BIND port 53.
*   `TLS_CERT_RESOLVER=`: Specifies the Traefik ACME certificate resolver to use (`le-resolver` or `stepca-resolver`).
*   `COMPOSE_PROFILES=`: Used to activate Docker Compose profiles.

## Makefile

*   **Lifecycle**: `up`, `down`, `restart`, `ps`
*   **Logs**: `logs`
*   **Certificate Management**:
    *   `certs-local`: Generate local self-signed certificates (Mode A).
    *   `certs-le-issue`: Issue Let's Encrypt certificates (Mode B).
    *   `certs-le-renew`: Renew Let's Encrypt certificates (Mode B).
    *   `stepca-up`: Start `step-ca` service (Mode C).
    *   `stepca-down`: Stop `step-ca` service (Mode C).
    *   `stepca-bootstrap`: Bootstrap `step-ca` server (Mode C).
    *   `stepca-trust-install`: Install Step-CA root CA into Ubuntu trust store.
    *   `stepca-trust-uninstall`: Remove Step-CA root CA from Ubuntu trust store.
    *   `stepca-trust-verify`: Verify Step-CA root CA trust on Ubuntu.
*   **Bind DNS**:
    *   `bind-up`: Start BIND service (profile `bind`).
    *   `bind-down`: Stop BIND service.
    *   `bind-logs`: Follow BIND service logs.
    *   `bind-status`: Show BIND service status.
    *   `bind-provision`: Generate BIND zone file from ENDPOINTS.
    *   `bind-provision-dry`: Dry-run BIND zone generation.
*   **Testing**: `test`
*   **Help**: `help`

## Scripts

*   `scripts/common.sh`: Common utility functions (logging, env loading, checks).
*   `scripts/up.sh`: Starts Docker Compose stack.
*   `scripts/down.sh`: Stops and removes Docker Compose stack.
*   `scripts/logs.sh`: Shows real-time Docker Compose logs.
*   `scripts/healthcheck.sh`: Orchestrates running all smoke tests.
*   `scripts/certs-selfsigned-generate.sh`: Generates local CA and leaf certificates for Mode A.
*   `scripts/certbot-issue.sh`: Issues new Let's Encrypt certificates using Certbot. **Note**: Currently hardcodes domains for issuance.
*   `scripts/certbot-renew.sh`: Renews existing Let's Encrypt certificates using Certbot. **Note**: Currently hardcodes domains for renewal.
*   `scripts/stepca-bootstrap.sh`: Initializes and configures the Smallstep `step-ca` server.
*   `scripts/stepca-trust-install.sh`: Installs Step-CA root certificate into the Ubuntu trust store.
*   `scripts/stepca-trust-uninstall.sh`: Removes Step-CA root certificate from the Ubuntu trust store.
*   `scripts/stepca-trust-verify.sh`: Verifies OS trust for the Step-CA root certificate.
*   `scripts/bind-provision.sh`: Generates a BIND zone file from ENDPOINTS.

## Tests

*   `tests/smoke/test_traefik_ready.sh`: Checks if Traefik's API/health endpoint is reachable.
*   `tests/smoke/test_routing.sh`: Verifies that `whoami` service routing works.
*   `tests/smoke/test_tls_handshake.sh`: Checks TLS handshake and certificate details for `whoami`.
*   `tests/smoke/test_http_redirect.sh`: Conditionally verifies HTTP to HTTPS redirection.
*   `tests/smoke/test_bind_service_config.sh`: Verifies BIND service compose configuration.

## TLS Artifacts (Paths)

*   **Mode A (Self-Signed)**:
    *   CA: `shared/certs/local-ca/ca.key`, `shared/certs/local-ca/ca.crt`
    *   Leaf: `shared/certs/local/privkey.pem`, `shared/certs/local/fullchain.pem`
*   **Mode B (Certbot)**:
    *   Certbot working directory: `services/certbot/conf/`
    *   Certbot webroot: `services/certbot/www/`
*   **Mode C (Step-CA)**:
    *   Config: `services/step-ca/config/`
    *   Secrets: `services/step-ca/secrets/`
    *   Data: `stepca-data/`
