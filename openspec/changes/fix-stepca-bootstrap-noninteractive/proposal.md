# Change: Make step-ca bootstrap fail-fast, non-interactive, and truthful

## Why
The current bootstrap script can succeed silently even when initialization fails, and it relies on interactive behaviors that break in container exec contexts. This makes setup unreliable and causes confusing outcomes for users.

## What Changes
- Make `scripts/stepca-bootstrap.sh` fail-fast and return non-zero on any critical error.
- Switch bootstrap to a non-interactive initialization path (container env vars or explicit password files) and avoid `--ssh` unless explicitly enabled.
- Validate and/or derive `STEP_CA_DNS` so SANs are never empty.
- Print verification outputs only after successful init (ACME directory URL, CA cert path, and a verification command).

## Impact
- Affected capability: `stepca-bootstrap`
- Affected code:
  - `scripts/stepca-bootstrap.sh`
  - `.env.example` (only if new vars are introduced)
  - `services/step-ca/*` (only if required for bootstrap paths)

