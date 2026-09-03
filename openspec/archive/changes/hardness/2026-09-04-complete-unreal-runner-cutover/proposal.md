## Why

Registered linked workspaces retain intentionally exact, often long, Git paths. UnrealBuildTool still passes several paths through Windows components that are not uniformly long-path safe, and historical runs have failed with `OtherCompilationError` when the same project succeeds from a short path. Moving registered worktrees is not a general solution because Git cannot move linked worktrees that contain submodules, and persisting aliases in `AgentConfig.ini` would weaken the exact workspace identity contract.

The repository also retains root `Tools` UE build/test wrappers after Hardness gained the maintained `ue.*` surface. They are no longer the maintained command surface, but broad deletion and reference cleanup are a separate migration concern rather than part of this focused path repair.

## What Changes

- Preserve the managed `AgentConfig.ini`, `WorkspaceRoot`, `ProjectFile`, Git common-directory identity, run evidence, and lease keys as true physical paths.
- Add a Windows-only, machine-local, stable transient DOS-device assignment for every Unreal workspace. The mapped drive is an execution view only and is never written into workspace configuration.
- Give Unreal Request/Run records stable schema names with physical and execution paths, explicit assignment/mapping state, and a `WaitingExecutionDrive` lifecycle state.
- Keep `PlanOnly` fully read-only while exposing the proposed or existing execution assignment.
- Route every workspace-local UBT/editor argument, log/report/output path, suite entry path, and child temporary directory through the execution view. EngineRoot remains physical and default UBA/XGE behavior remains unchanged.
- Correlate mapped UBT command lines back to physical workspace identity and clean up only exact mappings owned by Hardness; preserve matching foreign mappings.
- Align the engine `AngelscriptSmoke` group with the declarative Hardness Smoke suite.
- Exercise one real default-executor build through the short execution view without executor overrides, and verify one real Smoke run reaches a successful terminal state. Existing product compilation failures are recorded for later work rather than folded into this path-focused Change; broad root `Tools` deletion remains a separate focused cleanup.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `hardness/unreal`: Add transient short-path execution, stable run evidence, mapped process correlation, exact ownership cleanup, and focused acceptance gates.

## Impact

- Hardness Unreal PowerShell leaf, focused tests, public Unreal specification, and engine smoke configuration.
- A machine-local assignment registry under `%LOCALAPPDATA%/TDGameStudio/Hardness/Unreal/DriveAssignments.json`.
- Root UE runner deletion and consumer-reference cleanup remain separate from this focused short-path Change.
- No worktree move, Git identity alias, EngineRoot mapping, forced UBA/XGE disable, Documents migration, plugin runtime behavior change, commit, push, or worktree removal.
