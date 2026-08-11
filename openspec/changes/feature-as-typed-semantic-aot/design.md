## Context

AngelScript's public JIT integration is intentionally bytecode-oriented. A module finishes compiling a script function into VM bytecode, then invokes the configured JIT compiler with `asIScriptFunction`; the documented input available to a conventional JIT is `GetByteCode()`. Unreal AngelScript's StaticJIT follows that contract: `FAngelscriptStaticJIT::CompileFunction()` collects script functions, `WriteOutputCode()` analyzes them after the complete initial compile, and `GenerateCppCode()` walks every bytecode instruction through `FAngelscriptBytecode` implementations. The generated function then exposes VM, raw, and reflected-parameter entry points.

That architecture is valid when only bytecode is available, but this project's AOT generation command owns the complete source build. During `asCCompiler` execution the frontend already knows the exact `asCDataType` of every expression, the selected overload or constructor, implicit conversions, local-variable scopes, and the original structured statement tree. Most parser nodes are destroyed after bytecode generation, while the current sparse `asISemanticObserver` event stream records only resolved calls, constructors, assignments, and constant strings. Those events are useful for offline analysis but cannot reconstruct a function body, ownership, nesting, values, or control flow.

Unreal-facing script functions marked by the preprocessor's `UFUNCTION()` macro already have `FAngelscriptFunctionDesc` records. During ClassGenerator analysis each descriptor is matched to the exact `asCScriptFunction` and stored in `FunctionDesc->ScriptFunction`; global UFUNCTIONs are represented through the generated statics-class surface. `FAngelscriptStaticJIT` defers output until `WriteOutputCode()`, so the final descriptor graph can define Semantic AOT roots without changing the AngelScript parser or public JIT callback.

The adjacent `refactor-as-static-jit-external-module` change owns stable artifact identity, provider ABI, project module scaffolding, fixed buckets, route snapshots, Editor/PIE behavior, and Live Coding refresh. This change must produce the same entry shapes and later publish through that provider, but it must not invent a competing provider or persistence format.

The external provider also changes the C++ linkage boundary. A generated `<ProjectName>AngelscriptStaticJIT` Runtime module is a different DLL from `AngelscriptRuntime`. Today `FScriptFunctionNativeForm` is exported, but its ordinary function/method forms record C++ spelling, optional include text, and triviality rather than external linkage. For example, `Binds/Bind_FMath.h` declares `FAngelscriptFMathBinds` without `ANGELSCRIPTRUNTIME_API`, while `Binds/Bind_FApp.cpp` declares `FAngelscriptFAppBinds` only inside the implementation file. These bindings may be callable through stored pointers inside Runtime, yet their named out-of-line helpers are not thereby linkable from a generated project DLL. Registration lambdas are unrelated: they install the binding and are not the callable target.

## Goals / Non-Goals

**Goals:**

- Preserve a structured, typed, host-neutral function HIR during source compilation without changing bytecode semantics.
- Prove an end-to-end UFUNCTION-first path from typed HIR to generated C++ and the existing VM/raw/parameter entry ABI.
- Cover a useful scalar vertical slice: locals, conversions, arithmetic, comparisons, bitwise/logical operations, structured control flow, returns, and statically resolved scalar calls.
- Prove cross-module native direct calls through explicit header, owning-module, export/linkage, ABI, and route-safety metadata rather than assuming that a native-form name is linkable.
- Provide a reviewed exported Runtime callable/thunk surface for selected scalar FBind targets while preserving provider-private implementation boundaries.
- Make backend selection explicit and reversible, with legacy bytecode StaticJIT remaining the default and per-function fallback.
- Distinguish unsupported language semantics from generator defects through typed, source-located eligibility results.
- Compare legacy and semantic implementations through deterministic generated output and isolated dual execution tests.
- Keep the HIR reusable by the UE and Standalone hosts while it remains a fork-private model that can evolve.

**Non-Goals:**

