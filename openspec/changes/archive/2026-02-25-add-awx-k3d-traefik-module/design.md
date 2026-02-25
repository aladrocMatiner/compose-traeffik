## Context

El repositorio está diseñado alrededor de Docker Compose + Traefik + Make, con guardrails, bootstrap de secretos y smoke tests ligeros. AWX introduce una excepción importante: el despliegue soportado upstream usa `AWX Operator` sobre Kubernetes.

El objetivo es integrarlo sin romper el patrón operativo del repo y sin obligar a un clúster externo. `k3d` se elige como runtime local por encajar con Docker y permitir recreación rápida.

## Goals / Non-Goals

- Goals:
- Desplegar AWX de forma soportada (Operator + Kubernetes) usando `k3d` local.
- Mantener Traefik del repo como edge TLS único para `awx.<DEV_DOMAIN>`.
- Exponer ciclo de vida completo vía `make awx-*` y scripts del repo.
- Proveer bootstrap de secretos, guardrails y documentación completa.
- Definir tests estáticos reproducibles + checklist de validación runtime manual.

- Non-Goals:
- No introducir observabilidad completa de AWX en Kubernetes (Prometheus/Loki) en esta primera change.
- No soportar despliegue AWX en clúster remoto (`external-k8s`) en esta iteración.
- No cubrir backup/restore/upgrade de producción en detalle (se planifica en change separada de day-2).
- No exponer receptor/mesh ingress (TCP 27199) en el MVP.

## Proposed Architecture

### High-level

- `Traefik` (Compose) permanece como proxy/TLS y expone `https://awx.<DEV_DOMAIN>`.
- `k3d` crea un clúster K3s local con Traefik interno deshabilitado (`--disable=traefik`) para evitar doble edge/proxy.
- AWX se despliega en Kubernetes mediante `AWX Operator` + recurso `AWX` (CR).
- El servicio web de AWX se expone como `NodePort` fijo mapeado al host por `k3d`.
- Traefik enruta a ese backend usando file provider (upstream `host.docker.internal:<AWX_NODEPORT_HTTP>`).
  - Si la implementación necesita desacoplar el puerto `NodePort` de Kubernetes del puerto publicado en el host, el cambio deberá introducir una variable separada y documentarla explícitamente (sin asumir igualdad implícita).

### Why NodePort + host-gateway

- Evita acoplar Traefik (Compose) a la red Docker interna de `k3d`.
- Simplifica la conectividad Linux usando `host.docker.internal` con `host-gateway`.
- Mantiene el patrón del repo (Traefik file provider para rutas no-Docker, si se añade la plantilla correspondiente).

### Service Directory Layout (Hybrid Module)

`services/awx/` contendrá:
- README(s) del servicio
- manifests/plantillas Kubernetes (`namespace`, `operator values`, `AWX` CR)
- scripts auxiliares o templates de render
- (opcional) manifiestos de secrets no sensibles templados

No se planifica `services/awx/compose.yml` como runtime principal porque AWX no corre en Compose. Se documenta como módulo híbrido y se actualiza `services-layout` para reflejar esta excepción soportada.

## Key Decisions

- Decision: `k3d` es el modo local por defecto para AWX.
- Rationale: mejor encaje con Docker/Compose, destrucción/recreación rápida, menor fricción para este repo.

- Decision: Traefik del repo sigue siendo el edge TLS para AWX.
- Rationale: reutiliza los modos TLS A/B/C, middlewares, docs y operación homogénea.

- Decision: Exposición AWX en K8s vía `NodePort` fijo, no ingress interno en el MVP.
- Rationale: reduce complejidad y evita conflicto con Traefik interno de K3s/K3d.

- Decision: Bootstrap persistirá secretos AWX en `.env` para reproducibilidad local.
- Rationale: alinea con el patrón existente de bootstrap de credenciales/htpasswd.

- Decision: Tests AWX del MVP serán estáticos (wiring/guardrails/templates) + checklist runtime manual.
- Rationale: minimiza dependencias pesadas en `make test` y deja validación runtime explícita.

## Security Considerations

- AWX solo debe exponerse públicamente por Traefik (HTTPS) usando `awx.<DEV_DOMAIN>`.
- El `NodePort` usado por AWX debe quedar mapeado al host de forma controlada (preferencia loopback si `k3d`/entorno lo permite; si no, guardrail + documentación de riesgo).
- Traefik debe aplicar `security-headers@file` al router AWX por defecto.
- Validar configuración de cookies seguras (`csrf_cookie_secure`, `session_cookie_secure`) en la instancia AWX al operar detrás de HTTPS reverse proxy.
- Secretos AWX (admin password / secret key) no se commitean; se generan con bootstrap idempotente.
- Scripts de administración (`awx-admin-password`, `awx-logs`) no deben volcar secretos a logs por defecto salvo comando explícito.

## Operational Considerations

- Herramientas host requeridas: `docker`, `k3d`, `kubectl`, `helm`.
- Versionado/pinning a documentar: `k3d`, imagen K3s usada por `k3d`, `awx-operator`, y versión AWX objetivo.
- Recursos recomendados (documentar): CPU/RAM mínimos para AWX lab (AWX + operator + postgres en k3d).
- Tiempos de arranque largos: `make awx-up` debe incluir waits con timeouts claros y mensajes de progreso.
- `make awx-down` y `make awx-k3d-down` deben tener semánticas distintas (borrar instancia vs destruir clúster).

## Risks / Trade-offs

- Riesgo: incompatibilidades por cambios upstream del AWX Operator (chart, CR fields, secrets esperados).
- Mitigación: paso explícito de verificación de contrato upstream y pin de versiones antes de implementar.

- Riesgo: complejidad extra por módulo híbrido (Compose + K8s tooling).
- Mitigación: scripts/wrappers dedicados y guardrails de prerequisitos.

- Riesgo: routing Traefik -> NodePort falla por diferencias de red en Linux/macOS.
- Mitigación: documentar y validar `host.docker.internal` + `host-gateway`; incluir test estático y checklist runtime.

- Riesgo: scripts `kubectl/helm` apunten accidentalmente a un clúster/contexto equivocado.
- Mitigación: fijar `KUBECONFIG` del repo y validar contexto/cluster esperado antes de aplicar cambios.

- Riesgo: AWX requiere más recursos que el resto del stack y la experiencia local sea lenta.
- Mitigación: documentar sizing mínimo y timeouts configurables.

## Implementation Phasing (for medium Codex agent)

### Phase 1 (this change)
- k3d cluster lifecycle + operator install + AWX instance (single local mode)
- Traefik route integration via file provider
- Make targets + bootstrap secrets + guardrails
- docs + smoke tests estáticos + runtime checklist

### Phase 2 (separate day-2 change)
- Backup/restore/upgrade runbooks y comandos auxiliares
- Export de soporte/debug bundles
- endurecimiento operacional adicional

## Validation Strategy (planned)

- Static validation:
- `bash -n` de scripts nuevos
- smoke tests AWX (wiring/guardrails/templates)
- `openspec validate ... --strict`
- `make docs-check`

- Runtime manual validation:
- `make awx-bootstrap`
- `make awx-k3d-up`
- `make awx-up`
- `make awx-status`
- `make awx-admin-password`
- acceso a `https://awx.<DEV_DOMAIN>` via Traefik
- login UI/API básico y comprobación de cookies/sesión bajo HTTPS proxy
