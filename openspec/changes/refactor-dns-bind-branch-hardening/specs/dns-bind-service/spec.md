## MODIFIED Requirements

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
