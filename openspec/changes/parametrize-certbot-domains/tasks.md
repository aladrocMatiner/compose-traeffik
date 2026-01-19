## 1. Implementation
- [x] Define configurable domain list source.  
  Files: `.env.example`, `scripts/certbot-issue.sh`  
  Acceptance: A single env var is selected and documented.

- [x] Update certbot issuance script.  
  Files: `scripts/certbot-issue.sh`  
  Acceptance: `-d` arguments are built from the configured list.

- [x] Document domain configuration.  
  Files: `docs/tls-mode-b-letsencrypt-certbot.md`, `docs/05-tls/mode-b-letsencrypt-certbot.md`  
  Acceptance: Docs explain how to set the domain list and defaults.

## 2. Verification
- [x] Verify backward compatibility.  
  Files: `scripts/certbot-issue.sh`, `.env.example`  
  Acceptance: Default behavior matches current domain list when the new var is unset.
