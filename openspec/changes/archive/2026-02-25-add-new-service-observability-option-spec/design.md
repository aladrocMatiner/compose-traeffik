## Context
The repository uses modular services with consistent Compose/Traefik/Make/docs/test patterns. Observability support should become a standard optional capability rather than a per-service afterthought.

## Goals / Non-Goals
- Goals:
- Standardize a minimal observability option contract for future services.
- Keep observability optional and non-blocking for service adoption.
- Require documentation and test coverage for observability wiring decisions.

- Non-Goals:
- This change does not implement the observability stack itself.
- This change does not retrofit every existing service immediately.

## Decision
- Decision: Add a dedicated cross-cutting spec instead of encoding the rule only in one service proposal.
- Rationale: makes the policy explicit and reusable across future service additions.
