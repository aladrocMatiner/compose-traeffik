# dns-bind-provisioning Specification

## Purpose
TBD - created by archiving change add-bind-dns-provisioning. Update Purpose after archive.
## Requirements
### Requirement: Bind DNS zone provisioning
El sistema MUST generar un zone file para BIND usando `ENDPOINTS`, `BASE_DOMAIN` y `LOOPBACK_X`, con asignaciones deterministicas para desarrollo local.

#### Scenario: Provision con endpoints
- **WHEN** se ejecuta `bind-provision`
- **THEN** se genera `db.${BASE_DOMAIN}` con registros A para cada endpoint valido
- **AND** el resultado se escribe en `services/dns-bind/zones/`

#### Scenario: Dry-run
- **WHEN** se ejecuta `bind-provision --dry-run`
- **THEN** se imprime el contenido del zone file sin escribir en disco

#### Scenario: Host reservado para bind
- **WHEN** se genera la zona BIND
- **THEN** se incluye el host `bind.${BASE_DOMAIN}` en la IP reservada `127.0.<LOOPBACK_X>.254`
- **AND** un endpoint `bind` en `ENDPOINTS` no genera entradas duplicadas

### Requirement: Secure and validated zone provisioning inputs
The system SHALL validate `BASE_DOMAIN` and endpoint labels before generating a BIND zone file, and SHALL reject malformed values.

#### Scenario: Invalid domain rejected
- **WHEN** `bind-provision` receives an invalid `BASE_DOMAIN`
- **THEN** provisioning exits non-zero with a clear error
- **AND** no zone file is written

#### Scenario: Invalid endpoint rejected
- **WHEN** `bind-provision` receives an endpoint label with invalid DNS characters
- **THEN** provisioning exits non-zero with a clear error
- **AND** no zone file is written

