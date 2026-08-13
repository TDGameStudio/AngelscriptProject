## Context

AngelScript's public JIT integration is intentionally bytecode-oriented. A module finishes compiling a script function into VM bytecode, then invokes the configured JIT compiler with `asIScriptFunction`; the documented input available to a conventional JIT is `GetByteCode()`. Unreal AngelScript's StaticJIT follows that contract: `FAngelscriptStaticJIT::CompileFunction()` collects script functions, `WriteOutputCode()` analyzes them after the complete initial compile, and `GenerateCppCode()` walks every bytecode instruction through `FAngelscriptBytecode` implementations. The generated function then exposes VM, raw, and reflected-parameter entry points.

That architecture is valid when only bytecode is available, but this project's AOT generation command owns the complete source build. During `asCCompiler` execution the frontend already knows the exact `asCDataType` of every expression, the selected overload or constructor, implicit conversions, local-variable scopes, and the original structured statement tree. Most parser nodes are destroyed after bytecode generation, while the current sparse `asISemanticObserver` event stream records only resolved calls, constructors, assignments, and constant strings. Those events are useful for offline analysis but cannot reconstruct a function body, ownership, nesting, values, or control flow.

Unreal-facing script functions marked by the preprocessor's `UFUNCTION()` macro already have `FAngelscriptFunctionDesc` records. During ClassGenerator analysis each descriptor is matched to the exact `asCScriptFunction` and stored in `FunctionDesc->ScriptFunction`; global UFUNCTIONs are represented through the generated statics-class surface. The generation-only Engine from `refactor-as-unified-jit-coordinator` exposes the same descriptor information without creating script reflection objects, so the final generation view can define TypedASTJIT roots without changing the parser or public JIT callback.

`refactor-as-static-jit-multi-provider` owns stable artifact identity, Provider ABI, route snapshots, Editor/PIE behavior, and Live Coding refresh. `refactor-as-unified-jit-coordinator` owns BytecodeJIT extraction, the private Static backend contract, deterministic generator/packager boundary, and generation-only Engine. This change implements `"typed-ast"` through those seams and must not invent a competing Provider, Static registry, coordinator, or persistence format.

The external provider also changes the C++ linkage boundary. A generated `<ProjectName>AngelscriptStaticJIT` Runtime module is a different DLL from `AngelscriptRuntime`. Today `FScriptFunctionNativeForm` is exported, but its ordinary function/method forms record C++ spelling, optional include text, and triviality rather than external linkage. For example, `Binds/Bind_FMath.h` declares `FAngelscriptFMathBinds` without `ANGELSCRIPTRUNTIME_API`, while `Binds/Bind_FApp.cpp` declares `FAngelscriptFAppBinds` only inside the implementation file. These bindings may be callable through stored pointers inside Runtime, yet their named out-of-line helpers are not thereby linkable from a generated project DLL. Registration lambdas are unrelated: they install the binding and are not the callable target.

### StaticJIT terminology and current compiler timeline

This change uses `TypedASTJIT` as the product/backend name for a **source-known Static AOT backend**, not a Runtime JIT. The parser AST is syntax-only and short-lived; the retained input is a separate compiler-owned `TypedSemanticIR`/typed HIR. The exact pipeline is `source -> parser AST -> semantic compiler -> function-owned typed HIR -> TypedASTJIT C++ -> platform C++ compiler -> Static Provider`.

Current code makes that retained boundary mandatory. `asCCompiler::CompileFunction()` creates a local `asCParser`, parses the statement block, and recursively compiles it while resolved `asCExprContext`/`asCExprValue` state exists. Parser nodes are allocated from the parser's `FMemStackBase`; the parser is reset and destroyed when that local scope ends. `asCCompiler::FinalizeFunction()` then commits bytecode and VM metadata to `asCScriptFunction::ScriptFunctionData`. In UE stage 3, `FAngelscriptEngine::CompileModule_Code_Stage3()` deletes the module builder before `asCModule::JITCompile()` invokes `OnFunctionReady()`. Final Provider generation happens later still. Consequently, selecting `"typed-ast"` only at final output cannot recover parser or compiler state; capture must be frozen before source compilation.

The two Static backends therefore coexist without sharing body IR: BytecodeJIT analyzes bytecode and emits C++; TypedASTJIT analyzes typed HIR and emits C++. Both implement the internal per-task Static contract, share Entry Plan/Provider packaging, and retain VM fallback. Angelsea/MIR and LLVM bytecode-to-native Runtime JITs are external plugins with different lifecycle, executable-memory, invalidation, and VM-exit requirements.

## Goals / Non-Goals

**Goals:**

- Preserve a structured, typed, host-neutral function HIR during source compilation without changing bytecode semantics.
- Freeze Static BackendId/capture profile before target source compilation, then validate it at generation-view construction so programmatic generation cannot request `"typed-ast"` after capture-off compilation.
- Prove an end-to-end UFUNCTION-first path from typed HIR to generated C++ and the existing VM/raw/parameter entry ABI.
- Cover a useful scalar vertical slice: locals, conversions, arithmetic, comparisons, bitwise/logical operations, structured control flow, returns, and statically resolved scalar calls.
- Prove cross-module native direct calls through explicit header, owning-module, export/linkage, ABI, and route-safety metadata rather than assuming that a native-form name is linkable.
- Provide a reviewed exported Runtime callable/thunk surface for selected scalar FBind targets while preserving provider-private implementation boundaries.
- Make backend selection explicit and reversible, with `"bytecode"` remaining the default and per-function TypedASTJIT-to-BytecodeJIT-to-VM fallback.
- Distinguish unsupported language semantics from generator defects through typed, source-located eligibility results.
- Compare VM, BytecodeJIT, and TypedASTJIT through deterministic output and isolated differential execution tests without a `"dual"` backend.
- Keep the HIR reusable by the UE and Standalone hosts while it remains a fork-private model that can evolve.
- Keep TypedASTJIT eligibility, dependency/reference collection, and body emission independent of VM instruction traversal while leaving BytecodeJIT intact.

**Non-Goals:**

- Removing, disabling, or feature-freezing BytecodeJIT.
- Replacing VM bytecode as the runtime correctness format or changing `PrecompiledScript.Cache`.
- Persisting HIR, inventing an HIR cache, or loading HIR when only precompiled bytecode is available.
- Publishing a stable typed-IR ABI through `angelscript.h` in the first version.
- Retaining raw `asCScriptNode` parser trees after compilation or extending parser `FMemStack` lifetime for StaticJIT.
- Introducing a typed CFG/SSA layer, LLVM/MIR lowering, optimization/deoptimization pipeline, runtime hotness coordinator, or executable-code memory manager in this change.
- Modifying Unreal Engine source; all required host work remains inside the plugin, maintained AngelScript fork, tests, and generated provider boundary.
- Supporting UObject/property access, references/out parameters, containers, value-object lifetime, delegates, lambdas, closures, non-empty exceptional cleanup, any future exception-handler regions, or suspend/coroutine state in the first emitter.
- Directly lowering RPC, BlueprintEvent, BlueprintOverride, virtual dispatch, or other calls that must retain Unreal `ProcessEvent`/route behavior.
- Duplicating the external provider, incremental artifact identity, Editor routing, Live Coding, or project-module scaffolding work.
- Adding `ANGELSCRIPTRUNTIME_API` to every FBind provider/helper or treating binding-registration lambdas as generated-code entry points.
- Performing production shadow execution of two function bodies.
- Reusing the live Editor Engine for capture, creating script UClass/UFunction/CDO state in the generation Engine, or adding another Static backend registry/packager.

