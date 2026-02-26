## 1. Upstream Verification (Gate Before Coding)

- [x] 1.1 Verify official n8n Docker deployment guidance and recommended persistent settings (DB, encryption key, host/webhook URL) for the pinned module version.
- [x] 1.2 Verify reverse proxy requirements for n8n behind Traefik (forwarded headers, public URL/webhook settings, editor/realtime connectivity if applicable) and capture exact settings required.
- [x] 1.3 Verify the supported Keycloak integration path in n8n (including product edition constraints) and callback URL requirements.
- [x] 1.4 Verify n8n observability capabilities (health, metrics, telemetry/diagnostics controls if any) and document the chosen scope; implement the full upstream-documented path if one exists.
- [x] 1.5 Verify the recommended approach for trusting an internal Keycloak issuer certificate signed by step-ca (e.g., Node extra CA certs) if Keycloak is enabled with internal PKI.

## 2. OpenSpec Alignment

- [x] 2.1 Add proposal, design, tasks, and spec deltas for the n8n service module.
- [x] 2.2 Validate change artifacts with `openspec validate add-n8n-service-module --strict`.

## 3. n8n Service Module (Implementation)

- [x] 3.1 Add `services/n8n/compose.yml` with Traefik routing to `https://n8n.<DEV_DOMAIN>` and bundled PostgreSQL service(s) under profile `n8n`.
- [x] 3.2 Add n8n bootstrap/render scripts that generate runtime env/config artifacts and optional Keycloak/observability runbooks.
- [x] 3.3 Add n8n multilingual service docs (`services/n8n/README*.md`).

## 4. Repo Integration (Implementation)

- [x] 4.1 Add n8n env vars to `.env.example` (with safe defaults and hostname default `n8n`) and ignore rendered artifacts in `.gitignore`.
- [x] 4.2 Extend `scripts/env-generate.sh` / bootstrap flows so `make bootstrap` randomizes required n8n/database secrets and provisions any generated local assets/config for the module.
- [x] 4.3 Wire the n8n compose file into `scripts/compose.sh` and lifecycle/test targets into `Makefile`.
- [x] 4.4 Extend `scripts/validate-env.sh` with n8n profile guardrails and optional Keycloak/observability/step-ca trust validation.
- [x] 4.5 Update root multilingual READMEs and `docs.manifest.json` with n8n links/endpoints/operations notes.
- [x] 4.6 Update `scripts/README.md` and `tests/README.md` inventories and examples.

## 5. Testing (Implementation)

- [x] 5.1 Add n8n static smoke tests for Make target wiring, compose wiring, guardrails, and bootstrap rendering.
- [x] 5.2 Run the n8n smoke suite (`make test-n8n`).
- [x] 5.3 Run docs validation (`make docs-check`).
- [x] 5.4 Run compose config validation with and without the `n8n` profile.

## 6. Runtime Validation and Handoff (Implementation)

- [x] 6.1 Perform a manual runtime validation of `make n8n-up` and confirm Traefik routing to `https://n8n.<DEV_DOMAIN>`.
- [x] 6.2 Validate a representative n8n runtime endpoint (health and/or metrics if enabled) through Traefik and record the result.
- [x] 6.3 If Keycloak is enabled, validate the login flow (including internal CA trust when using step-ca-signed Keycloak TLS). (Not applicable in this validation run because Keycloak remained disabled.)
- [x] 6.4 Do a final self-review pass for gaps (docs/tests/guardrails drift) before handoff.
