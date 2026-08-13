## Context

Current StaticJIT has four coupled limitations:

1. `asIJITCompiler::CompileFunction()` must synchronously return one `asJITFunction`. The maintained fork also stores separate `jitFunction_Raw` and `jitFunction_ParmsEntry` fields outside that public lifecycle and does not reliably release compiled entries when functions/modules are discarded.
2. Generated code registers process-local numeric FunctionIds in `FJITDatabase`; one `FStaticJITCompiledInfo::ActiveInfo` and precompiled `DataGuid` decide process-wide activation. FunctionIds change across compile order, process, Cache restore, and hot reload and cannot be a persistent Native identity.
3. Editor disables the production JIT path, while UASFunction soft reload can retain old VM/Raw/Parms pointers and generated script-to-script calls directly link content-specific symbols.
4. Test-generated C++ currently lives inside `AngelscriptTest`, paired with a local legacy `.Cache`. There is no independent provider module that proves the same module boundary required of a real game project.

The archived `refactor-as-incremental-function-cache` change has already delivered `FAngelscriptStableFunctionKey`, `FAngelscriptFunctionContentHash`, `FAngelscriptArtifactProfileKey`, `FAngelscriptFunctionArtifactIdentity`, and per-Engine function-route publications. Some reusable route/reference values still carry Cache-specific names. This change consumes those identities and generalizes the live route/reference layer; it does not consume Cache V2 generations, pack selection, source policy, maintenance, or persistence lifecycle as the JIT provider format.

The local AngelScript 2.38 reference contains the JIT interface introduced in 2.37. `asIJITCompilerV2::NewFunction()` allows delayed compilation and `asIScriptFunction::SetJITFunction()` later publishes a result; `CleanFunction()` runs when the entry is replaced or the function is destroyed. Those lifecycle semantics are useful, but the upstream API still has one entry pointer, a v1/v2 engine property, no stable identity, no provider generation, no multi-Engine route ownership, and no Unreal Raw/Parms entry family. The fork can break its old interface because this plugin is still under development.

UE 5.8 exposes `ILiveCodingModule::Compile()`, compile result states, `IsEnabledForSession()`, and `GetOnPatchCompleteDelegate()`. Live Coding can update only a module already present in the active Editor target, so project scaffolding and one full Editor build are prerequisites. Correctness must remain on VM/previous exact routes if generation or patching fails.

## Goals / Non-Goals

**Goals:**

- Establish one lifecycle-aware, non-versioned fork JIT interface with delayed complete Binding publication and correct cleanup.
- Make stable function/content/profile/ABI identity authoritative and keep numeric FunctionId transient.
- Share one neutral per-Engine live function route between Cache V2 restore and StaticJIT provider attachment.
- Move generated test code into an Editor-only `AngelscriptTestJIT` module that exercises the production provider boundary.
- Generate project code into a fixed `AngelscriptJIT` module, usable by Editor, PIE, Development Game, and Shipping.
- Preserve function-granular Native reuse and current VM fallback through AS hot reload and provider refresh.
- Support explicit Editor Generate/Refresh through Live Coding without making Live Coding a Runtime dependency.
- Keep UASFunction dispatch and Native script-to-script calls bound to the current function/override.
- Preserve deterministic generation, diagnostics, multi-Engine isolation, and packaged fallback.

**Non-Goals:**

- Redesigning Cache V2 storage, first-start persistence, source discovery, dependency invalidation, or flush policy.
- Automatically invoking UBT or Live Coding on every `.as` save.
- Generating or compiling C++ on packaged end-user machines.
- Guaranteeing Native artifact reuse across a changed platform, UE build, compiler/toolchain, Runtime ABI, binding ABI, target profile, or generator revision.
- Duplicating the typed semantic HIR/backend owned by `feature-as-typed-semantic-aot`.
- Reusing the Runtime-independent `NativeModuleFunctionAddress` transport ABI.
- Maintaining the old FunctionId/DataGuid provider path or parallel JIT interface versions.

## Decisions

### The fork exposes one complete JIT Binding lifecycle

Replace the current interface family with:

