## ADDED Requirements

### Requirement: Project `traefik-dns-bind` deploys BIND with Traefik edge services
The system SHALL provide a predefined project `traefik-dns-bind` that deploys the BIND DNS service together with Traefik edge services via the project workflow.

#### Scenario: Operator selects `project=traefik-dns-bind`
- **WHEN** an operator runs `make deployment-project project=traefik-dns-bind`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared services for Traefik and BIND

### Requirement: Project `traefik-dns-bind` enforces DNS and HTTP(S) traffic boundary
The system SHALL keep DNS traffic served by BIND on UDP/TCP 53 and SHALL use Traefik only for HTTP(S) project routes when present.

#### Scenario: DNS traffic path is evaluated
- **WHEN** the `traefik-dns-bind` project is deployed
- **THEN** DNS service exposure remains bound to BIND DNS ports
- **AND** Traefik is not used as a DNS protocol proxy path

### Requirement: Project `traefik-dns-bind` uses OpenSpec TLS mode for Traefik HTTPS routes
The system SHALL apply OpenSpec TLS mode through Traefik for HTTPS routes in `traefik-dns-bind`, defaulting to `stepca-acme` unless explicitly overridden with a supported mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-dns-bind` is run without TLS override
- **THEN** Traefik certificate handling for project HTTPS routes uses `stepca-acme`
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides a supported `tls_mode` override
- **THEN** Traefik uses the requested TLS mode for project HTTPS routes
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-dns-bind` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-dns-bind` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
