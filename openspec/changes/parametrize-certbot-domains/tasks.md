1. Title: Define configurable domain list source
   Files: `.env.example`, `scripts/certbot-issue.sh`
   Acceptance: A single env var or derivation method is selected and documented.

2. Title: Update certbot issuance script
   Files: `scripts/certbot-issue.sh`
   Acceptance: `-d` arguments are built from the configured list.

3. Title: Document domain configuration
   Files: `docs/tls-mode-b-letsencrypt-certbot.md`, `docs/05-tls/mode-b-letsencrypt-certbot.md`
   Acceptance: Docs explain how to set the domain list and defaults.

4. Title: Verify backward compatibility
   Files: `scripts/certbot-issue.sh`, `.env.example`
   Acceptance: Default behavior matches current domain list when the new var is unset.