```cpp
struct asSJITFunctionBinding
{
    asJITFunction VMEntry = nullptr;
    asJITFunction_Raw RawEntry = nullptr;
    asJITFunction_ParmsEntry ParmsEntry = nullptr;
    void* UserData = nullptr;
};

class asIJITCompiler
{
public:
    virtual void OnFunctionReady(asIScriptFunction* Function) = 0;
    virtual void ReleaseFunctionBinding(
        asIScriptFunction* Function,
        const asSJITFunctionBinding& Binding) = 0;
};
```

`asIScriptFunction` exposes `SetJITBinding()` and `GetJITBinding()`. The internal script-function data owns one complete Binding rather than three independently mutated public fields.

`OnFunctionReady()` runs only for a successfully compiled or bytecode-restored script function with JIT entry instructions. It does not require an immediate Binding. A compiler/adapter can wait for the full module, provider arrival, or patch completion before calling `SetJITBinding()`.

Replacing a non-empty Binding clears it before invoking `ReleaseFunctionBinding()` to avoid re-entrant double release. Function destruction releases the current Binding exactly once. Replacing or clearing the installed compiler at an Engine safe point releases every Binding owned by the previous compiler, installs the new compiler, and notifies it of existing eligible functions. The engine never has a public JIT interface version selection.

`UserData` is opaque to AngelScript and lets the Runtime adapter associate engine-owned route state without putting Unreal identity types into the generic AS header. Provider-owned view memory is never stored there.

Static source generation no longer installs a temporary compiler into a live Engine. The generator enumerates completed module functions explicitly, so running Generate cannot detach Runtime routes or transfer Binding ownership.

Alternative rejected: copy upstream v2 and merely rename it. That would leave Raw/Parms lifetime and UASFunction dispatch as unmanaged side channels.

Alternative rejected: place `FAngelscriptStableFunctionKey`, provider catalogs, and UE module state in the AS core. That would couple the maintained frontend/runtime to Unreal-specific artifact and module infrastructure.

### Cache and StaticJIT share a neutral function-artifact route

Move the reusable live values currently named `FAngelscriptCacheFunctionRouteSnapshot`, `FAngelscriptCacheLiveFunctionRoute`, and `EAngelscriptCacheFunctionExecutionRoute` into `Core/Artifacts` and rename them without `Cache`. Do the same for the common stable reference tuple (`Kind + StableKey + ExpectedAbi`) while leaving Cache serialization codecs and Cache-only dependency record types in `Cache/`.

Each `FAngelscriptEngine` owns:

- stable key to current `asIScriptFunction*` resolution;
- the current function's transient numeric id;
- verified `FAngelscriptFunctionArtifactIdentity`;
- immutable VM/Native route entries;
- route publication ordinal and provider generation selection;
- typed match/miss result and execution counters.

Cache restore publishes current VM functions into this route. StaticJIT enriches the same publication with an exact Native Binding. No process-global catalog owns current function pointers or FunctionIds.

Provider enumeration and hashing may prepare off-thread. Binding active functions, updating ScriptFunction state, and publishing a new route snapshot occur only at the existing Engine compilation/safe-point handoff. Old immutable snapshots and provider code remain referenced until in-flight calls finish.

Alternative rejected: add a second `FAngelscriptStaticJITRouteManager` next to the implemented Cache route. Two route authorities could disagree about the current function after restore/hot reload.

### Runtime owns a current-revision multi-provider ABI

Add Runtime public values named:

```text
FAngelscriptJITProviderId
FAngelscriptJITProviderGeneration
FAngelscriptJITEntryPoints
FAngelscriptJITReferenceSlot
FAngelscriptJITArtifactEntry
FAngelscriptJITProviderView
IAngelscriptJITArtifactProvider
FAngelscriptJITProviderRegistry
```

A Provider view contains `StructSize`, `AbiRevision`, full stable `ProviderId`, diagnostic provider name, content-derived `ProviderGeneration`, artifact-set digest, artifact profile, Native environment fingerprint, and entry table/count. `ProviderId` identifies one generated ownership domain independently of load order or process address. `AbiRevision` is a DLL layout revision, not an alternate JIT behavior version. Runtime accepts only its current revision and has no old-view adapter. Generated translation-unit count and layout are build-tool metadata, not Runtime ABI, so the provider view does not expose or validate a bucket count.

