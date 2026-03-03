# bootstrap-secrets Specification

## Purpose
TBD - created by archiving change add-env-secrets-htpasswd. Update Purpose after archive.
## Requirements
### Requirement: Persisted bootstrap secrets
El sistema MUST persistir en `.env` las credenciales usadas para generar archivos `htpasswd` y reutilizarlas en ejecuciones posteriores del bootstrap. Tambien MUST soportar secretos del modulo CTFd generados por `make ctfd-bootstrap` (por ejemplo `CTFD_SECRET_KEY` y credenciales de base de datos/cache) con comportamiento idempotente por defecto.

#### Scenario: Bootstrap con secretos nuevos
- **WHEN** no existen valores de credenciales en `.env`
- **THEN** el bootstrap genera valores aleatorios seguros y los guarda en `.env`
- **AND** genera los archivos `htpasswd` con esos valores

#### Scenario: Bootstrap idempotente
- **WHEN** ya existen valores de credenciales en `.env`
- **THEN** el bootstrap no los sobrescribe sin un flag explicito
- **AND** re-genera los archivos `htpasswd` con los valores existentes

#### Scenario: CTFd bootstrap idempotente
- **WHEN** se ejecuta `make ctfd-bootstrap` y ya existen secretos `CTFD_*` requeridos en `.env`
- **THEN** el comando reutiliza los valores existentes por defecto
- **AND** solo rota secretos con una accion explicita del operador

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

### Requirement: Plane bootstrap secrets are generated and persisted idempotently
The system SHALL provide a Plane bootstrap flow that generates required secrets in `.env` when missing, preserves them on rerun by default, and supports explicit rotation.

#### Scenario: Plane bootstrap with missing secrets
- **WHEN** a user runs `make plane-bootstrap` and required Plane secrets are absent
- **THEN** secure values are generated and persisted in `.env`

#### Scenario: Plane bootstrap idempotent rerun
- **WHEN** `make plane-bootstrap` is re-run and required Plane secrets already exist
- **THEN** existing values are reused by default
- **AND** secrets are rotated only when an explicit force/rotation action is requested

### Requirement: Docling bootstrap secrets are generated and persisted idempotently
The system SHALL provide a Docling bootstrap flow that generates required secrets in `.env` when missing, preserves them on rerun by default, and supports explicit rotation.

#### Scenario: Docling bootstrap with missing secrets
- **WHEN** a user runs `make docling-bootstrap` and required Docling secrets are absent
- **THEN** secure values are generated and persisted in `.env`

#### Scenario: Docling bootstrap idempotent rerun
- **WHEN** `make docling-bootstrap` is re-run and required Docling secrets already exist
- **THEN** existing values are reused by default
- **AND** secrets are rotated only when an explicit force/rotation action is requested

