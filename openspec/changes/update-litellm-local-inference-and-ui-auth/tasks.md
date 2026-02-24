## 1. Upstream Behavior Verification (required before coding)
- [x] 1.1 Verify the pinned LiteLLM version's browser-facing docs/admin/UI endpoints and which paths need protection/documentation.
- [x] 1.2 Verify whether the LiteLLM management UI requires DB-backed features, and document the expected behavior in the no-DB module.
- [x] 1.3 Verify the LiteLLM config syntax for local-provider routes (Ollama-compatible defaults and env placeholders) for the pinned version.

## 2. Environment Template and Bootstrap Extensions
- [x] 2.1 Extend `.env.example` with local inference defaults (enable flag, provider/base URL, default local model alias/model string, and optional UI hostname).
- [x] 2.2 Extend `.env.example` with LiteLLM management UI BasicAuth credentials/path variables following the project auth path convention (`/etc/traefik/auth/...`).
- [x] 2.3 Extend `scripts/litellm-bootstrap.sh` to generate LiteLLM UI credentials (and htpasswd file) in addition to `LITELLM_MASTER_KEY` and `LITELLM_SALT_KEY`.
- [x] 2.4 Keep `scripts/litellm-bootstrap.sh` idempotent by default and support `--force` rotation for both API secrets and UI credentials.
- [x] 2.5 Ensure bootstrap supports non-default env files (`ENV_FILE` / `--env-file`) and writes UI credentials to the selected target env file.

## 3. LiteLLM Service / Traefik Routing Integration
- [x] 3.1 Update `services/litellm/config.yaml` to include a default local inference route driven by `.env` variables (no manual YAML edits required).
- [x] 3.2 Update `services/litellm/compose.yml` to support host reachability for local inference defaults (e.g. `host-gateway` mapping if needed on Linux).
- [x] 3.3 Add a dedicated LiteLLM management hostname/router (e.g. `llm-admin`) in `services/litellm/compose.yml` that points to the same backend service.
- [x] 3.4 Apply Traefik BasicAuth middleware to the management router only, leaving the API router bearer-auth based (LiteLLM master key) for clients.
- [x] 3.5 Update Traefik dynamic middleware configuration/rendering for the LiteLLM management UI BasicAuth middleware (and optional allowlist if the project pattern is reused).
- [x] 3.6 Add a standalone Traefik + LiteLLM compose startup workflow (service selection only) that does not start `whoami`, `dns`, or local `stepca`.

## 4. Compose Wrapper and Make Standalone Mode Integration
- [x] 4.1 Add dedicated Make targets for standalone LiteLLM edge mode (e.g. `litellm-standalone-up/down/logs/status`) using the standard compose wrapper.
- [x] 4.2 Ensure standalone startup renders Traefik dynamic config before compose startup (matching `up.sh` behavior) while selecting only `traefik` and `litellm` services.
- [x] 4.3 Document and test how standalone mode combines with TLS settings (including remote `STEP_CA_CA_SERVER`) without requiring the local `stepca` profile.
- [x] 4.4 Update `.PHONY` and `make help` output for standalone LiteLLM targets.

## 5. Guardrails and Safety Checks
- [x] 5.1 Extend `scripts/validate-env.sh` to validate LiteLLM management UI htpasswd path/file requirements when the UI router is enabled.
- [x] 5.2 Extend `scripts/validate-env.sh` to validate local inference endpoint env formatting (URL/hostname/port shape) without requiring runtime connectivity.
- [x] 5.3 Ensure all new LiteLLM checks remain profile-gated and do not block unrelated stacks when `litellm` is disabled.
- [x] 5.4 Add clear error messages pointing to `make litellm-bootstrap` when LiteLLM UI credentials/htpasswd are missing.

## 6. Tests (No-Sudo, No Runtime Inference Dependency)
- [x] 6.1 Extend `tests/smoke/test_litellm_service_config.sh` to validate the admin router hostname, middleware assignment, and host-gateway mapping (if used).
- [x] 6.2 Extend `tests/smoke/test_litellm_config_template.sh` to validate the default local inference route and env-placeholder usage.
- [x] 6.3 Extend `tests/smoke/test_litellm_guardrails.sh` to cover missing/invalid LiteLLM UI auth credentials/path and local inference env validation.
- [x] 6.4 Extend `tests/smoke/test_litellm_bootstrap_env.sh` to validate generated LiteLLM UI credentials and htpasswd behavior (idempotent + `--force`).
- [x] 6.5 Add or extend a Makefile wiring smoke test to validate standalone LiteLLM mode targets and service-selection commands.
- [x] 6.6 Add a config-only smoke test (or extend existing tests) to verify standalone mode launches only `traefik` + `litellm` service selection (no `whoami`) via the documented target pattern.
- [x] 6.7 Update `scripts/healthcheck.sh` only if test names or inventory order changes require it.
- [x] 6.8 Run `bash -n` and the updated LiteLLM smoke tests individually.

## 7. Documentation (Multilingual + Scripts/Tests)
- [x] 7.1 Update `README.md`, `README.sv.md`, and `README.es.md` to document the new LiteLLM management hostname and auth expectations.
- [x] 7.2 Update root docs to explain optional `ENDPOINTS` additions for `llm` and `llm-admin` when using hosts/DNS automation.
- [x] 7.3 Document the standalone Traefik + LiteLLM mode in root docs, including commands, expected dependencies, and what is intentionally not started.
- [x] 7.4 Document standalone TLS usage with a remote `step-ca` ACME endpoint (`STEP_CA_CA_SERVER`) and client trust prerequisites.
- [x] 7.5 Update `services/litellm/README*.md` with local inference default behavior, how to override the endpoint/model, and the UI login flow.
- [x] 7.6 Document the security distinction between API auth (`LITELLM_MASTER_KEY`) and UI BasicAuth credentials.
- [x] 7.7 Update `scripts/README.md` to describe the expanded `make litellm-bootstrap` side effects (UI credential + htpasswd generation) and standalone targets if script workflows change.
- [x] 7.8 Update `tests/README.md` to describe the new LiteLLM local inference/UI auth/standalone smoke-test coverage.
- [x] 7.9 Update `docs.manifest.json` only if new README anchors or service metadata change is required.

## 8. Validation and Handoff
- [x] 8.1 Run `openspec validate update-litellm-local-inference-and-ui-auth --strict`.
- [x] 8.2 Run `make docs-check`.
- [x] 8.3 Run updated LiteLLM smoke tests individually.
- [x] 8.4 Run `make test` and note unrelated failures separately if any exist.
