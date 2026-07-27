# Conversions and Casts

## Dimensions

| Axis | Values |
| --- | --- |
| Source type | every primitive width/category, enum, alias, value object, automatic reference, base/derived object, null |
| Target type | every primitive width/category, enum, alias, value object conversion target, automatic reference/base/derived, bool context |
| Form | implicit assignment, initializer, argument, return, arithmetic promotion, explicit cast, constructor conversion, operator conversion, condition context |
| Source value | zero, one, negative, min/max, near boundary, out-of-range, fractional, NaN/Inf, null, exact object type, base/derived runtime kind |
| Resolution context | single target, overload set, operator operands, default argument, property/index accessor, conditional common type |
| Outcome | exact preservation, widening, truncation, wrap/rejection, selected overload, null/successful cast, ambiguous, compile failure, runtime exception |

## Required products

- `LANG-CONV-NUMERIC` is the complete numeric source type × numeric target type × assignment/initializer/argument/return/promotion/explicit form × ordinary/boundary value product. All 4,200 cells print and explicitly record acceptance or rejection. Accepted portable cells use an independent C++-computed target literal for exact value verification; current-fork float-to-integer cells whose result is host-dependent retain compilation, target metadata, execution, and cleanup evidence plus an explicit fork limitation instead of fabricating a portable value.
- `LANG-CONV-FLOAT-FINITE-SPECIAL` owns `float32`/`float64` source × numeric target × invocation form × positive-zero/negative-zero/subnormal source. Every cell reaches its conversion expression and verifies exact target bits.
- `LANG-CONV-FLOAT64-TO-FLOAT32-RANGE` owns the only representable finite narrowing boundary: `float64` to `float32` × invocation form × above/below target finite maximum. It verifies the exact positive or negative infinity target bits.
- `LANG-CONV-NONFINITE-PRECONVERSION` owns `float32`/`float64` source × numeric target × invocation form × positive-infinity/negative-infinity/NaN construction. The fork raises the exact divide-by-zero exception while constructing the source, before conversion; these rows verify compilation, return metadata, context cleanup, and that pre-conversion behavior without claiming a conversion result.
- `LANG-CONV-BOOL-CONTEXT` owns primitive/enum/alias source × `if`/`while`/ternary/logical context × zero/one/negative value. Current-fork behavior is active; desired 2.38-only truth conversion remains compiled and Disabled under `#as-v238-backport`.
- `LANG-CONV-ENUM-ALIAS` owns enum or signed/unsigned alias source × enum/numeric target × conversion form × value partition and distinguishes nominal enum identity from transparent alias representation. Accepted cells compare against an independently constructed target literal derived from the source storage width and target width/category; the verifier never recomputes the expected value by applying the same source conversion expression.
- `LANG-CONV-OBJECT-CAST` owns runtime kind × static source view × target view × assignment/initializer/argument/return/explicit form, including source-view establishment, identity, null, failure, and balanced reference lifetime.
- `LANG-CONV-VALUE-OBJECT` owns constructor/operator availability and explicitness × target × invocation form × direct/selected/ambiguous/rejected fixture outcome, with exact marker and temporary lifecycle evidence.
- `LANG-CONV-OVERLOAD` owns conversion family × overload/operator/default/property/index/conditional resolution context × exact/selected/ambiguous/rejected outcome.
- `LANG-CONV-ABI` owns script `float`/`double` spelling × native 32/64-bit storage × argument/return/property direction × accepted/rejected registration outcome and pins `asEP_FLOAT_IS_FLOAT64` evidence.
- `LANG-CONV-FAILURE` isolates every compile/runtime conversion failure, causal line, partial-publication boundary, lifecycle cleanup, and fresh or same-module/context recovery.

## ABI and fork-specific evidence

The current `asEP_FLOAT_IS_FLOAT64` configuration is inspected per case. C++ callback/register/return access uses the actual ABI, and tests distinguish script declaration spelling from storage/call ABI. A rejected double-backed native call is a separate active negative, never an alternative accepted outcome in the same case.

Finite range combinations that cannot be sourced at their declared width, and floating-to-integer inputs without a portable fork result contract, are deliberately absent from the three products above. Their exact `24 + 128` accounting, minimal reason, and revisit requirement are retained in `fork-limitations.md`; they are not counted as passed conversion cases.

## Planned ownership

- `Language/Conversions/AngelscriptNativeNumericConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeBoolConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeEnumAliasConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeObjectCastTests.cpp`
- `Language/Conversions/AngelscriptNativeValueObjectConversionTests.cpp`
- `Language/Conversions/AngelscriptNativeConversionResolutionTests.cpp`
- `Language/Conversions/AngelscriptNativeConversionAbiTests.cpp`
- `Language/Conversions/AngelscriptNativeConversionFailureTests.cpp`
