## 1. Implementation
- [x] Inventory `rg` usage in smoke tests.
- [x] Replace `rg` in Traefik readiness test with `grep`/`awk` equivalents.
- [x] Replace `rg` in DNS service config test with `grep`/`awk` equivalents.
- [x] Align healthcheck dependency validation with remaining tools. (No `rg` remaining; no changes needed.)
- [x] Adjust `.gitignore` to track `services/traefik/dynamic/` templates.

## 2. Verification
- [x] Confirm smoke tests no longer require `rg` (or healthcheck explicitly validates it). (No `rg` remaining.)
- [x] Confirm `services/traefik/dynamic/` is no longer ignored by git.
