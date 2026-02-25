## ADDED Requirements
### Requirement: AWX local deployment via k3d and AWX Operator
El sistema SHALL permitir desplegar una instancia local de AWX usando `k3d` + `AWX Operator` mediante scripts y targets Make del repositorio.

#### Scenario: Deploy AWX in local lab mode
- **WHEN** un operador ejecuta el flujo documentado (`awx-bootstrap`, `awx-k3d-up`, `awx-up`)
- **THEN** el repositorio crea/usa un clúster `k3d`, instala el `AWX Operator` y aplica una instancia AWX funcional
- **AND** el flujo usa versiones pinneadas y configuración reproducible del repositorio

### Requirement: Traefik edge exposure for AWX
El sistema SHALL exponer la UI/API de AWX por el Traefik del repositorio en `https://awx.<DEV_DOMAIN>` usando HTTPS y middlewares de seguridad del repo.

#### Scenario: Access AWX through repository Traefik
- **WHEN** AWX está desplegado y Traefik está activo
- **THEN** el acceso a AWX se realiza mediante `https://awx.<DEV_DOMAIN>`
- **AND** la ruta aplica `security-headers@file` por defecto
- **AND** AWX no requiere exponer un host:port público alternativo como interfaz primaria para el usuario

### Requirement: AWX backend exposure strategy is explicit and bounded
El sistema SHALL documentar y configurar una estrategia explícita para conectar Traefik (Compose) con AWX (k3d), incluyendo el puerto backend y sus límites de exposición.

#### Scenario: NodePort backend is configured for Traefik reachability
- **WHEN** el módulo AWX usa `NodePort` para exponer AWX desde k3d
- **THEN** el `NodePort` es configurable por `.env` dentro de un rango válido
- **AND** la documentación indica cómo Traefik alcanza ese backend (por ejemplo `host.docker.internal`)
- **AND** se explicitan los riesgos si el puerto queda expuesto fuera del uso previsto

### Requirement: Reverse-proxy security settings for AWX
El sistema SHALL planificar/configurar los ajustes de AWX necesarios para operar correctamente detrás de HTTPS reverse proxy.

#### Scenario: Secure cookies behind TLS-terminating proxy
- **WHEN** AWX se sirve detrás de Traefik con terminación TLS
- **THEN** la configuración de AWX contempla ajustes de cookies/sesión/CSRF seguros (por ejemplo `csrf_cookie_secure` y `session_cookie_secure`)
- **AND** el flujo de validación runtime incluye comprobación de login básico vía proxy
