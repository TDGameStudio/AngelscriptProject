# StaticJIT Multi-Provider Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task with review checkpoints. Steps use checkbox (`- [ ]`) syntax for tracking. Current session policy forbids subagent dispatch unless the user explicitly asks for it.

**Goal:** Complete `refactor-as-static-jit-multi-provider` from the implemented M1–M4 baseline, using a strict one-AS-module-per-target-profile-`<StableModuleKey>.<TargetProfile>.jit.cpp` generated layout through test, project, Editor/PIE, Live Coding, Development, and Shipping workflows.

**Architecture:** `AngelscriptRuntime` owns the current Provider ABI, registry, engine-local matching/routing, deterministic per-AS-module emission, and generated-file comparison primitives. `AngelscriptEditor` owns project discovery, scaffold, Generate/Verify, and Live Coding orchestration; `AngelscriptTest` owns test orchestration and assertions; the new Editor-only `AngelscriptTestJIT` module owns only generated fixture code and test-native probes. Provider entries remain function-granular and content-addressed even though physical C++ ownership is module-granular.

**Tech Stack:** Unreal Engine 5.8 C++, AngelScript maintained fork, CQTest/UE Automation, Unreal commandlets, UBT modules, `IModularFeatures`, Cache V2, `ILiveCodingModule`, PowerShell test runners, deterministic JSON/Blake3 identities.

## Global Constraints

- Work in the current checkout; do not create a worktree.
- `Plugins/Angelscript` is a git submodule. Do not commit or update the parent gitlink unless the user explicitly asks.
- The plugin is the deliverable; project code belongs only in the fixed proof module `Source/AngelscriptJIT`.
- Strict layout invariant: for each target profile, every JIT-bearing StableModuleKey owns exactly one source-relative `<SourceStem>.<ShortStableModuleKey>.<TargetProfile>.jit.cpp`; modules never share a generated implementation TU and one module is never split. The short key extends deterministically on case-insensitive basename collision, while the profile suffix prevents UE 5.8 UBT's basename-flattened object names from colliding across profile directories.
- Function symbols remain `StableFunctionKey + ExecutionHash` content-addressed; numeric FunctionId and process addresses never become persistent identity.
- `EditorDevelopment`, `GameDevelopment`, and `GameShipping` are isolated generation profiles with explicit compile guards and environment fingerprints.
- Runtime Provider ABI contains no bucket or generated-translation-unit topology. Layout changes bump the current ABI with no compatibility adapter.
- Generate may write only recognized owned files atomically and must preserve byte-identical files/timestamps. Verify is read-only and returns non-zero for every stale/missing/unexpected/conflicting artifact.
- Adding/removing a generated module `.jit.cpp` changes the UBT source set and requires a normal full build; Live Coding is allowed only when the generated source-path set is unchanged.
- Editor/PIE source compilation and structural hot reload remain authoritative. Any mismatch falls back at function granularity to the current VM route.
- `AngelscriptTestJIT` is Editor/PostDefault, depends on `AngelscriptRuntime`, is depended on by `AngelscriptTest`, and is excluded from non-Editor targets.
- No packaged end-user C++ generation and no automatic Live Coding compile on `.as` save.
- Use `apply_patch` for hand edits, `rg` for search, and record exact RED/GREEN evidence in `verification.md` at each milestone.
- Treat this plan as revisable: when implementation evidence contradicts an assumption, update `design.md`, `tasks.md`, and this plan before continuing. Route incremental investigations, failed approaches, migration samples, performance data, and long logs according to `attachments/README.md`; keep `tasks.md` as a clean acceptance checklist.

## Current Baseline

M1–M4 and generic file publication are implemented: unified VM/Raw/Parms binding lifecycle, neutral artifact routes, multi-provider catalog/matching, stable reference slots, engine-local execution contexts, routed generated calls, and route-aware `UASFunction` publication. The former M5 per-function-slice/32-bucket output is deliberately superseded and must be removed rather than preserved behind a mode.

---

### Task 1: Remove build topology from the Provider ABI

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProvider.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProvider.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.cpp`
- Create: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderLifetime.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProviderAbiTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProviderRegistryTests.cpp`

**Interfaces:**
- Consumes: current `FAngelscriptJITProviderView`, manifest hashing, copied provider catalogs.
- Produces: Provider ABI revision `2` without `BucketCount`/`GeneratedBucketCount`, plus updated deterministic digest/validation behavior.

- [x] **Step 1: Add a failing ABI revision and topology-independence test**

Change the ABI tests to require revision 2 and prove otherwise identical provider views validate and hash without any generated-file-count input:

```cpp
TEST_METHOD(ProviderAbiRevisionDoesNotEncodeGeneratedFileTopology)
{
    ASSERT_THAT(AreEqual(2u, FAngelscriptJITProviderAbi::Revision));
    FAngelscriptJITProviderView View = MakeValidProviderView();
    ASSERT_THAT(IsTrue(
        FAngelscriptJITProviderManifest::Validate(View).IsValid()));
}
```

- [x] **Step 2: Run the focused test and capture RED**

Run:

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-per-module-abi-red -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProviderAbi' -Label staticjit-per-module-abi-red-tests -TimeoutMs 180000
```

Expected: ABI test fails because revision is still 1 and current validation/view still exposes bucket topology.

- [x] **Step 3: Implement the ABI cutover**

Make the public shape exactly:

```cpp
namespace FAngelscriptJITProviderAbi
{
    inline constexpr uint32 Revision = 2;
    inline constexpr uint32 MaximumEntryCount = 1u << 20;
    inline constexpr uint32 MaximumReferenceSlotCount = 1u << 16;
}

