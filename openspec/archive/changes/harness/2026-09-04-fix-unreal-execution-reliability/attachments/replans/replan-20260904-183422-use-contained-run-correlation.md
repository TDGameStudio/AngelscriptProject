---
replan_id: replan-20260904-183422-use-contained-run-correlation
status: applied
source: evidence
source_ref: C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/Executors/ExecutorFactory.cs
scope: UBT ownership correlation, executor policy, process-discovery acceptance, and adjacent archive protocol repair
base_commit: f630171493d1e5d54279d100f16e488e5c15f7c8
base_tasks_sha256: 2d1aa5e4750bf63fffc05c89a7b16a4537684828b1e718b5909a56eda5927929
result_tasks_sha256: 67f68abf32b77de58427422fa4d00cf83f712f291f3bdf61f4a1cd6d328180bf
created_at: 2026-09-04T18:34:22.8213094+08:00
resume_task: "1.2"
---

# Use contained run correlation instead of recursive UBT Session

## Trigger and Evidence

The initial Task `1.1` assumed UE 5.8 would choose a non-UBA local executor after `-NoUBA`. Direct source inspection disproved that acceptance condition. `ExecutorFactory.GetExecutor()` falls through to `GetUBAExecutor()` whenever no remote executor is selected, and `GetUBAExecutor()` merely sets `Config.bAllowDetour = false` when `bAllowUBAExecutor` is false. `UBAExecutor` still requires `ITrace.GlobalTrace`, which top-level `UnrealBuildTool` suppresses whenever the command line contains `-Session=`.

The current project already sets `bAllowUBAExecutor=false` in its project-local UBT configuration, yet the archived low-action runs still failed in `UBAExecutor.Init`. Adding another `-NoUBA` therefore cannot fix the incompatibility. The user's XGE-capacity question also invalidates forcing XGE: local inspection finds a healthy licensed Incredibuild 10.32.2 Agent, but official Incredibuild behavior makes concurrent starts dependent on Multiple Builds configuration, licensed cores, minimum cores per build, and current load.

The Task `3.1` RED additionally found that the immediately preceding closure archive contains `attachments/scripts/Test-LegacyTestQuarantine.ps1` without the required exact INDEX entry. The protocol is correct to reject this; weakening archive validation is not acceptable.

## Decision

Remove UBT's recursive `-Session` option from every top-level Harness UBT request and preserve configured executor selection. Derive the Harness RunId from the exact execution `-Log` path already present on the command line, then recognize an active build only after all of the following match:

1. the log has the contained `Saved/Harness/Unreal/Runs/<RunId>/UBT.log` shape;
2. the mapped project resolves to the same physical workspace and project;
3. contained Request and metadata schemas, RunId, Build operation, and execution identity match;
4. metadata `nativePid` equals the inspected process;
5. the request contains exactly the same managed log argument and valid build/concurrency data.

Preserve Task `1.1` as completed rejected-path evidence and add Task `1.2` for the corrective TDD cycle. Repair the newly created archive index with one missing navigation entry during Task `3.1`; do not alter its substantive historical records.

## Impact

- Proposal, design, and the `harness/unreal` delta now specify Session-free top-level UBT and contained-log correlation.
- Task `1.2` owns Operations, Engine process correlation, and their focused tests; Task `3.1` now includes the adjacent archive index repair.
- The truthful synchronous-envelope work from Task `2.1` remains valid and complete.
- No Unreal Engine source, plugin code, public route name, input parameter, run schema, or aggregate profile changes.

## Old Task Disposition

Task `1.1` remains checked because its RED/GREEN cycle genuinely established the initial design and the later source proof that supersedes it. Its `-NoUBA` production change is reverted by Task `1.2`; its evidence is not reused as completion evidence for the new behavior.

## Diff Snapshot

- Affected tracked implementation at replan time: Harness dispatcher and tests, Unreal Operations and tests.
- Active record: proposal/design/spec/tasks/INDEX revised; one applied replan added.
- Task graph: Task `1.2` added after `1.1`; Task `3.1` now depends on `1.2` and `2.1`.
- Task state: `1.1` and `2.1` preserved complete; resume moves to new Task `1.2`.
- Archive protocol repair: one missing script INDEX entry, no substantive archive record rewrite.

## Preserved Work

The terminal-operation envelope mapping, its contained leaf fixture, all public route boundaries, executor raw-argument ownership, run evidence schemas, short execution mapping, and prior product-isolation commits remain unchanged.

## References and Result

- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/UnrealBuildTool.cs`
- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/Executors/ExecutorFactory.cs`
- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/Executors/UnrealBuildAccelerator/UBAExecutor.cs`
- `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Programs/UnrealBuildTool/Executors/XGE.cs`
- `openspec/archive/changes/angelscript/2026-09-04-refactor-legacy-runtime-tests-quarantine/attachments/implementation/issue-20260904-171616-ubt-session-uba-executor.md`

The updated Task DAG validates and resumes at Task `1.2`.
