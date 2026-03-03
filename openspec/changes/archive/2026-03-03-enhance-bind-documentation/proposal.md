## Why

BIND is the DNS target for this branch, but documentation can be improved further for contributor onboarding, cross-language parity, and long-term maintenance. We need a dedicated documentation change that defines those updates before implementation.

## What Changes

- Define a docs-focused change to strengthen BIND onboarding and maintenance guidance.
- Plan updates for root/docs indexes, DNS guide clarity, and multilingual parity checks.
- Plan explicit validation expectations for `make docs-check` after DNS documentation updates.
- Plan branch-intent messaging so BIND docs are unambiguous in this branch.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `documentation`: refine contributor-facing setup/path guidance for current branch behavior.
- `docs-multilang`: tighten parity expectations for DNS/BIND documentation across EN/SV/ES.
- `dns-docs-tests`: strengthen DNS guide/index requirements for BIND workflows.

## Impact

- Affected files (planned): `README*.md`, `docs/README.md`, `docs/00-index.md`, `docs/06-howto/service-dns-bind.md`, `docs.manifest.json`.
- No runtime changes in this phase; this change only defines documentation-development scope.
