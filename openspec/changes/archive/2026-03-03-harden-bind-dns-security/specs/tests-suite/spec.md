## ADDED Requirements

### Requirement: DNS security smoke coverage
The system SHALL include DNS security smoke tests that verify recursion denial, AXFR denial, metadata minimization, provisioning-input validation, and listener-scope behavior.

#### Scenario: Security checks execute in smoke suite
- **WHEN** `make test` runs
- **THEN** DNS security smoke tests execute as part of `scripts/healthcheck.sh`
- **AND** failures are reported with explicit per-test signals

