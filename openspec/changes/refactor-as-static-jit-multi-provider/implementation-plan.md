# StaticJIT External Module Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:executing-plans` and implement these milestones sequentially with review checkpoints; this plan has shared Runtime/provider/generator state and is not intended for parallel subagent execution.

**Goal:** Build a stable, function-granular, multi-provider StaticJIT system usable by Editor, PIE, Development, and Shipping, with an isolated plugin-test Provider and independently generated project Providers.

**Architecture:** One maintained-fork JIT Binding lifecycle feeds a Runtime-owned multi-provider Registry and per-Engine routes/reference slots. The plugin-test `AngelscriptTestJIT` and fixed project `AngelscriptJIT` modules register through the same Runtime ABI but use separate owners, commands, inputs, ProviderIds, manifests, outputs, and lifecycles.

**Tech Stack:** Unreal Engine C++ modules and commandlets, maintained AngelScript fork, Cache V2 artifact identities, `IModularFeatures`, UE Live Coding, CQTest/Automation, PowerShell project runners, and Python diagnostics inspection.

## Global Constraints

- Do not preserve the old JIT interface, FunctionId database, DataGuid pairing, Provider layout, or test `.Cache` compatibility.
- `AngelscriptTestJIT` is Editor-only, plugin-test-only, and never consumes or modifies project state.
- The fixed project module is `Source/AngelscriptJIT` with UE module name `AngelscriptJIT`; its Scaffold/Generate/Verify belongs to `AngelscriptEditor` and never depends on test modules.
- Several UE Provider modules and multi-AS-module Providers must coexist; different-Provider exact conflicts use `AmbiguousExactProvider` plus VM.
- Provider descriptions may be process-visible, but functions, reference slots, Bindings, routes, counters, and FunctionIds are Engine-local.
- Editor/PIE current AS compilation and structural hot reload remain authoritative; Native execution is an exact-match optimization.
- Live Coding refresh is explicit and requires one prior full target build; `.as` save alone never launches C++ compilation.
- All builds/tests use `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, or `Tools\RunTestSuite.ps1` and paths from `AgentConfig.ini`.
- Keep new tests split by responsibility and use `Angelscript`-prefixed test filenames.

---

> Status: ready-to-execute plan, rewritten 2026-08-12. This document records future implementation only. This OpenSpec refactor does not change plugin, project, generated, build, or test source.

## 1. Outcome And Non-Negotiable Boundaries

The implementation replaces the present process-local FunctionId/global-database StaticJIT pairing with a stable, function-granular provider model that can be consumed by Editor, PIE, Development Game, and Shipping. It also replaces the fork's incomplete JIT callback ownership with one lifecycle-aware interface capable of publishing and retiring the complete Unreal entry family.

The finished dependency shape is:

```text
                                   generated test code only
AngelscriptRuntime <---------- AngelscriptTestJIT <---------- AngelscriptTest
        ^                                                        |
        |                                                        +-- tests/fixtures
        |                                                        +-- AngelscriptTestJIT Generate/Verify
        |
        +-------------------- AngelscriptJIT <--------------- AngelscriptEditor
                           Runtime/PostDefault provider           |
                                                                 +-- project Scaffold/Generate/Verify
