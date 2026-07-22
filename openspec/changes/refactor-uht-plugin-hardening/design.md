## Context

The current UHT exporter is `AngelscriptFunctionBindingExporter` plus a static `AngelscriptFunctionBindingCodeGenerator`. The generator reads project INI text, classifies the engine distribution, walks the UHT type tree, scans headers with a custom text parser, emits Runtime-linked shards or target-module thunks, writes CSV/JSON artifacts, and deletes stale files.

The default installed-engine build currently analyzes thousands of functions successfully. The audit also found that the default build emits 29 Runtime-linked shards but 704 fixed Build.cs wrapper translation units, and each Engine shard repeats roughly 224 includes. The target-module path is not yet verified end-to-end on a source-built engine.

The target-module bridge registers POD-shaped data through `IModularFeatures`. Runtime binding entries keep pointers into generated module storage as `UserData`. That storage belongs to the source module and becomes invalid after module unload unless the Runtime registry tracks and removes it.

## Goals / Non-Goals

**Goals:**

- Make target-module registration safe across late loading, worker-thread notifications, class-registration timing, module unload, and module reload.
- Ensure UHT never emits a native binding when declaration visibility, overload identity, preprocessor state, or signature safety is uncertain.
- Make Editor, UBT, and UHT agree on one effective method and module set.
- Keep generated output deterministic, bounded, diagnosable, and efficient to compile.
- Split responsibilities without changing the confirmed public FunctionBinding names.
- Add source-engine validation that exercises the real generated C++ path.

**Non-Goals:**

- Expanding the supported target-module marshalling surface for containers, delegates, interfaces, out parameters, world-context injection, or reference returns.
- Replacing the existing reflective fallback implementation.
- Reworking unrelated handwritten bindings or the Angelscript compiler.
- Reintroducing JSON profiles or per-module hybrid binding selection.

## Decisions

### 1. Runtime registry owns feature lifetime

The Runtime bridge will maintain an internal registration record per modular-feature instance. A record includes the source feature pointer, module name, descriptor range, resolved class/function bindings, and lifecycle state. Registration and unregistration callbacks both flow through this registry.

Queued GameThread work must not capture an unowned feature pointer without a validity token. The preferred design is a shared registration state whose queued task checks that the feature is still registered before reading its payload. Unregistration removes pending work and removes any `ClassFunctionBindings` entries whose user data belongs to that feature.

The bridge will also retain unresolved descriptors and retry them after class registration or an equivalent UObject lifecycle signal. A class-not-found warning is not a terminal discard.

### 2. Keep the ABI opaque and source-owned

The source-owned bridge header remains the contract authority for field order, flags, and layout version. Generated target-module code must not silently invent a second semantic ABI. Where C++ type identity differs across generated and Runtime translation units, the call-frame and thunk boundary should use an explicitly opaque/C-compatible representation or a generated shared declaration.

The layout token continues to protect field changes, but layout checks alone are not treated as proof that incompatible function-pointer types or ownership semantics are safe.

### 3. Use a conservative analysis pipeline

The analyzer will produce one typed result per eligible `UFunction`. It will distinguish eligibility, binding category, signature confidence, export visibility, include dependencies, and failure reason.

UHT-native typed flags are authoritative for callable, event, RPC, static, const, editor-only, custom-thunk, and parameter properties. Header inspection is retained only where UHT does not expose enough C++ declaration information, primarily overload selection and link visibility.

The declaration resolver must account for active preprocessor state or reject declarations it cannot prove active. It must not treat comments, strings, inactive branches, nested access labels, or function-body punctuation as declarations. Any ambiguous result becomes `ReflectiveFallback` for Runtime-linked mode or a skipped target-module diagnostic.

The current broad signature fallback is narrowed. A resolver failure such as missing class range, missing declaration, malformed declaration, or unresolved overload is not sufficient evidence to emit a native pointer. Special cases must be represented as explicit policy data with tests, not class/function string comparisons embedded in the builder.

### 4. Establish one effective configuration contract

UE INI configuration remains the user-facing authority. The implementation will define one normalized representation containing the selected method, selected module set, unused-array diagnostics, engine distribution, and configuration source. Editor, UBT, and UHT must consume the same token and array semantics, including clear/remove operations or explicitly reject unsupported operations.

If a shared parser implementation cannot be compiled into both UBT and UHT, the project will use shared parser test vectors and a normalized manifest boundary so that the two consumers are checked against the same expected effective settings. A consumer must fail closed when it cannot resolve the same settings as the other build stages.

### 5. Generate only real sources

The generated output will preserve deterministic shards and shard-local include sets, but the Build.cs integration will stop compiling a fixed 64 wrappers per configured module. The preferred layout is a stable per-module aggregator or manifest that references only the shards emitted in the current UHT pass. The final design must keep incremental rebuild behavior acceptable and must not depend on stale generated files being present.

