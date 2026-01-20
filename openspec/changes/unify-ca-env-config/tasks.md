## 1. Implementation
- [x] 1.1 Define shared CA variables in `.env.example` (and document in README/tls guides).
- [x] 1.2 Update `scripts/certs-selfsigned-generate.sh` to consume shared CA values for subject and SANs (with sensible defaults).
- [x] 1.3 Update `scripts/stepca-bootstrap.sh` to consume shared CA values for CA name/DNS (keep backward-compatible fallbacks).
- [x] 1.4 Update docs to reference the shared CA section for Mode A and Mode C.
- [x] 1.5 Add or update tests/validation scripts if needed to ensure values are wired correctly.
