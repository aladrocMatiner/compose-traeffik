## 1. Implementation
- [x] 1.1 Replace the smoke test inventory list in `tests/README.md` with a table that covers every script invoked by `scripts/healthcheck.sh`.
- [x] 1.2 Include standard columns (script, purpose, prerequisites, expected output) and keep the wording aligned with the scripts.
- [x] 1.3 Update any references in root README or docs that point to the inventory list so they reference the new table format.

## 2. Verification
- [x] 2.1 Verify the table includes all tests: traefik readiness, routing, TLS handshake, HTTP redirect, hosts subdomains, DNS provision, DNS configure (Ubuntu), DNS service config.
- [x] 2.2 Confirm `make test` continues to run the same scripts (no behavior change).
