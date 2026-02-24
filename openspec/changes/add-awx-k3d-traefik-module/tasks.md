## 1. Upstream Contract Verification (Required before coding)

- [x] 1.1 Verificar versión estable objetivo de `awx-operator` y `awx` (tag pinneado) y registrar links oficiales en `services/awx/README*.md`. *(Verificado upstream: chart `3.2.0` -> operator `2.19.1`; AWX docs/referencia target `24.6.1`.)*
- [x] 1.2 Verificar método de instalación del operator por `helm` (repo/chart/CRDs) y sintaxis actual de los campos CR usados (`service_type`, admin secret, `extra_settings`, etc.). *(Verificado por docs/operator docs + helm repo; implementación base usa Helm chart + CR template, pendiente validación runtime de todos los campos.)*
- [x] 1.3 Verificar guía de exposición de AWX detrás de reverse proxy/TLS (cookies seguras, settings Django/AWX aplicables). *(Campos `csrf_cookie_secure` y `session_cookie_secure` incluidos en la plantilla CR.)*
- [x] 1.4 Verificar sintaxis actual de `k3d cluster create` para mapear NodePort (y host-port si se desacoplan) y deshabilitar Traefik interno (`--disable=traefik`). *(Validado runtime con `k3d` local: cluster creado con `--disable=traefik` y mapeo host-port -> NodePort.)*

## 2. Module Layout and Templates

- [x] 2.1 Crear `services/awx/` con estructura híbrida documentada (`README*.md`, `k8s/`, `templates/` si aplica).
- [x] 2.2 Añadir manifiesto/plantilla de namespace y/o operator install values (`services/awx/k8s/operator/`).
- [x] 2.3 Añadir plantilla de recurso `AWX` (CR) con placeholders para hostname, service type, NodePort y settings proxy/TLS.
- [x] 2.4 Añadir plantillas/manifestos de secrets no sensibles (nombres/estructuras) sin commitear valores reales.

## 3. k3d and Kubernetes Tooling Scripts

- [x] 3.1 Crear wrapper(s) AWX/k3d (`scripts/awx-k3d-up.sh`, `scripts/awx-k3d-down.sh`) con soporte `--env-file`.
- [x] 3.2 Crear script de despliegue AWX (`scripts/awx-up.sh`) que instale/actualice operator y aplique el CR.
- [x] 3.3 Crear scripts utilitarios (`scripts/awx-status.sh`, `scripts/awx-admin-password.sh`, `scripts/awx-logs.sh`, `scripts/awx-down.sh`).
- [x] 3.4 Asegurar que scripts usan `KUBECONFIG` controlado por el repo (ruta configurable), validan contexto/cluster esperado y muestran mensajes claros de error.
- [x] 3.5 Asegurar idempotencia razonable: reruns no deben destruir cluster/instance salvo flags explícitos.

## 4. Traefik Integration for AWX External Upstream

- [x] 4.1 Añadir plantilla de Traefik file-provider para AWX (`services/traefik/dynamic/awx.yml`) con router HTTPS + middleware `security-headers@file`.
- [x] 4.2 Ampliar `scripts/traefik-render-dynamic.sh` para renderizar/gatear la config AWX según activación del módulo (`COMPOSE_PROFILES` o variable explícita `AWX_ENABLED`).
- [x] 4.3 Añadir/ajustar conectividad `host.docker.internal` en `services/traefik/compose.yml` (Linux `host-gateway`) para reachability al NodePort de k3d.
- [x] 4.4 Documentar y validar estrategia de upstream (`host.docker.internal:<puerto host mapeado al servicio AWX>`) y timeouts básicos. *(Traefik -> AWX validado con respuesta `302` via `https://awx.<DEV_DOMAIN>`.)*

## 5. Environment and Bootstrap Secrets

- [x] 5.1 Añadir variables `AWX_*` y `K3D_*` en `.env.example` (hostname, namespace, cluster name, NodePort, host-port si aplica, versiones incluyendo imagen K3s, kubeconfig path, admin user/password, secret key).
- [x] 5.2 Crear `scripts/awx-bootstrap.sh` para generar/persistir secretos AWX en `.env` (idempotente; `--force` para rotación).
- [x] 5.3 Añadir target `make awx-bootstrap` y documentar semántica de rotación.
- [x] 5.4 Definir defaults seguros (pin de versiones, no exposición directa de AWX fuera de Traefik, timeouts conservadores). *(Pin base de chart/operator/K3s en `.env.example`; exposición primaria vía Traefik documentada.)*