- Removing, disabling, or feature-freezing the existing bytecode StaticJIT backend.
- Replacing VM bytecode as the runtime correctness format or changing `PrecompiledScript.Cache`.
- Persisting HIR, inventing an HIR cache, or loading HIR when only precompiled bytecode is available.
- Publishing a stable typed-IR ABI through `angelscript.h` in the first version.
- Supporting UObject/property access, references/out parameters, containers, value-object lifetime, delegates, lambdas, closures, try/catch cleanup, or suspend/coroutine state in the first emitter.
- Directly lowering RPC, BlueprintEvent, BlueprintOverride, virtual dispatch, or other calls that must retain Unreal `ProcessEvent`/route behavior.
- Duplicating the external provider, incremental artifact identity, Editor routing, Live Coding, or project-module scaffolding work.
- Adding `ANGELSCRIPTRUNTIME_API` to every FBind provider/helper or treating binding-registration lambdas as generated-code entry points.
- Performing production shadow execution of two function bodies.

## Decisions

### The compiler owns a structured sidecar HIR

Add fork-private `as_typed_semantic_ir.h/.cpp` under the maintained AngelScript source. `asCTypedSemanticFunction` owns indexed arenas for symbols, expressions, statements, switch cases, and child lists. Node references are stable integer IDs rather than host pointers to polymorphic nodes, which makes traversal, validation, deterministic dumping, and later lowering straightforward.

The initial model contains:

- `asSTypedSemanticSourceSpan`: script section index plus byte offset and length; row/column are derived through the existing script source map for display.
- `asSTypedSemanticSymbol`: stable function-local ID, parameter/local kind, source name, declared `asCDataType`, declaration span, and declaration order.
- `asSTypedSemanticExpression`: kind, exact result `asCDataType`, source span, ordered operand IDs, literal bits/text where relevant, operator/conversion classification, resolved symbol ID, and resolved `asCScriptFunction*` for calls.
- `asSTypedSemanticStatement`: kind, source span, ordered child statement/expression IDs, and explicit block/loop/switch structure.
- `asSTypedSemanticUnsupported`: category, source span, and stable detail token for syntax or semantic forms outside the current model.

Expression kinds initially cover primitive/enum literals, parameter/local reads, assignment and compound assignment, prefix/postfix increment/decrement, unary operations, arithmetic/comparison/bitwise/logical binary operations, explicit compiler-selected conversion, and resolved calls. Statement kinds initially cover block, local declaration, expression statement, if/else, for, while, do-while, switch/case/default, break, continue, and return. Logical `&&` and `||` remain explicit short-circuit nodes rather than ordinary eager binary operations. Ternary expressions, property access, object construction/lifetime, references, handles, containers, lambdas, exceptions, and suspend points initially produce unsupported nodes.

`asCScriptFunction::ScriptFunctionData` owns an optional `asCTypedSemanticFunction*`. It is allocated only for source compilation when HIR capture is enabled, committed only after successful function compilation and verification, and destroyed with `ScriptFunctionData`. Type and function references are valid only while the owning engine/module/function graph is alive, matching existing bytecode reference lifetime; consumers must not retain IR pointers across module replacement.

Alternative rejected: serialize parser AST nodes. They contain unresolved syntax state, temporary allocation/lifetime assumptions, and do not represent final conversions or selected overloads.

Alternative rejected: reconstruct HIR from `asISemanticObserver`. Its sparse event stream intentionally lacks statement nesting, value identity, local ownership, and control-flow structure. The observer remains unchanged and coexists with HIR capture.

Alternative rejected: define an Unreal-only `TArray`/`FString` IR. It would introduce UE into the maintained frontend and force Standalone to maintain a second semantic representation.

### HIR capture is opt-in and cannot perturb bytecode

Add a fork-private engine flag, set through the internal `asCScriptEngine` API rather than `asEEngineProp` or another public `angelscript.h` ABI. `FAngelscriptEngine` enables it before module compilation only for `Semantic` or `Dual` precompiled-data generation. Standalone tests may enable the same internal flag directly because the Standalone host already compiles the maintained private frontend.

`asCCompiler` owns an `asCTypedSemanticIRBuilder` alongside its existing `asCByteCode` builders. Existing semantic compilation remains authoritative: each capture hook runs only after the compiler has resolved the expression type, conversion, overload, and local-variable identity. The builder follows the recursive compiler statement/expression call stack, adds structured nodes, and never feeds decisions back into bytecode generation. Encountering an unsupported form records an unsupported node but does not issue a script compile error.