struct FAngelscriptJITProviderView
{
    uint32 StructSize = sizeof(FAngelscriptJITProviderView);
    uint32 AbiRevision = FAngelscriptJITProviderAbi::Revision;
    FAngelscriptJITProviderId ProviderId;
    FAngelscriptJITProviderGeneration ProviderGeneration;
    FAngelscriptHash256 ArtifactSetDigest;
    FAngelscriptArtifactProfileKey ArtifactProfile;
    FAngelscriptHash256 NativeEnvironmentFingerprint;
    const TCHAR* ProviderName = nullptr;
    const TCHAR* OwnerModuleName = nullptr;
    const FAngelscriptJITArtifactEntry* Entries = nullptr;
    uint32 EntryCount = 0;
};
```

Remove the bucket-count validation code/reason, stop hashing/emitting it, update copied catalogs, and update every view initializer. Do not add a revision-1 reader.

- [x] **Step 4: Build and run ABI/registry/provider matching tests**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-per-module-abi-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProviderAbi' -Label staticjit-per-module-abi-green-tests -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProviderRegistry' -Label staticjit-per-module-registry-abi -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProviderMatch' -Label staticjit-per-module-match-abi -TimeoutMs 180000
```

Expected: all focused tests pass and no Runtime header/source contains `BucketCount` or `GeneratedBucketCount`.

---

### Task 2: Define deterministic per-AS-module generation records

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITGenerationDeterminismTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITGenerationProfileTests.cpp`

**Interfaces:**
- Consumes: sorted `FAngelscriptJITGenerationFunction` values with StableModuleKey, current Cache publication canonical module names, target profile.
- Produces: `FAngelscriptJITGenerationModule`, `FAngelscriptJITGeneratedModule`, `ModuleSourceRelativePath`, and `EAngelscriptJITGeneratedFileKind::ModuleSource`.

- [x] **Step 1: Replace old golden expectations with failing strict-layout tests**

Add tests with two functions in module A and one in module B. Require exactly two implementation files and no slice/bucket path:

```cpp
ASSERT_THAT(AreEqual(2, Output.Modules.Num()));
ASSERT_THAT(AreEqual(2, Output.Files.FilterByPredicate(
    [](const FAngelscriptJITGeneratedFile& File)
    {
        return File.Kind == EAngelscriptJITGeneratedFileKind::ModuleSource;
    }).Num()));
ASSERT_THAT(IsTrue(Output.Functions[0].ModuleSourceRelativePath
    == Output.Functions[1].ModuleSourceRelativePath));
ASSERT_THAT(IsFalse(Output.Functions[0].ModuleSourceRelativePath
    == Output.Functions[2].ModuleSourceRelativePath));
ASSERT_THAT(IsFalse(Output.Files.ContainsByPredicate(
    [](const FAngelscriptJITGeneratedFile& File)
    {
        return File.RelativePath.Contains(TEXT("Slices/"))
            || File.RelativePath.Contains(TEXT("JITBucket_"));
    })));
```

Also require body-only changes to retain `<source-dir>/<source-stem>.<short-module-key>.<profile>.jit.cpp`, change only that module's content hash, and preserve the unrelated module's exact bytes.

- [x] **Step 2: Run generation tests and capture RED**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-per-module-generator-red -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.Generation' -Label staticjit-per-module-generator-red-tests -TimeoutMs 180000
```

Expected: failures name the old `FunctionSlice`, `BucketIndex`, `SliceRelativePath`, or 32 bucket output.

- [x] **Step 3: Introduce the new request/output model**

Use these exact public records:

```cpp
struct FAngelscriptJITGenerationModule
{
    FAngelscriptStableModuleKey ModuleKey;
    FString CanonicalModuleName;
    FString VirtualSourcePath;
};

struct FAngelscriptJITGeneratedModule
{
    FAngelscriptStableModuleKey ModuleKey;
    FString CanonicalModuleName;
    FString VirtualSourcePath;
    FString SourceRelativePath;
    FAngelscriptHash256 ContentHash;
    uint32 FunctionCount = 0;
};
```

Add `TArray<FAngelscriptJITGenerationModule> Modules` to the request and `TArray<FAngelscriptJITGeneratedModule> Modules` to the output. Replace `SliceRelativePath`/`BucketIndex` on generated functions with `ModuleSourceRelativePath`. Rename `BucketPreamble/Footer` to `ModuleSourcePreamble/Footer`. Set manifest `SchemaRevision = 3` and `OwnershipRevision = 2`.

- [x] **Step 4: Emit exactly one source per StableModuleKey**

Implement:

```cpp
Build all module paths as one set from `VirtualSourcePath`, source stem,
target-profile suffix, and an 8-character StableModuleKey prefix. Compare
physical basenames case-insensitively and extend colliding prefixes in
four-character steps until unique. Preserve the complete StableModuleKey in
metadata and manifest.
```

Validate unique non-zero module keys and non-empty canonical names; validate that every function names a declared module and every declared module owns at least one generated function. Sort modules by full key and functions by `(ModuleKey, FunctionKey)`. Concatenate the complete implementations for one module into its one source, calculate the deterministic content hash, and store function membership/count in manifest JSON. Remove `GetBucketIndex`, `BuildSliceRelativePath`, function-slice creation, bucket creation, and all fixed-count logic.

- [x] **Step 5: Feed module identity from real compiled modules**

In `GenerateStaticJITProviderArtifacts`, first collect the unique StableModuleKeys present in `OrderedFunctions`, then resolve exactly those keys from `Publications.Current->Modules` and add one request module per key:

```cpp
Request.Modules.Add({PublishedModule->ModuleKey,
    PublishedModule->CanonicalModuleName,
    ModuleDesc->Code[0].VirtualPath});
```

Continue deriving each function implementation and stable reference slots as today. Put shared includes/declarations into `ModuleSourcePreamble`; provider-only definitions remain in `ProviderSourcePreamble`.

- [x] **Step 6: Build and prove deterministic generation/profile isolation**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-per-module-generator-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.Generation' -Label staticjit-per-module-generator-green-tests -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.GeneratedOutput' -Label staticjit-per-module-generated-output -TimeoutMs 180000
```

Expected: one source per module, stable paths across body changes, separate guarded profile bytes, zero current-layout slice/bucket artifacts.

---

### Task 3: Publish, compare, and migrate owned per-module sources safely

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneratedFileStore.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneratedFileStore.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectGeneration.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectGeneration.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProjectGenerationTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITGenerationProfileTests.cpp`

