# TSet Negative 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSet/Negative`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`
- 约定: 上级 `../Organization.md`

CompileReject for **nested containers**. Bind rule: containers cannot be nested in other containers. Diagnostic fragment: `Containers cannot be nested in other containers`.

One illegal program per file. Do not mix with `Reject/` (wrong element type, unbound API) or `Exception/` (compile + Throw).

Legal struct-in-set lives in `UClass/SetOfStructsContainingArrays.as`（元素必须可哈希：`Hash` + `opEquals`）。

## TSet of TSet

| File | Site | Type |
|---|---|---|
| `TSetNestedLocal.as` | local | `TSet<TSet<int>>` |
| `TSetNestedLocalDeep.as` | local | `TSet<TSet<TSet<int>>>` |
| `TSetNestedProperty.as` | UPROPERTY | `TSet<TSet<int>>` |
| `TSetNestedPropertyDeep.as` | UPROPERTY | `TSet<TSet<TSet<int>>>` |
| `TSetNestedParam.as` | UFUNCTION parameter | `TSet<TSet<int>>` |
| `TSetNestedReturn.as` | UFUNCTION return | `TSet<TSet<int>>` |

Depth 2 vs 3 is the same diagnostic. `int` vs `bool` is not duplicated.

## TSet of TArray / TMap

| File | Site | Type |
|---|---|---|
| `TSetOfArraysLocal.as` | local | `TSet<TArray<int>>` |
| `TSetOfArraysProperty.as` | UPROPERTY | `TSet<TArray<int>>` |
| `TSetOfMapsLocal.as` | local | `TSet<TMap<int, int>>` |
| `TSetOfMapsProperty.as` | UPROPERTY | `TSet<TMap<int, int>>` |

Param/return for Array/Map-in-set is not duplicated; TSet-in-TSet covers signature sites.

Outer `TArray<TSet<...>>` stays in `Containers/TArray/Negative`.
Outer `TMap<..., TSet<...>>` stays in `Containers/TMap/Negative`.
