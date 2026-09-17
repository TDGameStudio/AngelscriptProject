# LANG-FN-ARITY-TYPE-STRESS

Author reference for `FFnArityTypeStressGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Arity: `ZERO` | `ONE` | `TWO` | `FOUR` | `EIGHT` | `SIXTEEN` | `THIRTY_TWO` | `SIXTY_FOUR`
2. Pattern: `HOMOGENEOUS_INT` | `HOMOGENEOUS_BOOL` | `ALTERNATING_INT_BOOL` | `ALTERNATING_BOOL_INT`
3. Target: `GLOBAL` | `NAMESPACE_GLOBAL` | `INSTANCE_METHOD`

Counts: 0, 1, 2, 4, 8, 16, 32, 64. Complete set: 8×4×3 = 96 cells. All 96 are normal-return aggregate entries.

Example: `LANG-FN-ARITY-TYPE-STRESS-ZERO-HOMOGENEOUS_INT-GLOBAL`.

## Source branches

Parameter type at slot `i` is `bool` when the pattern selects a bool slot, otherwise `int`. Bool arguments alternate `true`/`false` by even/odd index. Int arguments are `i + 1`. The probe returns `42` at arity 0, otherwise the sum of `P` or `(P ? 1 : 0)`.

Targets match arity-target: free function, namespaced function, or instance method. Names are uniquified from the entry so aggregate definitions do not collide.

## Observation

`ExpectedResult(Arity, Pattern)`: 42 when count is 0; otherwise sum of each slot's integer argument value. All rows are `ReturnValue` + `Standalone`. Unknown `GetExpected` is 0 and is not membership proof.
