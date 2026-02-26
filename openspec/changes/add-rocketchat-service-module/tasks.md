## 1. OpenSpec Alignment

- [x] 1.1 Add proposal, design, tasks, and spec deltas for the Rocket.Chat service module.
- [x] 1.2 Validate change artifacts with `openspec validate add-rocketchat-service-module --strict`.

## 2. Rocket.Chat Service Module

- [x] 2.1 Add `services/rocketchat/compose.yml` with Traefik routing, MongoDB replica set bootstrap, and NATS under profile `rocketchat`.
- [x] 2.2 Add Rocket.Chat bootstrap/render scripts that generate runtime env/config artifacts and a Keycloak setup checklist.
- [x] 2.3 Add Rocket.Chat multilingual service docs (`services/rocketchat/README*.md`).

## 3. Repo Integration

- [x] 3.1 Add Rocket.Chat env vars to `.env.example` and ignore rendered artifacts in `.gitignore`.
- [x] 3.2 Wire Rocket.Chat compose file into `scripts/compose.sh` and lifecycle/test targets into `Makefile`.
- [x] 3.3 Extend `scripts/validate-env.sh` with Rocket.Chat profile guardrails and optional Keycloak/observability validation.
- [x] 3.4 Update root multilingual READMEs and `docs.manifest.json` with Rocket.Chat links/endpoints/operations notes.
- [x] 3.5 Update `scripts/README.md` and `tests/README.md` inventories and examples.

## 4. Testing

- [x] 4.1 Add Rocket.Chat static smoke tests for Make target wiring, render/config wiring, and guardrails.
- [x] 4.2 Run Rocket.Chat smoke tests (`make test-rocketchat`).
- [x] 4.3 Run docs validation (`make docs-check`).
- [x] 4.4 Run compose config validation for the Rocket.Chat profile.

## 5. Review and Handoff

- [x] 5.1 Do a final self-review pass for gaps (docs/tests/guardrails drift).
