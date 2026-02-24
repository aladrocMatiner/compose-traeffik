# scripts-docs Specification

## Purpose
TBD - created by archiving change add-scripts-docs. Update Purpose after archive.
## Requirements
### Requirement: Scripts documentation
The system SHALL document all operational scripts in `scripts/README.md`, including purpose, usage, required env vars, and side effects.

#### Scenario: Script inventory
- **WHEN** a user opens `scripts/README.md`
- **THEN** they can find every script listed with its purpose and how to run it

### Requirement: README link to scripts
The system SHALL link to `scripts/README.md` from the root README in a visible location.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can navigate to the scripts documentation

### Requirement: LiteLLM bootstrap script documentation
The scripts documentation SHALL describe the LiteLLM bootstrap helper and its usage.

#### Scenario: Script inventory includes LiteLLM bootstrap
- **WHEN** a user reads `scripts/README.md`
- **THEN** `scripts/litellm-bootstrap.sh` is listed with purpose, invocation path (`make litellm-bootstrap`), required inputs, and side effects on `.env`

### Requirement: Rotation behavior documented
The scripts documentation SHALL describe how to rotate LiteLLM bootstrap-generated secrets.

#### Scenario: Secret rotation instructions
- **WHEN** a user needs to replace LiteLLM secrets
- **THEN** `scripts/README.md` documents the supported force/rotation workflow and cautions about invalidating existing clients

