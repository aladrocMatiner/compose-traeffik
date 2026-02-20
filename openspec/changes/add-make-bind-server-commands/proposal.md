## Why

Aunque la rama `dns-bind` ya prioriza BIND, necesitamos formalizar en OpenSpec el flujo operativo de Make para lanzar y operar el servidor BIND de forma consistente, segura y fácil de usar para el equipo.

## What Changes

- Definir comandos Make de ciclo de vida para BIND como interfaz operativa principal (`bind-up`, `bind-down`, `bind-logs`, `bind-status`).
- Evaluar y especificar si se añade `bind-restart` como atajo explícito para operación diaria.
- Garantizar que los comandos usen siempre el profile/servicio correcto (`bind`) vía wrapper de compose para evitar ejecuciones ambiguas.
- Alinear ayuda y documentación de operaciones para que los comandos de BIND sean descubribles y no se mezclen con flujos DNS legacy.
- Definir criterios de validación (tests/documentación) para asegurar que los targets de Make siguen funcionando tras cambios futuros.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `dns-bind-service`: formalizar la operación del servicio BIND mediante comandos Make estándar.
- `compose-wrapper`: reforzar la invocación determinista de compose para targets de BIND.
- `documentation`: actualizar la guía operativa para reflejar comandos Make de BIND como flujo oficial.

## Impact

- Affected code (planned): `Makefile`, `scripts/compose.sh` (si aplica), documentación operativa (`README*.md`, `docs/`, `scripts/README.md`).
- Affected validation (planned): smoke checks o validaciones de documentación relacionadas con comandos BIND.
- No implementación en este cambio por ahora; solo definición de alcance y contrato de cambio.