```

The boundaries are fixed:

- `AngelscriptTestJIT` is Editor-only and exists solely to compile JIT code/probes generated from committed plugin-test fixtures. It has no host project source, naming, setting, Scaffold, descriptor, output, or lifecycle relationship.
- `AngelscriptTest` owns automation, plugin-test fixtures, and the isolated `AngelscriptTestJIT` Generate/Verify orchestration.
- `AngelscriptEditor` owns project `AngelscriptJIT` Scaffold/Generate/Verify orchestration.
- Product/project generated code lives in the fixed `Source/AngelscriptJIT` module. ProviderId remains project/source-domain-specific and is not derived from the fixed module name alone.
- Runtime discovers several concurrent providers through a Runtime-owned modular-feature Registry and never depends on a generated provider module. One Provider may contain several AS modules; selection never uses registration/load order.
- Editor `.as` compilation and hot reload remain authoritative. JIT is an optional exact-match execution route.
- Cache V2 and StaticJIT share stable identity and neutral route/reference value types, not persistence or generation policy.
- Numeric FunctionId is transient diagnostic context only.
- There is one current JIT interface and one provider ABI revision. No compatibility layer is required for the old fork interface, upstream v1/v2 selection, legacy generated providers, or legacy test `.Cache` files.
- Live Coding is explicit and optional. It is never invoked automatically by saving `.as`, and it is attempted only after the generated module has completed a normal full build at least once.

## 2. Dependency Order And Milestone Gates

Implementation is intentionally sequential because later layers depend on ownership semantics established earlier:

```text
M1 AS lifecycle
  -> M2 neutral identity/route values
    -> M3 multi-provider ABI + stable references
      -> M4 current call/UASFunction routing
        -> M5 generator + commandlet
          -> M6 AngelscriptTestJIT proof
            -> M7 host project module
              -> M8 Editor/PIE
                -> M9 Live Coding
                  -> M10 packaged + legacy removal
                    -> M11 diagnostics/perf/full verification
```

Do not cross a milestone gate merely because code compiles. Each gate requires its focused red-to-green tests and invariants:

| Gate | Required evidence before continuing |
|---|---|
| M1 | complete binding publish/replace/clear/destroy/re-entry release tests pass |
| M2 | Cache V2 baseline remains green using neutral route/reference types |
| M3 | multi-provider/multi-AS-module validation, ambiguity recovery, stable-reference resolution, and two-engine isolation pass |
| M4 | script calls and representative `UASFunction` shapes prove current-target VM/Native parity |
| M5 | generation is deterministic, content-addressed, 32-bucketed, idempotent, and Verify is read-only |
| M6 | `AngelscriptTestJIT` runs against source and Cache V2-restored fresh engines |
| M7 | host Editor/Game full builds discover the fixed `AngelscriptJIT` module |
| M8 | Editor/PIE edits invalidate only appropriate bindings and structural hot reload remains correct |
| M9 | fake and real patch cycles prove VM-before-patch and Native-after-valid-patch |
| M10 | Development/Shipping package and multi-start correctness pass before old globals are deleted |
| M11 | diagnostics, benchmark, focused suites, All suite, and documentation are complete |

## 3. Milestone 1 — Unified AngelScript JIT Lifecycle

### 3.1 Primary files

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`
- relevant compiler/module discard paths beneath `ThirdParty/angelscript/source/`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Embedding/AngelscriptNativeJitCompilerTests.cpp`
- additional focused lifecycle test files beside it when the existing file would become too large

### 3.2 Target interface shape

Finalize names during implementation, but keep the semantic contract from `design.md`:

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
    virtual int OnFunctionReady(asIScriptFunction* Function) = 0;
    virtual void ReleaseFunctionBinding(
        asIScriptFunction* Function,
        const asSJITFunctionBinding& Binding) = 0;
};
```

`asIScriptFunction` gains delayed `SetJITBinding`/`GetJITBinding` behavior. Publication must atomically replace the complete entry family, never allow callers to observe a mixture of generations, and arrange exactly-once release after active readers finish.

### 3.3 Test-first slices

1. Convert the current recording JIT compiler test double to record `OnFunctionReady`, publication, and full release payloads.
2. Add a failing test for publication after bytecode compilation; no JIT entry is required to be returned synchronously from the callback.
3. Add one failing test each for replacement, explicit clear, module discard, function destruction, engine teardown, compiler replacement, and `SetJITCompiler(nullptr)`.
4. Add re-entrant execution and replacement tests so release cannot occur while an old binding is executing.
5. Implement binding ownership in `asCScriptFunction`, then make all destruction/rollback paths converge on one retire helper.
6. Remove the old `CompileFunction`/`ReleaseJITFunction` contract and any version-select property/interface aliases in one cut. Do not maintain dual behavior.
7. Refactor `FAngelscriptStaticJIT`/generator registration to the new lifecycle and prove the generator does not temporarily install itself through `SetJITCompiler` merely to collect functions.

