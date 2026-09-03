## Context

Hardness now identifies one exact registered Git workspace and rejects cross-workspace execution, but Unreal commands remain outside the router. The current Unreal Skill is a collection of copied scripts totaling more than 150 KB. Several paths launch `powershell.exe`, command arguments are manually quoted, suite definitions execute PowerShell data, test reporting depends on a missing file, and `ExecutionSlot` permits multiple editors to share one worktree's project outputs. UE 5.8 supplies its own .NET runtime and UBT mutex model, so fixed SDK paths and caller-controlled `-NoMutex` are not reliable contracts even though a Hardness-managed installed-project parallel lane remains useful.

## Goals / Non-Goals

**Goals:**

- Expose one cohesive PS7-only Unreal leaf behind Hardness.
- Keep every external command bound to one verified workspace and one explicit timeout.
- Make concurrency conservative, explainable, and safe across registered worktrees.
- Preserve argument boundaries and machine-readable run evidence.
- Support quick read-only planning and diagnostics without starting UE.
- Expose active build identity and bounded progress without requiring an agent to consume long logs.
- Retain current Unreal Automation suite intent in declarative data and restore structured report parsing.

**Non-Goals:**

- Delete or repair the root `Tools` tree in this Change.
- Implement package, Standalone CMake/CTest, Cache package, StaticJIT, coverage, or release pipelines.
- Guarantee concurrent modification of one source-engine checkout.
- Create a daemon, shared database, global active workspace, or implicit background scheduler.
- Run a complete UE Automation suite while the product repository is undergoing its separate refactor.
- Support Windows PowerShell 5.1.

## Decisions

### One leaf module and declarative data

`UnrealEngineDevelop.psd1` is the only public Skill module. Its root module loads small private function files for common validation, engine discovery, concurrency, run lifecycle, native operations, Automation reporting, and suites. Hardness publishes the leaf functions as `ue.*` routes. Suite definitions, launch profiles, and audited UBT capabilities are tracked JSON, never dot-sourced executable configuration.

The old script entry points are removed rather than maintained as a second implementation. `Invoke-UnrealRunWorker.ps1` remains a narrow internal process boundary for asynchronous and cancellable execution; it imports the same module and accepts only a generated request file contained in the selected run directory.

### Exact workspace and configuration boundary

Every mutating or process-launching function calls `Assert-HardnessWorkspaceExecution` before resolving engine paths. The selected workspace's managed `Paths.ProjectFile` must equal its sole root `.uproject`. `Paths.EngineRoot` and optional Build/Test settings remain machine-local values in ignored `AgentConfig.ini`; Git topology, branch, HEAD, and active run state are never persisted there. A stale Hazelight reference is rejected and removed by explicit bootstrap.

### Request, worker, and run evidence

An operation first validates and normalizes a request, selects a concurrency decision, and writes `Request.json` plus initial `RunMetadata.json` beneath `Saved/Hardness/Unreal/Runs/<run-id>/`. `-PlanOnly` returns that normalized plan without launching. A real run starts one hidden `pwsh.exe` worker by `ProcessStartInfo.ArgumentList`; synchronous calls wait for it, while `-NoWait` returns the run identity immediately.

The worker owns leases and native process lifetime. States are `Queued`, `WaitingWorkspace`, `WaitingEngine`, `Running`, and terminal `Succeeded`, `Failed`, `TimedOut`, or `Cancelled`. Status may infer `Orphaned` when recorded non-terminal PIDs no longer exist, without silently relaunching work. Build status derives a bounded progress snapshot from the private UBT/stdout logs and reports unknown progress explicitly. Request, metadata, command log, optional Automation report, and summary are sufficient to reproduce the selected command but are ignored local evidence rather than repository state.

### Workspace exclusivity and managed engine lanes

Every operation takes one workspace mutex for its whole lifetime. `Auto` and `Wait` wait within the total timeout; `Fail` rejects an occupied workspace immediately. Same-workspace parallel test slots are removed because they still share `Intermediate`, `Saved`, DerivedDataCache selection, generated code, and the `.uproject`.

