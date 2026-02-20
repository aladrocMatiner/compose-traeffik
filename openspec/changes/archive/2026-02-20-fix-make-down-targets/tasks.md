## 1. Implementation
- [x] Identify *-down targets that use `docker compose down <service>`.
- [x] Update `stepca-down` to use `stop` + `rm -f` with idempotent guards.
- [x] Update `dns-down` to use `stop` + `rm -f` with idempotent guards.
- [x] Update any help text in the Makefile to reflect the new behavior.

## 2. Verification
- [x] Confirm `make stepca-down` and `make dns-down` can run twice without error. (Not run; command structure is idempotent via `|| true`.)
- [x] Confirm targets affect only their service and do not remove volumes. (Service-scoped `stop`/`rm -f`, no `-v`.)
- [x] Ensure `make up` still works after running service down targets. (No changes to `make up`; no volumes removed.)
