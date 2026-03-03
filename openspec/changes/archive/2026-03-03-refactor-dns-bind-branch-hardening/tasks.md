## 1. OpenSpec Alignment

- [x] 1.1 Add spec deltas for BIND-focused behavior and Technitium capability retirement.
- [x] 1.2 Validate change artifacts with `openspec validate refactor-dns-bind-branch-hardening --strict`.

## 2. Runtime and Script Refactor

- [x] 2.1 Remove Technitium runtime files (`services/dns/**`) and deprecated DNS scripts (`scripts/dns-provision.sh`, `scripts/dns-configure-ubuntu.sh`).
- [x] 2.2 Update compose orchestration (`Makefile`, `scripts/compose.sh`) to use BIND-only DNS paths.
- [x] 2.3 Update env/bootstrap/preflight scripts (`.env.example`, `scripts/env-generate.sh`, `scripts/validate-env.sh`, `scripts/traefik-render-dynamic.sh`) to match BIND-only flow.

## 3. Documentation Refactor

- [x] 3.1 Rewrite DNS how-to and root/service docs to remove Technitium references and point to BIND commands.
- [x] 3.2 Update docs metadata/index files (`docs.manifest.json`, `docs/README.md`, `docs/00-index.md`, `docs/90-facts.md`, `tests/README.md`).

## 4. Testing Integration

- [x] 4.1 Replace Technitium smoke checks with BIND config smoke coverage (`test_bind_service_config.sh`, `scripts/healthcheck.sh`).
- [x] 4.2 Run `make docs-check` and relevant smoke tests to verify no regressions in branch behavior.
