# TMap Negative 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TMap/Negative`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp`
- 约定: 上级 `../Organization.md`

CompileReject for **nested containers**. Bind rule: containers cannot be nested in other containers. Diagnostic fragment: `Containers cannot be nested in other containers`.

One illegal program per file. Do not mix with `Reject/` (wrong key/value type, unbound API) or `Exception/` (compile + Throw).

Legal struct-in-map lives in `UClass/MapOfStructsContainingArrays.as`.

## TMap of TMap

| File | Site | Type |
|---|---|---|
| `TMapNestedLocal.as` | local | `TMap<int, TMap<int, int>>` |
| `TMapNestedLocalDeep.as` | local | `TMap<int, TMap<int, TMap<int, int>>>` |
| `TMapNestedProperty.as` | UPROPERTY | `TMap<int, TMap<int, int>>` |
| `TMapNestedPropertyDeep.as` | UPROPERTY | `TMap<int, TMap<int, TMap<int, int>>>` |
| `TMapNestedParam.as` | UFUNCTION parameter | `TMap<int, TMap<int, int>>` |
| `TMapNestedReturn.as` | UFUNCTION return | `TMap<int, TMap<int, int>>` |

Depth 2 vs 3 is the same diagnostic. `int` vs `bool` is not duplicated.

## TMap of TArray / TSet

| File | Site | Type |
|---|---|---|
| `TMapOfArraysLocal.as` | local | `TMap<int, TArray<int>>` |
| `TMapOfArraysProperty.as` | UPROPERTY | `TMap<int, TArray<int>>` |
| `TMapOfSetsLocal.as` | local | `TMap<int, TSet<int>>` |
| `TMapOfSetsProperty.as` | UPROPERTY | `TMap<int, TSet<int>>` |

`TMapOfArraysProperty` moved from `Containers/TArray/Negative/TMapWithArrayValues.as`.

Param/return for Array/Set-in-map is not duplicated; TMap-in-TMap covers signature sites.

Outer `TArray<TMap<...>>` stays in `Containers/TArray/Negative`.
Outer `TSet<TMap<...>>` lives in `Containers/TSet/Negative`.
