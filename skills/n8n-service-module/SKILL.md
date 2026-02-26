---
name: n8n-service-module
description: Use this skill when planning or implementing an n8n service module in this Traefik compose repo, especially with optional Keycloak, observability, and step-ca compatibility. It guides OpenSpec-first planning, upstream verification, repo integration points, guardrails, docs, and static smoke tests.
---

# n8n Service Module Skill

Use this skill for future work on adding n8n to this repo. It is written for this repository's patterns (Traefik-first, profile-gated services, OpenSpec-driven changes, multilingual docs, preflight guardrails).

## When To Use

- planning or implementing `services/n8n/`
- adding `n8n` Makefile targets or compose profile wiring
- adding n8n bootstrap/render scripts
- wiring optional Keycloak, observability, or step-ca compatibility for n8n
- writing n8n smoke tests or docs

## Default Workflow (OpenSpec First)

1. Read `openspec/AGENTS.md` and the active change `openspec/changes/add-n8n-service-module/`.
2. Do not implement before the proposal is approved.
3. During implementation, work in this order:
   - upstream verification gate (official n8n docs)
   - compose module + bootstrap/render scripts
   - Makefile / compose wrapper / `validate-env.sh`
   - static smoke tests
   - docs (`README*.md`, `services/n8n/README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`)
   - validation (`openspec validate`, `make docs-check`, `make test-n8n`, compose config checks)

## Repo Integration Checklist (n8n)

- `services/n8n/compose.yml` (profile `n8n`, Traefik labels, no direct public app port)
- default public route hostname `n8n` (i.e., `https://n8n.<DEV_DOMAIN>`) unless overridden
- `services/n8n/README.md`, `README.sv.md`, `README.es.md`
- `services/n8n/rendered/` for generated artifacts (gitignored)
- `scripts/n8n-bootstrap.sh` and `scripts/n8n-render-config.sh`
- `scripts/env-generate.sh` / `make bootstrap` integration to randomize n8n + DB secrets and provision generated assets
- `Makefile` targets: `n8n-bootstrap`, `n8n-up`, `n8n-down`, `n8n-restart`, `n8n-logs`, `n8n-status`, `test-n8n`
- `scripts/compose.sh` include `services/n8n/compose.yml`
- `scripts/validate-env.sh` guardrails (profile-gated)
- `tests/smoke/test_n8n_*.sh` static suite

## Upstream Verification Gate (Before Coding)

Verify against official n8n documentation before locking implementation details:
- Docker deployment guidance (persistent DB + `N8N_ENCRYPTION_KEY`)
- Reverse proxy/public URL/webhook settings behind Traefik
- Keycloak / SSO support path and edition constraints
- Observability capabilities (health + metrics flags/endpoints)
- Node/container CA trust method for internal Keycloak TLS signed by step-ca (e.g., `NODE_EXTRA_CA_CERTS`)

If an assumption is unclear, keep it as a documented verification item in OpenSpec instead of guessing.

## Optional Integration Guidance

### Keycloak

Default to generated runbook/checklist unless a stable supported config-as-code path exists for the target n8n edition/version. Be explicit if SSO is enterprise-only.

### Observability

Default off. If upstream documents health/metrics toggles, implement them behind explicit env toggles and validate mode-specific inputs.

### step-ca Compatibility

Inbound TLS is handled by Traefik. Extra n8n work is only needed if n8n must trust outbound HTTPS to an internal issuer (e.g., Keycloak signed by step-ca).

## Safety / Local Context Notes

This machine may contain unrelated untracked directories (for example `services/gitlab/` or `services/wikijs/`) from work on other branches. Do not stage or modify them unless the user explicitly asks.
