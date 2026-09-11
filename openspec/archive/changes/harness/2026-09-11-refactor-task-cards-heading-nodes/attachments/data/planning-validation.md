# Planning validation: refactor-task-cards-heading-nodes

Self-review of this Change's own `tasks.md` against the contract in `.agents/skills/openspec/references/tasks.md`, performed 2026-09-11 after the plan was rewritten in heading-node form and before task 3.2 closed. Reviewer: the applying agent; the packaged `openspec 0.10.0` supplied the machine checks.

## Machine checks

- `Invoke-Harness -Command openspec.validate -ArgumentList @('harness/refactor-task-cards-heading-nodes','--strict','--json')` → `Succeeded`, `valid: true`, no issues.
- `task.status` → 8 nodes, `fileRoles` projected for every card (for example 1.1: `Tools/openspec/src/core/task_plan.rs = modify`, `Tools/openspec/tests/heading_task_contract.rs = create`).
- Scoped `OpenSpecSkill.Tests.ps1` attachment INDEX audit → every file under `attachments/` indexed exactly once; no `openspec/drafts/` path anywhere in the Change.

## Self-review items

1. **Every requirement has a task.** Requirement coverage table maps the five MODIFIED `harness/core` requirements to 1.1–3.2; each task ID in the table exists in the plan and in `task_graph`. No requirement maps to nothing; no task is uncovered.
2. **Every card is complete for its kind.** Behavior cards 1.1, 1.2, 1.3, 1.4, 2.2 carry brief, Outcome, Interfaces with a code fence, Cases with at least one `new RED`, Files diff fence, Verification fence. Document/migration cards 2.1, 3.1, 3.2 carry brief, Outcome, Files, Verification. Evidence follows execution on 1.1–1.4, 2.1, 2.2.
3. **No forbidden phrase; no undefined symbol.** Scanned for `TBD`, `TODO`, `implement later`, `fill in details`, `add appropriate error handling`, `handle edge cases`, `write tests for the above`, `similar to Task`, `known values`, `existing fixtures`, `preserve behavior`: none present. New names (`FileRole`, `FileRoleKind`, `fileRoles`, `heading_task_contract.rs`, `execution-conventions.md`, `unsupported-task-format` message text) are declared in Interfaces with their source (`attachments/drafts/glossary.md` or the naming round in the talk).

## Deviations recorded

- 1.1–1.3 were executed as one feature group with a shared RED/GREEN run; task-specific evidence is kept under each card, as `execution-conventions.md` requires for shared runs.
- 2.2's RED for its token loop was observed as design only because the Skills and tests were edited in the same pass; the Notes on the card say so.
- Migration (3.1) is syntax-only by design; the thin cards it produces are intended to be blocked by apply preflight in their owning Changes, not repaired here.
