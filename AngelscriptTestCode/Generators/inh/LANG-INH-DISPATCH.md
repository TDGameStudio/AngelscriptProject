# LANG-INH-DISPATCH

Author reference for `FInhDispatchGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Depth: `BASE` | `TWO_LEVELS` | `THREE_LEVELS` | `DEEP` (`BaseEdges` 1 / 2 / 3 / 8)
2. Member: `FIELD` | `NONVIRTUAL_METHOD` | `VIRTUAL_METHOD` | `OVERRIDE` | `GETTER_METHOD` | `SETTER_METHOD`
3. View: `DERIVED_OBJECT` | `BASE_VIEW` | `EXPLICIT_BASE` | `OWNER` | `DERIVED_IMPL`
4. Invocation: `DIRECT` | `VIRTUAL_ROUTE` | `EXPLICIT_BASE`

Product ID prefix: `LANG-INH-DISPATCH`. Complete set: 4×6×5×3 = 360 cells. All normal-return. Example: `LANG-INH-DISPATCH-BASE-FIELD-DERIVED_OBJECT-DIRECT`.

## Source branches

Unique `FDispatchRoot` / intermediate / `FDispatchPrimary` suffixes per cell. Field root stores `DispatchField = 701`. Setter probes pass `7`. `UsesExplicitBase` is view or invocation `explicit_base`. `UsesBaseView` is `base_view` or `virtual_route` when not explicit.

## Observation

- nonvirtual_method → 100
- UsesExplicitBase: field 701, setter 107, else 100
- field + virtual_route → 701 + Level×10; other field → 701
- setter → 100 + Level×100 + 7
- else → 100 + Level×100
