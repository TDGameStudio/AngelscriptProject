# Typed native-call VM bridge

## Ordinary no-export Binding RED to GREEN evidence (2026-08-15)

The first ordinary installed-Bind fixture is now
`float32 TypedASTOrdinaryBridgeSqrt(float32)`, whose resolved system call is
`Math::Sqrt(float32)` / registered display `FMath::Sqrt`. It has no explicit
external-call descriptor and therefore must not be emitted as a guessed direct
DLL symbol. The exact AOT verification test first reached the generation
Engine successfully but selected the BytecodeJIT fallback, proving that the
gap was descriptor-only `NativeCallTargets` capture rather than AS frontend,
Bind installation, Cache V2, or HIR capture. RED evidence:
`Saved/Tests/typed-aot-ordinary-bridge-red-02/20260815_093830_717_951369cf`.

The production fix will not synthesize a fake external descriptor. Native
scalar ABI remains direct-linkage evidence. A separate VM-bridge ABI describes
only the AS-visible receiver/parameter directions/result and reviewed hidden,
lifetime and routing constraints. The first automatic admission slice is a
non-void global by-value primitive scalar `FunctionCaller` with no defaults,
hidden metadata, WorldContext, return-on-stack or compile-out rewrite. This
keeps methods, Generic callbacks, void emission and managed values closed until
their dedicated tests prove receiver/result/lifetime behavior.

The first slice is now GREEN. Capture accepts a descriptor-absent target only
when its current generation-Engine installed inventory row proves the exact
`FunctionCaller` scalar shape and both stable function-reference identity and
the separate VM-bridge ABI are valid. Explicit descriptor-backed registrations
remain independently capturable without an inventory row, preserving isolated
test/project registrations. Generated code names `FMath::Sqrt` only as reader
metadata, passes `ASJIT_Call_Sqrt_000f5a28` to
`InvokeBound<float, float>`, and dispatches through the adopted numeric slot.
The executed provider returns `12.0f` for `144.0f`; missing bridge ABI and a
disabled bridge Runtime both fail closed. Final focused evidence is recorded in
`implementation-progress.md` under the corresponding RED-to-GREEN section.

Inventory policy is independent of Git size: full row-level CSVs are generated
and retained under ignored `Saved/TypedSemanticAOT/NativeCallInventory/<run>/`
whenever useful for analysis. OpenSpec commits the reproducible generator,
count/size/hash and conclusions, never the large CSV itself.
Authoritative audit runs must not substitute the compact summary for this full
export: the complete CSV is generated first and remains available locally;
only its Git-tracking boundary is restricted.

## Purpose

TypedASTJIT generated code lives in a project-owned DLL. A registered
AngelScript system function may point at a provider-private C++ helper that is
callable by the AngelScript VM but cannot be named or linked from that DLL. The
bridge must preserve two properties:

1. the generated `.jit.cpp` tells a developer which AngelScript/C++ target the
   converted call represents; and
2. execution reaches the current Engine registration without persisting or
   guessing the private C++ function pointer.

This note records the maintained-fork evidence and selected implementation
contract. It does not open object, reference, container, hidden, suspend, or
other unreviewed ABI shapes in the first scalar slice.

## Maintained-fork evidence

### A resolved slot can retain the current function safely

`FAngelscriptJITReferenceIndexBuilder::AddScriptFunction()` in
`StaticJIT/AngelscriptJITReferenceResolver.cpp:329` stores the current
`asIScriptFunction*` and attaches `FScriptFunctionReferenceLifetime`, which
balances `AddRef`/`Release`. The resolved table therefore has the correct
lifetime vehicle for a current `asCScriptFunction`; generated output does not
need to retain a pointer or Engine-local FunctionId.

`FAngelscriptJITGeneratedReferenceAccess::GetScriptFunction()` in
`StaticJIT/StaticJITHeader.cpp:116` already demonstrates slot-indexed access
with reference-kind validation. TypedASTJIT should expose a narrower bridge
API rather than making generated semantic expressions depend on the generic
`FAngelscriptJITExecutionContext` utility.

