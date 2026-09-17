# LANG-CONV-ABI

Author reference for `FConvAbiGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. ScriptDeclaration: `FLOAT` | `DOUBLE`
2. NativeStorage: `FLOAT32` | `FLOAT64`
3. Direction: `ARGUMENT` | `RETURN` | `PROPERTY`

Product ID prefix: `LANG-CONV-ABI`. Complete set: 2×2×3 = 12 cells. Normal-return aggregate = 12. Compile reject = 0. Runtime fault = 0.

`LANG-CONV-ABI-MANUAL-DECLARATION` is not part of this product.

Example: `LANG-CONV-ABI-FLOAT-FLOAT32-ARGUMENT` → `int EntryLangConvAbiFloatFloat32Argument()`.

## Source branches

No shared script helpers. Each cell uses a CaseId-qualified host symbol so conflicting `float32`/`float64` declarations do not collide in the aggregate.

- `ARGUMENT`: `T Value = T(3.25); return CallAbi<Qualifier>(Value);`
- `RETURN`: `T Result = CallAbi<Qualifier>(); return Result == T(3.25) ? 1 : 0;`
- `PROPERTY`: write `T(6.5)` through `AbiValue<Qualifier>` and compare `Output == Input`.

Host must register the matching `float32` or `float64` function or property. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is the script direction marker only:

- `ARGUMENT` + `FLOAT32` → 101
- `ARGUMENT` + `FLOAT64` → 202
- `RETURN` / `PROPERTY` → 1

The host `ExpectedBits` memcpy oracle is independent and is not packed into the int32. Rows are `ReturnValue` + `RequiresHostSetup` with `bLimitedObservation`. `GetExpected` returns 0 for unknown IDs. That zero fallback is not membership proof. There is no real expected-zero cell.
