## Why

AWX ya no se despliega de forma soportada con `docker compose`; el camino oficial es Kubernetes + AWX Operator. Para integrarlo en este repositorio sin romper el patrón operativo existente (Traefik + Make + scripts + docs + smoke tests), necesitamos definir un módulo híbrido: `Traefik` en Compose y `AWX` en un clúster local `k3d` gestionado por scripts del repo.

## What Changes

- Añadir un módulo híbrido `awx` con despliegue de AWX sobre `k3d` + `AWX Operator`, manteniendo `Traefik` del repo como edge TLS para `awx.<DEV_DOMAIN>`.
- Definir ciclo de vida vía `Makefile` y scripts (`k3d`, `kubectl`, `helm`) para cluster, operator, instancia AWX y utilidades operativas básicas (status, logs, admin password).
- Añadir integración de Traefik por file-provider hacia un upstream AWX expuesto desde `k3d` (NodePort sobre host), sin exponer directamente AWX al exterior más allá de Traefik.
- Añadir bootstrap de secretos AWX en `.env`, guardrails de prerequisitos/herramientas/puertos/hostnames, y documentación multicapas (root, servicio, scripts, tests).
- Definir smoke tests estáticos y checks de wiring para AWX/k3d, con validación runtime manual documentada para la primera iteración.

## Capabilities

### New Capabilities
- `awx-k3d-service`: despliegue y operación base de AWX sobre k3d detrás de Traefik.
- `k3d-cluster-management`: ciclo de vida del clúster local k3d para módulos Kubernetes.
- `k8s-tooling-wrapper`: wrappers/scripts para operaciones Kubernetes/Helm reproducibles desde el repo.

### Modified Capabilities
- `services-layout`: permitir módulos híbridos (runtime principal no-Compose) manteniendo layout consistente en `services/`.
- `bootstrap-secrets`: ampliar bootstrap para secretos AWX persistidos en `.env`.
- `guardrails`: validar prerequisitos de AWX/k3d y configuración segura antes de acciones destructivas/arranques.
- `docs-endpoints-tls`: documentar endpoint AWX y notas TLS/proxy.
- `tests-suite`: añadir inventario de smoke tests AWX y criterios de validación.
- `tests-docs`: documentar flujo de tests AWX (estático vs runtime manual).
- `scripts-docs`: documentar scripts AWX/k3d/Kubernetes del repo.

## Impact

- Affected code (planned): `Makefile`, `scripts/validate-env.sh`, `scripts/traefik-render-dynamic.sh`, `services/traefik/*`, `.env.example`, `tests/smoke/*`, `tests/README.md`, `README*.md`, `services/awx/*`.
- New dependencies/tools (planned): `k3d`, `kubectl`, `helm` (host tooling).
- New runtime surface (planned): clúster local Kubernetes (`k3d`) además del stack Compose existente.
- No implementación en este cambio; solo planificación detallada para ejecución posterior.
