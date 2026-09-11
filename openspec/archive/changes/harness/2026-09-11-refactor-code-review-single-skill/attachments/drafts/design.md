# Design: one `code-review` Skill

Status: approved 2026-09-11 (Round 1, all recommended options).

## 1. Outcome

`.agents/skills/code-review/` contains exactly one Skill, `code-review/SKILL.md` (name `code-review`), which owns the reviewer's stance for an explicitly requested fixed-snapshot Review. The coordinator's triage rules live in `harness/references/review.md`. The two disabled superpowers copies are deleted.

## 2. Decisions

| # | Decision | Chosen | Rejected |
|---|---|---|---|
| D1 | Directory shape | Flatten to `.agents/skills/code-review/SKILL.md` | Keep `code-review/code-reviewer/`; rename to `code-reviewer/` |
| D2 | Skill name | `code-review` | `code-reviewer` |
| D3 | superpowers `receiving-code-review` / `requesting-code-review` | Delete; carry only the ideas listed in §3 | Rewrite as project Skills |
| D4 | Rule set | All 18 candidate rules from `findings/superpowers-review-analysis.md` §4 | Reviewer-side only |
| D5 | Delivery | OpenSpec Change `harness/refactor-code-review-single-skill` | Direct edit |
| D6 | Review cadence | Unchanged: explicit request only | superpowers "after every task" |

## 3. Content moves

### `code-review/SKILL.md` (reviewer side, rules 1–10)

Keep the existing `code-reviewer` text (assignment fields, evaluate list, finding fields, no line limit, `APPROVE` rule) and add:

- Input contract completeness → report limitation, never guess.
- Read tests and task cards first.
- Read-only: `git show` / temporary worktree; never move HEAD or touch the index.
- No sub-dispatch; split-by-area is the coordinator's pre-assignment decision.
- Severity definitions for `Critical` / `Required` / `Advisory`.
- Planning findings labelled as such, never prescribing Replan.
- A "Verified sound" coverage section.

### `harness/references/review.md` Triage section (coordinator side, rules 11–18)

- Reproduce before acting; reject with evidence.
- Clarify all ambiguous findings before repairing any.
- Repair order: Critical → Required → Advisory; blocking → simple → complex; verify each repair with the owning task's proving selection.
- Finding vs user-owned decision: attended → ask the user; unattended → park through `openspec-update-change`.
- Unused-functionality requests answered with usage evidence.
- Language: state repair and evidence; no performative agreement, gratitude, or apology.
- Re-review bounds: checks previous resolution conditions on a new snapshot; new scope = new Review.
- Fan-out by area with distinct reviewers and no overlapping scopes.

### Deleted

- `.agents/skills/code-review/receiving-code-review/_SKILL.md`
- `.agents/skills/code-review/requesting-code-review/_SKILL.md`

### Ripple

- `harness/references/routing.md` row → `code-review/SKILL.md`.
- `.agents/skills/README.md` line 38 → `code-review`.
- `OpenSpecSkill.Tests.ps1` `/goal` exclusion regex drops `code-review`; new tokens assert the severity definitions, "Verified sound", no sub-dispatch, and the triage ordering in `review.md`; assert the two `_SKILL.md` paths do not exist.
- `openspec/specs/harness/core` delta: MODIFIED "Explicit Review intake and direct closure" adds severity definitions, re-review bound, and fan-out as durable behavior.

## 4. Vocabulary

See `glossary.md`. New public names: Skill `code-review`; section heading "Verified sound"; terms "planning finding", "re-review", "fan-out".

## 5. Out of scope

- Any change to Review cadence or the `review-v2` schema.
- A request template for external agents (`review-request.md`) — flip condition in `findings/code-review-inventory.md`.
- Baseline test/spec debt.
