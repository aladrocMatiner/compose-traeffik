# Change: Add hosts subdomain mapper script and Makefile targets

## Why
Managing local hostnames for the Traefik edge stack is currently manual and error-prone. A dedicated script and Makefile targets will standardize loopback subdomain mapping, keep /etc/hosts changes safe and idempotent, and document the workflow.

## What Changes
- Add a hosts subdomain mapper script with generate/apply/remove/status subcommands and dry-run support.
- Add Makefile targets to invoke the script with repo conventions and help output updates.
- Extend .env.example with BASE_DOMAIN, LOOPBACK_X, ENDPOINTS, and optional HOSTS_FILE/ENV_FILE.
- Document usage and verification steps in README or docs.
- Add a no-sudo test that uses a temporary hosts file to validate apply/remove behavior.

## Impact
- Affected specs: hosts-subdomain-mapper
- Affected code: scripts/hosts-subdomains.sh, Makefile, .env.example, README.md or docs, tests
