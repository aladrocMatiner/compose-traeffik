## 1. Upstream Verification (Gate Before Coding)
- [x] 1.1 Verify latest stable GitLab Omnibus Docker image/tag strategy (`gitlab-ee` vs `gitlab-ce`) and choose a pinned default.
- [x] 1.2 Verify required Docker/Compose runtime settings for GitLab Omnibus (including `shm_size`, required volumes, and port expectations for HTTP/SSH).
- [x] 1.3 Verify Omnibus reverse-proxy SSL termination settings required behind Traefik (`external_url`, `nginx['listen_port']`, `nginx['listen_https']`, trusted proxies/headers as needed).
- [x] 1.4 Verify health/readiness endpoints and exact semantics for runtime checks.
- [x] 1.5 Verify OIDC (OmniAuth OpenID Connect) config syntax in Omnibus and the minimum required settings for Keycloak.
- [x] 1.6 Verify observability-related built-in endpoints/exporters and identify which are safe to leave disabled/unrouted by default.

## 2. Service Scaffolding and Compose Integration
- [x] 2.1 Add `services/gitlab/compose.yml` with `gitlab` service and persistent volumes following repo layout.
- [x] 2.2 Add a generated/mounted Omnibus config pattern (`gitlab.rb` or fragment) under `services/gitlab/` and ensure compose mounts it read-only.
- [x] 2.3 Store rendered GitLab config artifacts in a gitignored path and add/verify ignore rules.
- [x] 2.4 Route GitLab HTTP(S) through Traefik labels using repo TLS pattern and `security-headers@file` (configurable).
- [x] 2.5 Publish Git SSH on a configurable host port (default non-conflicting) and document clone URL behavior.
- [x] 2.6 Ensure no management/exporter ports are published publicly by default.
- [x] 2.7 Add observability labels/hooks (safe no-op when observability stack is absent).

## 3. Bootstrap and Secret Management
- [x] 3.1 Add `.env.example` entries for core GitLab, SSH, OIDC optional, and observability optional variables.
- [x] 3.2 Implement `scripts/gitlab-bootstrap.sh` to generate/persist required secrets in `.env` (idempotent, `--force` for rotation if supported).
- [x] 3.3 Implement rendering of Omnibus config from `.env` values, including optional OIDC block generation only when enabled.
- [x] 3.4 Integrate bootstrap flow into `Makefile` (`make gitlab-bootstrap`) and document side effects.

## 4. Guardrails and Validation
- [x] 4.1 Extend `scripts/validate-env.sh` with profile-gated GitLab checks (`gitlab` profile only).
- [x] 4.2 Validate required GitLab vars (hostname, root password state, SSH port format/range, image tag pin policy).
- [x] 4.3 Validate OIDC variables only when `GITLAB_OIDC_ENABLED=true`, including required issuer/client settings and HTTPS issuer guidance.
- [x] 4.4 Validate observability toggles do not imply public telemetry exposure by default.

## 5. Make Targets and Compose Wrapper Wiring
- [x] 5.1 Add `make gitlab-up/down/restart/logs/status` using the standard compose wrapper.
- [x] 5.2 Add `make test-gitlab` for service-specific smoke tests.
- [x] 5.3 Integrate GitLab suite into `scripts/healthcheck.sh` / `make test` using repo policy (service-aware if supported on this branch).
- [x] 5.4 Update `make help` and PHONY targets.

## 6. Tests
- [x] 6.1 Add smoke test for make target wiring (`test_gitlab_make_targets.sh`).
- [x] 6.2 Add smoke test for compose config/rendered Omnibus routing (`test_gitlab_service_config.sh`).
- [x] 6.3 Add smoke test for guardrails (`test_gitlab_guardrails.sh`).
- [x] 6.4 Add smoke test for OIDC wiring/rendered config (`test_gitlab_oidc_wiring.sh`).
- [x] 6.5 Add smoke test for observability hooks/telemetry non-exposure defaults (`test_gitlab_observability_wiring.sh`).
- [x] 6.6 Add runtime validation checklist steps in docs (manual, not required in CI).

## 7. Documentation
- [x] 7.1 Update root `README.md`, `README.es.md`, `README.sv.md` with GitLab endpoint, profile, SSH notes, and commands.
- [x] 7.2 Add `services/gitlab/README.md`, `README.es.md`, `README.sv.md` with setup, bootstrap, lifecycle, SSH clone notes, OIDC optional setup, and troubleshooting.
- [x] 7.3 Add `services/gitlab/observability/README*.md` documenting optional observability integration and security defaults.
- [x] 7.4 Update `scripts/README.md` and `tests/README.md` inventories.
- [x] 7.5 Update `docs.manifest.json` entries for GitLab docs.

## 8. Validation and Handoff
- [x] 8.1 Run `openspec validate add-gitlab-service-module --strict`.
- [x] 8.2 Run `make docs-check`.
- [x] 8.3 Run GitLab smoke tests (`make test-gitlab`) and shared suite wiring checks.
- [x] 8.4 Perform manual runtime validation (GitLab up, Traefik route, health, SSH port, optional OIDC metadata behavior).
