## ADDED Requirements

### Requirement: StaticJIT BackendId and capture profile are explicit at generation time

StaticJIT generation SHALL use the internal stable BackendIds `"bytecode"` and `"typed-ast"`, SHALL default to `"bytecode"`, SHALL freeze BackendId and typed-HIR capture before the generation Engine compiles target source, and SHALL validate the request/capture profile before constructing the generation view. `"dual"` MUST NOT be registered as a backend.

#### Scenario: Missing backend option preserves BytecodeJIT behavior

- **WHEN** precompiled-data generation runs without an explicit StaticJIT backend option
- **THEN** it selects `"bytecode"`
- **AND** it uses the existing bytecode-to-C++ generation path without retaining typed HIR

#### Scenario: TypedASTJIT enables HIR before source compilation

- **WHEN** generation selects `"typed-ast"`
- **THEN** typed HIR capture is enabled before any target module source is compiled
- **AND** eligible functions use TypedASTJIT while other functions fall back per function through BytecodeJIT to VM

#### Scenario: Programmatic generation validates the compiled capture profile

- **WHEN** a Provider-artifact API or test helper requests `"typed-ast"` output for functions produced by a capture-off Engine
- **THEN** the complete generation fails with `CaptureProfileMismatch`
- **AND** it does not recompile inside the backend or relabel BytecodeJIT output as TypedASTJIT output

#### Scenario: Differential generation is restricted to tests

- **WHEN** a development AOT fixture compares Static backends
- **THEN** it runs isolated `"bytecode"` and `"typed-ast"` generation tasks and may expose independent test entries
- **AND** production generation publishes only the requested task and never enables shadow execution

#### Scenario: Invalid backend value is rejected

- **WHEN** generation receives an unknown backend value
- **THEN** generation fails with a diagnostic listing `bytecode` and `typed-ast`
- **AND** it does not silently substitute another backend

#### Scenario: Runtime routing cannot transpile a missing backend

- **WHEN** a loaded Provider contains only BytecodeJIT or VM entries for a function
- **THEN** changing a runtime setting cannot create a TypedASTJIT body for that function
- **AND** TypedASTJIT C++ generation remains a build-time Static operation rather than a Runtime JIT tier

### Requirement: TypedASTJIT generation uses a complete side-effect-free source build

The orchestrator SHALL create one generation-only `FAngelscriptEngine` for the selected target profile, replay the complete sealed Bind collection into that Engine, compile the complete Provider source graph from source with typed-HIR capture enabled, and perform ClassGenerator descriptor analysis without materializing script reflection. The immutable backend input SHALL expose the full result as `CompiledSourceGraph` and carry a separate `EmitModuleSet`. `FAngelscriptTypedASTJIT` MUST NOT trigger compilation itself.

#### Scenario: Reflected scripts are compiled for generation

- **WHEN** the source graph declares UCLASS, USTRUCT, delegate, UPROPERTY, and UFUNCTION surfaces
- **THEN** `CompiledSourceGraph` resolves descriptors, function roots, receivers, signatures, shared Entry Plans, artifact dependencies, and external native-call descriptors
- **AND** no script UClass, UScriptStruct, UDelegateFunction, UFunction, CDO, class redirect, reload, or reinstancing state is created

#### Scenario: Temporary Engine has a complete native type surface

- **WHEN** TypedASTJIT source compilation resolves a native bound type or callable
- **THEN** that declaration and its native-call metadata come from the complete target-profile Bind replay into the temporary `asIScriptEngine`
- **AND** existing native UE reflection is observed rather than recreated or rebound as new `UClass` objects

#### Scenario: Complete graph is compiled but selected modules are emitted

- **WHEN** one generation request selects a subset of modules from a Provider source domain
- **THEN** Bind, overload, import, global, and helper semantics come from one complete target-profile source compile
- **AND** Provider packaging emits only `EmitModuleSet`

#### Scenario: Generation Engine is destroyed

- **WHEN** synchronous TypedASTJIT analysis/emission and Provider packaging finish
- **THEN** all HIR, type/function objects, descriptors, and Engine-local IDs are destroyed with the generation Engine
- **AND** output retains only stable identity, stable references, generated C++, provenance, and diagnostics

