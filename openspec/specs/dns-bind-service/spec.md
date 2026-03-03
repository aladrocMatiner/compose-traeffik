# dns-bind-service Specification

## Purpose
TBD - created by archiving change add-bind-dns-service-ui. Update Purpose after archive.
## Requirements
### Requirement: Bind DNS service with admin UI
El sistema MUST ofrecer un servicio DNS basado en BIND bajo un profile `bind`, con publicacion de DNS autoritativo para el dominio base sin depender de una UI web.

#### Scenario: Servicio BIND accesible en profile bind
- **WHEN** el profile `bind` esta activo
- **THEN** el contenedor `bind` inicia con configuracion montada desde `services/dns-bind/`
- **AND** expone `53/udp` y `53/tcp` ligados por `BIND_BIND_ADDRESS` (localhost por defecto)

#### Scenario: Sin dependencia de UI DNS
- **WHEN** el stack se ejecuta con BIND
- **THEN** no se requiere un router/UI DNS en Traefik para que la resolucion DNS funcione
- **AND** el flujo operativo usa `make bind-up`, `make bind-logs` y `make bind-down`

### Requirement: BIND hardened runtime defaults
The system SHALL run BIND with hardened defaults that minimize attack surface for local authoritative DNS operation.

#### Scenario: Service starts with hardened options
- **WHEN** BIND is started through the `bind` profile
- **THEN** recursion is disabled
- **AND** zone transfer is denied by default
- **AND** metadata disclosure via CHAOS queries is minimized

#### Scenario: Configuration validated before daemon start
- **WHEN** the BIND container command executes
- **THEN** it validates the rendered configuration and target zone before launching `named`
- **AND** startup fails fast if validation fails

### Requirement: Make lifecycle interface for BIND operations
The system SHALL expose BIND lifecycle operations through Make targets `bind-up`, `bind-down`, `bind-logs`, `bind-status`, and `bind-restart`.

#### Scenario: Start BIND service
- **WHEN** an operator runs `make bind-up`
- **THEN** compose starts the BIND workload with profile `bind`
- **AND** the command targets the BIND service flow for this branch

#### Scenario: Restart BIND service quickly
- **WHEN** an operator runs `make bind-restart`
- **THEN** the command performs a stop/start cycle equivalent to the documented BIND lifecycle operations
- **AND** avoids requiring manual sequencing in daily operations

#### Scenario: Inspect BIND runtime
- **WHEN** an operator runs `make bind-status` or `make bind-logs`
- **THEN** the command outputs only BIND-relevant status/log information
- **AND** does not depend on legacy DNS service naming

