## 1. Cross-Cutting Observability Option Spec

- [ ] 1.1 Add a new spec capability defining the observability option contract for new services.
- [ ] 1.2 Define safe-default telemetry exposure rules (internal-only unless explicitly documented/exposed).
- [ ] 1.3 Define disabled-mode behavior (service works without observability stack).
- [ ] 1.4 Define docs/test expectations for observability integration sections and smoke checks.

## 2. Existing Cross-Spec Alignment

- [ ] 2.1 Update `services-layout` spec to require new services to document observability option handling.
- [ ] 2.2 Update `tests-docs` and/or `tests-suite` specs to require observability wiring documentation/test guidance for new services when applicable.
- [ ] 2.3 Update `scripts-docs` spec to cover observability-related service scripts or toggles when introduced.

## 3. Validation

- [ ] 3.1 Run `openspec validate add-new-service-observability-option-spec --strict`.