### Requirement: TypedASTJIT initially targets a safe UFUNCTION subset

TypedASTJIT SHALL classify roots from the generation view's resolved `FAngelscriptFunctionDesc::ScriptFunction` identity and SHALL emit only concrete ordinary UFUNCTION bodies whose reflected ABI and HIR are inside the initial scalar contract.

#### Scenario: Ordinary scalar UFUNCTION is eligible

- **WHEN** a concrete non-event UFUNCTION has only by-value void/bool/integer/float/double/enum parameters and return, has verified supported HIR, and requires no unsupported routing or lifetime behavior
- **THEN** the function is eligible for TypedASTJIT
- **AND** overload or root identification uses resolved function identity rather than name matching

#### Scenario: Special Unreal dispatch function is ineligible

- **WHEN** a UFUNCTION is RPC/net, BlueprintEvent, BlueprintOverride, virtual/non-final, thread-safe-special, suspendable, a validation/event wrapper, or depends on generated WorldContext injection
- **THEN** TypedASTJIT rejects it with `UnsupportedUFunctionFlags` or the more specific maintained reason
- **AND** Unreal routing is not bypassed

#### Scenario: Complex signature is ineligible

- **WHEN** a UFUNCTION signature contains references, out parameters, handles, UObjects, structs, containers, delegates, or return-on-stack values
- **THEN** TypedASTJIT rejects it with a source-visible unsupported signature/type reason
- **AND** the function remains available through BytecodeJIT or VM execution

#### Scenario: Unsupported body is ineligible

- **WHEN** an otherwise safe UFUNCTION contains an unsupported HIR expression, statement, lifetime, exception-cleanup, or suspend operation
- **THEN** eligibility reports the first deterministic unsupported category and source span
- **AND** no partial TypedASTJIT entry is registered

### Requirement: TypedASTJIT eligibility consumes normalized function and receiver semantics

TypedASTJIT eligibility and emission SHALL consume the verified normalized function header and resolved call/member operands rather than interpreting function modifiers ad hoc. The initial scalar backend SHALL fail closed for unsupported receiver, function-kind, trait, hidden-ABI, and cleanup shapes while preserving per-function BytecodeJIT/VM fallback.

#### Scenario: External implicit receiver keeps its global ABI

- **WHEN** a captured global function uses a valid external-implicit-this parameter-zero receiver
- **THEN** entry planning keeps parameter zero in the global function signature and records the receiver alias
- **AND** it does not generate an instance-method object slot or remove the first parameter

#### Scenario: Initial object receiver uses typed fallback

- **WHEN** the initial scalar emitter reaches an external implicit receiver, object instance receiver, object mixin receiver, or resolved member/property operation
- **THEN** it reports `UnsupportedReceiver` or the more specific unsupported object/member/lifetime reason at the responsible source span
- **AND** it emits no partial TypedASTJIT symbol or registration for that function
- **AND** BytecodeJIT/VM remains behaviorally authoritative

#### Scenario: Unknown or inconsistent trait is not ignored

- **WHEN** a function header contains an unknown trait bit or a known trait inconsistent with its normalized invocation/receiver shape
- **THEN** TypedASTJIT eligibility returns `UnsupportedFunctionTrait` or `InvalidTypedHIR`
- **AND** the emitter is not invoked for that function

#### Scenario: Compile-out rewrite is emitted as the final value

- **WHEN** the frontend compiled a selected call out entirely, replaced it with the first parameter, or retained only a method-chain receiver
- **THEN** TypedASTJIT emits the corresponding final HIR value/effect
- **AND** generated C++ contains no call to the compiled-out target

#### Scenario: Hidden or ABI-only argument requires a proven plan

- **WHEN** a resolved target requires hidden WorldContext, script-function-first, generic-call, call-convention object, or other non-source ABI inputs
- **THEN** direct emission is eligible only if the call plan and external descriptor represent the same behavior and argument order
- **AND** otherwise the call uses a proven bridge or causes a typed root fallback

### Requirement: Reachable non-root helpers are validated as a call closure