### The VM call contract is already available through a pooled context

Existing BytecodeJIT dynamic-call lowering in
`StaticJIT/BytecodeJIT/AngelscriptBytecodes.cpp:1546-1613` emits this sequence:

```text
FAngelscriptContext CallContext(CallFunction->GetEngine())
CallContext->Prepare(CallFunction)
CallContext->SetObject / SetArg*
CallContext->Execute()
check Execution.bExceptionThrown and CallContext status
read the return registers
```

`FAngelscriptPooledContextBase::Init()` and its destructor in
`Core/AngelscriptEngine.cpp:2863-2970` reuse the active compatible context when
legal, otherwise take a matching context from the thread-local/global pool or
create one for the requested Engine, then restore or return it on scope exit.
TypedASTJIT must reuse this mechanism rather than create a second context pool.

`asCContext::Prepare()` and `SetArgByte/Word/DWord/QWord/Float/Double` in
`ThirdParty/angelscript/source/as_context.cpp:407-845` own the VM frame layout.
For a registered system function, `asCContext::Execute()` reaches
`CallSystemFunction()` (`as_callfunc.cpp:447`), which selects the registered
`CallFunctionCaller()` or `CallGeneric()`. Those implementations in
`as_context.cpp:5357-5559` consume the registration's real call convention,
object placement, parameter offsets, metadata argument, caller and return
placement. This is the authoritative path to an unexported Bind target.

Calling the provider-private pointer by a guessed C++ cast, copying the legacy
native-form spelling into an `extern` declaration, or invoking
`FStaticJITFunction::ScriptCallNative()` with an ad-hoc stack would duplicate
or bypass part of this contract and is rejected.

### Installed Engine dispatch is not the same as a native C++ signature

The fresh Win64/EditorDevelopment generation inventory contains 78,082 system
functions. The exact pointer-free `CallSystemFunction` route is:

```text
FunctionCaller   72,240
GenericFunction   1,175
GenericMethod     4,667
Native fallback       0
```

The 72,240 `FunctionCaller` rows still retain an internal registered function
or method pointer inside the current Engine, but that pointer is an operand to
the maintained type-erased caller. It is not evidence that a generated project
DLL can name, import, or safely cast the implementation. The 5,842 generic
rows are even more explicit: their callback ABI is
`void(asIScriptGeneric*)`, not the AS-visible `Return(Args...)` declaration.

Generation therefore records a `DispatchKind` enum after applying the same
precedence as `CallSystemFunction`: a bound caller wins; otherwise the route is
generic function, generic method, or the platform native fallback. No target or
caller address crosses the snapshot boundary.

`NativeScalarABI` remains a direct-C++-linkage fact. It may validate an
explicit exported/header-inline descriptor, but it must never admit or cast a
generic callback. VM bridge admission uses a separate AS-visible marshalling
identity for the receiver, visible parameters, directions, return and reviewed
lifetime/exception constraints, plus the stable expected target ABI. The first
implemented bridge slice may support a scalar generic global only after a test
proves that `Prepare/SetArg*/Execute` reaches its current `CallGeneric` callback;
generic methods and complex object/reference/container forms remain closed
until their own receiver and lifetime tests land.

At this checkpoint, all 835 classified scalar bridge candidates are
`FunctionCaller`-backed. The 5,842 generic rows deliberately remain
`unsupported` for TypedASTJIT rather than being misclassified from their AS
declaration text. Task 5.9 owns the separate bridge-marshalling identity and
task 5.7 owns the first real `CallFunctionCaller` plus `CallGeneric` execution
representatives.

### The outer JIT execution state must be threaded explicitly

`FScriptExecution` in `ThirdParty/angelscript/source/as_context.h:257` owns the
call-scoped Engine, binding payload, resolved reference table and fast
exception flag. Maintained JIT entry in `as_context.cpp:977-1025` constructs it
for the active JIT call and turns `bExceptionThrown` into
`asEXECUTION_EXCEPTION`.