Engine concurrency is selected from operation kind, engine layout, and an explicit `Auto | Parallel | Serialize` build mode:

- `Auto` selects the controlled parallel lane only for an ordinary installed-engine project build. That lane uses Hardness-managed `-NoMutex -NoEngineChanges`, run-local temp/log paths, and a shared engine lane so distinct workspaces may build concurrently while a Hardness exclusive operation cannot overlap.
- `Parallel` is an explicit spelling of that installed-project lane and is rejected for source/unknown engines, QueryTargets, generic UBT, destructive modes, or engine-write-capable requests. Raw `-NoMutex`, `-WaitMutex`, and `-NoEngineChanges` arguments remain reserved because Hardness owns their consistent combination; `-NoMutex` is not classified as inherently dangerous.
- `Serialize` and every source/unknown-engine build, QueryTargets request, or generic UBT invocation take the exclusive Hardness engine lane keyed by canonical EngineRoot and pass UBT `-WaitMutex`. This also coordinates with external UBT processes that retain the same assembly-level mutex.
- Tests and commandlets may overlap only across distinct workspaces because they do not invoke UBT and their project/run outputs are isolated. Each still holds its own workspace lease.
- Distinct EngineRoots naturally use distinct engine lanes. `Auto | Wait | Fail` continues to control acquisition behavior within the total timeout rather than selecting the build mode.

The decision and reason are stored in run metadata. Direct bundled-dotnet invocation avoids `Build.bat`'s additional lock loop. Child-only per-run temp paths and an explicit UBT log avoid the shared defaults. Because `-NoEngineChanges` does not cover every UHT timestamp write, a detected shared-engine UHT timestamp conflict promotes the run to failure and points to `Serialize` or a dedicated EngineRoot.

### Engine and UBT resolution

The leaf resolves the configured engine first and may enumerate Epic Launcher and UnrealVersionSelector registrations read-only. It detects installed versus source layout from engine markers and `Build.version`. The bundled host is discovered below `Engine/Binaries/ThirdParty/DotNet` by architecture and executable presence rather than a version literal. UBT uses `Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll`; the process receives an isolated child environment and never rewrites the parent process environment.

Target listing defaults to a fast scan of project `*.Target.cs` declarations. An explicit UBT query may use QueryTargets under serialized engine policy. Generic UBT invocation is supported for deliberate advanced use, but it is always classified conservatively and blocks prohibited `UniqueBuildEnvironment` and destructive clean modes in this Change. Process discovery identifies active UBT builds machine-wide, associates recognizable workspace/target/concurrency fields, and attaches progress only when an accessible explicit log can be correlated.

### Suites and Automation truth

Tracked suites contain only Unreal Automation entries in this Change. Planning returns normalized entries, tiers, launch profile, total timeout, and execution order. Suite execution is sequential within the single workspace lease. Parallel agents can obtain throughput by using different registered worktrees rather than corrupting one worktree.

The embedded report parser prefers UE JSON reports, normalizes pass/fail/skip states, records failed tests and bounded log hints, and treats a zero editor exit without a structured summary as failure unless the caller explicitly disables report enforcement.

## Risks / Trade-offs

- Controlled installed-project parallelism preserves multi-worktree throughput but is not proof of complete engine immutability. Per-run temp/log isolation, Hardness shared/exclusive lanes, `-NoEngineChanges`, and UHT timestamp conflict promotion bound known failure modes; source engines and uncertain requests remain serialized.
- Process cancellation is inherently platform-specific. It is explicit, validates the recorded worker identity and contained run path, and stops descendants before the worker.
- Registry formats and bundled .NET directory names can change. Discovery is best-effort and the configured engine remains authoritative.
- A hermetic fake-engine integration test validates process, timeout, report, and state mechanics. Real UE validation in this Change is limited to read-only status and command planning so the unrelated product refactor is not treated as a tooling failure.