## Decisions

### The compiler owns a structured sidecar HIR

Add fork-private `as_typed_semantic_ir.h/.cpp` under the maintained AngelScript source. `asCTypedSemanticFunction` owns indexed arenas for symbols, expressions, statements, switch cases, and child lists. Node references are stable integer IDs rather than host pointers to polymorphic nodes, which makes traversal, validation, deterministic dumping, and later lowering straightforward.

The initial model contains:

- `asSTypedSemanticSourceSpan`: owned script section name plus byte offset and length; zero-based row/column are captured through the existing script source map for deterministic diagnostics.
- `asSTypedSemanticSymbol`: stable function-local ID, parameter/local kind, source name, declared `asCDataType`, declaration span, and declaration order.
- `asSTypedSemanticExpression`: kind, exact result `asCDataType`, source span, ordered operand IDs, literal bits/text where relevant, operator/conversion classification, resolved symbol ID, and engine-local resolved function ID for calls. It does not retain an `asCScriptFunction*` or create recursive function-reference ownership.
- `asSTypedSemanticStatement`: kind, source span, ordered child statement/expression IDs, explicit block/loop/switch phases, and verified target-statement IDs for control transfers.
- `asSTypedSemanticUnsupported`: category, source span, and stable detail token for syntax or semantic forms outside the current model.

Expression kinds initially cover primitive/enum literals, parameter/local reads, assignment and compound assignment, prefix/postfix increment/decrement, unary operations, arithmetic/comparison/bitwise/logical binary operations, explicit compiler-selected conversion, and resolved calls. Assignment/compound/prefix/postfix nodes preserve a single-evaluation mutation plan rather than only an operator token. Statement kinds initially cover block, local declaration, expression statement, if/else, for, while, do-while, switch/case/default, break, continue, and return. Loop nodes retain their ordered initializer/condition/body/increment phases; `Break` and `Continue` retain a verified target statement ID. Source-point/safe-point roles are captured independently of whether the initial output profile instruments them. Logical `&&` and `||` remain explicit short-circuit nodes rather than ordinary eager binary operations. Ternary expressions, property access, object construction/lifetime, references, handles, containers, lambdas, exceptions, and suspend points initially produce unsupported nodes.

`asCScriptFunction::ScriptFunctionData` owns an optional `asCTypedSemanticFunction*`. It is allocated only for source compilation when HIR capture is enabled, committed only after successful function compilation and verification, and discarded at the start of function destruction before existing type/function references are released. Exact `asCDataType` descriptors and resolved function IDs are valid only while the owning engine/module/function graph is alive, matching existing bytecode reference lifetime; consumers must not retain IR pointers across module replacement.

`asCExprContext` gains one invalid-by-default HIR expression ID when capture is enabled. `Clear()` invalidates it, `Copy()` propagates it, and `Merge()` adopts the final value identity. Every compiler-selected conversion, assignment, unary/binary operation, call, and short-circuit result creates or replaces the ID only after its existing semantic decision is final. Void/discarded values clear it. This propagation is required because reconstructing expression identity only at outer statement hooks would lose nested evaluation order, conversions, and temporary rewrites. It remains sidecar state and never influences `asCExprValue`, overload resolution, or bytecode emission.

Alternative rejected: serialize parser AST nodes. They contain unresolved syntax state, temporary allocation/lifetime assumptions, and do not represent final conversions or selected overloads.

Alternative rejected: reconstruct HIR from `asISemanticObserver`. Its sparse event stream intentionally lacks statement nesting, value identity, local ownership, and control-flow structure. The observer remains unchanged and coexists with HIR capture.

Alternative rejected: define an Unreal-only `TArray`/`FString` IR. It would introduce UE into the maintained frontend and force Standalone to maintain a second semantic representation.

### HIR capture is opt-in and cannot perturb bytecode

Add a fork-private engine flag, set through the internal `asCScriptEngine` API rather than `asEEngineProp` or another public `angelscript.h` ABI. The disposable generation `FAngelscriptEngine` enables it before module compilation only when the frozen request selects BackendId `"typed-ast"`. Standalone tests may enable the same internal flag directly because the Standalone host already compiles the maintained private frontend.

Backend selection has a two-stage contract. The generation request freezes BackendId (`"bytecode"` or `"typed-ast"`) and the expected capture profile before constructing/building the generation Engine. Final output generation revalidates that request against the Engine that produced the functions. A programmatic helper or provider-artifact path requesting `"typed-ast"` from a capture-off Engine fails the generation task with `CaptureProfileMismatch`; it does not attempt a hidden recompile and cannot claim a TypedASTJIT artifact. Per-function eligibility/emitter failures occur only after this task-level validation and may fall back through BytecodeJIT to VM. `"dual"` is not a BackendId. Command-line parsing is one way to populate the request; it is not hidden global authority for programmatic generation.

`asCCompiler` owns an `asCTypedSemanticIRBuilder` alongside its existing `asCByteCode` builders. Existing semantic compilation remains authoritative: each capture hook runs only after the compiler has resolved the expression type, conversion, overload, and local-variable identity. The builder follows the recursive compiler statement/expression call stack, adds structured nodes, and never feeds decisions back into bytecode generation. Encountering an unsupported form records an unsupported node but does not issue a script compile error.

The builder is a provisional function transaction created from `asCCompiler::Reset()`. If compilation reports any error, the provisional HIR is discarded. It is published into `ScriptFunctionData` only after normal bytecode finalization succeeds and the complete HIR verifies. If HIR verification fails despite a successful script compile, the function retains bytecode but receives an invalid-HIR diagnostic; TypedASTJIT must fall back rather than consuming a partial model. Default constructors/destructors, factories, lambdas/accessors, and other compiler-synthesized function variants must either follow the same commit/discard rule or record a deterministic unsupported disposition; none may publish a half-built HIR.

Bytecode invariance is a release criterion: compiling an identical source/module/engine configuration with capture disabled and enabled must produce identical bytecode, debug metadata when enabled, dependency information, and script execution results. HIR is never added to `FAngelscriptPrecompiledFunction`, `FAngelscriptPrecompiledData`, `SaveByteCode`, or `LoadByteCode`. A module loaded only from bytecode therefore has no HIR and deterministically selects legacy/VM.