**Interfaces:**
- Consumes: schema/ownership revision 2 output and prior revision-1 inventory.
- Produces: atomic publication, read-only comparison, `AddedModuleSources`/`RemovedModuleSources`, and one-time safe legacy cleanup.

- [x] **Step 1: Add RED tests for unchanged modules and legacy cleanup**

Test that changing one module rewrites only its source and provider metadata; another module's timestamp and bytes remain identical. Seed a revision-1 inventory with recognized `function-slice`/`bucket` markers and require Generate to remove those paths. Seed an unowned lookalike path and require `OwnershipConflict` without deletion.

- [x] **Step 2: Run the file-store/project-generation prefixes and capture RED**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectGeneration' -Label staticjit-per-module-store-red -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.GenerationProfile' -Label staticjit-per-module-profile-red -TimeoutMs 180000
```

- [x] **Step 3: Implement profile guards and source-set deltas**

Module sources must be wrapped exactly as follows:

```cpp
// EditorDevelopment
#if WITH_EDITOR && UE_BUILD_DEVELOPMENT
// generated module content
#endif

// GameDevelopment
#if !WITH_EDITOR && UE_BUILD_DEVELOPMENT
// generated module content
#endif

// GameShipping
#if !WITH_EDITOR && UE_BUILD_SHIPPING
// generated module content
#endif
```

`PrepareProjectProfileOutput` leaves `ModuleSource` paths as real `.jit.cpp` files and renames only generated provider implementation to `Provider.generated.inl`. Compare prior/current owned inventories to return added/removed module-source paths separately from ordinary content changes.

- [x] **Step 4: Implement revision-1 cleanup as removal-only migration**

Parse a revision-1 owned inventory only to identify prior files. Delete a prior file only when its content starts with the exact revision-1 owned marker and its normalized path remains below the target profile root. Never accept revision-1 output as current and never emit it. Stage all writes and validate every removal before replacing/deleting any destination.

- [x] **Step 5: Run focused and regression tests**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-per-module-store-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectGeneration' -Label staticjit-per-module-store-green-tests -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.GenerationProfile' -Label staticjit-per-module-profile-green-tests -TimeoutMs 180000
```

---

### Task 4: Refactor project Scaffold, Generate, and Verify

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectScaffold.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectScaffold.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITCommand.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITCommand.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITCommandlet.cpp`
- Create: `Tools/RunAngelscriptJIT.ps1`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProjectScaffoldTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITCommandletTests.cpp`

**Interfaces:**
- Consumes: per-module project generation and source-set delta.
- Produces: bucket-free stable scaffold, detailed Verify report, `bRequiresFullBuild`, and non-zero stale exit.

- [x] **Step 1: Write failing scaffold/commandlet tests**

Require Scaffold to create only `Build.cs`, module source, selector header/source, and `.uproject` entry; assert no `JITBucket_` path exists. Generate two modules and assert two real `.jit.cpp` paths. Verify report must contain:

```text
Status=Stale
ProviderId=<full hash>
Profile=EditorDevelopment
ProviderAbiRevision=2
StableModuleKey=<full hash>
CanonicalModuleName=<name>
VirtualSourcePath=/Angelscript/Game/<path>.as
ModuleSource=<path>/<stem>.<short-key>.EditorDevelopment.jit.cpp
Function StableFunctionKey=<full hash> Declaration=<AS declaration> Source=<virtual-path>:<line>:<column> Symbol=<content symbol>
Difference Kind=Missing|UnexpectedOwnedFile|ContentMismatch Path=<path>
```

Assert `UAngelscriptJITCommandlet::Main()` returns `1` and leaves stale bytes untouched.

- [x] **Step 2: Run RED tests**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectScaffold' -Label staticjit-per-module-scaffold-red -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.Commandlet' -Label staticjit-per-module-command-red -TimeoutMs 180000
```

- [x] **Step 3: Remove fixed bucket scaffold and inspection**

Delete `FixedBucketContent`, the 32-file scaffold loop, bucket marker inspection, and bucket-count currentness checks. The stable provider selector continues selecting `Profiles/EditorDevelopment/Provider.generated.inl`, `Profiles/GameDevelopment/Provider.generated.inl`, or `Profiles/GameShipping/Provider.generated.inl`.

- [x] **Step 4: Expose full-build requirement and module diagnostics**

Add to the project-generation/command result:

```cpp
bool bRequiresFullBuild = false;
TArray<FString> AddedModuleSources;
TArray<FString> RemovedModuleSources;
FString Report;
```

Generate succeeds even when the source set changes, but reports the exact added/removed paths and full-build requirement. Verify reports every difference and remains read-only. Scaffold reports that Generate followed by a full target build is required before the first provider can load.

Add `Tools/RunAngelscriptJIT.ps1` with validated `Mode=Scaffold|Generate|Verify`, `Profile=EditorDevelopment|GameDevelopment|GameShipping|All`, project path from `AgentConfig.ini`, isolated logs/metadata beneath `Saved/AngelscriptJITRuns/<label>/`, explicit timeout, and propagation of the commandlet exit code. Scaffold omits the profile argument; Generate/Verify pass it explicitly.

- [x] **Step 5: Build and run command/scaffold/project prefixes**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-per-module-command-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectScaffold' -Label staticjit-per-module-scaffold-green -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.Commandlet' -Label staticjit-per-module-command-green-tests -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectGeneration' -Label staticjit-per-module-project-green -TimeoutMs 180000
```

---

### Task 5: Finish safe provider generation retirement and coexistence

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITBindingContext.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITBindingContext.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITExecutionContext.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITExecutionContext.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITMultiProviderTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITBindingPublicationTests.cpp`

**Interfaces:**
- Consumes: copied immutable catalogs and retained binding snapshots.
- Produces: owner-scoped generation handles that keep retired provider code/reference tables alive through the last active reader.

- [x] **Step 1: Add RED overlap/coexistence tests**

Cover: generation A call active while generation B publishes; A unregisters while call is active; unrelated Provider C remains selected; two engines retain independent snapshots; two different ProviderIds conflict only on the claimed function; unregister/re-register recovers deterministically independent of registration order.

- [x] **Step 2: Run RED prefixes**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.MultiProvider' -Label staticjit-provider-retirement-red -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.BindingPublication' -Label staticjit-provider-binding-red -TimeoutMs 180000
```

