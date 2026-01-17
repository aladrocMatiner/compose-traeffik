## Context
The compose wrapper relies on `docker compose` defaults, which vary by working directory. This causes new projects, networks, and volumes when the wrapper is invoked from other CWDs. Additionally, `make ps` is malformed due to indentation.

## Goals / Non-Goals
- Goals:
  - Make `make ps` functional and consistent with other targets.
  - Pin compose project directory and project name for deterministic behavior.
- Non-Goals:
  - Rework compose file layering or service definitions.

## Decisions
- Decision: Pin `--project-directory` to the repo root in `scripts/compose.sh`.
  - Rationale: Prevents Compose from deriving a different project name based on CWD.
- Decision: Use `COMPOSE_PROJECT_NAME` if set, else `PROJECT_NAME`, else a stable fallback (repo basename).
  - Rationale: Keeps existing env usage and avoids breaking users without new vars.
- Decision: Keep Makefile as the primary entrypoint but ensure it passes through a stable project name if needed.
  - Rationale: Aligns shell wrapper and Make targets.

## Risks / Trade-offs
- Some users may rely on the implicit project name from CWD; pinning changes that behavior. This is expected for determinism and will be documented.

## Migration Plan
1) Fix `make ps` indentation.
2) Pin project directory/name in the compose wrapper.
3) Update `.env.example` (and optionally README) to document the behavior.

## Open Questions
- Do we want a dedicated `COMPOSE_PROJECT_NAME` variable, or rely solely on `PROJECT_NAME`?

