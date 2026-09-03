## Why

The project currently has a copied set of large script entry points under `unreal-engine-develop` plus legacy counterparts under `Tools`. The copies still launch Windows PowerShell 5.1, contain a hard-coded .NET 8 path that does not describe the local UE 5.8 installation, emulate same-workspace parallelism with execution slots, and do not share Hardness workspace identity. The default test path also calls a report helper that is absent from the Skill package. This makes multi-worktree execution difficult to reason about and leaves the advertised test surface incomplete.

## What Changes

- Replace the copied script collection with one PowerShell 7 leaf module whose public functions are routed through Hardness.
- Add read-only engine, target, UBT capability, active-process, build-progress, suite, run, and status discovery.
- Add exact-root build, automation-test, commandlet, generic UBT, suite-plan, suite-run, run-status, and explicit run-cancel operations.
- Validate the selected Git workspace and its ignored `AgentConfig.ini` before any external process starts.
- Resolve the engine-bundled .NET host dynamically, keep argument boundaries through `ProcessStartInfo.ArgumentList`, and record the selected UBT concurrency policy.
- Replace same-workspace execution slots with one workspace lease, restore controlled ordinary installed-engine build overlap across distinct workspaces, and serialize source/unknown-engine, QueryTargets, and generic UBT work.
- Store bounded per-run request, state, command log, report, and summary evidence under `Saved/Hardness/Unreal/Runs/<run-id>/`.
- Move Unreal Automation report parsing and suite definitions into the Skill, using tracked declarative JSON rather than executable suite data.
- Keep root `Tools` PowerShell entries as unused deletion candidates; do not edit or execute them. `Tools/openspec` remains the source-submodule exception.

## Capabilities

### New Capabilities

- `hardness/unreal`: Workspace-safe Unreal Engine discovery, UBT/build/test/commandlet execution, suite planning, concurrency, and run evidence.

### Modified Capabilities

- `hardness/core`: Publish the verified `ue.*` leaf routes through the lightweight dispatcher.
- `hardness/workspace`: Make stale Hazelight configuration invalid and retain exact execution guarding for the Unreal leaf.

## Impact

This is a parent-repository tooling change under `.agents/skills`, `openspec`, and project-local Hardness configuration policy. It does not change an Unreal plugin submodule, plugin runtime code, `Tools/openspec`, product build output, or a public C++/AngelScript API. Existing root `Tools` scripts remain untouched and are no longer an accepted runtime dependency.
