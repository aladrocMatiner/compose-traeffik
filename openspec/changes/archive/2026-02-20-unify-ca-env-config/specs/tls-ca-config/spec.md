## ADDED Requirements

### Requirement: Shared CA configuration
The system SHALL define a shared `.env` configuration section that contains the canonical CA identity and SAN values used by local certificate workflows.

#### Scenario: Shared CA values defined
- **WHEN** a user configures CA identity/SANs for local TLS
- **THEN** the values are set in a single shared `.env` section

### Requirement: Mode A consumes shared CA values
Mode A (local self-signed) certificate generation SHALL read CA subject and SAN values from the shared `.env` configuration.

#### Scenario: Mode A uses shared values
- **WHEN** `make certs-local` runs with shared CA variables set
- **THEN** the generated CA and leaf certificates use those shared values

### Requirement: Mode C consumes shared CA values
Mode C (step-ca bootstrap) SHALL read CA name and DNS/SAN values from the shared `.env` configuration.

#### Scenario: Mode C uses shared values
- **WHEN** `make stepca-bootstrap` runs with shared CA variables set
- **THEN** step-ca is initialized using those shared values

### Requirement: Backward-compatible fallbacks
The system SHALL preserve compatibility with existing mode-specific environment variables when shared CA values are not provided.

#### Scenario: Legacy variables only
- **WHEN** shared CA variables are unset and existing mode-specific variables are present
- **THEN** the system behaves as it does today for Mode A and Mode C