The cleanup pass will cover current prefixes, the one-cycle legacy prefixes, target-module shards, bridge probes, statistics, and module output directories. Cleanup must never delete outside UHT-owned output directories.

### 6. Simplify Runtime-linked generated source ownership

Each configured `NativeRuntimeLinked` module emits exactly one source named `AS_FunctionBinding_<Module>.gen.cpp`. That source owns every direct-binding and reflective-fallback registration for its module, and registers its callback under the stable `FAngelscriptBinds` name `UHT.FunctionBinding.<Module>`. To stay below MSVC's optimized-function size limit, the source may contain private bounded registration helper functions; one public `FBind` callback invokes them all. This gives bind execution observation, disabled-bind diagnostics, and future logging a human-searchable module identity without relying on source filenames or shard numbering.

The generated Runtime-linked callback does not perform wall-clock measurement or emit registration logs. The Runtime timing accumulator and its startup summary are removed with it. The existing top-level performance scope and test-only overall bind observations are independent instrumentation and remain unchanged.

Build.cs retains one generated aggregator translation unit per configured Runtime-linked module solely to include that module's one UHT source when it exists. The aggregator is not a function-binding shard and does not restore fixed wrapper arrays. Source-engine-only `NativeModuleFunctionAddress` output is intentionally unchanged; its module-local thunk shards have a distinct ABI and compilation ownership.

### 7. Diagnostics are a contract

Every eligible function contributes exactly one analysis result. Generated diagnostics include category, confidence/result, failure reason, shard, and generated artifact. Skipped target-module functions and Runtime-linked reflective fallbacks use the same reason vocabulary. Aggregate statistics are computed from the result set rather than from separate emitter counters.

### 8. Responsibility-oriented types

The monolithic generator will be split into types with narrow responsibilities:

- `AngelscriptFunctionBindingConfigurationResolver`
- `AngelscriptFunctionBindingAnalyzer`
- `AngelscriptCppDeclarationResolver`
- `AngelscriptRuntimeLinkedEmitter`
- `AngelscriptNativeModuleFunctionAddressEmitter`
- `AngelscriptFunctionBindingArtifactWriter`
- `AngelscriptFunctionBindingOutputCleaner`

The exact names may change during implementation, but configuration, analysis, declaration resolution, emission, artifact writing, and cleanup must be independently testable.

## Risks / Trade-offs

- **[Risk] Conservative analysis temporarily lowers native-binding coverage.** → Report every fallback reason and add policy-driven support incrementally rather than silently emitting unsafe pointers.
- **[Risk] A module with no eligible Runtime-linked functions has no UHT source.** → Keep the one-module Build.cs aggregator guarded by `__has_include`, so configuration alone cannot create an include failure.
- **[Risk] Module unload cleanup may interact with already-created Angelscript functions.** → Remove or invalidate bindings before module code becomes unreachable and add a reload test that calls affected script functions after unload.
- **[Risk] Source-engine detection differs across Git, worktree, Perforce, and source distributions.** → Define explicit classification tests and make unknown distributions fail closed for target-module mode.
- **[Risk] Aggregation can increase one translation unit's size.** → Preserve bounded shards and benchmark compile time before and after wrapper changes.

## Migration Plan

1. Add lifecycle and configuration tests without changing the default method.
2. Introduce the typed analysis result and diagnostics schema while retaining current generated names.
3. Implement safe target-module registration/unregistration and source-engine end-to-end coverage.
4. Replace the header parser fallback behavior and migrate policy exceptions.
5. Change Runtime-linked generation to one named source and one guarded aggregator per module, remove stale numeric-shard outputs, and remove runtime registration timing.
6. Split the generator types, update documentation, and run default plus source-engine verification.
8. Replace Runtime-linked numeric shards with a single named source per module and verify the generated source contract.

Rollback is configuration-safe: keep `NativeRuntimeLinked` as the default and allow `None` to disable automatic UHT output while a target-module implementation is being corrected. Generated artifacts are disposable and must be regenerated after rollback.

## Open Questions

- Which UObject lifecycle delegate is available in the supported UE versions for retrying unresolved classes without polling?
- Does the project require dynamic plugin module unload/reload support for target-module bindings, or can specific modules be declared startup-only?
- Should `BlueprintNativeEvent` functions that also have `BlueprintCallable` be excluded from FunctionBinding generation because the BlueprintEvent path owns them?
- What is the acceptable maximum generated translation-unit size after wrapper aggregation?
- Can UBT and UHT share a parser source file in the supported Unreal build pipeline, or is a normalized manifest the safer boundary?
