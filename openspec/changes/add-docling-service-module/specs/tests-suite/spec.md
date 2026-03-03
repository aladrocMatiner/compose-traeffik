## ADDED Requirements
### Requirement: Docling service receives service-scoped smoke coverage
The test suite SHALL include Docling-specific smoke tests for compose wiring, guardrails, Makefile targets, bootstrap behavior, and optional integration toggles.

#### Scenario: Docling smoke target execution
- **WHEN** a contributor runs `make test-docling`
- **THEN** Docling smoke tests execute without requiring unrelated module tests

#### Scenario: Service-aware healthcheck integration
- **WHEN** Docling services are running during `make test`
- **THEN** `scripts/healthcheck.sh` executes the Docling smoke suite according to service-aware test selection rules
