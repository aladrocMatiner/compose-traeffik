## Context
Mode A hardcodes CA subject/SANs in `scripts/certs-selfsigned-generate.sh`. Mode C uses `.env` variables (`STEP_CA_NAME`, `STEP_CA_DNS`) during bootstrap. This splits CA identity across sources.

## Goals / Non-Goals
- Goals:
  - Provide a single `.env` section as the canonical source for CA identity and SAN values.
  - Keep Mode A and Mode C aligned without requiring duplicate edits.
  - Preserve backward compatibility for existing `.env` files.
- Non-Goals:
  - Change certificate issuance flow for Mode B (Certbot).
  - Modify how Traefik selects resolvers or TLS modes.

## Decisions
- Decision: Introduce shared CA variables in `.env` (e.g., `CA_NAME`, `CA_SUBJECT_*`, `CA_DNS`, `CA_IPS`).
- Decision: Mode A and Mode C read from shared variables first, then fallback to current mode-specific variables (e.g., `STEP_CA_NAME`, `STEP_CA_DNS`) or internal defaults.
- Alternatives considered: Keep per-mode variables only (rejected due to drift), or use a generated config file instead of `.env` (rejected due to added complexity).

## Risks / Trade-offs
- Risk: Users with existing `.env` may not see changes if they rely on legacy vars only.
  - Mitigation: Fallbacks remain and docs call out the shared section as the preferred source.
- Risk: Ambiguity between shared and mode-specific values.
  - Mitigation: Document precedence order explicitly in scripts and docs.

## Migration Plan
1. Add shared CA section to `.env.example` and docs.
2. Update scripts to read shared values with fallbacks.
3. Announce precedence order in release notes/README.

## Open Questions
- Exact variable names for shared CA config (align with existing naming conventions).
- Whether to include validity periods or key sizes in the shared section.
