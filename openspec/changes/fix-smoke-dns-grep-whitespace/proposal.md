# Change: Fix DNS Smoke Test Whitespace Grep

## Summary
Make the DNS service config smoke test use a portable whitespace pattern so it correctly matches `- dns` lines.

## Problem
`tests/smoke/test_dns_service_config.sh` uses `grep -q "^\\s*- dns"`. Standard `grep` does not interpret `\\s` without `-P`, so the check can fail even when the configuration is correct.

## Goals
- Replace the non-portable `\\s` usage with a POSIX‑compatible pattern.
- Keep the change minimal and scoped to the DNS smoke test validation.

## Non-goals
- No other test logic changes.
- No dependency on `grep -P` or non‑POSIX tools.

## Approach
- Replace `\\s` with a portable whitespace matcher, e.g. `grep -E "^[[:space:]]*- dns"` or an `awk`/`sed` equivalent.
- Ensure the check matches both `- dns` and indented `  - dns` lines.
- Keep scope limited to the single validation line; add a brief manual verification example if needed.

## Affected files
- `tests/smoke/test_dns_service_config.sh`

## Verification
- Manual check: verify the updated pattern matches lines like `- dns` and `  - dns`.
