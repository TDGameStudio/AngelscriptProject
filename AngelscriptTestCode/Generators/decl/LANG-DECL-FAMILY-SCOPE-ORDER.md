# LANG-DECL-FAMILY-SCOPE-ORDER

Author reference for `FDeclFamilyScopeOrderGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Kept families (original full-table indices 0-9): `FUNCTION` | `METHOD` | `CLASS` | `STRUCT` | `FIELD` | `CONSTRUCTOR` | `DESTRUCTOR` | `NAMESPACE` | `ENUM` | `TYPEDEF`.

Kept scopes (indices 0-4): `GLOBAL` | `NAMESPACE` | `NESTED_NAMESPACE` | `MEMBER` | `MULTIPLE_SECTIONS`.

Orderings: `BEFORE_USE` | `FORWARD_USE` | `SAME_SECTION` | `LATER_SECTION` | `REVERSED_SECTIONS` | `REBUILD`.

Dropped: funcdef, import, virtual_property, indexed_property, mixin_global, imported_module. Filter is 10×5×6 = 300 cells, all normal-return.

Example: `LANG-DECL-FAMILY-SCOPE-ORDER-FUNCTION-GLOBAL-BEFORE_USE` → expected 600.

## Source branches

Unique per-cell suffixes on family/scope/ordering witnesses. `typedef` emits script `typedef int FamilyPublishedAlias…`. `destructor` is script-local with no native lifecycle bridge. before_use / rebuild / same_section emit the ordering target first; the other orderings emit the consumer first.

## Observation

`GetExpected = (100 + FamilyIndex) + (200 + ScopeIndex) + (300 + OrderingIndex)` using original full-table indices. Entry returns `FamilyWitness() + ScopeWitness() + OrderingWitness()`.
