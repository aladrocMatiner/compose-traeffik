## ADDED Requirements

### Requirement: Semaphore UI profile-gated preflight validation
The system SHALL validate Semaphore UI configuration in preflight checks only when the `semaphoreui` profile is enabled.

#### Scenario: Semaphore UI profile disabled
- **WHEN** the `semaphoreui` profile is not enabled
- **THEN** missing Semaphore UI variables do not block unrelated compose workflows

#### Scenario: Semaphore UI profile enabled with invalid config
- **WHEN** the `semaphoreui` profile is enabled and required Semaphore UI values are invalid or placeholders
- **THEN** preflight validation fails with a clear error message

### Requirement: OIDC and observability safety checks for Semaphore UI
The system SHALL validate optional OIDC and observability settings for Semaphore UI with safe defaults.

#### Scenario: OIDC disabled
- **WHEN** OIDC is disabled for Semaphore UI
- **THEN** OIDC-specific values are not required by preflight validation

#### Scenario: OIDC enabled with missing client secret
- **WHEN** OIDC is enabled and required provider/client settings are missing or placeholders
- **THEN** preflight validation fails before Compose is executed

#### Scenario: Unsafe observability exposure requested by default config
- **WHEN** Semaphore UI observability settings would expose telemetry publicly under default/safe mode
- **THEN** preflight validation fails unless the configuration explicitly uses a documented override path