A Typed body containing a bridge must therefore receive the existing
`FScriptExecution&`; generated expressions do not need to construct or name
`FAngelscriptJITExecutionContext`. A nested context temporarily becomes the
active AS context while it executes, then the pooled-context and execution
scopes restore the outer state.

The current legacy dynamic-call path only promotes failure to the outer
boolean. This change has a stronger already-recorded requirement: the bridge
must adopt the first nested exception string, function and source location into
the active exception payload exactly once before marking outer execution
failed. It must not log or replace the same primary failure twice.

## Selected generated-source contract

Every bridged call has one named immutable row in the same translation unit:

```cpp
// AS Bind             : int PrivateAdd(int, int)
// Route               : CurrentBindingSlot
// Emitted C++ Callee  : AngelscriptTypedASTJIT::InvokeBound<int32, int32, int32>
// Runtime DLL Core    : AngelscriptTypedASTJIT::InvokeBoundViaVM
// Registered Target   : FProviderPrivateBinds::PrivateAdd (registered, unexported)
static const FAngelscriptTypedASTJITBoundCallSite ASJIT_Call_PrivateAdd_a13f09c2 = {
    "int PrivateAdd(int, int)",
    "FProviderPrivateBinds::PrivateAdd",
    <stable-function-key>,
    <expected-abi>,
    7
};

const int32 ASJIT_Result =
    AngelscriptTypedASTJIT::InvokeBound<int32, int32, int32>(
        Execution, ASJIT_Call_PrivateAdd_a13f09c2, Left, Right);
if (UNLIKELY(Execution.bExceptionThrown))
{
    return <typed-entry-failure-value>;
}
```

The generated code answers two different questions truthfully:

- **What C++ function appears at the converted call site?** The header-defined
  `AngelscriptTypedASTJIT::InvokeBound<Return, Args...>` template.
- **What imported Runtime DLL function performs the VM-equivalent call?** The
  fixed non-template `ANGELSCRIPTRUNTIME_API`
  `AngelscriptTypedASTJIT::InvokeBoundViaVM` core used by that template.
- **What AS/Bind target does it represent?** The canonical declaration and
  optional registered C++ display spelling in
  `ASJIT_Call_PrivateAdd_a13f09c2`.

The row identifier follows
`ASJIT_Call_<sanitized-readable-function-name>_<short-stable-suffix>`. The
readable stem makes the converted source navigable, while the suffix
deterministically disambiguates overloads, namespaces and equal short names.
The full stable key remains in the row. Neither identifier component is read
to select the runtime target.

The strings are a static diagnostic view. `InvokeBound` may read them only
when constructing a failure/dump record. It must not copy, parse, hash, compare
or search them to select a target. Duplicate or changed display text cannot
redirect execution.

`Return, Args...` is the compile-time marshalling contract, not dispatch
identity. Stable function key plus expected ABI is resolved once while the
Provider is adopted; the row's deterministic integer index selects that
validated current slot during a call.

### Why the target name is metadata, not dispatch

The generated source needs a readable function name, but neither of the two
obvious name-driven implementations is safe:

- a bare string/declaration lookup on every call is ambiguous for overloads,
  wastes work on the hot path, and can silently follow a different registration
  after reload;
- encoding the target spelling as a template/tag still does not make a private
  C++ symbol linkable and would create target-specific template machinery while
  duplicating identity already owned by the Provider reference table.

The selected split is therefore exact and visible in generated C++:

1. `InvokeBound<Return, Args...>` is the literal C++ callee and compile-time ABI
   shape;
2. the named `FAngelscriptTypedASTJITBoundCallSite` row contains the canonical
   AS declaration and registered C++ display spelling for readers and failures;
3. `InvokeBoundViaVM` consumes the row's prevalidated numeric slot and never
   resolves either display string.

The generated expression passes the whole immutable row by `const&`, not a bare
function-name string. On the successful path the row's strings are untouched;
only an inspection or failure path may render them. This preserves the user's
ability to identify the exact represented Bind next to the converted call while
keeping overload, rebind, module unload, Engine replacement, and hot-reload
behavior tied to stable key + expected ABI + current slot.

