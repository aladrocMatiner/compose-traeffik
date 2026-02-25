# bootstrap-secrets Specification

## Purpose
TBD - created by archiving change add-env-secrets-htpasswd. Update Purpose after archive.
## Requirements
### Requirement: Persisted bootstrap secrets
El sistema MUST persistir en `.env` las credenciales usadas para generar archivos `htpasswd` y reutilizarlas en ejecuciones posteriores del bootstrap.

#### Scenario: Bootstrap con secretos nuevos
- **WHEN** no existen valores de credenciales en `.env`
- **THEN** el bootstrap genera valores aleatorios seguros y los guarda en `.env`
- **AND** genera los archivos `htpasswd` con esos valores

#### Scenario: Bootstrap idempotente
- **WHEN** ya existen valores de credenciales en `.env`
- **THEN** el bootstrap no los sobrescribe sin un flag explicito
- **AND** re-genera los archivos `htpasswd` con los valores existentes

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

