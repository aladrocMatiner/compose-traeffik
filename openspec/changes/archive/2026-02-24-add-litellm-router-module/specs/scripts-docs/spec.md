## ADDED Requirements
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
