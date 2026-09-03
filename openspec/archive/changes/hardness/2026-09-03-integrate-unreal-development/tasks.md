---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["1.2"]
    "3.1": ["2.1", "2.2"]
    "3.2": ["2.1", "2.2"]
    "3.3": ["3.2"]
    "3.4": ["3.1"]
    "4.1": ["3.3", "3.4"]
    "4.2": ["4.1"]
    "4.3": ["4.2"]
---

## 1. Contract and module boundary

- [x] 1.1 Capture the UE 5.8, legacy-runner, and multi-worktree evidence — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/openspec/bin/openspec.exe' validate 'hardness/integrate-unreal-development' --strict --json"`
  > Files: `openspec/changes/hardness/integrate-unreal-development/attachments/data/ue58-ubt-evidence.md`, `openspec/changes/hardness/integrate-unreal-development/attachments/knowledges/unreal-runner-migration.md`, `openspec/changes/hardness/integrate-unreal-development/attachments/INDEX.md`

  1. Record exact local UBT source evidence for mutexes, QueryTargets, installed/source detection, and bundled .NET.
  2. Record broken or unsafe behavior in the copied Skill runners without treating root Tools as live inputs.
  3. Keep the retained evidence concise and English-only.

- [x] 1.2 Establish the PS7 module, data schemas, and hermetic test fixture — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Foundation`
  > Files: `.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1`, `.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psm1`, `.agents/skills/unreal-engine-develop/scripts/Private/Common.ps1`, `.agents/skills/unreal-engine-develop/data/ubt-capabilities.json`, `.agents/skills/unreal-engine-develop/data/launch-profiles.json`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Add failing module/data/config tests first.
  2. Implement strict PS7 loading, contained path helpers, JSON I/O, configuration projection, and safe argument validation.
  3. Build fake workspace/engine fixtures without depending on root Tools or a real UE run.

## 2. Engine and run foundations

- [x] 2.1 Implement engine, target, process, capability, and concurrency discovery — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Discovery`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Concurrency.ps1`, `.agents/skills/unreal-engine-develop/data/ubt-capabilities.json`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Resolve configured and registered engine installations without mutation.
  2. Discover bundled .NET and UBT dynamically and list source targets quickly.
  3. Establish the initial conservative serialized UBT policy; Task 3.4 supersedes its installed-build concurrency decision while preserving source/generic UBT serialization.

- [x] 2.2 Implement the contained worker, lifecycle, timeout, status, and explicit cancellation — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag RunLifecycle`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Run.ps1`, `.agents/skills/unreal-engine-develop/scripts/Invoke-UnrealRunWorker.ps1`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Test request containment and legal state transitions before implementation.
  2. Launch hidden PS7 workers and native children with `ArgumentList` and isolated environment.
  3. Verify timeout cleanup, orphan inference, explicit PID-safe cancellation, and lease release.

## 3. Unreal operations

- [x] 3.1 Implement generic UBT and build planning/execution — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Build`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Concurrency.ps1`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Normalize configured defaults and explicit target/configuration inputs.
  2. Prohibit UniqueBuildEnvironment and destructive clean requests.
  3. Verify the initial serialized plans for installed and source engines, including installed-only NoEngineChanges, then exercise a fake native process; Task 3.4 replaces the installed-build plan.

- [x] 3.2 Implement Automation, commandlet, and structured report handling — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Automation`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/AutomationReport.ps1`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Preserve exact prefix/group and commandlet argument boundaries.
  2. Enforce crash-only isolation and default NullRHI behavior.
  3. Parse representative UE report JSON, bounded log hints, and zero-exit/missing-report failure.

- [x] 3.3 Replace executable suite scripts with declarative planning and sequential execution — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag Suites`
  > Files: `.agents/skills/unreal-engine-develop/data/suites.json`, `.agents/skills/unreal-engine-develop/scripts/Private/Suites.ps1`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Preserve current Unreal Automation coverage while excluding deferred external pipelines explicitly.
  2. Return stable plans without launching UE.
  3. Run entries sequentially under one workspace lease and aggregate results.

