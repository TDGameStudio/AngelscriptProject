# Planning validation: refactor-apply-change-absorb-planning

Self-review of this Change's `tasks.md` against `.agents/skills/openspec/references/tasks.md` (single `### Preflight` text) and `cases.md`, performed 2026-09-11 at plan acceptance (19:22) and re-checked at closure (19:40). This is the first Change planned under the merged `openspec-apply-change` step 0: the agent wrote proposal, specs delta, design and tasks from the seeded handoff in one pass, then ran this preflight before selecting 1.1.

## Machine checks

- `openspec.validate harness/refactor-apply-change-absorb-planning --strict` → Succeeded at acceptance and at closure.
- `task.status` → 3 nodes; `1.1` Ready at acceptance.
- Scoped `OpenSpecSkill.Tests.ps1` on the Change directory → INDEX audit and English scan pass; no `openspec/drafts/` reference.

## Self-review items

1. **Every requirement has a task.** Two MODIFIED `harness/core` requirements: "Exploration markers and durable carryover" and "Ready-to-execute Task authoring" → 1.1; retirement ripple → 2.1; record → 3.1.
2. **Every card is complete for its kind.** 1.1 and 2.1: brief, Outcome, Interfaces fences, Cases with `new RED` (headers `· behavior`, `· absence`, `· invariant`), Files fence, Verification fence. 3.1: document card.
3. **No forbidden phrase; no undefined symbol.** None present; the only new wording `Ensure plan` is declared in 1.1 Interfaces with its glossary source.

## Deviations recorded

- 2.1 Verification scope narrowed to the owned Skill directories and `openspec/README.md` (root `README.md` is Chinese; `.agents/skills/web/**` carries CJK data); recorded in 2.1 Evidence.
- The live-reference scan in the suite excludes `tests/` because the suite holds the literal `openspec-continue-change` in its own negative assertions.