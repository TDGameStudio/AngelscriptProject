# Operators

## Operator families

- unary sign and logical/bitwise negation: `+`, `-`, `!`, `~`;
- prefix/postfix mutation where supported: `++`, `--`;
- arithmetic: `+`, `-`, `*`, `/`, `%`, `**`;
- shifts: `<<`, `>>`, `>>>` according to current fork semantics;
- bitwise: `&`, `|`, `^`;
- comparison/equality: `<`, `<=`, `>`, `>=`, `==`, `!=`;
- logical: `&&`, `||`, `^^` and keyword aliases only if tokenized by this fork;
- assignment and compound forms: `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `**=`, `&=`, `|=`, `^=`, `<<=`, `>>=`, `>>>=`;
- overloaded operator methods supported by the fork, including equality/comparison, index, conversion, assignment, and arithmetic forms;
- deliberately rejected identity/handle/operator forms receive active Conformance or negative coverage.

## Dimensions

| Axis | Values |
| --- | --- |
| Operand category | every signed/unsigned width, current floating families, bool, enum/alias, value object, automatic reference/null where legal |
| Operand pairing | same type, mixed width, signed+unsigned, int+float, enum+integer where legal, object+object, object+primitive overload |
| Value partition | zero, one, negative, min/max, near boundary, divisor zero, shift 0/width-1/width/negative, NaN/Inf where applicable |
| Value category | mutable lvalue, const lvalue, temporary, field/property, reference alias |
| Result context | assignment, return, condition, overload argument, chained expression, switch/index |
| Overload shape | member/global if supported, const/non-const, exact/promoted parameter, return type, duplicate/invalid signature |
| Outcome | runtime value, mutation, selected overload, overflow/truncation behavior, exception, compile diagnostic |

## Required products

- `LANG-OP-NUMERIC-BINARY` owns every numeric left type × numeric right type × arithmetic/comparison operator × ordinary/boundary value cell. Variables, rather than literals, force the fork's runtime promotion rules; exact function return type metadata and runtime bits are both evidence.
- `LANG-OP-UNARY` owns the 28 exact legal positive/negative numeric and integral-complement operation/type pairs × five value categories × five meaningful numeric partitions. Unsigned sign operations remain active because this fork deliberately converts them to their signed type of equal width.
- `LANG-OP-LOGICAL-NOT` separately owns boolean value category × false/true. It is not multiplied by numeric-only minimum/maximum labels.
- `LANG-OP-UNARY-REJECTION` owns eight concrete illegal boolean/numeric/floating operation families × five source categories and same-name recovery. It omits the value axis because primitive unary legality is type-driven; repeating one rejection for five irrelevant values would not add evidence.
- `LANG-OP-POWER-UNIVERSAL` separates constant folding from mutable, const, and returned runtime operands across every base/exponent type for universally representable zero, one, near-limit, and overflow values. `LANG-OP-POWER-NEGATIVE-EXPONENT` separately crosses every base with only signed/floating exponent types, while `LANG-OP-POWER-FRACTIONAL-EXPONENT` crosses every base with only floating exponent types. This prevents an unsigned negative or integral fractional declaration from masquerading as exponentiation coverage, while retaining the fork's distinct constant and non-constant integer behavior.
- `LANG-OP-LOGICAL` owns source shape × logical operator × truth pair × consuming context and records the exact left/right evaluation trace, so short-circuit and eager exclusive-or behavior cannot be inferred from result alone.
- `LANG-OP-INTEGRAL-BITWISE` owns integral type × bitwise/shift operator × right-operand partition × value category. For shifts, the right partition is zero, one, source-width-minus-one, source width, or negative; for `&`, `|`, and `^`, the same values are concrete right-side bit patterns. The source-width boundary is intentionally distinct from the promoted 32/64-bit execution width. This fork lowers `>>` to logical shift and `>>>` to arithmetic shift; catalog names must preserve that fork behavior rather than infer semantics from an upstream-style “unsigned right shift” label.
- `LANG-OP-ASSIGNMENT` owns only type-supported simple/compound assignment form × writable local/field/registered-property/inout-alias route. `LANG-OP-ASSIGNMENT-TARGET-REJECTION` independently owns those same legal form/type pairs on const and returned-temporary targets. `LANG-OP-ASSIGNMENT-TYPE-REJECTION` owns unsupported bool and floating operation/type pairs on real writable routes. This preserves a causal diagnostic: an invalid type is never crossed with a non-writable target simply to manufacture a second failure label.
- `LANG-OP-INCREMENT` independently owns prefix/postfix × increment/decrement × numeric type × writable target category × before/result/after observation. `LANG-OP-INCREMENT-TARGET-REJECTION` owns const/temporary numeric targets, and `LANG-OP-INCREMENT-TYPE-REJECTION` owns writable bool-shaped targets. Compile failures have no fabricated before/result/after rows.
- `LANG-OP-COMPARISON-FLOAT` owns physical 32/64-bit floating signed zero, NaN, infinity, finite boundaries, and equal pairs under every comparison token and both operand orders.
- `LANG-OP-COMPARISON-ENUM-ALIAS` owns enum nominal identity versus alias representation across equal, adjacent, minimum, and maximum underlying pairs under every comparison token and both operand orders.
- `LANG-OP-COMPARISON-REFERENCE` owns automatic-reference identity for same, different, base-view, sibling, const, and null relations; equality executes while unsupported ordering produces one located rejection and balanced retained objects.
- `LANG-OP-COMPARISON-OVERLOAD` owns `opCmp`/`opEquals` selection, relation value, receiver constness, operand reversal, exact runtime marker/order, and value-object lifetime for every comparison token.
- `LANG-OP-OVERLOAD-INTEGER-CONSUMER` owns 20 legal integer-result declaration or resolution scenarios × six integer-capable consumers. It keeps selected marker/metadata paths distinct from marked ambiguous or missing consumer diagnostics.
- `LANG-OP-OVERLOAD-BOOLEAN-CONSUMER` owns four legal comparison-result scenarios × the five consumers with an independent boolean observation. A boolean `switch` selector is not represented as an artificial duplicate.
- `LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER` owns four `opAssign` result-reference scenarios × six reference-capable consumers, verifying that the actual returned reference rather than a substituted integer is consumed.
- `LANG-OP-OVERLOAD-DUPLICATE-DECLARATION` owns one duplicate signature rejection per operator family. It is declaration-only because the raw compiler rejects the second declaration before a consumer expression exists.
- `LANG-OP-RESULT-CONTEXT` owns the interaction between every operator family and assignment, return, condition, overload-argument, chain, and switch/index consumers.
- `LANG-OP-FAILURE` owns isolated unsupported operands, zero division/modulo, shift and overflow boundaries, invalid lvalues, const mutation, overload failures, null receivers, operand exceptions, cleanup, and fresh/same-state recovery.

## Failure coverage

Unsupported operand categories, division/modulo by zero, invalid shifts, overflow behavior, invalid lvalue, const mutation, missing overload, ambiguous overload, invalid operator signature, duplicate operator, null receiver, and exception cleanup are isolated.

The overload products retain only declaration shapes the fork grammar can express and consumer routes that can observe that result kind. The removed `837` pseudo-combinations are classified by exact cause (`144 + 161 + 24 + 20 + 488`) in `fork-limitations.md`, including the rule that a duplicate declaration cannot be multiplied by consumers that compile later.

## Planned ownership

- `Language/Operators/AngelscriptNativeUnaryOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeLogicalNotOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeUnaryOperatorFailureTests.cpp`
- `Language/Operators/AngelscriptNativeNumericBinaryOperatorTests.cpp`
- `Language/Operators/AngelscriptNativePowerOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeBitwiseOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeComparisonOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeEnumAliasComparisonOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeReferenceComparisonOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeOverloadedComparisonOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeLogicalOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeAssignmentOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeAssignmentTargetRejectionTests.cpp`
- `Language/Operators/AngelscriptNativeAssignmentTypeRejectionTests.cpp`
- `Language/Operators/AngelscriptNativeIncrementOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeIncrementTargetRejectionTests.cpp`
- `Language/Operators/AngelscriptNativeIncrementTypeRejectionTests.cpp`
- `Language/Operators/AngelscriptNativeOverloadedOperatorTests.cpp`
- `Language/Operators/AngelscriptNativeOverloadedBooleanConsumerTests.cpp`
- `Language/Operators/AngelscriptNativeOverloadedAssignmentConsumerTests.cpp`
- `Language/Operators/AngelscriptNativeOverloadedDuplicateDeclarationTests.cpp`
- `Language/Operators/AngelscriptNativeOperatorContextTests.cpp`
- `Language/Operators/AngelscriptNativeOperatorFailureTests.cpp`
