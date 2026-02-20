## ADDED Requirements

### Requirement: DNS security test documentation
The system SHALL document DNS security smoke tests in `tests/README.md`, including prerequisites, expected pass/fail signals, and troubleshooting guidance.

#### Scenario: Contributor investigates a DNS security failure
- **WHEN** a DNS security smoke test fails
- **THEN** `tests/README.md` provides actionable diagnostics and remediation steps
- **AND** the documented inventory matches the tests executed by `scripts/healthcheck.sh`

