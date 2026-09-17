# LANG-INH-OVERRIDE-SIGNATURE

Author reference for `FInhOverrideSignatureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Dimension: `PARAMETER_TYPE` | `PARAMETER_COUNT` | `RETURN_TYPE` | `CONSTNESS` | `VISIBILITY` | `NAME_HIDING`
2. Variant: `EXACT` | `COMPATIBLE_OVERLOAD` | `INCOMPATIBLE`
3. View: `BASE` | `DERIVED` | `EXPLICIT_BASE`

Product ID prefix: `LANG-INH-OVERRIDE-SIGNATURE`. Complete set: 6×3×3 = 54 cells. Normal-return aggregate = 36. Compile reject = 18 (`INCOMPATIBLE` × every view).

Example: `LANG-INH-OVERRIDE-SIGNATURE-PARAMETER_TYPE-EXACT-BASE`.

## Source branches

Unique `FSignatureBase` / `FSignaturePrimary` suffixes. Base returns `101 + Value`. Derived returns `202 + int(Value)`, `202 + Left + Right`, or `202.0f + float(Value)`. Explicit-base probe calls `FSignatureBase::Resolve(BaseArg)`.

`bBuildAccepted` is false for every incompatible cell. `BuildOverrideSignatureSource` is positive-only.

## Observation

- explicit_base → 102
- base + exact → 203; base + compatible → 102
- derived exact → 203
- derived compatible: parameter_count 205, name_hiding 204, else 203
