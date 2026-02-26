## ADDED Requirements

### Requirement: Wiki.js static smoke suite documentation
The system SHALL document a Wiki.js static smoke suite in `tests/README.md`, including what it validates and how to run it.

#### Scenario: Contributor validates Wiki.js module wiring without runtime startup
- **WHEN** a contributor reads `tests/README.md`
- **THEN** they can run `make test-wikijs`
- **AND** they understand the suite validates wiring, guardrails, and rendering rather than a full Wiki.js runtime flow
