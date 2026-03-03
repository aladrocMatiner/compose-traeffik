## ADDED Requirements
### Requirement: Docling module lifecycle targets use the shared compose wrapper
The system SHALL provide Docling module lifecycle targets that use `scripts/compose.sh` and the `docling` profile, preserving deterministic compose project behavior.

#### Scenario: Docling lifecycle commands
- **WHEN** a user runs `make docling-up`, `make docling-down`, or `make docling-status`
- **THEN** commands execute through the shared compose wrapper with `--profile docling`
- **AND** they operate only on Docling module services

#### Scenario: Docling smoke target
- **WHEN** a user runs `make test-docling`
- **THEN** only Docling-specific smoke tests are executed using repository test wrappers
