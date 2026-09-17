# LANG-CONV-OBJECT-CAST

Author reference for `FConvObjectCastGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Kind: `BASE` | `DERIVED` | `UNRELATED` | `NULL`
2. Source view: `BASE` | `DERIVED` | `UNRELATED`
3. Target view: `BASE` | `DERIVED` | `UNRELATED`
4. Form: `ASSIGNMENT` | `INITIALIZER` | `ARGUMENT` | `RETURN` | `EXPLICIT_CAST`

Product ID prefix: `LANG-CONV-OBJECT-CAST`. Complete set: 4×3×3×5 = 180 cells. Normal-return aggregate = 108. Compile reject = 72. Runtime fault = 0.

Example: `LANG-CONV-OBJECT-CAST-BASE-BASE-BASE-ASSIGNMENT` → `int EntryLangConvObjectCastBaseBaseBaseAssignment()`.

## Source branches

Host reference types `FObjectCastBase`, `FObjectCastDerived`, `FObjectCastUnrelated` and factories `MakeObjectCast{Kind}()` are not defined in the generated module.

Shared aggregate helpers, emitted once:

- `ObserveObjectCastTarget` overloads returning `Value == nullptr ? -1 : Value.GetField()`
- `ReturnObjectCast{Target}({Source} Value)` identity for each implicitly convertible pair

Each entry binds `RuntimeValue` from the kind factory. Source view `base` uses `RuntimeValue`; other views use `cast<{View}>(RuntimeValue)`.

- assignment / initializer use `SourceValue` directly
- argument returns `ObserveObjectCastTarget(SourceValue)` or `ObserveObjectCastTarget(cast<{Target}>(SourceValue))` for `explicit_cast`
- return assigns `ReturnObjectCast{Target}(SourceValue)`
- explicit_cast assigns `cast<{Target}>(SourceValue)`

Non-argument entries return `-1` on null, otherwise `GetIdentity` match ? `GetField()` : `-2`.

`ShouldCompile`: implicit forms require `IsImplicitlyConvertible` (same view, or target `base`). `explicit_cast` also allows source `base` to a non-base target.

`BuildObjectCastSource` is positive-only. `BuildRejectSource` and `ListRejectCaseIds` own the 72 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = IsVisibleThroughView(Kind, Source) && IsVisibleThroughView(Kind, Target) ? (int(Kind)+1)*1000+1 : -1`.

`IsVisibleThroughView` is false for `null`. Otherwise `base` is always visible; `derived`/`unrelated` require a matching runtime kind.

Normal rows are `ReturnValue` + `RequiresHostSetup` with notes naming the `MakeObjectCast*` factories. Reject rows are `CompileReject` with no declaration. `GetExpected` is 0 for reject and unknown IDs; that fallback is not membership proof.
