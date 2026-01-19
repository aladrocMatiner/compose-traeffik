## 1. Implementation
- [x] Inventory OpenSpec cert path references.  
  Files: `openspec/changes/`  
  Acceptance: All occurrences of `certs/` in OpenSpec changes are listed.

- [x] Update historical path references.  
  Files: `openspec/changes/refactor-services-layout/proposal.md` (and any other affected change files)  
  Acceptance: References to `certs/` are updated to `shared/certs/` where they describe current paths.

- [x] Add clarification note (if needed).  
  Files: affected OpenSpec change files  
  Acceptance: Not needed; path references now align with canonical `shared/certs/`.

## 2. Verification
- [x] Verify consistency.  
  Files: `openspec/changes/`  
  Acceptance: OpenSpec change files no longer recommend `certs/` for current usage.
