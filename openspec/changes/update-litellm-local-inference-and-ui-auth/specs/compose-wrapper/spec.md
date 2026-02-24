## ADDED Requirements
### Requirement: Standalone LiteLLM edge mode Make targets
The system SHALL provide dedicated Make targets for a standalone LiteLLM edge mode that starts Traefik and LiteLLM only.

#### Scenario: Standalone startup target
- **WHEN** a user runs the documented standalone LiteLLM startup target
- **THEN** the command uses the standard compose wrapper with `COMPOSE_PROFILES=litellm`
- **AND** it selects `traefik` and `litellm` services explicitly instead of starting the default stack services

#### Scenario: Standalone teardown and logs targets
- **WHEN** a user runs the documented standalone LiteLLM down/logs/status targets
- **THEN** they operate on the same standalone service scope consistently through the compose wrapper

### Requirement: Traefik dynamic config rendering for standalone mode
Standalone LiteLLM edge mode SHALL render Traefik dynamic configuration before starting services.

#### Scenario: Standalone startup pre-render
- **WHEN** a user starts standalone LiteLLM edge mode
- **THEN** the Traefik dynamic config render step runs before compose startup, matching the safety/consistency behavior of `make up`

### Requirement: Standalone mode help discoverability
The Make help output SHALL document the standalone LiteLLM edge mode targets and their scope.

#### Scenario: Help output lists standalone LiteLLM mode
- **WHEN** a user runs `make help`
- **THEN** the output lists the standalone LiteLLM targets and clarifies that they start `traefik` + `litellm` only
