## ADDED Requirements

### Requirement: Secure and validated zone provisioning inputs
The system SHALL validate `BASE_DOMAIN` and endpoint labels before generating a BIND zone file, and SHALL reject malformed values.

#### Scenario: Invalid domain rejected
- **WHEN** `bind-provision` receives an invalid `BASE_DOMAIN`
- **THEN** provisioning exits non-zero with a clear error
- **AND** no zone file is written

#### Scenario: Invalid endpoint rejected
- **WHEN** `bind-provision` receives an endpoint label with invalid DNS characters
- **THEN** provisioning exits non-zero with a clear error
- **AND** no zone file is written

