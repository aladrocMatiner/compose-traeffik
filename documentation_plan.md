# Documentation Plan for Traefik Docker Compose Edge Stack

This document outlines the documentation delivery plan for the existing Traefik Docker Compose edge stack repository, structured as Epics, Changes, and Tasks, including dependencies and acceptance criteria. The plan is grounded in a thorough discovery of the repository's current state.

## A) Discovery Summary

**Canonical certs path:** `CERTS_DIR = shared/certs/`

Based on the repository scan, the following key facts have been identified:

*   **File Structure**:
*   **Root**: `.env.example`, `Makefile`, `README.md`, `compose/base.yml`, `services/<service>/compose.yml`
    *   **Configuration**: `traefik/traefik.yml`, `traefik/dynamic/middlewares.yml`, `traefik/dynamic/tls.yml`
    *   **Scripts**: `scripts/common.sh`, `scripts/up.sh`, `scripts/down.sh`, `scripts/logs.sh`, `scripts/healthcheck.sh`, `scripts/certs-selfsigned-generate.sh`, `scripts/certbot-issue.sh`, `scripts/certbot-renew.sh`, `scripts/stepca-bootstrap.sh`
    *   **Tests**: `tests/README.md`, `tests/smoke/test_http_redirect.sh`, `tests/smoke/test_routing.sh`, `tests/smoke/test_tls_handshake.sh`, `tests/smoke/test_traefik_ready.sh`
*   **TLS Assets (dirs)**: `shared/certs/local-ca`, `shared/certs/local`, `certbot/conf`, `certbot/www`, `step-ca/config`, `step-ca/secrets`, `step-ca/data`

*   **Docker Compose Details**:
    *   **Profiles**: `le`, `stepca`
    *   **Networks**: `traefik-proxy` (bridge), `stepca-internal` (internal bridge)
    *   **Services**: `traefik`, `whoami` (default), `certbot` (profile `le`), `step-ca` (profile `stepca`)
    *   **Volumes**: `traefik-certs-data` (for ACME storage), `stepca-data` (for `step-ca` persistence)

*   **Environment Variables (`.env.example`)**:
    *   `DEV_DOMAIN=local.test`
    *   `TRAEFIK_IMAGE=traefik:v3.0`
    *   `TRAEFIK_DASHBOARD=false`
    *   `HTTP_TO_HTTPS_REDIRECT=true`
    *   `ACME_EMAIL=you@example.com`
    *   `LETSENCRYPT_STAGING=true`
    *   `STEP_CA_NAME="Local Dev CA"`
    *   `STEP_CA_ADMIN_PROVISIONER_PASSWORD="adminpassword"`
    *   `STEP_CA_PASSWORD="capassword"`
    *   `TLS_CERT_RESOLVER=`
    *   `COMPOSE_PROFILES=`

*   **Make Targets (`Makefile`)**:
    *   `help`, `up`, `down`, `restart`, `logs`, `ps`, `test`
    *   `certs-local`
    *   `certs-le-issue`, `certs-le-renew`
    *   `stepca-up`, `stepca-down`, `stepca-bootstrap`

*   **Script Functions**:
    *   `scripts/common.sh`: Provides logging, env loading, command checks.
    *   `scripts/up.sh`: Wraps `docker compose up -d`.
    *   `scripts/down.sh`: Wraps `docker compose down`.
    *   `scripts/logs.sh`: Wraps `docker compose logs -f`.
    *   `scripts/healthcheck.sh`: Orchestrates running all `tests/smoke/*.sh`.
    *   `scripts/certs-selfsigned-generate.sh`: Generates local CA and leaf certs for Mode A using `openssl`.
    *   `scripts/certbot-issue.sh`: Executes `certbot certonly` for Mode B.
    *   `scripts/certbot-renew.sh`: Executes `certbot renew` for Mode B.
    *   `scripts/stepca-bootstrap.sh`: Initializes and configures `step-ca` for Mode C.

