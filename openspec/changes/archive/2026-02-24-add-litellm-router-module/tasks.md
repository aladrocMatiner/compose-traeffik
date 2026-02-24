## 1. Upstream Contract Verification (required before coding)
- [x] 1.1 Verify the LiteLLM image tag to pin (stable release) and record the exact image reference for `.env.example`.
- [x] 1.2 Verify proxy startup command/entrypoint, default listen port, config file path, and health endpoint(s) for the pinned version.
- [x] 1.3 Verify the exact LiteLLM env vars for API auth (`master key`) and any required/optional salt or secret values used by the selected feature set.
- [x] 1.4 Verify config file syntax for referencing env vars (for provider API keys and secrets) in the pinned version.
- [x] 1.5 Decide and document whether any docs/admin endpoints should be disabled or explicitly documented in v1, based on verified upstream behavior.

## 2. Compose Service Scaffolding
- [x] 2.1 Create `services/litellm/compose.yml` with service `litellm`, profile `litellm`, Traefik HTTPS router labels, configurable router middlewares (default including `security-headers@file`), and no direct host port publish.
- [x] 2.2 Add a LiteLLM config template file at `services/litellm/config.yaml` with environment-referenced secrets/provider keys and at least one documented example route.
- [x] 2.3 Add `services/litellm/README.md`, `services/litellm/README.sv.md`, and `services/litellm/README.es.md` using the standard service README anchors and language selector links.
- [x] 2.4 If the chosen LiteLLM mode needs local state directories, create the directory layout and update `.gitignore` accordingly (do not commit generated state).

## 3. Environment and Bootstrap Secrets
- [x] 3.1 Extend `.env.example` with a LiteLLM section including image tag, hostname prefix, secrets, and documented optional provider key variables.
- [x] 3.2 Add `scripts/litellm-bootstrap.sh` to populate required LiteLLM secrets in `.env` (idempotent by default).
- [x] 3.3 Support explicit rotation/overwrite behavior (for example `--force`) in `scripts/litellm-bootstrap.sh` and document how `make` passes it through.
- [x] 3.4 Add `make litellm-bootstrap` in `Makefile` and ensure it works with `ENV_FILE`/`.env` conventions used by the repo.

## 4. Compose Wrapper and Make Integration
- [x] 4.1 Add `services/litellm/compose.yml` to `scripts/compose.sh` `COMPOSE_FILES`.
- [x] 4.2 Add `services/litellm/compose.yml` to `Makefile` `COMPOSE_FILES` (keep parity with `scripts/compose.sh`).
- [x] 4.3 Add `litellm-up`, `litellm-down`, `litellm-restart`, `litellm-logs`, and `litellm-status` targets using `./scripts/compose.sh --profile litellm`.
- [x] 4.4 Update `.PHONY` and `make help` text so LiteLLM targets are visible and consistent with other service modules.

## 5. Preflight Guardrails
- [x] 5.1 Extend `scripts/validate-env.sh` to validate LiteLLM hostname prefix format and reject invalid values.
- [x] 5.2 Extend `scripts/validate-env.sh` to require non-empty, non-placeholder LiteLLM secrets when the `litellm` profile is enabled.
- [x] 5.3 Ensure LiteLLM guardrails are profile-gated so they do not block unrelated stacks when `litellm` is disabled.
- [x] 5.4 Ensure guardrails are compatible with `make litellm-*` targets and the generic `scripts/compose.sh` preflight path.
- [x] 5.5 Add clear error messages that tell the user to run `make litellm-bootstrap` when secrets are missing.

## 6. Tests (No-Sudo, No External Provider Dependency)
- [x] 6.1 Add `tests/smoke/test_litellm_service_config.sh` to validate compose profile, Traefik labels (including default middleware), no direct host port publish, and expected service wiring.
- [x] 6.2 Add `tests/smoke/test_litellm_config_template.sh` to validate the committed LiteLLM config template structure and env-placeholder usage.
- [x] 6.3 Add `tests/smoke/test_litellm_guardrails.sh` to validate profile-gated preflight failures for missing/placeholder secrets and invalid hostname values.
- [x] 6.4 Add `tests/smoke/test_litellm_make_targets.sh` to validate Make target presence/help text/wiring patterns.
- [x] 6.5 Add `tests/smoke/test_litellm_bootstrap_env.sh` to validate bootstrap idempotency and force rotation behavior using a temp env file.
- [x] 6.6 Update `scripts/healthcheck.sh` to execute the new LiteLLM smoke tests.
- [x] 6.7 Run `bash -n` on new/modified shell scripts and tests.

## 7. Documentation and Manifest Updates
- [x] 7.1 Update `README.md`, `README.sv.md`, and `README.es.md` to list the LiteLLM service, profile, endpoint, auth expectations, and basic usage flow.
- [x] 7.2 Update root endpoint references and examples to explain how/when to add `llm` to `ENDPOINTS` for hosts/DNS tooling.
- [x] 7.3 Update `docs.manifest.json` to include service slug `litellm` and titles for EN/SV/ES.
- [x] 7.4 Update `scripts/README.md` to document `scripts/litellm-bootstrap.sh` and any new Make target linkage.
- [x] 7.5 Update `tests/README.md` to document LiteLLM smoke tests and their no-provider/no-sudo scope.
- [x] 7.6 Document a verified LiteLLM request/health-check example in `services/litellm/README*.md` (using the pinned-version endpoint path and auth header expectations).
- [x] 7.7 Ensure the new `services/litellm/README*.md` files use the standard anchor set required by `docs-check`.

## 8. Validation and Handoff
- [x] 8.1 Run `openspec validate add-litellm-router-module --strict`.
- [x] 8.2 Run `make docs-check`.
- [x] 8.3 Run the new LiteLLM smoke tests individually.
- [x] 8.4 Run `make test` and note any unrelated pre-existing failures separately from LiteLLM work.
- [x] 8.5 Confirm tasks are checked off only after implementation is complete (planning-only PR should keep them unchecked).
