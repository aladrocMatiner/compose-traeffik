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
*   `./certs/local-ca/`: Stores local self-signed CA certificate and key.
*   `./certs/local/`: Stores local self-signed leaf certificate and key.
*   `./certbot/conf/`: Used by Certbot for storing certificates and configurations.
*   `./certbot/www/`: Webroot for Certbot's HTTP-01 challenges.
*   `./step-ca/config/`: Configuration files for the Smallstep `step-ca` service.
*   `./step-ca/secrets/`: Sensitive keys and secrets for `step-ca`.
*   `./step-ca/data/`: Persistent data for `step-ca` (e.g., issued certificates database).
*   `./traefik/`: Traefik's main static configuration files.
*   `./traefik/dynamic/`: Traefik's dynamic configuration files (middlewares, TLS).
*   `./dns/data/`: Persistent data for the Technitium DNS service.

## Docker Compose

*   **Compose file(s) found**: `docker-compose.yml`
*   **Profiles found**:
    *   `le`: Enables the `certbot` service.
    *   `stepca`: Enables the `step-ca` service.
    *   `dns`: Enables the Technitium DNS service.
*   **Networks**:
    *   `traefik-proxy`: The main proxy network to which Traefik and exposed services connect. This is the "proxy" network.
    *   `stepca-internal`: An internal network for the `step-ca` service, isolating it from other services.

## Environment Variables (.env.example)

*   `PROJECT_NAME=compose-traeffik`: Project name used for default domain convention.
*   `DEV_DOMAIN=compose-traeffik.aladroc.io`: Base domain for local development.
*   `BASE_DOMAIN=compose-traeffik.aladroc.io`: Base domain for loopback subdomain mappings.
*   `LOOPBACK_X=10`: Loopback X octet for 127.0.X.Y assignments.
*   `ENDPOINTS=whoami,traefik,stepca`: Optional list of endpoints for mapping.
*   `TRAEFIK_IMAGE=traefik:v3.6.7`: Docker image tag for Traefik.
*   `TRAEFIK_DASHBOARD=false`: Toggle to enable/disable Traefik dashboard.
*   `HTTP_TO_HTTPS_REDIRECT=true`: Toggle for global HTTP to HTTPS redirection.
*   `ACME_EMAIL=you@example.com`: Email for ACME registrations (Let's Encrypt, step-ca).
*   `LETSENCRYPT_STAGING=true`: Toggle for Let's Encrypt staging environment (Certbot only).
*   `LETSENCRYPT_CA_SERVER=https://acme-staging-v02.api.letsencrypt.org/directory`: ACME directory URL for Traefik.
*   `STEP_CA_NAME="Local Dev CA"`: Name for the Smallstep CA.
*   `STEP_CA_ADMIN_PROVISIONER_PASSWORD="adminpassword"`: Password for `step-ca` admin provisioner (bootstrap only).
*   `STEP_CA_PASSWORD="capassword"`: Password for `step-ca` CA key (bootstrap only).
*   `DNS_BIND_ADDRESS=127.0.0.1`: Bind address for DNS port 53.
*   `DNS_UI_HOSTNAME=dns`: Hostname prefix for the DNS UI.
*   `DNS_ADMIN_PASSWORD=change-me`: Admin password for Technitium DNS web console.
*   `DNS_UI_BASIC_AUTH_HTPASSWD_PATH=./traefik/auth/dns-ui.htpasswd`: BasicAuth htpasswd path for DNS UI.
*   `DNS_UI_MIDDLEWARES=security-headers@file,dns-ui-auth@file`: Middlewares applied to DNS UI router.
*   `DNS_UI_ALLOWLIST_SOURCE_RANGES=127.0.0.1/32,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16`: Allowlist ranges (optional).
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
*   **DNS Service**:
    *   `dns-up`: Start DNS service (profile `dns`).
    *   `dns-down`: Stop DNS service.
    *   `dns-logs`: Follow DNS service logs.
    *   `dns-status`: Show DNS service status.
    *   `dns-provision`: Provision DNS records via API.
    *   `dns-provision-dry`: Dry-run DNS provisioning.
    *   `dns-config-apply`: Configure Ubuntu split-DNS (requires sudo).
    *   `dns-config-remove`: Remove Ubuntu split-DNS config (requires sudo).
    *   `dns-config-status`: Show Ubuntu split-DNS status.
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
*   `scripts/dns-provision.sh`: Provisions DNS records via the Technitium DNS API.
*   `scripts/dns-configure-ubuntu.sh`: Configures Ubuntu 24.04 split-DNS via systemd-resolved.

## Tests

*   `tests/smoke/test_traefik_ready.sh`: Checks if Traefik's API/health endpoint is reachable.
*   `tests/smoke/test_routing.sh`: Verifies that `whoami` service routing works.
*   `tests/smoke/test_tls_handshake.sh`: Checks TLS handshake and certificate details for `whoami`.
*   `tests/smoke/test_http_redirect.sh`: Conditionally verifies HTTP to HTTPS redirection.
*   `tests/smoke/test_dns_provision.sh`: Verifies DNS provisioning dry-run output.
*   `tests/smoke/test_dns_configure_ubuntu.sh`: Verifies DNS config script dry-run output.
*   `tests/smoke/test_dns_service_config.sh`: Verifies DNS service compose configuration.

## TLS Artifacts (Paths)

*   **Mode A (Self-Signed)**:
    *   CA: `certs/local-ca/ca.key`, `certs/local-ca/ca.crt`
    *   Leaf: `certs/local/privkey.pem`, `certs/local/fullchain.pem`
*   **Mode B (Certbot)**:
    *   Certbot working directory: `certbot/conf/`
    *   Certbot webroot: `certbot/www/`
*   **Mode C (Step-CA)**:
    *   Config: `step-ca/config/`
    *   Secrets: `step-ca/secrets/`
    *   Data: `step-ca/data/`
