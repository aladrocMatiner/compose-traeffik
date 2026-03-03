## ADDED Requirements
### Requirement: Plane service receives service-scoped smoke coverage
The test suite SHALL include Plane-specific smoke tests for compose wiring, guardrails, Makefile targets, bootstrap behavior, and optional integration toggles.

#### Scenario: Plane smoke target execution
- **WHEN** a contributor runs `make test-plane`
- **THEN** Plane smoke tests execute without requiring unrelated module tests

#### Scenario: Service-aware healthcheck integration
- **WHEN** Plane services are running during `make test`
- **THEN** `scripts/healthcheck.sh` executes the Plane smoke suite according to service-aware test selection rules
