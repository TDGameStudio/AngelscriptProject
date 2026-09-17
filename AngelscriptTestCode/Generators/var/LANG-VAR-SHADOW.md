# LANG-VAR-SHADOW

Author reference for `FVarShadowGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Relation: `NONE` | `INNER_OUTER` | `PARAMETER_GLOBAL` | `PARAMETER_MEMBER` | `SIBLING`
2. Path: 22 filtered scope-use paths from `FUNCTION_BEFORE_DECLARATION` through `AFTER_OWNER`. `foreach_*` paths are dropped.

Product ID prefix: `LANG-VAR-SHADOW`. Complete set: 110 cells. Normal-return = 89. Compile reject = 21. Runtime fault = 0.

Reject: `after_owner` unless the relation is a parameter (3) plus before-declaration paths unless the relation is a parameter (18).

Example: `LANG-VAR-SHADOW-NONE-FUNCTION_AFTER_DECLARATION` → `int EntryLangVarShadowNoneFunctionAfterDeclaration()`.

## Source branches

Unique `ScopeSibling{Relation}`, `NestedScopeCall{Relation}{Path}`, and `FScopeOwner{Path}` names keep aggregate definitions from colliding. Parameter-member cells wrap the owner body in that unique class.

## Observation

- `after_owner` + parameter relation → 5
- any other parameter-relation cell → 11
- inner target + `inner_outer` → 22
- inner target + `sibling` → 21
- otherwise → 11

`BuildScopeSource` refuses reject-category inputs. Empty `FunctionName` emits `Entry`.
