## 1. Command Contract

- [x] 1.1 Confirm and formalize the BIND lifecycle target set (`bind-up`, `bind-down`, `bind-logs`, `bind-status`, `bind-restart`).
- [x] 1.2 Define target semantics (service scope, profile usage, and expected operator outcome).

## 2. Makefile and Compose Integration Plan

- [x] 2.1 Define required Makefile updates for lifecycle targets and `make help` discoverability.
- [x] 2.2 Define wrapper/compose expectations so BIND targets remain deterministic from any CWD.

## 3. Documentation and Testing Plan

- [x] 3.1 Define documentation updates in root/service docs to present BIND commands as official branch workflow.
- [x] 3.2 Define smoke-test coverage and/or doc-validation checks that detect regressions in BIND command wiring.

## 4. Validation Preparation

- [x] 4.1 Validate change artifacts with `openspec validate add-make-bind-server-commands --strict`.
- [x] 4.2 Prepare implementation handoff checklist for apply phase.
