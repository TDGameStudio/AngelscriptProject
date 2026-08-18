## ADDED Requirements

### Requirement: External native calls require an explicit linkage contract

A generated StaticJIT project module SHALL directly name a native binding target only when its native-call descriptor proves an externally consumable declaration, linkage kind, owning module, supported typed ABI, and safe routing. Existing `NativeFunction`, `NativeMethod`, or generated C++ name metadata alone SHALL NOT prove cross-module linkability.

#### Scenario: Exported Runtime symbol supplies a reviewed current-native contract

- **WHEN** a Runtime-owned scalar call target has external linkage, an includable declaration marked `ANGELSCRIPTRUNTIME_API`, a declared owning module/header, a matching typed ABI, and safe routing
- **THEN** TypedASTJIT may emit a `CurrentNativeBinding` call from the generated project module
- **AND** Provider adoption resolves stable key plus expected ABI against the selected Engine and the generated call loads that registration's current native address from its deterministic slot
- **AND** the generated expression does not freeze the exported symbol or a numeric address as executable identity

#### Scenario: Linkage metadata exists before value lowering is supported

- **WHEN** an exported Runtime callable has an exact installed native-call identity and complete routing/default/compile-out/exception/lifetime metadata, but its object or managed-value ABI is not yet supported by the TypedASTJIT emitter
- **THEN** the complete inventory retains that accurate descriptor and classifies its lowering domain as deferred
- **AND** direct-call validation reports `TypedABIUnavailable` rather than pretending the callable is scalar-compatible or discarding its known linkage
- **AND** no generated direct call is emitted until the dedicated value materialization and cleanup contract is proven

#### Scenario: Existing native form has no external contract

- **WHEN** a binding has a legacy `NativeFunction` or `NativeMethod` spelling but no explicit external linkage descriptor
- **THEN** TypedASTJIT classifies it as non-direct
- **AND** it uses a proven scalar bridge or makes the root ineligible rather than guessing that the symbol is exported

#### Scenario: Declaration is visible but symbol is not exported

- **WHEN** a target declaration can be included but its out-of-line implementation belongs to another DLL and lacks that module's import/export API contract
- **THEN** the target is not externally direct-callable
- **AND** compile-only visibility is not reported as successful linkability

#### Scenario: Provider-private scalar target reuses the current registered address

- **WHEN** an unexported provider-private system global has an explicit reviewed scalar descriptor, the actual installed function is `CDECL` or `STDCALL`, its AS-visible return and arguments exactly match the supported by-value native scalar ABI, it has no receiver/default/hidden/WorldContext/return-on-stack/compile-out behavior, and it cannot set a script exception
- **THEN** TypedASTJIT emits `CurrentNativeBinding` rather than `InvokeBoundViaVM`
- **AND** generated C++ names neither the private symbol nor a raw pointer, but passes the immutable stable key, expected ABI and deterministic slot row to `InvokeBoundNative<Return, Args...>`
- **AND** the Runtime resolver loads the selected Engine registration's current `sysFuncIntf->func` and performs one typed indirect native call without creating an AngelScript context
- **AND** DLL visibility is not used as a proxy for native ABI safety

#### Scenario: Provider-private Generic target remains VM-dispatched

- **WHEN** the AS-visible scalar declaration is implemented by `void(asIScriptGeneric*)`, a Generic method, a receiver-bearing callable, a hidden/default/WorldContext/return-on-stack form, or a target that may set a script exception
- **THEN** it is never cast to the AS-visible native function type
- **AND** a separately reviewed bridge shape may use `InvokeBoundViaVM`; otherwise the root falls back with a typed reason

### Requirement: Header-inline and module-exported targets remain distinct

The native-call descriptor SHALL distinguish fully defined header-inline/template targets from out-of-line exported symbols and SHALL validate the dependencies needed by the generated consumer module.

The descriptor's installed native-call identity SHALL match the exact current Engine registration after calling convention, parameter/return layout, function traits, default/hidden arguments and compile-out policy are applied. Its lowering-domain identity SHALL separately prove that the emitter supports those values; source spelling or a public C++ signature alone SHALL NOT substitute for either check.

