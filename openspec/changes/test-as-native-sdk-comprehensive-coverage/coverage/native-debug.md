# Raw SDK Debug and Introspection

## Scope

This catalog covers direct native behavior of `asIScriptContext`, `asCContext`, and `asIScriptFunction`. It does not test the UE DebugServer, DAP messages, editor breakpoints, source navigation, or VS Code client.

## API families

| Family | APIs |
| --- | --- |
| Exception callback | `SetExceptionCallback`, invocation, replacement, `ClearExceptionCallback`, exception metadata, and concrete `asCContext::WillExceptionBeCaught` disposition |
| Instruction callback | `SetInstructionCallback`, callback phase/opcode/name/register pointers/user data, clear/replacement |
| Fork line/loop callbacks | `asCContext::SetLineCallback`, `SetLoopDetectionCallback`, `ClearLineCallback` and current callback cadence |
| Fork stack-pop callback | `SetStackPopCallback`, `ClearStackPopCallback`, old-frame range, normal/return/exception/unprepare cleanup |
| Call stack | `GetCallstackSize`, `GetFunction`, `GetBlueprintCallstackFrame`, `GetLineNumber` |
| Locals | `GetVarCount`, `GetVarName`, `GetVarDeclaration`, `GetVarTypeId`, `GetAddressOfVar`, `IsVarInScope` |
| Receiver | `GetThisTypeId`, `GetThisPointer` |
| Nested state | `PushState`, `PopState`, `IsNested`, outer/inner function and state preservation |
| Concrete frame | `asCContext::GetStackFrame`, `GetStackFrameSize`, frame pointer/size boundaries |
| Function debug metadata | `asIScriptFunction::GetVarCount`, `GetVar`, `GetVarDecl`, `FindNextLineWithCode`, section name, bytecode pointer/length |

## Callback dimensions

| Axis | Values |
| --- | --- |
| Callback state | absent, installed, replaced, cleared, cleared twice, context reused |
| Execution path | straight line, branch selected/not selected, loop 0/1/many, nested calls, recursion, method, exception, suspend/abort request |
| Callback action | observe only, count/record, request suspend/abort where legal, set exception, inspect frames/locals, no-op |
| User data | null, pointer to case-owned recorder, replacement recorder |
| Outcome | exact event order/count, instruction phase/opcode data, source line sequence, stack-pop range, context state/result, no callback after clear |

Required products:

- `Callback family × state × execution path` for representative control paths, with installed/replaced/cleared behavior.
- `Instruction phase × representative opcode family × nested depth` where the fork exposes phase/opcode data.
- `Line callback × branch/loop path × source layout(LF/CRLF/preserve-lines)` with exact reached line sequence.
- `Stack-pop callback × exit path(normal/return/exception/unprepare) × frame depth` with valid pointer range and event order.
- Callback reentrancy/illegal operations are isolated and characterized; tests must not destabilize the process.

## Stack and source dimensions

| Axis | Values |
| --- | --- |
| Frame depth | 1, 2, 3, recursion, configured/deep representative |
| Call shape | global→global, global→method, method→method, base/virtual dispatch, imported function, nested context state |
| Observation state | callback during execution, suspended state if supported, exception state with caught/unhandled disposition, finished state, unprepared/invalid state |
| Frame index | first/current, middle, last/root, exactly out of range, large invalid |
| Source | one/multiple sections, namespace, LF/CRLF, blank/comment lines, optimized/unoptimized, build without line cues if supported |
| Result | stack depth, function identity/declaration, section, line, column, blueprint-frame value, invalid result |

Required products:

- `Frame depth × valid frame index × function/line/section query`.
- `Observation state × frame query family` records when data remains valid and when it resets.
- `Exception disposition × asCContext::WillExceptionBeCaught` directly observes the raw-context value at a real fault: the enabled current-fork unhandled path is `false`, while the selected-2.38 tagged try/catch owner retains the `true` case until its parser/compiler/runtime support is enabled.
- `Source shape × executable line × FindNextLineWithCode/GetLineNumber` correlates static function metadata with live frames.
- Invalid frame indexes are tested for every query family without dereferencing returned null/invalid data.

## Local-variable dimensions