Production TypedASTJIT roots SHALL be selected from the generation-only descriptor view, but every reachable ordinary AS helper, mixin, generated function, and lifecycle entry needed by a TypedASTJIT root SHALL receive its own body/receiver/call-route disposition. Non-root status SHALL NOT be treated as permission to omit or guess a helper implementation.

#### Scenario: Eligible helper becomes an internal TypedASTJIT symbol

- **WHEN** an eligible UFUNCTION root calls an ordinary non-UFUNCTION AS helper whose normalized header, body, signature, and route are TypedASTJIT-safe
- **THEN** the artifact emits a deterministic provider-internal helper symbol
- **AND** the root materializes inputs in the verified evaluation sequence and calls that symbol using formal ABI order
- **AND** no independent UASFunction entry is published for the helper

#### Scenario: Generated lifecycle helper is not automatically safe

- **WHEN** a root or reachable helper calls a generated asset/singleton lifecycle function carrying external implicit this or object member semantics
- **THEN** `GENERATED_FUNCTION` or hidden naming alone does not make it directly eligible
- **AND** the lifecycle helper must be emitted, bridged, or cause the calling root to fall back according to its normalized receiver/body requirements

#### Scenario: Ineligible required callee falls back the root

- **WHEN** a TypedASTJIT root has an executable call to a reachable callee that cannot be emitted or bridged with equivalent semantics
- **THEN** the root reports `UnsupportedCall` with the call span and callee disposition
- **AND** the backend does not mix an undeclared BytecodeJIT helper symbol into the TypedASTJIT body

#### Scenario: Recursive helper closure is classified as one unit

- **WHEN** reachable AS helpers form a recursive strongly connected component
- **THEN** eligibility validates the component's complete receiver/signature/body/route set before publishing any member symbol
- **AND** one unsupported required member causes the affected root/component to fall back without partial registration

### Requirement: TypedASTJIT lowers HIR without decoding bytecode

For an eligible function, the complete TypedASTJIT analysis/reference/emission path SHALL generate its plan and structured C++ exclusively from typed HIR, generation-view descriptor/Provider metadata, explicit native-call metadata, and the shared Entry Plan, and SHALL preserve AngelScript scalar evaluation, conversion, control-flow, and runtime-error behavior.

#### Scenario: TypedASTJIT generation does not traverse VM instructions

- **WHEN** an eligible UFUNCTION is generated by TypedASTJIT
- **THEN** the emitter does not read `asIScriptFunction::GetByteCode()`
- **AND** it does not dispatch through `FAngelscriptBytecode` implementations or a VM bytecode cursor

#### Scenario: TypedASTJIT reference collection comes from HIR

- **WHEN** TypedASTJIT collects called functions, types, external symbols, includes, and Provider dependencies for an eligible function
- **THEN** it uses resolved HIR nodes, the shared entry plan, explicit external-call descriptors, and provider route metadata
- **AND** neither eligibility nor reference collection invokes BytecodeJIT analysis or its bytecode reference scanner

#### Scenario: HIR uses reconcile with authoritative compiler dependencies

- **WHEN** TypedASTJIT analysis creates references for calls, types, properties, global constants, or storage
- **THEN** every semantic use is covered by the same compile's compatible `artifactDependencies` entry and stable host mapping
- **AND** extra compiler dependencies remain part of the artifact dependency set
- **AND** missing, mismatched, or unmappable coverage reports `SemanticDependencyMismatch` before emission

#### Scenario: Structured control flow remains structured

- **WHEN** HIR contains nested if/else, loops, switch cases, break, continue, and returns
- **THEN** the emitted C++ represents those constructs from HIR block relationships
- **AND** behavior does not depend on reconstructing jump labels from bytecode offsets
- **AND** every transfer uses its verified target statement and exact loop phase rather than an emitter-selected `nearest` label

#### Scenario: Loop continue phases and transfer cleanup are exact

- **WHEN** TypedASTJIT lowers for, while, or do-while with effectful conditions, increments, continue, or exited scopes
- **THEN** for-continue executes increment then condition, while-continue reevaluates condition, and do-while-continue reaches the trailing condition
- **AND** the analyzer proves the transfer's exited-scope cleanup is trivial or reports `UnsupportedLifetime`