Runtime synchronously copies and validates each view returned through `IModularFeatures`; it never retains provider-owned view/array/string memory. For every accepted generation it also creates a Runtime-owned lifetime lease. A modular-build lease resolves every VM/Raw/Parms address to its actual base or Live Coding patch image and adds one platform reference per distinct DLL; a monolithic lease records process-image lifetime. Every Registry registration path is rejected when Runtime cannot prove that all entry code remains mapped. Catalogs, Bindings, routes, and active execution readers retain this lease until the generation's last reader exits, and replacement/unregistration defers final catalog/snapshot destruction until after the Registry lock is released. One UE module may register one or more fixed provider feature objects in `StartupModule()` and unregister only those objects in `ShutdownModule()`. Generated carrier modules disable ordinary dynamic unloading, while primary loading remains owned by UE. Each feature object exposes one current view and calls a generated accessor whenever the view is requested, so Live Coding can patch its manifest without relying on duplicate static-constructor registration. Detailed UE evidence and the pin/retirement sequence are recorded in `attachments/provider-dll-lifetime-and-retirement.md`.

Each entry contains full 256-bit values:

```text
StableFunctionKey
+ ExecutionHash
+ DebugHash
+ ArtifactProfile
+ EntryAbiHash
+ NativeEnvironmentFingerprint
+ EntryPoints(VM, Raw, Parms)
+ ordered stable reference slots
```

The environment fingerprint covers platform/architecture, target/configuration, UE build, Unreal AngelScript fork/runtime ABI, generator and bridge revisions, toolchain identity, optimization/debug profile, and binding surface. Entry ABI additionally covers the exact referenced layouts/functions used by that entry. A display GUID is diagnostic only.

Provider generations are content hashes, not counters. For one `ProviderId`, a new compatible generation supersedes its older generation at a safe publication point. Duplicate `ProviderId + ProviderGeneration` with different bytes is rejected. Provider departure prevents new Registry selection immediately and removes only routes supplied by that ProviderId/generation at the next Engine safe point. Retired metadata, Engine-local references, Binding state, and the Provider code pin remain alive until the last active reader exits.

### The Runtime registry supports multiple UE and AngelScript modules

The process-visible Registry is a catalog of immutable provider descriptions, not the owner of current Engine functions:

```text
AngelscriptTestJIT -------- TestFixture ProviderId ------+
ProjectAAngelscriptJIT ---- ProjectA ProviderId --------+--> Runtime JIT Provider Registry
PluginXAngelscriptJIT ----- PluginX ProviderId ---------+             |
                                                                       +--> Engine A routes/references
                                                                       +--> Engine B routes/references
```

These axes are independent:

- several UE provider modules may be registered at once;
- one UE module may expose several ProviderIds when it intentionally owns separate generated domains;
- one Provider may contain functions from several AngelScript modules, and every entry retains its `StableModuleKey + StableFunctionKey` ownership;
- several AngelScript engines may consume the same immutable Provider catalog, but every Engine resolves separate functions, reference slots, Bindings, routes, miss state, and counters.

Candidate selection never uses UE module load order, registration order, pointer value, or numeric FunctionId. Runtime first filters complete identity/profile/environment/ABI/reference compatibility. Within one `ProviderId`, only its selected current generation participates. If two different ProviderIds then claim the same complete current function identity, Runtime returns `AmbiguousExactProvider`, publishes VM for that function, and lists both Providers in diagnostics. It does not silently choose a lexicographic or last-registered winner. In normal operation StableModuleKey/source-domain separation prevents this collision; the explicit fallback makes packaging/configuration mistakes safe.

The current `FJITDatabase` is therefore treated as a static-registration accumulator, not retained as the new Registry. Its `TMap<uint32, ...>` overwrite semantics, all-or-nothing `Clear()`, global reference arrays, single active compiled info, and lack of owner-scoped unregister are removed after parity.

### Generated references are stable slots, not process addresses

Generated code stops emitting archive-local `FJitRef_*` objects that are initialized from process-specific addresses or numeric ids. Each provider entry declares ordered `FAngelscriptJITReferenceSlot` records:

