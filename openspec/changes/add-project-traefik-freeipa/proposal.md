## Why

Necesitamos integrar FreeIPA en este repositorio siguiendo el patron real de `services/*` (no existe `deployment-project` en `master`).

El objetivo es disponer de un modulo `freeipa` detras de Traefik con contratos explicitos para TLS mode, autenticacion Keycloak y observabilidad, mas wiring operativo (`make` + smoke tests + docs).

## What Changes

- Añadir modulo `services/freeipa/compose.yml` con perfil `freeipa`.
- Añadir bootstrap de secretos con `scripts/freeipa-bootstrap.sh` y target `make freeipa-bootstrap`.
- Añadir targets operativos `freeipa-up/down/restart/logs/status` y `test-freeipa`.
- Extender preflight `scripts/validate-env.sh` para guardrails de FreeIPA:
  - secretos core obligatorios
  - `FREEIPA_TLS_MODE` soportado (`local-ca`, `letsencrypt`, `stepca-acme`)
  - contrato Keycloak cuando `FREEIPA_KEYCLOAK_ENABLED=true`
  - contrato de observabilidad cuando `FREEIPA_OBSERVABILITY_ENABLED=true`
- Añadir smoke tests de servicio/wiring/bootstrap/guardrails/integraciones opcionales.
- Actualizar documentacion (`README*`, `services/freeipa/README*`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`, `.env.example`).

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `services-layout`: agrega el modulo `freeipa` dentro de `services/`.
- `guardrails`: agrega validacion profile-gated para contrato FreeIPA.
- `tests-suite`: agrega inventario y ejecucion de smoke tests del modulo FreeIPA.

## Impact

- Affected code:
  - `services/freeipa/*`
  - `scripts/freeipa-bootstrap.sh`
  - `scripts/validate-env.sh`
  - `scripts/healthcheck.sh`
  - `Makefile`
  - `tests/smoke/test_freeipa_*.sh`
  - `.env.example`
  - `README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`
- Operacion: nuevo modulo identity-management desplegable tras Traefik via perfil `freeipa`.
- Riesgo: contratos incompletos de TLS/Keycloak/observabilidad; mitigado con guardrails fail-fast y smoke tests especificos.
