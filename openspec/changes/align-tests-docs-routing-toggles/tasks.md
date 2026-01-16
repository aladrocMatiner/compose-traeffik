## 1. Implementation
- [x] 1.1 Confirm final behavior from `fix-traefik-provider-dashboard-redirect` and `fix-tls-bc-determinism` (dashboard access path, redirect toggle strategy, certbot mount path).
- [x] 1.2 Update `tests/smoke/test_traefik_ready.sh` to check readiness using the new access path (HTTPS router or container-local ping).
- [x] 1.3 Update `tests/smoke/test_http_redirect.sh` to assert both enabled and disabled behavior for `HTTP_TO_HTTPS_REDIRECT`.
- [x] 1.4 Add or update a test to fail when docker provider routing is disabled (e.g., verify provider config or profile endpoint routing).
- [x] 1.5 Refresh `tests/README.md` to describe the updated test expectations and prerequisites.
- [x] 1.6 Update `README.md` and TLS guides to match the new routing/tls toggles and deterministic Mode B/C behavior.

## 2. Validation
- [ ] 2.1 Run `make test` after the provider/tls fixes to confirm smoke tests pass.
- [ ] 2.2 Verify docs no longer claim certbot affects routing without the required mounts/config.