- [x] **Step 3: Retain immutable generation ownership in bindings**

Each selected route/binding holds a shared immutable generation record containing copied metadata, entry/reference tables, ProviderId/generation, and the Runtime-owned code-image lifetime lease. In modular builds the lease resolves all VM/Raw/Parms addresses and pins every distinct containing base/Live-Coding-patch DLL with an extra platform handle; in monolithic builds it records process-image lifetime. All Registry registration paths reject unprovable code lifetime. Registry removal prevents new selection immediately but defers generation destruction and handle release until all binding/route/execution snapshots release it, with final old-catalog/snapshot release occurring outside the Registry lock. Generated carrier modules also disable ordinary dynamic unloading. Never store provider-owned array/string memory or provider-implemented release callbacks. See `attachments/provider-dll-lifetime-and-retirement.md`.

- [x] **Step 4: Prove coexistence and mark tasks 3.6/3.8 complete**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-provider-retirement-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.MultiProvider' -Label staticjit-provider-retirement-green-tests -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.BindingPublication' -Label staticjit-provider-binding-green-tests -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ExecutionContext' -Label staticjit-provider-execution-green-tests -TimeoutMs 180000
```

---

### Task 6: Create the Editor-only `AngelscriptTestJIT` module

**Files:**
- Modify: `Plugins/Angelscript/Angelscript.uplugin`
- Create: `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJIT.Build.cs`
- Create: `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITModule.cpp`
- Create: `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.h`
- Create: `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.cpp`
- Create: `Plugins/Angelscript/Source/AngelscriptTestJIT/Generated/Provider.generated.h`
- Create: `Plugins/Angelscript/Source/AngelscriptTestJIT/Generated/Provider.generated.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITTestModuleOwnershipTests.cpp`

**Interfaces:**
- Consumes: `IAngelscriptJITArtifactProvider` and generated provider accessor.
- Produces: fixed Editor-only provider carrier with dependency chain `Runtime <- TestJIT <- Test`.

- [x] **Step 1: Add RED descriptor/build-rule ownership tests**

Read `Angelscript.uplugin` and Build.cs files in a CQTest fixture. Require `Type=Editor`, `LoadingPhase=PostDefault`, Runtime dependency from TestJIT, private TestJIT dependency from Test, no reverse dependency, no project/scaffold path strings, and no test registration source in TestJIT.

- [x] **Step 2: Run the ownership test and capture RED**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-testjit-module-red -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.TestModuleOwnership' -Label staticjit-testjit-module-red-tests -TimeoutMs 180000
```

- [x] **Step 3: Add the module shell and null/current selector**

The module implements `IModuleInterface` plus `IAngelscriptJITArtifactProvider`, registers one modular feature in `StartupModule`, unregisters only itself in `ShutdownModule`, and returns `GetCurrentGeneratedAngelscriptTestJITProviderView()`. The selector returns `nullptr` when no generated profile include exists. Test-native counters/probes are exported by `ANGELSCRIPTTESTJIT_API` and reset explicitly by tests.

- [x] **Step 4: Build and prove Editor-only dependency ownership**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-testjit-module-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.TestModuleOwnership' -Label staticjit-testjit-module-green-tests -TimeoutMs 180000
```

Also run:

```powershell
.\Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -Label staticjit-testjit-game-exclusion -TimeoutMs 3600000
```

Confirm the packaged target receipt excludes `AngelscriptTestJIT`.

---

### Task 7: Add independent TestJIT Generate/Verify and fresh Cache V2 proof

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotTestCommandlet.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotTestCommandlet.cpp`
- Move/remove: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/*`
- Generate: `Plugins/Angelscript/Source/AngelscriptTestJIT/Generated/EditorDevelopment/**/*.jit.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITAotTests.cpp`
- Modify: `Tools/RunStaticJITTests.ps1`

**Interfaces:**
- Consumes: shared Runtime generator/file store and fixed test ProviderId.
- Produces: `-run=AngelscriptTestJIT -Mode=Generate|Verify`, committed per-module fixture provider, isolated Cache V2 restore proof.

- [x] **Step 1: Add RED tests for command isolation and one-file-per-fixture-module**

Require the test command to use only committed fixture roots and `AngelscriptTestJIT/Generated`, never read the host project `Script/`, `.uproject`, project ProviderId, or project scaffold. Verify must be read-only/non-zero and report module/function identity.

- [x] **Step 2: Implement the independent commandlet orchestration**

Use a fixed, checked-in ProviderId constant and explicit Editor test artifact profile. Build `FAngelscriptJITGenerationModule` from committed fixture modules, publish to the fixed test output root, and invoke only Runtime emission/comparison primitives. Do not call `FAngelscriptJITCommand` or `FAngelscriptJITProjectGeneration`.

- [x] **Step 3: Generate fixture output and rebuild**

Run the commandlet through the documented runner so generated files are created by product code, not hand-authored:

```powershell
.\Tools\RunStaticJITTests.ps1 -Mode Generate
.\Tools\RunBuild.ps1 -Label staticjit-testjit-generated-rebuild -NoXGE
.\Tools\RunStaticJITTests.ps1 -Mode Verify
```

Expected: each non-empty fixture AS module has one `.jit.cpp`; no legacy `.jit.hpp`, `AngelscriptJitCode_*.jit.cpp`, local `.Cache`, slice, or bucket remains.

- [x] **Step 4: Replace local `.Cache` with isolated Cache V2 restoration**

Source-compile fixture engine A into `Saved/Automation/StaticJIT/<guid>/CacheV2`, destroy it, create a fresh engine B, restore through normal Cache V2 startup, and require the same logical provider entries to bind through B's own function objects/reference slots. Do not add Engine testing APIs.

Final evidence (2026-08-13): the production-shaped fixture session performs
Engine A's authoritative source discovery, `InitialCompile`, current Cache V2
publication, explicit Store flush, and destruction. A fresh Engine B selects
the same persisted Generation through normal Cache V2 startup, restores both
modules and all 46 provider functions into B's own function/reference objects,
and executes the current Native route. Ordinary behavior tests disable only
disk persistence while retaining the in-memory current artifact snapshot used
for provider matching; the dedicated persistence regression proves shutdown
writes no files in that mode.

- [x] **Step 5: Run the complete TestJIT matrix**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.AOT' -Label staticjit-testjit-aot-green -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.UASFunction' -Label staticjit-testjit-uasfunction-green -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Cache.StaticJITIsolation' -Label staticjit-testjit-cache-green -TimeoutMs 300000
```

