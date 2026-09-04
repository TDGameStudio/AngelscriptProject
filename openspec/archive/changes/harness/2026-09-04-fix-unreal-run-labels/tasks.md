---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

## 1. Run label contract

- [x] 1.1 Restore caller-defined labels across single-operation Unreal routes and observations — verify: `& ./.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag RunLabels`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Run.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  > Produces: Optional public labels for build, generic UBT, test, and commandlet plans/runs; stable defaults; bounded validation; status and recognized-build projections; unchanged RunId-only paths and native arguments.

  1. Add a focused `RunLabels` fixture that exercises all four route plans, defaulting, Unicode/whitespace normalization, invalid values, persisted status, and recognized-build output, then observe the expected missing-parameter/property RED.
  2. Add the smallest shared normalization and projection changes without placing labels in paths, arguments, locks, or correlation identity.
  3. Rerun the exact focused fixture and keep all assertions green.

  Evidence: The focused fixture first failed because `ue.build` had no `Label` parameter, then failed at the remaining route boundary, then at the missing status/process projection, and finally showed that historical metadata fell back to `Test` instead of the request label. After the bounded implementation, the exact command passed with caller labels on all four routes, existing defaults, trimmed Unicode, invalid-label rejection without run creation, RunId-only paths, argument isolation, persisted request/metadata equality, historical fallback, and trusted process observation.

## 2. Durable contract and completion

- [x] 2.1 Synchronize the run-label behavior and verify the affected Harness boundary — verify: `& ./.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Integration`
  > Files: `openspec/specs/harness/unreal/spec.md`, `openspec/changes/harness/fix-unreal-run-labels/specs/harness/unreal/spec.md`, `openspec/changes/harness/fix-unreal-run-labels/tasks.md`, `openspec/changes/harness/fix-unreal-run-labels/attachments/INDEX.md`, `openspec/changes/harness/fix-unreal-run-labels/attachments/data/workflow-evaluation.md`

  > Context: The focused fixture is the implementation proof; the existing Harness integration fixture proves route dispatch remains compatible after the new optional parameter.

  1. Merge the complete modified Requirement and new Scenario Cards into the current `harness/unreal` specification without dropping existing scenarios.
  2. Run the focused fixture, the direct Integration tag, Protocol tests, doctor, Task DAG validation, and strict Change/current-spec validation.
  3. Record the impact-scoped evidence and exclusions, produce the final workflow evaluation, and pass the exact terminal evolution gate.

  Evidence: The complete modified `Per-run lifecycle and evidence` Requirement was semantically merged into the current `harness/unreal` specification with every existing scenario preserved and three detailed run-label cards appended. The exact Integration tag and Protocol tests passed. OpenSpec doctor reported zero errors; strict exact-Change and `harness/unreal` validation passed; all seven current specifications passed strict validation. The focused RunLabels fixture was rerun as the direct implementation proof. Broader Quick, Performance, full Integration profile, UE build, and Automation execution were intentionally omitted because labels are metadata-only, native argument arrays and RunId paths are directly asserted unchanged, and no plugin, executor, performance, or product behavior changed.
