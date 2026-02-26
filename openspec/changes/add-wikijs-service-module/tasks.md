## 1. Upstream Verification (Gate Before Coding)

- [ ] 1.1 Verify official Wiki.js Docker deployment guidance and recommended database backend/version for the pinned module version.
- [ ] 1.2 Verify reverse proxy requirements for Wiki.js behind Traefik (forwarded headers, WebSocket support, upload/body size considerations) and capture the exact Traefik/Wiki.js settings required.
- [ ] 1.3 Verify the supported Keycloak integration path in Wiki.js (OIDC/OpenID Connect vs generic OAuth/SAML) and callback URL requirements.
- [ ] 1.4 Verify Wiki.js observability capabilities (telemetry, health endpoints, metrics endpoints if any) and document the chosen scope; implement the full upstream-documented path if one exists.
- [ ] 1.5 Verify the recommended approach for trusting an internal Keycloak issuer certificate signed by step-ca (e.g., Node extra CA certs) if Keycloak is enabled with internal PKI.

## 2. OpenSpec Alignment

- [x] 2.1 Add proposal, design, tasks, and spec deltas for the Wiki.js service module.
- [x] 2.2 Validate change artifacts with `openspec validate add-wikijs-service-module --strict`.

## 3. Wiki.js Service Module (Implementation)

- [ ] 3.1 Add `services/wikijs/compose.yml` with Traefik routing to `https://wiki.<DEV_DOMAIN>` and bundled database service(s) under profile `wikijs`, including WebSocket-compatible proxy wiring.
- [ ] 3.2 Add Wiki.js bootstrap/render scripts that generate runtime env/config artifacts and optional Keycloak/observability runbooks.
- [ ] 3.3 Add Wiki.js multilingual service docs (`services/wikijs/README*.md`).

## 4. Repo Integration (Implementation)

- [ ] 4.1 Add Wiki.js env vars to `.env.example` (with safe defaults and hostname default `wiki`) and ignore rendered artifacts in `.gitignore`.
- [ ] 4.2 Extend `scripts/env-generate.sh` / bootstrap flows so `make bootstrap` randomizes required Wiki.js/database secrets and provisions any generated local assets/config for the module.
- [ ] 4.3 Wire the Wiki.js compose file into `scripts/compose.sh` and lifecycle/test targets into `Makefile`.
- [ ] 4.4 Extend `scripts/validate-env.sh` with Wiki.js profile guardrails and optional Keycloak/observability/step-ca trust validation.
- [ ] 4.5 Update root multilingual READMEs and `docs.manifest.json` with Wiki.js links/endpoints/operations notes.
- [ ] 4.6 Update `scripts/README.md` and `tests/README.md` inventories and examples.

## 5. Testing (Implementation)

- [ ] 5.1 Add Wiki.js static smoke tests for Make target wiring, compose wiring (including WebSocket-related routing config assertions where feasible), guardrails, and bootstrap rendering.
- [ ] 5.2 Run the Wiki.js smoke suite (`make test-wikijs`).
- [ ] 5.3 Run docs validation (`make docs-check`).
- [ ] 5.4 Run compose config validation with and without the `wikijs` profile.

## 6. Runtime Validation and Handoff (Implementation)

- [ ] 6.1 Perform a manual runtime validation of `make wikijs-up` and confirm Traefik routing to `https://wiki.<DEV_DOMAIN>`.
- [ ] 6.2 Validate a Wiki.js realtime/WebSocket-capable interaction through Traefik (or the closest upstream-documented realtime check) and record the result.
- [ ] 6.3 If Keycloak is enabled, validate the login flow (including internal CA trust when using step-ca-signed Keycloak TLS).
- [ ] 6.4 Do a final self-review pass for gaps (docs/tests/guardrails drift) before handoff.
