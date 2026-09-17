# TArray type and direction names

Source of truth for new FileTags: `TestSource-old/Containers/TArray/Function/*.as`, packed as one observation per file.

## Identity

- FileTag `Containers/TArray/<Observation>`
- File `AngelscriptTestCode/Containers/TArray/<Observation>.as`
- Stem = `@begin` = entry function
- File header lists the stem
- Do not use method-alias stems from `METHOD_ALIAS_STEMS`

## Type suffixes

Pascal, no underscore. Existing int32 observe files keep their names.

| Suffix | Element | Compare |
|---|---|---|
| (none) | `int32` | `==` |
| `Float` | `float` | `==` |
| `Bool` | `bool` | `==` |
| `FString` | `FString` | `==` |
| `FVector` | `FVector` | `Equals` |
| `UObject` | `UObject` handle | pointer identity; dummy `UCLASS` + `NewObject` |

`SortAscending` has no `FVector` / `UObject` leaves. `EmptyConstruction` gets type Key observes only, no three-direction set.

## Direction stems for Add (cited hole)

Existing: `AddAndOrder`

| Direction | int32 | Typed |
|---|---|---|
| Observe | `AddAndOrder` | `AddAndOrderFloat`, `AddAndOrderBool`, `AddAndOrderFString`, `AddAndOrderFVector`, `AddAndOrderUObject` |
| `const&in` | `ReadAddOrder` | `ReadAddOrderFloat`, `ReadAddOrderBool`, `ReadAddOrderFString`, `ReadAddOrderFVector`, `ReadAddOrderUObject` |
| `&out` | `FillByAdd` | `FillByAddFloat`, `FillByAddBool`, `FillByAddFString`, `FillByAddFVector`, `FillByAddUObject` |
| `&inout` | `AppendWithAdd` | `AppendWithAddFloat`, `AppendWithAddBool`, `AppendWithAddFString`, `AppendWithAddFVector`, `AppendWithAddUObject` |

## Direction pattern for other Function subjects

Keep the existing int32 observe stem. Add `<Stem><Type>` for typed observes. Add three direction families:

- `Read<Subject>` / `Read<Subject><Type>` — `const TArray<T>&in`
- `FillBy<Subject>` / `FillBy<Subject><Type>` — `TArray<T>&out`
- `Mutate<Subject>` / `Mutate<Subject><Type>` — `TArray<T>&inout`, unless the old file already names a more precise verb (`AppendWithAdd`, `ClearByReset`, `OverwriteRunInPlace`). Prefer the old verb when it is already an observation.

Subject tokens come from the current observe stem, not from a raw Bind method (`ContainsReportsMembership` → `ReadContainsReportsMembership`).

## Return-value FileTags

- `ReturnIntArray`
- `ReturnFRotatorArray`
- `ReadFRotatorArray`
- `FillByFRotatorArray`
- `MutateFRotatorArray`
- `ReturnFTransformArray`
- `ReadFTransformArray`
- `FillByFTransformArray`
- `MutateFTransformArray`
- `ReturnFLinearColorArray`
- `ReadFLinearColorArray`
- `FillByFLinearColorArray`
- `MutateFLinearColorArray`

## Out of this glossary

CompileFail / RuntimeFail already admitted. Advance compose boxes. Other container types.