This is the selected answer to the string-versus-template choice. Strings hold
the full AS declaration and registered C++ spelling for humans, failure
records and dumps. `Return, Args...` templates compile the marshalling shape.
Neither mechanism chooses the function: adoption resolves the full stable key
and expected ABI to a current numeric slot, and invocation consumes that slot.

## Runtime algorithm for the first scalar slice

`InvokeBound<Return, Args...>` is a thin header template: it statically checks
and packs the reviewed scalar/enum receiver, parameters and return storage into
the bridge's POD-like views, calls the exported non-template
`InvokeBoundViaVM`, and converts the reviewed result back to `Return`. The
non-template Runtime core performs these steps:

1. Read the resolved table from `FScriptExecution`, validate the row's slot
   index, reference kind, non-null value, current Engine and adoption state.
2. Treat the slot value as the retained current `asCScriptFunction`. Do not
   repeat stable-key/ABI matching and do not query a function by name.
3. Construct `FAngelscriptContext CallContext(Target->GetEngine())` so the
   maintained nested/pool behavior and Engine identity are preserved.
4. `Prepare(Target)`, set a receiver only for a proven receiver plan, and
   marshal materialized temporaries through reviewed `SetArg*` specializations.
   The first slice covers only proven scalar/enum ABI shapes.
5. Execute the context. It may run a script body or, for an unexported Bind,
   enter the registration's `CallFunctionCaller`/`CallGeneric` path.
6. On `asEXECUTION_FINISHED`, extract the result through the corresponding
   reviewed scalar return accessor and convert it to `Return`.
7. On exception, abort, suspend, preparation failure, stale slot or ABI/state
   failure, create/adopt one outer failure, set `Execution.bExceptionThrown`,
   and return the type's inert failure value. Generated code checks the flag
   immediately, before evaluating any later effect.
8. Let pooled-context and Typed frame scopes restore outer state on every exit.

## Fail-closed boundary

The bridge is not a universal FFI. Eligibility remains false when the target
requires any unimplemented object/reference/container ownership, return-on-
stack cleanup, hidden WorldContext/metadata argument, RPC/ProcessEvent/virtual
routing, suspension, ambiguous receiver, or exception-cleanup behavior.
Header-inline targets use ordinary direct C++. Exported or provider-private
targets with a separately reviewed raw scalar ABI use `CurrentNativeBinding`;
provider-private Generic/context-dependent targets use this VM bridge.
Everything else falls back with a typed reason.

## Verification matrix

Implementation is incomplete until tests prove all of the following:

- golden C++ contains the literal bridge callee and readable registered target
  name at the exact call site;
- identical slot/key/ABI with changed display strings reaches the same target,
  and duplicate display strings cannot redirect it;
- the same generated provider observes bind, rebind, unbind and Engine
  replacement through slot refresh/invalidation without regenerating C++;
- a private scalar system function receives exact arguments and returns the
  same value through VM, BytecodeJIT and TypedASTJIT;
- `CallFunctionCaller` and `CallGeneric` representatives are covered when the
  supported ABI claims them;
- nested exceptions preserve first message/function/section/row/column exactly
  once and suppress later operand effects;
- method/hidden/object/reference/container/suspend cases stay rejected until
  their separate marshalling/lifetime/routing tests land;
- generated source contains no private-symbol reference/redeclaration, raw
  pointer literal, Engine-local FunctionId, per-call string lookup, or
  `FAngelscriptJITExecutionContext`.

## Implemented call-site identifier and dedup contract

The selected implementation is
`AssignAngelscriptTypedASTJITBridgeCallSiteSymbols`. It operates over the full
function emission-plan set before C++ emission:

1. extract the readable function stem from the canonical AS declaration and
   replace every non-C++-identifier character with `_`;
2. group by that sanitized stem and the initially visible eight-hex stable-key
   prefix;
3. when distinct full stable keys collide, extend only that group by four hex
   digits and repeat until unique;
