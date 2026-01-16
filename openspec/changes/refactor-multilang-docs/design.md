## Context
Documentation is distributed across multiple files and languages are not supported. A multilingual README system requires strict structure parity and automated validation to prevent drift.

## Goals / Non-Goals
- Goals:
  - EN/SV/ES versions of root and per-service READMEs.
  - Language selector on every README linking to same-path equivalents.
  - Validation script to ensure existence, selector correctness, link parity, and anchor alignment.
- Non-Goals:
  - Translating every existing docs page outside the README system.
  - Changing operational behavior or commands.

## Decisions
- Use a JSON manifest as the source of truth for services and titles.
- Add a `docs-check` script to enforce structure and links.
- Root README remains the primary entry point; service READMEs contain service-specific guidance.

## Risks / Trade-offs
- Migration requires careful mapping from `docs/` to README structure to avoid losing content.
- Keeping anchors in sync across languages adds maintenance overhead; tooling mitigates drift.

## Migration Plan
- Build EN README content from existing docs, then clone structure for SV/ES placeholders.
- Keep legacy `docs/` temporarily with deprecation pointers, or move content into new READMEs.
- Add validation and Makefile target before removing old docs.

## Open Questions
- Whether to keep a short `services/README.*.md` index in addition to root index.
