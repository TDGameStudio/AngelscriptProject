# Expressions and Evaluation

## Elements and dimensions

| Axis | Values |
| --- | --- |
| Primary | literals, identifiers, scoped names, parenthesized expression, function call, constructor call, member access, indexed access, cast, null |
| Composition | unary, binary, assignment, compound assignment, ternary, call chain, member/index chain, nested cast, default/named argument where current syntax supports it |
| Operand type | all primitive families, enum/alias, value object, automatic reference/null, funcdef where legal |
| Value category | mutable lvalue, const lvalue, temporary/rvalue, reference alias, field/property, invalid non-lvalue |
| Context | initializer, assignment RHS/LHS, argument, return, condition, loop clause, switch selector, index, property accessor |
| Evaluation | left/right order, short circuit, selected ternary branch, repeated subexpression, side-effect counter, exception point |
| Resolution | exact symbol/member, namespace qualified, overload, conversion, inaccessible, missing, ambiguous |
| Source shape | whitespace/comments, parentheses depth, multiline, line/column-sensitive malformed form |

## Required products

- `Typed primary variant × context` is generated as isolated modules. The twenty-two variants bind grammar form to a real type/value category—rather than crossing literals with impossible lvalue labels—and every cell has an explicit legal or rejected expectation, exact result/type metadata where legal, and an owning source location where rejected.
- `Value category × mutation × placement` covers assignment, compound assignment, pre/post increment, and `out` calls for locals, globals, members, and indexed targets. Alias visibility and one-write counters are required for legal cells.
- Every ordered pair drawn from all twelve precedence levels is generated unparenthesized, left-parenthesized, and right-parenthesized. Same-level associativity is separately generated for repeated and mixed operators so precedence evidence cannot stand in for associativity evidence.
- `Eager composition × operand count × completion/exception point × source shape` covers binary and mutation expressions, call/constructor/index argument lists, call/member/index chains, and nested casts. Every cell has two, three, or eight observable operand stages; exceptional cells stop at the selected first, middle, or last stage and prove cleanup.
- `Logical/conditional form × selector × operand outcome × source shape` proves lazy evaluation with value, side-effect, and exception operands. The stopped trace, object cleanup, exception frame, and context reuse are required.
- `Chain shape × depth × state × context` covers two-, three-, eight-, and deep-boundary member/index/call/cast chains. Null receivers, invalid or throwing intermediate stages, and missing terminals must prove that later stages did not run.
- `Resolution state × expression context × source shape` covers exact, qualified, overloaded, converted, missing, ambiguous, inaccessible, and wrong-type outcomes. Successful cells record the exact declaration; rejected cells own one located diagnostic.
- `Source boundary scenario × context × build generation` covers parentheses, chain and argument-count depths, numeric boundaries, comments/whitespace/multiline layout, and same/changed rebuilds.
- `Failure × context × recovery` isolates parse, compile, and runtime failures, then proves a clean fresh-module rebuild or same-context recovery.
- `Operand type pair × representative binary expression family` is linked to Operators; this theme owns composition and evaluation order, not duplicate operator semantics.

## Generated source policy

Expression products use reviewed input tables and deterministic builders because the required source forms differ along several independent axes. Generation does not weaken reviewability:

- each generated module has one stable case ID and one intended semantic result or failure;
- a cell may be excluded only by an explicit language-legality predicate recorded beside the input tables; it may not silently disappear from the product;
- expected parse grouping, selected declaration, runtime value, evaluation trace, exception location, lifecycle balance, and recovery result are computed independently from the emitted expression text;
- successful, rejected, exceptional, first-build, same-rebuild, and changed-rebuild source versions are all printed in full before compilation using the common `[AS-SOURCE-BEGIN]`, numbered `[AS-SOURCE]`, and `[AS-SOURCE-END]` records;
- malformed cells remain isolated modules so a deliberate syntax error cannot create unrelated follow-on diagnostics;
- hand-written C++ assertions may inspect raw metadata or bytecode, but the AngelScript input for those assertions still follows the same source-print contract.

## Boundary coverage

Deep parentheses/chains, zero/one/many arguments, numeric/literal boundaries, invalid lvalues, missing delimiters, malformed ternary, missing member/index, division/index/null exceptions, unreachable side effects, source range, and rebuild/bytecode equivalence are required.

## Planned ownership

- `Language/Expressions/AngelscriptNativePrimaryExpressionTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionCompositionTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionPrecedenceTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionValueCategoryTests.cpp`
- `Language/Expressions/AngelscriptNativeLazyExpressionEvaluationTests.cpp`
- `Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionChainTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionResolutionTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionBoundaryTests.cpp`
- `Language/Expressions/AngelscriptNativeExpressionFailureTests.cpp`
