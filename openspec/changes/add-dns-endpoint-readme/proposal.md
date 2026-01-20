# Change: Add DNS UI endpoint to README lists

## Summary
Add the DNS UI endpoint to the primary endpoint lists in the root README files so users can discover it without scanning service docs.

## Problem
The DNS UI endpoint is not surfaced in the main README endpoint lists, which makes the optional DNS service harder to discover and verify after `make up`.

## Goals
- Document the DNS UI endpoint alongside the other core endpoints.
- Keep endpoint lists accurate and consistent across README languages.

## Non-goals
- Changing runtime configuration or compose profiles.
- Adding new services or routes.

## Approach
- Update the endpoints section in `README.md`, `README.es.md`, and `README.sv.md` to include `https://dns.${BASE_DOMAIN}` with the same profile/auth notes used elsewhere.
- Keep formatting and ordering consistent with the existing lists.

## Affected files
- `README.md`
- `README.es.md`
- `README.sv.md`

## Verification
- Endpoint lists include the DNS UI entry with the correct hostname and profile note.
- The three README variants remain aligned.
