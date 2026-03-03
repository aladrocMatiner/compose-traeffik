## ADDED Requirements
### Requirement: Docling bootstrap secrets are generated and persisted idempotently
The system SHALL provide a Docling bootstrap flow that generates required secrets in `.env` when missing, preserves them on rerun by default, and supports explicit rotation.

#### Scenario: Docling bootstrap with missing secrets
- **WHEN** a user runs `make docling-bootstrap` and required Docling secrets are absent
- **THEN** secure values are generated and persisted in `.env`

#### Scenario: Docling bootstrap idempotent rerun
- **WHEN** `make docling-bootstrap` is re-run and required Docling secrets already exist
- **THEN** existing values are reused by default
- **AND** secrets are rotated only when an explicit force/rotation action is requested