### 3.4 Gate checks

- Native SDK JIT lifecycle prefix passes.
- Instrumented test compiler sees one release for every published binding and none for an unpublished failed binding.
- Module discard and engine shutdown no longer retain the documented current-fork leak/limitation.
- Normal non-JIT engine behavior remains green with a null compiler.

## 4. Milestone 2 — Neutral Artifact Identity, References, And Routes

### 4.1 Primary files

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h/.cpp`
- new `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactReference.h/.cpp`
- new `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptFunctionRoute.h/.cpp`
- existing Cache V2 route/reference declarations under `AngelscriptRuntime/Cache/`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptArtifactIdentityTests.cpp`
- `.../Cache/AngelscriptCacheFunctionRouteSnapshotTests.cpp`
- `.../Cache/AngelscriptCacheFreshEngineRestoreTests.cpp`
- new small neutral-artifact tests under `AngelscriptTest/Cache/` or `AngelscriptTest/StaticJIT/`

### 4.2 Refactor rule

Move only reusable values and algorithms out of the Cache namespace:

- stable module/type/function identity;
- execution-content, source/debug, profile, environment, and ABI identity dimensions;
- stable reference descriptor/value kinds;
- immutable route value, generation, and typed miss/rejection values;
- safe publication/retirement primitive when both systems genuinely use the same mechanism.

Keep these Cache-owned:

- filesystem store, manifests, generations, transactions, locking, compaction;
- module/class graph restoration;
- dependency invalidation and startup policy;
- cache-specific diagnostics and maintenance.

Keep these StaticJIT-owned:

- C++ generation, provider ABI, Native entry pointers, Live Coding generation, JIT diagnostics.

The desired result is one neutral vocabulary, not a new all-purpose artifact framework.

### 4.3 Gate checks

- Existing Cache V2 source compile and fresh-engine restore tests pass without semantic changes.
- Compile-time layout tests prevent accidental ABI changes to shared values.
- Two engines can reuse/reorder FunctionIds while stable identities compare equal and current routes remain isolated.
- There is no `FAngelscriptStaticJITRouteManager` duplicating the Cache route manager; both consumers use the neutral engine-local route owner.

## 5. Milestone 3 — Multi-Provider ABI And Stable Reference Resolution

### 5.1 Primary files

- new `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProvider.h/.cpp`
- new `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.h/.cpp`
- new `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITReferenceResolver.h/.cpp`
- `StaticJITHeader.h/.cpp`
- `StaticJITBinds.h/.cpp`
- `AngelscriptStaticJIT.h/.cpp`
- `FScriptExecution` declarations/implementation at their existing Runtime locations
- new `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProviderAbiTests.cpp`
- new `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProviderRegistryTests.cpp`
- new `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITMultiProviderTests.cpp`
- new `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITReferenceSlotTests.cpp`

### 5.2 Provider contract

Implement the names fixed by the design unless compile-time constraints require a documented adjustment:

- `FAngelscriptJITProviderId`
- `FAngelscriptJITProviderGeneration`
- `FAngelscriptJITEntryPoints`
- `FAngelscriptJITReferenceSlot`
- `FAngelscriptJITArtifactEntry`
- `FAngelscriptJITProviderView`
- `IAngelscriptJITArtifactProvider`
- `FAngelscriptJITProviderRegistry`

The provider view is a bounded POD-like view exported via `IModularFeatures`. Runtime copies and validates all metadata needed after the registration callback. Generated pointer lifetime is protected by UE-module/ProviderGeneration retention. Every view has explicit structure size, ABI revision, full stable ProviderId, diagnostic module/name, entry count, profile/environment identity, artifact-set identity, content-derived ProviderGeneration, and sorted entries carrying StableModuleKey plus StableFunctionKey.

Compatibility behavior is deliberately simple:

- current revision + valid layout: evaluate entries;
- unknown revision, truncated/invalid layout, invalid order/count/pointer: reject the provider with a typed reason;
- never reinterpret an older shape and never silently downgrade.

The Registry must independently support:

