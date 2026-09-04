## Why

The live Harness implementation, project configuration, and Unreal routes now target UE 5.8, PowerShell 7, the `Harness` identity, and an explicit-review lifecycle. Several project entry documents still describe UE 5.7, Windows PowerShell 5.1, Current/Goal repository modes, the retired Hardness name, mandatory Review cadence, or deleted root `Tools` wrappers. These contradictions can send an agent through unsupported entry points before it reaches the authoritative Skills.

## What Changes

- Establish one testable project-guidance contract across the Chinese and English agent instructions, root README, and live Harness/Unreal Skills.
- Describe UE 5.8 and PowerShell 7 as the current supported baseline.
- Make the selected Git workspace and Harness routes authoritative; Codex `/goal` remains continuation only, and root `Tools` PowerShell wrappers are not a fallback.
- Clarify that ordinary Harness calls run directly in the already-active PowerShell 7 process. A child `pwsh` process is reserved for intentional isolation, tests, hooks, or managed Unreal workers.
- Preserve explicit Review intake and remove stale automatic-review or required-worktree language.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Make the maintained project entry guidance consistent with the live Harness, PowerShell, workspace, Review, and UE contracts.

## Impact

The parent repository changes focused project guidance, live Skill guidance, one static regression gate, and the Harness core specification. It does not modify Unreal execution code, root `Tools` wrappers, the `Tools/openspec` source submodule, or unrelated documentation already being edited by the user.
