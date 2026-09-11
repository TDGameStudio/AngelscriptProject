# Handoff

Draft `harness/lifecycle-skill-consolidation`; design approved 2026-09-11 19:18 (Round 2 Q6 A); carryover: none confirmed (Q5).

## Problem

`openspec-continue-change` only reformats a decision-complete handoff into planning artifacts, is fast-forwarded on every real run, and duplicates the preflight text kept in `tasks.md` and `openspec-apply-change`.

## Success Criteria

`openspec-apply-change` takes a Change from created to implemented with one `Ensure plan` step; one preflight text lives in `tasks.md ### Preflight` and is linked at plan acceptance and task start; the continue-change directory, routing row and README bullets are gone; no archived record is edited; scoped Skill tests pass; `harness/core` strict after sync.

## Scope and Exclusions

Skill wording, tests, spec delta. Excluded: CLI changes, artifact set or templates, other lifecycle Skills' scope, archived records.

## Constraints

Planning authority (stop on a missing user-owned decision, unsettled public name is a stop) stays distinct from implementation authority (never ask, `Naming assumed`). Records in English; no `openspec/drafts/` reference in the Change.

## Decision and Rationale

See `design.md` §3–§4 and `log.md` Round 1. Chosen: fold into apply (user's mental model is create → apply; a draft-less clear fix then needs only apply). Rejected: fold into create-change (would make create-change do two jobs); keep as is (three preflight copies, dead cadence).

## Verification

Scoped `OpenSpecSkill.Tests.ps1`; `Test-Path` negative on the removed directory; `openspec.validate <change> --strict`; spec delta strict; `harness/core --type spec --strict` after sync.

## OpenSpec Handoff

- Target Change: `harness/refactor-apply-change-absorb-planning`
- Title: Fold planning-artifact creation into openspec-apply-change
- Requirement changes: MODIFIED `harness/core` "Exploration markers and durable carryover" (canonical truth enters planning artifacts through `openspec-apply-change` step 0) and "Ready-to-execute Task authoring" (preflight moments named; single text). No new requirement.
- Files owned: `.agents/skills/openspec-continue-change/SKILL.md` (delete), `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec/references/tasks.md`, `.agents/skills/openspec/references/cases.md`, `.agents/skills/openspec-create-change/SKILL.md`, `.agents/skills/harness/SKILL.md`, `.agents/skills/harness/references/routing.md`, `.agents/skills/README.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/brainstorming/SKILL.md`, `.agents/skills/brainstorming/references/naming.md`, `.agents/skills/brainstorming/references/deep-exploration.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/README.md`, `README.md`, `openspec/specs/harness/core/spec.md` (via sync).
- Task boundaries: (1) apply step 0 + single preflight text + tests; (2) ripple references and delete the directory; (3) planning-validation record.

## Exploration Carryover

None confirmed (Round 2 Q5). Draft copies only: `design.md`, `handoff.md`, `glossary.md`.
