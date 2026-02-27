## 1. OpenSpec Contract

- [x] 1.1 Review and approve the CLI contract for `deployment-list-os` and `deployment-list-targets` (stable, script-friendly output).
- [x] 1.2 Confirm phase scope for `deployment-list-targets` as `qemu` only.
- [x] 1.3 Validate change artifacts with `openspec validate add-deployment-list-os-and-targets-commands --strict`.

## 2. Makefile Commands

- [x] 2.1 Add a canonical source-of-truth list for supported deployment OS selectors.
- [x] 2.2 Add a canonical source-of-truth list for supported deployment targets, with current value `qemu`.
- [x] 2.3 Implement `make deployment-list-os` to print one OS selector per line in stable order.
- [x] 2.4 Implement `make deployment-list-targets` to print one target selector per line in stable order.
- [x] 2.5 Ensure both commands are read-only, do not require Terraform/env preconditions, and exit `0` on success.

## 3. Documentation

- [x] 3.1 Update `make help` with both commands and their purpose.
- [x] 3.2 Update `scripts/README.md` usage examples for the new discovery commands.
- [x] 3.3 Update tests/docs references if command paths or test inventory entries change.

## 4. Testing

- [x] 4.1 Add/adjust deployment smoke tests to validate target wiring and command output.
- [x] 4.2 Validate that `deployment-list-targets` currently returns only `qemu`.
- [x] 4.3 Run the relevant deployment smoke tests and docs checks.

## 5. Validation and Handoff

- [x] 5.1 Re-run `openspec validate add-deployment-list-os-and-targets-commands --strict`.
- [x] 5.2 Do a final review for docs/tests/Makefile drift.
