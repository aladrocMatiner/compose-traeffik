1. Title: Identify compose files with deprecated version key
   Files: `compose/base.yml`, `services/*/compose.yml`
   Acceptance: All files containing `version:` are listed.

2. Title: Remove version key from compose fragments
   Files: `compose/base.yml`, `services/traefik/compose.yml`, `services/whoami/compose.yml`, `services/dns/compose.yml`, `services/certbot/compose.yml`, `services/step-ca/compose.yml`
   Acceptance: `version:` line is removed with no other changes.

3. Title: Verify no behavioral changes
   Files: compose files above
   Acceptance: Only the `version` field is removed; service definitions remain identical.

4. Title: Verification step
   Files: none (runtime check)
   Acceptance: `docker compose` no longer warns about obsolete `version`.
