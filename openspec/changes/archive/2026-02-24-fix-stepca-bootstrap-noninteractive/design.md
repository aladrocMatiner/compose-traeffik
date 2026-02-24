## Context
`stepca-bootstrap.sh` uses `docker compose exec` with interactive init patterns and can log success even when initialization fails. Step-ca supports non-interactive initialization via `DOCKER_STEPCA_INIT_*` environment variables in its entrypoint. The script should use a deterministic, non-interactive path and validate inputs up front.

## Goals / Non-Goals
- Goals:
  - Non-interactive bootstrap in container context.
  - Clear, fail-fast error handling.
  - No empty SAN list for Step-CA DNS names.
  - Honest success/verification output.
- Non-Goals:
  - Changing Traefik configuration.
  - Reworking step-ca service routing or profiles.

## Decisions
- Decision: Prefer `DOCKER_STEPCA_INIT_*` envs for initialization, executed via `docker compose run` or equivalent.
  - Rationale: Official, non-interactive path built into the step-ca image entrypoint.
- Decision: Gate SSH CA generation behind `STEP_CA_ENABLE_SSH` (default false) or remove it if not needed.
  - Rationale: Avoid missing template dependencies and TTY prompts unless explicitly requested.
- Decision: Derive `STEP_CA_DNS` from `DEV_DOMAIN` when missing, but fail if still empty.
  - Rationale: Keeps SANs deterministic and safe.

## Risks / Trade-offs
- Using `DOCKER_STEPCA_INIT_*` requires matching env vars in `.env.example` and possibly `services/step-ca/compose.yml`.
- Some environments may already have initialized data; script must detect and avoid re-init.

## Migration Plan
1) Add non-interactive init path to `stepca-bootstrap.sh` and gate SSH behavior.
2) Update `.env.example` defaults if needed (e.g., `STEP_CA_ENABLE_SSH=false`).
3) Validate success/failure behavior with a fresh bootstrap.

## Open Questions
- Should we keep SSH CA support at all, or remove it entirely to simplify local ACME use?
- Do we want to expose `DOCKER_STEPCA_INIT_*` directly in `.env.example`, or keep them internal to the script?