#### Scenario: Header-inline target needs no DLL export

- **WHEN** the complete supported function or template specialization is defined in an includable header and every required dependency is legal for the generated module
- **THEN** it may be classified `HeaderInline`
- **AND** no `_API` export is required solely for that inline definition

#### Scenario: Engine-owned target uses its owning module API

- **WHEN** the direct target is already publicly declared and exported by an Unreal Engine module
- **THEN** its descriptor records that header and owning module
- **AND** the plugin does not add `ANGELSCRIPTRUNTIME_API` to the Engine declaration

#### Scenario: Private module dependency blocks direct inclusion

- **WHEN** a candidate header depends on a module that is not a legal public dependency of the generated project module
- **THEN** the candidate is not classified as a public direct-call surface
- **AND** Runtime may expose a narrow thunk or the call may bridge/fall back

### Requirement: Runtime exports a reviewed callable surface, not binding providers wholesale

Runtime-owned FBind implementations selected for external direct calls SHALL have a narrow includable declaration marked `ANGELSCRIPTRUNTIME_API`, or SHALL be reached through a narrow exported Runtime thunk when their provider/helper type should remain private.

The change SHALL inventory every installed `Bind_*.cpp` callable and assign a stable direct-export, inline, exported-callable, bridge, compile-out, or unsupported disposition. No callable may be treated as directly available merely because it lacks an inventory row.

#### Scenario: Actual exported callable remains current-Engine selected

- **WHEN** a Runtime-owned Bind implementation can be represented by a stable public C++ signature
- **THEN** Runtime prefers an `ANGELSCRIPTRUNTIME_API` namespaced free function as the actual implementation
- **AND** the Bind registration stores that implementation in the Engine database while generated code retains only its stable identity, expected ABI and slot
- **AND** the generated call resolves and invokes the current slot's non-generic native address without passing through the AngelScript VM or a generic caller

#### Scenario: Every installed Bind has an explicit disposition

- **WHEN** the Bind registration inventory is generated and reviewed
- **THEN** every installed AS callable appears exactly once with its authoritative AS identity and implementation route
- **AND** direct-capable functions have importable linkage descriptors
- **AND** complex functions explicitly identify bridge, compile-out, or unsupported behavior instead of remaining unknown

#### Scenario: Private FBind helper receives an exported thunk

- **WHEN** an eligible scalar binding implementation is provider-private or declared only in `Bind_*.cpp`
- **THEN** Runtime may publish a stable `ANGELSCRIPTRUNTIME_API` thunk with the exact supported signature
- **AND** the generated module calls the thunk while the provider class remains private

#### Scenario: Selected helper is intentionally public

- **WHEN** a reviewed binding helper is itself an appropriate supported Runtime API
- **THEN** its declaration is moved to a legal public header and marked with `ANGELSCRIPTRUNTIME_API`
- **AND** its external native-call descriptor names that declaration, header, and owning module

#### Scenario: Binding registrar lambda remains private

- **WHEN** `FAngelscriptBind` uses a lambda only to register functions during bind installation
- **THEN** the registrar lambda is not exported and is not treated as a script-call target
- **AND** direct-call eligibility is determined from the registered callable target and its external descriptor

### Requirement: Complete row-level inventory remains available as a local analysis artifact

Every authoritative native-call inventory run SHALL materialize and retain the complete row-level CSV, including unsupported, bridge, compile-out, generic, and unresolved records. Repository-size policy SHALL only control where that derived artifact is stored: the full CSV MUST be written beneath an ignored local output such as `Saved/TypedSemanticAOT/NativeCallInventory/<run>/` (or an equivalent path outside the repository), while Git retains only deterministic generators, compact summaries, hashes, reconciliation evidence, and conclusions. A compact summary MUST NOT replace or truncate the complete local export.

#### Scenario: Full inventory is generated without entering Git

- **WHEN** an authoritative inventory or reconciliation run completes
- **THEN** the complete row-level CSV remains locally available for unrestricted querying and later re-analysis
- **AND** its row count, byte size, and content hash are recorded in committed evidence
- **AND** Git ignore/tracking checks prove that the large CSV itself is not staged or committed

