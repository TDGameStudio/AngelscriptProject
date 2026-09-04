---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-121653-clause-detail-ownership
status: resolved
source: user
source_ref: "user:2026-09-04 per-WHEN/THEN Task-style detail correction"
affected_tasks: ["1.1", "1.2", "2.1", "2.2"]
created_at: 2026-09-04T12:16:53+08:00
resolved_at: 2026-09-04T12:26:23+08:00
resolution_ref: "attachments/data/workflow-evaluation.md#verification"
---

# Clause Detail Ownership Mismatch

## Symptom

The shipped authoring contract places one optional detail block after all Scenario behavior clauses. The user expected each `WHEN` or `THEN` item to own indented `>` notes and nested lists exactly as each Task checkbox owns its supporting block.

## Investigation Log

- Compared the archived Change and current template with the actual Task Card form in `.agents/skills/harness/references/task-dag.md` and the preceding Change's `tasks.md`.
- Confirmed that Task detail is indented beneath its owning checkbox, while the shipped Scenario example is an unindented tail owned by the Scenario heading.

## Root Cause

The requirement was interpreted as richer Scenario-level prose instead of reusable list-item composition at the individual behavior-clause level.

## Disposition

Correct the ownership contract through this exact successor Change. Preserve ordinary Markdown flexibility and move representative examples under their exact owning clauses.

## Evidence

### Failure Evidence (RED)

- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Artifact: `attachments/data/clause-detail-red.md`
- Result: At `2026-09-04T12:19:24+08:00`, the command exited `1` with `Scenario Card contract is missing: behavior-clause list item`.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
- Artifact: `attachments/data/workflow-evaluation.md`
- Result: All eight Quick gates passed after the focused OpenSpec Skill test, strict workflow/spec/Change validation, and five changed-Skill package validations passed.

### What This Proves

The user-visible nesting contract and its regression coverage are owned by a durable follow-up rather than by rewriting the prior archive.

### What This Does Not Prove

It does not change the portable parser, make details mandatory, or authorize implementation instructions in specifications.

## Links

- Prior immutable archive: `openspec/archive/changes/harness/2026-09-04-improve-spec-card-detail-blocks`
- Authoring reference: `.agents/skills/openspec/references/specs.md`
- Project template: `openspec/workflows/angelscript/templates/spec.md`
