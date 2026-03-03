## MODIFIED Requirements

### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting. When optional-module smoke tests are added (for example WireGuard config/guardrail checks), the documentation SHALL describe their scope and limitations.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

#### Scenario: Optional-module test scope is clear
- **WHEN** WireGuard smoke tests are present
- **THEN** `tests/README.md` identifies them as configuration/guardrail (and optionally Make-wiring) checks
- **AND** it clarifies they do not validate end-to-end tunnel runtime behavior

### Requirement: README link to tests
The system SHALL link to `tests/README.md` from the root README.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can find a direct link to the smoke test documentation

