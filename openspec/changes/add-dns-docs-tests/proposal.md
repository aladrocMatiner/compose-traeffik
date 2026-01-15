# Change: Add DNS documentation index and DNS service verification tests

## Why
The DNS service work needs structured documentation under `docs/` and additional verification tests focused on the DNS service. This improves discoverability and ensures the DNS service configuration is validated consistently.

## What Changes
- Add `docs/README.md` as a documentation index.
- Add `docs/06-howto/service-dns-bind.md` with full DNS service documentation (setup, provisioning, Ubuntu split-DNS, security, verification).
- Wire the new docs into the existing docs index and facts as needed.
- Add DNS service verification tests (no sudo) covering compose config and Traefik exposure expectations.
- Update test documentation to describe the new DNS-focused tests.

## Impact
- Affected specs: dns-docs-tests
- Affected code/docs: docs/README.md, docs/06-howto/service-dns-bind.md, docs/00-index.md, docs/90-facts.md, tests/*, tests/README.md
