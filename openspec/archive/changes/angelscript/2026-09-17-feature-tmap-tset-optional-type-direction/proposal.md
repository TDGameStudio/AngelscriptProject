## Why

The directory rewrite admitted TMap, TSet, and TOptional as `Containers/<Type>/<Observation>` leaves, but those leaves are almost all local int observes. `TestSource-old/Containers/<Type>/Function` already required Observe plus `const&in` / `&out` / `&inout` and each tree's type suffixes. The archived TArray Change ported that contract as one observation per file. These three trees did not.

TMap is a half layer: `ContainsKey` / `NumCountsPairs` / `IndexAccess` have typed leaves and `*In`, with no `&out` / `&inout`, and Add-family subjects stay local. TSet and TOptional have almost no directions and no type axis.

This Change comes from approved draft scope `tmap-tset-optional` (R3). Names: [attachments/drafts/glossary.md](attachments/drafts/glossary.md).

## What Changes

- Hand-author TMap remaining, TSet, and TOptional observation leaves that port the old Function type-axis and direction cases.
- Keep existing int observes and admitted TMap `*In` FileTags.
- Project the new FileTags and publish representative `Get` lookups per tree.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/host-api-fixtures`: admitted TMap / TSet / TOptional Function coverage includes the old type-axis and UFUNCTION direction FileTags, not only local int observes.

## Impact

Parent repository: `AngelscriptTestCode/Containers/{TMap,TSet,TOptional}/`, CodeGenTool author tests, host-api-fixtures spec.
Plugin submodule: `Generated/Containers/{TMap,TSet,TOptional}/`, `HostApiFixtureCorpusTests.cpp`.

## Non-goals

Pointer wrappers. SoftObjectPath. Language. Unreal first-batch. TestSource-old Advance compose boxes. Negative nested-container files. Reject aliases. Misplaced TSet Function files. Renaming admitted TMap `*In`. Conversion scripts. Parser changes. AngelScript compile or execute as admission.
