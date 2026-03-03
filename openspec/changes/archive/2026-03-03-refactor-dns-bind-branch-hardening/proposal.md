## Why

The `dns-bind` branch still contains a mixed DNS implementation (Technitium + BIND), which creates operational drift, conflicting defaults, and inconsistent docs/tests. We need this branch to be fully BIND-first so development, validation, and onboarding follow a single DNS path.

## What Changes

- **BREAKING** Remove Technitium DNS service artifacts from this branch (`services/dns`, `scripts/dns-*`, `make dns-*`, and Technitium-specific env/docs/tests).
- Make BIND the only DNS profile in compose wrappers, Make targets, bootstrap defaults, and preflight guardrails.
- Align smoke tests with BIND (`test_bind_service_config.sh`) and remove obsolete Technitium dry-run checks.
- Rewrite DNS documentation and references so `docs/06-howto/service-dns-bind.md` and root/service docs describe BIND behavior only.
- Update OpenSpec capabilities to retire Technitium-specific requirements and tighten BIND-focused requirements.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `dns-bind-service`: remove legacy UI assumptions and define BIND-only service behavior.
- `dns-bind-provisioning`: clarify deterministic zone generation and reserved host handling.
- `dns-docs-tests`: align docs/test requirements with BIND compose and commands.
- `environment-config`: switch default optional profile set from `dns` to `bind`.
- `guardrails`: enforce preflight for `bind` flows and remove Technitium password checks.
- `stack-config`: pin BIND image expectations and remove DNS UI auth guardrail assumptions.
- `dns-service`: retire Technitium service requirements from this branch.
- `dns-provisioning`: retire Technitium API provisioning requirements from this branch.
- `dns-ubuntu-config`: retire Technitium split-DNS script requirements from this branch.

## Impact

- Affected code: `.env.example`, `Makefile`, `scripts/compose.sh`, `scripts/env-generate.sh`, `scripts/validate-env.sh`, `scripts/healthcheck.sh`, `scripts/README.md`, `services/dns-bind/**`, `services/traefik/dynamic/middlewares.yml`.
- Removed artifacts: `services/dns/**`, `scripts/dns-provision.sh`, `scripts/dns-configure-ubuntu.sh`, `tests/smoke/test_dns_*.sh`.
- Affected docs: `README*.md`, `docs/README.md`, `docs/00-index.md`, `docs/06-howto/service-dns-bind.md`, `docs/90-facts.md`, `docs.manifest.json`, `tests/README.md`.
