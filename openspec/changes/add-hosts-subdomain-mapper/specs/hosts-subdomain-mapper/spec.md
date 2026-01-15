## ADDED Requirements
### Requirement: Generate hosts block from endpoints
The system SHALL generate a deterministic hosts block mapping endpoints to loopback IPs using BASE_DOMAIN and LOOPBACK_X.

#### Scenario: ENDPOINTS provided
- **WHEN** ENDPOINTS is set to a comma-separated list
- **THEN** the generated block preserves the listed order and assigns IPs as 127.0.<LOOPBACK_X>.<y> for y=1..N

#### Scenario: ENDPOINTS not provided
- **WHEN** ENDPOINTS is unset and Traefik router Host() labels exist in docker-compose.yml
- **THEN** the system extracts endpoints from those labels and assigns IPs in alphabetical order

#### Scenario: No endpoints discovered
- **WHEN** ENDPOINTS is unset and no Host() labels are found
- **THEN** the system fails with guidance to set ENDPOINTS

### Requirement: Manage hosts file block safely
The system SHALL insert, update, and remove a clearly marked block in the hosts file without duplicates and with dry-run support.

#### Scenario: Apply block idempotently
- **WHEN** apply is executed against a hosts file
- **THEN** a single managed block exists with no duplicate entries

#### Scenario: Remove block cleanly
- **WHEN** remove is executed against a hosts file containing the managed block
- **THEN** the block is deleted and other entries remain unchanged

#### Scenario: Dry-run behavior
- **WHEN** apply or remove is executed with --dry-run
- **THEN** the system prints intended changes without modifying the hosts file

### Requirement: Provide CLI interface and environment resolution
The system SHALL expose generate/apply/remove/status subcommands and resolve configuration from --env-file, ENV_FILE, .env, or .env.example.

#### Scenario: Explicit env file
- **WHEN** --env-file is provided
- **THEN** the system uses that file for BASE_DOMAIN, LOOPBACK_X, and ENDPOINTS

#### Scenario: Status reporting
- **WHEN** status is executed
- **THEN** the system reports whether the managed block exists and lists its entries
