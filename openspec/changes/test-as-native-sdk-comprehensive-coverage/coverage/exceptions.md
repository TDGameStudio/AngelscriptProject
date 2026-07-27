# Exceptions, Propagation, and Recovery

## Dimensions

| Axis | Values |
| --- | --- |
| Origin | explicit script throw/current syntax, null access, divide/modulo/runtime fault where defined, bounds/custom native callback fault, host `SetException`, constructor/member/destructor/protocol callback |
| Call depth | top level, one nested call, three levels, recursion, method/base/virtual path, imported function |
| Handling | caught exact, nearest nested handler, outer handler, rethrow, uncaught, malformed handler |
| State interaction | normal execution, suspend request, abort, nested context state, callback installed/cleared, reuse with same/different signature |
| Cleanup state | no live values, locals, nested scopes, arguments, partial construction, base/members/derived, iterator, script object/reference |
| Metadata | text, exception function, section, row, column, stack depth/order, local/this inspection, callback event |
| Follow-up | unprepare, prepare same function, prepare different arity/type/return, rebuild module, release context, execute cleanly |

## Required products

- `Origin × call depth × caught/uncaught` for supported origin/handler combinations.
- `Call depth × metadata field` validates exact owning frame, section, row/column, and stack order before cleanup.
- `Cleanup state × exception point` proves exactly initialized values unwind in reverse order.
- `Handling mode × nested handler depth × rethrow` proves nearest selection and preservation/change of message/origin as defined.
- `Exception result × follow-up action` proves correct context cleanup and reuse with same and different signatures.
- `Exception callback installed/replaced/cleared × origin` links to native debug callback coverage.
- `Exception × suspend/abort/nested state` records distinct context results and legal recovery sequences.
- `Call depth × source layout` owns exact exception function, generated line/column/section, every retained script frame, and post-`Unprepare` callstack cleanup for top-level, nested, deep, and member-origin exceptions under LF, CRLF, and comment-separated source.
- `Unsupported handler form × function placement × line ending` retains active current-fork rejection evidence for `try/catch`, missing-handler, orphan-handler, and `rethrow` syntax. Every source must retain its compiler diagnostic, publish no partial entry, be discardable, and recover under the same module name with an independent valid function. The selected 2.38 positive behavior remains in the tagged Disabled conformance owner until the parser/compiler/runtime path is backported.

## Negative and boundary coverage

Malformed try/catch/rethrow syntax, throw/rethrow outside legal context, exception during cleanup, callback setting another exception, invalid context calls while active, stale metadata after unprepare, stack depth limit, long/empty messages, and module discard after exception are explicitly characterized.

## Planned ownership

- `Language/Exceptions/AngelscriptNativeExceptionPropagationTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionHandlerTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionMetadataTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionCleanupTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionContextRecoveryTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionStateInteractionTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionFailureTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionMetadataTests.cpp`
- `Language/Exceptions/AngelscriptNativeExceptionHandlingRejectionTests.cpp`
- raw stack/locals/callback details are shared IDs implemented under `Runtime/Debug`.
