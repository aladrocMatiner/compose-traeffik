# compose-wrapper Specification

## Purpose
TBD - created by archiving change fix-compose-project-pin. Update Purpose after archive.
## Requirements
### Requirement: Deterministic compose project
The system SHALL pin the compose project name and project directory so that commands run from any CWD reuse the same project, networks, and volumes.

#### Scenario: Different CWD
- **WHEN** a compose command is run from a different working directory
- **THEN** the same compose project name and resources are used

### Requirement: Functional ps target
The system SHALL provide a working `make ps` target that lists running services using the standard compose wrapper.

#### Scenario: make ps
- **WHEN** a user runs `make ps`
- **THEN** the command executes successfully and lists services

### Requirement: LiteLLM compose file included in wrapper and Makefile
The system SHALL include the LiteLLM service compose fragment in both `scripts/compose.sh` and `Makefile` `COMPOSE_FILES` lists.

#### Scenario: Wrapper and Makefile parity
- **WHEN** a developer inspects compose file lists in `scripts/compose.sh` and `Makefile`
- **THEN** both include `services/litellm/compose.yml`

### Requirement: LiteLLM lifecycle Make targets
The system SHALL provide service-specific Make targets for LiteLLM lifecycle management using the standard compose wrapper.

#### Scenario: Start LiteLLM service
- **WHEN** a user runs `make litellm-up`
- **THEN** the command invokes `./scripts/compose.sh --profile litellm` to start the `litellm` service

#### Scenario: Stop and inspect LiteLLM service
- **WHEN** a user runs `make litellm-down`, `make litellm-logs`, or `make litellm-status`
- **THEN** each command targets the `litellm` service consistently through the compose wrapper

#### Scenario: Restart LiteLLM service
- **WHEN** a user runs `make litellm-restart`
- **THEN** the command performs the standard service restart workflow for the `litellm` module using the project compose wrapper

### Requirement: Make help discoverability
The system SHALL document LiteLLM Make targets in `make help` output.

#### Scenario: Help output includes LiteLLM section
- **WHEN** a user runs `make help`
- **THEN** the output lists the LiteLLM bootstrap and lifecycle targets with short descriptions

