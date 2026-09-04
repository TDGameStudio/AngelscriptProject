---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260904-130017-evolution-terminal-bypass
status: resolved
source: dogfooding
source_ref: "review:2026-09-04 comprehensive Harness self-upgrade audit"
affected_tasks: ["1.1", "1.2", "2.1", "2.2"]
created_at: 2026-09-04T13:00:17+08:00
resolved_at: 2026-09-04T13:24:27+08:00
resolution_ref: "run:HarnessEvolution.Tests.ps1-20260904T132427+0800"
---

# Evolution Terminal Gate Bypass

## Symptom

An exact active Change can report `ClosureReady = true` without proving complete Task state, current evaluation content, strict v2 issue ownership, or closure of an existing Review. Archived records also enter the same terminal policy path.

## Investigation Log

- The current route scans only direct `attachments/implementation/issue-*.md` children.
- A schema-less issue is counted as legacy even while its Change is active.
- `affected_tasks` is syntax-checked but not resolved against the active TaskPlan.
- The canonical evaluation has no closure kind or content digest.
- Existing Review files are not part of the terminal decision.
- The original issue scan was non-recursive, active schema-less records inherited archive compatibility, lifecycle timestamps were not ordered, and successor ownership was not reciprocal.

## Root Cause

The first evolution gate summarized frontmatter but did not bind closure readiness to all mutable active-Change owners. Historical read compatibility and current terminal policy were not separated.

## Disposition

Added one focused real-route fixture and made active closure fail closed across TaskPlan, issue, Review, successor, and digest-bound evaluation owners. Historical archive inspection remains read-only, and archived terminal evaluation is rejected in favor of strict archived OpenSpec validation.

## Evidence

### Failure Evidence (RED)

- Command: `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
- Artifact: `attachments/data/evolution-closure-red.md`
- Result: At `2026-09-04T13:05:11+08:00`, the focused test exited `1` because completed closure returned `Succeeded` for an incomplete TaskPlan.

### Resolution Evidence (GREEN)

- Command: `& ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1`
- Run ID: `HarnessEvolution.Tests.ps1-20260904T132427+0800`
- Result: `PASS` in approximately `2.8 s`, covering incomplete TaskPlan, stale/non-canonical digest, closure-kind mismatch, recursive active schemas, task/timestamp/body validation, Review lifecycle/findings, evaluation capture order, reciprocal successor ownership, and archive compatibility.
- Command: `& ./.agents/skills/harness/tests/Protocol.Tests.ps1`
- Result: `PASS`.
- Command: `& ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Result: package safety and Skill package tests passed.
- Commands: exact `workflow validate angelscript --json`, strict Change validation, and strict `harness/core` spec validation.
- Result: all passed; the Quick profile was only listed to confirm the focused evolution check is registered as the ninth fixture and was not executed.

### What This Proves

The real terminal route now rejects each demonstrated bypass and accepts only a complete, current, task-bound active evidence set. The regression is covered by a dedicated temporary fixture rather than requiring broad unrelated suites per edit.

### What This Does Not Prove

It does not prove unrelated Git, Workspace, Unreal, build, Editor, Automation, performance, or full Quick behavior. It does not change portable archive semantics or create Reviews automatically.

## Links

- `.agents/skills/harness/scripts/Harness.psm1`
- `.agents/skills/harness/references/closure.md`
- `.agents/skills/openspec/references/attachments.md`
