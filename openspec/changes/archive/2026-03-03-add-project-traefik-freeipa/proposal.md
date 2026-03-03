## Why

We need `traefik-freeipa` to exist in the deployment project system now, even though the FreeIPA service stack is not implemented yet. This lets us lock the project contract early (ID, dependencies, TLS defaults, and guardrails) and avoid ad-hoc behavior when service implementation starts.

## What Changes

- Add a new deployment project change scope for `traefik-freeipa` in the catalog contract.
- Define deployment-side contract for manifest structure and project wiring (project id, dependency, TLS default, host contract).
- Define an explicit pre-compose guardrail: project deployment MUST fail fast with a clear "service not implemented" error while FreeIPA compose service/profile is missing.
- Keep service implementation, compose service files, and FreeIPA runtime configuration out of scope for this change.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: add `traefik-freeipa` as a deployment-managed project contract in "deployment-only" state.

## Impact

- Affected code (planned): `deployment/projects/traefik-freeipa/*`, `deployment/projects/catalog.json`, deployment docs/tests and guardrails.
- Operational impact: operators can discover `traefik-freeipa` in catalog and get deterministic behavior before service implementation.
- Risk: confusion about partial availability; mitigated by explicit fail-fast message and documentation marking service as pending.