#### Scenario: Inventory contract or installed surface changes

- **WHEN** descriptor, routing, call-site, Provider, or installed-Engine data changes after an earlier accepted export
- **THEN** verification regenerates a fresh complete row-level CSV from the current authoritative inputs
- **AND** it does not reuse only the earlier compact summary as evidence

### Requirement: Missing linkage degrades to bridge or typed fallback

Failure to prove cross-module native linkage SHALL NOT produce generated code that relies on an unresolved symbol. The call classifier SHALL choose an exported/inline direct entry, an exported Runtime thunk, the scalar bridge, or typed root fallback in that order according to available contracts.

#### Scenario: Private target has a scalar bridge

- **WHEN** the resolved target has no external direct symbol but its scalar parameters, return, exception behavior, and routing are supported by the bridge
- **THEN** the TypedASTJIT caller remains eligible and invokes the bridge
- **AND** diagnostics identify the call as bridged because its native target is provider-private or unexported

#### Scenario: Generated bridge call is readable but does not resolve by name per call

- **WHEN** generated C++ invokes a private or unexported AS/native target
- **THEN** the same generated `.jit.cpp` contains an immutable named call-site metadata row with the canonical AS declaration and the registered C++ callable display spelling when one exists
- **AND** the row's generated C++ identifier uses a sanitized readable function-name stem plus a short deterministic stable-identity suffix, so overloads and equal short names remain distinct without exposing a full hash in every expression
- **AND** its metadata distinguishes `Emitted C++ Callee`, `Runtime DLL Core`, and `Registered Target`
- **AND** the literal generated C++ callee is the header-defined typed `InvokeBound` template, which calls the fixed exported non-template `InvokeBoundViaVM` Runtime core, so the source does not falsely imply that the private target is linked directly
- **AND** the `InvokeBound<Return, Args...>` template arguments expose the concrete typed marshalling shape
- **AND** the generated call passes its metadata row by reference to `InvokeBound`, making the intended target name visible beside the converted call
- **AND** the row identifies the target by stable function key, expected ABI and deterministic reference-slot index
- **AND** Provider/Engine initialization resolves that identity once into a deterministic reference slot
- **AND** the hot invocation path uses a typed `InvokeBound` template plus that slot instead of a raw pointer, Engine-local function ID, or repeated string lookup, parsing or hashing

#### Scenario: Generated native call names the registered target but executes the current slot

- **WHEN** generated C++ invokes an exported non-inline target or a header-inline target
- **THEN** its metadata comment contains the canonical AS declaration, exact registered C++ callable spelling, and selected route
- **AND** `HeaderInline` calls the inline symbol while an exported non-inline Bind calls `InvokeBoundNative<Return, Args...>` with the current-Engine slot
- **AND** the non-inline generated expression contains neither a target-symbol invocation nor a persisted native pointer
- **AND** the Provider manifest and diagnostics expose the same mapping for offline inspection

#### Scenario: Display strings never become dispatch identity

- **WHEN** canonical declarations or native callable names are emitted as strings for comments, manifests, or diagnostics
- **THEN** overload selection and runtime dispatch still use the stable function key, expected ABI, and resolved reference slot
- **AND** passing the immutable call-site metadata row to the bridge does not copy, parse, hash or search either display string on the hot path
- **AND** renaming or duplicate display text cannot redirect a call
- **AND** a stale, missing, or ABI-mismatched slot fails closed before the registered caller is executed

#### Scenario: Bridge reuses authoritative AngelScript registered caller

