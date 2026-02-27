## Why

`make test` currently mixes all smoke checks into one run, which causes unrelated failures when optional modules are not running (for example BIND runtime checks while validating a CTFd deployment). We also need a consistent Makefile pattern where each service/module exposes its own smoke-test target.

## What Changes

- Define service-scoped smoke test Make targets (core, DNS/BIND, CTFd, observability).
- Change `make test` behavior to run common utility tests plus only the suites for services that are currently running.
- Document the new service-aware behavior and service-scoped test commands in `tests/README.md`.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `compose-wrapper`: add requirements for service-scoped smoke test Make targets and adaptive `make test` behavior.
- `tests-suite`: define service-aware suite selection behavior for the smoke runner.
- `tests-docs`: require documentation of service-scoped test commands and `make test` skip behavior.

## Impact

- Affected files: `Makefile`, `scripts/healthcheck.sh`, `tests/README.md`.
- Improves local validation ergonomics without changing service runtime configuration.
