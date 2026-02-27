## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `depends_on_projects` como campo soportado de manifiesto de proyecto.
- [ ] 1.2 Confirmar preflight obligatorio de dependencias en `deployment-project`.
- [ ] 1.3 Validar artefactos del cambio con `openspec validate add-project-dependency-guardrails --strict`.

## 2. Manifest Schema and Validation

- [ ] 2.1 Extender esquema de manifiesto para incluir `depends_on_projects` (lista opcional de `project-id`).
- [ ] 2.2 Validar tipo/forma de `depends_on_projects` y rechazar entradas inválidas.
- [ ] 2.3 Definir comportamiento por defecto cuando no hay dependencias declaradas.

## 3. Dependency Preflight

- [ ] 3.1 Implementar preflight que evalúe dependencias declaradas antes del despliegue de proyecto.
- [ ] 3.2 Fallar temprano si falta una dependencia con mensaje que liste proyectos faltantes.
- [ ] 3.3 Incluir guía de recuperación (`deploy` de dependencias y `retry` del proyecto objetivo).

## 4. Documentation and Testing

- [ ] 4.1 Documentar campo `depends_on_projects` y su semántica.
- [ ] 4.2 Añadir smoke tests para dependencias faltantes y dependencias satisfechas.
- [ ] 4.3 Asegurar que tests de contrato no dependan de credenciales ni estado remoto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-dependency-guardrails --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
