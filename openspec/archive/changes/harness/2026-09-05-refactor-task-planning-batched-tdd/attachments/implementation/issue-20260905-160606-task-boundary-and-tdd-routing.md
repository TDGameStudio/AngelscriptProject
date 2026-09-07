---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-160606-task-boundary-and-tdd-routing
status: resolved
resolved_at: 2026-09-05T16:43:34.0665824+08:00
resolution_ref: attachments/data/verification.md
source: user
source_ref: user-confirmed feature-group TDD and detailed tasks; AS task 4.1 and its 20260905-095630 batching replan
affected_tasks: ["1.1", "2.1", "3.1"]
created_at: 2026-09-05T16:06:06+08:00
---

## Symptom

The AS task 4.1 remains one unchecked node despite multiple independently useful verified batches. A user-authorized delayed-first-run exception and the shared per-test TDD instructions describe different sequencing without a common feature-group contract.

## Investigation Log

- Read Harness verification, Task DAG, OpenSpec task authoring, workflow/template, TDD, the active task and batching replan.
- The authoring reference already requires independently testable outcomes, but common generation and execution entries primarily enforce format. Extra ownership and checks accumulate in 4.1 tail prose.
- The local Superpowers v6.3.0 reference distinguishes task outcomes from execution steps and focused iteration from complete-suite checks; it does not justify importing its unrelated workspace/review policy.
- The user explicitly selected outcome-sized detailed cards and grouped observed RED/GREEN, including replanning the pending AS tasks.

## Root Cause

Planning quality is not checked at the generation/execution routing boundaries, and proof granularity is conflated with process scheduling. This permits an oversized task to absorb independent work while a batch exception bypasses shared TDD wording.

## Disposition

Repair shared policy routing, detailed task examples, evidence mapping and pending AS boundaries; retain valid work and immutable history. This is not a Harness executor failure.

## Evidence

### Failure Evidence (RED)

- Command: `Get-Content .agents/skills/harness/references/verification.md; Get-Content .agents/skills/test-driven-development/SKILL.md; Get-Content openspec/changes/angelscript/refactor-builder-engine-independent/tasks.md`
- Artifact: `data/behavior-probe.md`; source diagnosis compares the exact per-task RED rule, single-test TDD loop and active task's co-development exception and oversized 4.1.
- The diagnostic conflict is established; the independent old-policy exercise will be recorded honestly even if it compensates for some missing guidance.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`; scoped OpenSpecSkill owner command in tasks.md; `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-builder-engine-independent','--strict','--json')`.
- Artifact: `attachments/data/verification.md` and `attachments/data/behavior-probe.md` contain exact owner results, six policy hashes and independent consumer comparison.
- Result: owner checks pass; strict AS validation 2a81e5f013074bb2a26fae4a33851720 passes; task.status aa394baa0ba34726b9f64570da8623c7 confirms preserved eight completed nodes and four new pending feature groups, sole Ready 4.2. This resolves guidance/task boundaries, not AS behavior.

### What This Proves

The instructions and current task boundary need a coordinated correction explicitly requested by the user.

### What This Does Not Prove

No UE launch optimization, AS code correctness, or new runtime defect has been demonstrated by this issue.

## Links

- `../data/behavior-probe.md`
- `../../design.md`
- AS change: `angelscript/refactor-builder-engine-independent`, task 4.1.
