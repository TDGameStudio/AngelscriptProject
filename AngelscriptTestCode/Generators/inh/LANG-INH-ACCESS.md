# LANG-INH-ACCESS

Author reference for `FInhAccessGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Access: `DEFAULT` | `PROTECTED` | `PRIVATE`
2. Member: `FIELD` | `METHOD` | `GETTER_SETTER_METHOD` | `CONSTRUCTOR`
3. Site: `OWNER` | `DIRECT_DERIVED` | `DEEP_DERIVED` | `UNRELATED` | `GLOBAL`

Product ID prefix: `LANG-INH-ACCESS`. Complete set: 3×4×5 = 60 cells. Normal-return aggregate = 37. Compile reject = 23. Runtime fault = 0.

Example: `LANG-INH-ACCESS-DEFAULT-FIELD-OWNER` → `int EntryLangInhAccessDefaultFieldOwner()`.

## Source branches

Each cell owns unique `FAccessBase` / `FAccessDerived` / `FAccessDeep` / `FAccessUnrelated` suffixes. `getter_setter_method` is an ordinary Get/Set pair; the generated body still calls `SetValue(73)` while the oracle remains 43.

`ShouldCompile`: owner except private constructor; derived sites `!private`; unrelated/global only `default`, except protected constructors remain accepted.

`BuildInheritanceAccessSource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

- field → 41
- method → 42
- getter_setter_method → 43
- constructor: unrelated → 46; derived → 48; owner/global → 47

`GetExpected` is 0 for reject and unknown IDs. That zero is not membership proof. No host, lifecycle, or limited-observation notes apply.
