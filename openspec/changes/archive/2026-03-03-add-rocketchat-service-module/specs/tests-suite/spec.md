## ADDED Requirements

### Requirement: Service-specific static smoke suites
The system SHALL support documented service-specific static smoke suites in addition to the default `make test` suite when a module requires targeted wiring and guardrail checks.

#### Scenario: Rocket.Chat static suite is available
- **WHEN** a contributor needs to validate only the Rocket.Chat module wiring
- **THEN** they can run a dedicated make target for Rocket.Chat smoke tests
- **AND** the target executes the Rocket.Chat module static checks without requiring a full runtime startup