If compilation reports any error, the provisional HIR is discarded. If HIR verification fails despite a successful script compile, the function retains bytecode but receives an invalid-HIR diagnostic; Semantic AOT must fall back rather than consuming a partial model.

Bytecode invariance is a release criterion: compiling an identical source/module/engine configuration with capture disabled and enabled must produce identical bytecode, debug metadata when enabled, dependency information, and script execution results. HIR is never added to `FAngelscriptPrecompiledFunction`, `FAngelscriptPrecompiledData`, `SaveByteCode`, or `LoadByteCode`. A module loaded only from bytecode therefore has no HIR and deterministically selects legacy/VM.

Alternative rejected: make HIR the source for VM bytecode in the first version. That is a desirable possible future consolidation, but it would combine a VM compiler rewrite with the first Semantic AOT proof and eliminate bytecode as an independent oracle.

### Backend selection is a generation-time enum

Add `EAngelscriptStaticJITBackend : uint8 { Legacy, Semantic, Dual }` and `FAngelscriptEngineConfig::StaticJITBackend`. `FAngelscriptEngineConfig::FromCurrentProcess()` parses `-as-static-jit-backend=legacy|semantic|dual` only in combination with precompiled-data generation.

- Missing option selects `Legacy`.
- `Legacy` uses the existing collector, analyzer, bytecode generator, generated symbols, and registration behavior.
- `Semantic` captures HIR, selects eligible roots at final output, emits Semantic AOT when possible, and invokes the legacy generator for every other function.
- `Dual` is accepted only by developer/test generation surfaces. It generates independent legacy and semantic symbols for eligible test fixtures without registering both implementations for the same production function.
- An unknown option is a configuration error with the accepted values; it must not silently become `Legacy`.

The selected backend belongs to the generation artifact/profile and is not a runtime CVar. Runtime/provider routing chooses among entries already present; it does not transpile or switch a compiled function body on demand.

Alternative rejected: per-function UFUNCTION metadata or AngelScript annotations. Developers should not maintain backend eligibility manually, and annotations would make generator limitations part of the script API.

Alternative rejected: compile-time C++ macros. They prevent one build from producing and testing both paths and make diagnostics less precise.

### The final descriptor graph defines UFUNCTION roots

`FAngelscriptStaticJIT::CompileFunction()` continues collecting every script function during module build. At `WriteOutputCode()`, after the normal initial compile and ClassGenerator analysis, a root index is built from every `FAngelscriptFunctionDesc` with a resolved `ScriptFunction` pointer. Pointer identity, not declaration text or name matching, classifies a root. This handles overloads and generated static classes without adding frontend metadata.

An initial Semantic AOT root must satisfy all of the following:

- It is a concrete `asFUNC_SCRIPT` function represented by a `FAngelscriptFunctionDesc` created for a UFUNCTION surface.
- It is not RPC/net, BlueprintEvent, BlueprintOverride, virtual/non-final, thread-safe-special, suspendable, a validation/event wrapper, or dependent on generated WorldContext injection.
- Its reflected parameters and return are `void`, bool, fixed-width signed/unsigned integer, float, double, or enum by value. References, out parameters, handles, objects, structs, arrays, sets, maps, delegates, and return-on-stack shapes are rejected.
- Its HIR verifies and contains only supported scalar expressions/statements/lifetimes.
- Every call has a scalar marshalling plan and either a safe direct entry or an allowed bridge route.

An instance method may retain an opaque `this` pointer for entry ABI purposes, but using object properties, object casts, virtual calls, or object-valued expressions makes the body ineligible. A global/static UFUNCTION can be eligible when it otherwise meets the same rules.

Eligibility returns `FAngelscriptSemanticAOTEligibility`, containing actual disposition, stable fallback enum, source span when applicable, and a deterministic detail token. Initial fallback categories are `NotUFunctionRoot`, `MissingTypedIR`, `UnsupportedFunctionKind`, `UnsupportedUFunctionFlags`, `UnsupportedSignature`, `UnsupportedType`, `UnsupportedStatement`, `UnsupportedExpression`, `UnsupportedCall`, `UnsupportedLifetime`, `SuspendOrExceptionState`, `InvalidIR`, `EmitterFailure`, and `BackendUnavailable`.

