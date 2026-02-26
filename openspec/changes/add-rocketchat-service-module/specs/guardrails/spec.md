## ADDED Requirements

### Requirement: Rocket.Chat profile preflight validation
The system SHALL validate Rocket.Chat profile inputs and rendered config prerequisites before compose operations when the `rocketchat` profile is used.

#### Scenario: Rocket.Chat profile enabled without rendered config
- **WHEN** `COMPOSE_PROFILES` includes `rocketchat` and the rendered Rocket.Chat env file is missing
- **THEN** preflight validation fails with a clear message instructing the operator to run the Rocket.Chat bootstrap/render command

#### Scenario: Optional Keycloak integration enabled with invalid inputs
- **WHEN** Rocket.Chat Keycloak integration is enabled and the issuer URL is not HTTPS or required credentials are missing
- **THEN** preflight validation fails with a clear message

#### Scenario: Optional observability settings are invalid
- **WHEN** Rocket.Chat observability is enabled and the configured metrics port is invalid
- **THEN** preflight validation fails with a clear message