- **WHEN** a current reference slot resolves an unexported system function
- **THEN** the Runtime bridge obtains the retained current `asCScriptFunction` from the validated numeric slot, prepares it in the maintained pooled `FAngelscriptContext`, marshals the proven typed arguments through reviewed `SetArg*` specializations, and executes it
- **AND** system-function execution reaches the maintained `CallSystemFunction -> CallFunctionCaller/CallGeneric` route, so the registered calling convention, object placement, metadata arguments, parameter offsets, caller and return rules remain authoritative
- **AND** the header-defined `InvokeBound<Return, Args...>` template owns typed scalar packing while the only cross-DLL bridge call is the fixed `ANGELSCRIPTRUNTIME_API AngelscriptTypedASTJIT::InvokeBoundViaVM` core
- **AND** the target's current function pointer is obtained from the Engine binding database rather than persisted in generated output
- **AND** nested exception state is adopted into the outer execution exactly once
- **AND** the bridge does not call a guessed pointer cast, synthesize an `extern` declaration, or maintain a second context pool/caller implementation

#### Scenario: Internal FunctionCaller and generic callbacks remain distinct

- **WHEN** the installed system-function interface contains a private target pointer together with either a bound `FunctionCaller` or an `asCALL_GENERIC` function/method convention
- **THEN** generation records the pointer-free authoritative dispatch kind selected by `CallSystemFunction`, with `FunctionCaller` taking precedence
- **AND** neither the registered target pointer nor the caller pointer is copied into the inventory, Provider manifest, or generated `.jit.cpp`
- **AND** a generic callback is never treated as `Return(Args...)` native C++ ABI and is never direct-called through a cast
- **AND** generic bridge eligibility is derived from a separately reviewed AS-visible argument/result marshalling shape and stable expected target ABI
- **AND** an eligible generic bridge reaches the current registration through `Prepare/SetArg*/Execute -> CallGeneric`, while an unreviewed shape remains typed fallback

#### Scenario: Template types and target names have separate responsibilities

- **WHEN** generated C++ emits `InvokeBound<Return, Args...>(Execution, CallSiteRow, ...)`
- **THEN** `Return, Args...` define the compile-time scalar marshalling shape
- **AND** the row's canonical AS declaration and registered C++ target string explain which function the bridge call represents to a source reader and diagnostic tool
- **AND** the source-visible row identifier, comment and dump retain the readable name even though the template arguments contain only types
- **AND** stable key plus expected ABI is resolved once into the numeric slot that owns actual dispatch identity
- **AND** changing or duplicating either display string without changing the validated slot cannot change the invoked function

#### Scenario: Bridge target is inspectable before and after binding changes

- **WHEN** a developer inspects generated source, the Provider manifest, or the Runtime native-call dump for a bridged call
- **THEN** the view renders `AS declaration -> InvokeBound<Return, Args...> -> InvokeBoundViaVM -> reference slot -> current registered target`
- **AND** it reports the stable key, expected ABI and current bound, unbound, stale or ABI-mismatch state
- **AND** the registered-target display string is diagnostic metadata rather than the lookup key

#### Scenario: Current binding slot becomes stale

- **WHEN** the Engine is replaced, a binding is rebound or unbound, or its owning module unloads
- **THEN** the reference slot is updated or invalidated before another invocation
- **AND** an invalid or ABI-mismatched slot fails closed without calling the old pointer

#### Scenario: Private target cannot be bridged

- **WHEN** the resolved target is neither externally callable nor supported by the bridge
- **THEN** the root receives `UnsupportedCall` with a stable external-linkage detail and source span
- **AND** no C++ reference to the private symbol is emitted

### Requirement: Cross-DLL linkability is verified by a separate consumer module

Every Runtime-owned native symbol or thunk advertised as externally direct-callable SHALL be compiled and linked from a UE module other than `AngelscriptRuntime`; generated-text and same-module tests alone are insufficient evidence.

#### Scenario: Missing API export fails the contract test

- **WHEN** an advertised out-of-line Runtime symbol has an includable declaration but is missing `ANGELSCRIPTRUNTIME_API` or has internal linkage
- **THEN** the separate consumer-module build fails the linkage gate or its descriptor validation fails before generation
- **AND** the symbol cannot be accepted as an external direct target

#### Scenario: Exported target links and executes

- **WHEN** the consumer module includes the declared header, links the exported symbol/thunk, and invokes it with the supported scalar ABI
- **THEN** the cross-module link test passes
- **AND** an AOT fixture proves the generated provider calls the same target without a bridge
