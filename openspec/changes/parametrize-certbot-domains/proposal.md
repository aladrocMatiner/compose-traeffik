# Change: Parametrize Certbot Domain List

## Summary
Make Certbot issuance/renewal domain lists configurable so new subdomains don’t require script edits.

## Problem
Certbot scripts currently hardcode domain arguments, so adding/removing subdomains requires editing scripts and risks drift from `.env`.

## Goals
- Allow domain lists for Certbot to be driven by configuration (e.g., `.env`).
- Keep default behavior compatible with the current stack.

## Non-goals
- No change to the ACME flow (still HTTP‑01 with `--webroot`).
- No refactor beyond the domain list handling.

## Approach
- Introduce a single env var (e.g., `CERTBOT_DOMAINS`) or derive from existing config.
- Use the configured list to build `-d` arguments in `scripts/certbot-issue.sh`.
- Keep `certbot-renew.sh` unchanged or document renewal behavior.

## Affected files
- `scripts/certbot-issue.sh`
- `.env.example` (if adding a new variable)
- `docs/tls-mode-b-letsencrypt-certbot.md`
- `docs/05-tls/mode-b-letsencrypt-certbot.md`

## Verification
- Certbot issuance uses the configured domain list without manual script edits.
- Docs explain how to set the domain list.
