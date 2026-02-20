# Change: add-bind-dns-provisioning

## Summary
Agregar provisión de zonas/registros para el servicio BIND usando los mismos inputs del stack (ENDPOINTS, BASE_DOMAIN, LOOPBACK_X).

## Problem
Technitium tiene `dns-provision`, pero el nuevo servicio BIND necesita un flujo equivalente para generar la zona local sin intervención manual.

## Goals
- Proveer un script de provisión para BIND con `--dry-run`.
- Generar un zone file consistente con `ENDPOINTS` y `LOOPBACK_X`.
- Integrar el flujo con Makefile y README del servicio.

## Non-goals
- Soportar actualización dinamica via `nsupdate` o TSIG (se puede ampliar despues).
- Gestionar multiples zonas complejas o vistas avanzadas.

## Approach
- Implementar `scripts/bind-provision.sh`:
  - Lee `.env` (o `--env-file`), valida `BASE_DOMAIN`, `LOOPBACK_X`.
  - Genera `services/dns-bind/zones/db.${BASE_DOMAIN}` con A records para endpoints.
  - Incluye `bind.${BASE_DOMAIN}` apuntando a `127.0.${LOOPBACK_X}.254` (paridad con otros endpoints).
  - Soporta `--dry-run` para imprimir sin escribir.
- Añadir `make bind-provision` y `make bind-provision-dry`.
- Documentar en `services/dns-bind/README*`.

## Affected files
- `scripts/bind-provision.sh`
- `services/dns-bind/zones/`
- `Makefile`
- `services/dns-bind/README.md`
- `services/dns-bind/README.es.md`
- `services/dns-bind/README.sv.md`

## Verification
- `make bind-provision-dry` imprime un zone file con entradas para endpoints.
- `make bind-provision` escribe `db.${BASE_DOMAIN}` en el directorio de zonas.
