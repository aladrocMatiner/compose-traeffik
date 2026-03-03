## ADDED Requirements
### Requirement: Plane profile preflight validation is profile-gated and integration-aware
The system SHALL validate Plane configuration before compose execution when the `plane` profile is enabled, including core secrets/hostname checks and optional integration checks for Keycloak and observability.

#### Scenario: Missing core Plane configuration
- **WHEN** `COMPOSE_PROFILES` includes `plane` and required Plane values are missing or placeholders
- **THEN** preflight validation fails with clear remediation guidance (including bootstrap command hints)

#### Scenario: Keycloak integration enabled with incomplete OIDC configuration
- **WHEN** Plane OIDC integration is enabled and required Keycloak/OIDC values are incomplete
- **THEN** preflight validation fails with a clear message before containers start

#### Scenario: Keycloak integration disabled
- **WHEN** Plane OIDC integration is disabled
- **THEN** Keycloak-specific checks do not block Plane startup

#### Scenario: Observability integration disabled
- **WHEN** Plane observability integration is disabled
- **THEN** observability-specific checks do not block Plane startup
