## 1. Implementation
- [x] 1.1 Audit current `ENDPOINTS` defaults and hosts generation logic to confirm why DNS is missing.
- [x] 1.2 Update env generation defaults so full mode includes the DNS endpoint when `ENDPOINTS` is set.
- [x] 1.3 Adjust hosts-subdomains logic to validate or normalize `ENDPOINTS` entries for known services when applicable.
- [x] 1.4 Update quickstart docs (all languages) to reference `--mode` where env generation is described.

## 2. Verification
- [x] 2.1 `make bootstrap-full` + `make hosts-generate` includes the DNS entry.
- [x] 2.2 Quickstart docs in all languages mention `--mode` for env generation.