```text
ReferenceKind + full StableKey + ExpectedAbi + SlotIndex
```

The Runtime adapter resolves those records against the current Engine/binding environment into an immutable engine-local table. A missing, ambiguous, or ABI-mismatched required slot makes only that entry a VM miss. `FScriptExecution` carries the current Engine/function/Binding context so generated code can read resolved slots without `FAngelscriptEngine::Get()`.

The generator emits accessors for the semantic use rather than embedding the resolved value: script functions, system-function pointer payloads, type/object-type records, script-global storage, string-literal storage, and script-property offsets are all obtained from the current Binding's slot table. String literals require an explicit content-addressed `StringLiteral` descriptor because the VM owns their process-local storage even when the Cache V2 dependency graph does not otherwise expose them as function dependencies. Provider sources and manifests therefore contain no process pointer literals, archive-local `FJitRef_*` initializers, or address-verification objects; independent Generate and Verify processes must produce byte-identical owned output.

Cache V2 and StaticJIT use the same neutral stable reference kind/key/ABI value. This is a type extraction and shared semantic contract, not a new JIT persistence format inside Cache packs.

### Function matching is granular and debug identity is separate

The route selects Native only when full stable function key, Execution hash, artifact profile, entry ABI, environment, and every required reference match. FunctionId and source timestamp do not participate.

Execution and Debug hashes retain separate meaning:

- whitespace/comment/line movement that does not change executable semantics keeps the Execution hash;
- generated hot-reloadable entries emit stable debug-site identifiers and consult current function debug metadata, so a Debug-only change does not invalidate Native execution;
- the provider keeps Debug hash for diagnostics and debug-artifact validation;
- an entry type that cannot use runtime-mapped debug sites must declare exact-debug matching and fall back on a Debug mismatch rather than silently using stale locations.

A body edit normally preserves StableFunctionKey and changes Execution hash, so only that function loses Native. A signature, owner type, UFUNCTION metadata, reflected ABI, layout, or required reference change alters the stable key or Entry ABI and invalidates the affected entries. Normal AS compilation, Hot Reload, ClassGenerator, and Blueprint/UObject reinstancing remain responsible for those structural changes.

### Editor callers and UASFunctions resolve the current Binding

Hot-reloadable generated script-to-script calls encode the callee StableFunctionKey and invoke the Runtime route bridge. The bridge performs current virtual/override resolution first, then selects the current Native Binding or current VM function. An unchanged Native caller therefore cannot directly call a stale callee symbol after the callee changes.

Generated implementation symbols are content-addressed with the full stable function and Execution hashes. A changed body creates a different implementation symbol and provider generation.

Editor/PIE `UASFunction` wrappers retain the current ScriptFunction/route handle and query its current complete Binding at dispatch. Soft reload updates the ScriptFunction association; it does not copy old VM/Raw/Parms addresses into long-lived UFunction fields. Specialized and generic wrappers, static/world-context calls, virtual calls, primitive/reference/object returns, and thread-safe paths obey the same rule.

An immutable cooked provider may use direct script-to-script symbols and direct UASFunction wrappers only after the complete artifact-set digest and environment fingerprint match. If the set is incomplete, every entry that relies on its direct links is disabled and execution uses safe routed Native or VM behavior.

### `AngelscriptTestJIT` is a test artifact module only

Add `AngelscriptTestJIT` to `Angelscript.uplugin` before `AngelscriptTest` as `Editor/PostDefault`:

```text
AngelscriptRuntime <- AngelscriptTestJIT <- AngelscriptTest
```

`AngelscriptTestJIT` depends on Runtime and contains fixed provider module code, generated per-AS-module `.jit.cpp` sources/manifests, and narrowly scoped exported Native probes used by generated test functions. It contains no CQTest/Automation registrations and no project/runtime feature. It is never created by project Scaffold, never reads the host `Script/` root or project JIT settings, never updates `.uproject`, and never emits into project `Source/AngelscriptJIT`. `AngelscriptTest` privately depends on it and continues to own committed plugin-test fixtures, assertions, the canonical runner, and a separate test-only `-run=AngelscriptTestJIT -Mode=Generate|Verify` entry.