Alternative rejected: compile every AS helper semantically in the first version. UFUNCTION roots provide an existing Unreal ABI and a representative product path; helpers remain callable through legacy/raw/VM bridges and can become roots in a later capability extension.

### Semantic lowering preserves AngelScript scalar semantics

Add a separate `StaticJIT/SemanticAOT` implementation containing eligibility analysis, scalar ABI/type spelling, structured C++ emission, and call marshalling. The emitter never calls `GetByteCode()` and tests must be able to assert that no bytecode cursor or `FAngelscriptBytecode` implementation participates in Semantic AOT generation.

The emitter produces structured C++ blocks and typed locals from HIR. It uses explicit casts and helper functions where C++ would otherwise differ from AngelScript for signedness, narrowing, shifts, integer division, divide-by-zero, overflow boundaries, enum representation, float/double conversion, and boolean normalization. Runtime errors enter the same `FScriptExecution` exception contract used by legacy StaticJIT. Because the first slice has no managed object temporaries, exception cleanup does not own destructors; a function requiring cleanup is ineligible.

Extract or introduce a shared entry-plan layer that describes the function symbol, literal C++ parameter/return representation, VM stack mapping, reflected parameter offsets, and available VM/raw/parameter wrappers. Both emitters consume that plan. The legacy generated text and behavior remain protected by existing golden/AOT tests; extracting the plan must not remove or collapse `FStaticJITContext` or `AngelscriptBytecodes.cpp`.

Generated Semantic AOT entries register through the same current `FStaticJITFunction` seam. After `refactor-as-static-jit-external-module` publishes its ABI, both legacy and semantic entry sets use the same provider entry record, stable identity, and route snapshot. Backend kind may be added as diagnostics metadata, but it is never a second identity namespace.

### Native direct calls require a separate external-linkage descriptor

Keep the existing native forms and `.NativeFunction()`/`.NativeMethod()` behavior for Legacy compatibility, but do not reinterpret those APIs as cross-DLL proof. Extend the native-form/call-plan surface with an explicit `FAngelscriptExternalNativeCall`-style descriptor whose stable data includes:

- linkage class: `ExportedSymbol`, `HeaderInline`, or `ExportedRuntimeThunk`;
- exact C++ symbol expression and includable header;
- owning UE module and legal consumer dependency classification;
- normalized parameter/return ABI identity and supported calling form;
- routing, virtual-dispatch, exception, and lifetime safety flags.

Absence of this descriptor means “not externally direct-callable,” even when Legacy StaticJIT already has a call spelling. The descriptor is attached deliberately by the owning FBind registration or native-form implementation; Semantic AOT does not scan source text, infer `_API` macros from symbol names, or emit its own `extern` redeclaration.

There are three valid outward implementations:

1. **Owning-module export:** the callee already has a public declaration marked by its owning module's API macro. Engine functions keep their Engine-module API; Runtime-owned functions use `ANGELSCRIPTRUNTIME_API`.
2. **Header inline/template:** the complete definition is in the included header and all dependencies are legal for the generated module. It does not need DLL export merely for linkage, but still needs typed ABI and routing proof.
3. **Exported Runtime thunk:** a narrow `ANGELSCRIPTRUNTIME_API` function in an AOT-callable Runtime header forwards to a provider-private helper. This is preferred when exposing `FAngelscript*Binds` would make binding organization a public ABI or leak Runtime-private module dependencies.

The implementation inventory classifies every existing native form and direct-pointer binding as `ExportedSymbol`, `HeaderInline`, `ExportedRuntimeThunk`, `ProviderPrivate`, or `UnknownLegacyNativeForm`. Only the initial supported scalar subset must be migrated in this change; the inventory records deferred functions and why. Adding `ANGELSCRIPTRUNTIME_API` only to a `.cpp` definition is invalid because the generated consumer needs the same imported declaration. Exporting a whole provider struct merely to expose one member is also rejected when a narrow thunk suffices.

