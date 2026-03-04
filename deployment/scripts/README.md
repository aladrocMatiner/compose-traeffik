# Deployment Scripts

This directory contains scripts used by the `make deployment-*` workflow.

- `infra-provision.sh`
- `infra-validate.sh`
- `deployment-access.sh`
- `deployment-project.sh`
- `host-wait-ssh.sh`
- `host-bootstrap.sh`
- `host-bootstrap-check.sh`

`Makefile` resolves them through `DEPLOYMENT_SCRIPTS_DIR`.

Project orchestration entrypoints:

- `make deployment-project-list` -> `deployment-project.sh list`
- `make deployment-project project=<id> [target=<qemu>] [os=<ubuntu|ubuntu20.04|ubuntu22.04|ubuntu24.04>] [tls_mode=<stepca-acme|letsencrypt-acme>]`

Manifest dependency guardrails (`depends_on_projects`):

- `depends_on_projects` is an optional manifest array of required `project-id` values.
- `make deployment-project` enforces a dependency preflight before `system_bootstrap` and `project_deploy`.
- Missing dependencies fail early using local registry state (`deployment/state/projects.json`) with explicit recovery guidance:
  - deploy required dependencies first
  - retry target project deployment
- If dependencies are satisfied (or none are declared), deployment continues with baseline stages.

Current catalog projects:

- `traefik-stepca`
- `traefik-keycloak`
- `traefik-observability`
- `traefik-wikijs`
- `traefik-semaphoreui`
- `traefik-rocketchat`
- `traefik-gitlab`
- `traefik-dns-bind`
- `traefik-litellm`
- `traefik-docling`
- `traefik-webui`
- `traefik-awx`

`traefik-observability` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- requires `KEYCLOAK_FORWARDAUTH_ADDRESS` to wire Keycloak-based forward auth for Grafana

`traefik-wikijs` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for Wiki.js (`realm=local.test`, `client_id=wikijs`) during deployment

`traefik-semaphoreui` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for Semaphore UI (`realm=local.test`, `client_id=semaphoreui`) during deployment

`traefik-rocketchat` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for Rocket.Chat (`realm=local.test`, `client_id=rocketchat`) during deployment

`traefik-gitlab` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for GitLab (`realm=local.test`, `client_id=gitlab`) during deployment

`traefik-litellm` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for LiteLLM (`realm=local.test`, `client_id=litellm`) during deployment
- defaults to OpenAI-compatible inference backend `http://10.64.70.81:11434/v1` and model `openai/gpt-oss:20b` (override with `OPENAI_API_BASE` / `LITELLM_MODEL`)
- configures Keycloak role mapping (`realm_access.roles`) and assigns realm role `litellm_proxy_admin` to bootstrap user so SSO user becomes LiteLLM `proxy_admin`

`traefik-docling` contract highlights:

- deployable project id is already registered in catalog and manifest wiring
- defaults to `tls_mode=stepca-acme` and depends on `traefik-stepca`
- current state is deployment-only: runner fails before compose apply with an explicit "service runtime implementation is pending" guardrail
- transition path is explicit in guardrail output (`services/docling/compose.yml` + `docling` profile implementation)

`traefik-webui` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca`
- deploys `openwebui` behind Traefik on `https://openwebui.<BASE_DOMAIN>`

`traefik-awx` contract highlights:

- default contract requires StepCA + Keycloak dependencies (`traefik-stepca`, `traefik-keycloak`)
- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- current state is deployment-only for `deployment-project`: runner fails before compose apply with an explicit hybrid-runtime pending guardrail
- transition path is explicit in guardrail output (`k3d + AWX operator` workflow integration in `deployment-project`)

Keycloak bootstrap + OIDC operational contract:

- Deploying `project=traefik-keycloak` bootstraps shared realm and initial user idempotently:
  - realm default: `local.test`
  - username default: `jose.romero`
  - password default: `abcd123`
- Bootstrap defaults can be overridden at deploy time:
  - `KEYCLOAK_BOOTSTRAP_REALM`
  - `KEYCLOAK_BOOTSTRAP_USERNAME`
  - `KEYCLOAK_BOOTSTRAP_PASSWORD`
- Example override:
  - `KEYCLOAK_BOOTSTRAP_PASSWORD='new-pass' make deployment-project project=traefik-keycloak target=qemu os=ubuntu`
- OIDC-enabled projects provision their own Keycloak client during deployment (create when missing, update when existing).
- OIDC clients are provisioned on demand only for deployed projects; clients are not globally pre-seeded.
- Project manifests own OIDC client contract values under `oidc`:
  - `enabled`, `realm`, `client_id`, optional `redirect_uris`, optional `web_origins`
- After `project=traefik-keycloak` succeeds, the runner auto-reconciles already deployed OIDC dependents (projects that declare `depends_on_projects` containing `traefik-keycloak` and `oidc.enabled=true`) based on local registry state (`deployment/state/projects.json`).
- Auto-reconciliation is enabled by default and can be disabled with:
  - `DEPLOYMENT_PROJECT_AUTO_RECONCILE_KEYCLOAK_DEPENDENTS=false`
- After `project=traefik-stepca` succeeds, the runner auto-reconciles deployed StepCA/TLS dependents that declare:
  - `depends_on_projects` including `traefik-stepca`
  - `tls_mode=stepca-acme`
  - `traefik` in manifest services
- StepCA dependent auto-reconcile defaults to running VMs only in local `qemu/libvirt` demo flow.
- StepCA dependent auto-reconcile defaults to exclude `traefik-docling` for the current demo.
- StepCA auto-reconcile toggles:
  - `DEPLOYMENT_PROJECT_AUTO_RECONCILE_STEPCA_DEPENDENTS=false`
  - `DEPLOYMENT_PROJECT_STEPCA_RECONCILE_RUNNING_ONLY=false`
  - `DEPLOYMENT_PROJECT_STEPCA_RECONCILE_EXCLUDE=traefik-docling,another-project`

Hostname contract for web projects:

- Default public host: `<project-id>.<BASE_DOMAIN>`
- Optional manifest override: `public_host`

Terraform state isolation:

- `deployment-project` uses one tfstate per VM/project under `infra/terraform/state/<target>/<vm-name>.tfstate`.
- This allows running multiple project VMs in parallel (for example: stepca + keycloak + observability).
