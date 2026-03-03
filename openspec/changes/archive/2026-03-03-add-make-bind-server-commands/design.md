## Context

La rama `dns-bind` ya expone targets de Make para operar BIND, pero no existe un contrato OpenSpec que los fije como interfaz operativa estable. Sin ese contrato, futuros cambios en Make/compose/documentacion pueden romper el flujo sin una referencia clara.

## Goals / Non-Goals

- Goals:
- Definir el contrato operativo de comandos Make para el ciclo de vida de BIND.
- Asegurar que esos comandos se ejecutan de forma determinista via wrapper de compose y profile `bind`.
- Dejar definido el alcance de documentacion y validacion para evitar deriva entre comando real y guias.
- Non-Goals:
- No cambiar arquitectura de DNS ni el contenido funcional de BIND.
- No introducir privilegios extra ni dependencias nuevas para el flujo base.

## Decisions

- Decision: El conjunto de comandos operativos de BIND incluye `bind-up`, `bind-down`, `bind-logs`, `bind-status` y `bind-restart`.
- Rationale: Los cuatro primeros cubren operacion minima y `bind-restart` reduce friccion operativa para cambios iterativos.

- Decision: Todos los targets BIND se ejecutan mediante el wrapper de compose compartido, manteniendo nombre de proyecto/directorio determinista.
- Rationale: Evita divergencias por CWD y reutiliza red/volumenes esperados.

- Decision: La documentacion principal debe listar comandos BIND como flujo oficial de esta rama.
- Rationale: Minimiza ambiguedad con flujos DNS legacy y mejora onboarding.

## Risks / Trade-offs

- Riesgo: `bind-restart` podria duplicar logica de `bind-down` + `bind-up`.
- Mitigacion: Implementarlo como atajo explicito que reutiliza las mismas primitivas.

- Riesgo: Documentacion desalineada respecto al Makefile.
- Mitigacion: Incluir validacion de inventario/comandos en tareas de testing/docs.

## Migration Plan

1. Actualizar deltas de `dns-bind-service`, `compose-wrapper` y `documentation`.
2. Implementar/ajustar targets Make y ayuda.
3. Actualizar docs operativas.
4. Alinear smoke checks/documentacion de test y validar.