- several UE provider modules loaded at the same time, including `AngelscriptTestJIT`, the host project Provider, and synthetic/plugin Providers used by tests;
- one UE module registering several provider feature objects with distinct ProviderIds;
- one Provider containing entries from several AS source modules;
- several AS Engines resolving the same immutable catalog into separate functions, reference slots, Bindings, routes, and counters.

Within one ProviderId, a newer compatible ProviderGeneration supersedes its older generation at a safe point. Across different ProviderIds, exact function candidates coexist unless they claim the same complete current identity. Such a collision produces `AmbiguousExactProvider` and VM fallback for that function; load/registration order is never a tie-breaker. Unregister removes only the departing ProviderId's candidates, allowing a remaining unique candidate to become Native without AS recompilation.

### 5.3 Stable reference slots

Generated C++ must not embed process addresses, current function objects, numeric ids, or archive-local pointer variables as durable identity. Each generated function declares ordered stable reference descriptors for its dependencies. Runtime resolves them per engine into immutable slots before publishing the binding.

Cover at minimum:

- script function/callee;
- object type and value type;
- global property;
- string/constant data where the runtime requires an engine-local object;
- imported function/module target;
- Runtime helper/thunk with an ABI-stable symbolic key.

A required unresolved, ambiguous, wrong-kind, or wrong-ABI reference rejects only that artifact entry. Optional references must be explicitly typed as optional; null must never mean both “valid null” and “resolution failed.”

### 5.4 Gate checks

- Full provider validation matrix passes.
- `AngelscriptTestJIT`, project, and synthetic/plugin Providers coexist without catalog clearing or cross-selection.
- One Provider matches functions from several AS modules and isolates a changed module's entries.
- Cross-Provider exact conflict uses VM, reports all candidates, and recovers after one Provider unregisters.
- A provider can unregister/replace while an old call is active without use-after-free.
- Equivalent functions in two engines resolve distinct local slots from the same immutable provider description.
- `FScriptExecution` receives the current binding/slots explicitly; no process-global `FAngelscriptEngine::Get()` assumption is needed for generated calls.

## 6. Milestone 4 — Current Call And UASFunction Routing

### 6.1 Primary files

- `AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp`
- `AngelscriptRuntime/StaticJIT/StaticJITHeader.*`
- ClassGenerator/UASFunction allocation and dispatch files located by the current `UASFunction` subclasses
- existing `AngelscriptTest/StaticJIT/AngelscriptStaticJITNativeBridgeTests.cpp`
- existing ASFunction/UASFunction matrix tests; add separate StaticJIT route files instead of growing a single large test file

### 6.2 Reloadable dispatch rule

In Editor, PIE, and reloadable Development contexts:

1. Resolve virtual/import/current-script target according to existing AngelScript semantics.
2. Read the target function's current immutable binding/route snapshot.
3. Use the required Native entry only when the complete exact binding and references are valid.
4. Otherwise execute the current VM/context path.

Generated Native callers and `UASFunction` wrappers must obey the same rule. A Native caller must not hard-code yesterday's Native callee just because both were Native when generated.

### 6.3 Immutable cooked optimization

The generator may retain direct calls only in a profile explicitly marked immutable and only after Runtime validates the complete artifact set, not merely the individual caller and callee. Any mismatch before execution rejects the direct set and preserves VM correctness. Shipping does not attempt partial Editor-style regeneration.

### 6.4 Gate checks

- Changed body: only changed callee falls back, unchanged siblings remain Native.
- Current child override wins over a parent Native entry.
- Reflected Raw/Parms paths preserve writeback, returns, exceptions, cleanup, world context, and object identity.
- In-flight calls retain their old immutable snapshot; later calls see the new generation.

## 7. Milestone 5 — Deterministic Emission And Isolated Tooling

### 7.1 Primary files