#### Scenario: Switch preserves exhaustive enum failure

- **WHEN** TypedASTJIT lowers a compiler-accepted integral or enum switch
- **THEN** it preserves the compiler-selected 32-bit selector normalization, ordered constant cases, case scopes, fallthrough/default behavior, and enum exhaustiveness
- **AND** an unexpected value entering an exhaustive enum switch without default sets the same `Invalid enum value passed to switch` script exception as VM/BytecodeJIT

#### Scenario: Scalar edge semantics match AngelScript

- **WHEN** generated code performs signed or unsigned conversion, narrowing, enum conversion, shifts, integer division, divide-by-zero checks, float/double conversion, boolean normalization, or short-circuit evaluation
- **THEN** signed add/subtract/multiply use unsigned-width bit-domain helpers, signed division/remainder checks zero and minimum-value divided by minus one before the operator, shift counts are masked to 31 or 63, arithmetic right shift performs explicit sign fill, and booleans are normalized
- **AND** non-finite/out-of-range float-to-integer conversion uses a reviewed shared helper with toolchain differential coverage or returns `NonPortableNumericConversion`
- **AND** runtime errors enter the same `FScriptExecution` exception contract as legacy StaticJIT

#### Scenario: Scalar mutation is single-evaluation

- **WHEN** generated code lowers assignment, compound assignment, prefix increment/decrement, or postfix increment/decrement
- **THEN** it materializes the target/address and operands exactly once in the HIR mutation sequence and performs one final store
- **AND** compound assignment does not inherit ordinary binary operand order
- **AND** prefix exposes the updated result while postfix returns the copied old value

#### Scenario: Power support follows the accepted compiler shape

- **WHEN** a body contains a power expression
- **THEN** TypedASTJIT accepts only float/double operand and conversion shapes proven by the maintained native power matrix
- **AND** a double base with integral exponent uses the compiler-normalized 32-bit exponent
- **AND** compiler-rejected integer power never appears as a supported TypedASTJIT runtime operation

#### Scenario: Effectful call inputs are materialized in HIR order

- **WHEN** a supported call has an effectful receiver, source/named/default/hidden arguments, or operands that may set script exception state
- **THEN** generated C++ evaluates each input exactly once into a typed temporary in the authoritative HIR evaluation sequence
- **AND** it invokes the target with those temporaries in formal ABI order
- **AND** it does not rely on C++ function-argument evaluation ordering

#### Scenario: Script exception stops later effects

- **WHEN** an operand, direct script/native call, Runtime thunk, or scalar bridge may set script exception state
- **THEN** generated code checks `FScriptExecution` immediately after that operation
- **AND** it does not evaluate any later operand or side effect after an exception
- **AND** C++ `noexcept` is not treated as proof that the script exception state cannot change

#### Scenario: Suspend or managed cleanup remains ineligible

- **WHEN** a call may suspend or the current function requires managed temporary cleanup during exceptional exit
- **THEN** TypedASTJIT reports `SuspendOrExceptionState` or `UnsupportedLifetime`
- **AND** it does not approximate cleanup from C++ scope alone

### Requirement: TypedASTJIT execution satisfies explicit observability and control capabilities

Every TypedASTJIT entry and directly emitted TypedASTJIT helper SHALL participate in the maintained `FScriptExecution` frame/exception chain, SHALL enforce bounded native recursion, and SHALL run only when its complete direct-call closure satisfies the current execution requirements for position, debugger, coverage, timeout, abort, and suspend behavior. Unsupported requirements SHALL select an approved VM route rather than silently losing behavior.

#### Scenario: TypedASTJIT frame preserves public execution position

- **WHEN** a TypedASTJIT root or direct internal helper is active with debug-position metadata enabled
- **THEN** its frame/depth scope links through the current `FScriptExecution`, publishes current function/file/line through the existing JIT debug-frame contract, and restores the previous frame on every exit
- **AND** creating or leaving the TypedASTJIT frame does not require an active `asIScriptContext`

#### Scenario: Direct helper cannot disappear from execution control

