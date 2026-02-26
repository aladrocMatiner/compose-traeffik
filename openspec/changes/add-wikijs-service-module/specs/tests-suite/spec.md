## ADDED Requirements

### Requirement: Service-specific static smoke suites cover Wiki.js module wiring
The system SHALL support a dedicated service-specific static smoke suite for the Wiki.js module in addition to the default `make test` suite.

#### Scenario: Contributor runs the Wiki.js static suite
- **WHEN** a contributor needs to validate only the Wiki.js module planning contracts and wiring
- **THEN** they can run a dedicated make target for Wiki.js smoke tests
- **AND** the target executes the Wiki.js static checks without requiring a full runtime startup