- `AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h/.cpp`
- new `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.h/.cpp` for deterministic identity/emission/bucket/provider/comparison primitives
- new `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectGeneration.h/.cpp`
- new `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITCommandlet.h/.cpp` defining `UAngelscriptJITCommandlet`
- `AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.*`
- replace `AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotTestCommandlet.h/.cpp` with `AngelscriptTest/StaticJIT/AOT/AngelscriptTestJITCommandlet.h/.cpp` defining `UAngelscriptTestJITCommandlet`
- new `AngelscriptTest/StaticJIT/AngelscriptJITGenerationDeterminismTests.cpp`
- new `AngelscriptTest/StaticJIT/AngelscriptJITProjectScaffoldTests.cpp`
- new `AngelscriptTest/StaticJIT/AngelscriptJITProjectVerifyTests.cpp`
- new `AngelscriptTest/StaticJIT/AngelscriptTestJITGenerationIsolationTests.cpp`

Generation needs initialized Unreal/AngelScript state, but project discovery/scaffolding and test fixture orchestration do not belong in Runtime. Runtime supplies deterministic stable-identity, reference-capture, function-emission, bucket, Provider ABI/manifest, and comparison primitives. `AngelscriptEditor` supplies project source/profile/descriptor/output orchestration; `AngelscriptTest` supplies committed fixture/fixed ProviderId/test-output orchestration. Neither calls through or depends on the other, and Runtime gains no Editor or test dependency.

### 7.2 Generated layout

Each generated module owns this version-marked layout:

```text
<Module>/
  <Module>.Build.cs                  # scaffold-owned until user modifies ownership marker
  Private/
    <Module>Module.cpp
    Generated/
      Provider.generated.h
      Provider.generated.cpp
      ProviderManifest.generated.json
      Buckets/
        JITBucket_00.cpp
        ...
        JITBucket_31.cpp
      Slices/
        <stable-key>/<content-hash>.jit.hpp
```

Per-function slices are included from one of exactly 32 bucket `.cpp` files. Bucket assignment is a documented stable hash of the full stable function key. Symbols and slice paths include execution content so a Live Coding replacement creates new symbol addresses rather than relying on object-file symbol replacement for the same name.

Generate uses an owned-file inventory and atomic writes:

- byte-identical files are untouched;
- changed owned files are atomically replaced;
- removed generated functions delete only files carrying the expected ownership marker and listed by the previous inventory;
- user-owned or marker-mismatched files cause a conflict, never overwrite;
- profile outputs cannot overwrite another profile's identity.

Verify regenerates into an isolated temporary directory, compares semantic and byte-stable owned output, emits actionable differences, and never edits the project.

### 7.3 Isolated command contracts

```text
# AngelscriptEditor project tool
-run=AngelscriptJIT -Mode=Scaffold
-run=AngelscriptJIT -Mode=Generate [-Profile=EditorDevelopment|GameDevelopment|GameShipping]
-run=AngelscriptJIT -Mode=Verify   [-Profile=EditorDevelopment|GameDevelopment|GameShipping]

# AngelscriptTest plugin-fixture tool
-run=AngelscriptTestJIT -Mode=Generate
-run=AngelscriptTestJIT -Mode=Verify
```

Project `Scaffold` creates the reserved `Source/AngelscriptJIT` Runtime/PostDefault module, updates `.uproject` structurally, and is idempotent. It does not derive a project-name prefix or suffix. An incompatible/user-owned `AngelscriptJIT` module is a hard conflict rather than a reason to invent a longer name. Project Generate requires the module to exist. Project Verify is non-mutating and returns failure for stale/missing/unexpected project-owned output. The generated ProviderId is derived from canonical project/source-domain identity, not from the fixed UE module name alone.

Test Generate/Verify has no Scaffold mode. It uses the committed `AngelscriptTestJIT` module shell, a fixed plugin-test ProviderId, explicit committed fixture roots, and only `AngelscriptTestJIT/Private/Generated`. It must reject project-root/module/output options so accidental project coupling is test-visible.

### 7.4 Gate checks

- Golden outputs are identical across repeated runs and independent temporary roots.
- Whitespace/debug-only source edits retain execution slice identity while updating the separate source/debug manifest fields.
- Removed functions disappear from slice inventory/buckets without touching user files.
- All 32 bucket files always exist so UBT's source discovery is stable.
- Project and test runs with equivalent function shapes exercise the same Runtime emission/ABI primitives but never read or modify each other's ProviderId, manifest, source root, module, or output.

