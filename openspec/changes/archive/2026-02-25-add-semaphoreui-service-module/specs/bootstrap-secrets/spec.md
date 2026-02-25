## ADDED Requirements

### Requirement: Semaphore UI bootstrap secrets persistence
The system SHALL persist Semaphore UI bootstrap secrets and generated defaults in `.env` so repeated bootstrap runs remain idempotent.

#### Scenario: First Semaphore UI bootstrap
- **WHEN** a user runs `make semaphoreui-bootstrap` without existing Semaphore UI secrets in `.env`
- **THEN** the bootstrap generates required secrets and stores them in `.env`
- **AND** subsequent runs reuse the stored values by default

#### Scenario: Forced secret rotation
- **WHEN** a user runs the Semaphore UI bootstrap with an explicit force/rotation flag
- **THEN** bootstrap-managed Semaphore UI secrets are regenerated and persisted
- **AND** the documentation explains the operational impact
