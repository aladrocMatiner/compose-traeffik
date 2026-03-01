## 1. OpenSpec Contract

- [x] 1.1 Confirmar `depends_on_projects` como campo soportado de manifiesto de proyecto.
- [x] 1.2 Confirmar preflight obligatorio de dependencias en `deployment-project`.
- [x] 1.3 Validar artefactos del cambio con `openspec validate add-project-dependency-guardrails --strict`.

## 2. Manifest Schema and Validation

- [x] 2.1 Extender esquema de manifiesto para incluir `depends_on_projects` (lista opcional de `project-id`).
- [x] 2.2 Validar tipo/forma de `depends_on_projects` y rechazar entradas inválidas.
- [x] 2.3 Definir comportamiento por defecto cuando no hay dependencias declaradas.

## 3. Dependency Preflight

- [x] 3.1 Implementar preflight que evalúe dependencias declaradas antes del despliegue de proyecto.
- [x] 3.2 Fallar temprano si falta una dependencia con mensaje que liste proyectos faltantes.
- [x] 3.3 Incluir guía de recuperación (`deploy` de dependencias y `retry` del proyecto objetivo).

## 4. Documentation and Testing

- [x] 4.1 Documentar campo `depends_on_projects` y su semántica.
- [x] 4.2 Añadir smoke tests para dependencias faltantes y dependencias satisfechas.
- [x] 4.3 Asegurar que tests de contrato no dependan de credenciales ni estado remoto.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-dependency-guardrails --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
