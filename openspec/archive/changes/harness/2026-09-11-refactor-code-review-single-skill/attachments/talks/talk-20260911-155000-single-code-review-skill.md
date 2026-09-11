# Talk: one `code-review` Skill, explicit-request cadence retained

- Captured: 2026-09-11
- Source: brainstorming draft `openspec/drafts/harness/code-review-skills/` (local, git-ignored), Round 1 and carryover round; original wording in its `log.md`.
- Requested by: user, during a review of the Harness Skill system after `harness/refactor-explore-brainstorming-drafts` archived.

## Context

`.agents/skills/code-review/` held one routed project Skill (`code-reviewer`) and two underscore-disabled copies of superpowers Skills (`receiving-code-review`, `requesting-code-review`). The user found the group confusing and asked what was special about the two copies and what rules the project's own code review needs.

## Evidence

- `harness/references/review.md` and the `harness/core` requirement "Explicit Review intake and direct closure" already own the Review lifecycle: explicit request only, immutable snapshot, `review-v2` record, triage, closure.
- The superpowers `requesting-code-review` mandate ("review after each task, before merge") is the opposite of the project rule.
- Thirty-six archived Review records show long evidence-heavy planning-plus-code reviews, re-review chains up to five rounds, and coordinator-side fan-out into several area Reviews — patterns the existing rules did not name.
- The comparison table is retained as `knowledges/review-rule-provenance.md`.

## Options considered

- A. Collapse to one Skill; fold coordinator triage stance into `review.md`. **Chosen.**
- B. Two leaves: reviewer + a rewritten `review-triage` Skill. Rejected: the triage stance is a few sentences and `review.md` already owns triage mechanics.
- C. Keep as-is, fix dead links. Rejected: leaves foreign disabled workflow text in the maintained tree.

## Settled decisions

| # | Decision |
|---|---|
| D1 | Flatten to `.agents/skills/code-review/SKILL.md`; no single-child group directory. |
| D2 | Skill name `code-review` (the user's wording; every other Skill is single-level). `code-reviewer` rejected. |
| D3 | Delete both superpowers copies; carry only the ideas in the knowledge record. |
| D4 | Adopt all 18 candidate rules: 1–10 reviewer side in the Skill, 11–18 coordinator side in `review.md`. |
| D5 | Deliver through Change `harness/refactor-code-review-single-skill`, not a direct edit. |
| D6 | Review cadence unchanged: explicit user or external-agent request only. superpowers per-task cadence rejected. |

## Consequences

- One review leaf, one lifecycle reference; routing, README, and the `/goal` test exclusion are updated.
- Severity names stay `Critical / Required / Advisory` but gain definitions; "Verified sound" replaces superpowers' "Strengths" as a coverage statement.
- Re-review and fan-out become named, bounded behaviors in the `harness/core` spec.

## Flip conditions

- If Reviews are routinely executed by an external agent that needs a hand-off template, add `harness/references/review-request.md`; do not revive the superpowers file.
- If the triage stance in `review.md` grows past a short section, split it into a `review-triage` reference — still not a Skill.
