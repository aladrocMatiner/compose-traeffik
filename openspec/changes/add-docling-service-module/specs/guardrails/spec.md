## ADDED Requirements
### Requirement: Docling profile preflight validation is profile-gated and integration-aware
The system SHALL validate Docling configuration before compose execution when the `docling` profile is enabled, including core hostname/auth checks and optional integration checks for Keycloak and observability.

#### Scenario: Missing core Docling configuration
- **WHEN** `COMPOSE_PROFILES` includes `docling` and required Docling values are missing or placeholders
- **THEN** preflight validation fails with clear remediation guidance (including bootstrap command hints)

#### Scenario: Keycloak integration enabled with incomplete auth configuration
- **WHEN** Docling Keycloak integration is enabled and required auth values are incomplete
- **THEN** preflight validation fails with a clear message before containers start

#### Scenario: Keycloak integration disabled
- **WHEN** Docling Keycloak integration is disabled
- **THEN** Keycloak-specific checks do not block Docling startup

#### Scenario: Observability integration disabled
- **WHEN** Docling observability integration is disabled
- **THEN** observability-specific checks do not block Docling startup
