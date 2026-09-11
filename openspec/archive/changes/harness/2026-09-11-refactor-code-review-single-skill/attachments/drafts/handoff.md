# Handoff

## OpenSpec Handoff

- Target Change: `harness/refactor-code-review-single-skill`
- Title: Collapse code-review to one Skill and define review rules
- Design: `design.md` (approved 2026-09-11)
- Requirement changes: MODIFIED `harness/core` "Explicit Review intake and direct closure" — add severity definitions, re-review bound, fan-out; no new requirement.
- Files owned: `.agents/skills/code-review/**`, `.agents/skills/harness/references/review.md`, `.agents/skills/harness/references/routing.md`, `.agents/skills/README.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/specs/harness/core/spec.md` (via sync).
- Verification: scoped `OpenSpecSkill.Tests.ps1`, `Protocol.Tests.ps1` (temp copy with the pre-existing closure-v1 assertion downgraded), `openspec.validate <change> --strict`, `openspec.validate harness/core --type spec --strict`, Skill validator on `code-review`.
- Non-goals: cadence, `review-v2` schema, external request template, baseline debt.

## Exploration Carryover

Confirmed by the user 2026-09-11 (see log).

- `findings/superpowers-review-analysis.md` → knowledge `knowledges/review-rule-provenance.md` — which superpowers review ideas were adopted, adapted, or rejected and why; reusable when adapting any external review guidance.
- Round 1 decisions D1–D6 with the rejected cadence → talk `talks/talk-<ts>-single-code-review-skill.md` — prevents re-deciding "should Review run after every task" and the directory shape.