Alternative rejected: make HIR the source for VM bytecode in the first version. That is a desirable possible future consolidation, but it would combine a VM compiler rewrite with the first TypedASTJIT proof and eliminate bytecode as an independent oracle.

### Function traits are normalized into an effective receiver and call shape

The maintained fork's function semantics are not described by declaration text or `asSFunctionTraits` alone. `objectType`, `funcType`, `vfTableIdx`, parameter modifiers, `hiddenArgumentIndex`, `determinesOutputTypeArgumentIndex`, `compileOutType`, return-on-stack, system call convention, exception/suspend state, and final ClassGenerator/UFUNCTION routing can all change the executable shape. The HIR therefore stores a function-level normalized header containing the raw trait snapshot for diagnostics plus an invocation kind, body kind, declared parameters, effective receiver, hidden-argument origins, compile-out disposition, concrete return ABI, and unsupported/profile state. Unknown future trait bits fail closed for TypedASTJIT eligibility instead of being ignored.

Receivers are modeled as one of `None`, `NativeObjectThis`, `ExplicitParameterAlias`, or `MixinFirstParameter`. A native instance receiver is a synthetic function symbol backed by the VM object slot and is not inserted into the declared parameter list. A mixin call maps the source method receiver to the global function's real formal parameter zero, while the mixin body continues using that named parameter explicitly. These forms must not be collapsed into a single `HasThis` flag.

`external_implicit_this` is the fork-specific counterexample that fixes this boundary. It is legal only on a global function, and the current compiler records the object type and stack position of declared parameter zero as the fallback `this` for unqualified member/property/method lookup. Parameter zero remains present in the script signature, VM stack, raw entry, and global call. The HIR records `ExplicitParameterAlias(ParameterIndex=0, Symbol=parameter-zero)`; every resolved member/property/call node refers to that receiver expression explicitly. A generated C++ body must use the explicit receiver or an approved object/property bridge and must never erase the parameter or emit C++ `this` as though the global function were a member.

Resolved calls record three distinct views after mixin receiver insertion, named/default/hidden arguments, concrete determines-output-type resolution, and call rewrites: source receiver/argument roles, effective formal bindings, and the authoritative evaluation sequence. The maintained fork compiles ordinary call, constructor, index, and chained-call operands in reverse formal order; method receiver placement is call-shape dependent, assignment compiles RHS before LHS, and ordinary eager binary expressions may use a different order. HIR therefore never reduces these rules to a generic source-order or left-to-right flag. Default expressions retain both callee-declaration/parameter origin and caller processed-source provenance. `CompileOutEntirely`, `ReplaceWithFirstParam`, and `CompileOutAsMethodChain` are captured as the final expression semantics before a call node is created; TypedASTJIT must not emit a native call that the authoritative compiler compiled out. Host-only arguments such as WorldContext defaults or a native `PassScriptFunctionAsFirstParam` value remain distinct from source parameters and from receivers.

The first scalar emitter recognizes and verifies these shapes but supports only ordinary receiver-free scalar functions. Object receivers, member/property access, mixin object calls, constructors/destructors, return-on-stack, and complex lifetime/cleanup initially receive a source-located typed fallback. This is a capability boundary, not a reason to omit receiver information: later object slices open eligibility against the same verified HIR and must preserve null checks, access/property resolution, evaluation order, virtual/RPC/Blueprint routing, and exception behavior.

Production roots are still selected from the final UFUNCTION descriptor graph, but an ordinary helper, mixin, or generated lifecycle function can appear in a root's reachable call closure. `NotUFunctionRoot` means that the helper does not publish an independent UASFunction entry; it does not make the helper body irrelevant. Each reachable callee must be emitted as an internal TypedASTJIT helper, called through a proven bridge, or cause the caller root to fall back. The full trait matrix, source evidence, verifier rules, Singleton lowering constraint, and test axes are recorded in `research/function-traits-and-effective-receiver.md`.

Alternative rejected: branch on individual traits independently in HIR capture, eligibility, entry planning, and the emitter. That duplicates semantic interpretation and permits different stages to disagree about parameter zero, an object slot, or a hidden argument.

Alternative rejected: rewrite all methods, mixins, and external implicit receivers into canonical global functions before bytecode compilation. That would disturb overload resolution, access control, debug mapping, virtual routing, and the bytecode oracle in the first TypedASTJIT change.

### The first implementation milestone is a provider-independent functional slice

The first implementation milestone proves actual generated-code behavior before production provider publication or Runtime JIT coordination. It captures one global scalar UFUNCTION fixture named `SemanticScalarBranch` (the historical fixture name is retained), verifies and dumps its function-owned HIR, emits C++ through a core API that cannot receive bytecode/provider state, compiles a checked-in test probe, and compares isolated VM, BytecodeJIT, and TypedASTJIT execution for the same inputs. Production packaging still waits for the shared generation view/backend contract.

The test probe is intentionally not a production provider entry. It reuses the maintained AOT generated-file workflow only to prove that real compiler output can become a compiled native function. A test-only entry counter must show that the TypedASTJIT body ran; matching results without the counter do not satisfy the milestone. Completing this slice does not complete provider identity, UASFunction attachment, native-call linkage, hot reload, or Runtime JIT tasks.

The concrete patch sequence, interface skeletons, compiler hook map, execution matrix, and verification commands are recorded in `research/typed-semantic-staticjit-patch-cookbook.md`. Synthetic positive, fallback, and invalid HIR examples live under `research/fixtures/semantic-aot-v1/`. Those JSON files are research test vectors only: Runtime never loads them, they are not an HIR persistence schema, and the real C++ model remains the implementation under test.

This ordering isolates feature correctness from provider packaging. Once the shared Static backend/generation-view foundation and functional slice pass, a thin production adapter freezes capture before compilation, selects final UFUNCTION roots, consumes the shared entry shape, and packages successful TypedASTJIT emission through the backend-neutral provider ABI. Provider API movement must not require rewriting compiler-owned HIR or the pure TypedASTJIT analyzer/emitter.

Alternative rejected: require the provider/runtime architecture to land before emitting or executing any test-only TypedASTJIT function. That ordering would couple frontend correctness to packaging and make it harder to distinguish HIR/emitter defects from provider integration defects. Production TypedASTJIT integration does require the shared backend/generation-view foundation.

### Static BackendId and capture profile are frozen before the generation Engine compiles

The internal Static contract from `refactor-as-unified-jit-coordinator` defines stable BackendIds `"bytecode"` and `"typed-ast"`. Existing generation entry points select `"bytecode"`; Editor/Commandlet and programmatic generation carry an explicit `FAngelscriptStaticJITBackendId` plus a capture profile. The orchestrator validates both before it creates the generation-only Engine.

