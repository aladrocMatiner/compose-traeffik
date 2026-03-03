## Why

We need `traefik-docling` to be part of the deployment project system now, even though the Docling service stack is not implemented yet. Locking the deployment contract early avoids ad-hoc behavior and keeps future implementation aligned with the existing project deployment model.

## What Changes

- Add a new deployment project change scope for `traefik-docling` in the project catalog contract.
- Define deployment-side contract for manifest structure and project wiring (project id, dependency, TLS default, host contract).
- Define an explicit pre-compose guardrail: project deployment MUST fail fast with a clear "service not implemented" message while Docling compose service/profile is missing.
- Keep service implementation, compose service files, and Docling runtime configuration out of scope for this change.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: add `traefik-docling` as a deployment-managed project contract in "deployment-only" state.

## Impact

- Affected code (planned): `deployment/projects/traefik-docling/*`, `deployment/projects/catalog.json`, deployment docs/tests and guardrails.
- Operational impact: operators can discover `traefik-docling` in the catalog and get deterministic behavior before service implementation.
- Risk: confusion about partial availability; mitigated by explicit fail-fast message and documentation marking service as pending.
