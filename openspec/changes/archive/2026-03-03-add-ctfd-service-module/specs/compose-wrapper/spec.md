## ADDED Requirements
### Requirement: CTFd module Makefile wrappers
The system SHALL provide module-scoped Makefile targets for CTFd that invoke the shared compose wrapper and preserve deterministic compose project behavior.

#### Scenario: CTFd up/down/status
- **WHEN** a user runs `make ctfd-up`, `make ctfd-down`, or `make ctfd-status`
- **THEN** the commands use `scripts/compose.sh` with the `ctfd` profile
- **AND** they operate on the CTFd module services without requiring the user to handcraft compose flags
