# LANG-CTOR-VISIBILITY

Author reference for `FCtorVisibilityGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Selection: `EXACT` | `PROMOTION` | `EXPLICIT_CAST` | `IMPLICIT_REJECTED` | `AMBIGUOUS` | `MISSING`
2. Site: `OWNER` | `DERIVED` | `UNRELATED` | `GLOBAL`
3. Visibility: `DEFAULT` | `PROTECTED` | `PRIVATE`

Product ID prefix: `LANG-CTOR-VISIBILITY`. Complete set: 6×4×3 = 72 cells. Normal-return aggregate = 21. Compile reject = 51. Runtime fault = 0.

Normal = direct selection (`EXACT`, `PROMOTION`, `EXPLICIT_CAST`) and accessible site (default: all sites; protected: owner + derived; private: owner only).

Example: `LANG-CTOR-VISIBILITY-EXACT-OWNER-DEFAULT` → `int EntryLangCtorVisibilityExactOwnerDefault()`.

## Source branches

Shared helper, emitted once per aggregate or isolated reject module:

- empty `RecordConstructorVisibilitySelection(int Marker)`

Each cell owns tagged `FVisibilityNoMatch{Tag}`, `FVisibilityTarget{Tag}`, optional `FVisibilityDerived{Tag}` / `FVisibilityUnrelated{Tag}`, and `ConsumeVisibilityTarget{Tag}`. Constructor arguments are `int(7)`, `int8(7)`, or `int64(int8(7))`. Implicit-rejected cells pass `int(7)` into the consume helper. Ambiguous cells declare two defaulted extra-parameter constructors. Missing cells take `FVisibilityNoMatch{Tag}` but are still called with `int(7)`.

Sites:

- owner: `Owner.ExerciseVisibility()`
- derived: construct derived (`super(arg)` or implicit consume) and return `.Value`
- unrelated: `Caller.ExerciseVisibility()`
- global: construct the target in the entry

`BuildConstructorVisibilitySource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

Every normal ID returns 7. Reject and unknown IDs return 0 from `GetExpected` without membership proof. There is no real expected-zero normal cell. Normal rows are `ReturnValue` + `RequiresHostSetup`.