Existing generated `.jit.cpp/.jit.hpp` output moves from `AngelscriptTest/StaticJIT/AOT/Generated` to `AngelscriptTestJIT/Generated` and is regenerated into the strict per-AS-module layout. `AngelscriptTestJITModule.cpp`, `AngelscriptTestJITProbes.cpp`, and `AngelscriptTestJITProbes.h` live directly at the UE module root; this fixed internal test carrier intentionally has neither `Private` nor `Public`. `AngelscriptTest` reaches the root probe header through a private include path and retains a private module dependency. `ANGELSCRIPTTESTJIT_API` still owns the cross-DLL symbol export; it does not require a physical `Public` directory. Checked-in generated C++ remains a reproducible build input. The legacy ignored `StaticJITAotFixture.Cache` pair is removed. Fresh-Engine tests instead create Cache V2 data under an isolated `Saved/Automation/...` root, restore a second Engine, and prove the same provider matches the restored stable identities.

The test Provider registers into the same Runtime multi-provider Registry and uses the production ABI, stable identity, Binding, reference-slot, and per-AS-module emission primitives so it tests the real boundary. That shared protocol is the full extent of the relationship: test and project Providers have different ProviderIds, source roots, target descriptors, commands, manifests, generated outputs, and lifecycles. There is no simplified test-only registration path and no project-owned input in the test Provider.

### Project code lives in the fixed `AngelscriptJIT` module

The `AngelscriptEditor`-owned project commandlet is:

```text
-run=AngelscriptJIT -Mode=Scaffold
-run=AngelscriptJIT -Mode=Generate [-Profile=...]
-run=AngelscriptJIT -Mode=Verify [-Profile=...]
```

Scaffold creates the reserved project module `AngelscriptJIT` beneath `Source/AngelscriptJIT` and adds a `Runtime/PreDefault` `.uproject` descriptor. The earlier phase is an explicit lifecycle contract: the Provider must be registered before the Runtime's first authoritative Engine compile in monolithic Development and Shipping targets, without relying on coincidental ordering among modules in the same phase. It never prefixes or suffixes the host project name. The generated module privately depends on `AngelscriptRuntime`; Runtime discovers it through `IModularFeatures` and never depends back on it.

The fixed UE module name is not the Provider identity. The generated ProviderId is derived from the canonical project/source ownership domain and generation contract, so projects all use the readable UE module name `AngelscriptJIT` without collapsing their stable Provider identities. Within one target, an existing incompatible module named `AngelscriptJIT` is a scaffold conflict and is never overwritten.

The generated project layout intentionally has no `Private` wrapper:

```text
Source/AngelscriptJIT/
├── AngelscriptJIT.Build.cs
├── AngelscriptJITModule.cpp
└── Generated/
    ├── Provider.generated.h                 # stable scaffold selector declaration
    ├── Provider.generated.cpp               # stable target-profile selector TU
    ├── EditorDevelopment/
    │   ├── Provider.generated.h
    │   ├── Provider.generated.inl
    │   ├── ProviderManifest.generated.json
    │   ├── OwnedFiles.generated.json
    │   ├── Tests/Test_Handles.07a7af43.EditorDevelopment.jit.cpp
    │   └── Examples/Core/Example_Math.7fca3709.EditorDevelopment.jit.cpp
    ├── GameDevelopment/
    │   └── ...same source-relative shape...
    └── GameShipping/
        └── ...same source-relative shape...
```

`AngelscriptTestJIT` uses the same module-root convention:

```text
Plugins/Angelscript/Source/AngelscriptTestJIT/
├── AngelscriptTestJIT.Build.cs
├── AngelscriptTestJITModule.cpp
├── AngelscriptTestJITProbes.cpp
├── AngelscriptTestJITProbes.h
└── Generated/EditorDevelopment/...
```

