## ADDED Requirements
### Requirement: Non-interactive step-ca initialization
The system SHALL initialize step-ca without interactive prompts when run in a container exec context.

#### Scenario: Headless bootstrap
- **WHEN** `scripts/stepca-bootstrap.sh` runs in a non-interactive environment
- **THEN** initialization completes without requiring TTY input

### Requirement: Fail-fast bootstrap behavior
The system SHALL exit non-zero on any bootstrap failure and SHALL not emit success messages unless initialization completes.

#### Scenario: Init fails
- **WHEN** a critical init step fails
- **THEN** the script exits non-zero with a clear error message

#### Scenario: Init succeeds
- **WHEN** initialization completes
- **THEN** success output is printed and verification commands are shown

### Requirement: Non-empty DNS/SAN list
The system SHALL validate `STEP_CA_DNS` and SHALL not proceed with an empty DNS/SAN list.

#### Scenario: Missing STEP_CA_DNS
- **WHEN** `STEP_CA_DNS` is missing
- **THEN** the script derives a deterministic list from `DEV_DOMAIN` or fails with guidance

