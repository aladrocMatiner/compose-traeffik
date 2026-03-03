## Context

The branch has moved to BIND-first DNS operation, but current smoke checks mainly validate static configuration. Planned test development should ensure BIND behavior is verifiable, deterministic, and clearly documented for contributors.

## Goals / Non-Goals

**Goals:**
- Define how BIND-focused tests should be structured and documented.
- Keep test inventory synchronized with `scripts/healthcheck.sh`.
- Require clear expected signals and troubleshooting guidance.

**Non-Goals:**
- Implementing new tests in this change.
- Altering runtime compose profiles or DNS service code.

## Decisions

- Decision: Keep all BIND smoke checks no-sudo where possible.
  Rationale: maintains CI/local portability and quick feedback loops.

- Decision: Tie inventory requirements to `scripts/healthcheck.sh` execution order.
  Rationale: avoids doc drift where tests exist but are not executed.

- Decision: Use existing test capability specs instead of creating a new DNS-test capability.
  Rationale: testing behavior already belongs to `tests-*` capabilities.

## Risks / Trade-offs

- [Risk] Broader test scope may increase maintenance overhead.
  Mitigation: enforce inventory parity and explicit prerequisites in docs.

- [Risk] Some desired DNS assertions may need elevated/system dependencies.
  Mitigation: separate no-sudo smoke tests from optional manual checks.

## Migration Plan

1. Approve this testing change.
2. Implement tests and healthcheck wiring in a follow-up apply phase.
3. Update test docs and verify via `make test` + `make docs-check`.

## Open Questions

- Which specific BIND runtime assertions should be mandatory in no-sudo smoke tests versus optional manual integration checks.
