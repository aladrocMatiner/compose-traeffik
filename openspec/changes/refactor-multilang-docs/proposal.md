# Change: Refactor documentation into multilingual README system

## Why
Documentation is currently spread across README and docs pages with a single language. A consistent multilingual README system with language selectors and validation will improve accessibility while preventing drift.

## Discovery Summary
- **Services found**: traefik, whoami, certbot, step-ca, dns (from `services/*/compose.yml`).
- **Current doc files**: `README.md`, `docs/README.md`, `docs/00-index.md`, `docs/90-facts.md`, `docs/98-doc-qa.md`, `docs/99-style-guide.md`, `docs/99-glossary.md`, `docs/05-tls/*`, `docs/06-howto/*`, `docs/migration/refactor-services-layout.md`, `services/*/README.md`, `tests/README.md`.
- **Existing doc languages**: English only.
- **Make targets referenced in docs**: `make up`, `make down`, `make logs`, `make test`, `make certs-local`, `make certs-le-issue`, `make certs-le-renew`, `make stepca-bootstrap`, `make stepca-trust-*`, `make hosts-*`, `make dns-*`.
- **Env vars referenced in docs**: `DEV_DOMAIN`, `BASE_DOMAIN`, `PROJECT_NAME`, `LOOPBACK_X`, `ENDPOINTS`.
- **Note**: `docker-compose.yml` is no longer present; compose is layered via `compose/base.yml` and `services/*/compose.yml`.

## What Changes
- Introduce EN/SV/ES root READMEs with a language selector and aligned section structure.
- Add EN/SV/ES service READMEs under each `services/<service>/` directory with consistent anchors and structure.
- Add a manifest and validation script to enforce parity, links, and selector correctness.
- Update docs cross-links to be language-aware and non-orphaned.

## Impact
- Affected specs: docs-multilang
- Affected code/docs: root README files, `services/*/README*`, `docs/` content migration, new manifest, new docs validation script, Makefile targets.
