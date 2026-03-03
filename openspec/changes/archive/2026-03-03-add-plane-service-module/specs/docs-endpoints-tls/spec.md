## ADDED Requirements
### Requirement: Plane endpoint and optional integration behavior are documented in root docs
The system SHALL document the Plane endpoint, profile usage, and optional integration behavior for Step-CA, Keycloak, and observability in root README guidance.

#### Scenario: User reads endpoint list
- **WHEN** a user reviews the Endpoints section
- **THEN** `https://plane.<DEV_DOMAIN>` is listed with profile and security notes consistent with repository conventions

#### Scenario: User reviews optional integrations
- **WHEN** a user reads Plane setup instructions in root docs
- **THEN** documentation explains how Plane behaves with Step-CA, Keycloak, and observability both enabled and disabled
- **AND** it clarifies that these integrations are optional for baseline Plane startup
