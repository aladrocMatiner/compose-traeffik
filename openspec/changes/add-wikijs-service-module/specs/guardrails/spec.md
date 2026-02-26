## ADDED Requirements

### Requirement: Wiki.js profile preflight validation
The system SHALL validate Wiki.js profile inputs and rendered-config prerequisites before compose operations when the `wikijs` profile is used, and SHALL validate optional integration inputs only when those integrations are enabled.

#### Scenario: Wiki.js profile enabled without rendered config
- **WHEN** `COMPOSE_PROFILES` includes `wikijs` and the required Wiki.js rendered config artifact is missing
- **THEN** preflight validation fails with a clear message instructing the operator to run the Wiki.js bootstrap/render command

#### Scenario: Keycloak integration enabled with invalid inputs
- **WHEN** the Wiki.js Keycloak integration is enabled and the configured issuer URL or required credentials are invalid
- **THEN** preflight validation fails with a clear message

#### Scenario: Optional observability or step-ca trust inputs are invalid
- **WHEN** Wiki.js optional observability or step-ca trust hooks are enabled and their configured mode-specific inputs (for example ports, paths, or booleans) are invalid
- **THEN** preflight validation fails with a clear message
