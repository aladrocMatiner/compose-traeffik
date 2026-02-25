## MODIFIED Requirements
### Requirement: Scripts documentation
The system SHALL document all operational scripts in `scripts/README.md`, including purpose, usage, required env vars, and side effects.

#### Scenario: Script inventory
- **WHEN** a user opens `scripts/README.md`
- **THEN** they can find every script listed with its purpose and how to run it

#### Scenario: Keycloak scripts documented
- **WHEN** the Keycloak module adds bootstrap or lifecycle helper scripts
- **THEN** `scripts/README.md` documents those scripts, required env vars, and any side effects

### Requirement: README link to scripts
The system SHALL link to `scripts/README.md` from the root README in a visible location.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can navigate to the scripts documentation