A separate UE consumer module must include, link, and invoke every Runtime-owned external symbol/thunk advertised by the initial slice. Golden generated text and tests compiled inside `AngelscriptRuntime` cannot detect a Windows DLL import/export defect. The final generated provider fixture repeats the same proof at the actual module boundary.

Alternative rejected: infer external linkability from `FScriptFunctionNativeForm::GenerateCall()`. It proves only the emitted expression and was designed before the separate project-DLL boundary.

Alternative rejected: add `ANGELSCRIPTRUNTIME_API` to all `FAngelscript*Binds` classes. It expands a large internal implementation surface into a supported public ABI, can expose private dependency headers, and still does not describe routing or typed-call safety.

### Calls degrade at the call site

HIR call nodes retain the resolved `asCScriptFunction*`, exact argument/result types, evaluation order, and source span. The Semantic emitter evaluates arguments left-to-right according to AngelScript semantics and selects one of four lowering forms:

1. **Direct script entry:** a concrete non-virtual script target has a proven scalar raw ABI and the active provider/profile permits that direct route. Emit the resolved entry/reference mechanism owned by the provider contract.
2. **Direct external native entry:** a registered native target has a matching external-call descriptor and is `ExportedSymbol`, `HeaderInline`, or `ExportedRuntimeThunk`. Emit the declared include and typed call without redeclaring the target.
3. **Scalar bridge:** marshal scalar arguments into the existing StaticJIT/VM call frame contract, invoke the current script/native target, propagate exception state, and convert the scalar result back to the HIR type. This covers ordinary non-UFUNCTION AS helpers and bindings whose callable implementation remains provider-private.
4. **Unsupported call:** object/reference/container marshalling, suspend behavior, ambiguous dynamic dispatch, missing external linkage without a bridge, or any target that cannot preserve routing produces `UnsupportedCall` for the root.

Calls to RPC, BlueprintEvent, BlueprintOverride, or virtual Unreal surfaces are never raw-direct even when a pointer is discoverable. They must use the existing current-function/`ProcessEvent`/VM route; if the first-version scalar bridge cannot demonstrate that route, the root is ineligible.

This policy prevents one unsupported helper from automatically forcing its caller back to bytecode while still refusing ABI guesses.

Alternative rejected: require every call to be direct. It would make common UFUNCTION bodies ineligible and conflate backend coverage with binding availability.

Alternative rejected: send every call through the generic VM. It is correct but leaves obvious safe raw/native call performance unused and would not validate typed call lowering.

### Dual mode is a test artifact, not shadow execution

For an eligible fixture, Dual generation emits two content-distinct implementation/entry symbol sets. Only the normal selected set is eligible for ordinary registration. The AngelscriptTest AOT fixture exposes test-only access to both sets so the harness can execute them sequentially against separately initialized scalar inputs/fixture instances.

The differential oracle compares return value, reflected parameter memory, exception state, and explicitly declared scalar observable state. Fixtures must not share UObject mutation, global containers, file/network state, randomness, time, or other effects that cannot be cloned. A Semantic eligibility claim followed by emitter failure is a Dual test failure; an intentionally ineligible function may generate legacy-only output accompanied by the expected fallback reason.

Production Semantic mode never executes both bodies and never reports a comparison based on two executions with shared side effects.

### Diagnostics distinguish request, selection, and fallback

Extend non-Shipping StaticJIT diagnostics with:

- requested backend and whether HIR capture was enabled;
- per-function UFUNCTION-root state and HIR availability/validity;
- selected actual backend (`Legacy`, `Semantic`, or `VM`);
- eligibility/fallback enum, deterministic detail, and source location;
- per-call lowering kind (`DirectScript`, `DirectExported`, `DirectInline`, `RuntimeThunk`, or `Bridge`) and stable external-linkage rejection detail when a direct native call was considered;
- entry kinds produced and execution counters;
- in Dual tests, both generated symbol identities and comparison result.

Human-readable `as.StaticJIT.DumpDiagnostics` prints the same information in stable field order. Diagnostics must not expose new `FAngelscriptEngine::*ForTesting` methods and remain compiled out of Shipping according to the existing capability.

### External provider integration is deliberately sequenced

