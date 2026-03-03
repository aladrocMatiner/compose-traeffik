## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-freeipa` como proyecto soportado en el catálogo.
- [ ] 1.2 Confirmar dependencias obligatorias: `traefik-stepca`, `traefik-keycloak`, `traefik-observability`.
- [ ] 1.3 Confirmar política TLS: default `stepca-acme` con override explícito soportado.
- [ ] 1.4 Confirmar contrato de autenticación/OIDC con Keycloak para el proyecto.
- [ ] 1.5 Validar artefactos del cambio con `openspec validate add-project-traefik-freeipa --strict`.

## 2. Project Definition and Catalog Wiring

- [ ] 2.1 Crear `deployment/projects/traefik-freeipa/manifest.json`.
- [ ] 2.2 Registrar `traefik-freeipa` en `deployment/projects/catalog.json`.
- [ ] 2.3 Añadir `traefik-freeipa` a `deployment-project-list` y test de salida esperada.

## 3. Deployment Behavior

- [ ] 3.1 Implementar sync del repo/ref pinneado en host objetivo para `project=traefik-freeipa`.
- [ ] 3.2 Ejecutar compose para servicios declarados en manifiesto (sin overrides ad-hoc).
- [ ] 3.3 Aplicar `tls_mode=stepca-acme` por defecto.
- [ ] 3.4 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [ ] 3.5 Aplicar contrato OIDC/Keycloak según manifiesto y variables efectivas.
- [ ] 3.6 Aplicar contrato de integración con observabilidad según manifiesto.
- [ ] 3.7 Garantizar que FreeIPA se publica detrás de Traefik y la terminación TLS la gestiona Traefik según `tls_mode`.
- [ ] 3.8 Mantener idempotencia razonable del flujo `deployment-project` para re-ejecuciones.

## 4. Guardrails, Documentation and Testing

- [ ] 4.1 Validar variables requeridas antes de `docker compose up -d`.
- [ ] 4.2 Añadir guardrails para dependencias faltantes (`traefik-stepca`, `traefik-keycloak`, `traefik-observability`).
- [ ] 4.3 Documentar ejecución de `project=traefik-freeipa` y override TLS.
- [ ] 4.4 Añadir tests de wiring de catálogo y contrato TLS/auth/dependencias.
- [ ] 4.5 Evitar overrides ad-hoc de servicios fuera del manifiesto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-traefik-freeipa --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