- Missing backend selects `"bytecode"` and leaves HIR capture off.
- `"bytecode"` creates `FAngelscriptBytecodeJIT` and preserves the current collector/analyzer/emitter/output behavior.
- `"typed-ast"` forces a complete source compile in the generation-only Engine with HIR capture enabled before the first function compiles.
- A request/capture mismatch fails the complete generation with `CaptureProfileMismatch`; low-level generation never recompiles secretly and never labels all-BytecodeJIT output as TypedASTJIT success.
- With a valid capture profile, per-function unsupported/invalid HIR falls back through BytecodeJIT to VM while other eligible functions remain TypedASTJIT.
- `"dual"` is not a BackendId. Tests invoke isolated BytecodeJIT and TypedASTJIT generation tasks and compare both results with VM.
- An unknown or duplicate Static BackendId is a configuration error and must not silently become `"bytecode"`.

The selected backend belongs to the generation artifact/profile and is not a runtime CVar. Runtime/Provider routing chooses among entries already compiled into Providers; it does not transpile or switch a function body on demand.

Alternative rejected: per-function UFUNCTION metadata or AngelScript annotations. Developers should not maintain backend eligibility manually, and annotations would make generator limitations part of the script API.

Alternative rejected: compile-time C++ macros. They prevent one build from producing and testing both paths and make diagnostics less precise.

Alternative rejected: let `FAngelscriptTypedASTJIT` trigger compilation when HIR is absent. Backend execution occurs after the generation view is frozen; recompilation belongs exclusively to Editor/Commandlet orchestration so target profile, Bind replay, source graph, and reflection-side-effect policy remain explicit.

### TypedASTJIT uses the side-effect-free generation Engine

For each target profile, the orchestrator creates one disposable `FAngelscriptEngine` in StaticJIT-generation mode. Process-level Bind callback discovery/sealing is reused, but every callback is replayed into the new `asIScriptEngine`; its type info, FunctionId, PropertyId, module objects, and HIR are Engine-local. The Engine compiles the complete Provider source graph so overloads, imports, globals, helper closure, and target-profile declarations are authoritative, while the output request may select a smaller module set.

The generation Engine performs ClassGenerator descriptor analysis only. It may read existing native Unreal reflection during Bind and ABI classification, but it does not create script `UClass`, `UScriptStruct`, `UDelegateFunction`, `UFunction`, or CDO objects; execute class redirects, Soft/Full Reload, reinstancing, or default-object initialization; or publish into the live Editor Engine. TypedASTJIT roots and Entry Plans come from the resulting generation-local descriptor view.

HIR and descriptor pointers remain valid only until synchronous backend analysis/emission finishes. The backend output contains stable identity, C++ text, stable references, provenance, and typed reasons, never a raw AngelScript/UE pointer or Engine-local numeric ID. Destroying the generation Engine releases its HIR and cannot invalidate Provider output.

Alternative rejected: use the live Editor Engine and toggle capture before an in-place compile. Existing modules may have come from Cache V2 or capture-off compilation, and generation would race Hot Reload/world state. Alternative rejected: run a second process in v1; descriptor-only generation provides the required UObject isolation without introducing another serialized IR and IPC lifecycle.

### The final descriptor graph defines UFUNCTION roots

The generation-only Engine view exposes a complete `CompiledSourceGraph` containing every compiled script function/type/global, compiler artifact dependency, external native-call descriptor, and descriptor-only ClassGenerator graph. It separately exposes `EmitModuleSet`; filtering output never filters semantic analysis input. Before backend construction, the Static generator builds a root index from each `FAngelscriptFunctionDesc` with a resolved `ScriptFunction` pointer. Pointer identity is valid only inside that synchronous view and, rather than declaration text or name matching, classifies roots; output uses the corresponding stable function identity.

An initial TypedASTJIT root must satisfy all of the following:

- It is a concrete `asFUNC_SCRIPT` function represented by a `FAngelscriptFunctionDesc` created for a UFUNCTION surface.
- It is not RPC/net, BlueprintEvent, BlueprintOverride, virtual/non-final, thread-safe-special, suspendable, a validation/event wrapper, or dependent on generated WorldContext injection.
- Its reflected parameters and return are `void`, bool, fixed-width signed/unsigned integer, float, double, or enum by value. References, out parameters, handles, objects, structs, arrays, sets, maps, delegates, and return-on-stack shapes are rejected.
- Its HIR verifies and contains only supported scalar expressions/statements/lifetimes.
- Every call has a scalar marshalling plan and either a safe direct entry or an allowed bridge route.

An instance method may retain an opaque `this` pointer for entry ABI purposes, but using object properties, object casts, virtual calls, or object-valued expressions makes the body ineligible. A global/static UFUNCTION can be eligible when it otherwise meets the same rules.

Eligibility returns `FAngelscriptTypedASTJITEligibility`, containing actual disposition, stable fallback enum, source span when applicable, and a deterministic detail token. Initial fallback categories are `NotUFunctionRoot`, `MissingTypedHIR`, `UnsupportedFunctionKind`, `UnsupportedFunctionTrait`, `UnsupportedReceiver`, `UnsupportedUFunctionFlags`, `UnsupportedSignature`, `UnsupportedType`, `UnsupportedStatement`, `UnsupportedExpression`, `UnsupportedCall`, `UnsupportedGlobalStorage`, `UnsupportedGlobalInitializer`, `UnsupportedImportedRoute`, `TypedSemanticDependencyMismatch`, `NonPortableNumericConversion`, `UnsupportedExecutionObservability`, `UnsupportedExecutionControl`, `UnsupportedLifetime`, `SuspendOrExceptionState`, `InvalidEffectiveReceiver`, `InvalidCallEvaluationSequence`, `InvalidControlTarget`, `InvalidTypedHIR`, `EmitterFailure`, and `BackendUnavailable`. Execution categories use stable details such as `DebuggerStepUnavailable`, `CoverageHookUnavailable`, `LoopTimeoutSafepointUnavailable`, `RecursionGuardUnavailable`, and `DirectCalleeProfileMismatch` rather than introducing a new enum for every capability bit.

Alternative rejected: compile every AS helper semantically in the first version. UFUNCTION roots provide an existing Unreal ABI and a representative product path; helpers remain callable through legacy/raw/VM bridges and can become roots in a later capability extension.

### TypedASTJIT lowering preserves AngelScript scalar semantics

Add `StaticJIT/TypedASTJIT` containing eligibility analysis, reference/dependency planning, scalar ABI/type spelling, structured C++ emission, and call marshalling. Neither the TypedASTJIT analyzer nor emitter calls `GetByteCode()`: tests must assert that no bytecode reference scan, bytecode cursor, or `FAngelscriptBytecode` implementation participates from TypedASTJIT eligibility through C++ body generation. TypedASTJIT references come from resolved HIR calls/types/symbols, shared Entry Plans, explicit external-native-call descriptors, and Provider route metadata. BytecodeJIT retains its existing bytecode analysis and reference resolver.