| Axis | Values |
| --- | --- |
| Variable type | every primitive family, enum/alias, value object, automatic reference/null, parameter, `this`, native object where legal |
| Storage/role | parameter, local, nested-block local, loop local, temporary-visible-if-defined, shadowed local, return storage excluded/characterized |
| Scope state | before declaration, initialized/in scope, inner shadow active, after inner exit, after outer exit, exception point |
| Frame | current, caller, root, nested-state outer/inner |
| Query | count, name, declaration with/without namespace, type ID, address, scope, read value, mutate-through-address only if API contract permits |
| Optimization | optimize on/off, line cues on/off where meaningful |

Required products:

- `Variable type × role(parameter/local) × query family`.
- `Scope state × IsVarInScope × address availability` for nested/shadowed/loop variables.
- `Frame × query family × valid/invalid variable index`.
- `Shadowed name × frame/scope × address/value` proves correct identity.
- `Optimization mode × local metadata/address/scope` records the exact supported debug contract and any optimized-away behavior.

## Receiver dimensions

- `Call shape(global/member/base/derived/virtual) × frame × GetThisTypeId/GetThisPointer`.
- Base and derived views must distinguish declared receiver type from runtime pointer behavior according to the fork.
- Global frames, invalid frames, null object errors, finished/unprepared contexts, and nested outer/inner states have explicit results.

## Nested context-state dimensions

- `PushState` from prepared, active-callback, suspended-if-supported, exception, finished, and unprepared states.
- `Nest count {0,1,2}` × `IsNested` with and without output pointer.
- Outer function signature/state/arguments/return/exception/debug frame are captured before push, an inner function with same and different signature executes, and `PopState` restores the outer state exactly.
- Invalid `PopState` at nesting zero, repeated push/pop, inner exception, inner abort/suspend, callback installation, and context reuse are covered.
- The test never assumes `Suspend()` succeeds; it asserts the current fork's active result and keeps any desired 2.38 behavior separate.

## Function metadata dimensions

- `GetVarCount/GetVar/GetVarDecl` across parameter/local types, shadowed variables, namespaces, and optimize modes.
- `FindNextLineWithCode` from before first line, exact executable line, blank/comment line, between statements, final line, and after end.
- `GetByteCode` pointer/length for script/system/imported/no-op functions as applicable, before/after rebuild, optimize on/off, and loaded bytecode.
- Section/module/name/declaration identity correlates with live stack frames and exception metadata.

## Planned ownership

- `Runtime/Debug/AngelscriptNativeExceptionCallbackTests.cpp`
- `Runtime/Debug/AngelscriptNativeInstructionCallbackTests.cpp`
- `Runtime/Debug/AngelscriptNativeLineCallbackTests.cpp`
- `Runtime/Debug/AngelscriptNativeLineCallbackSourceTests.cpp` — the first enabled source-path × line-ending × callback-state depth owner; it is intentionally separate from the broader callback lifecycle owner so each selected executable marker and excluded branch/body remains reviewable.
- `Runtime/Debug/AngelscriptNativeStackPopCallbackTests.cpp`
- `Runtime/Debug/AngelscriptNativeStackPopCallbackDepthTests.cpp` — exit-path × call-depth × callback-state evidence for old-frame ranges and same-context recovery.
- `Runtime/Debug/AngelscriptNativeCallstackTests.cpp`
- `Runtime/Debug/AngelscriptNativeSourceLocationTests.cpp`
- `Runtime/Debug/AngelscriptNativeLocalVariableTests.cpp`
- `Runtime/Debug/AngelscriptNativeThisPointerTests.cpp`
- `Runtime/Debug/AngelscriptNativeNestedContextTests.cpp`
- `Runtime/Debug/AngelscriptNativeNestedContextDepthTests.cpp` — nested depth × same/different signature × success/exception/rejected suspend/abort action evidence for `PushState`, `PopState`, `IsNested`, caller restoration, and same-context cleanup.
- `Runtime/Debug/AngelscriptNativeConcreteStackFrameTests.cpp`
- `Runtime/Debug/AngelscriptNativeFunctionDebugMetadataTests.cpp`
- `Runtime/Debug/AngelscriptNativeDebugInvalidStateTests.cpp`

## Safety

Callbacks use case-owned POD recorders and no UE wrapper. Raw stack pointers are compared/range-checked but not read beyond the public/fork contract. Invalid indexes are tested through return values only. Any crash-prone internal operation first receives a narrow characterization test and cannot be placed in a broad batch.
