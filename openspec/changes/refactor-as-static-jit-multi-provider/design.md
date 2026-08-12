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

A Provider view contains `StructSize`, `AbiRevision`, full stable `ProviderId`, diagnostic provider name, content-derived `ProviderGeneration`, artifact-set digest, artifact profile, Native environment fingerprint, entry table/count, and bucket count. `ProviderId` identifies one generated ownership domain independently of load order or process address. `AbiRevision` is a DLL layout revision, not an alternate JIT behavior version. Runtime accepts only its current revision and has no old-view adapter.

Runtime synchronously copies and validates each view returned through `IModularFeatures`; it never retains provider-owned view/array/string memory. One UE module may register one or more fixed provider feature objects in `StartupModule()` and unregister only those objects in `ShutdownModule()`. Each feature object exposes one current view and calls a generated accessor whenever the view is requested, so Live Coding can patch its manifest without relying on duplicate static-constructor registration.

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

Provider generations are content hashes, not counters. For one `ProviderId`, a new compatible generation supersedes its older generation at a safe publication point. Duplicate `ProviderId + ProviderGeneration` with different bytes is rejected. Provider departure removes only routes supplied by that ProviderId/generation at the next safe point.

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

`AngelscriptTestJIT` depends on Runtime and contains fixed provider module code, generated buckets/slices/manifests, and narrowly scoped exported Native probes used by generated test functions. It contains no CQTest/Automation registrations and no project/runtime feature. It is never created by project Scaffold, never reads the host `Script/` root or project JIT settings, never updates `.uproject`, and never emits into project `Source/AngelscriptJIT`. `AngelscriptTest` privately depends on it and continues to own committed plugin-test fixtures, assertions, the canonical runner, and a separate test-only `-run=AngelscriptTestJIT -Mode=Generate|Verify` entry.

Existing generated `.jit.cpp/.jit.hpp` output moves from `AngelscriptTest/StaticJIT/AOT/Generated` to `AngelscriptTestJIT/Private/Generated`. Checked-in generated C++ remains a reproducible build input. The legacy ignored `StaticJITAotFixture.Cache` pair is removed. Fresh-Engine tests instead create Cache V2 data under an isolated `Saved/Automation/...` root, restore a second Engine, and prove the same provider matches the restored stable identities.

The test Provider registers into the same Runtime multi-provider Registry and uses the production ABI, stable identity, Binding, reference-slot, and 32-bucket emission primitives so it tests the real boundary. That shared protocol is the full extent of the relationship: test and project Providers have different ProviderIds, source roots, target descriptors, commands, manifests, generated outputs, and lifecycles. There is no simplified test-only registration path and no project-owned input in the test Provider.

### Project code lives in the fixed `AngelscriptJIT` module

The `AngelscriptEditor`-owned project commandlet is:

```text
-run=AngelscriptJIT -Mode=Scaffold
-run=AngelscriptJIT -Mode=Generate [-Profile=...]
-run=AngelscriptJIT -Mode=Verify [-Profile=...]
```

Scaffold creates the reserved project module `AngelscriptJIT` beneath `Source/AngelscriptJIT` and adds a `Runtime/PostDefault` `.uproject` descriptor. It never prefixes or suffixes the host project name. The generated module privately depends on `AngelscriptRuntime`; Runtime discovers it through `IModularFeatures` and never depends back on it.

The fixed UE module name is not the Provider identity. The generated ProviderId is derived from the canonical project/source ownership domain and generation contract, so projects all use the readable UE module name `AngelscriptJIT` without collapsing their stable Provider identities. Within one target, an existing incompatible module named `AngelscriptJIT` is a scaffold conflict and is never overwritten.

Scaffold creates exactly 32 bucket `.cpp` translation units. Function slices map by `ReadLE64(StableFunctionKey[0..7]) mod 32`; entries and includes sort by full hash. New functions change an existing bucket include rather than creating a new `.cpp`, which keeps the active Live Coding target graph stable.

Generated source is partitioned into `EditorDevelopment`, `GameDevelopment`, and `GameShipping` profiles. Fixed bucket source selects the current target's profile through compile-time target macros. The generator uses an explicit generation profile on an isolated `FAngelscriptEngine`, including AS `EDITOR`, `EDITORONLY_DATA`, `RELEASE`, `TEST`, cooked binding selection, and artifact identity inputs; it must not assume the Editor commandlet's compile macros describe a Shipping script surface.

Scaffold and Generate write only files with a recognized ownership/revision marker, via temporary-file replacement, and preserve byte-identical files/timestamps. A conflicting unowned file aborts the operation. Verify generates into a temporary root and compares paths, bytes, stable identities, bucket membership, reference slots, and manifest semantics without mutating project source.

Alternative rejected: one `.cpp` per function because active target discovery and build overhead scale badly.

Alternative rejected: one monolithic generated `.cpp` because every edit recompiles the complete project provider.

### Editor source compilation remains authoritative

Remove the blanket Editor skip only after the new adapter/provider route exists; never enable the old global FunctionId database in Editor. Normal preprocessing, source compilation, module swap, ClassGenerator, and class hot reload finish first. A failed AS compile publishes neither a new current-function route nor a JIT route.

After successful AS hot reload, the route snapshot immediately reflects current functions. Unchanged exact entries remain Native; changed/missing entries are VM. Saving a script does not generate C++ or invoke Live Coding.

The explicit `Generate/Refresh AngelScript JIT` Editor operation:

1. rejects AS errors, missing scaffold/active target, or overlapping compile/generation/patch requests;
2. generates only the `EditorDevelopment` profile changes;
3. verifies that Live Coding is available, started, and enabled for the session;
4. subscribes to patch completion and calls `ILiveCodingModule::Compile()`;
5. after completion, requires the expected newer provider generation/artifact-set digest;
6. re-enumerates providers, builds a route snapshot, and publishes it at the Engine safe point;
7. reports written files, compile/patch result, provider rejection reasons, and Native/VM counts.

Unavailable Live Coding leaves valid source on disk and reports the required full build/restart. Compile failure, cancellation, timeout, no provider update, stale generation, or invalid manifest publishes nothing. Runtime and packaged modules have no LiveCoding dependency.

### Packaged profiles remain VM-correct

Development and Shipping builds may load the project JIT module plus other explicitly packaged plugin Provider modules like ordinary Runtime modules. Cache V2 or source compilation establishes current functions; every Provider is attached only through the same Registry and stable identity checks. Test Provider modules remain excluded. Packaged end users never scaffold, generate, or compile C++.

When no provider exists or a provider is stale, bytecode/VM remains the correctness path. Shipping may compile out human diagnostics but retains manifest validation and fallback. A full immutable provider-set match may enable direct-call optimization; partial mismatch cannot invoke stale direct symbols.

### Diagnostics observe providers and routes without test-only Engine APIs

Retain `as.StaticJIT.DumpDiagnostics` in non-Shipping builds and change its model to ProviderIds/UE modules/generations, per-Provider AS-module membership, conflicts, Bindings, stable keys, content/profile/environment/ABI comparisons, stable reference slots, current transient FunctionId, route generation, Native/VM selection, typed miss reason, bucket/slice, and execution counts.

Provider manifests also emit deterministic JSON metadata beside generated C++ for commandlet Verify and offline inspection. The JSON contains no process addresses and is not a runtime authority. Tests use the same diagnostics/provider surfaces rather than adding `FAngelscriptEngine::*ForTesting` cache/JIT methods.

## Risks / Trade-offs

- **AS public ABI break affects embedders and tests** → update the fork header, implementation, StaticJIT adapter, Standalone/native SDK coverage, and generated bridge in one task group; no compatibility layer is promised.
- **Route indirection costs Editor Native performance** → benchmark hot-reloadable callers separately; reserve direct calls for fully validated immutable packaged sets.
- **VM fallback from a Native caller has frame/lifetime edge cases** → require parity tests for primitive/reference/object values, exceptions, virtual dispatch, world context, and thread-safe calls before enabling Editor Native callers.
- **Live Coding may patch code without re-running module startup** → keep one fixed feature object per ProviderId and make it read a patched generated accessor; select only the expected generation for that ProviderId after patch completion.
- **Live Coding completion can race active script calls** → publish only at Engine safe points and retain old immutable route/provider state for in-flight execution.
- **Editor commandlet cannot naturally represent Shipping preprocess/build flags** → introduce an explicit isolated generation profile and prove profile-specific source/binding surfaces before package acceptance.
- **Extracting Cache-named types risks Cache regressions** → perform a representation-preserving type move first and run Cache prefixes before adding provider fields.
- **Generated stale slices can accumulate** → remove them from active manifests immediately; prune physical files only when unreferenced and outside an active patch rollback requirement.
- **Public provider layout drifts** → keep `StructSize`, current `AbiRevision`, golden layout/hash tests, and deterministic reject-before-read behavior; do not carry old revisions.
- **Two independently packaged Providers claim the same function** → never choose by load order; publish `AmbiguousExactProvider`/VM for that function, report all candidates, and keep unrelated Providers/routes active.

## Migration Plan

1. Add red lifecycle tests, replace the fork JIT interface, and remove interface-version selection while leaving existing StaticJIT generation behavior otherwise intact.
2. Extract neutral route/reference values from Cache naming, preserve Cache V2 behavior, and install the per-Engine JIT adapter.
3. Add the current multi-provider ABI/Registry, ProviderId/generation selection, multi-AS-module ownership, stable reference slots, exact match/miss/conflict model, safe publication, and diagnostics.
4. Refactor Runtime generation into content-addressed function slices and fixed buckets; add separate `AngelscriptEditor` project and `AngelscriptTest` fixture orchestration without cross-dependencies.
5. Create the fixed `AngelscriptTestJIT`, move one minimal committed fixture through its independent ProviderId, and expand it through multi-provider and Cache V2 fresh-Engine proof.
6. Use the Editor-owned project Scaffold/Generate/Verify path to generate `Source/AngelscriptJIT` and prove it coexists with TestJIT without consuming it.
7. Enable Editor/PIE current routes, routed script-to-script calls, and route-aware UASFunction dispatch.
8. Add the explicit Live Coding state machine, fake-backend tests, and one opt-in real Editor patch smoke.
9. Validate Development/Shipping multi-module load and immutable-set behavior, then remove the old database/ActiveInfo/DataGuid/FunctionId activation and Editor skip.
10. Update Chinese guidance first, then English guidance, benchmarks, package evidence, All-suite evidence, and final OpenSpec verification.

During migration, VM is the rollback path. The old global path is removed only after the new provider test module and immutable packaged proof cover VM/Raw/Parms execution and multiple engines.

## Open Questions

None. Test/project command and source/output isolation, multi-Provider/multi-AS-module Registry behavior, ProviderId conflict policy, module names, single lifecycle interface, provider/route ownership, fixed bucket count, target profiles, explicit refresh policy, Live Coding role, Cache V2 relationship, UASFunction policy, and no-legacy-compatibility policy are fixed by this design.
