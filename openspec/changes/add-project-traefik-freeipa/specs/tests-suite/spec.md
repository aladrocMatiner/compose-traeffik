## ADDED Requirements

### Requirement: FreeIPA smoke suite is part of documented service-aware testing
The system SHALL provide a FreeIPA smoke suite and document it in the smoke test inventory.

#### Scenario: Operator runs FreeIPA smoke suite
- **WHEN** an operator runs `make test-freeipa`
- **THEN** FreeIPA service configuration, make wiring, bootstrap idempotency, guardrails, and optional integration contracts are validated.

#### Scenario: Service-aware test runner detects FreeIPA
- **WHEN** FreeIPA container is running and `make test` executes `scripts/healthcheck.sh`
- **THEN** the FreeIPA smoke subset is executed as part of service-aware suites.
