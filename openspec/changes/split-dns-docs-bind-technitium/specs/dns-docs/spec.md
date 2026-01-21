## ADDED Requirements
### Requirement: DNS documentation split
La documentacion MUST separar la guia de Technitium y la guia de BIND en archivos distintos con enlaces actualizados.

#### Scenario: Guia Technitium
- **WHEN** un usuario busca la guia Technitium
- **THEN** encuentra `service-dns-technitium.md` con el contenido correcto

#### Scenario: Guia BIND
- **WHEN** un usuario busca la guia BIND
- **THEN** encuentra `service-dns-bind.md` con instrucciones del profile `bind`
