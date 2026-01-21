# Change: split-dns-docs-bind-technitium

## Summary
Separar la documentacion de DNS en dos guias distintas: Technitium (actual) y BIND (nuevo), evitando la confusion del nombre "service-dns-bind".

## Problem
La guia `docs/06-howto/service-dns-bind.md` describe Technitium pero su titulo y path sugieren BIND. Con la adicion de un servicio BIND real, esto genera ambiguedad y enlaces confusos.

## Goals
- Renombrar la guia actual a `service-dns-technitium.md`.
- Crear una guia nueva `service-dns-bind.md` para el servicio BIND.
- Actualizar indices y enlaces para evitar referencias rotas.

## Non-goals
- Cambios de runtime o compose.
- Modificar el contenido de los READMEs de servicios (se hace en otros changes).

## Approach
- Mover/renombrar `docs/06-howto/service-dns-bind.md` a `docs/06-howto/service-dns-technitium.md` y ajustar el titulo.
- Crear una nueva guia `docs/06-howto/service-dns-bind.md` con estructura estandar (Purpose, Prerequisites, Steps, Expected Result, Verification, Pitfalls, Security).
- Actualizar referencias en `docs/README.md`, `docs/00-index.md` y `README.md` para apuntar a los nuevos paths.
- Ejecutar `make docs-check` como verificacion de enlaces (manual en apply).

## Affected files
- `docs/06-howto/service-dns-bind.md` (nuevo)
- `docs/06-howto/service-dns-technitium.md` (renombrado)
- `docs/README.md`
- `docs/00-index.md`
- `README.md`

## Verification
- Los indices apuntan a `service-dns-technitium.md` y `service-dns-bind.md`.
- `docs/06-howto/service-dns-bind.md` describe BIND y no Technitium.
- No quedan referencias al path antiguo.
