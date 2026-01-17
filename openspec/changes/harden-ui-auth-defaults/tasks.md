## 1. Discovery
- [x] 1.1 Record current middleware usersFile paths and auth example files.
- [x] 1.2 Record how Traefik dynamic rendering replaces env vars today.
- [x] 1.3 Record DNS service env handling and where DNS_ADMIN_PASSWORD is required.

## 2. Implementation
- [x] 2.1 Implement fail-closed auth policy for dashboard and DNS UI.
  - Acceptance: UIs are not accessible unless a non-example htpasswd path is configured.
- [x] 2.2 Wire `DNS_UI_BASIC_AUTH_HTPASSWD_PATH` into the DNS UI middleware usersFile.
  - Acceptance: changing the env var changes the usersFile path used by Traefik.
- [x] 2.3 Add dashboard htpasswd env var (if missing) and wire it into middleware usersFile.
  - Acceptance: dashboard uses the configured usersFile path.
- [x] 2.4 Add preflight validation that `DNS_ADMIN_PASSWORD` is set when DNS profile is enabled.
  - Acceptance: `make up` fails early with a clear message if DNS is enabled and password is missing.
- [x] 2.5 Update README with a short security note: generate htpasswd, set env vars, and enable UI.
  - Acceptance: concise and accurate.

## 3. Validation
- [x] 3.1 With default `.env.example`, DNS UI/dashboard are not accessible with example creds.
- [x] 3.2 With real htpasswd paths set, DNS UI/dashboard return 401 (and then 200 with valid creds).
- [x] 3.3 Enabling DNS profile without `DNS_ADMIN_PASSWORD` fails fast.
