## Why

Hoy no existe una forma directa de consultar por comando qué selectores de `os` y `target` se consideran soportados en el flujo `make deployment-*`. El operador tiene que inspeccionar `Makefile`, ayuda y documentación, lo que puede generar confusión y drift entre UX y realidad operativa.

## What Changes

- Añadir `make deployment-list-os` para listar los selectores de OS soportados en el flujo de deployment.
- Añadir `make deployment-list-targets` para listar los selectores de target soportados para el flujo de deployment.
- Definir salida estable y script-friendly (una entrada por línea, orden fijo, salida 0).
- Fijar explícitamente el alcance inicial de `deployment-list-targets`: **solo `qemu`** en esta fase.
- Actualizar ayuda/documentación y añadir smoke tests estáticos para evitar drift.

## Capabilities

### New Capabilities

- `deployment-cli`: descubrimiento de selectores soportados para comandos `make deployment-*`.

### Modified Capabilities

- None.

## Impact

- Affected code (planned): `Makefile`, documentación de scripts/tests y smoke tests de deployment.
- Operator UX: mejora de discoverability sin necesidad de leer internals.
- Scope note: este cambio no elimina rutas internas existentes; solo define y expone la lista soportada por los nuevos comandos de discovery.