*   **Certificate Storage Locations**:
    *   **Mode A (Self-Signed)**:
        *   CA: `shared/certs/local-ca/ca.crt`, `shared/certs/local-ca/ca.key`
        *   Leaf: `shared/certs/local/fullchain.pem`, `shared/certs/local/privkey.pem` (mounted to `/etc/certs/local` in Traefik)
    *   **Mode B (Let's Encrypt via Certbot)**:
        *   Certbot working dir: `certbot/conf/` (mounted to `/etc/letsencrypt` in Certbot)
        *   Traefik ACME storage: `traefik-certs-data` volume (stores `acme-le.json` at `/certs/acme-le.json`)
    *   **Mode C (Step-CA)**:
        *   Step-CA config/secrets/data: `step-ca/config`, `step-ca/secrets`, `step-ca/data` (mounted to `/home/step/...` in `step-ca`)
        *   Traefik ACME storage: `traefik-certs-data` volume (stores `acme-stepca.json` at `/certs/acme-stepca.json`)

## B) Epic Map

*   **E1 — Documentation Foundation**: Establish the base documentation structure, including a new `docs/` directory, an index file, and define a consistent style guide and glossary to ensure high-quality and consistent content.
*   **E2 — README & Quickstart (Mode A)**: Enhance the main `README.md` to be a comprehensive entry point, and create a dedicated quickstart guide (`docs/quickstart-mode-a.md`) that enables a new user to quickly get the stack running with Mode A (local self-signed TLS) and verify its functionality.
*   **E3 — Architecture Deep Dive**: Document the core architectural components including Docker networks, Compose profiles, Traefik providers, and the overall routing model. Emphasize secure-by-default choices and their implications in `docs/architecture.md`.
*   **E4 — Compose Usage & Profiles**: Detail the usage of `docker compose` commands and the activation of `COMPOSE_PROFILES`. Explain how to manage the stack with different profiles for TLS modes and general service orchestration in `docs/compose-usage.md`.
*   **E5 — Makefile & Scripts Operations**: Provide clear documentation for all `Makefile` targets and helper scripts, covering common operational workflows such as starting/stopping the stack, viewing logs, and running tests in `docs/make-and-scripts.md`.
*   **E6 — Service Docs**: Create dedicated documentation files for each key service (`traefik`, `whoami`, `certbot`, `step-ca`) within `docs/04-services/`, detailing their purpose, configuration, and integration.
*   **E7 — TLS Mode Guides (A/B/C)**: Develop in-depth guides for each TLS mode (`docs/05-tls/mode-a-selfsigned.md`, `mode-b-letsencrypt-certbot.md`, `mode-c-stepca-acme.md`), including step-by-step instructions for setup, verification, renewal/rotation, and potential rollback procedures.
*   **E8 — How-to: Add a Service**: Create a practical guide (`docs/06-howto/add-a-service.md`) that outlines the process for integrating new services into the stack, including required Traefik labels, middleware examples, and a checklist for successful deployment.
*   **E9 — Testing + Troubleshooting**: Document the smoke testing framework (`docs/07-testing.md`), explaining how tests work and how to interpret results. Create a comprehensive troubleshooting guide (`docs/08-troubleshooting.md`) organized by symptoms, providing diagnostic steps and solutions.
*   **E10 — Documentation QA Pass**: Conduct a final review and consistency sweep across all documentation, ensuring valid cross-links, accurate commands, correct environment variable usage, consistent terminology, and clear security callouts.

## C) Epic Details

### E1 — Documentation Foundation
Goal: structure, style guide, glossary, index, doc templates.

#### CH1: Docs directory skeleton + Index + Style Guide
*   **T1.1**: Create `docs/` directory and `docs/00-index.md`
    *   **Owner**: Documentation Lead
    *   **Description**: Establish the main documentation directory and an initial index file for navigation.
    *   **Files/paths affected**: `docs/`, `docs/00-index.md`
    *   **Dependencies**: None
    *   **Acceptance criteria**:
        *   `docs/` directory exists.
        *   `docs/00-index.md` exists and contains a basic navigation structure.
    *   **Review checklist**:
        *   Index links are placeholders but logically ordered.
        *   File created in correct location.
*   **T1.2**: Create `docs/glossary-style-guide.md`
    *   **Owner**: Documentation Lead
    *   **Description**: Define a consistent style guide and populate a glossary with key terms used across the repository (e.g., Traefik, Whoami, ACME, Let's Encrypt, Step-CA, DEV_DOMAIN, profiles).
    *   **Files/paths affected**: `docs/glossary-style-guide.md`
    *   **Dependencies**: T1.1
    *   **Acceptance criteria**:
        *   File exists.
        *   Contains sections for Style Guide and Glossary.
        *   Glossary includes definitions for at least: Traefik, ACME, Certbot, Step-CA, Docker Compose Profile, DEV_DOMAIN.
    *   **Review checklist**:
        *   Style guide rules are clear and concise.
        *   Glossary entries are accurate and comprehensive.

### E2 — README & Quickstart (Mode A)
Goal: “from zero to working” with Mode A, with verification and minimal troubleshooting.

#### CH2: README.md update & Quickstart Guide
*   **T2.1**: Update `README.md` with enhanced structure and internal cross-links
    *   **Owner**: Documentation Lead
    *   **Description**: Refine the main `README.md` to serve as a high-level overview and primary entry point to the detailed documentation in `docs/`, including improved TOC and cross-referencing.
    *   **Files/paths affected**: `README.md`
    *   **Dependencies**: T1.1, T1.2
    *   **Acceptance criteria**:
        *   `README.md` contains updated Table of Contents linking to `docs/` files (placeholders).
        *   README clearly states the purpose and features of the repository.
        *   README includes core operating principles.
    *   **Review checklist**:
        *   All new `docs/` files are linked (even if content is pending).
        *   Overview is concise and inviting.
        *   No broken links in the README itself.
*   **T2.2**: Create `docs/quickstart-mode-a.md`
    *   **Owner**: DevOps UX Engineer
    *   **Description**: Develop a detailed quickstart guide for Mode A, covering prerequisites, host configuration (`/etc/hosts`), generating self-signed certificates, starting the stack, and verifying initial functionality.
    *   **Files/paths affected**: `docs/quickstart-mode-a.md`
    *   **Dependencies**: T2.1
    *   **Acceptance criteria**:
        *   Document includes clear steps for: `cp .env.example .env`, `make certs-local`, `make up`, `make test`.
        *   Includes specific instructions for editing `/etc/hosts` for `DEV_DOMAIN`.
        *   Mentions trusting the local CA (`certs/local-ca/ca.crt`) as a post-setup step.
        *   Provides verification commands and expected outputs.
    *   **Review checklist**:
        *   Commands are copy/paste friendly.
        *   Every step has an expected result/verification.
        *   Security-by-default (CA trust) is highlighted.

### E3 — Architecture Deep Dive
Goal: networks, profiles, routing model, Traefik providers, why secure-by-default.

#### CH3: Architecture documentation
*   **T3.1**: Create `docs/01-architecture.md`
    *   **Owner**: Platform Architect
    *   **Description**: Document the overall architecture, explaining the role of Traefik, Docker networks (`traefik-proxy`, `stepca-internal`), Docker Compose profiles, and Traefik providers (Docker, File).
    *   **Files/paths affected**: `docs/01-architecture.md`
    *   **Dependencies**: T1.1, T2.1
    *   **Acceptance criteria**:
        *   Explains Traefik's function as a reverse proxy.
        *   Details the purpose and isolation of `traefik-proxy` and `stepca-internal` networks.
        *   Describes how Docker Compose profiles enable modularity.
        *   Covers Traefik's Docker and File providers.
    *   **Review checklist**:
        *   Clear diagrams/illustrations are conceptually implied (if not drawn).
        *   Terminology from glossary is used consistently.
        *   Focus on "why" architectural decisions were made.
*   **T3.2**: Document secure-by-default principles
    *   **Owner**: Platform Architect
    *   **Description**: Detail the secure-by-default choices, such as disabled Traefik dashboard, `exposedByDefault: false` for Docker provider, and internal networks.
    *   **Files/paths affected**: `docs/01-architecture.md`
    *   **Dependencies**: T3.1
    *   **Acceptance criteria**:
        *   Explains *why* the dashboard is disabled by default and risks if enabled.
        *   Clarifies `exposedByDefault: false` implication for service integration.
        *   Documents the role of internal networks for security.
    *   **Review checklist**:
        *   Security implications are clearly stated.
        *   Guidance on enabling features safely is provided.

### E4 — Compose Usage & Profiles
Goal: explain docker compose commands, COMPOSE_PROFILES usage, Mode A/B/C workflows.

#### CH4: Compose Usage documentation
*   **T4.1**: Create `docs/02-compose-usage.md`
    *   **Owner**: DevOps UX Engineer
    *   **Description**: Provide a comprehensive guide to using `docker compose` commands with this repository, focusing on `up`, `down`, `logs`, `ps`, and the effective use of `COMPOSE_PROFILES`.
    *   **Files/paths affected**: `docs/02-compose-usage.md`
    *   **Dependencies**: T1.1, T2.1
    *   **Acceptance criteria**:
        *   Explains common `docker compose` commands relevant to the stack.
        *   Clearly demonstrates how `COMPOSE_PROFILES` activates specific services (`le`, `stepca`).
        *   Provides examples like `COMPOSE_PROFILES=le make up`.
    *   **Review checklist**:
        *   All commands are valid and tested.
        *   Explains how to determine active profiles (`docker compose config`).
        *   Highlights potential conflicts when combining profiles.

### E5 — Makefile & Scripts Operations
Goal: document make targets and scripts; operational workflows (up/down/logs/test/certs).

#### CH5: Makefile & Scripts documentation
*   **T5.1**: Create `docs/03-make-and-scripts.md`
    *   **Owner**: DevOps UX Engineer
    *   **Description**: Document all `Makefile` targets, explaining their purpose and which `scripts/` they execute. Detail the helper scripts' functionality and best practices (e.g., `set -euo pipefail`).
    *   **Files/paths affected**: `docs/03-make-and-scripts.md`
    *   **Dependencies**: T1.1, T2.1
    *   **Acceptance criteria**:
        *   Lists all `Makefile` targets with their descriptions (from `make help`).
        *   Describes each helper script (`common.sh`, `up.sh`, `down.sh`, `logs.sh`, `healthcheck.sh`, `certs-selfsigned-generate.sh`, `certbot-issue.sh`, `certbot-renew.sh`, `stepca-bootstrap.sh`).
        *   Explains the `set -euo pipefail` philosophy for scripts.
    *   **Review checklist**:
        *   Each documented target/script matches actual implementation.
        *   Security implications of scripts (e.g., password in `.env` for `stepca-bootstrap`) are noted.
        *   Cross-references to `docs/02-compose-usage.md` for profile management.

### E6 — Service Docs
Goal: per-service docs (Traefik, whoami, certbot, step-ca) using a standard template.

#### CH6: Core Service Documentation
*   **T6.1**: Create `docs/04-services/traefik.md`
    *   **Owner**: Traefik & Routing Specialist
    *   **Description**: Document the Traefik service, covering its configuration (`traefik.yml`, dynamic configs), providers, entrypoints, and how its labels are used for routing.
    *   **Files/paths affected**: `docs/04-services/traefik.md`
    *   **Dependencies**: T1.1, T2.1, E3 (T3.1, T3.2)
    *   **Acceptance criteria**:
        *   Explains static vs. dynamic configuration.
        *   Details `web` and `websecure` entrypoints.
        *   Documents Docker provider's `exposedByDefault: false` and network listening.
        *   Covers Traefik's internal services (`api@internal`, `ping@internal`).
    *   **Review checklist**:
        *   Configuration snippets are accurate.
        *   Links to relevant TLS mode docs for certificate resolvers.
*   **T6.2**: Create `docs/04-services/whoami.md`
    *   **Owner**: Traefik & Routing Specialist
    *   **Description**: Document the `whoami` demo service, explaining its role, Traefik label configuration for routing and middlewares, and how to verify its functionality.
    *   **Files/paths affected**: `docs/04-services/whoami.md`
    *   **Dependencies**: T1.1, T2.1, T6.1
    *   **Acceptance criteria**:
        *   Explains `whoami` as a simple test service.
        *   Details the Traefik labels used in `services/whoami/compose.yml` for `whoami`.
        *   Shows how `redirect-to-https` and `security-headers` middlewares are applied.
    *   **Review checklist**:
        *   Label examples are accurate copy/paste snippets.
        *   Verification steps are concise.
*   **T6.3**: Create `docs/04-services/certbot.md`
    *   **Owner**: TLS / PKI Specialist
    *   **Description**: Document the `certbot` service (Mode B), its Docker Compose profile (`le`), mounted volumes, and its role in obtaining and renewing Let's Encrypt certificates.
    *   **Files/paths affected**: `docs/04-services/certbot.md`
    *   **Dependencies**: T1.1, T2.1, E4 (T4.1), E5 (T5.1)
    *   **Acceptance criteria**:
        *   Explains the `le` profile activation.
        *   Details the purpose of `certbot/conf` and `certbot/www` volumes.
        *   Refers to `scripts/certbot-issue.sh` and `scripts/certbot-renew.sh`.
    *   **Review checklist**:
        *   Distinguishes Certbot's role from Traefik's ACME resolver.
        *   Highlights `LETSENCRYPT_STAGING` and `ACME_EMAIL` variables.
*   **T6.4**: Create `docs/04-services/step-ca.md`
    *   **Owner**: TLS / PKI Specialist
    *   **Description**: Document the `step-ca` service (Mode C), its Docker Compose profile (`stepca`), mounted volumes, and its function as an internal ACME server.
    *   **Files/paths affected**: `docs/04-services/step-ca.md`
    *   **Dependencies**: T1.1, T2.1, E4 (T4.1), E5 (T5.1)
    *   **Acceptance criteria**:
        *   Explains the `stepca` profile activation.
        *   Details the purpose of `step-ca/config`, `step-ca/secrets`, `step-ca/data` volumes.
        *   Refers to `scripts/stepca-bootstrap.sh`.
        *   Explains its internal network (`stepca-internal`) and Traefik proxying.
    *   **Review checklist**:
        *   Clarifies the role of `step-ca` as a private CA and ACME server.
        *   Highlights `STEP_CA_NAME`, `STEP_CA_ADMIN_PROVISIONER_PASSWORD`, `STEP_CA_PASSWORD` variables.

### E7 — TLS Mode Guides (A/B/C)
Goal: deep guides for each mode with steps + verify + rotate + rollback.

#### CH7: Detailed TLS Mode Guides
*   **T7.1**: Create `docs/05-tls/mode-a-selfsigned.md`
    *   **Owner**: TLS / PKI Specialist
    *   **Description**: Provide an in-depth guide for TLS Mode A, covering the generation process, how Traefik uses these certificates, and crucial steps for trusting the local CA.
    *   **Files/paths affected**: `docs/05-tls/mode-a-selfsigned.md`
    *   **Dependencies**: T1.1, T2.1, T5.1, T6.1 (for Traefik context)
    *   **Acceptance criteria**:
        *   Detailed steps for `make certs-local`.
        *   Clear instructions for manually trusting `certs/local-ca/ca.crt` on different OS.
        *   Verification steps (e.g., `openssl s_client` output, browser check).
        *   Common pitfalls (e.g., browser warnings, `/etc/hosts` issues).
    *   **Review checklist**:
        *   All commands shown are executable.
        *   Includes screenshots/illustrations where OS-specific steps are complex (conceptually).
*   **T7.2**: Create `docs/05-tls/mode-b-letsencrypt-certbot.md`
    *   **Owner**: TLS / PKI Specialist
    *   **Description**: Detail TLS Mode B, including prerequisites (public domain, open ports), configuring `.env`, issuing and renewing certificates with `make certs-le-issue`/`certs-le-renew`, and setting up automated renewals.
    *   **Files/paths affected**: `docs/05-tls/mode-b-letsencrypt-certbot.md`
    *   **Dependencies**: T1.1, T2.1, T5.1, T6.3
    *   **Acceptance criteria**:
        *   Clearly lists production prerequisites.
        *   Provides steps for configuring `ACME_EMAIL`, `LETSENCRYPT_STAGING`, `TLS_CERT_RESOLVER`.
        *   Details usage of `make certs-le-issue` and `make certs-le-renew`.
        *   Suggests automation for renewal (e.g., cron job).
    *   **Review checklist**:
        *   Security callouts for production usage.
        *   Explanation of staging vs. production.
        *   Troubleshooting for common issuance failures (rate limits, DNS).
*   **T7.3**: Create `docs/05-tls/mode-c-stepca-acme.md`
    *   **Owner**: TLS / PKI Specialist
    *   **Description**: Guide for TLS Mode C, covering `step-ca` bootstrapping (`make stepca-bootstrap`), configuring Traefik's ACME resolver to point to `step-ca`, and trusting the `step-ca` root certificate.
    *   **Files/paths affected**: `docs/05-tls/mode-c-stepca-acme.md`
    *   **Dependencies**: T1.1, T2.1, T5.1, T6.4
    *   **Acceptance criteria**:
        *   Steps for configuring `STEP_CA_ADMIN_PROVISIONER_PASSWORD`, `STEP_CA_PASSWORD`, `TLS_CERT_RESOLVER`.
        *   Details usage of `make stepca-up` and `make stepca-bootstrap`.
        *   Instructions for retrieving and trusting `step-ca/config/ca.crt`.
        *   Verification of cert issuance via `step-ca` logs or Traefik status.
    *   **Review checklist**:
        *   Emphasizes `step-ca` as an internal CA.
        *   Clear guidance on password handling for bootstrap.
        *   Troubleshooting for `step-ca` initialization or Traefik ACME issues.

### E8 — How-to: Add a Service
Goal: service integration contract, label templates (Host/Path), middlewares examples, checklist.

#### CH8: Adding a New Service How-to
*   **T8.1**: Create `docs/06-howto/add-a-service.md`
    *   **Owner**: Traefik & Routing Specialist
    *   **Description**: Develop a practical guide for adding a new service to the stack, detailing the required Traefik labels, network configuration, and common middleware application.
    *   **Files/paths affected**: `docs/06-howto/add-a-service.md`
    *   **Dependencies**: T1.1, T2.1, T6.1, T6.2
    *   **Acceptance criteria**:
        *   Provides a reusable label template for services in `services/<service>/compose.yml`.
        *   Explains `traefik.enable`, `traefik.http.routers.<name>.rule` (Host, Path), `entrypoints`, `service`, `tls`, `tls.certresolver`, `middlewares`.
        *   Includes a checklist for integrating a new service (Compose entry, labels, network, `.env` / `/etc/hosts` entries, verification).
    *   **Review checklist**:
        *   Examples are minimal and clear.
        *   Highlights critical points like network connection.
        *   Cross-links to relevant middleware and TLS docs.

### E9 — Testing + Troubleshooting
Goal: smoke tests explained and troubleshooting by symptom with commands.

#### CH9: Testing & Troubleshooting Guides
*   **T9.1**: Create `docs/07-testing.md`
    *   **Owner**: QA / Test Engineer
    *   **Description**: Document the smoke testing framework, explaining `make test`, how individual scripts work (`test_traefik_ready.sh`, `test_routing.sh`, `test_tls_handshake.sh`, `test_http_redirect.sh`), and how to interpret their output.
    *   **Files/paths affected**: `docs/07-testing.md`
    *   **Dependencies**: T1.1, T2.1, E5 (T5.1)
    *   **Acceptance criteria**:
        *   Explains `make test` as the entry point.
        *   Details the purpose and expected output of each smoke test script.
        *   Provides guidance on troubleshooting failed tests (e.g., check logs, `.env` config).
    *   **Review checklist**:
        *   Test execution commands are accurate.
        *   Links to relevant service and TLS docs for deeper debugging.
*   **T9.2**: Create `docs/08-troubleshooting.md`
    *   **Owner**: DevOps UX Engineer
    *   **Description**: Compile a comprehensive troubleshooting guide, structured by common symptoms or error messages, providing diagnostic steps and solutions.
    *   **Files/paths affected**: `docs/08-troubleshooting.md`
    *   **Dependencies**: T1.1, T2.1, E3 (T3.1), E7 (T7.1, T7.2, T7.3)
    *   **Acceptance criteria**:
        *   Covers issues like "Domain does not resolve", "Certificate errors", "Service not reachable", "ACME challenge failures".
        *   Provides specific `docker compose` or `make` commands for diagnosis (e.g., `make logs`, `docker compose config`).
        *   Suggests common fixes (e.g., `/etc/hosts`, firewall, `.env` variables).
    *   **Review checklist**:
        *   Symptoms are clear and actionable.
        *   Solutions are concise and directly address the problem.
        *   Cross-links to relevant sections of the detailed docs.

### E10 — Documentation QA Pass
Goal: consistency sweep: links, commands, env vars, paths, security notes.

#### CH10: Final Documentation Quality Assurance
*   **T10.1**: Conduct a full cross-linking review
    *   **Owner**: Documentation Lead
    *   **Description**: Verify that all internal links between documentation files are valid, correctly point to the intended sections, and use consistent relative paths.
    *   **Files/paths affected**: All `.md` files in `docs/` and `README.md`
    *   **Dependencies**: All prior documentation tasks (T1.1 - T9.2)
    *   **Acceptance criteria**:
        *   All `[text](link)` syntax is correct.
        *   All linked paths exist in the repository.
        *   No broken internal documentation links.
    *   **Review checklist**:
        *   Use a link checker tool (conceptually) if available.
        *   Ensure anchors (`#heading`) are correct.
*   **T10.2**: Verify command and environment variable accuracy
    *   **Owner**: DevOps UX Engineer, QA / Test Engineer
    *   **Description**: Systematically check every command snippet and environment variable reference across all documentation files against the actual `Makefile`, `scripts/`, `compose/base.yml`, `services/<service>/compose.yml`, and `.env.example`.
    *   **Files/paths affected**: All `.md` files in `docs/` and `README.md`, `Makefile`, `scripts/*.sh`, `compose/base.yml`, `services/<service>/compose.yml`, `.env.example`
    *   **Dependencies**: All prior documentation tasks (T1.1 - T9.2)
    *   **Acceptance criteria**:
        *   Every `make` target mentioned exists in `Makefile`.
        *   Every script referenced exists and is executable.
        *   Every environment variable mentioned has a definition in `.env.example`.
        *   Commands are copy/paste friendly and reflect the latest implementation.
    *   **Review checklist**:
        *   Execute a sample of commands from docs to confirm functionality.
        *   Check for consistent use of `COMPOSE_PROFILES=` prefix where applicable.
*   **T10.3**: Ensure security-by-default callouts are prominent
    *   **Owner**: Documentation Lead, Platform Architect
    *   **Description**: Review all documentation to ensure that secure-by-default decisions (e.g., disabled dashboard, internal networks, password handling for `step-ca`) are explicitly highlighted, and any deviations or risks are clearly documented.
    *   **Files/paths affected**: All `.md` files in `docs/` and `README.md`
    *   **Dependencies**: All prior documentation tasks (T1.1 - T9.2)
    *   **Acceptance criteria**:
        *   Risks of enabling Traefik dashboard publicly are clearly stated.
        *   Rationale for `exposedByDefault: false` is explained.
        *   Warnings for handling sensitive data (e.g., `step-ca` passwords, `acme.json`) are present.
    *   **Review checklist**:
        *   Security notes are actionable and easy to find.
        *   No accidental exposure of sensitive info in docs examples.
*   **T10.4**: Glossary and Terminology Consistency Check
    *   **Owner**: Documentation Lead
    *   **Description**: Perform a final review of all documentation against the `docs/glossary-style-guide.md` to ensure consistent terminology, formatting, and adherence to the defined style.
    *   **Files/paths affected**: All `.md` files in `docs/` and `README.md`
    *   **Dependencies**: T1.2, All prior documentation tasks (T2.1 - T10.3)
    *   **Acceptance criteria**:
        *   All key terms defined in the glossary are used consistently.
        *   Formatting (e.g., code blocks, bolding) follows the style guide.
        *   No jargon is used without explanation or glossary entry.
    *   **Review checklist**:
        *   Read through docs to catch any style deviations.
        *   Ensure a natural flow and readability.

## D) Definition of Done (DoD) for “Docs v1 complete”

The documentation version 1 is considered complete when:

*   All epics and their associated changes and tasks outlined in this plan have been executed.
*   All required documentation files listed in "STEP 2 — REQUIRED DOCUMENTATION SCOPE" exist and contain content aligned with their purpose.
*   The `README.md` serves as a comprehensive entry point, providing a clear overview and effective navigation to all detailed documentation.
*   The `docs/` directory is well-structured and contains all the planned `.md` files.
*   The Quickstart (Mode A) is fully functional and verifiable by following the documented steps.
*   All `Makefile` targets and `scripts/` are accurately documented and their usage is clearly explained.
*   Each TLS Mode (A, B, C) has a dedicated guide with setup, verification, and troubleshooting steps.
*   The "How to Add a New Service" guide provides clear and actionable instructions.
*   The Testing and Troubleshooting guides are comprehensive and practical.
*   All commands, environment variables, and file paths mentioned in the documentation are accurate and correspond to the repository's current state.
*   Cross-linking within the documentation is complete and accurate.
*   Security-by-default principles are consistently highlighted and explained throughout the documentation.
*   The documentation adheres to the defined style guide and maintains consistent terminology.
*   All acceptance criteria for each task have been met and reviewed.
