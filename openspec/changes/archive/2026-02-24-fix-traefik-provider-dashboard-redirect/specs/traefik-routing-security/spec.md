## ADDED Requirements
### Requirement: Docker provider routing
The system SHALL enable the Traefik docker provider with `exposedByDefault=false` and a proxy network configuration so docker label routers are loaded safely.

#### Scenario: Docker label routing
- **WHEN** Traefik starts with the docker provider enabled
- **THEN** services with `traefik.enable=true` labels route through the proxy network

### Requirement: Secure dashboard exposure
The system SHALL not expose the Traefik dashboard on host port 8080 by default and SHALL only allow dashboard access via HTTPS with authentication or keep it disabled.

#### Scenario: Dashboard access
- **WHEN** the stack starts with default settings
- **THEN** the dashboard is not available on `http://<host>:8080` and is only reachable via HTTPS + auth if enabled

### Requirement: Redirect toggle wiring
The system SHALL make the HTTP-to-HTTPS redirect toggle control routing behavior using an environment-driven middleware selection.

#### Scenario: Redirect disabled
- **WHEN** the redirect toggle is disabled
- **THEN** HTTP requests are not redirected to HTTPS

#### Scenario: Redirect enabled
- **WHEN** the redirect toggle is enabled
- **THEN** HTTP requests are redirected to HTTPS
