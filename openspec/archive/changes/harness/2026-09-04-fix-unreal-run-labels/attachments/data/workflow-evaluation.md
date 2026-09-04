---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-unreal-run-labels
closure_kind: completed
input_sha256: bd2baa128f840448237f23c1c195733c2bdede57409cb6b85ac15754f10adbff
captured_at: 2026-09-04T21:33:46+08:00
---

# Workflow evaluation

## Lifecycle

- The clear legacy-migration defect skipped deep Explore and entered one focused Harness Change in the selected primary workspace.
- Proposal, durable delta, design, Ready Task DAG, and attachment index were created and strictly validated before implementation.
- Task `1.1` completed four focused TDD cycles: missing build parameter, missing remaining route parameters and validation, missing status/process projection, and missing historical metadata fallback.
- Task `2.1` synchronized the complete modified Requirement into current `harness/unreal` behavior and ran the completion checks.

## Material friction and corrective action

No material implementation issue, Review, or Replan was required. Each failing fixture identified the next local contract boundary, and the repair remained within the accepted task files and behavior. The separate user-reported Scenario authoring-priority issue is intentionally not bundled into this Change and will use its own Harness Change.

## Verification

- `UnrealEngineDevelop.Tests.ps1 -Tag RunLabels`: passed after exercising all four public routes, defaults, trimmed Unicode labels, 128-code-unit and control-character rejection, no invalid-run creation, RunId-only paths, native-argument isolation, request/metadata persistence, status, historical fallback, and recognized-build observation.
- `UnrealEngineDevelop.Tests.ps1 -Tag Integration`: passed.
- `Protocol.Tests.ps1`: passed.
- OpenSpec doctor: valid with zero errors.
- Strict exact Change validation: passed.
- Strict `harness/unreal` validation: passed.
- Strict all-current-spec validation: 7/7 passed.

## Synchronization and ownership

The modified `Per-run lifecycle and evidence` Requirement and its three complete Scenario Cards were merged into `openspec/specs/harness/unreal/spec.md`. No plugin, submodule, UBT executable, suite catalog, schema name, or run-directory layout changed.

## Exclusions

Harness Quick, Performance, the aggregate Integration profile, real UE builds, UE Automation, and plugin/Standalone tests were intentionally omitted. The change is display metadata only; the focused real-module fixture directly proves that labels cannot affect native arguments, RunIds, run paths, leases, or process correlation, while the direct Integration tag proves Harness route compatibility. No product, performance, release, or executor behavior changed.

## Raw-data provenance

Focused command output was observed directly in the current PowerShell 7 session. Temporary fixture workspaces and ignored `Saved/Harness` run evidence were not promoted because the durable task evidence records the exact commands and observable results without machine-local paths.
