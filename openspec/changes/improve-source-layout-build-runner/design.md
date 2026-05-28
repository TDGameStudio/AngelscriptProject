## Context

The current build runner resolves UnrealBuildTool by looking for `Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll` under `AgentConfig.ini` `Paths.EngineRoot`. That is correct for installed or already-precompiled engine layouts, but fails early for source-layout engines where `Engine\Source\Programs\UnrealBuildTool\UnrealBuildTool.csproj` exists and the DLL has not been generated yet.

The recent source-layout build was successful only after bypassing the project runner and using the engine batch entry directly. That proves the engine root is valid, but the project runner is missing a source-layout bootstrap branch.

## Goals / Non-Goals

**Goals:**

- Keep `Tools\RunBuild.ps1` as the single public build entry for agents and maintainers.
- Detect whether the configured engine root is precompiled-layout or source-layout before launching the build.
- For precompiled-layout engines, keep the existing direct UBT execution path unchanged.
- For source-layout engines, use a dedicated PowerShell-controlled path that can bootstrap UBT and then build the configured project target.
- Treat source-layout bootstrap/build as an engine-output-writing operation and serialize it by engine root.
- Preserve timeout budgets, live logs, cleanup, per-run log directories, final exit codes, and metadata shape.
- Document the behavior in `Documents\Guides\Build.md` without writing machine-local paths.

**Non-Goals:**

- Do not replace `Tools\RunBuild.ps1` with direct daily `Build.bat` instructions.
- Do not require `-UniqueBuildEnvironment`.
- Do not commit `AgentConfig.ini` or any local engine path.
- Do not attempt a full engine rebuild beyond what the selected editor target requires.
- Do not change test runner behavior in this change.

## Decisions

### Keep one public build entry

The public entry should remain `Tools\RunBuild.ps1`. The source-layout path may be implemented as helper functions or an internal script, but normal instructions should continue to send users and agents through the same runner. This keeps worktree locking, labels, timeout rules, and log layout centralized.

### Classify engine layout before constructing arguments

The runner should classify the engine root into three states:

```text
precompiled-layout: UnrealBuildTool.dll exists
source-layout: UnrealBuildTool.csproj exists and UnrealBuildTool.dll is missing
invalid-layout: neither usable UBT artifact nor source project exists
```

The invalid state should fail as a configuration error with an actionable message.

### Source-layout builds serialize by engine root

A source-layout build can generate UBT and write engine-side build products before or during project compilation. The runner should acquire the engine-level mutex for source-layout mode even if the user does not explicitly pass `-SerializeByEngine`. This avoids two worktrees racing to generate the same engine-side outputs.

### Preserve current precompiled fast path

Installed/precompiled engines should continue using direct `dotnet UnrealBuildTool.dll` invocation with `-NoMutex`, private `-Log=`, and `-NoEngineChanges` when not serialized. This avoids regressing the existing concurrent worktree behavior.

### Use source-layout adapter only for source-layout engines

The source-layout branch should be narrow. It should use the engine-supported bootstrap/build mechanism from PowerShell, stream output into the same `Build.log`, capture metadata, and keep final exit code semantics aligned with existing runner behavior.

The source-layout adapter should not leak a direct engine batch command into regular user instructions. It is an implementation detail behind `Tools\RunBuild.ps1`.

## Planned Runtime Shape

```text
AgentConfig.ini
  -> Tools\RunBuild.ps1
    -> Resolve-AgentConfiguration
    -> Resolve engine build layout
      -> precompiled-layout
        -> existing direct UBT path
      -> source-layout
        -> acquire engine mutex
        -> source-layout adapter bootstraps UBT/project target
      -> invalid-layout
        -> config error
    -> shared logging / metadata / timeout / cleanup
```

## Risks / Trade-offs

- Source-layout mode can be slower on first run because it may build UBT and target-dependent engine artifacts.
- Automatically serializing source-layout mode reduces parallelism but prevents shared engine output races.
- The engine batch path can produce different log phrasing than direct UBT; metadata should record the selected mode so failures remain diagnosable.
- Mock validation should cover layout detection without requiring an actual engine checkout; one real validation run can be done manually on a source-layout engine when available.

## Open Questions

- Should the source-layout adapter be an internal helper inside `Tools\Shared\UnrealCommandUtils.ps1`, or a separate internal script called only by `Tools\RunBuild.ps1`?
- Should source-layout mode expose an explicit opt-out switch for automatic engine serialization, or should serialization remain mandatory for safety?