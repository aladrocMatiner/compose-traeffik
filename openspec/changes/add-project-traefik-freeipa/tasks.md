## 1. OpenSpec Contract

- [x] 1.1 Confirmar que el alcance se adapta al patron `services/*` existente en `master`.
- [x] 1.2 Confirmar contrato TLS mode para FreeIPA (`local-ca`, `letsencrypt`, `stepca-acme`).
- [x] 1.3 Confirmar contrato Keycloak opcional para FreeIPA.
- [x] 1.4 Confirmar contrato de observabilidad opcional para FreeIPA.

## 2. Service Module Implementation

- [x] 2.1 Crear `services/freeipa/compose.yml` con perfil `freeipa` y routing Traefik.
- [x] 2.2 Crear `scripts/freeipa-bootstrap.sh` para defaults + secretos idempotentes.
- [x] 2.3 Integrar modulo en `Makefile` (`COMPOSE_FILES`, lifecycle targets, `test-freeipa`).

## 3. Guardrails and Runtime Contracts

- [x] 3.1 Extender `scripts/validate-env.sh` con guardrails FreeIPA profile-gated.
- [x] 3.2 Validar contrato TLS mode y resolver esperado por modo.
- [x] 3.3 Validar contrato Keycloak cuando esta habilitado.
- [x] 3.4 Validar contrato observabilidad cuando esta habilitado.

## 4. Tests and Documentation

- [x] 4.1 Añadir smoke tests de FreeIPA (service config, make targets, bootstrap, guardrails, optional integrations).
- [x] 4.2 Integrar suite FreeIPA en `scripts/healthcheck.sh` y `tests/README.md`.
- [x] 4.3 Actualizar `.env.example`, READMEs y `docs.manifest.json`.

## 5. Validation and Handoff

- [x] 5.1 Ejecutar `make test-freeipa`.
- [x] 5.2 Ejecutar `make docs-check`.
- [x] 5.3 Ejecutar `openspec validate add-project-traefik-freeipa --strict`.
- [x] 5.4 Revisar coherencia final entre proposal, tasks y spec deltas.
