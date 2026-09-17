# TestSource-old TArray Function versus current leaves

Compared 2026-09-17.

## Cited hole

`TestSource-old/Containers/TArray/Function/TArrayAddAndOrder.as` has 24 UFUNCTIONs: Observe + `const&in` + `&out` + `&inout` for `int`, `float`, `bool`, `FString`, `FVector`, `UObject`.

Current `AngelscriptTestCode/Containers/TArray/AddAndOrder.as` is one `TArray<int32>` local Add. A workspace search of `Containers/TArray/**/*.as` finds no `&in`, `&out`, `&inout`, `_FString`, `_float`, or `_FVector`.

## Old Function pile

31 `.as` files under `TestSource-old/Containers/TArray/Function/`. Coverage.md required L2 three-direction and L3 type suffixes on each Function subject. The files themselves carry those UFUNCTIONs (AddAndOrder has 59 type/direction marker hits).

Current TArray has about 98 observation files, nearly all int32 local or Fail polarity. Fail siblings stay; this Change adds the missing Function type and direction leaves.

## Not ported here

- `Advance/` compose, sidecar, transaction, replay, sequence, restore
- `Negative/` nested containers
- `Reject/` aliases (already CompileFail)
- `Exception/` (already RuntimeFail)
- `UClass/` actor property hosts except Function-file `UObject` NewObject handles
