## 1. Makefile Test Target Partitioning

- [x] 1.1 Add service-scoped smoke test targets in `Makefile` (`test-core`, `test-dns`, `test-ctfd`, `test-observability`).
- [x] 1.2 Update `make help` text to describe the new test targets.

## 2. Service-Aware `make test` Execution

- [x] 2.1 Update `scripts/healthcheck.sh` to detect running services via compose and gate service-specific smoke suites.
- [x] 2.2 Keep common utility smoke tests runnable in `make test` even when no optional services are running.
- [x] 2.3 Preserve clear skip/failure logging so users can see which suites were skipped.

## 3. Documentation

- [x] 3.1 Update `tests/README.md` to describe service-aware `make test` behavior.
- [x] 3.2 Document service-scoped test commands (`make test-*`) in `tests/README.md`.

## 4. Validation

- [x] 4.1 Run targeted smoke tests for new Make targets (`test-ctfd`, `test-observability`, `test-core` wiring).
- [x] 4.2 Run `make test` to validate service-aware skipping behavior.
- [x] 4.3 Validate OpenSpec artifacts with `openspec validate update-service-aware-smoke-test-make-targets --strict`.
