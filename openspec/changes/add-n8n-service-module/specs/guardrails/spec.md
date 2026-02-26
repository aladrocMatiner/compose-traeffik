## ADDED Requirements

### Requirement: n8n profile preflight validation
The system SHALL validate n8n profile inputs and rendered-config prerequisites before compose operations when the `n8n` profile is used, and SHALL validate optional integration inputs only when those integrations are enabled.

#### Scenario: n8n profile enabled without rendered config
- **WHEN** `COMPOSE_PROFILES` includes `n8n` and the required n8n rendered config artifact is missing
- **THEN** preflight validation fails with a clear message instructing the operator to run the n8n bootstrap/render command

#### Scenario: Keycloak integration enabled with invalid inputs
- **WHEN** the n8n Keycloak integration is enabled and the configured issuer URL or required credentials are invalid
- **THEN** preflight validation fails with a clear message

#### Scenario: Optional observability or step-ca trust inputs are invalid
- **WHEN** n8n optional observability or step-ca trust hooks are enabled and their configured mode-specific inputs (for example ports, paths, or booleans) are invalid
- **THEN** preflight validation fails with a clear message