The emitter produces structured C++ blocks and typed locals from HIR. It uses explicit casts and helper functions where C++ would otherwise differ from AngelScript for signedness, narrowing, shifts, integer division, divide-by-zero, overflow boundaries, enum representation, float/double conversion, and boolean normalization. Runtime errors enter the same `FScriptExecution` exception contract used by legacy StaticJIT. Because the first slice has no managed object temporaries, exception cleanup does not own destructors; a function requiring cleanup is ineligible.

Structured output preserves compiler phases rather than translating only surface syntax. `for` continue executes the increment list then condition, `while` continue reevaluates its condition, and `do-while` continue reaches the trailing condition. Every `Break`/`Continue` names and verifies the nearest legal lexical target; the analyzer computes exited scopes and accepts only trivial cleanup in the first scalar slice. Switch lowering preserves the current 32-bit selector normalization, constant/duplicate/type rules, ordered fallthrough/default disposition, explicit case scopes, and the exhaustive-enum invalid-value exception edge. A C++ `switch` with an omitted default is not equivalent when the compiler requires `Invalid enum value passed to switch`.

Assignment, compound assignment, and prefix/postfix increment/decrement lower from explicit mutation plans: evaluate the recorded target/address and operands exactly once in the authoritative order, retain the old value where required, apply exact type/edge helpers, and perform one final store. The emitter does not use C++ `lhs op= rhs` unless that spelling is proven equivalent. Postfix returns the copied old value; prefix exposes the updated result. Float/double power remains unsupported until the maintained native power matrix proves each compiler-selected conversion/opcode shape; integer power is never advertised because the frontend currently rejects it even though internal opcode names exist.

Signed add/subtract/multiply execute in the corresponding unsigned bit domain and are then reinterpreted/narrowed; signed division and remainder check divide-by-zero and minimum-value divided by minus one before the C++ operator executes. Shift counts are explicitly masked to 31 or 63, logical shift uses an unsigned bit pattern, and arithmetic right shift performs explicit sign fill instead of relying on implementation-defined signed C++ shift. A dynamic float/double-to-integer conversion uses one reviewed shared Runtime conversion primitive with strict toolchain differential coverage or receives `NonPortableNumericConversion`; the emitter does not scatter raw casts for non-finite or out-of-range cases.

Every effectful call operand is materialized into a typed temporary in the HIR evaluation sequence, after which the target is invoked with temporaries in formal ABI order. Generated C++ never relies on its own function-argument evaluation order. Every direct or bridged call plan declares whether it can set a script exception, suspend, or require managed cleanup. A `MaySetScriptException` call is followed immediately by the existing `FScriptExecution` exception check before any later operand or side effect; `MaySuspend` and `RequiresCleanup` are initially ineligible. C++ `noexcept` is not treated as proof that a target cannot set an AngelScript exception.

Extract or introduce a shared entry-plan layer that describes the function symbol, literal C++ parameter/return representation, VM stack mapping, reflected parameter offsets, and available VM/raw/parameter wrappers. Function collection and provider packaging also remain shared, but body support analysis is backend-specific. Both emitters consume the entry plan. The legacy generated text and behavior remain protected by existing golden/AOT tests; extracting the plan must not remove or collapse `AnalyzeScriptFunction()`, `FStaticJITContext`, `GenerateCppCode()`, or `AngelscriptBytecodes.cpp`.

Generated TypedASTJIT entries use the same current Static Provider entry seam. BytecodeJIT and TypedASTJIT results pass through `FAngelscriptStaticJITGenerator` and `FAngelscriptJITGeneration`, use the same Provider entry record, stable identity, and route snapshot, and may coexist in one module TU. Backend kind is diagnostics metadata, never a second identity namespace.

### Native direct calls require a separate external-linkage descriptor

Keep the existing native forms and `.NativeFunction()`/`.NativeMethod()` behavior for BytecodeJIT compatibility, but do not reinterpret those APIs as cross-DLL proof. Extend the native-form/call-plan surface with an explicit `FAngelscriptExternalNativeCall`-style descriptor whose stable data includes:

- linkage class: `ExportedSymbol`, `HeaderInline`, or `ExportedRuntimeThunk`;
- exact C++ symbol expression and includable header;
- owning UE module and legal consumer dependency classification;
- normalized parameter/return ABI identity and supported calling form;
- routing, virtual-dispatch, exception, and lifetime safety flags.

Absence of this descriptor means “not externally direct-callable,” even when BytecodeJIT already has a call spelling. The descriptor is attached deliberately by the owning FBind registration or native-form implementation; TypedASTJIT does not scan source text, infer `_API` macros from symbol names, or emit its own `extern` redeclaration.

There are three valid outward implementations:

1. **Owning-module export:** the callee already has a public declaration marked by its owning module's API macro. Engine functions keep their Engine-module API; Runtime-owned functions use `ANGELSCRIPTRUNTIME_API`.
2. **Header inline/template:** the complete definition is in the included header and all dependencies are legal for the generated module. It does not need DLL export merely for linkage, but still needs typed ABI and routing proof.
3. **Exported Runtime thunk:** a narrow `ANGELSCRIPTRUNTIME_API` function in an AOT-callable Runtime header forwards to a provider-private helper. This is preferred when exposing `FAngelscript*Binds` would make binding organization a public ABI or leak Runtime-private module dependencies.

The implementation inventory classifies every existing native form and direct-pointer binding as `ExportedSymbol`, `HeaderInline`, `ExportedRuntimeThunk`, `ProviderPrivate`, or `UnknownBytecodeNativeForm`. Only the initial supported scalar subset must be migrated in this change; the inventory records deferred functions and why. Adding `ANGELSCRIPTRUNTIME_API` only to a `.cpp` definition is invalid because the generated consumer needs the same imported declaration. Exporting a whole provider struct merely to expose one member is also rejected when a narrow thunk suffices.

A separate UE consumer module must include, link, and invoke every Runtime-owned external symbol/thunk advertised by the initial slice. Golden generated text and tests compiled inside `AngelscriptRuntime` cannot detect a Windows DLL import/export defect. The final generated provider fixture repeats the same proof at the actual module boundary.

Alternative rejected: infer external linkability from `FScriptFunctionNativeForm::GenerateCall()`. It proves only the emitted expression and was designed before the separate project-DLL boundary.

Alternative rejected: add `ANGELSCRIPTRUNTIME_API` to all `FAngelscript*Binds` classes. It expands a large internal implementation surface into a supported public ABI, can expose private dependency headers, and still does not describe routing or typed-call safety.

### Globals, source provenance, and compiler dependencies fail closed

Global initialization remains the separate `CompileGlobalVariables()`/`CompileGlobalVariable()` pipeline. Its anonymous initializer functions currently lack the complete invocation identity, init-order publication, destruction, and hot-reload contract required for provider output. The first TypedASTJIT slice therefore does not emit global initializer bodies and rejects mutable/object/container global storage. It may consume a compiler-folded primitive/enum `isPureConstant` only when the HIR retains a `FoldedGlobalConstant` origin and the artifact carries the existing hard-value dependency/fingerprint; a folded value never becomes an origin-free literal.

