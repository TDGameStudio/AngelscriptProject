---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-115352-spec-card-detail-blocks
status: resolved
source: user
source_ref: "conversation 2026-09-04: Task-like quoted detail and ordered-list request"
affected_tasks: ["1.1", "1.2", "2.1", "2.2"]
created_at: 2026-09-04T11:53:52.0983501+08:00
resolved_at: 2026-09-04T12:07:20.9243136+08:00
resolution_ref: "attachments/data/workflow-evaluation.md#verification"
---

# Scenario Card flexible detail blocks are not visible

## Symptom

The project template shows `WHEN` / `THEN` followed by five fixed optional quoted labels, while Task Cards visibly support quoted metadata and subsequent lists. Current specs enrich only selected scenarios, so the user cannot see that a Scenario may own richer free-form detail and correctly reports the upgrade as incomplete.

## Investigation Log

- The archived Scenario Card Change intentionally allowed ordinary Markdown but made bulk enrichment and required fields non-goals.
- The central reference says optional detail may be replaced with prose, but neither its primary example nor the template shows a `Details` block, ordered list, unordered list, example, or table.
- Four current Harness specs contain useful candidates where durable sequence or isolation detail can demonstrate the form without adding boilerplate.

## Root Cause

The prior upgrade defined permission abstractly around fixed labels instead of making the Scenario-owned free-form detail shape visible across the authoring entry points and representative current specifications.

## Disposition

Expand the authoring contract and template, update lifecycle Skill wording, add a focused RED/GREEN contract, and synchronize four representative current Scenario Cards. Keep the parser, profiles, Task DAG, and compact scenarios unchanged.

## Evidence

### Failure Evidence (RED)

- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Artifact: `attachments/data/spec-card-detail-red.md`
- Result: the package-safety phase passed, then the focused contract exited non-zero with `Scenario Card contract is missing: > Details:`.
- This proves the pre-repair central authoring contract did not visibly expose the Task-like Scenario detail block requested by the user.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
- Artifact: `attachments/data/workflow-evaluation.md#verification`
- Result: all 8 public Harness Quick gates passed after the focused OpenSpec and Protocol tests, five changed Skill validations, strict workflow validation, strict current-spec validation, and exact active-Change validation passed.

### What This Proves

The project authoring surface now visibly permits one Scenario-owned detail block containing quoted metadata, prose, ordered or unordered lists, examples, or tables. Four synchronized current specs demonstrate that form without changing Task state or parser behavior.

### What This Does Not Prove

This authoring repair does not change runtime behavior or require every Scenario to carry detail.

## Links

- `proposal.md`
- `specs/harness/core/spec.md`
- `.agents/skills/openspec/references/specs.md`
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- `attachments/data/spec-card-detail-red.md`
