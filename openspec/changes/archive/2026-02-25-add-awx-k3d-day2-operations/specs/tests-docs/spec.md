## MODIFIED Requirements
### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

### Requirement: README link to tests
The system SHALL link to `tests/README.md` from the root README.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can find a direct link to the smoke test documentation

### Requirement: Day-2 validation guidance is documented
La documentación de tests/runbooks SHALL indicar cómo validar manualmente operaciones day-2 de servicios con estado (por ejemplo AWX restore/upgrade) cuando esas validaciones no forman parte de `make test`.

#### Scenario: Restore validation checklist
- **WHEN** un operador ejecuta un restore de AWX
- **THEN** la documentación ofrece una checklist de validación manual posterior (UI/API accesible, login, jobs básicos, estado de pods)