The maintained compiler already captures function signatures/content, type declaration/layout, property layout, mutable global storage, and pure-constant hard values in `ScriptFunctionData::artifactDependencies`. TypedASTJIT analysis derives a typed `SemanticUseManifest` from verified HIR and requires every use to be covered by a compatible authoritative compiler dependency. Extra compiler dependencies are preserved. Missing or incompatible coverage, or failure to map an engine-local coordinate to the current stable artifact identity, returns `SemanticDependencyMismatch`; TypedASTJIT analysis does not invoke the BytecodeJIT reference scanner to repair the manifest.

Imported calls are represented as current-binding slots using source module and canonical signature, not as a direct body edge to the current `boundFunctionId`. Shared/external declarations separately record declaration identity, body owner, and calling module. An imported call requires a bridge/provider route that observes the current binding on every call, and a shared/external body may be emitted only by its authoritative owner; otherwise the caller receives `UnsupportedImportedRoute` or `UnsupportedCall`.

Every HIR node owns the processed source section/range used by the compiler. It may additionally retain an authored origin or generated-origin record only when the preprocessor can supply a reliable mapping. Diagnostics prefer a precise authored origin, then a generated anchor, then the processed span; they never label a processed offset as an authored-file offset. Source provenance affects diagnostics and reproducibility, not semantic decisions or bytecode.

The complete evidence, v1 global matrix, imported/shared rules, scalar helper requirements, and fixture contract are recorded in `research/global-state-evaluation-and-scalar-parity.md`.

### Calls degrade at the call site

HIR call nodes retain target kind, engine-local target or binding-slot coordinate, exact argument/result types, source roles, formal bindings, authoritative evaluation sequence, default/hidden origins, and source provenance. The TypedASTJIT analyzer resolves those coordinates only against the same generation Engine/function graph; the HIR itself does not own a target function pointer. The emitter materializes receiver/argument effects exactly once in the recorded sequence, checks script exception state at each required boundary, then supplies the temporaries in formal ABI order to one of four lowering forms:

1. **Direct script entry:** a concrete non-virtual script target has a proven scalar raw ABI and the active provider/profile permits that direct route. Emit the resolved entry/reference mechanism owned by the provider contract.
2. **Direct external native entry:** a registered native target has a matching external-call descriptor and is `ExportedSymbol`, `HeaderInline`, or `ExportedRuntimeThunk`. Emit the declared include and typed call without redeclaring the target.
3. **Scalar bridge:** marshal scalar arguments into the existing StaticJIT/VM call frame contract, invoke the current script/native target, propagate exception state, and convert the scalar result back to the HIR type. This covers ordinary non-UFUNCTION AS helpers and bindings whose callable implementation remains provider-private.
4. **Unsupported call:** object/reference/container marshalling, suspend behavior, ambiguous dynamic dispatch, missing external linkage without a bridge, or any target that cannot preserve routing produces `UnsupportedCall` for the root.

Calls to RPC, BlueprintEvent, BlueprintOverride, or virtual Unreal surfaces are never raw-direct even when a pointer is discoverable. They must use the existing current-function/`ProcessEvent`/VM route; if the first-version scalar bridge cannot demonstrate that route, the root is ineligible.

This policy prevents one unsupported helper from automatically forcing its caller back to bytecode while still refusing ABI guesses.

Alternative rejected: require every call to be direct. It would make common UFUNCTION bodies ineligible and conflate backend coverage with binding availability.

Alternative rejected: send every call through the generic VM. It is correct but leaves obvious safe raw/native call performance unused and would not validate typed call lowering.

### Execution observability and control are explicit route capabilities

Generated code participates in the maintained `FScriptExecution` chain. A TypedASTJIT entry or internal helper cannot establish a competing thread-local execution model: `FScriptExecution` deliberately makes the active VM context null, owns JIT exception state, and carries the non-Shipping debug-frame chain. Every entered TypedASTJIT root/helper therefore uses reviewed frame/depth RAII, updates current function/source position when the output profile requests it, and restores the previous frame on every normal or exceptional return.

The route evaluates an execution-requirements snapshot against the complete direct TypedASTJIT call closure. The conceptual capabilities are frame position, line callback, debugger stepping/locals, coverage, loop timeout, abort/suspend polling, and recursion budget. They may be represented as flags/profile data rather than another provider kind. A root cannot satisfy an instrumented session while directly calling an uninstrumented child; every direct callee/SCC must satisfy the same required profile or the call/root routes through an approved bridge/VM fallback. Instrumentation profile participates in content/profile identity and invalidation.

The maintained VM implements line callback and loop-timeout polling at `asBC_SUSPEND`; BytecodeJIT currently emits debug frame/line metadata but treats that bytecode as a no-op. Debug position is therefore not debugger, coverage, or timeout parity. The first TypedASTJIT version routes active breakpoints, stepping, local inspection, CodeCoverage recording, and required timeout/abort/suspend sessions to VM unless the generated profile explicitly contains approved equivalent source/safe-point hooks. It never calls the game-thread-only line/coverage pipeline directly from an arbitrary worker thread.

Direct JIT-to-JIT recursion also bypasses the nested VM `m_callStack` depth guard. Every TypedASTJIT frame/helper/SCC must consume a bounded script recursion budget and turn exhaustion into the maintained script exception before native stack overflow. Until that guard exists, a recursive closure reports `UnsupportedExecutionControl` with `RecursionGuardUnavailable` or routes to VM.

HIR stores source-point and safe-point roles at function entry, effectful/throwing boundaries, loop entry/backedges, calls, transfers, switch invalid-value edges, and returns. Capturing the role does not force instrumentation, but it lets eligibility choose an output profile without reading bytecode. Runtime line-event placement must be compared with compiler `LineInstr`/VM behavior; treating every HIR span as a line callback is rejected.

The complete evidence, v1 routing table, control-flow/mutation contract, and verification matrix are recorded in `research/execution-observability-and-control-flow.md`.

Alternative rejected: claim debugger/coverage parity because generated C++ updates `FScopeJITDebugCallstack::LineNumber`. That frame supports position reporting but does not provide a VM context, inspectable locals, line callback, loop timer, or execution-status polling.

### Exception payload, bridge adoption, and cleanup are separate capabilities

The maintained execution paths do not currently expose one equivalent exception contract. VM execution stores the exception message, originating function, section, line and column in `asCContext`, and drives the exception callback from that record. JIT execution primarily shares `FScriptExecution::bExceptionThrown`; `FAngelscriptEngine::Throw()` and generated BytecodeJIT helpers set the flag and log through `HandleExceptionFromJIT()`, while top-level wrappers convert the flag to `asEXECUTION_EXCEPTION`. That is enough to stop generated code, but it is not enough to reproduce `GetExceptionString()`, `GetExceptionFunction()` or `GetExceptionLineNumber()` after a mixed JIT/VM call.

