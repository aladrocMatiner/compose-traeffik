# Change: Clean Up Historical OpenSpec Cert Paths

## Summary
Align historical OpenSpec references to cert paths with the current canonical `shared/certs/` to reduce confusion.

## Problem
Older OpenSpec proposals and notes still mention `certs/`, which is no longer canonical. This can mislead readers who treat OpenSpec content as current truth.

## Goals
- Update historical OpenSpec references to use `shared/certs/`.
- Add a short note that OpenSpec historical changes may reflect past state, but paths should align with current canonical references.

## Non-goals
- No runtime or docs changes outside OpenSpec.
- No changes to behavior or tooling.

## Approach
- Locate OpenSpec files that mention `certs/` in a non-historical context.
- Replace path references with `shared/certs/` where appropriate.
- Add a brief clarification in the affected OpenSpec change(s) if needed.

## Affected files
- `openspec/changes/refactor-services-layout/proposal.md` (and any other OpenSpec change referencing `certs/`)

## Verification
- OpenSpec changes no longer reference `certs/` as current paths.
- Canonical `shared/certs/` is consistent across OpenSpec content.
