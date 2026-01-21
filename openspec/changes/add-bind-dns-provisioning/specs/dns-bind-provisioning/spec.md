## ADDED Requirements
### Requirement: Bind DNS zone provisioning
El sistema MUST generar un zone file para BIND usando `ENDPOINTS`, `BASE_DOMAIN` y `LOOPBACK_X`.

#### Scenario: Provision con endpoints
- **WHEN** se ejecuta `bind-provision`
- **THEN** se genera `db.${BASE_DOMAIN}` con registros A para cada endpoint

#### Scenario: Dry-run
- **WHEN** se ejecuta `bind-provision --dry-run`
- **THEN** se imprime el contenido del zone file sin escribir en disco
