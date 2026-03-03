## ADDED Requirements
### Requirement: Docling endpoint and integration behavior are documented in root docs
The system SHALL document the Docling endpoint, profile usage, and integration behavior for Step-CA, Keycloak, and observability in root README guidance.

#### Scenario: User reads endpoint list
- **WHEN** a user reviews the Endpoints section
- **THEN** `https://docling.<DEV_DOMAIN>` is listed with profile and security notes consistent with repository conventions

#### Scenario: User reviews integration behavior
- **WHEN** a user reads Docling setup instructions in root docs
- **THEN** documentation explains how Docling behaves with Step-CA, Keycloak, and observability enabled and disabled
- **AND** it clarifies that baseline Docling startup does not require optional integrations