- **WHEN** a TypedASTJIT root directly calls an emitted non-root helper
- **THEN** the helper enters the same reviewed frame/depth/exception contract as an entry function
- **AND** direct-call optimization cannot omit recursion accounting, source position, required instrumentation, or exception checks

#### Scenario: Recursive TypedASTJIT closure is bounded

- **WHEN** a direct TypedASTJIT self-call or mutually recursive SCC exceeds the configured script recursion/frame budget
- **THEN** execution sets the maintained script exception and returns before native C++ stack exhaustion
- **AND** a closure without that guard reports `UnsupportedExecutionControl` with `RecursionGuardUnavailable` or routes to VM

#### Scenario: Debug position does not imply debugger parity

- **WHEN** generated output contains JIT file/line frame updates but lacks VM-equivalent line callbacks and inspectable locals
- **THEN** diagnostics advertise position-only capability
- **AND** the route does not claim breakpoint, stepping, local inspection, coverage, timeout, abort, or suspend capability from those updates

#### Scenario: Breakpoint or step requirement routes to VM

- **WHEN** the current execution requires an active source breakpoint, step control, or VM local-variable inspection and the TypedASTJIT profile lacks an approved equivalent
- **THEN** the root and its direct TypedASTJIT closure execute through VM
- **AND** no TypedASTJIT entry counter increments for that invocation

#### Scenario: Coverage requirement cannot lose line hits

- **WHEN** CodeCoverage recording requires line callbacks
- **THEN** the selected TypedASTJIT profile supplies approved thread-aware equivalent line-hit hooks for every direct callee or the invocation routes to VM
- **AND** generated code does not call the game-thread-only coverage/debug pipeline directly from an arbitrary worker thread

#### Scenario: Timeout abort or suspend requirement needs safe points

- **WHEN** execution requires editor loop timeout, abort polling, or cooperative suspend
- **THEN** every loop/backedge and required boundary in the direct TypedASTJIT closure has an approved source/safe-point hook or the invocation routes to VM
- **AND** position-only line metadata is not accepted as a safe point

#### Scenario: Capability is closed over direct calls

- **WHEN** a root satisfies an execution requirement but one direct TypedASTJIT callee/SCC does not
- **THEN** the analyzer selects an approved bridge/VM route or rejects/reroutes the root with `UnsupportedExecutionObservability` or `UnsupportedExecutionControl` and `DirectCalleeProfileMismatch`
- **AND** an instrumented root never directly enters an uninstrumented child during that invocation

#### Scenario: Instrumentation participates in artifact identity

- **WHEN** two generated bodies have identical HIR but different frame/coverage/safe-point instrumentation profiles
- **THEN** their content/profile identity and invalidation inputs differ
- **AND** runtime routing cannot reuse the uninstrumented artifact for an instrumented requirement

### Requirement: StaticJIT analysis is backend-specific while Entry Plans remain shared

StaticJIT SHALL retain backend-specific body analysis and emission for BytecodeJIT and TypedASTJIT functions while sharing generation-view collection, route/root classification, Entry ABI planning, and Provider packaging through `FAngelscriptStaticJITGenerator`.

#### Scenario: BytecodeJIT retains bytecode analysis and output

- **WHEN** a function selects `"bytecode"`
- **THEN** the existing `AnalyzeScriptFunction()`/bytecode reference analysis and `GenerateCppCode()`/`FAngelscriptBytecode` path remain authoritative
- **AND** shared Entry Plan extraction does not require typed HIR or change protected BytecodeJIT generated output

#### Scenario: TypedASTJIT uses an independent analyzer and emitter

- **WHEN** a function selects `"typed-ast"`
- **THEN** a TypedASTJIT eligibility/reference analyzer produces its call and dependency plan from HIR before the HIR emitter runs
- **AND** BytecodeJIT analysis is not executed for that TypedASTJIT body unless it is selected as a fallback
- **AND** the generated entries still consume the same applicable VM/raw/parameter entry plan

#### Scenario: One module mixes static backends per function

- **WHEN** a `"typed-ast"` generation module contains both eligible and ineligible functions
- **THEN** each eligible function uses TypedASTJIT and each fallback function uses BytecodeJIT or VM independently
- **AND** Provider packaging emits one module TU, preserves one stable function identity, and reports actual backend as diagnostic metadata

