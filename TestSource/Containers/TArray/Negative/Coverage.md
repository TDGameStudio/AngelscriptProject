# TArray Negative 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray/Negative`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
- 约定: 上级 `../Organization.md`

CompileReject for **nested containers**. Bind rule: containers cannot be nested in other containers. Diagnostic fragment: `Containers cannot be nested in other containers`.

One illegal program per file. Do not mix with `Reject/` (wrong element type, unbound API) or `Exception/` (compile + Throw).

Legal struct-in-array lives in `UClass/ArrayOfStructsContainingArrays.as`.

## TArray of TArray

| File | Site | Type |
|---|---|---|
| `TArrayNestedLocal.as` | local | `TArray<TArray<int>>` |
| `TArrayNestedLocalDeep.as` | local | `TArray<TArray<TArray<int>>>` |
| `TArrayNestedProperty.as` | UPROPERTY | `TArray<TArray<int>>` |
| `TArrayNestedPropertyDeep.as` | UPROPERTY | `TArray<TArray<TArray<int>>>` |
| `TArrayNestedParam.as` | UFUNCTION parameter | `TArray<TArray<int>>` |
| `TArrayNestedReturn.as` | UFUNCTION return | `TArray<TArray<int>>` |

Depth 2 vs 3 is the same diagnostic. `int` vs `bool` is not duplicated.

## TArray of TMap / TSet

| File | Site | Type |
|---|---|---|
| `TArrayOfMapsLocal.as` | local | `TArray<TMap<int, FString>>` |
| `TArrayOfMapsProperty.as` | UPROPERTY | `TArray<TMap<int, FString>>` |
| `TArrayOfSetsLocal.as` | local | `TArray<TSet<int>>` |
| `TArrayOfSetsProperty.as` | UPROPERTY | `TArray<TSet<int>>` |

Param/return for Map/Set-in-array is not duplicated; TArray-in-TArray covers signature sites.

Outer `TMap<int, TArray<int>>` moved to `Containers/TMap/Negative/TMapOfArraysProperty.as`.

Outer `TSet<TArray<...>>` lives in `Containers/TSet/Negative`.