Compiler HIR, eligibility, emitter, current entry registration, and Dual AOT tests can proceed against the existing three-entry seam. No task in this change creates a stable key, provider catalog, route snapshot, project module, bucket layout, or Live Coding action.

The final integration task begins only after the provider ABI task group from `refactor-as-static-jit-external-module` lands. It maps the Semantic entry plan to the same provider record and proves mixed providers may contain legacy and semantic entries without changing stable function identity. The provider change may remove the old global `FJITDatabase` registration after its own parity gate; that does not remove the legacy bytecode-to-C++ generator required by this change.

## Risks / Trade-offs

- **Capture hooks duplicate traversal concerns inside the direct bytecode compiler** → Keep the builder write-only, capture only after existing semantic decisions, add bytecode-on/off equality tests, and reject any patch that makes bytecode depend on HIR.
- **The initial HIR is incomplete** → Represent unsupported forms explicitly with source spans and fall back per function; never synthesize guessed semantics.
- **C++ scalar behavior differs at edge cases** → Use explicit helpers/casts and differential fixtures for signed overflow boundaries, divide-by-zero, shifts, narrowing, float/double, enums, and short-circuit effects.
- **Call marshalling reintroduces VM-layout complexity** → Limit the first bridge to scalar signatures, reuse the existing call contract, and reject any target without a tested marshalling plan.
- **A native-form name compiles but fails when linked from the generated DLL** → Require an explicit external-call descriptor and a separate-module link test; never treat broad include paths or generated call text as export proof.
- **Exporting FBind helpers expands Runtime's public ABI** → Export only the reviewed scalar callable surface, prefer thin Runtime thunks for provider-private helpers, and keep a generated inventory of direct/inline/thunk/private/deferred classifications.
- **UFUNCTION descriptor resolution happens after frontend compilation** → Collect all functions first and classify roots only during final `WriteOutputCode()` when `FunctionDesc->ScriptFunction` is resolved.
- **HIR memory increases generation builds** → Capture only in Semantic/Dual precompiled builds, use indexed arenas, and destroy HIR with the source function; ordinary Editor/game compilation remains off by default.
- **Legacy and Semantic emitter changes collide with provider refactoring** → Keep this change's long-term boundary at the entry plan and three pointers; postpone provider-specific registration edits until its ABI is available.
- **Dual execution can observe order-dependent effects** → Restrict the oracle to cloneable scalar fixtures and reject unsafe differential cases instead of claiming equivalence.
- **A fork-private API can still spread accidentally** → Keep headers under private frontend sources, add an include-boundary test, and expose only deterministic text dumps to broader tools in the first version.

## Migration Plan

1. Add the private HIR model, builder, verifier, dump, lifetime handling, and capture flag with capture-disabled/capture-enabled bytecode equality tests.
2. Capture the initial scalar expression and structured statement set; preserve unsupported nodes for every deferred form.
3. Add backend configuration, final UFUNCTION root indexing, typed eligibility, and diagnostics while `Legacy` remains the only code emitter selected by default.
4. Add the Semantic scalar emitter and shared entry plan; prove generated C++ shape and the VM/raw/parameter entry paths on a small UFUNCTION fixture.
5. Inventory FBind/native-form targets, add explicit external-linkage metadata, export or thunk the reviewed scalar subset, prove it from a separate consumer module, and then add direct/bridge lowering.
6. Add Dual AOT generation/execution and require legacy-versus-semantic parity for every claimed supported construct.
7. After the external provider ABI lands, publish both backend kinds through that one contract and validate mixed entry routing.
8. Update Chinese StaticJIT/compiler architecture and testing guidance first, then English consumer guidance. Keep `Legacy` as the production default until a future, separately reviewed change supplies coverage and performance evidence for changing it.

Rollback at every stage is selection of `Legacy` or absence of HIR. No cache migration is required because HIR is not persisted and the bytecode archive remains authoritative.

## Open Questions

None. Ownership, lifetime, public visibility, persistence, initial node/type/function scope, UFUNCTION eligibility, backend modes, native-call export/linkage rules, fallback behavior, dual-test policy, entry ABI reuse, and external-provider boundary are fixed by this design.