### Requirement: Resolved calls select safe direct or scalar bridge lowering

The TypedASTJIT emitter SHALL lower each resolved call independently, using a proven direct entry when safe and externally linkable from the generated module, and otherwise using the existing current-function/StaticJIT/VM call contract when a supported scalar bridge exists.

#### Scenario: Safe script raw target is called directly

- **WHEN** a resolved scalar script target has a concrete non-virtual raw entry whose ABI, provider profile, and routing are proven safe
- **THEN** the emitted caller uses that resolved entry
- **AND** argument evaluation order and result conversion follow the HIR contract

#### Scenario: Direct and bridge forms share one materialization plan

- **WHEN** otherwise equivalent calls select direct script, direct exported/inline/thunk native, or scalar bridge lowering
- **THEN** all forms use the same verified receiver/argument materialization and exception-boundary plan
- **AND** changing call disposition cannot change observable operand order

#### Scenario: Safe exported native target is called directly

- **WHEN** a resolved scalar native target has an explicit matching external-call descriptor for an exported symbol, header-inline definition, or exported Runtime thunk
- **THEN** the emitted caller includes the declared header and uses the typed target directly
- **AND** it does not infer external linkability from legacy native-form call spelling

#### Scenario: Provider-private FBind target uses scalar bridge

- **WHEN** a resolved scalar binding target is implemented by a provider-private helper, an unexported out-of-line symbol, or a native form without an explicit external contract
- **THEN** it is not emitted as a named direct C++ call
- **AND** the TypedASTJIT caller remains eligible when the scalar bridge can preserve its call ABI, routing, result, and exception state

#### Scenario: Ordinary AS helper uses scalar bridge

- **WHEN** an eligible UFUNCTION calls a scalar non-UFUNCTION AS helper that is available only through legacy StaticJIT or VM
- **THEN** the caller marshals the scalar call through the existing call contract
- **AND** the caller itself remains TypedASTJIT
- **AND** return and exception state propagate correctly

#### Scenario: Event or RPC target is never raw-direct

- **WHEN** a resolved target requires RPC, BlueprintEvent, virtual, override, or `ProcessEvent` routing
- **THEN** TypedASTJIT does not invoke a raw implementation pointer directly
- **AND** it uses a proven current-function/Unreal route or marks the root ineligible

#### Scenario: Unsupported call marshalling rejects the root

- **WHEN** a call requires object, reference, container, suspend, or otherwise unproven marshalling
- **THEN** eligibility reports `UnsupportedCall` with the call source span
- **AND** the complete root falls back without registering an invalid TypedASTJIT implementation

#### Scenario: Imported function uses current binding or falls back

- **WHEN** a resolved target is an imported binding slot whose bound implementation may change
- **THEN** TypedASTJIT uses only a proven route that observes the current binding and unbound-function behavior on every invocation
- **AND** it never freezes the current `boundFunctionId` into a direct helper edge
- **AND** absence of that route reports `UnsupportedImportedRoute`

### Requirement: Initial global-state support is constant-only and dependency-safe

The initial TypedASTJIT backend SHALL support only compiler-folded primitive/enum pure globals with retained origin and hard-value invalidation. It SHALL keep mutable global storage, object/container globals, and global initializer bodies on typed BytecodeJIT/VM fallback until stable storage relocation, initialization order, destruction, and hot-reload publication are implemented.

#### Scenario: Folded pure constant is eligible with hard-value authority

- **WHEN** an otherwise eligible function consumes a folded primitive/enum pure global value whose HIR origin maps to the authoritative `HardValue` dependency/fingerprint
- **THEN** TypedASTJIT may emit the scalar literal bits
- **AND** a value or declaration change invalidates the artifact through the existing stable dependency contract

#### Scenario: Origin-free folded value is rejected

- **WHEN** a value appears folded but has no global origin or compatible hard-value dependency
- **THEN** TypedASTJIT analysis reports `SemanticDependencyMismatch`
- **AND** it does not publish a stale embedded constant

#### Scenario: Mutable global storage falls back

