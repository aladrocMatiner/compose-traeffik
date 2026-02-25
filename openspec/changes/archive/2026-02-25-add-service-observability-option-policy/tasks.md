## 1. Cross-Cutting Observability Option Spec

- [x] 1.1 Add a new spec capability defining the observability option contract for new services.
- [x] 1.2 Define safe-default telemetry exposure rules (internal-only unless explicitly documented/exposed).
- [x] 1.3 Define disabled-mode behavior (service works without observability stack).
- [x] 1.4 Define docs/test expectations for observability integration sections and smoke checks.

## 2. Existing Cross-Spec Alignment

- [x] 2.1 Update `services-layout` spec to require new services to document observability option handling.
- [x] 2.2 Update `tests-docs` and/or `tests-suite` specs to require observability wiring documentation/test guidance for new services when applicable.
- [x] 2.3 Update `scripts-docs` spec to cover observability-related service scripts or toggles when introduced.

## 3. Validation

- [x] 3.1 Run `openspec validate add-service-observability-option-policy --strict`.
