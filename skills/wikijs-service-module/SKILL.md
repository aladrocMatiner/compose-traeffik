---
name: wikijs-service-module
description: Use this skill when planning or implementing a Wiki.js service module in this Traefik compose repo, especially with optional Keycloak, observability, and step-ca compatibility. It guides OpenSpec-first planning, upstream verification, repo integration points, guardrails, docs, and static smoke tests.
---

# Wiki.js Service Module Skill

Use this skill for future work on adding Wiki.js to this repo. It is written for this repository's patterns (Traefik-first, profile-gated services, OpenSpec-driven changes, multilingual docs, preflight guardrails).

## When To Use

Trigger this skill when the task involves any of the following in this repo:
- planning or implementing `services/wikijs/`
- adding `wikijs` Makefile targets or compose profile wiring
- adding Wiki.js bootstrap/render scripts
- wiring optional Keycloak, observability, or step-ca compatibility for Wiki.js
- writing Wiki.js smoke tests or docs

## Default Workflow (OpenSpec First)

1. Read `openspec/AGENTS.md` and the active change `openspec/changes/add-wikijs-service-module/`.
2. Do not implement before the proposal is approved.
3. During implementation, work in this order:
   - upstream verification gate (official Wiki.js docs / repo)
   - compose module + bootstrap/render scripts
   - Makefile / compose wrapper / `validate-env.sh`
   - static smoke tests
   - docs (`README*.md`, `services/wikijs/README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`)
   - validation (`openspec validate`, `make docs-check`, `make test-wikijs`, compose config checks)

## Repo Integration Checklist (Wiki.js)

Mirror the patterns used by other service modules in this repo:
- `services/wikijs/compose.yml` (profile `wikijs`, Traefik labels, no direct public app port if Traefik fronts it)
- default public route hostname `wiki` (i.e., `https://wiki.<DEV_DOMAIN>`) unless the user explicitly overrides it
- `services/wikijs/README.md`, `README.sv.md`, `README.es.md` (standard service anchors)
- `services/wikijs/rendered/` for generated artifacts (gitignored)
- `scripts/wikijs-bootstrap.sh` and `scripts/wikijs-render-config.sh` (or equivalent)
- `scripts/env-generate.sh` / `make bootstrap` integration to randomize Wiki.js + DB secrets and provision local generated assets
- `Makefile` targets: `wikijs-bootstrap`, `wikijs-up`, `wikijs-down`, `wikijs-restart`, `wikijs-logs`, `wikijs-status`, `test-wikijs`
- `scripts/compose.sh` include `services/wikijs/compose.yml`
- `scripts/validate-env.sh` guardrails (profile-gated)
- `tests/smoke/test_wikijs_*.sh` static suite
- `README*.md`, `tests/README.md`, `scripts/README.md`, `docs.manifest.json`

## Upstream Verification Gate (Before Coding)

Verify against official Wiki.js documentation and/or the official repo before locking implementation details:
- Docker deployment guidance and DB backend requirements/recommendations
- Reverse proxy requirements (WebSockets, forwarded headers, upload/body limits)
- Supported auth provider flow for Keycloak (OIDC/OpenID Connect vs generic OAuth/SAML)
- Observability capabilities: telemetry, health endpoints, metrics endpoints (if any)
- If upstream documents a full observability integration/install path, prefer implementing that full path behind optional toggles
- Node/container CA trust method for internal Keycloak TLS signed by step-ca (e.g., `NODE_EXTRA_CA_CERTS`)

If an assumption is unclear, keep it as a documented verification item in OpenSpec instead of guessing.

## Optional Integration Guidance

### Keycloak

Prefer a generated runbook/checklist first unless Wiki.js supports stable config-as-code for auth providers in the target version.

Guardrails to include when enabled:
- issuer URL uses HTTPS
- required client ID/secret vars present and non-placeholder
- callback URL/runbook generated from `DEV_DOMAIN` and the Wiki.js hostname

### Observability

Default off. Scope only what upstream confirms.

Acceptable first-pass hooks:
- Wiki.js telemetry guidance (documented manual/admin toggle if not env-driven)
- health endpoint checks (if available)
- container labels / scrape wiring only if a metrics endpoint is verified

Do not assume Prometheus support without upstream confirmation.
If upstream documents a full metrics/observability integration path, implement that full path and add guardrails/docs/tests for it.

### step-ca Compatibility

Inbound TLS is handled by Traefik (same as other services). Extra Wiki.js work is only needed if Wiki.js must trust outbound HTTPS to an internal issuer (e.g., Keycloak signed by step-ca).

Plan for:
- optional CA cert mount
- optional env toggle/path validation
- preflight checks for missing CA file when that mode is enabled

## Static Smoke Tests (Expected)

Add a Wiki.js-specific static suite (`make test-wikijs`) similar to other service modules:
- Make target wiring test
- compose wiring/Traefik label test
- WebSocket/realtime proxy wiring assertions (static config checks where feasible)
- preflight guardrails test
- bootstrap/render output test

Keep runtime startup tests separate and only run when explicitly requested.

## Safety / Local Context Notes

This machine may contain unrelated untracked directories (for example `services/gitlab/` or `services/rocketchat/`) from work on other branches. Do not stage or modify them unless the user explicitly asks.

## Validation Checklist (After Implementation, Not During Planning)

- `openspec validate add-wikijs-service-module --strict`
- `make docs-check`
- `make test-wikijs`
- `./scripts/compose.sh config --services`
- `./scripts/compose.sh --profile wikijs config --services`
- optional runtime validation only if requested by the user
