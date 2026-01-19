# Change: Repo Hygiene for Separate WIP

## Summary
Define a short policy to keep proposals clean and avoid mixing work-in-progress changes across unrelated OpenSpec changes.

## Problem
Local uncommitted changes can bleed across change scopes, confusing guardrails and reviews (e.g., proposal/apply for one change while unrelated files are modified).

## Goals
- Establish a lightweight hygiene policy for separating WIP by change.
- Provide a concise checklist to run before moving from proposal to apply.

## Non-goals
- No repository changes or enforcement mechanisms.
- No changes outside OpenSpec documentation.

## Approach
- Document a short policy for isolating WIP per change (e.g., keep unrelated files clean, avoid cross-change edits).
- Add an operational checklist for proposal→apply transitions.

## Hygiene Policy
- Keep the working tree clean for files outside the active change scope.
- Do not mix unrelated edits across multiple change IDs in a single working tree state.
- Stage/commit or stash unrelated WIP before moving a different change to apply.

## Pre-Apply Checklist
- Confirm only files in the active change scope are modified.
- Ensure unrelated WIP is committed, stashed, or reverted.
- Verify the change’s tasks.md reflects the current plan and scope.

## Affected files
- `openspec/changes/repo-hygiene-separate-wip/proposal.md`
- `openspec/changes/repo-hygiene-separate-wip/tasks.md`

## Verification
- The proposal includes a clear hygiene policy and a pre-apply checklist.
