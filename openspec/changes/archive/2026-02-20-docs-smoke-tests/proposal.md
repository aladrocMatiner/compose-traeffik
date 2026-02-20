# Change: Document smoke tests and link from README

## Why
Smoke tests are critical for validating the stack, but the current test documentation is minimal and the main README does not clearly point to it. Expanding tests/README.md and linking it from the root README will improve discoverability and troubleshooting.

## Discovery Summary
- **Smoke tests**: `tests/smoke/test_traefik_ready.sh`, `test_routing.sh`, `test_tls_handshake.sh`, `test_http_redirect.sh`, `test_hosts_subdomains.sh`, `test_dns_provision.sh`, `test_dns_configure_ubuntu.sh`, `test_dns_service_config.sh`.
- **Test runner**: `scripts/healthcheck.sh` invoked by `make test`.
- **Make target**: `make test` runs `scripts/healthcheck.sh`.
- **Env vars used by tests**: `DEV_DOMAIN`, `HTTP_TO_HTTPS_REDIRECT` (from `.env.example`).
- **Current tests/README.md**: basic run instructions and a list of tests.
- **README.md**: mentions `make test` in quickstart but no direct link to tests/README.md.

## What Changes
- Expand `tests/README.md` with full smoke test documentation: purpose, how to run, inventory, configuration, expected output, common failures with diagnose/fix steps.
- Add a link to `tests/README.md` in the root README in a visible testing section or quickstart step.

## Impact
- Affected specs: tests-docs
- Affected files: `tests/README.md`, `README.md` (link only)
