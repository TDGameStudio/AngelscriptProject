# LANG-FE-STRUCTURAL-MUTATION

Author reference for `FForeachStructuralMutationGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Size: `ONE` (1) | `TWO` (2) | `MANY` (4)
2. Mutation: `STABLE` | `SHRINK_FIRST` | `SHRINK_MIDDLE` | `CLEAR_AFTER_FIRST`
3. Element: `PRIMITIVE_VALUE` | `VALUE_OBJECT_COPY` | `VALUE_OBJECT_CONST_REF`

Product ID prefix: `LANG-FE-STRUCTURAL-MUTATION`. Complete set: 3×4×3 = 36 cells. Enumeration nests Size (outer), then Mutation, Element (inner). All 36 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-FE-STRUCTURAL-MUTATION-ONE-STABLE-PRIMITIVE_VALUE` → `int EntryLangFeStructuralMutationOneStablePrimitiveValue()`.

## Source branches

Each case owns `FForeachTransferRange_<Entry>` wrapping `FNativeCaseRange`. Value-object elements store `FNativeCaseValue` and return it from `opForValue`; primitive elements return `int&`.

The foreach variable is `int Value`, `FNativeCaseValue Value`, or `const FNativeCaseValue& Value`. The body increments `Trace` once per visit, then mutates `Range.Native.Count` when requested:

- `STABLE`: no mutation
- `SHRINK_FIRST`: on iteration 0, `Count = 1`
- `SHRINK_MIDDLE`: on iteration 1, `Count = 2`
- `CLEAR_AFTER_FIRST`: on iteration 0, `Count = 0`

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`ExpectedMutationVisits`: `STABLE` → Size; `SHRINK_FIRST` / `CLEAR_AFTER_FIRST` → `min(Size, 1)`; `SHRINK_MIDDLE` → `min(Size, 2)`.

`GetExpected` uses this formula for every ID. Unknown IDs return 0; that zero fallback is not membership proof. No cell has expected 0.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `FNativeCaseRange` and `FNativeCaseValue`.
