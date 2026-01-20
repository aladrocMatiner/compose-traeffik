## 1. Implementation
- [ ] 1.1 Update `.env.example` (and any bootstrap copies) so that Traefik dashboard and the optional profiles (`dns`, `le`, `stepca`) are enabled by default and point to real auth assets.
- [ ] 1.2 Teach `scripts/env-generate.sh` (and `make bootstrap`) to populate the required htpasswd files, secrets, and profile lists so `validate-env.sh` passes without manual edits.
- [ ] 1.3 Update the README/docs to describe the new default experience and any trust steps needed for the built-in auth assets.
- [ ] 1.4 Adjust any smoke-test/setup docs to reflect the new default services.

## 2. Verification
- [ ] 2.1 `make bootstrap` should produce an `.env` that enables the dashboard, optional profiles, and references the newly provisioned auth files.
- [ ] 2.2 `make up`/`make test` should pass with the default configuration without additional env overrides.