The physical path mirrors the readable virtual source domain: `/Angelscript/Game/<path>` maps directly beneath the profile, `/Angelscript/Plugin/<Name>/<path>` maps beneath `Plugin/<Name>`, and memory-backed modules map beneath `Memory/<Provider>`. The basename is `<SourceStem>.<ShortStableModuleKey>.<TargetProfile>.jit.cpp`. The short key starts at eight hexadecimal characters and extends deterministically in four-character steps when any case-insensitive basename would collide across the complete generated source set; the full StableModuleKey remains authoritative in the file header and manifest. The explicit profile suffix remains mandatory because UE 5.8 UBT may flatten `.cpp` basenames for intermediate object naming.

Each module source starts with the unchanged revision-2 ownership marker, followed by a deterministic metadata block containing virtual source path, canonical module name, target profile, full StableModuleKey, ProviderId, artifact profile, native environment, and function count. Each function has a metadata block containing its canonical AS declaration, virtual source line/column, full StableFunctionKey, execution/debug/entry-ABI hashes, plus an immediate declaration/source/entry-kind comment above every Raw, VM, and Parms entry. Internal C++ symbols remain the complete `ASJIT_<StableFunctionKey>_<ExecutionHash>...` form; readable filenames and comments do not shorten linkage identity.

Scaffold creates only the stable UE module shell, provider selector, Build.cs, and module entry point. Generate groups the complete sorted function set by full `StableModuleKey` and emits exactly one real source-relative `<SourceStem>.<ShortStableModuleKey>.<TargetProfile>.jit.cpp` for every non-empty AS module in each selected target profile. Every generated function retains its full content-addressed symbol based on `StableFunctionKey + ExecutionHash`, but function identity no longer creates a filesystem node. Within a module source, functions and their reference metadata sort by full stable function key. Two modules never share a generated `.jit.cpp`, and one module is never split across generated implementation files.

Generated source is partitioned into `EditorDevelopment`, `GameDevelopment`, and `GameShipping` profiles. The same logical AS module therefore has one independent `.jit.cpp` under each generated profile, because preprocessing, bindings, entry ABI, and environment identity may differ. Each profile source is compile-time guarded so UBT may discover every generated `.cpp` while only the current target's matching source contributes definitions. The generator uses an explicit generation profile on an isolated `FAngelscriptEngine`, including AS `EDITOR`, `EDITORONLY_DATA`, `RELEASE`, `TEST`, cooked binding selection, and artifact identity inputs; it must not assume the Editor commandlet's compile macros describe a Shipping script surface.

A function body/add/delete/rename inside an existing AS module rewrites only that module's `.jit.cpp` plus provider metadata. Byte-identical module sources preserve timestamps. Adding or removing a whole AS module adds or removes one `.jit.cpp` for that profile and changes UBT's source-file set; Generate succeeds and writes the authoritative output, but Refresh refuses Live Coding and requires one normal Editor/Game build before that source-set change can become the active module binary. Deleting a module removes it from the current provider manifest immediately; already loaded historical code may remain mapped until the full rebuild but is unreachable from current routes.

Scaffold and Generate write only files with a recognized ownership/revision marker, via temporary-file replacement, and preserve byte-identical files/timestamps. A conflicting unowned file aborts the operation. Verify generates into a temporary root and compares paths, bytes, stable module membership, per-function identities, reference slots, profile guards, provider metadata, and manifest semantics without mutating project source.

This readability refinement bumps the manifest schema to revision 3 while retaining ownership marker/inventory revision 2 and Provider ABI revision 2. Verify treats both `Private/Generated/<Profile>` and the still older `Private/Generated/Profiles/<Profile>` as stale without mutating either root. Generate migrates legacy profile roots only when their revision-2 inventory, profile, ProviderId, and every existing inventory-listed file marker validate; it deletes only inventory-listed paths and then removes empty legacy directories non-recursively. Scaffold likewise moves the project-owned module entry and selector files from `Private` only when their scaffold ownership markers validate. Invalid or user-replaced legacy output blocks migration and is preserved. Checked-in `AngelscriptTestJIT` implementation sources are repository moves rather than generated-file migration. Every source-path move changes UBT's source set, so a normal build is mandatory and Live Coding refresh is refused.

