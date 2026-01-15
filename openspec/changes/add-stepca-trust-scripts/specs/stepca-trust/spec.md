## ADDED Requirements
### Requirement: Install Step-CA trust on Ubuntu
The system SHALL provide a script that installs the Step-CA root CA into the Ubuntu 24.04 system trust store.

#### Scenario: Install trust from a local CA certificate
- **WHEN** a valid Step-CA root certificate is available on disk
- **THEN** the script installs it into the system trust store
- **AND THEN** the system trust store is updated successfully

#### Scenario: Install fails when CA certificate is missing
- **WHEN** the Step-CA root certificate is not available on disk
- **THEN** the script exits with a non-zero status and a clear error message

### Requirement: Uninstall Step-CA trust on Ubuntu
The system SHALL provide a script that removes the installed Step-CA root CA from the Ubuntu 24.04 system trust store.

#### Scenario: Uninstall trust
- **WHEN** the Step-CA root certificate was previously installed by the script
- **THEN** the script removes it from the system trust store
- **AND THEN** the system trust store is updated successfully

#### Scenario: Uninstall when not present
- **WHEN** the installed Step-CA root certificate is not present
- **THEN** the script exits successfully with a clear message

### Requirement: Verify Step-CA trust on Ubuntu
The system SHALL provide a script that verifies OS trust for the Step-CA root CA on Ubuntu 24.04.

#### Scenario: Trust verification succeeds
- **WHEN** the Step-CA root certificate is present in the system trust store
- **THEN** the script reports success and exits with status 0

#### Scenario: Trust verification fails
- **WHEN** the Step-CA root certificate is not present or not trusted
- **THEN** the script reports failure and exits with a non-zero status

### Requirement: Security boundary for CA trust scripts
The system SHALL restrict trust installation to public CA certificate material and SHALL NOT access private keys or secret files.

#### Scenario: CA certificate source is public
- **WHEN** the script reads the CA certificate
- **THEN** it only reads a public certificate file and never reads private key or password files
