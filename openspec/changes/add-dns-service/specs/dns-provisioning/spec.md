## ADDED Requirements
### Requirement: Deterministic DNS record provisioning
The system SHALL provision A records for each endpoint in a hosted zone based on deterministic loopback IP assignments.

#### Scenario: ENDPOINTS provided
- **WHEN** ENDPOINTS is set to a comma-separated list
- **THEN** records are created in the listed order at `127.0.<LOOPBACK_X>.<y>` for `y=1..N`

#### Scenario: ENDPOINTS derived
- **WHEN** ENDPOINTS is unset and Traefik Host() rules exist in docker-compose.yml
- **THEN** endpoints are derived from those rules and sorted alphabetically before assignment

#### Scenario: DNS UI hostname reserved IP
- **WHEN** provisioning runs
- **THEN** an A record for `dns.<BASE_DOMAIN>` is created at reserved `127.0.<LOOPBACK_X>.254`

#### Scenario: Missing endpoints
- **WHEN** ENDPOINTS is unset and no Host() rules are found
- **THEN** provisioning fails with instructions to set ENDPOINTS
