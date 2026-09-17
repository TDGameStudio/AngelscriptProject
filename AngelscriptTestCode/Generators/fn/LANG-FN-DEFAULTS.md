# LANG-FN-DEFAULTS

Author reference for `FFnDefaultsGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Omission: `NONE` | `ONE` | `MANY` (omitted counts 0, 1, 2)
2. Pattern: `FINAL_ONE` | `FINAL_MANY` | `ALL_OPTIONAL` | `EXPLICIT_OVERRIDE` | `MIXED_OMITTED_PROVIDED` | `NON_TRAILING_INVALID` | `TYPE_INVALID` | `EARLIER_PARAMETER_REFERENCE_INVALID`
3. Target: `GLOBAL` | `NAMESPACE_GLOBAL` | `INSTANCE_METHOD`

Complete set: 3×8×3 = 72 cells. Normal-return aggregate = 57. Compile reject = 15.

Example: `LANG-FN-DEFAULTS-NONE-FINAL_ONE-GLOBAL`.

## Source branches

Probe body is always `return A * 100 + B * 10 + C;`. Parameter text:

- `FINAL_ONE`: `int A, int B, int C = 3`
- `FINAL_MANY`: `int A, int B = 2, int C = 3`
- optional-all / override / mixed: `int A = 1, int B = 2, int C = 3`
- `NON_TRAILING_INVALID`: `int A = 1, int B, int C = 3`
- `TYPE_INVALID`: `int A = UnknownDefault, int B = 2, int C = 3`
- `EARLIER_PARAMETER_REFERENCE_INVALID`: `int A = 1, int B = A, int C = 3`

`MIXED_OMITTED_PROVIDED` uses named arguments (`A: 4`, `C: 6`, or `C: 6` alone). Other patterns use positional `4, 5, 6` / `4, 5` / `4`.

`BuildDefaultArgumentSource` is positive-only.

## Observation

Reject when the declaration is `NON_TRAILING_INVALID`, when `EARLIER_*` omits more than one argument, or when omitted count exceeds optional count. `TYPE_INVALID` remains a normal characterization cell.

Named mixed results: 456 / 426 / 126. Positional: 456 / 453 / 423. `GetExpected` is 0 for reject and unknown IDs.
