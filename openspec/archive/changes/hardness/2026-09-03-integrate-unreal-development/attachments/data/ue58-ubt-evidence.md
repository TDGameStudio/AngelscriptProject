---
record_id: ue58-ubt-evidence
status: accepted
source: local-ue58-and-repository-audit
created_at: 2026-09-03T18:26:00+08:00
supports_task: "1.1"
---

# UE 5.8 and Existing Runner Evidence

## Audited baseline

- The configured local engine reports UE `5.8.0`, changelist `55116800`, branch `++UE5+Release-5.8`.
- `Engine/Build/InstalledBuild.txt` exists. UBT itself uses only this marker to classify an installed engine (`Unreal.cs:257-258`); an installed distribution may still include UBT source.
- `UnrealBuildTool.runtimeconfig.json` targets `net10.0` and `Microsoft.NETCore.App 10.0.0`. The bundled SDK is `10.0.203`, while the existing Skill hard-codes `8.0.412` and therefore falls back to machine PATH.
- The existing Skill contains 15 PowerShell scripts and about 5,010 lines, no module manifest, no Skill-local test suite, and 24 `powershell.exe` references.
- `RunTests.ps1` calls a missing Skill-local `GetAutomationReportSummary.ps1`; the root Tools copy is already a deletion candidate. Report-enabled tests therefore have a deterministic post-run failure.

No legacy runner was executed, no product build/test was started, and no Tools loop content was inspected.

## UBT locking and shared state

- `GlobalOptions.cs:69-76` defines `-NoMutex` and `-WaitMutex`.
- `UnrealBuildTool.cs:441-448` shows the SingleInstance lock is skipped whenever NoMutex is true and otherwise keyed by the executing UBT assembly path; WaitMutex chooses waiting rather than immediate conflict.
- `GlobalSingleInstanceMutex.cs:22-26,41-47` constructs the global name from an uppercase path hash and reports a conflicting instance when it cannot acquire immediately. `UnrealEngineTypes.cs:74-77` maps that conflict to exit code 10.
- `BuildMode.cs:48-52` and `QueryTargetsMode.cs:17-20` both declare SingleInstance.
- `QueryTargetsMode.cs:81-95`, `RulesCompiler.cs:70-100,289-302,419-427`, and `WriteMetadataMode.cs:63-71` show additional engine/project/plugin/metadata locks. These protect specific writes but do not make arbitrary NoMutex execution safe.
- Installed UBT maps writable engine state to a shared user directory (`Unreal.cs:204-214`). C++ dependency and file-hash caches mount paths there (`CppDependencyCache.cs:419-485`, `FileHashCache.cs:59-94`) and rewrite files without a cross-process merge (`CppDependencyCache.cs:135-151`, `FileHashCache.cs:187-231`). `BuildMode.cs:288-303` saves those caches after a build.
- `UnrealBuildTool.cs:398-427` derives a shared default temp directory from the UBT DLL. Each run must instead receive child-only `UnrealBuildTool_TMP`, `TMP`, and `TEMP` beneath its run directory.
- `BuildMode.cs:727-744` explicitly permits new engine files under NoEngineChanges while rejecting changes to existing produced files. `UnrealEngineTypes.cs:49-52` maps this failure to exit code 5.
- `Build.bat:14-35` adds a separate lockfile loop. Direct bundled dotnet plus UBT avoids that extra process and makes process ownership observable.

## Invocation contract

Hardness owns the mutex combination rather than accepting raw overrides. Ordinary installed-engine project builds use the controlled `Auto`/`Parallel` lane with `-NoMutex -NoEngineChanges`; source/unknown builds, QueryTargets, and generic UBT use the exclusive engine lane with `-WaitMutex`. Every UBT run supplies `-Log=<run>/UBT.log`, `-Session=<run-id>`, and run-local child temp variables. The working directory is `Engine/Source`.

The copied runner and retained Build guide prove that distinct-worktree installed builds previously used `-NoMutex -NoEngineChanges` successfully enough to be the default, while also recording a real shared-engine UHT `Timestamp` contention signature. The maintained lane therefore preserves that throughput but promotes the known signature to failure and offers `Serialize` or a dedicated EngineRoot when engine-side writes are required. The shared/exclusive Hardness lane coordinates maintained callers; external processes that bypass both Hardness and UBT mutexes remain observable rather than controllable.

`GetDotnetPath.bat:24-34` supplies the child-environment precedent: bundled DOTNET_ROOT, PATH prefix, `DOTNET_MULTILEVEL_LOOKUP=0`, and `DOTNET_ROLL_FORWARD=LatestMajor`. The parent PowerShell environment is never modified.

QueryTargets uses a run-local output path rather than the default project `Intermediate/TargetInfo.json`. `QueryTargetsMode.cs:24-52,105-108,121-150,190-221` shows supported arguments, output shape, and partial-result warnings. Returned relative target paths must be resolved and boundary-checked; warnings about target-rule construction make the result partial.

`-SkipBuild`, `-WriteOutdatedActions`, `-TargetList`, and partial action filters are not read-only planning primitives. The first two can still write metadata or delete produced items, and TargetList carries executable command lines. PlanOnly is therefore implemented entirely in Hardness without launching UBT.

## Existing Skill gaps to close

1. Replace script-root-derived workspace selection with an explicit Hardness WorkspaceRoot and the existing execution guard.
2. Replace manual quoting, Start-Process, parent environment edits, and repeated whole-log reads with ProcessStartInfo.ArgumentList, child-only environment, and streamed output.
3. Remove ExecutionSlot; it bypasses the workspace lease while sharing Intermediate, Saved, and generated state.
4. Replace executable suite/timing tables and whole Saved-history scans with tracked JSON and direct run identities.
5. Add atomic run state, status, timeout, cancellation, orphan inference, and a local Automation report parser.
6. Parse bounded `-Progress`/action evidence so process and run status expose known progress without scanning whole logs.
6. Keep Package, Standalone, Cache-package, StaticJIT, coverage, and release workflows explicitly unavailable until separate migrations; never fall back to Tools.
