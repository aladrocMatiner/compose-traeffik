## ADDED Requirements
### Requirement: Bind DNS service with admin UI
El sistema MUST ofrecer un servicio DNS basado en BIND bajo un profile `bind`, con una UI web administrable expuesta via Traefik.

#### Scenario: UI accesible con BasicAuth
- **WHEN** el profile `bind` esta activo
- **THEN** la UI responde en `https://bind.${BASE_DOMAIN}`
- **AND** solicita BasicAuth usando el htpasswd configurado

#### Scenario: Credenciales persistentes
- **WHEN** se ejecuta el bootstrap en modo full
- **THEN** se generan credenciales en `.env` si faltan
- **AND** se regenera el archivo htpasswd desde `.env`