## 6. Guardrails and Preflight Validation

- [x] 6.1 Extender `scripts/validate-env.sh` con validaciones AWX/k3d profile-gated (hostname label, NodePort range, valores obligatorios no placeholder). *(Se integra por `AWX_ENABLED=true` delegando en `scripts/validate-awx-env.sh`.)*
- [x] 6.2 Validar presencia de herramientas requeridas (`docker`, `k3d`, `kubectl`, `helm`) para targets AWX/k3d antes de ejecutar.
- [x] 6.3 Validar conflicto de puertos/cluster names conocidos (o al menos mensajes de diagnóstico claros). *(`awx-k3d-up` ahora detecta puerto host ocupado con `ss`/`lsof` y da mensaje claro.)*
- [x] 6.4 Validar ruta de kubeconfig bajo directorios permitidos y gitignored del repo (o documentar y aceptar override explícito).
- [x] 6.5 Añadir/actualizar `.gitignore` para kubeconfigs locales y artefactos generados del módulo AWX que no deben versionarse.

## 7. Makefile Integration (Hybrid Module)

- [x] 7.1 Añadir targets `awx-bootstrap`, `awx-k3d-up`, `awx-k3d-down`, `awx-up`, `awx-down`, `awx-status`, `awx-logs`, `awx-admin-password`.
- [x] 7.2 Integrar `make help` con descripción clara de la semántica (instancia vs clúster).
- [x] 7.3 Definir comportamiento de `awx-up` respecto a Traefik (precondición documentada vs auto-start de Traefik).
- [x] 7.4 Mantener compatibilidad con `ENV_FILE` / `COMPOSE_PROFILES` y wrappers existentes.

## 8. Smoke Tests (Static) and Runtime Checklist

- [x] 8.1 Añadir smoke test de wiring de Make (`tests/smoke/test_awx_make_targets.sh`).
- [x] 8.2 Añadir smoke test de guardrails AWX/k3d (`tests/smoke/test_awx_guardrails.sh`).
- [x] 8.3 Añadir smoke test de plantillas/manifiestos AWX (`tests/smoke/test_awx_k8s_templates.sh`).
- [x] 8.4 Añadir smoke test de integración Traefik route AWX (`tests/smoke/test_awx_traefik_routing_config.sh`).
- [x] 8.5 Documentar checklist runtime manual en `tests/README.md` y `services/awx/README*.md` (no meterlo en `make test` por defecto).
- [x] 8.6 (Opcional según rama base) Añadir `make test-awx` o integrar el suite AWX al patrón de tests particionados por servicio si ya existe.

## 9. Documentation (Root, Service, Scripts, Tests)

- [x] 9.1 Actualizar `README.md`, `README.es.md`, `README.sv.md` con endpoint AWX, prerequisitos k3d/K8s y comandos AWX.
- [x] 9.2 Crear `services/awx/README.md`, `services/awx/README.es.md`, `services/awx/README.sv.md` con arquitectura híbrida, flujo de bootstrap/deploy, troubleshooting y seguridad.
- [x] 9.3 Actualizar `scripts/README.md` con scripts AWX/k3d/K8s.
- [x] 9.4 Actualizar `tests/README.md` con inventario de tests AWX y separación entre tests estáticos y validación runtime manual.
- [x] 9.5 Actualizar `docs.manifest.json` para incluir `awx`.
- [x] 9.6 Documentar relación con `ENDPOINTS` / hosts mapping (`awx`) y modos TLS A/B/C del repo.

## 10. Validation and Handoff

- [x] 10.1 Ejecutar `openspec validate add-awx-k3d-traefik-module --strict`.
- [x] 10.2 Ejecutar `bash -n` sobre scripts/tests AWX nuevos.
- [x] 10.3 Ejecutar smoke tests AWX estáticos y `make docs-check`.
- [x] 10.4 Realizar validación runtime manual mínima (`awx-bootstrap`, `awx-k3d-up`, `awx-up`, acceso UI via Traefik) y documentar resultados. *(Validado en host local con `k3d/kubectl/helm`: cluster creado, AWX deploy aplicado, `awx-admin-password` funciona, `awx-web`/`awx-task` en `Running` y UI responde `HTTP 200` via Traefik; el primer arranque tarda varios minutos por migraciones e imagen `awx-ee`.)*
- [x] 10.5 Actualizar `tasks.md` marcando solo lo realmente completado y anotar gaps (por ejemplo runtime parcial).
