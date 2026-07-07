## Why

`Tools\RunBuild.ps1` currently assumes a precompiled UnrealBuildTool DLL exists under the configured engine root. Source-layout engines can instead provide UnrealBuildTool source and rely on the engine build entry to generate or compile UBT before the project target builds.

This change plans first-class source-layout engine support so agents and maintainers can keep using the project build runner instead of manually falling back to engine batch commands.

## What Changes

- Add source-layout engine detection to the build runner path resolution.
- Route source-layout engines through a dedicated PowerShell-controlled build path while keeping `Tools\RunBuild.ps1` as the public build entry.
- Preserve existing precompiled-engine behavior for engines that already provide `UnrealBuildTool.dll`.
- Keep timeout handling, live log streaming, process-tree cleanup, per-run logs, and metadata output consistent across both engine layouts.
- Update build documentation to describe source-layout behavior without requiring local machine paths.

## Capabilities

### New Capabilities

- `runbuild-source-engine-support`: Allows the standard project build runner to handle source-layout Unreal Engine roots that do not initially contain a precompiled UnrealBuildTool DLL.

### Modified Capabilities

- None.

## Impact

- Build runner: `Tools\RunBuild.ps1`.
- Shared command utilities: `Tools\Shared\UnrealCommandUtils.ps1`.
- Build documentation: `Documents\Guides\Build.md`.
- Tooling tests or dry-run validation scripts under `Tools\Diagnostics\tests\` or an equivalent existing tooling-test location.
- Local configuration remains `AgentConfig.ini`; no local engine path is committed.