- **WHEN** a function reads or writes mutable primitive, object, handle, or container global storage
- **THEN** the initial backend reports `UnsupportedGlobalStorage` at the use span
- **AND** it does not emit an engine pointer, process address, or guessed C++ global symbol

#### Scenario: Global initializer body falls back

- **WHEN** HIR belongs to the anonymous function produced by `CompileGlobalVariable()`
- **THEN** the initial backend reports `UnsupportedGlobalInitializer`
- **AND** it does not register the initializer as an ordinary function/provider entry or reorder module initialization

#### Scenario: Shared or external body is emitted only by its owner

- **WHEN** a reachable declaration uses shared/external identity and the current module does not authoritatively own its body
- **THEN** closure planning references a proven provider/bridge route or falls back the caller
- **AND** it does not duplicate the body under a new module-local identity

### Requirement: TypedASTJIT reuses existing function entry shapes

TypedASTJIT-generated functions SHALL expose the same applicable VM entry, raw entry, and reflected-parameter entry contracts used by BytecodeJIT Providers and `UASFunction` dispatch.

#### Scenario: Eligible function publishes applicable entries

- **WHEN** TypedASTJIT emits an eligible instance or static scalar UFUNCTION
- **THEN** generated registration publishes the applicable `VMEntry`, `Raw`, and `ParmsEntry` pointers defined by its entry plan
- **AND** existing callers do not require a TypedASTJIT-specific invocation API

#### Scenario: Reflected invocation reaches TypedASTJIT body

- **WHEN** a generated `UASFunction` is invoked through reflected parameter memory
- **THEN** its existing parameter entry path reaches the TypedASTJIT-generated body
- **AND** primitive arguments and return values match VM behavior

#### Scenario: Unsupported entry shape falls back

- **WHEN** the current entry planner cannot represent a function shape without changing dispatch semantics
- **THEN** TypedASTJIT reports `UnsupportedSignature` or `BackendUnavailable`
- **AND** legacy StaticJIT or VM remains authoritative

### Requirement: BytecodeJIT remains the compatibility backend

TypedASTJIT SHALL retain BytecodeJIT as the default Static backend, per-function fallback, and differential oracle, and SHALL never silently publish a partial or failed TypedASTJIT function.

#### Scenario: Ineligible function falls back independently

- **WHEN** one function in a module is ineligible for TypedASTJIT
- **THEN** that function uses BytecodeJIT when supported, otherwise VM
- **AND** other eligible functions in the same module may still use TypedASTJIT

#### Scenario: Unexpected emitter failure is visible

- **WHEN** a function passes eligibility but TypedASTJIT emission or verification fails
- **THEN** production generation records `EmitterFailure` and falls back without registering partial entries
- **AND** the differential test treats the same unexpected failure as a test failure

#### Scenario: BytecodeJIT remains buildable and testable

- **WHEN** TypedASTJIT support is compiled into the plugin
- **THEN** the existing bytecode generator and its tests remain present
- **AND** selecting `"bytecode"` does not require typed HIR or TypedASTJIT emitter state

### Requirement: Differential tests compare isolated VM, BytecodeJIT and TypedASTJIT execution

The AOT test surface SHALL run isolated BytecodeJIT and TypedASTJIT generation/execution for eligible scalar fixtures and compare both with VM without registering a `"dual"` backend or shadow-executing implementations in production.

#### Scenario: Eligible fixture produces two independent implementations

- **WHEN** a test fixture requests differential generation
- **THEN** BytecodeJIT and TypedASTJIT implementations use distinct generated symbols and test-visible entries
- **AND** ordinary production registration does not publish two competing entries for one function

#### Scenario: Differential execution compares equivalent inputs

- **WHEN** the differential harness evaluates a fixture
- **THEN** it initializes separate equivalent scalar inputs and fixture state for each backend
- **AND** it compares return value, reflected parameter memory, exception state, and declared scalar observable state

#### Scenario: Unsafe shadow fixture is rejected

- **WHEN** a proposed differential case depends on shared UObject/global/container state, time, randomness, file/network access, or another non-cloneable effect
- **THEN** the differential harness rejects the case as unsupported
- **AND** it does not claim backend equivalence from order-dependent execution

### Requirement: TypedASTJIT entries share the unified Static Provider contract

