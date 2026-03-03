## MODIFIED Requirements

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