- [x] 3.4 Restore controlled cross-worktree builds and observable progress — verify: `pwsh.exe -NoProfile -File .agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1 -Tag ConcurrencyProgress`
  > Files: `.agents/skills/unreal-engine-develop/scripts/Private/Concurrency.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Operations.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Engine.ps1`, `.agents/skills/unreal-engine-develop/scripts/Private/Run.ps1`, `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`

  1. Add Hardness-owned Auto, Parallel, and Serialize build modes: ordinary installed-engine project builds may use `-NoMutex -NoEngineChanges` across distinct workspaces, while source/unknown engines, QueryTargets, and generic UBT remain serialized.
  2. Keep same-workspace execution exclusive, coordinate Hardness parallel/exclusive engine lanes, isolate temp/log paths, and fail closed on detected shared-engine UHT timestamp contention.
  3. List active UBT builds with workspace/target/concurrency identity and return bounded structured progress from recognized run-local logs; report unknown progress explicitly.

## 4. Hardness integration and closure

- [x] 4.1 Publish `ue.*` routes and retire copied entry scripts — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/hardness/tests/Hardness.Tests.ps1'; if (-not $?) { exit 1 }; & '.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1' -Tag Integration"`
  > Files: `.agents/skills/hardness/scripts/Hardness.psm1`, `.agents/skills/hardness/tests/Hardness.Tests.ps1`, `.agents/skills/hardness/SKILL.md`, `.agents/skills/unreal-engine-develop/SKILL.md`, `.agents/skills/unreal-engine-develop/references/concurrency.md`, `.agents/skills/unreal-engine-develop/references/migration.md`, `.agents/skills/unreal-engine-develop/scripts/Run*.ps1`, `.agents/skills/unreal-engine-develop/scripts/Get-*.ps1`, `.agents/skills/unreal-engine-develop/scripts/Shared/*`, `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psm1`, `.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Tests.ps1`, `.agents/skills/README.md`, `AGENTS.md`

  1. Add context defaults and lazy leaf routes without importing Unreal during unrelated commands.
  2. Reject the obsolete Hazelight key in configuration status and retain exact-root execution guards.
  3. Remove duplicate copied implementations and document root Tools as unused deletion candidates.

- [x] 4.2 Pass the complete PS7 gate and retain timing evidence — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1'; if (-not $?) { exit 1 }; & '.agents/skills/hardness/scripts/Test-Hardness.ps1' -Profile Quick"`
  > Files: `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1`, `.agents/skills/unreal-engine-develop/tests/Measure-UnrealEngineDevelop.ps1`, `openspec/changes/hardness/integrate-unreal-development/attachments/data/workflow-evaluation.md`, `openspec/changes/hardness/integrate-unreal-development/attachments/INDEX.md`

  1. Run module, protocol, and Hardness route tests under PowerShell 7 only.
  2. Measure module import, status, target/process scan, suite plan, build PlanOnly, and run-progress parsing with warmups and retained raw hashes.
  3. Run actual-workspace read-only status and plan commands without starting a product build or suite.

- [x] 4.3 Synchronize durable specifications and prove direct completed closure readiness — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/openspec/bin/openspec.exe' validate 'hardness/integrate-unreal-development' --strict --json; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; & '.agents/skills/openspec/bin/openspec.exe' validate --specs --strict --json; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; & '.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1' -Tag Integration"`
  > Files: `openspec/specs/hardness/unreal/spec.md`, `openspec/specs/hardness/unreal/spec.yaml`, `openspec/specs/hardness/core/spec.md`, `openspec/specs/hardness/workspace/spec.md`, `openspec/changes/hardness/integrate-unreal-development/tasks.md`, `openspec/changes/hardness/integrate-unreal-development/attachments/INDEX.md`

  1. Merge durable deltas into current specifications and create the capability manifest through the CLI.
  2. Confirm no unresolved material issue or explicitly requested Review exists.
  3. Validate active and current records, then close and archive directly without automatic Final Review.