TypedASTJIT execution therefore treats the boolean as the fast control signal and adds one first-failure record owned by the active execution chain. Conceptually the record contains a stable function identity, message, processed section/row/column, backend/route origin and a reported/adopted state. The first failure wins. Direct TypedASTJIT/BytecodeJIT calls share the same record; a VM or scalar bridge copies the nested context's primary exception into the outer record exactly once; a public context entry adopts the record into the outer `asCContext` before returning `asEXECUTION_EXCEPTION`. Cleanup failures may be retained as diagnostics but never replace the primary exception. Any public/provider layout change is coordinated with the provider ABI rather than silently extending a frozen POD.

HIR models exceptional control separately from handler syntax. Every potentially failing operation has an explicit failure successor. Each lexical scope has a cleanup plan referencing lifetime slots with construction state and reverse destruction order. The initial scalar slice is eligible only when verification proves every normal transfer and failure edge has an empty cleanup plan. A later value-object slice must track partial construction and destroy only live slots, later declarations before earlier ones, exactly once. It must also resolve the existing BytecodeJIT destructor-call hazard: script destructors currently run with `bIgnoreExceptions=true` while sharing an already-failed `FScriptExecution`, even though generated function prologs assume no incoming exception. That path needs an isolated child-execution or VM-cleanup bridge before TypedASTJIT lifetime eligibility opens.

The current language surface does not accept source-level exception handlers. `AngelscriptNativeExceptionHandlingRejectionTests.cpp` rejects `try`, `catch`, `try` without `catch`, `catch` without `try`, and bare rethrow. Although the fork retains internal `tryCatchInfo`, `FindExceptionTryCatch()` and `asCByteCode::TryBlock`, the compiler has no producer for `.TryBlock()` and the tokenizer/parser has no maintained source syntax for it. HIR must record a stable unsupported exception-region marker if such metadata is ever encountered, but this change does not advertise current try/catch support or make invalid source compile.

As an immediate future compatibility correction, BytecodeJIT's exception-cleanup label must emit live local destructors in reverse declaration order, matching VM unwinding and normal scope cleanup. An exploratory generated-output CQTest produced the expected RED result, but both the test and source edit were removed from the active submodule checkout; their exact candidate patch and evidence remain research-only. The full source audit, proposed record/bridge/lifetime seams, test-first patch and validation evidence are in `research/exception-cleanup-and-mixed-execution.md` and `research/patches/exception-cleanup-and-bridge-test-first-patch.md`.

Alternative rejected: treat `bExceptionThrown` plus a log line as exception parity. Logging loses machine-readable origin metadata and cannot satisfy public context APIs or deterministic isolated differential tests.

Alternative rejected: rely on C++ RAII for AngelScript cleanup. Generated storage, return-on-stack ownership, partial construction, bridged VM frames and script destructor calls do not map safely to unverified C++ lexical lifetime.

### Differential generation is a test policy, not a backend or shadow execution

For an eligible fixture, the harness runs isolated `"bytecode"` and `"typed-ast"` generation tasks and retains content-distinct implementation/entry symbol sets only in test artifacts. Only the requested production generation is eligible for ordinary registration. The AngelscriptTest AOT fixture exposes test-only access so the harness can execute VM, BytecodeJIT, and TypedASTJIT sequentially against separately initialized scalar inputs/fixture instances.

The differential oracle compares return value, reflected parameter memory, the primary exception message/function/section/row/column and route origin, cleanup trace, and explicitly declared scalar observable state. Fixtures must not share UObject mutation, global containers, file/network state, randomness, time, or other effects that cannot be cloned. A TypedASTJIT eligibility claim followed by emitter failure is a differential-test failure; an intentionally ineligible function may generate BytecodeJIT-only output accompanied by the expected fallback reason.

Production `"typed-ast"` generation never executes two bodies and never reports a comparison based on shared side effects.

### Diagnostics distinguish request, selection, and fallback

Extend non-Shipping StaticJIT diagnostics with:

- requested backend and whether HIR capture was enabled;
- per-function UFUNCTION-root state and HIR availability/validity;
- selected actual backend (`"bytecode"`, `"typed-ast"`, or no Static entry/VM);
- eligibility/fallback enum, deterministic detail, and source location;
- per-call lowering kind (`DirectScript`, `DirectExported`, `DirectInline`, `RuntimeThunk`, or `Bridge`) and stable external-linkage rejection detail when a direct native call was considered;
- required/available execution capabilities, instrumentation profile, recursion-budget availability, and execution-route detail;
- primary exception payload availability/origin/adoption, exception-region disposition, and cleanup-plan/lifetime state;
- entry kinds produced and execution counters;
- in differential tests, both generated symbol identities and the VM/BytecodeJIT/TypedASTJIT comparison result.

Human-readable `as.StaticJIT.DumpDiagnostics` prints the same information in stable field order. Diagnostics must not expose new `FAngelscriptEngine::*ForTesting` methods and remain compiled out of Shipping according to the existing capability.

### External provider integration is deliberately sequenced

Compiler HIR model/capture can proceed independently. Production backend integration starts only after the private Static contract and generation-only Engine milestones in `refactor-as-unified-jit-coordinator`; no task here creates a stable key, backend registry, Provider catalog/packager, route snapshot, project module, bucket layout, Coordinator, or Live Coding action.

The final integration maps TypedASTJIT results into the shared emitted-function contract and proves one Provider module may contain BytecodeJIT and TypedASTJIT entries without changing stable identity. Removal of an old provider registration seam never removes BytecodeJIT, which remains the default and per-function fallback.

## Risks / Trade-offs

