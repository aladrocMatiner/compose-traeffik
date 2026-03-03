## 1. OpenSpec Contract

- [ ] 1.1 Confirm `traefik-docling` as a valid project identifier in deployment catalog scope.
- [ ] 1.2 Confirm dependency and TLS baseline contract for `traefik-docling` (StepCA ACME default with explicit override support).
- [ ] 1.3 Confirm this change is deployment-only and explicitly excludes service runtime implementation.
- [ ] 1.4 Validate artifacts with `openspec validate add-project-traefik-docling --strict`.

## 2. Deployment-Side Project Definition

- [ ] 2.1 Create `deployment/projects/traefik-docling/` manifest scaffold.
- [ ] 2.2 Register `traefik-docling` in project catalog wiring for list/discovery commands.
- [ ] 2.3 Define required manifest fields (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host`).

## 3. Guardrails (No Service Yet)

- [ ] 3.1 Add deployment preflight check that detects missing Docling service/profile implementation.
- [ ] 3.2 Fail fast before `docker compose up -d` with a clear actionable message indicating deployment-side contract exists but service stack is pending.
- [ ] 3.3 Ensure no partial compose apply happens when guardrail triggers.

## 4. Documentation and Testing

- [ ] 4.1 Document project state as "deployment contract available, service not implemented".
- [ ] 4.2 Add/extend tests to validate catalog presence and fail-fast behavior.
- [ ] 4.3 Document expected transition path from deployment-only to full project/service implementation.

## 5. Validation and Handoff

- [ ] 5.1 Re-run `openspec validate add-project-traefik-docling --strict`.
- [ ] 5.2 Verify proposal/tasks/spec delta remain consistent on deployment-only scope.
