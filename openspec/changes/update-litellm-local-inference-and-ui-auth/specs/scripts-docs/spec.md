## MODIFIED Requirements
### Requirement: LiteLLM bootstrap script documentation
The scripts documentation SHALL describe the LiteLLM bootstrap helper and its usage.

#### Scenario: Script inventory includes LiteLLM bootstrap
- **WHEN** a user reads `scripts/README.md`
- **THEN** `scripts/litellm-bootstrap.sh` is listed with purpose, invocation path (`make litellm-bootstrap`), required inputs, and side effects on `.env`

#### Scenario: Rotation behavior documented
- **WHEN** a user needs to replace LiteLLM secrets
- **THEN** `scripts/README.md` documents the supported force/rotation workflow and cautions about invalidating existing clients

#### Scenario: UI credentials and htpasswd side effects documented
- **WHEN** `make litellm-bootstrap` also generates LiteLLM management UI credentials/htpasswd files
- **THEN** `scripts/README.md` documents the additional files/variables written and the auth path convention used

#### Scenario: Standalone LiteLLM mode workflow documented
- **WHEN** standalone `Traefik + LiteLLM` Make targets are added
- **THEN** `scripts/README.md` or the root operational docs explain how those targets differ from `make up` and `make litellm-up`