## 8. Milestone 6 — AngelscriptTestJIT

### 8.1 Primary files

- `Plugins/Angelscript/Angelscript.uplugin`
- new `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJIT.Build.cs`
- new `.../AngelscriptTestJIT/Private/AngelscriptTestJITModule.cpp`
- new `.../AngelscriptTestJIT/Private/Generated/`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
- current `AngelscriptTest/StaticJIT/AOT/*`
- new focused AOT provider/source-engine/cache-engine/refresh/UASFunction test files

### 8.2 Module responsibilities

`AngelscriptTestJIT` contains only:

- module startup/shutdown that publishes its generated provider;
- generated provider/bucket/slice code;
- narrow test-native probes referenced by generated fixture code.

It contains no automation registration, CQTest class, commandlet, source fixture orchestration, cache service, or product feature. `AngelscriptTest` owns all of those and privately depends on `AngelscriptTestJIT`.

`AngelscriptTestJIT` is a predeclared plugin module, not an instance of the project scaffold. Its ProviderId is fixed to the plugin-test ownership domain. It never derives a name from the host `.uproject`, reads the host `Script/` root or project JIT settings, modifies `.uproject`, or writes beneath project `Source/`. The project Provider can be loaded beside it only as another independent Registry entry.

### 8.3 Fresh-engine test topology

Replace the ignored legacy `.Cache` prerequisite with a production-like sequence:

```text
committed virtual/physical AS fixture
  -> Engine A current-source compile
  -> stable identity + provider binding + execute
  -> isolated Saved/Automation/... Cache V2 root
  -> flush committed cache generation
  -> destroy Engine A
  -> create Engine B from scratch
  -> restore unchanged artifacts through Cache V2
  -> resolve Engine B reference slots/provider binding + execute
```

The physical file is only backing storage for the existing virtual script path. Tests must use a test-specific cache root and clean it through scoped test fixtures. Logs should print virtual path, physical fixture root, cache generation, engine instance label, stable key, provider generation, binding entries, route generation, and result.

### 8.4 Canonical runner order

1. Baseline Editor target build so the fixed test module and test-only commandlet are discoverable.
2. Run `-run=AngelscriptTestJIT -Mode=Generate` for committed plugin fixtures.
3. Rebuild Editor target to compile changed generated buckets.
4. Run `-run=AngelscriptTestJIT -Mode=Verify`.
5. Run focused StaticJIT AOT/source/cache/multi-engine/multi-provider/UASFunction automation prefixes, including coexistence with an unrelated synthetic or host project Provider.

The runner must explain that generated C++ cannot execute until step 3. Generate succeeding is not execution proof.

## 9. Milestone 7 — Real Project Module Proof

Use the `AngelscriptEditor` project commandlet to Scaffold `Source/AngelscriptJIT/` and add an `AngelscriptJIT` Runtime/PostDefault module descriptor to `AngelscriptProject.uproject`. This is deliberately project-owned output, not plugin product or test logic. Neither project generation nor the generated module depends on `AngelscriptTest` or `AngelscriptTestJIT`.

Required proof:

- UBT discovers it in a full Editor build.
- UBT discovers it in a full Game/Development build.
- module startup publishes the current provider without Runtime linking back to it.
- its ProviderId differs from the fixed `AngelscriptTestJIT` ProviderId and both can coexist in the Editor Registry.
- Generate/Verify are deterministic for the host `Script/` tree.
- repeated Generate touches only changed owned files.
- this initial full build is documented as a prerequisite to Editor Live Coding.

If project-generated output becomes too large for the main review, keep the scaffold/module proof minimal but real; do not substitute `AngelscriptTestJIT` as evidence for fixed project-module/target behavior.

## 10. Milestone 8 — Editor And PIE

### 10.1 Integration points