The selected layout flattens both carriers consistently. Two alternatives were rejected: moving only `Generated` while keeping module implementation files under `Private`, and flattening the project carrier while leaving `AngelscriptTestJIT/Private` intact. Both retain a distinction that is irrelevant for these internal generated-code carriers and leave two path conventions for tooling, documentation, and reviewers to remember.

Alternative rejected: one `.cpp` or include slice per function because filesystem, source discovery, indexing, version-control, and verification overhead scale with function count without improving the actual UE compilation-unit granularity enough to justify it.

Alternative rejected: fixed hash buckets because they allow unrelated AS modules to share one C++ translation unit and violate the required strict one-AS-module-to-one-`.jit.cpp` ownership boundary.

Alternative rejected: one monolithic generated `.cpp` because every edit recompiles the complete project provider.

### Editor source compilation remains authoritative

Remove the blanket Editor skip only after the new adapter/provider route exists; never enable the old global FunctionId database in Editor. Normal preprocessing, source compilation, module swap, ClassGenerator, and class hot reload finish first. A failed AS compile publishes neither a new current-function route nor a JIT route.

After successful AS hot reload, the route snapshot immediately reflects current functions. Unchanged exact entries remain Native; changed/missing entries are VM. Saving a script does not generate C++ or invoke Live Coding.

The explicit `Generate/Refresh AngelScript JIT` Editor operation:

1. rejects AS errors, missing scaffold/active target, or overlapping compile/generation/patch requests;
2. generates only the `EditorDevelopment` profile changes;
3. compares the previous and current generated module-source sets and requires a normal full build if an AS module added or removed a `.jit.cpp`;
4. for an unchanged source set, verifies that Live Coding is available, started, and enabled for the session;
5. subscribes to patch completion and calls `ILiveCodingModule::Compile()`;
6. after completion, requires the expected newer provider generation/artifact-set digest;
7. re-enumerates providers, builds a route snapshot, and publishes it at the Engine safe point;
8. reports changed module sources, source-set changes, compile/patch result, provider rejection reasons, and Native/VM counts.

Unavailable Live Coding leaves valid source on disk and reports the required full build/restart. Compile failure, cancellation, timeout, no provider update, stale generation, or invalid manifest publishes nothing. Runtime and packaged modules have no LiveCoding dependency.

### Packaged profiles remain VM-correct

Development and Shipping builds may load the project JIT module plus other explicitly packaged plugin Provider modules like ordinary Runtime modules. Cache V2 or source compilation establishes current functions; every Provider is attached only through the same Registry and stable identity checks. Test Provider modules remain excluded. Packaged end users never scaffold, generate, or compile C++.

When no provider exists or a provider is stale, bytecode/VM remains the correctness path. Shipping may compile out human diagnostics but retains manifest validation and fallback. A full immutable provider-set match may enable direct-call optimization; partial mismatch cannot invoke stale direct symbols.

The current migration keeps production `bUseImmutableDirectScriptCalls`
disabled for every profile. Development and Shipping use validated Native
VM/Raw/Parms Bindings; the complete immutable-set validator remains the safety
boundary for a future direct-call emitter. Enabling and benchmarking direct
script-to-script symbols is a separate optimization change because it requires
explicit cross-translation-unit declaration and whole-set generation coverage
under the strict one-AS-module-per-`.jit.cpp` layout.

### Diagnostics observe providers and routes without test-only Engine APIs

Retain `as.StaticJIT.DumpDiagnostics` in non-Shipping builds and change its model to ProviderIds/UE modules/generations, per-Provider AS-module membership, conflicts, Bindings, stable keys, content/profile/environment/ABI comparisons, stable reference slots, current transient FunctionId, route generation, Native/VM selection, typed miss reason, owning generated module source, and execution counts.

Provider manifests also emit deterministic JSON metadata beside generated C++ for commandlet Verify and offline inspection. The JSON contains no process addresses and is not a runtime authority. Tests use the same diagnostics/provider surfaces rather than adding `FAngelscriptEngine::*ForTesting` cache/JIT methods.

## Risks / Trade-offs

