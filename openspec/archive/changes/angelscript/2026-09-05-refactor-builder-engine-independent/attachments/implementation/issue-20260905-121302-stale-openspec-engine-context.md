---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-121302-stale-openspec-engine-context
status: resolved
source: dogfooding
source_ref: "task.status 40b1883c098b4ddd9d2f23f310ca6407"
affected_tasks: ["4.1", "7.2"]
created_at: 2026-09-05T12:13:02+08:00
resolved_at: 2026-09-05T21:20:00+08:00
resolution_ref: "openspec/config.yaml UE 5.8 prompt context"
---

## Symptom

The Harness `task.status` projectContext still describes this repository as a UE 5.7 host, while the canonical root entry and the selected real UE toolchain are UE 5.8. A zero-context agent receives conflicting version guidance.

## Investigation Log

- Task status run `40b1883c098b4ddd9d2f23f310ca6407` reproduced the UE 5.7 text in `data.projectContext`.
- `rg -n '5\.7 host' openspec -g '*.yaml'` locates the producer at `openspec/config.yaml:5`.
- Root `AGENTS.md:3` identifies the plugin as Unreal Engine 5.8. The exact workspace `ue.build` PlanOnly result (`664f3018be4e4fa79a4065761bc2d72f`) selects the installed `UE_5.8` EngineRoot.

## Root Cause

The project-owned OpenSpec prompt context retains an obsolete version literal. Harness forwards this configuration; no evidence shows the UE route selecting the wrong toolchain.

## Disposition

Recorded immediately under the user's instruction to preserve discovered Harness/OpenSpec issues. Keep using canonical AGENTS plus the exact Harness UE plan. The current product-code batch does not silently modify shared workflow configuration. Before terminal closure, resolve the prompt inconsistency with its owner-scoped verification or transfer this issue to an explicit successor; it is not an acceptable unrecorded deferral.

## Evidence

### Failure Evidence (RED)

- Command: `Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'angelscript/refactor-builder-engine-independent' }`
- Run ID: `40b1883c098b4ddd9d2f23f310ca6407`, contradictory version in returned projectContext; source is the literal at `openspec/config.yaml:5`.

### Resolution Evidence (GREEN)

`openspec/config.yaml` now states UE 5.8. Fresh `task.status` must no longer emit the 5.7 host literal. Actual Harness `ue.*` execution already selected UE 5.8 independently of that prompt.

### What This Proves

The stale version is reproducible planning guidance rather than merely an old conversation statement.

### What This Does Not Prove

No build/test failure, incorrect engine invocation or Harness execution defect is established by this finding.

## Links

- `openspec/config.yaml:5`
- `AGENTS.md:3`
- `tasks.md`, tasks 4.1 and 7.2