- **Capture hooks duplicate traversal concerns inside the direct bytecode compiler** → Keep the builder write-only, capture only after existing semantic decisions, add bytecode-on/off equality tests, and reject any patch that makes bytecode depend on HIR.
- **Expression IDs are lost during compiler context rewrites** → Treat `asCExprContext` identity propagation across `Clear`, `Copy`, `Merge`, conversions, calls, and short-circuit construction as a tested invariant, not an emitter concern.
- **TypedASTJIT is selected after source compilation** → Freeze BackendId/capture before the generation Engine builds, validate it while freezing the generation view, and fail `CaptureProfileMismatch`; never attempt late AST recovery or backend-owned recompilation.
- **The initial HIR is incomplete** → Represent unsupported forms explicitly with source spans and fall back per function; never synthesize guessed semantics.
- **C++ scalar behavior differs at edge cases** → Use unsigned-domain wrap helpers, pre-checked division/remainder, masked/sign-filled shifts, shared numeric-conversion helpers, boolean normalization, and differential fixtures for every boundary.
- **C++ or a direct-call form reorders argument effects** → Separate source roles, formal bindings, and authoritative evaluation sequence in HIR; materialize every effectful operand into temporaries before assembling the formal call.
- **A call reports a script exception but generated code continues** → Classify call exception/suspend/cleanup behavior and check `FScriptExecution` immediately after every potentially failing operand/call before later side effects.
- **Mixed JIT/VM execution returns exception status but loses the origin** → Keep the boolean control flag, add one first-failure payload, adopt nested VM metadata exactly once, and copy it into the public context before returning exception status.
- **Cleanup or a destructor replaces the original failure** → Preserve the first exception as primary, retain later cleanup failures only as secondary diagnostics, and isolate script-destructor execution from the already-failed parent execution state.
- **Generated C++ scope looks like AngelScript lifetime parity** → Require explicit construction-state slots and per-edge reverse cleanup plans; v1 accepts only plans verified empty.
- **Dormant internal try-region types are mistaken for language support** → Keep the current compile-rejection oracle for try/catch/rethrow and fail closed if internal exception-region metadata appears.
- **Debug frame metadata is mistaken for debugger/coverage/timeout support** → Model execution capabilities explicitly, require the complete direct-call closure to satisfy the current session, and route to VM when line callback/step/local/coverage/safe-point behavior is unavailable.
- **Direct TypedASTJIT recursion bypasses the VM call-stack guard** → Enter a bounded frame/depth scope for every root/helper/SCC and raise a script exception before native stack exhaustion; recursive closures remain VM-routed until this guard exists.
- **A generic `break`/`continue` targets the wrong enclosing construct** → Store and verify the nearest legal target statement ID and compute exited-scope cleanup before lowering.
- **C++ loop/switch spelling hides maintained compiler behavior** → Preserve loop phase order, switch 32-bit selector/case/fallthrough/default/exhaustive-enum rules, and differential-test every transfer edge.
- **C++ compound/postfix syntax evaluates or returns the wrong value** → Lower an explicit single-evaluation mutation plan with old-value/result/store identities and reuse assignment/increment operator oracles.
- **A folded global value hides its invalidation source** → Retain folded-global origin and require the compiler's hard-value dependency; keep mutable global storage and initializer bodies on typed fallback until storage/init lifecycle routing is implemented.
- **Imported/shared/external identifiers are mistaken for owned bodies** → Preserve binding-slot/body-owner semantics and require current-route/provider proof rather than freezing engine-local ids or `boundFunctionId` values.
- **HIR references drift from Cache V2 dependencies** → Reconcile the HIR semantic-use manifest against the authoritative compiler dependencies and fail closed on missing/incompatible coverage without consulting bytecode.
- **Generated/preprocessed offsets are reported as authored source** → Preserve processed authority plus optional explicit authored/generated provenance and degrade diagnostics honestly when no precise map exists.
- **Call marshalling reintroduces VM-layout complexity** → Limit the first bridge to scalar signatures, reuse the existing call contract, and reject any target without a tested marshalling plan.
- **A native-form name compiles but fails when linked from the generated DLL** → Require an explicit external-call descriptor and a separate-module link test; never treat broad include paths or generated call text as export proof.
- **Exporting FBind helpers expands Runtime's public ABI** → Export only the reviewed scalar callable surface, prefer thin Runtime thunks for provider-private helpers, and keep a generated inventory of direct/inline/thunk/private/deferred classifications.
- **UFUNCTION descriptor resolution happens after frontend compilation** → Collect all functions first and classify roots only during final `WriteOutputCode()` when `FunctionDesc->ScriptFunction` is resolved.
- **HIR memory increases generation builds** → Capture only in explicit `"typed-ast"` generation Engines/tests, use indexed arenas, and destroy HIR with the source function; ordinary Editor/game and `"bytecode"` generation remain off by default.
- **BytecodeJIT and TypedASTJIT changes collide with Provider refactoring** → Consume the unified Static request/result and shared Entry Plan; never modify BytecodeJIT or duplicate Provider packaging from this change.
- **TypedASTJIT output still depends on hidden bytecode analysis** → Keep the backend analyzer/reference collection HIR-only, then use bytecode-access sentinels for the complete TypedASTJIT eligibility/reference/emission pipeline.
- **Differential execution can observe order-dependent effects** → Run isolated generation/execution state for VM, BytecodeJIT, and TypedASTJIT; reject non-cloneable cases instead of claiming equivalence.
- **A fork-private API can still spread accidentally** → Keep headers under private frontend sources, add an include-boundary test, and expose only deterministic text dumps to broader tools in the first version.

## Migration Plan

1. Preserve completed research evidence, then add the private HIR model, verifier, dump, optional function sidecar, provisional commit/discard transaction, and default-off capture flag with capture-disabled/capture-enabled bytecode equality tests.
2. Propagate HIR expression identity through `asCExprContext` lifecycle operations and capture only the scalar expression/statement set required by `SemanticScalarBranch`; represent every other encountered form as an explicit unsupported node without changing bytecode.
3. After the unified Static backend contract is available, add a provider-independent `FAngelscriptTypedASTJIT` analyzer/emitter whose input cannot contain bytecode/Provider state, require an explicitly empty cleanup plan, generate a checked-in test probe, and require VM/BytecodeJIT/TypedASTJIT parity plus a non-zero TypedASTJIT execution counter.
4. Route explicit `"typed-ast"` generation through the no-UClass generation Engine, enable capture before its complete source build, freeze the generation view, and fail task-level profile mismatch rather than recompiling inside the backend.
5. Expand scalar/enum and structured-control-flow support, including failure successors, transfer targets, loop phases, switch invalid-value edges, mutation plans, deterministic output, edge semantics, and compiler-synthesized dispositions.
6. Add first-failure exception payload/adoption, frame/depth RAII, recursion protection, execution capability closure, source/safe-point profile identity, and VM routing for unsupported debugger/coverage/timeout/abort sessions before enabling mixed, recursive, or observable production execution.
7. Add descriptor-view UFUNCTION root indexing, shared Entry Plan consumption, typed eligibility, actual-backend/fallback diagnostics, and per-function TypedASTJIT-to-BytecodeJIT-to-VM fallback while `"bytecode"` remains the default.
8. Inventory FBind/native-form targets, add explicit external-linkage metadata, export or thunk the reviewed scalar subset, prove it from a separate consumer module, and then add direct/bridge lowering.
9. Add isolated differential generation/execution and require VM/BytecodeJIT/TypedASTJIT parity for every claimed supported construct and execution route.
10. Publish both Static backend results through the one unified generator/Provider contract, validate mixed-backend module routing, then update Chinese guidance before English consumer documentation.

Rollback at every stage is selection of `"bytecode"` or absence of TypedASTJIT entries. No cache migration is required because HIR is not persisted and bytecode remains authoritative.

## Open Questions

None. Ownership, parser-AST non-retention, expression-ID propagation, provisional commit, capture timing, full-source generation Engine, no-UClass descriptor analysis, profile-mismatch failure, public visibility, persistence, initial node/type/function scope, transfer/mutation/failure semantics, exception payload/adoption, cleanup, source-handler rejection, execution capabilities, recursion, UFUNCTION eligibility, HIR-only analysis/reference collection, stable BackendIds, native-call linkage, fallback, differential-test policy, Entry ABI reuse, and Provider boundary are fixed by this design.
