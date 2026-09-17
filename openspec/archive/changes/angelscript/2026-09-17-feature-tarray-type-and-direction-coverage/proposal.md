## Why

The archived Change `angelscript/feature-container-type-directories` rewrote TArray into observation files, but each admitted leaf is almost always one `TArray<int32>` local walk. `AddAndOrder.as` is the cited hole: `TestSource-old/Containers/TArray/Function/TArrayAddAndOrder.as` already had Observe plus `const&in` / `&out` / `&inout` for `int`, `float`, `bool`, `FString`, `FVector`, and `UObject` (24 UFUNCTIONs). Current `AngelscriptTestCode/Containers/TArray/**` has no `&in`, `&out`, `&inout`, `FString`, `FVector`, or typed Add siblings.

This is a Direct-origin Change. Brainstorming was skipped because the user named the comparison corpus (`TestSource-old/Containers/TArray`), the omitted axes (element types and UFUNCTION directions), and TArray-only scope. Packing stays the accepted one-observation-per-file identity. Assumption: no remaining user-owned product choice.

## What Changes

- Hand-author new TArray observation leaves that port the TestSource-old Function type-axis and direction cases.
- Keep existing int32 observe files. Split each old multi-UFUNCTION file into parentless `@begin` files whose stem equals the entry.
- Project the new FileTags and publish representative `Get` lookups for a typed observe and an `&out` direction.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/host-api-fixtures`: admitted TArray Function coverage includes the old type-axis and UFUNCTION direction FileTags, not only int32 local observes.

## Impact

Parent repository: `AngelscriptTestCode/Containers/TArray/`, CodeGenTool author tests, host-api-fixtures spec.
Plugin submodule: `Generated/Containers/TArray/`, `HostApiFixtureCorpusTests.cpp`.

## Non-goals

Other container types. Language. Unreal first-batch. `Math/`. Pending dumps. TestSource-old Advance compose/sidecar/transaction/replay boxes. Negative nested-container files. Reject aliases already covered by CompileFail. Conversion scripts. Parser changes. AngelScript compile or execute as admission.