- **AS public ABI break affects embedders and tests** → update the fork header, implementation, StaticJIT adapter, Standalone/native SDK coverage, and generated bridge in one task group; no compatibility layer is promised.
- **Route indirection costs Editor Native performance** → benchmark hot-reloadable callers separately; reserve direct calls for fully validated immutable packaged sets.
- **VM fallback from a Native caller has frame/lifetime edge cases** → require parity tests for primitive/reference/object values, exceptions, virtual dispatch, world context, and thread-safe calls before enabling Editor Native callers.
- **Live Coding may patch code without re-running module startup** → keep one fixed feature object per ProviderId and make it read a patched generated accessor; select only the expected generation for that ProviderId after patch completion.
- **Live Coding completion can race active script calls** → publish only at Engine safe points and retain old immutable route/provider state for in-flight execution.
- **Editor commandlet cannot naturally represent Shipping preprocess/build flags** → introduce an explicit isolated generation profile and prove profile-specific source/binding surfaces before package acceptance.
- **Extracting Cache-named types risks Cache regressions** → perform a representation-preserving type move first and run Cache prefixes before adding provider fields.
- **Adding/removing an AS module changes the UBT source graph** → Generate the authoritative per-module file set, refuse Live Coding refresh for that transition, retain VM correctness, and print the exact full-build requirement. Function changes inside an existing module retain a stable `.jit.cpp` path.
- **Large individual AS modules produce large C++ translation units** → keep the strict user-selected module boundary, report per-module generated bytes/function counts, and benchmark the largest modules; do not silently split a module into buckets or function slices.
- **Generated stale module sources can accumulate** → remove them from active manifests immediately and atomically prune only files proven owned by the prior inventory; already loaded historical code remains unreachable until the required full build unloads it.
- **Public provider layout drifts** → keep `StructSize`, current `AbiRevision`, golden layout/hash tests, and deterministic reject-before-read behavior; do not carry old revisions.
- **Two independently packaged Providers claim the same function** → never choose by load order; publish `AmbiguousExactProvider`/VM for that function, report all candidates, and keep unrelated Providers/routes active.

## Migration Plan

1. Add red lifecycle tests, replace the fork JIT interface, and remove interface-version selection while leaving existing StaticJIT generation behavior otherwise intact.
2. Extract neutral route/reference values from Cache naming, preserve Cache V2 behavior, and install the per-Engine JIT adapter.
3. Add the current multi-provider ABI/Registry, ProviderId/generation selection, multi-AS-module ownership, stable reference slots, exact match/miss/conflict model, safe publication, and diagnostics.
4. Refactor Runtime generation into deterministic one-AS-module-per-profile `.jit.cpp` sources with content-addressed function symbols; add separate `AngelscriptEditor` project and `AngelscriptTest` fixture orchestration without cross-dependencies.
5. Create the fixed `AngelscriptTestJIT`, move one minimal committed fixture through its independent ProviderId, and expand it through multi-provider and Cache V2 fresh-Engine proof.
6. Use the Editor-owned project Scaffold/Generate/Verify path to generate `Source/AngelscriptJIT` and prove it coexists with TestJIT without consuming it.
7. Enable Editor/PIE current routes, routed script-to-script calls, and route-aware UASFunction dispatch.
8. Add the explicit Live Coding state machine, fake-backend tests, and one opt-in real Editor patch smoke.
9. Validate Development/Shipping multi-module load and immutable-set behavior, then remove the old database/ActiveInfo/DataGuid/FunctionId activation and Editor skip.
10. Update Chinese guidance first, then English guidance, benchmarks, package evidence, the complete impact-focused verification matrix, and final OpenSpec verification. A configured `All` run may provide extra diagnostic evidence but is not required when it repeats unrelated product surfaces outside this change.

During migration, VM is the rollback path. The old global path is removed only after the new provider test module and immutable packaged proof cover VM/Raw/Parms execution and multiple engines.

## Open Questions

None. Test/project command and source/output isolation, multi-Provider/multi-AS-module Registry behavior, ProviderId conflict policy, module names, single lifecycle interface, provider/route ownership, strict one-AS-module-per-profile-`.jit.cpp` layout, target profiles, full-build requirement for module-source-set changes, explicit refresh policy, Live Coding role, Cache V2 relationship, UASFunction policy, and no-legacy-compatibility policy are fixed by this design.
