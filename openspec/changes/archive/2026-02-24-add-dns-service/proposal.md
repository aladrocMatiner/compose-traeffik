# Change: Add DNS service, secure UI, and Ubuntu DNS config helpers

## Why
Local hostname management is currently split across hosts-file tooling and manual edits. A dedicated DNS service with a secure UI and automation scripts will centralize hostname records, simplify local resolution, and make onboarding consistent for Ubuntu 24.04.

## What Changes
- Add a DNS service (Technitium DNS Server) behind Traefik with HTTPS-only UI at `dns.<BASE_DOMAIN>` and default BasicAuth protection.
- Introduce `PROJECT_NAME` and domain convention defaults for `BASE_DOMAIN` in `.env.example`.
- Add DNS provisioning and Ubuntu split-DNS configuration scripts with dry-run support.
- Add Makefile targets for DNS service lifecycle, provisioning, and systemd-resolved configuration.
- Add docs and tests for provisioning and DNS config scripts (no sudo required).

## Impact
- Affected specs: dns-service, dns-provisioning, dns-ubuntu-config
- Affected code: docker-compose.yml, traefik/dynamic/middlewares.yml, dns/**, scripts/dns-provision.sh, scripts/dns-configure-ubuntu.sh, .env.example, Makefile, README.md or docs, tests