TypedASTJIT and BytecodeJIT results SHALL publish through the single `FAngelscriptStaticJITGenerator` and Provider identity/routing contract without creating backend-specific artifact identity, registry, packager, or refresh infrastructure.

#### Scenario: Unified Static backend contract is unavailable

- **WHEN** compiler HIR work precedes the unified Static backend/generation-view implementation
- **THEN** the compiler model and pure emitter may validate in Native Core and provider-independent probes
- **AND** production integration waits rather than creating a second Static registry, Provider catalog, packager, route snapshot, or stable-key type

#### Scenario: Mixed provider contains both backend kinds

- **WHEN** one Provider module publishes BytecodeJIT and TypedASTJIT functions
- **THEN** both use the same stable function/content/profile/entry ABI identity rules
- **AND** backend kind is diagnostic metadata rather than a separate identity namespace

### Requirement: TypedASTJIT exceptions preserve primary metadata across mixed routes

TypedASTJIT, BytecodeJIT and VM execution participating in one invocation chain SHALL preserve one first-failure exception record containing the message, originating function, processed section/row/column and route/backend origin. The fast JIT exception flag SHALL remain a control signal rather than the sole public payload. A bridge SHALL adopt nested VM metadata into the active record exactly once, and a public context entry SHALL expose the adopted record through the maintained exception query APIs before returning exception status.

#### Scenario: Direct TypedASTJIT failure records the primary payload

- **WHEN** a TypedASTJIT helper or generated runtime check raises the first script exception in an invocation
- **THEN** execution sets the exception control flag and records message, stable function identity, processed source location and TypedASTJIT route origin
- **AND** later cleanup or bridge failures do not replace the primary payload

#### Scenario: VM bridge adopts nested exception metadata

- **WHEN** a TypedASTJIT caller invokes a VM/scalar bridge and the nested `asIScriptContext` finishes with `asEXECUTION_EXCEPTION`
- **THEN** the bridge copies the nested exception string, function and source location into the active first-failure record exactly once
- **AND** it does not report or log a second primary exception while propagating the failure

#### Scenario: Public context exposes JIT-origin metadata

- **WHEN** a public VM/parameter entry returns `asEXECUTION_EXCEPTION` because its nested TypedASTJIT or BytecodeJIT body failed
- **THEN** the outer context's maintained exception query APIs expose the adopted primary message/function/line metadata
- **AND** returning only the execution status with an empty context payload is not considered parity

#### Scenario: Provider ABI cannot drift silently

- **WHEN** the exception record or bridge state would change a public provider POD or generated-entry layout
- **THEN** the provider layout/version contract is updated and covered by ABI tests
- **AND** the TypedASTJIT change does not append fields to a frozen external layout without coordination

### Requirement: TypedASTJIT lifetime cleanup is verified before eligibility opens

TypedASTJIT eligibility SHALL require a verified cleanup plan for every normal transfer and failure edge. The first scalar slice SHALL accept only explicit empty plans. Any future managed-value slice SHALL track construction state, destroy only live values in reverse declaration order exactly once, preserve return-on-stack ownership, and prevent cleanup failures from replacing the primary script exception.

#### Scenario: Hidden cleanup requirement falls back

- **WHEN** a function appears scalar at its public signature but HIR contains a managed local, temporary, return-on-stack value, constructor, destructor or bridged cleanup obligation
- **THEN** TypedASTJIT reports `UnsupportedLifetime` with the owning scope/source location
- **AND** no TypedASTJIT body is registered for that function

#### Scenario: Cleanup failure preserves the primary exception

- **WHEN** exceptional unwinding invokes a destructor or cleanup bridge that itself fails
- **THEN** the original exception remains the public primary payload
- **AND** the cleanup failure is suppressed or retained only as deterministic secondary diagnostics

#### Scenario: Non-empty exception-handler region falls back

- **WHEN** dormant internal or future exception-region metadata is present in a function
- **THEN** TypedASTJIT reports a stable unsupported exception-region reason and uses BytecodeJIT/VM only if that route supports the same region semantics
- **AND** current source-level `try`/`catch` rejection is not weakened by this backend rule
