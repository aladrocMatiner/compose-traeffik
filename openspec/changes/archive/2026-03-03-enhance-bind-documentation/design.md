## Context

The branch already moved from mixed DNS behavior toward BIND, but documentation quality work should be handled as a focused change to ensure consistency across root docs, how-to guides, and multilingual pages.

## Goals / Non-Goals

**Goals:**
- Define precise documentation updates required for BIND-first branch clarity.
- Ensure multilingual parity for DNS-related pages.
- Define docs validation outcomes before implementation.

**Non-Goals:**
- Implementing doc edits in this change.
- Altering runtime scripts or compose behavior.

## Decisions

- Decision: Keep documentation updates split from runtime/test implementation.
  Rationale: allows isolated review of content quality and link integrity.

- Decision: Reuse existing capabilities (`documentation`, `docs-multilang`, `dns-docs-tests`) rather than introducing new doc capabilities.
  Rationale: these specs already define expected doc behavior and validation.

- Decision: Require explicit docs-check validation criteria in tasks.
  Rationale: prevents regressions in language selectors, links, and anchors.

## Risks / Trade-offs

- [Risk] Docs updates may lag behind runtime changes if not planned early.
  Mitigation: define concrete tasks and validation gating in this change.

- [Risk] Multilingual updates can drift structurally.
  Mitigation: require anchor and selector parity checks in implementation tasks.

## Migration Plan

1. Approve this documentation change.
2. Implement planned docs updates in apply phase.
3. Run `make docs-check` and fix parity/link issues.

## Open Questions

- Whether to include an explicit branch comparison note to `dns-technitium` in user-facing docs or keep that internal to contribution guides.
