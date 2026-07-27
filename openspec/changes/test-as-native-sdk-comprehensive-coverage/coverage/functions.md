# Functions and Parameter Lists

## Elements

This theme covers declaration, exact lookup, calls, parameters, returns, overloads, default arguments, recursion, funcdef/delegate invocation, mixin global functions, methods, namespaces, const methods, and resolution failures. Host registration and calling conventions remain Embedding-owned.

## Dimensions

| Axis | Values |
| --- | --- |
| Call target | global, namespace global, instance method, base-qualified method, virtual override, mixin global, funcdef/delegate, imported function |
| Arity | 0, 1, 2, 3, representative many, configured 64/65 stress points, plus an isolated wrong-count rejection; no fixed fork maximum is assumed without runtime evidence |
| Position | only, first, middle, last |
| Parameter type | every signed/unsigned integer width, bool, current float families/ABI, enum, typedef/alias, script value object, script automatic reference, registered native value/reference object, funcdef where legal |
| Direction | value/default, `&in`, `&out`, `&inout`; constrained by type legality |
| Qualifier | mutable, const input, const receiver, legal reference qualifier combinations, illegal duplicates/conflicts |
| Argument source | literal, local lvalue, const local, global const, field/member, function return, arithmetic expression, conditional expression, null, base view, derived view |
| Default pattern | none, final one, final many, all optional, explicit override, mixed omitted/provided, non-trailing invalid, type-invalid default, earlier-parameter reference invalid |
| Return | void, each primitive family, enum/alias, value object, automatic reference, null/reference, funcdef where legal |
| Return path | direct, if/else, switch, early return, recursive base, exception/no return, invalid missing return, incompatible return |
| Resolution | exact match, promotion, explicit-only conversion, arity distinction, direction/const distinction, namespace distinction, method constness, one ambiguity, no match, inaccessible |
| Invocation | direct, nested, self-recursive, mutual-recursive, callback/indirect, imported, after rebuild, after exception reuse |

## Required complete products

1. `Parameter type × legal direction` for one-parameter functions. Every cell validates declaration text, argument transfer, writeback where applicable, and cleanup.
2. `Parameter type × position(first/middle/last) × direction` in a three-parameter signature, constrained to legal forms. Sentinel values prove ABI slot order and that only the intended `out/inout` slot changes.
3. `Arity × call target` for zero through representative-many parameters. The 64/65 stress points receive a dedicated owner; they characterize the current fork rather than claiming that 64 is a language maximum. Wrong-count rejection is tested separately.
4. `Default pattern × omission count × call target(global/method/namespace)` with exact selected declaration and runtime result.
5. `Parameter type × direction × default/call state × call target` is owned separately so value/`&in` default temporaries and missing/omitted `&out`/`&inout` calls cannot be inferred from independent direction/default owners. Every 11 primitive types × four directions × four states × three targets cell retains source, parameter flags/default metadata, exact diagnostic or runtime transfer/writeback, and cleanup.
6. `Return type × return path` for all legal type categories, including type-correct context accessors and the fork's double-backed float behavior.
7. `Overload discriminator(type/arity/const/direction/namespace) × outcome(exact/promotion/ambiguous/missing)` with the selected function ID/declaration and runtime marker.
8. `Argument source × direction` for legal sources. Illegal temporary/const/out combinations assert one exact diagnostic.
9. `Core indirect mechanism × scenario` for registered funcdef metadata/compatibility, the current script-funcdef rejection, mixin dispatch, and imported-function binding/rebinding. UE delegate integration is deliberately excluded from the raw SDK suite.
10. `Failure stage × initialized-value count × value argument/return transfer` with ordered construction/copy/destruction evidence and context reuse.

## Required interaction products

- overload × implicit conversion × default argument;
- overload × const receiver × base/derived view;
- recursive depth `{0,1,many,configured limit}` × parameter type `{primitive,value object,reference}` × outcome `{return,exception}`;
- funcdef/delegate null/non-null × compatible/incompatible signature × direct/nested invocation;
- parameter direction × constructor/copy/destructor counters for value objects;
- exception at parameter evaluation/body/return construction × already initialized arguments × cleanup order;
- rebuild/save-load × exact declaration × changed implementation result.

## Negative and boundary coverage

Wrong count, wrong type, wrong direction, const violation, duplicate signature, return mismatch, missing return, illegal default ordering, invalid default expression, inaccessible method, ambiguous overload, recursive limit, null delegate, and stale function use after rebuild/discard must each have isolated diagnostics/state assertions.

## Planned ownership

- `Language/Functions/AngelscriptNativeFunctionParameterDirectionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionParameterPositionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionArityTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionDefaultArgumentTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionDirectionDefaultTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionReturnTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionOverloadResolutionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionRecursionTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionValueLifecycleTests.cpp`
- `Language/Functions/AngelscriptNativeFunctionFailureTests.cpp`
