## Context

`dns-bind` currently mixes two DNS tracks:
- BIND (`services/dns-bind`, `bind-*` commands)
- Technitium (`services/dns`, `dns-*` commands, API provisioning, Ubuntu split-DNS helper)

This dual-path model causes inconsistent defaults (`COMPOSE_PROFILES=dns,...`), stale docs/tests, and operational ambiguity around port 53 ownership.

## Goals / Non-Goals

**Goals:**
- Make `dns-bind` branch BIND-only for runtime, scripts, docs, env defaults, and smoke tests.
- Keep developer workflows deterministic (`make bind-*`, `make test`, `make docs-check`).
- Capture the behavior change in OpenSpec deltas.

**Non-Goals:**
- Implement a BIND web UI.
- Keep backwards compatibility for Technitium make/script entry points in this branch.
- Modify unrelated TLS, Traefik, or Step-CA behavior.

## Decisions

- Decision: Remove Technitium service and scripts from this branch instead of keeping them dormant.
  Rationale: avoids drift and duplicate DNS code paths.
  Alternative considered: keep both profiles and document one as preferred. Rejected due to recurring ambiguity and guardrail complexity.

- Decision: Keep BIND provisioning as file-based zone generation (`bind-provision`) only.
  Rationale: matches BIND runtime model and avoids API coupling.
  Alternative considered: add dynamic API-compatible abstraction. Rejected as unnecessary complexity.

- Decision: Update preflight/bootstrapping around `bind` profile defaults.
  Rationale: bootstrap and validation must match runtime entrypoints to prevent false-positive configs.
  Alternative considered: keep legacy env variables as no-op. Rejected because they obscure active configuration.

## Risks / Trade-offs

- [Risk] Existing users relying on `dns-*` commands will break.
  Mitigation: update README/docs/facts with explicit `bind-*` replacements.

- [Risk] Branch diverges from other branches still carrying Technitium.
  Mitigation: keep Technitium work isolated in `dns-technitium` branch and document branch intent in OpenSpec change context.

- [Risk] Residual references to Technitium remain in docs/tests.
  Mitigation: run grep-based sweep and docs/test checks before finishing.

## Migration Plan

1. Introduce OpenSpec deltas and implementation tasks.
2. Remove Technitium runtime/scripts/tests and align compose/bootstrap/preflight.
3. Rewrite DNS docs + root references to BIND-only guidance.
4. Validate with smoke/doc checks and OpenSpec validation.

Rollback:
- Revert the refactor commit in this branch and continue Technitium work from `dns-technitium`.

## Open Questions

- None for implementation scope; branch intent is explicitly BIND-only.
