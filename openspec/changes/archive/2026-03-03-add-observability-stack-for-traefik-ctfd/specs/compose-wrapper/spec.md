## ADDED Requirements
### Requirement: Observability module Makefile wrappers
The system SHALL provide module-scoped Makefile targets for the observability stack that invoke the shared compose wrapper and preserve deterministic compose project behavior.

#### Scenario: Observability up/down/status
- **WHEN** a user runs `make observability-up`, `make observability-down`, or `make observability-status`
- **THEN** the commands use `scripts/compose.sh` with the `observability` profile
- **AND** they operate on the observability services without requiring manual compose flags
