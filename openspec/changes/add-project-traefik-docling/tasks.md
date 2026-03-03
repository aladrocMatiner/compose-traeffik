## 1. OpenSpec Contract

- [x] 1.1 Confirm `traefik-docling` as a valid project identifier in deployment catalog scope.
- [x] 1.2 Confirm dependency and TLS baseline contract for `traefik-docling` (StepCA ACME default with explicit override support).
- [x] 1.3 Confirm this change is deployment-only and explicitly excludes service runtime implementation.
- [x] 1.4 Validate artifacts with `openspec validate add-project-traefik-docling --strict`.

## 2. Deployment-Side Project Definition

- [x] 2.1 Create `deployment/projects/traefik-docling/` manifest scaffold.
- [x] 2.2 Register `traefik-docling` in project catalog wiring for list/discovery commands.
- [x] 2.3 Define required manifest fields (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host`).

## 3. Guardrails (No Service Yet)

- [x] 3.1 Add deployment preflight check that detects missing Docling service/profile implementation.
- [x] 3.2 Fail fast before `docker compose up -d` with a clear actionable message indicating deployment-side contract exists but service stack is pending.
- [x] 3.3 Ensure no partial compose apply happens when guardrail triggers.

## 4. Documentation and Testing

- [x] 4.1 Document project state as "deployment contract available, service not implemented".
- [x] 4.2 Add/extend tests to validate catalog presence and fail-fast behavior.
- [x] 4.3 Document expected transition path from deployment-only to full project/service implementation.

## 5. Validation and Handoff

- [x] 5.1 Re-run `openspec validate add-project-traefik-docling --strict`.
- [x] 5.2 Verify proposal/tasks/spec delta remain consistent on deployment-only scope.
