## 1. Implementation
- [x] 1.1 Review current bootstrap defaults (profiles, endpoints, auth assets) to define the minimal production set.
- [x] 1.2 Implement a production-minimal env generation path (new script or `--mode=prod`) and keep the full mode behavior intact.
- [x] 1.3 Wire `make bootstrap` to production mode and add `make bootstrap-full` for the full mode.
- [x] 1.4 Update quickstart docs in `README.md`, `README.es.md`, and `README.sv.md` to document both options.

## 2. Verification
- [x] 2.1 `make bootstrap` yields production-minimal defaults in `.env`.
- [x] 2.2 `make bootstrap-full` yields the current full defaults in `.env`.
