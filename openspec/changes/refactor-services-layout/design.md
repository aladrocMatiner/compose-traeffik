## Context
The repository currently mixes service-specific assets across top-level directories. A unified `services/` layout improves discoverability and reduces coupling, but requires careful path and compose refactoring to preserve existing workflows.

## Goals / Non-Goals
- Goals:
  - One service per `services/<service>/` directory with a per-service README.
  - Compose layering strategy that preserves `make` commands and profiles.
  - Zero functional regressions for routing, TLS modes, and profiles.
- Non-Goals:
  - Changing service behavior or adding new services.
  - Altering TLS defaults, routing rules, or profile semantics.

## Decisions
- **Compose strategy**: Root Makefile will call a fixed set of compose files: `compose/base.yml` plus per-service `services/<service>/compose.yml`. Profiles remain defined in service compose files.
- **Shared assets**: Keep shared TLS assets under `shared/certs/` (or `shared/`) if a service needs them (e.g., Traefik Mode A certs), to avoid cross-service coupling.
- **Scripts**: Keep `scripts/` at repo root; per-service README links to relevant scripts.

## Risks / Trade-offs
- Path refactors may break scripts/tests if not updated.
- Compose file ordering must preserve existing routing and profile behavior.

## Migration Plan
- Introduce new layout in a single PR with clear mapping.
- Update Makefile and scripts to new compose paths.
- Document migration steps and path updates in a root migration note.

## Open Questions
- Confirm whether to keep root `docker-compose.yml` as a thin wrapper or move to `compose/base.yml` with Makefile `-f` layering only.