- Runtime compilation safe point after current functions and stable identities exist, before ClassGenerator consumers publish wrappers.
- Editor hot-reload pipeline under `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/`.
- ClassGenerator reinstancing for structural changes.
- Runtime/provider route refresh for execution-only changes.

### 10.2 Edit classification behavior

StaticJIT consumes semantic results; it must not invent a second text parser. The authoritative compilation/preprocessing/cache identity layer distinguishes:

| Edit | Expected JIT effect |
|---|---|
| line endings, indentation, comments | execution identity unchanged; source/debug identity may change |
| function body semantics | changed function binding becomes VM until matching generation arrives |
| signature, UFUNCTION metadata, reflected flags | function identity/ABI and relevant class graph change; ClassGenerator/hot reload rebuild current metadata |
| property/class layout, base class, interface | structural hot reload/reinstancing owns class impact; new current functions are rebound only after compile completes |
| imported/called declaration | dependency identity invalidates dependent generated entries as captured by compilation artifacts |
| delete/rename | old current binding is retired; no stale Unreal/script path may reach it |

Editor correctness must never depend on heuristically deciding “body-only” from raw file text. Cache V2 semantic capture and the compiler's current declarations are the oracle.

### 10.3 Gate checks

- Editor starts normally with no provider, compatible provider, and incompatible provider.
- PIE uses the same current engine/provider rules and does not bind a stale Editor preview object.
- Body-only edits retain current classes and fall back only affected functions.
- Structural edits still complete class reinstancing and never allow prior layout-specific Native code to execute.

## 11. Milestone 9 — Explicit Live Coding Refresh

The Editor action is a state machine, not a direct “write files and hope” call:

```text
Idle
  -> compile authoritative AS
  -> Generate owned JIT files
  -> ensure module had first full build
  -> request Live Coding compile
  -> wait for patch-complete result
  -> rediscover provider
  -> require newer generation + exact ABI/profile/artifacts
  -> publish affected bindings at safe point
  -> Native

Any failure after AS compile leaves current VM routes valid and reports the failed state.
```

The implementation should isolate `ILiveCodingModule` behind a small Editor service seam. Unit tests use a fake patch service and synthetic provider generations. A final real Editor smoke verifies the actual integration. Runtime and packaged targets must not link the LiveCoding module.

Save-time behavior remains:

- detect source change;
- authoritative AS hot reload/recompile;
- retire mismatched JIT bindings;
- execute VM safely.

Only the explicit action performs C++ generation and Live Coding. If Live Coding is unavailable or disabled, the action tells the user to perform a normal build/restart; it does not turn a correct VM route into an error.

## 12. Milestone 10 — Development, Shipping, And Cutover

### 12.1 Packaged profiles

Generate separate `EditorDevelopment`, `GameDevelopment`, and `GameShipping` provider identities. At package/startup:

- matching provider module loaded: bind exact entries;
- missing module or entry: run VM when the packaged policy permits it;
- profile/environment/ABI mismatch: reject Native entry with deterministic reason;
- complete immutable artifact set: direct-call optimization may be enabled;
- no Live Coding or Editor dependency exists.

Run package/multi-start tests to prove stable matching across process restarts. FunctionId allocation order and pointer values must be intentionally perturbed where possible.

### 12.2 Legacy removal gate

Delete the old path only after new parity exists:

- `FJITDatabase` registration by numeric FunctionId;
- single `FStaticJITCompiledInfo::ActiveInfo` ownership;
- whole-cache `DataGuid` pairing/clearing for generated StaticJIT code;
- generator behavior that replaces the engine JIT compiler;
- blanket Editor JIT exclusion;
- legacy test generated directory and local `.Cache` prerequisite;
- obsolete commandlets/settings/docs.

Search for old symbols before and after removal. No compatibility reader, adapter, migration flag, or v1/v2 terminology should remain in normative APIs.

## 13. Milestone 11 — Diagnostics, Python Inspection, Performance, And Documentation

### 13.1 Diagnostics

Extend `StaticJITDiagnostics.h/.cpp` and `as.StaticJIT.DumpDiagnostics` without adding `FAngelscriptEngine::*ForTesting` APIs. Reports must include:

