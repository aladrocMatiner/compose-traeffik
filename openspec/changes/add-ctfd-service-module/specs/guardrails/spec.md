## ADDED Requirements
### Requirement: CTFd profile preflight validation
The system SHALL validate CTFd-required environment variables and hostname format before compose runs when the `ctfd` profile is enabled.

#### Scenario: Missing CTFd secrets
- **WHEN** `COMPOSE_PROFILES` includes `ctfd` and required CTFd secrets are missing or placeholder values
- **THEN** preflight validation fails with a clear message that points to `make ctfd-bootstrap`

#### Scenario: CTFd profile disabled
- **WHEN** the `ctfd` profile is not enabled
- **THEN** CTFd-specific validation checks do not block unrelated stack workflows
