## ADDED Requirements
### Requirement: Multilingual README system
The system SHALL provide EN/SV/ES root and per-service README files with a language selector linking to equivalent pages.

#### Scenario: Language selector parity
- **WHEN** a user opens any README page
- **THEN** they see links to the EN/SV/ES versions of that same page

### Requirement: Structural parity across languages
The system SHALL keep section structure and anchor IDs consistent across EN/SV/ES variants.

#### Scenario: Anchor consistency
- **WHEN** a user navigates between languages
- **THEN** equivalent sections use the same anchor IDs

### Requirement: Validation tooling
The system SHALL include a docs validation script and Makefile target to verify completeness and link correctness.

#### Scenario: Docs check
- **WHEN** `make docs-check` is executed
- **THEN** it fails on missing README variants, broken links, or selector mismatches
