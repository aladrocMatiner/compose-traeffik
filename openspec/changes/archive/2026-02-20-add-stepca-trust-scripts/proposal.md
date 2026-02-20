# Change: Add Step-CA trust install/verify scripts for Ubuntu

## Why
Developers need a safe, repeatable way to trust Step-CA certificates on Ubuntu 24.04 so local TLS works without manual steps.

## What Changes
- Add scripts to install and uninstall the Step-CA root CA into the OS trust store (Ubuntu 24.04).
- Add a script to verify that OS trust is established for the Step-CA root CA.
- Add Makefile targets for install, uninstall, and verify.
- Document security boundaries for handling the CA certificate.

## Impact
- Affected specs: stepca-trust (new capability)
- Affected code: scripts/, Makefile, docs/