- ProviderId, diagnostic UE module/name, ProviderGeneration, profile, environment, and ABI;
- complete stable function identity and transient current-engine FunctionId;
- execution-content vs source/debug identity;
- VM/Raw/Parms binding availability;
- stable reference descriptors and engine-local resolution result;
- current route/binding generation and Native/VM selection;
- typed mismatch/rejection reason;
- generated slice/bucket/owned provider;
- execution counters when enabled.

Add a schema-revisioned machine-readable dump. A Python tool can summarize/diff/validate that dump without loading Unreal or parsing human console logs. Test the Python parser with checked-in valid/mismatch/malformed JSON fixtures; C++ tests are still responsible for proving the Runtime emits correct data.

### 13.2 Benchmarks

Record raw CSV/JSON under `openspec/changes/refactor-as-static-jit-multi-provider/benchmarks/` for:

- provider discovery/catalog copy;
- stable-reference resolution;
- per-call route lookup in Editor;
- route refresh after 1, 10, 100, and representative project-scale changed functions;
- Cache V2 restore plus provider binding;
- VM fallback;
- exactly 32-bucket incremental C++ rebuild scope;
- immutable cooked direct call.

Set acceptance budgets only after baseline measurement; do not fabricate thresholds in advance. Correctness and safe lifetime win over premature direct-pointer shortcuts.

### 13.3 Documentation order

Update Chinese guides first, then English equivalents:

- JIT lifecycle/fork difference;
- generated module setup and first-build requirement;
- Generate/Verify/explicit Refresh workflow;
- Editor/PIE fallback semantics;
- Cache V2 relationship;
- packaged profiles;
- diagnostics and Python dump use;
- build/test/package commands and AGENTS architecture counts/facts if module/test totals change.

## 14. Verification Commands

Exact command-line options must follow `Documents/Guides/Build.md` and `Documents/Guides/Test.md` at implementation time and use `AgentConfig.ini` for `Paths.EngineRoot`. The final verification packet must contain commands and report paths for, at minimum:

1. Native AngelScript SDK JIT lifecycle prefix.
2. Cache V2 identity/route/fresh-engine focused prefixes.
3. StaticJIT generation/provider/reference/dispatch diagnostics prefixes.
4. `UASFunction` dispatch matrix and hot-reload prefixes.
5. Baseline build → `AngelscriptTestJIT` Generate → rebuild → test Verify → AOT/multi-provider tests, without project Scaffold or source discovery.
6. Project Scaffold/Generate/Verify and full Editor/Game builds.
7. Real Editor startup, PIE, body-only edit, structural edit, and explicit Live Coding refresh.
8. Development and Shipping package, then at least two launches of each required profile where supported.
9. Configured All automation suite.
10. `openspec validate refactor-as-static-jit-multi-provider --strict`.
11. `git diff --check` in both plugin submodule and parent repository.

Verification logs should print stable keys/profile/ABI/provider generation/route generation on failures. Large test additions must be split by responsibility rather than appended indefinitely to `AngelscriptStaticJITAotTests.cpp`, `AngelscriptStaticJITDiagnosticsTests.cpp`, or existing large Cache test files.

## 15. Stop Conditions And Rollback Strategy

Stop and revise this OpenSpec before proceeding if implementation proves any of these assumptions false:

- Cache V2 cannot reproduce the stable function identities required by a fresh Engine without persisting process-local state.
- a complete binding cannot be retired safely without a broader AS context/call-frame ownership change;
- Raw/Parms entry signatures cannot be represented in one binding without an ABI break larger than recorded here;
- ClassGenerator must cache function pointers in a way that cannot be redirected to current functions;
- Live Coding cannot reliably surface provider-generation replacement for generated modules on the supported UE version;
- Shipping cannot safely fall back to VM under the selected packaging policy.

During implementation, each milestone remains independently revertible until the old global StaticJIT path is removed. The final cutover is deliberately late. If a milestone fails, keep the prior production path active, retain the new tests/research as evidence, and rewrite the remaining tasks rather than inserting undocumented compatibility branches.