4. assign the same final symbol to repeated occurrences of one exact adopted
   target, rejecting contradictory declaration/registered-target/ABI/slot
   metadata for the same full key; and
5. emit each exact named immutable row once per generated function, while all
   call expressions reference that shared row.

This preserves readable ordinary output and makes the collision path
deterministic rather than probabilistic. The full key remains present in the
row and Provider reference record; shortening affects only the C++ identifier.

The runtime negative deliberately supplies duplicate and misleading display
strings for two different already-adopted slots. Slot zero still calls the
first retained `asCScriptFunction`, and slot one still calls the second. No
canonical declaration, registered C++ spelling, sanitized stem or short suffix
is parsed, hashed, compared or searched on the successful invocation path.

## 2026-08-15 generated-address and rebind audit

The current generated providers never serialize a process-specific numeric
native address into `.jit.cpp`. They do, however, intentionally have two
different native-call binding semantics:

- `DirectExported`/`DirectInline` emits the declared C++ symbol expression.
  The compiler and DLL loader resolve an exported symbol for the current
  process, so ASLR and a different process base address do not invalidate the
  source artifact. This path does not consult the current AngelScript Engine's
  registered-function table at invocation time and therefore does not follow
  an in-process replacement of that Bind with a different implementation.
- `Bridge` and the existing BytecodeJIT reference forms emit only an immutable
  stable key/expected ABI plus a numeric reference-table slot. Provider
  adoption resolves that identity against `CollectCurrentRegisteredFunctions`
  for the selected Engine, retains the current `asCScriptFunction`, and stores
  it in the Engine-local immutable table. Each invocation loads the slot once;
  it does not scan the database or look up a name. Rebind, module replacement,
  Engine replacement, or unload requires table replacement/invalidation and
  the unchanged generated artifact then observes the newly adopted target.

These are separate guarantees. A normal imported DLL symbol is reusable across
process loads and relocations, but it is not dynamically replaceable through
the AS Bind database. If the product invariant is strengthened so every
non-inline Bind must follow the implementation currently installed in the
selected Engine, `DirectExported` must be split from raw direct emission. The
preferred additional route is `CurrentNativeBindingSlot`: adoption validates
stable key + ABI and stores the current native callable in an Engine-local
slot; generated code performs one slot load and one typed indirect native call.
Provider-private Generic targets continue through `InvokeBoundViaVM`, while a
true header-inline expression remains the only route that embeds behavior in
the generated translation unit. This change trades one predictable indirection
for exact Bind replacement semantics without adding a VM context to ordinary
native calls.

## 2026-08-15 provider-private native ABI correction

DLL linkage and native-call ABI are orthogonal. `ProviderPrivate` means a
generated consumer may not spell or link the underlying C++ symbol; it does
not mean the current Engine lacks the registered raw address. A provider-
private target may therefore use `CurrentNativeBinding` when all of the
following facts are proven from the actual installed `asCScriptFunction` and
an explicit reviewed descriptor:

- system global with no receiver;
- exact supported by-value scalar return/parameter identity (including
  `void` return);
- `ICC_CDECL` or `ICC_STDCALL`, non-null `sysFuncIntf->func`, no hidden first
  metadata, default/determines-output/WorldContext argument, compile-out
  rewrite, or return-on-stack form;
- stable current-Engine `EnvironmentSymbol` reference and exact expected ABI;
- by-value/no-retained-reference/no-Engine-capture lifetime; and
- `DoesNotSetScriptException`.

The generated artifact still contains no private symbol or pointer. It emits
the same immutable stable-key/ABI/reference-slot row as exported
`CurrentNativeBinding`, and the Runtime resolver obtains the selected Engine's
current `sysFuncIntf->func` before one typed indirect call. Rebind and Engine
replacement consequently update behavior without regeneration.

`asCALL_GENERIC`, Generic methods, receiver-bearing/member calls, hidden or
managed shapes, and `MaySetScriptException` remain VM-only. In particular an
AS declaration such as `int Fail(int)` backed by
`void(asIScriptGeneric*)` does not have the native ABI it appears to have and
must never be cast to the AS-visible function type.
