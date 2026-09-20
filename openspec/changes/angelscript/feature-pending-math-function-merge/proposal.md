## Why

Archived `feature-host-api-fixtures` merged Pending/Math into `Unreal/<Type>`, but 30 Function parameter/return programs never became `@begin` cases. Those files still sit only under `Pending/Math`.

## What Changes

- Rewrite the leftover Function* programs from Pending/Math FVector, FVector2D, FTransform, FRotator, and FLinearColor into the existing Unreal type pockets.
- Project those FileTags and record the completed Math merge on `host-api-fixtures`.
- Prove `Unreal/FVector` version `function-parameters-in` is queryable.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/host-api-fixtures`: Pending/Math Function programs are admitted on the matching `Unreal/<Type>` FileTags.

## Impact

Parent repository: five Unreal math author files, CodeGenTool test, host-api-fixtures spec.
Plugin submodule: matching generated units, `HostApiFixtureCorpusTests`.

## Non-goals

A new `Math/` root. FQuat (already complete). Bindings leftovers. Language. World execution. Parser changes.

## Direct-origin assumption

Skipped brainstorming because the destination `Unreal/<Type>` and the no-`Math/`-root decision are already accepted on the archived host-api-fixtures Change. This Change only closes the leftover Function* gap.