---

### Task 8: Scaffold and validate the real host `AngelscriptJIT` project module

**Files:**
- Modify: `AngelscriptProject.uproject`
- Create: `Source/AngelscriptJIT/AngelscriptJIT.Build.cs`
- Create: `Source/AngelscriptJIT/AngelscriptJITModule.cpp`
- Create: `Source/AngelscriptJIT/Generated/Provider.generated.h`
- Create: `Source/AngelscriptJIT/Generated/Provider.generated.cpp`
- Generate: `Source/AngelscriptJIT/Generated/<Profile>/**/*.jit.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITCommandletTests.cpp`

**Interfaces:**
- Consumes: project Scaffold/Generate/Verify commandlet.
- Produces: committed real-project proof Provider independent of TestJIT.

- [x] **Step 1: Re-run isolated conflict/idempotence tests**

Cover unowned Build.cs/source conflicts, incompatible descriptor, repeated scaffold, descriptor preservation, and no TestJIT changes before touching the real project.

- [x] **Step 2: Scaffold the host project through the commandlet**

```powershell
.\Tools\RunAngelscriptJIT.ps1 -Mode Scaffold -Label staticjit-host-scaffold -TimeoutMs 300000
```

Inspect that only the fixed module shell and descriptor were created and no bucket exists.

- [x] **Step 3: Perform the first complete Editor and Game builds**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-host-first-editor-build -TimeoutMs 1800000 -NoXGE
.\Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -Label staticjit-host-first-game-build -TimeoutMs 3600000
```

This makes UBT discover the new module before generation/refresh claims are tested.

- [x] **Step 4: Generate all profiles, rebuild, Verify, and repeat Generate**

Run:

```powershell
.\Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile All -Label staticjit-host-generate-all -TimeoutMs 600000
.\Tools\RunBuild.ps1 -Label staticjit-host-generated-editor-build -TimeoutMs 1800000 -NoXGE
.\Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -Label staticjit-host-generated-game-build -TimeoutMs 3600000
.\Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Shipping -Label staticjit-host-generated-shipping-build -TimeoutMs 3600000
.\Tools\RunAngelscriptJIT.ps1 -Mode Verify -Profile All -Label staticjit-host-verify-all -TimeoutMs 600000
.\Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile All -Label staticjit-host-generate-repeat -TimeoutMs 600000
```

Record added module sources/full-build requirement, snapshot hashes/timestamps before the repeated Generate, and require zero rewritten byte-identical files.

- [x] **Step 5: Prove host and TestJIT providers coexist**

Run the multi-provider/AOT/project tests with both modules loaded. Assert distinct ProviderIds, stable sorted catalogs, independent unregister, and function ownership by StableModuleKey.

---

### Task 9: Enable Editor/PIE current-provider routing

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASFunction_JITDispatch.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITEditorRoutingTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptUASFunctionCurrentBindingReloadTests.cpp`

**Interfaces:**
- Consumes: provider registry, exact matcher, safe binding publication, authoritative compile generation.
- Produces: Editor/PIE provider discovery and per-function Native/VM routing after successful source compile.

- [x] **Step 1: Add RED edit-classification and publication-order tests**

Cover body-only, whitespace/debug-only, signature/metadata, class layout, inheritance, import, delete, compile failure, ClassGenerator timing, and PIE engine isolation. Require current VM immediately after a changed execution hash and Native only after an exact provider generation is available.

- [x] **Step 2: Run Editor/PIE/UASFunction tests and capture RED**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.EditorRouting' -Label staticjit-editor-routing-red -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.UASFunctionCurrentBindingReload' -Label staticjit-editor-uas-red -TimeoutMs 180000
```

- [x] **Step 3: Enable the new registry path after authoritative compile**

Remove only the blanket Editor exclusion guarding the new provider route. On successful compile/restore, publish current functions first, match copied provider catalogs, resolve engine-local slots, atomically publish bindings, then allow ClassGenerator consumers. Failed compiles publish no new compile generation. Structural changes remain owned by hot reload/reinstancing.

- [x] **Step 4: Run focused Editor, PIE, HotReload, Cache, and UASFunction prefixes**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-editor-routing-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.EditorRouting' -Label staticjit-editor-routing-green-tests -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.HotReload' -Label staticjit-editor-hotreload-green -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Cache' -Label staticjit-editor-cache-green -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.UASFunction' -Label staticjit-editor-uas-green -TimeoutMs 300000
```

---

### Task 10: Add explicit Live Coding Generate/Refresh

**Files:**
- Create: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITRefreshService.h`
- Create: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITRefreshService.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptEditor/Tests/AngelscriptEditorModuleMenuTests.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITRefreshServiceTests.cpp`

**Interfaces:**
- Consumes: project Generate result, source-set delta, `ILiveCodingModule`, expected ProviderId/generation/digest, engine safe-point publication.
- Produces: explicit state machine with fake backend and real Editor action.

- [x] **Step 1: Define a testable backend and RED state matrix**

Use:

```cpp
class IAngelscriptJITPatchBackend
{
public:
    virtual ~IAngelscriptJITPatchBackend() = default;
    virtual bool IsAvailable(FString& OutReason) const = 0;
    virtual bool RequestCompile(TFunction<void(bool, FString)> Completion) = 0;
};
```

Test idle, AS errors, missing scaffold/full build, added/removed module source, unavailable backend, compile active/failure/cancel, patch failure, stale/wrong provider, valid newer generation, refresh failure, and repeated request.

