# Collapse code-review to one Skill and define review rules

## Why

`.agents/skills/code-review/` holds one routed project Skill (`code-review/code-reviewer/SKILL.md`) and two underscore-disabled copies of superpowers Skills (`receiving-code-review`, `requesting-code-review`). The copies are not routed or tested, one links a missing template, and their core rule — review after every task — contradicts the project's explicit-request Review policy. The `/goal` test even special-cases the directory to skip it. Meanwhile the project's own review rules name `Critical / Required / Advisory` without defining them, never bound re-review chains (archives show five-round chains), never name coordinator-side fan-out, and say nothing about how the coordinator should behave when a finding is ambiguous, contradicts a user-owned decision, or asks for unused functionality.

## What Changes

Flatten the group to one Skill at `.agents/skills/code-review/SKILL.md` named `code-review` and delete the two superpowers copies. Keep the existing reviewer contract and add the reviewer-side rules: complete input contract, tests and task cards first, read-only inspection via `git show` or a temporary worktree, no sub-dispatch, no rerun of supplied broad gates, severity definitions, distinctly labelled planning findings, a "Verified sound" coverage section, and verdict with real `reviewed_at`.

Extend the Triage section of `harness/references/review.md` with the coordinator-side rules: reproduce before acting, clarify every ambiguous finding before repairing any, repair order Critical → Required → Advisory and blocking → simple → complex with per-repair verification, route a finding that contradicts a user-owned decision to the user (attended) or `openspec-update-change` (unattended), answer unused-functionality requests with usage evidence, state repairs without performative language, bound re-review to previous resolution conditions on a new snapshot, and allow fan-out by area with distinct reviewers.

Update routing, the Skills README, the tests, and the `harness/core` durable specification (MODIFIED "Explicit Review intake and direct closure": severity definitions, re-review bound, fan-out). Review cadence and the `review-v2` schema do not change.

## Impact

Owned paths: `.agents/skills/code-review/**`, `.agents/skills/harness/references/review.md`, `.agents/skills/harness/references/routing.md`, `.agents/skills/README.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/specs/harness/core/spec.md` (via delta sync).

Non-goals: no cadence change, no `review-v2` schema change, no external-agent request template, no rewrite of the superpowers copies as project Skills, no baseline test or spec debt outside the owned files, no edits to immutable archives. Parent repository only.
