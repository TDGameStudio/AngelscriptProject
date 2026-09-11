# INDEX

## Current position

Change created 2026-09-11 from designed draft `openspec/drafts/harness/code-review-skills/` (local, git-ignored). Carryover confirmed by the user in the same session and materialized below. All three tasks complete with inline Evidence (grouped RED/GREEN through the scoped `OpenSpecSkill.Tests.ps1`). Spec sync done 2026-09-11 16:12: the MODIFIED "Explicit Review intake and direct closure" requirement replaced its live counterpart in `openspec/specs/harness/core/spec.md`, adding four scenarios (fixed severity, re-review, fan-out, user-owned decision); strict spec validation passes. Closure: completed.

Known baselines not owned here: unscoped `OpenSpecSkill.Tests.ps1` English audit, `Protocol.Tests.ps1` closure-v1 archive INDEX audit, and `validate --archived --strict` on older archives all fail on pre-existing records.

## Hard conclusions

- Exactly one Skill remains under `.agents/skills/code-review/`: `code-review/SKILL.md`, name `code-review`.
- Review cadence is unchanged: explicit user or external-agent request only.
- Reviewer-side rules live in the Skill; coordinator-side triage rules live in `harness/references/review.md`.

## Forbidden

- Do not revive or rewrite the superpowers `receiving-code-review` / `requesting-code-review` files as project Skills.
- Do not change the `review-v2` record schema.

## Attachment index

- drafts/design.md — approved design copied from the draft — read before editing any Skill or reference text.
- drafts/handoff.md — decision-complete handoff copied from the draft — read when checking scope, owned files, or carryover.
- talks/talk-20260911-155000-single-code-review-skill.md — decisions D1–D6 with rejected alternatives, including the rejected per-task Review cadence — read before proposing to change cadence or directory shape.
- knowledges/review-rule-provenance.md — candidate: idea-by-idea adopt/adapt/reject table for the superpowers review Skills — read before adapting any other external review guidance.
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1.
