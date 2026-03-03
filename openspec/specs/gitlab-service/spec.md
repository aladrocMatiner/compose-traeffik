# gitlab-service Specification

## Purpose
TBD - created by archiving change add-gitlab-service-module. Update Purpose after archive.
## Requirements
### Requirement: Optional GitLab service module behind Traefik
The system SHALL provide an optional `gitlab` service module under `services/gitlab/` that deploys GitLab Omnibus using Docker Compose and exposes the GitLab web UI/API through Traefik over TLS.

#### Scenario: GitLab profile enabled
- **WHEN** a user enables the `gitlab` profile and runs the standard service lifecycle target
- **THEN** Docker Compose starts the GitLab service with persistent storage
- **AND** Traefik routes `https://<gitlab-host>.<dev-domain>` to the GitLab web service
- **AND** GitLab web traffic uses the repository TLS pattern rather than direct container TLS configuration

### Requirement: Git SSH host port exposure is configurable and documented
The system SHALL expose Git SSH access on a configurable host port and document the resulting clone URL behavior.

#### Scenario: Custom SSH host port
- **WHEN** a user sets a non-default `GITLAB_SSH_HOST_PORT` in `.env`
- **THEN** the compose configuration publishes that host port to the GitLab SSH service
- **AND** documentation and runtime validation guidance reference the configured SSH clone port

### Requirement: Omnibus configuration is rendered from repo-managed templates
The system SHALL generate GitLab Omnibus configuration from repository-managed templates/scripts so that optional proxy, OIDC, and observability-related settings can be toggled from `.env` without hand-editing container internals.

#### Scenario: Bootstrap renders config
- **WHEN** a user runs `make gitlab-bootstrap`
- **THEN** the system renders a GitLab Omnibus configuration file or fragment from `.env`
- **AND** the generated configuration is mounted into the GitLab container by compose
- **AND** the process is idempotent unless a documented force/rotation path is used

### Requirement: Keycloak OIDC integration is optional and disabled by default
The system SHALL support an optional GitLab OIDC configuration compatible with Keycloak and SHALL keep local login behavior unchanged when OIDC is disabled.

#### Scenario: OIDC disabled
- **WHEN** `GITLAB_OIDC_ENABLED` is false or unset
- **THEN** the rendered GitLab configuration omits the OIDC provider block
- **AND** GitLab starts without requiring Keycloak connectivity

#### Scenario: OIDC enabled
- **WHEN** `GITLAB_OIDC_ENABLED=true` and required OIDC variables are configured
- **THEN** the rendered GitLab configuration includes a valid OpenID Connect provider definition for Keycloak
- **AND** the callback URL uses the GitLab public hostname over HTTPS

### Requirement: Observability integration is optional and secure by default
The system SHALL include optional observability hooks for GitLab (logs/health/labels and documented metrics integration points) without exposing telemetry endpoints publicly by default.

#### Scenario: Observability disabled
- **WHEN** observability integration is not enabled for GitLab
- **THEN** the service remains deployable without a Prometheus/Grafana/Loki stack
- **AND** no additional telemetry routes are published

#### Scenario: Observability enabled
- **WHEN** observability integration is enabled for GitLab
- **THEN** the module provides documented labels/configuration hooks for collectors and scrapers
- **AND** telemetry endpoints remain internal-only unless a user explicitly opts into public exposure in a documented override path

