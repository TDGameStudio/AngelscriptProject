# LANG-DECL-COLLISION

Author reference for `FDeclCollisionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. InsertionOrder: `LEFT_THEN_RIGHT` | `RIGHT_THEN_LEFT`
2. NamespaceRelation: `SAME` | `DIFFERENT` | `NESTED`
3. Pair: `FUNCTION_OVERLOAD` | `FUNCTION_DUPLICATE` | `FUNCTION_TYPE` | `FUNCTION_ENUM` | `TYPE_DUPLICATE` | `TYPE_ENUM` | `ENUM_DUPLICATE` | `METHOD_OVERLOAD` | `METHOD_DUPLICATE` | `METHOD_FIELD` | `METHOD_PROPERTY` | `FIELD_DUPLICATE` | `FIELD_PROPERTY` | `PROPERTY_GET_SET` | `PROPERTY_DUPLICATE_GET` | `PROPERTY_DUPLICATE_SET`

Product ID prefix: `LANG-DECL-COLLISION`. Complete set: 2×3×16 = 96 cells. Normal-return aggregate = 48. Compile reject = 48.

Example: `LANG-DECL-COLLISION-LEFT_THEN_RIGHT-SAME-FUNCTION_OVERLOAD`.

## Source branches

`bShouldCompile = !removed-property-syntax && (!same-owner || legal-in-same-owner)`. Legal same-owner pairs: function_overload, method_overload. Property pairs always reject and still emit the removed get/set syntax. Unique namespace / `FOwner` suffixes isolate aggregate entries. Entry returns 71.

`BuildCollisionSource` is positive-only.
