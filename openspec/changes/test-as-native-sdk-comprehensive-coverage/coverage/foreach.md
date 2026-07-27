# Foreach and Iterator Protocol

## Boundary

This theme tests the fork's selectively backported core `foreach` lowering with minimal locally registered or script-defined protocol fixtures. It does not register scriptarray, dictionary, or another SDK add-on to satisfy iteration coverage.

## Dimensions

| Axis | Values |
| --- | --- |
| Input size | empty, one, two, representative many |
| Element category | primitive, value object, automatic reference object, const element where legal |
| Iteration variable | value, inferred `auto`, mutable reference, const reference, explicit incompatible type |
| Protocol | complete valid `opFor*`, overloaded valid forms, missing begin/next/value/end member, wrong parameter/return, inaccessible, throwing callback |
| Transfer | complete, break first/middle/last, continue first/middle, return, exception |
| Nesting | single loop, nested same iterable, nested distinct iterables, foreach inside classic loop, classic loop inside foreach |
| Mutation/lifetime | read only, mutate through reference, replace/rebind, mutate iterable structure if the fork defines it, iterator construct/destruct, element lifetime |
| Resolution | exact protocol, conversion, const overload, ambiguous overload, missing protocol |

## Required products

- `Input size × variable form × element category` for every legal cell, validating order, values, alias/mutation, and iteration count.
- `Transfer × input size/position` validates visited elements and cleanup.
- `Nesting shape × transfer target` proves break/continue/return ownership.
- `Protocol member family × missing/wrong/inaccessible form` produces one owning diagnostic per fixture.
- `Protocol overload × receiver/element constness × resolution outcome` proves selected members.
- `Exit path(normal/break/return/exception) × iterator/element lifetime` validates exact cleanup.
- Structural mutation is characterized with an exact current-fork outcome; it may not remain a vague partial ceiling.

## Planned ownership

- `Language/Foreach/AngelscriptNativeForeachValueTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachReferenceTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachControlTransferTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachNestedTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachProtocolResolutionTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachLifetimeTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachFailureTests.cpp`
- `Language/Foreach/AngelscriptNativeForeachTransferLifetimeTests.cpp`

The transfer/lifetime owner is intentionally separate from the protocol and binding
owner. It executes complete, break-first, break-middle, continue-first,
continue-middle, return, and exception paths at single, same-range nested,
distinct-range nested, and classic-for nesting targets. Primitive values and
tracked native values use both by-value and const-reference bindings so the
iterator callback sequence is checked independently from native copy/destruction.
The same owner characterizes stable, first-iteration shrink, middle-iteration
shrink, and clear-after-first structural changes for one/two/many input sizes;
these are observed current-fork outcomes rather than an unqualified promise of
container invalidation semantics.
