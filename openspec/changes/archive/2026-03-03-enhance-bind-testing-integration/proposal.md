## Why

BIND is now the DNS path in this branch, but smoke coverage and test documentation are still minimal for BIND-specific workflows. We need explicit test planning changes so future implementation can add stronger, reproducible DNS validation without ambiguity.

## What Changes

- Define a BIND-focused testing change that expands smoke coverage beyond static compose checks.
- Plan additional no-sudo tests for zone generation and profile wiring consistency.
- Plan updates to `scripts/healthcheck.sh` and `tests/README.md` so test inventory remains synchronized.
- Document expected failure signals and prerequisites for BIND-centric smoke tests.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `tests-suite`: expand smoke test inventory requirements for BIND-specific checks.
- `tests-docs`: strengthen test documentation requirements for BIND workflows and troubleshooting.
- `tests-docs-alignment`: add BIND profile alignment expectations across smoke tests and docs.

## Impact

- Affected files (planned): `tests/smoke/*`, `scripts/healthcheck.sh`, `tests/README.md`, and related docs links.
- No runtime behavior change in this phase; this change only defines the test-development scope.