- [x] **Step 2: Implement Generate-first/source-set gate**

The service compiles authoritative AS source, writes EditorDevelopment output, and stops with `RequiresFullBuild` when added/removed module source arrays are non-empty or the module is not active. It never calls Live Coding in those states and does not alter current routes.

- [x] **Step 3: Implement patch completion validation**

For an unchanged source set, adapt `ILiveCodingModule` behind the interface, request compile once, wait for patch completion, re-enumerate the expected ProviderId, require the exact expected newer ProviderGeneration/artifact digest/profile/ABI, then publish routes at a safe point. All failures retain current VM/previous exact routes and return typed diagnostics.

- [x] **Step 4: Add the explicit Editor action and prove save-time silence**

Register `Generate/Refresh AngelScript JIT` in the existing Angelscript Editor action surface. File-watcher/hot-reload save handling may invalidate/recompile AS only; add a test proving it never invokes the patch backend automatically.

- [x] **Step 5: Run fake matrix and real opt-in smoke (complete)**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-livecoding-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.RefreshService' -Label staticjit-livecoding-fake-green -TimeoutMs 300000
```

Then run the documented real Editor smoke: change one existing-module function, observe VM before patch, invoke the action, observe expected new ProviderGeneration and Native execution after patch without restarting Editor. Record exact log evidence in `verification.md`.

---

### Task 11: Prove Development/Shipping and remove the legacy global path

**Files:**
- Modify/remove legacy sections in `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h`
- Modify/remove legacy sections in `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.cpp`
- Modify/remove legacy sections in `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h`
- Modify/remove legacy sections in `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITConfig.h`
- Remove obsolete generated/cache files under `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITPackagedProviderTests.cpp`

**Interfaces:**
- Consumes: complete new provider parity evidence.
- Produces: packaged exact-match/VM fallback behavior with no `FJITDatabase`, `ActiveInfo`, persisted FunctionId, or DataGuid activation.

- [x] **Step 1: Add packaged/multi-start RED tests before deletion**

Cover Development and Shipping provider load/unload, several AS modules, complete-set direct-call eligibility, stale/partial set rejection, ProviderId ambiguity, missing provider VM fallback, two process starts with reordered FunctionIds, and no Editor/LiveCoding/TestJIT dependency in target receipts.

- [x] **Step 2: Run packaged proof and retain logs**

Build Development Game and Shipping using `Documents/Guides/Build.md`; execute the package/multi-start harness twice and compare stable selection records. Do not remove legacy code until the new path passes.

- [x] **Step 3: Delete the superseded global implementation**

Remove `FJITDatabase`, `FStaticJITCompiledInfo::ActiveInfo`, numeric FunctionId generated registration, whole-cache `DataGuid` JIT pairing/clear, old static-constructor accumulators, legacy flags/commands, and compatibility tests/docs. Do not add readers or branches for old generated output.

- [x] **Step 4: Rebuild and run source/cache/editor/cooked parity**

```powershell
.\Tools\RunBuild.ps1 -Label staticjit-legacy-cutover-green -NoXGE
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT' -Label staticjit-legacy-cutover-staticjit -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Cache' -Label staticjit-legacy-cutover-cache -TimeoutMs 600000
```

Confirm `rg -n "FJITDatabase|ActiveInfo|DataGuid.*JIT|FStaticJITFunction\(FunctionId" Plugins/Angelscript/Source` returns no live legacy path.

---

### Task 12: Complete diagnostics, inspector, benchmarks, and documentation

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITDiagnostics.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITDiagnostics.cpp`
- Test: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITDiagnosticsTests.cpp`
- Create: `Tools/Diagnostics/InspectStaticJITDump.py`
- Create: `Tools/Diagnostics/Fixtures/StaticJIT/valid.json`
- Create: `Tools/Diagnostics/Fixtures/StaticJIT/mismatch.json`
- Create: `Tools/Diagnostics/Fixtures/StaticJIT/malformed.json`
- Create: `openspec/changes/refactor-as-static-jit-multi-provider/benchmarks/provider-routing.csv`
- Create: `openspec/changes/refactor-as-static-jit-multi-provider/benchmarks/module-rebuild.csv`
- Modify first: `Documents/Knowledges/ZH/RT_StaticJIT.md`
- Modify first: `AGENTS_ZH.md`
- Modify: `Plugins/Angelscript/README.md`
- Modify: `Documents/Guides/Build.md`
- Modify: `Documents/Guides/Test.md`
- Modify: `Documents/Guides/AngelscriptForkStrategy.md`
- Modify: `AGENTS.md`

**Interfaces:**
- Consumes: final provider/route/module-source model.
- Produces: human and deterministic JSON diagnostics, offline inspector, raw performance evidence, synchronized documentation.

- [x] **Step 1: Add RED diagnostics schema tests**

Require provider/module/function records sorted by stable identity and fields for ProviderId/generation, ABI/profile/environment, StableModuleKey, canonical name, module-source path/content hash/function count, full function identity, VM/Raw/Parms state, reference slots, route/miss/conflict, and counters. Require no process address or FunctionId as a record key and safe no-engine/no-provider/no-cache output.

- [x] **Step 2: Implement `as.StaticJIT.DumpDiagnostics` and JSON output**

Keep Runtime diagnostics read-only, compile human output/paths/counters out of Shipping, and avoid `FAngelscriptEngine::*ForTesting`. The JSON schema revision must be explicit and deterministic across process starts.

- [x] **Step 3: Implement and test the standalone Python inspector**

The script accepts one dump path, validates schema/required fields/hash lengths, prints provider/module/function summaries, returns 0 for valid fixtures and non-zero for malformed fixtures. Test valid, mismatch, and malformed checked-in JSON without loading Unreal.

- [x] **Step 4: Benchmark the required paths**

Record raw CSV for provider catalog load, reference resolution, route lookup/refresh, Editor VM fallback, Cache V2 restore+bind, generated file counts, unchanged-module preservation, representative/largest module `.jit.cpp` rebuild, and immutable cooked direct calls. Record hardware/build/profile/iterations and do not replace raw samples with prose.

- [x] **Step 5: Update Chinese documentation first, then English**

Document the lifecycle, registration/Engine consumption, strict per-module files, Generate/Verify, full-build versus Live Coding boundary, TestJIT/project isolation, Cache V2 relationship, diagnostics, packaging, and removal of legacy FunctionId/DataGuid activation. Then synchronize English README/guides/AGENTS.

---

### Task 13: Requirement-by-requirement completion audit

**Files:**
- Modify: `openspec/changes/refactor-as-static-jit-multi-provider/tasks.md`
- Modify: `openspec/changes/refactor-as-static-jit-multi-provider/verification.md`
- Inspect: every delta spec under `openspec/changes/refactor-as-static-jit-multi-provider/specs/`

**Interfaces:**
- Consumes: all implementation and evidence above.
- Produces: proven completion of every open checklist/spec item and a clean final workspace diff.

- [x] **Step 1: Run source/layout audits**

```powershell
rg -n "JITBucket_|FunctionSlice|SliceRelativePath|BucketIndex|BucketCount|GeneratedBucketCount" Plugins/Angelscript/Source Source/AngelscriptJIT
rg -n "FJITDatabase|ActiveInfo|FStaticJITFunction\(FunctionId" Plugins/Angelscript/Source
```

Expected: no live current-layout/legacy implementation references; historical migration tests/comments must be explicitly labeled.

- [x] **Step 2: Run all focused workflows**

Run native SDK lifecycle, Provider ABI/registry/matcher, generated output, TestJIT Generate/rebuild/Verify, project Scaffold/Generate/rebuild/Verify, StaticJIT, HotReload, UASFunction, Cache V2, Editor/PIE, real Live Coding smoke, Development/Shipping package, and multi-start proof. Record report directories and exact counts in `verification.md`.

- [x] **Step 3: Run final impact-focused validation**

```powershell
openspec validate "refactor-as-static-jit-multi-provider" --strict
git -C Plugins/Angelscript diff --check
git diff --check
```

Expected: every focused workflow in Step 2 succeeds, strict validation and
targeted diff checks return zero, and informational LF/CRLF warnings are
recorded separately from actual diff-check errors. A configured `All` run is
optional diagnostic coverage; if attempted, record its completed prefixes and
any unrelated/brittle failure without allowing it to replace the focused
matrix or expand this change into unrelated subsystems.

- [x] **Step 4: Audit every OpenSpec requirement and task against evidence**

For each scenario/task, link an authoritative source path plus build/test/runtime report. Leave an item unchecked when evidence is indirect, missing, or narrower than the requirement. Resolve every such gap before marking the change complete.

- [x] **Step 5: Finalize the record**

Only after all evidence is current, mark every completed checkbox, remove the superseded-plan notice/history ambiguity, rerun strict validation, and perform the goal completion call. Do not archive or commit unless the user explicitly requests it.

---

### Task 14: Readable source-relative generated layout refinement

**Files:**
- Modify: Runtime generation records/emission and generated-file store.
- Modify: Editor project generation/scaffold, TestJIT orchestration, diagnostics/package smoke tooling.
- Modify: StaticJIT generation/project/commandlet/TestJIT tests.
- Regenerate: project `Source/AngelscriptJIT` and plugin `AngelscriptTestJIT` owned outputs.
- Record: current spec/design/tasks/docs plus `attachments/readable-generated-layout-and-metadata.md`.

**Interfaces:**
- Consumes: full StableModuleKey/StableFunctionKey identities, virtual source paths, target profiles, revision-2 inventories.
- Produces: schema-3 manifests and source-relative readable paths/comments without changing Provider ABI 2, ownership revision 2, or internal full-hash symbols.

- [x] **Step 1: Add RED layout, filename-collision, metadata, selector, manifest, migration, and readable Verify-report tests.**
- [x] **Step 2: Emit direct `<Profile>/<source directories>/<stem>.<short-key>.<Profile>.jit.cpp` paths with deterministic global case-insensitive basename collision extension.**
- [x] **Step 3: Carry real virtual source/declaration/line/column data and map compiler-synthesized class functions to the preprocessor class declaration line.**
- [x] **Step 4: Implement schema-3 readable metadata plus Generate-only revision-2 legacy-root inspection/retirement and full-build reporting.**
- [x] **Step 5: Regenerate and compile TestJIT and all project profiles, then run focused Verify/tests/tooling and preserve the user's staged baseline.**

---

### Task 15: Remove `Private` and TestJIT `Public` wrappers

**Goal:** Make both generated-code carriers use one flat UE-module-root convention while safely migrating owned project output and keeping the TestJIT probe dependency private.

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProjectScaffoldTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITProjectGenerationTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITCommandletTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptJITTestModuleOwnershipTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectScaffold.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITProjectGeneration.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
- Move: `Plugins/Angelscript/Source/AngelscriptTestJIT/Private/AngelscriptTestJITModule.cpp` to `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITModule.cpp`
- Move: `Plugins/Angelscript/Source/AngelscriptTestJIT/Private/AngelscriptTestJITProbes.cpp` to `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.cpp`
- Move: `Plugins/Angelscript/Source/AngelscriptTestJIT/Public/AngelscriptTestJITProbes.h` to `Plugins/Angelscript/Source/AngelscriptTestJIT/AngelscriptTestJITProbes.h`
- Regenerate: `Plugins/Angelscript/Source/AngelscriptTestJIT/Generated/EditorDevelopment/**`
- Regenerate: `Source/AngelscriptJIT/Generated/{EditorDevelopment,GameDevelopment,GameShipping}/**`
- Modify: `Tools/RunAngelscriptJITPackageSmoke.ps1`
- Modify: `Documents/Knowledges/ZH/RT_StaticJIT.md`
- Modify: `Documents/Guides/Build.md`
- Modify: `Documents/Guides/Test.md`
- Modify: `Plugins/Angelscript/README.md`
- Record: current OpenSpec design/spec/tasks/attachment/verification files.

**Interfaces:**
- Current project scaffold paths: `AngelscriptJIT.Build.cs`, `AngelscriptJITModule.cpp`, `Generated/Provider.generated.h`, `Generated/Provider.generated.cpp`.
- Current generated roots: `Source/AngelscriptJIT/Generated/<Profile>` and `Plugins/Angelscript/Source/AngelscriptTestJIT/Generated/EditorDevelopment`.
- Legacy generated roots: `Private/Generated/<Profile>` and `Private/Generated/Profiles/<Profile>` beneath the respective carrier module.
- TestJIT probe header: module-root `AngelscriptTestJITProbes.h`, consumed by `AngelscriptTest` using `PrivateIncludePaths.Add(Path.GetFullPath(Path.Combine(ModuleDirectory, "..", "AngelscriptTestJIT")))`; exported functions retain `ANGELSCRIPTTESTJIT_API`.

- [ ] **Step 1: Add RED project scaffold and migration tests.**

Change current-path assertions to require root `AngelscriptJITModule.cpp` and `Generated/Provider.generated.*`. Add one fixture that first materializes the exact revision-2 `Private` scaffold, then proves the new Scaffold moves owned files and leaves no empty `Private`; add another that modifies one old scaffold file and proves Scaffold fails before writing or deleting anything.

- [ ] **Step 2: Run the focused project RED tests.**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectScaffold' -Label staticjit-no-private-scaffold-red -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectGeneration' -Label staticjit-no-private-generation-red -TimeoutMs 180000
```

Expected: fail on current `Private` paths and missing direct-root migration behavior; the host and test process still exit normally.

- [ ] **Step 3: Implement the project carrier root layout and safe migration.**

Make `BuildScaffoldFiles()` emit exactly:

```text
AngelscriptJIT.Build.cs
AngelscriptJITModule.cpp
Generated/Provider.generated.h
Generated/Provider.generated.cpp
```

Before staging new files, preflight the corresponding old `Private` files. Retire only byte-exact revision-2 scaffold content after all new writes publish; otherwise fail and preserve all old/new inputs. Generalize project generation legacy-root enumeration to inspect, report, and retire both `Private/Generated/<Profile>` and `Private/Generated/Profiles/<Profile>`. Remove only empty `Profiles`, `Generated`, and `Private` directories with non-recursive deletion.

- [ ] **Step 4: Re-run focused project tests to GREEN.**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectScaffold' -Label staticjit-no-private-scaffold-green -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectGeneration' -Label staticjit-no-private-generation-green -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.Commandlet' -Label staticjit-no-private-commandlet-green -TimeoutMs 180000
```

Expected: every selected test passes; migration tests confirm read-only Verify, ownership-guarded Generate/Scaffold, and empty-wrapper cleanup.

- [ ] **Step 5: Add and run the TestJIT RED ownership test.**

Require root-level `AngelscriptTestJITModule.cpp`, `AngelscriptTestJITProbes.cpp`, and `AngelscriptTestJITProbes.h`, root-level `Generated/EditorDevelopment`, no current `Private` or `Public` directory, a private TestJIT module dependency, a private sibling-root include path in `AngelscriptTest.Build.cs`, and the unchanged `ANGELSCRIPTTESTJIT_API` declarations.

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.TestModuleOwnership' -Label staticjit-testjit-flat-root-red -TimeoutMs 180000
```

Expected: fail because the checked-in TestJIT carrier still uses `Private` and `Public`.

- [ ] **Step 6: Move TestJIT sources and switch its generator root.**

Move the three hand-maintained TestJIT files to the module root without changing their APIs. Add only the sibling TestJIT module root to `AngelscriptTest` private include paths. Change the TestJIT generation current root to `AngelscriptTestJIT/Generated/EditorDevelopment`; enumerate both former `Private/Generated/EditorDevelopment` and older `Private/Generated/Profiles/EditorDevelopment` as ownership-validated legacy roots.

- [ ] **Step 7: Re-run TestJIT ownership and generation tests to GREEN.**

```powershell
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.TestModuleOwnership' -Label staticjit-testjit-flat-root-green -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.AOT' -Label staticjit-testjit-generation-flat-root-green -TimeoutMs 300000
```

Expected: all selected tests pass and only root-level `Generated` is current.

- [ ] **Step 8: Update tooling and documentation.**

Replace current-path references with `Source/AngelscriptJIT/Generated` and `AngelscriptTestJIT/Generated`. Keep explicit old paths only in migration tests/history and label them `legacy`. Document that root-level TestJIT probe declarations retain DLL exports but are consumed through a private include path.

- [ ] **Step 9: Regenerate both real carriers.**

```powershell
.\Tools\RunStaticJITTests.ps1 -Mode Generate -LabelPrefix staticjit-testjit-flat-root
.\Tools\RunAngelscriptJIT.ps1 -Mode Scaffold -Label staticjit-flat-root-scaffold
.\Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile All -Label staticjit-flat-root-generate-all
```

Expected: generated sources exist only under both root-level `Generated` directories; empty owned `Private` and `Public` wrappers are absent; any unrelated user file would instead preserve its wrapper and produce a migration error.

- [ ] **Step 10: Perform the required normal build and focused final verification.**

```powershell
.\Tools\RunBuild.ps1 -Target AngelscriptProjectEditor -Configuration Development -Label staticjit-flat-root-editor-build
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectScaffold' -Label staticjit-flat-root-final-scaffold -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.ProjectGeneration' -Label staticjit-flat-root-final-generation -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.Commandlet' -Label staticjit-flat-root-final-commandlet -TimeoutMs 180000
.\Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.TestModuleOwnership' -Label staticjit-flat-root-final-testjit -TimeoutMs 180000
openspec validate "refactor-as-static-jit-multi-provider" --strict
git -C Plugins/Angelscript diff --check
git diff --check
```

Expected: build and focused tests pass, OpenSpec is valid, and both diff checks are clean. Do not run the unrelated configured `All` suite.

- [ ] **Step 11: Record evidence and mark Task 13 complete.**

Append exact report directories, counts, generation results, build result, and any preserved legacy user-file behavior to `verification.md` and the readable-layout attachment; then mark OpenSpec tasks 13.1 through 13.4 complete only when their evidence exists. Do not commit or alter the user's staged baseline.
