# docs-multilang Specification

## Purpose
TBD - created by archiving change refactor-multilang-docs. Update Purpose after archive.
## Requirements
### Requirement: Multilingual README system
The system SHALL provide EN/SV/ES root and per-service README files with a language selector linking to equivalent pages.

#### Scenario: Language selector parity
- **WHEN** a user opens any README page
- **THEN** they see links to the EN/SV/ES versions of that same page
- **AND** DNS/BIND pages follow the same selector behavior

### Requirement: Structural parity across languages
The system SHALL keep section structure and anchor IDs consistent across EN/SV/ES variants.

#### Scenario: Anchor consistency
- **WHEN** a user navigates between languages
- **THEN** equivalent sections use the same anchor IDs
- **AND** DNS/BIND service pages keep matching section structure across EN/SV/ES

### Requirement: Validation tooling
The system SHALL include a docs validation script and Makefile target to verify completeness and link correctness.

#### Scenario: Docs check
- **WHEN** `make docs-check` is executed
- **THEN** it fails on missing README variants, broken links, or selector mismatches
- **AND** DNS/BIND documentation parity issues are surfaced as validation failures

### Requirement: Rocket.Chat docs maintain multilingual parity
The system SHALL provide Rocket.Chat service documentation and root README references in EN/SV/ES with consistent anchors and language selectors.

#### Scenario: User switches Rocket.Chat docs language
- **WHEN** a user opens the Rocket.Chat service page in EN, SV, or ES
- **THEN** each page contains the standard service anchors and links to the equivalent language variants
- **AND** root README service links point to the matching language file for Rocket.Chat

### Requirement: Semaphore UI multilingual documentation parity
The system SHALL provide EN/SV/ES Semaphore UI documentation pages (including observability integration docs if split out) with language selector parity.

#### Scenario: Semaphore UI docs language switching
- **WHEN** a user opens a Semaphore UI README in any supported language
- **THEN** they can navigate to equivalent Semaphore UI docs in EN/SV/ES
- **AND** equivalent pages preserve section structure parity

