# Planning validation: refactor-task-cases-open-shapes

Self-review of this Change's `tasks.md` against `.agents/skills/openspec/references/tasks.md` and the new `cases.md`, performed 2026-09-11 after the plan was written (18:35) and re-checked at closure (18:50). Reviewer: the applying agent; the packaged `openspec 0.10.0` supplied the machine checks.

## Machine checks

- `Invoke-Harness -Command openspec.validate -ArgumentList @('harness/refactor-task-cases-open-shapes','--strict','--json')` → `Succeeded`, no issues, at creation and at closure.
- `task.status` → 3 nodes, `1.1` Ready at creation; `fileRoles` projected (for example 1.1: `cases.md = create`, five modify paths).
- Scoped `OpenSpecSkill.Tests.ps1` on the Change directory → INDEX audit passes (every attachment indexed once), English scan clean, no `openspec/drafts/` reference.

## Self-review items

1. **Every requirement has a task.** The one MODIFIED `harness/core` requirement is split across 1.1 (grammar, roles, catalog, `Setup:`/`Replaces:`, table rule), 2.1 (definitions, preflight, TDD grouping, deferred exclusion) and 3.1 (self-review record, validation); each row names existing task IDs and every task is covered.
2. **Every card is complete for its kind.** 1.1 and 2.1 are behavior cards with brief, Outcome, Interfaces fences, Cases (each with at least one `new RED`, headers in the new form including `· behavior` and `· example-table` kinds), Files fence, Verification fence. 3.1 is a document card with brief, Outcome, Files, Verification.
3. **No forbidden phrase; no undefined symbol.** Scanned for the forbidden list: none present. New names (`cases.md`, header regex, `Setup:` / `Roles:` / `Kinds:` / `Replaces:`, `deferred RED until X.Y`, catalog kinds) are declared in 1.1 Interfaces with their glossary source; 2.1 produces no new names.

## Deviations recorded

- This plan uses the new header form (`— new RED · behavior`, `— boundary · example-table`) before 2.1 taught preflight to read kinds; the headers also satisfy the pre-existing preflight (role tag present), so the plan was accepted under both contracts.
- 1.1 and 2.1 each observed a real RED (missing `cases.md`; missing continue token) before their edits; no shared run.
- Case 1.1-4 tables sit inside `example-table` cases as the new rule requires; the earlier contract would have flagged them, which is the behavior this Change retires.
