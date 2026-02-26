## ADDED Requirements

### Requirement: Rocket.Chat static smoke suite documentation
The system SHALL document the Rocket.Chat static smoke suite in `tests/README.md`, including what it validates and how to run it.

#### Scenario: Contributor runs Rocket.Chat static checks
- **WHEN** a contributor reads `tests/README.md`
- **THEN** they can run `make test-rocketchat`
- **AND** they understand that the suite validates wiring/guardrails/rendering rather than a full Rocket.Chat runtime flow
