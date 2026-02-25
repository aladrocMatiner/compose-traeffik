## MODIFIED Requirements
### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

#### Scenario: Keycloak smoke tests documented
- **WHEN** the Keycloak module introduces smoke tests (including observability wiring tests)
- **THEN** `tests/README.md` documents them and distinguishes static checks from manual runtime validation

#### Scenario: Keycloak runtime checklist includes real auth flow sanity
- **WHEN** the Keycloak module documentation describes manual runtime validation
- **THEN** it includes more than landing-page reachability (for example login page/admin console or token endpoint sanity)
- **AND** it states how to validate observability-enabled vs disabled behavior when applicable

### Requirement: README link to tests
The system SHALL link to `tests/README.md` from the root README.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can find a direct link to the smoke test documentation
