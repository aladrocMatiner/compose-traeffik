## MODIFIED Requirements

### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/`, including WireGuard-focused config/guardrail checks when present, and provide a consistent, scan-friendly format.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: WireGuard checks are represented
- **WHEN** WireGuard-specific smoke checks are part of the suite
- **THEN** the inventory table explicitly lists them with prerequisites and expected signals
- **AND** the descriptions distinguish static configuration/guardrail/Make-wiring/bootstrap-env checks from runtime network behavior tests

#### Scenario: TLS mode compatibility check is documented as validation scope
- **WHEN** WireGuard UI routing relies on the shared `TLS_CERT_RESOLVER` pattern
- **THEN** the test documentation or validation notes identify which parts are covered by static smoke checks versus manual mode-specific validation
