## ADDED Requirements
### Requirement: Plane bootstrap secrets are generated and persisted idempotently
The system SHALL provide a Plane bootstrap flow that generates required secrets in `.env` when missing, preserves them on rerun by default, and supports explicit rotation.

#### Scenario: Plane bootstrap with missing secrets
- **WHEN** a user runs `make plane-bootstrap` and required Plane secrets are absent
- **THEN** secure values are generated and persisted in `.env`

#### Scenario: Plane bootstrap idempotent rerun
- **WHEN** `make plane-bootstrap` is re-run and required Plane secrets already exist
- **THEN** existing values are reused by default
- **AND** secrets are rotated only when an explicit force/rotation action is requested
