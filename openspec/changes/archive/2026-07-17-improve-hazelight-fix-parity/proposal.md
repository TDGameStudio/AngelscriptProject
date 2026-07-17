## Why

The previous Hazelight audit used a recent-commit preview and recorded `472bb2fab5a0` only in the human-readable trial log. The machine checkpoint remained empty, so the review did not establish a reliable incremental boundary. A complete review is needed before adopting fixes from the current Hazelight head.

## What Changes

- Add a complete, path-scoped Hazelight audit mode that walks all Angelscript-related commits after a known marker without relying on Unreal Engine's repository-wide compare limit.
- Record every reviewed commit in a reusable OpenSpec inventory with local mapping, classification, and next action.
- Adopt five low-risk plugin fixes: `FString::TrimQuotes`, immediate `UObjectTickable` tick shutdown, `CreateWidget` output-type metadata, `FLatentActionInfo` constructor registration, and EnhancedInput `GetHandle` nativization.
- Keep behavior-changing, engine-side, GAS, StaticJIT architecture, and broader UE-follow updates recorded but deferred for separate decisions.
- Update the Hazelight audit checkpoint only after the full range is reviewed and verified.

## Capabilities

### New Capabilities

- `as-hazelight-fix-parity`: Complete path-scoped upstream audit records and staged adoption of compatible Hazelight fixes.

### Modified Capabilities

None.

## Impact

- Audit tooling: `.agents/skills/hazelight-update-audit/scripts/Get-HazelightUpdateAudit.ps1` and its usage documentation.
- OpenSpec records: complete upstream inventory, design decisions, implementation tasks, and verification evidence.
- Plugin runtime and test modules under `Plugins/Angelscript`.
- Audit checkpoint and human-readable log under `.agents/skills/hazelight-update-audit/references/`.
- No direct modification to Unreal Engine source, GAS behavior, or unrelated parent-workspace changes.
