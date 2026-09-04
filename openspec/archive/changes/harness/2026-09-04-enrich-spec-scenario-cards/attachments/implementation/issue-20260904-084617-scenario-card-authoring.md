---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-084617-scenario-card-authoring
status: resolved
source: dogfooding
source_ref: 85c9c9552e4f42c9940e825800b6029b
affected_tasks: ["1.1", "1.2", "2.1", "2.2", "2.3"]
created_at: 2026-09-04T08:46:17+08:00
resolved_at: 2026-09-04T08:58:16+08:00
resolution_ref: "attachments/data/workflow-evaluation.md#verification"
---

# Scenario Card authoring gap

## Symptom

Maintained Harness specifications and the project spec template show only one `WHEN` and one `THEN`. Complex behavior has no shared progressive-detail convention for preconditions, inputs, observables, exclusions, or a stable verification oracle. The sync Skill also does not state whether updating a same-name scenario replaces its whole card or preserves unnamed detail.

## Investigation Log

- Harness observation `85c9c9552e4f42c9940e825800b6029b` recorded the authoring friction before Change creation.
- A read-only inventory found 128 scenarios across the four current Harness specs; every scenario had exactly one `WHEN` and one `THEN`, with no optional Scenario Card detail.
- The `angelscript` workflow already uses `record-v1`, which permits optional durable specs and accepts ordinary Markdown. No parser or validation-profile change is required.
- The workspace spec places four Git-derived discovery/status scenarios below the adjacent configuration-migration requirement, so synchronization needs one explicit ownership repair.

## Root Cause

Scenario authoring evolved around a deliberately minimal example, but no central specification reference was added when Task Cards gained progressive detail. As a result, the template, workflow prompt, lifecycle Skills, synchronization rules, and current examples do not share one durable contract.

## Disposition

Add one central Scenario Card authoring reference, route every spec lifecycle through it, retain `record-v1`, enrich only representative complex Harness scenarios, and correct the confirmed workspace ownership defect. Resolve this issue only after focused tests, strict record validation, Skill validation, and Harness Quick pass.

## Evidence

### Failure Evidence (RED)

- Command: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Artifact: `attachments/data/scenario-card-red.md` (source run chunk `c47de9`, exit code `1`).
- Failure: `Specification and Scenario Card reference is missing.`

### Resolution Evidence (GREEN)

- Command: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Artifact: `attachments/data/workflow-evaluation.md#verification` records the complete GREEN gate matrix and sync audit.
- Result: the focused test passed; all five changed Skill packages passed `quick_validate.py`; strict workflow/current-spec/exact-change/all-current validation passed; semantic sync checks passed; and Harness Quick passed `8/8`.

### Rejected Evidence

- A switch to `requirements-v1` was rejected because it would require durable deltas for maintenance Changes and does not provide Scenario Card richness.
- A parser/schema revision was rejected because all proposed detail is backward-compatible ordinary Markdown.

### What This Proves

The RED contract detected the missing authoring owner, and the GREEN evidence proves that one central reference now governs the template, prompts, lifecycle Skills, profile explanation, and synchronized representative specifications.

### What This Does Not Prove

These gates do not change or execute Unreal/plugin code and do not prove two real UBT builds can run concurrently end to end. They prove authoring, synchronization, structural, and fixture-level Harness contracts only.

## Links

- `proposal.md`
- `design.md`
- `specs/harness/core/spec.md`
- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- `attachments/data/workflow-evaluation.md`
