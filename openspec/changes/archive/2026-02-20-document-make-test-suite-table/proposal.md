# Change: Document make test suite in a standard table

## Why
- The current smoke test inventory is a bullet list, which makes it harder to scan dependencies, scope, and expected outcomes.
- A standardized table will help contributors quickly understand what each `make test` script validates and when it applies.

## What Changes
- Replace the smoke test inventory section with a table that lists each test script, purpose, prerequisites, and expected signals.
- Align the table format with the actual scripts executed by `scripts/healthcheck.sh`.
- Ensure the README/test docs explain that `make test` is the standard suite entrypoint.

## Impact
- Affected specs: test suite documentation
- Affected code: `tests/README.md` (and possibly root README references)
