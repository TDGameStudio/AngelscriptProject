# LANG-REF-SOURCE-OP

Author reference for `FRefSourceOpGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Operation: `INITIALIZE` | `ASSIGN` | `PASS` | `RETURN` | `IDENTITY` | `NULL_COMPARE` | `CAST` | `MEMBER_ACCESS` | `ALIAS_MUTATION`
2. Qualifier: `MUTABLE` | `CONST_OBJECT` | `CONST_INPUT` | `CONST_REMOVAL_INVALID`
3. Source: `NEW_LOCAL` | `FIELD` | `PARAMETER` | `RETURN` | `BASE_VIEW` | `DERIVED_VIEW` | `NATIVE_OBJECT` | `NULL`

Product ID prefix: `LANG-REF-SOURCE-OP`. Complete set: 9×4×8 = 288 cells. Non-reject aggregate = 200 (193 normal + 7 fault). Compile reject = 88. Runtime fault = 7. Faults stay in `OutCaseCount`.

Example: `LANG-REF-SOURCE-OP-INITIALIZE-MUTABLE-NEW_LOCAL` → `int EntryLangRefSourceOpInitializeMutableNewLocal()`.

## Source branches

Shared helpers, emitted once per aggregate: `ObserveReference`, `ReturnReference`, `ReturnConstReference`, `RequireMutable`, `FReferenceFieldOwner`, `ProvideReference`.

Each cell has a unique `Exercise<Entry>(<qualifier parameter>)` plus the named entry that binds the source expression (11–17, `nullptr`, `GetNativeRef`, `ProvideReference()`).

Reject partition:

- every `CONST_REMOVAL_INVALID`
- `ALIAS_MUTATION` unless `MUTABLE`

Fault partition (null source, not reject): `MEMBER_ACCESS`, `CAST`, and `ALIAS_MUTATION`.

`BuildReferenceIdentitySource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

Legal non-fault cells return 1. Fault rows are `RuntimeException` with `Null pointer access` and no integer value. Reject rows are `CompileReject` + `SourceOnly`. `GetExpected` returns 0 for reject, fault, and unknown IDs. That fallback is not membership proof. There is no real expected-zero normal cell.
