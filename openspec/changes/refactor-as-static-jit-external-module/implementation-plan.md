# External StaticJIT Provider and Editor Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended when explicitly authorized) or `superpowers:executing-plans` to implement this plan task-by-task. Use `angelscript-test-guide` before adding or changing C++ automation tests. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace global FunctionId/DataGuid StaticJIT registration with an external `<ProjectName>AngelscriptStaticJIT` provider module that supplies per-function Native entries to Game, Editor, and PIE through engine-owned routes and explicit Live Coding refresh.

**Architecture:** Runtime exposes a versioned typed provider view through `IModularFeatures`, copies validated provider generations, and builds immutable route snapshots per `FAngelscriptEngine`. StaticJIT emits content-addressed per-function slices into 32 pre-scaffolded buckets. Editor hot reload always produces correct AS/VM state first; explicit Generate/Refresh optionally compiles the provider with Live Coding and publishes a newer validated route generation.

**Tech Stack:** Unreal Engine 5.8 C++, maintained AngelScript StaticJIT, `IModularFeatures`, `ILiveCodingModule`, UE module descriptors/UBT, CQTest/UE Automation, PowerShell project runners, OpenSpec.

## Global Constraints

- Task 1 consumes the final `as-script-artifact-identity` interfaces/golden vectors from `refactor-as-incremental-function-cache` task group 1. Do not reimplement or fork those identity rules, and do not depend on Cache V2 storage/generation APIs.
- Work in the current main checkout; do not create a worktree unless explicitly requested.
- `Plugins/Angelscript` is a submodule. Commit plugin Runtime/Editor/tests first; then commit the parent gitlink, generated host module, `.uproject`, OpenSpec, Tools, and Documents.
- Runtime must never depend on a generated project/game module. The generated module depends on `AngelscriptRuntime` and registers through the Runtime-owned provider interface.
- Provider persistence/equality uses full 256-bit stable function/content/profile/environment/ABI hashes; FunctionId and `FGuid` are non-authoritative diagnostics.
- Editor save/hot reload must not automatically invoke UBT or Live Coding. Native update is explicit Generate/Refresh.
- Live Coding is optional. Every unsupported/failure path retains correct VM execution.
- Structured compilation events remain read-only; attach routes at engine compile safe points.
- New tests start with `Angelscript`; use existing `StaticJIT`, `HotReload`, and `Generator/ASFunction` owners rather than inventing a second harness.
- Build/test only through maintained Tools entry points. Do not hand-run UBT/Build.bat.
- Update Chinese documentation before English documentation.

---

## File Map

### Plugin Runtime — create

- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITArtifactProvider.h/.cpp` — public provider entry/view/interface plus validated copied provider catalog.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITRouteManager.h/.cpp` — engine-owned current-function map integration, typed match results, immutable snapshots, route handles, safe publication.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITRouteCall.h/.cpp` — hot-reloadable Native-to-current-callee invocation and VM fallback through the existing execution context.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGeneratedArtifact.h/.cpp` — per-function slice/bucket/provider manifest model shared by Runtime generation and Editor tooling.

### Plugin Runtime — modify/remove

- `StaticJIT/AngelscriptStaticJIT.h/.cpp` — generate per-function artifacts/content-addressed symbols/provider entries; remove FunctionId registration ownership.
- `StaticJIT/AngelscriptBytecodes.h/.cpp` — route script-to-script calls in hot-reloadable profiles; retain direct calls only for immutable fully matched sets.
- `StaticJIT/StaticJITHeader.h/.cpp` — replace `FStaticJITFunction(uint32 FunctionId, ...)` and single compiled info with provider-facing generated entry helpers, then remove obsolete global registration types.
- `StaticJIT/StaticJITConfig.h` — replace blanket Editor skip with profile-based provider route enablement.
- `StaticJIT/StaticJITDiagnostics.h/.cpp` — stable provider/route diagnostics.
- `Core/AngelscriptEngine.h/.cpp` — own route manager, refresh at module/compile lifecycle, remove global clearing/DataGuid decisions.
- `ClassGenerator/ASFunction.h/.cpp`, `ASFunction_CallHelpers.h`, `ASFunction_Dispatch.cpp`, `ASFunction_JITDispatch.cpp`, and `AngelscriptClassGenerator_SoftReload.cpp` — route-aware hot-reloadable UASFunction dispatch.

### Plugin Editor — create/modify

- `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptStaticJITModuleGenerator.h/.cpp` — module name/scaffold ownership, deterministic slices/buckets/manifest, Generate/Verify.
- `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptStaticJITCommandlet.h/.cpp` — `Scaffold`, `Generate`, and `Verify` modes.
- `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptStaticJITEditorService.h/.cpp` — Generate/Refresh command, Live Coding state machine, patch-complete/provider refresh.
- `Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs` and module startup — add Editor-only LiveCoding dependency and register commands/action.

### Plugin tests — create/modify

- `AngelscriptTest/StaticJIT/AngelscriptStaticJITProviderTests.cpp` — ABI/version/full-hash/provider lifecycle/multi-engine.
- `AngelscriptTest/StaticJIT/AngelscriptStaticJITRouteTests.cpp` — exact hit/miss, current-callee fallback, virtual/ABI/lifetime, safe publication.
- `AngelscriptTest/StaticJIT/AngelscriptStaticJITScaffoldingTests.cpp` — deterministic temp-project scaffold/generate/verify and conflict behavior.
- Existing AOT generation/fixtures/tests — convert generated output to provider slices/32 buckets/provider manifest.
- Existing StaticJIT diagnostics and HotReload/UASFunction tests — extend with current-route and stale-pointer assertions.
- `AngelscriptEditor/Tests/AngelscriptStaticJITEditorServiceTests.cpp` — Live Coding state-machine seam and failure/success generations.

### Generated host validation module — create/modify in parent

- `Source/AngelscriptProjectAngelscriptStaticJIT/AngelscriptProjectAngelscriptStaticJIT.Build.cs`
- `Source/AngelscriptProjectAngelscriptStaticJIT/Private/AngelscriptProjectAngelscriptStaticJITModule.cpp`
- `Source/AngelscriptProjectAngelscriptStaticJIT/Private/Generated/Bucket_000.cpp` through `Bucket_031.cpp`, aggregators, function slices, and provider manifest include.
- `AngelscriptProject.uproject` — add Runtime/PostDefault project module.

### Parent docs/evidence — modify/create

- `Documents/Guides/Build.md`, `Documents/Guides/Test.md`, plugin README, `AGENTS_ZH.md`, and `AGENTS.md`.
- `openspec/changes/refactor-as-static-jit-external-module/benchmarks/*.csv`, `verification.md`, and real Editor Live Coding evidence.

---

### Task 1: Versioned Provider ABI and Copied Catalog

**Files:**

- Create: `StaticJIT/AngelscriptStaticJITArtifactProvider.h/.cpp`
- Create: `AngelscriptTest/StaticJIT/AngelscriptStaticJITProviderTests.cpp`
- Modify: `AngelscriptRuntime.Build.cs`

**Interfaces:**

- Consumes `FAngelscriptHash256`, `FAngelscriptStableFunctionKey`, `FAngelscriptFunctionContentHash`, and `FAngelscriptArtifactProfileKey` from the Cache identity task.
- Produces `FAngelscriptStaticJITArtifactEntry`, `FAngelscriptStaticJITProviderView`, `IAngelscriptStaticJITArtifactProvider`, `FAngelscriptStaticJITProviderCatalog`, and typed validation results.

- [ ] **Step 1: Add provider ABI red tests**

```cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptStaticJITProviderTests,
	"Angelscript.TestModule.StaticJIT.Provider",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(CopiesCompatibleProviderView);
	TEST_METHOD(RejectsTruncatedUnknownOrOversizedCounts);
	TEST_METHOD(UsesFullHashesNotDisplayGuid);
	TEST_METHOD(RejectsProfileEnvironmentAndEntryAbiMismatch);
	TEST_METHOD(OrdersProvidersAndEntriesDeterministically);
	TEST_METHOD(ProviderDepartureRemovesOnlyItsEntries);
};
```

- [ ] **Step 2: Run the red build**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-provider-red -TimeoutMs 1800000
```

Expected: build fails only because the provider interfaces are absent, or the initial stub tests fail validation assertions.

- [ ] **Step 3: Implement the public ABI exactly**

```cpp
inline constexpr uint32 GAngelscriptStaticJITProviderAbiVersion = 1;

struct ANGELSCRIPTRUNTIME_API FAngelscriptStaticJITArtifactEntry
{
	FAngelscriptStableFunctionKey FunctionKey;
	FAngelscriptFunctionContentHash Content;
	FAngelscriptHash256 EntryAbiHash;
	asJITFunction VMEntry = nullptr;
	asJITFunction_Raw RawEntry = nullptr;
	asJITFunction_ParmsEntry ParmsEntry = nullptr;
	const TCHAR* DiagnosticDeclaration = nullptr;
};

struct ANGELSCRIPTRUNTIME_API FAngelscriptStaticJITProviderView
{
	uint32 StructSize = sizeof(FAngelscriptStaticJITProviderView);
	uint32 AbiVersion = GAngelscriptStaticJITProviderAbiVersion;
	const TCHAR* ProviderName = nullptr;
	FAngelscriptHash256 ProviderGeneration;
	FAngelscriptArtifactProfileKey Profile;
	FAngelscriptHash256 NativeEnvironmentFingerprint;
	const FAngelscriptStaticJITArtifactEntry* Entries = nullptr;
	uint32 EntryCount = 0;
	uint32 BucketCount = 0;
};

class ANGELSCRIPTRUNTIME_API IAngelscriptStaticJITArtifactProvider : public IModularFeature
{
public:
	static FName GetModularFeatureName();
	virtual bool GetProviderView(FAngelscriptStaticJITProviderView& OutView) const = 0;
};
```

Validate size/version/count/pointers before copying entries. Store copied strings and arrays in Runtime-owned immutable records.

- [ ] **Step 4: Implement provider catalog lifecycle**

Subscribe to modular-feature registration/unregistration, sort copied providers by name/generation/full manifest identity, and expose immutable validated/rejected snapshots. Do not store current AS functions or FunctionIds in the catalog.

- [ ] **Step 5: Run provider tests**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-provider-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Provider" -Label staticjit-provider-green -TimeoutMs 600000
```

Expected: build exit 0 and all provider ABI/lifecycle tests pass.

### Task 2: Engine-Owned Immutable Route Snapshots

**Files:**

- Create: `StaticJIT/AngelscriptStaticJITRouteManager.h/.cpp`
- Create: `StaticJIT/AngelscriptStaticJITRouteCall.h/.cpp`
- Create: `AngelscriptTest/StaticJIT/AngelscriptStaticJITRouteTests.cpp`
- Modify: `Core/AngelscriptEngine.h/.cpp`

**Interfaces:**

- Produces `EAngelscriptStaticJITRouteMissReason`, `FAngelscriptStaticJITRouteEntry`, immutable `FAngelscriptStaticJITRouteSnapshot`, `FAngelscriptStaticJITRouteHandle`, and engine-owned `FAngelscriptStaticJITRouteManager`.
- Consumes copied catalog state and the engine's stable current-function identity map.

- [ ] **Step 1: Add exact-hit/miss/multi-engine/safe-publication red tests**

Cover every miss enum, duplicate generations, provider departure, two engines reusing FunctionId, recompile of one engine, in-flight snapshot retention, and failed-refresh previous-snapshot preservation.

- [ ] **Step 2: Implement route values and full match**

```cpp
enum class EAngelscriptStaticJITRouteMissReason : uint8
{
	None,
	MissingFunctionKey,
	ContentMismatch,
	ProfileMismatch,
	EnvironmentMismatch,
	EntryAbiMismatch,
	ProviderAbiMismatch,
	StaleGeneration,
	DuplicateOrCollision
};

struct FAngelscriptStaticJITRouteEntry
{
	FAngelscriptFunctionArtifactIdentity CurrentIdentity;
	FAngelscriptStaticJITArtifactEntry Native;
	EAngelscriptStaticJITRouteMissReason MissReason = EAngelscriptStaticJITRouteMissReason::MissingFunctionKey;
	bool IsNative() const { return MissReason == EAngelscriptStaticJITRouteMissReason::None; }
};
```

Match all full hashes/ABI and build results sorted by full stable key.

- [ ] **Step 3: Make the manager engine-owned**

Add `TUniquePtr<FAngelscriptStaticJITRouteManager>` to `FAngelscriptEngine`. It rebuilds current identities after successful compile, prepares candidate snapshots without mutating functions, and publishes under the compilation safe point. Use shared immutable ownership so active calls retain old snapshots.

- [ ] **Step 4: Run route tests**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-route-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Route" -Label staticjit-route-green -TimeoutMs 900000
```

Expected: all miss isolation, multi-engine, departure, and lifetime cases pass.

### Task 3: Per-Function Slices, Fixed Buckets, and Current-Callee Calls

**Files:**

- Create: `StaticJIT/AngelscriptStaticJITGeneratedArtifact.h/.cpp`
- Modify: `StaticJIT/AngelscriptStaticJIT.h/.cpp`
- Modify: `StaticJIT/AngelscriptBytecodes.h/.cpp`
- Extend: `AngelscriptStaticJITGeneratedOutputTests.cpp` and `AngelscriptStaticJITRouteTests.cpp`

**Interfaces:**

- Produces deterministic `FAngelscriptStaticJITFunctionArtifact`, `FAngelscriptStaticJITBucketArtifact`, and `FAngelscriptStaticJITProviderManifestArtifact`.
- Produces content-addressed implementation symbols and hot-reloadable route calls.

- [ ] **Step 1: Add golden generation tests**

Assert exact full-hash symbol shape, slice filename, 32-bucket assignment, aggregator/provider sorting, byte stability, unchanged-file preservation, deletion behavior, and generation failure on duplicate content symbols.

- [ ] **Step 2: Refactor generation around one function artifact**

```cpp
struct FAngelscriptStaticJITFunctionArtifact
{
	FAngelscriptFunctionArtifactIdentity Identity;
	FAngelscriptHash256 EntryAbiHash;
	FString ImplementationBaseSymbol;
	FString RelativeSlicePath;
	uint32 BucketIndex = 0;
	FString Source;
};

uint32 GetStaticJITBucketIndex(const FAngelscriptStableFunctionKey& Key, uint32 BucketCount);
FString MakeStaticJITImplementationSymbol(const FAngelscriptFunctionArtifactIdentity& Identity, FStringView EntryKind);
```

Use the complete key/content hex in symbols and paths. Replace generated `FStaticJITFunction(uint32, ...)` registration with provider-entry rows.

- [ ] **Step 3: Add current-callee parity fixtures**

Create Native caller A and callee B fixtures for body change, arguments, references, primitive/object returns, exceptions, globals, virtual override, and thread-safe execution. Prove A Native + B VM before refresh, then A Native + B Native after a new exact provider snapshot.

- [ ] **Step 4: Emit route invocation for hot-reloadable calls**

Generated hot-reloadable calls pass the callee stable key and current frame shape to `FAngelscriptStaticJITRouteCall`. Resolve virtual target first; invoke current Native entry when exact, otherwise enter the current AS function through the existing execution/stack contract. Do not synthesize an alternate calling convention.

- [ ] **Step 5: Keep immutable direct calls behind full-set validation**

Add an artifact-set digest to cooked provider manifests. Only select direct-call entries when every required entry/environment hash matches; otherwise disable the affected immutable set.

- [ ] **Step 6: Run generated-output and route parity tests**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-slices-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.GeneratedOutput+Angelscript.TestModule.StaticJIT.Route" -Label staticjit-slices-green -TimeoutMs 1200000
```

Expected: deterministic artifacts and all Native/VM current-callee parity tests pass.

### Task 4: Project Module Scaffold, Generate, and Verify

**Files:**

- Create: `AngelscriptEditor/StaticJIT/AngelscriptStaticJITModuleGenerator.h/.cpp`
- Create: `AngelscriptEditor/StaticJIT/AngelscriptStaticJITCommandlet.h/.cpp`
- Create: `AngelscriptTest/StaticJIT/AngelscriptStaticJITScaffoldingTests.cpp`
- Modify: `AngelscriptEditor.Build.cs`

**Interfaces:**

- Produces `FAngelscriptStaticJITModuleGenerator::Scaffold`, `Generate`, and `Verify` with structured results.
- Commandlet maps `-Mode=Scaffold|Generate|Verify` to the same service.

- [ ] **Step 1: Add temp-project generator tests**

Cover `AngelscriptProject -> AngelscriptProjectAngelscriptStaticJIT`, invalid-character normalization, `.uproject` Runtime/PostDefault entry, private Runtime dependency, exactly 32 buckets, idempotency, byte-different atomic writes, user-file conflict, stale slice, deleted function, and UBT target discovery metadata.

- [ ] **Step 2: Implement the owned scaffold contract**

```cpp
enum class EAngelscriptStaticJITToolMode : uint8 { Scaffold, Generate, Verify };

struct FAngelscriptStaticJITGenerationResult
{
	bool bSuccess = false;
	FString ModuleName;
	FAngelscriptHash256 ProviderGeneration;
	TArray<FString> WrittenFiles;
	TArray<FString> StaleFiles;
	TArray<FString> Conflicts;
	TArray<FString> Diagnostics;
};

struct FAngelscriptStaticJITProjectInput
{
	FString ProjectFile;
	FString ProjectRoot;
	FString ProjectName;
};

struct FAngelscriptStaticJITGenerationInput
{
	FAngelscriptStaticJITProjectInput Project;
	FAngelscriptArtifactProfileKey Profile;
	TArray<FAngelscriptStaticJITFunctionArtifact> Functions;
};

class FAngelscriptStaticJITModuleGenerator
{
public:
	FAngelscriptStaticJITGenerationResult Scaffold(const FAngelscriptStaticJITProjectInput& Project);
	FAngelscriptStaticJITGenerationResult Generate(const FAngelscriptStaticJITGenerationInput& Input);
	FAngelscriptStaticJITGenerationResult Verify(const FAngelscriptStaticJITGenerationInput& Input);
};
```

Use a versioned ownership marker in generated files. Update `.uproject` through structured JSON/descriptor serialization. Do not parse or edit Target.cs.

- [ ] **Step 3: Implement commandlet modes**

Parse only the three modes, return nonzero on invalid scaffold/stale Verify/conflict, and print exact module name, required first full build, written/stale/conflicting files, provider generation, and stable-key diagnostics.

- [ ] **Step 4: Run scaffolding tests**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-scaffold-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Scaffolding" -Label staticjit-scaffold-green -TimeoutMs 900000
```

Expected: deterministic module layout, idempotency, non-overwrite, and Verify behavior pass.

### Task 5: Host Validation Module and Provider-Based AOT Fixtures

**Files:**

- Create generated parent `Source/AngelscriptProjectAngelscriptStaticJIT/**`
- Modify: `AngelscriptProject.uproject`
- Modify: existing `AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.*`, fixture, commandlet, generated artifacts, AOT tests, and `Tools/RunStaticJITTests.ps1`

**Interfaces:**

- Host module proves reusable plugin scaffolding in a real project.
- `AngelscriptTest` AOT generated content publishes through the same provider ABI rather than the old global FunctionId/DataGuid registration.

- [ ] **Step 1: Run Scaffold for the host project**

Use the maintained commandlet runner after the generator build:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet "AngelscriptStaticJIT" -Label staticjit-host-scaffold -TimeoutMs 600000 -ExtraArgs "-Mode=Scaffold"
```

Expected: creates `AngelscriptProjectAngelscriptStaticJIT`, adds one `.uproject` module entry, and reports a required full build. Inspect every generated parent-repo file before staging.

- [ ] **Step 2: Full-build the Editor target and verify project-module discovery**

Run the canonical Editor build and verify its UBT receipt contains the generated module. The maintained Development package command in Task 8 supplies the Game-target build proof; do not hand-run UBT or try to replace the target through raw `ExtraArgs`.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-host-full-build -TimeoutMs 1800000
```

Expected: Editor build exits 0 and the generated project module binary/receipt is present.

- [ ] **Step 3: Convert AOT generation to provider artifacts**

Generate fixture slices, 32 bucket aggregators, and provider manifest; remove semantic comparison of archive-local old pointer/FunctionId tokens. Verify full identity, entry kinds, bucket and source bytes.

- [ ] **Step 4: Convert AOT runtime assertions**

Replace global database/ID assertions with provider enumeration, engine route exact-match/miss, Native execution marker, per-function fallback, and two-engine route isolation.

- [ ] **Step 5: Run the canonical StaticJIT runner**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -LabelPrefix staticjit-provider-aot -BuildTimeoutMs 1800000 -CommandletTimeoutMs 600000 -TestTimeoutMs 900000
```

Expected: baseline build, provider artifact generation, generated build, and full StaticJIT prefix exit 0.

### Task 6: Editor/PIE Attachment and Explicit Live Coding Refresh

**Files:**

- Create: `AngelscriptEditor/StaticJIT/AngelscriptStaticJITEditorService.h/.cpp`
- Create: `AngelscriptEditor/Tests/AngelscriptStaticJITEditorServiceTests.cpp`
- Modify: Editor module startup and `AngelscriptEditor.Build.cs`
- Modify: Runtime compile handoff around `GetPreGenerateClasses()`

**Interfaces:**

- Produces a state machine: `Idle`, `Generating`, `WaitingForLiveCoding`, `WaitingForPatch`, `RefreshingProvider`, `Completed`, `Failed`.
- Exposes Editor command/action `Generate/Refresh StaticJIT`; no save watcher calls it.

- [ ] **Step 1: Add Editor service state tests**

Cover AS errors, missing scaffold, concurrent request, no Live Coding, compile immediate failure, patch failure, no newer provider, incompatible provider, valid newer generation, and service shutdown during request.

- [ ] **Step 2: Enable provider attachment in Editor safely**

Remove the blanket Editor skip only around the new route path. After successful AS compilation builds current identities, use `GetPreGenerateClasses()`/engine safe point to publish exact Native/VM routes before ClassGenerator finalizes UFunctions. Keep old global database disabled.

- [ ] **Step 3: Implement explicit generation and Live Coding state machine**

```cpp
enum class EAngelscriptStaticJITEditorRefreshState : uint8
{
	Idle,
	Generating,
	WaitingForLiveCoding,
	WaitingForPatch,
	RefreshingProvider,
	Completed,
	Failed
};

void FAngelscriptStaticJITEditorService::RequestGenerateAndRefresh();
void FAngelscriptStaticJITEditorService::HandlePatchComplete();
```

Call the generator first, then `ILiveCodingModule::Compile()`, bind/unbind patch completion with service lifetime, require a strictly newer validated provider generation, and request engine safe-point refresh. Never auto-call this from the directory watcher.

- [ ] **Step 4: Add Editor command/menu registration**

Register an explicit action and non-Shipping console command that report current state/result. Disable the action while AS compilation errors or another request exist.

- [ ] **Step 5: Run automated Editor/PIE tests**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-editor-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.StaticJIT+Angelscript.TestModule.HotReload.PIESession+Angelscript.TestModule.StaticJIT.Route" -Label staticjit-editor-green -TimeoutMs 1200000
```

Expected: state-machine and simulated provider-generation tests pass; ordinary save path never requests Native compilation.

- [ ] **Step 6: Perform and record one real Live Coding verification**

Start Editor after a full scaffold build; prove function B is Native, edit B and observe B VM while unchanged A remains Native, invoke Generate/Refresh, observe successful patch/new provider generation, then prove B Native with new behavior. Record logs, hashes, route dumps, and limitation if the environment cannot support Live Coding; do not replace automated state tests with this manual evidence.

### Task 7: Route-Aware UASFunction Hot Reload

**Files:**

- Modify: `ClassGenerator/ASFunction.h/.cpp`
- Modify: `ASFunction_CallHelpers.h`, `ASFunction_Dispatch.cpp`, `ASFunction_JITDispatch.cpp`
- Modify: `AngelscriptClassGenerator_SoftReload.cpp`
- Extend: ASFunction dispatch/argument/world-context/optimized-call tests and StaticJIT AOT UASFunction tests

**Interfaces:**

- Hot-reloadable wrappers retain ScriptFunction/route handle and load the current entry per call.
- Immutable cooked wrappers may cache direct pointers only after full provider-set validation.

- [ ] **Step 1: Add stale-pointer matrix failures**

For no-param, primitive arg/return, reference writeback, object return, static/world-context, virtual override, generic, specialized, and thread-safe shapes: invoke Native old version, soft-reload new AS version with provider miss, invoke same UFunction, and assert new VM behavior plus no old marker.

- [ ] **Step 2: Remove hot-reloadable pointer ownership from UASFunction**

Do not copy `ScriptFunction->jitFunction`, `_Raw`, or `_ParmsEntry` into long-lived UASFunction fields in Editor/PIE. Store current ScriptFunction/route handle and acquire an immutable route snapshot at dispatch.

- [ ] **Step 3: Preserve virtual and generic ordering**

Resolve current override first, then route. Generic/thread-safe paths use the same snapshot lifetime rule; no wrapper may bypass VM because a parent/old pointer is non-null.

- [ ] **Step 4: Run UASFunction and HotReload matrices**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-uasfunction-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT.UASFunctionDispatch+Angelscript.TestModule.HotReload+Angelscript.TestModule.Generator.ASFunction" -Label staticjit-uasfunction-green -TimeoutMs 1500000
```

Expected: every wrapper shape executes current semantics and no stale generated marker appears after a miss.

### Task 8: Diagnostics, Cooked Runtime, and Global Registry Removal

**Files:**

- Modify: `StaticJIT/StaticJITDiagnostics.h/.cpp`
- Modify: `StaticJIT/StaticJITHeader.h/.cpp`, `AngelscriptStaticJIT.h/.cpp`, `StaticJITConfig.h`
- Modify: `Core/AngelscriptEngine.cpp`
- Extend: `AngelscriptStaticJITDiagnosticsTests.cpp`, AOT multi-engine tests, package tests

- [ ] **Step 1: Add stable diagnostics tests**

Assert provider/generation/profile/environment, engine route generation, full/display key, transient FunctionId context, entries, miss reason, bucket/slice, counters, deterministic ordering, and no-engine/no-provider output.

- [ ] **Step 2: Implement diagnostics**

Extend `as.StaticJIT.DumpDiagnostics` lookup by canonical declaration or full-key hex. Print transient FunctionId only after the stable key. Exclude human diagnostics from Shipping.

- [ ] **Step 3: Prove old/new immutable AOT parity**

Before deletion, use test-only comparison to prove VM/raw/parms entry behavior, exceptions, debug callstack, native forms, primitive conversions, and multi-engine results match the provider route.

- [ ] **Step 4: Remove old global identity/activation**

Delete `FJITDatabase`, single `FStaticJITCompiledInfo::ActiveInfo`, persisted `uint32 FunctionId` constructors/registration, whole-cache DataGuid comparison/clear, and blanket Editor skip. Remove comparison seams in the same reviewed change.

- [ ] **Step 5: Validate Development Game and packaged immutable provider**

Prove generated project module loads without Editor/LiveCoding, exact immutable set permits direct calls, stale/missing set selects safe VM/provider fallback, and package enters the test map.

### Task 9: Benchmarks, Documentation, and Final Verification

**Files:**

- Create: `openspec/changes/refactor-as-static-jit-external-module/benchmarks/*.csv`
- Create: `openspec/changes/refactor-as-static-jit-external-module/verification.md`
- Modify: Chinese then English guides/README/AGENTS files listed in File Map.

- [ ] **Step 1: Capture performance/build-scope evidence**

Record provider enumeration/route-build time, hot-reloadable route overhead versus VM/old Native, one-function bucket rebuild scope/time, unchanged-file count, Live Coding generation/patch time, and cooked immutable direct-call performance with profile/commit/machine data.

- [ ] **Step 2: Update documentation in language order**

Document module name derivation, Scaffold/Generate/Verify, first full build, Editor/PIE behavior, explicit refresh, Live Coding optionality/failures, per-function fallback, packaged behavior, diagnostics, and relationship to Cache V2.

- [ ] **Step 3: Scan for forbidden production identity/global state**

```powershell
rg -n "FJITDatabase|ActiveInfo|PrecompiledDataGuid|FStaticJITFunction\(uint32|AS_SKIP_JITTED_CODE" Plugins/Angelscript/Source/AngelscriptRuntime Plugins/Angelscript/Source/AngelscriptEditor
```

Expected: no production provider/route selection uses those removed constructs; remaining occurrences, if any, are classified compatibility macros unrelated to the old path or explicit history/tests.

- [ ] **Step 4: Run scaffold verification and affected suites**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunCommandlet.ps1 -Commandlet "AngelscriptStaticJIT" -Label staticjit-final-verify -TimeoutMs 600000 -ExtraArgs "-Mode=Verify"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label staticjit-final -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -LabelPrefix staticjit-final -BuildTimeoutMs 1800000 -CommandletTimeoutMs 600000 -TestTimeoutMs 1200000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload+Angelscript.TestModule.Generator.ASFunction+Angelscript.Editor.StaticJIT" -Label staticjit-final-affected -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunPackage.ps1 -Configuration Development -Label staticjit-final-package -TimeoutMs 3600000
```

Expected: commandlet Verify reports current; builds/tests/package exit 0 with zero failed/skipped/not-run/timeouts.

- [ ] **Step 5: Run final repository gates**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All
openspec validate "refactor-as-static-jit-external-module" --strict
git diff --check
```

Expected: All suite and both repository checks exit 0.

- [ ] **Step 6: Commit in dual-repository order**

Commit Runtime/Editor/tests/generated test provider in `Plugins/Angelscript`; then stage the parent gitlink, host generated module, `.uproject`, docs/OpenSpec/evidence and commit using the repository rule.

---

## Self-Review Checklist

- Provider ABI/full identity/mismatch/lifecycle requirements map to Task 1.
- Per-engine route, multi-engine isolation, atomic publication, and departure map to Task 2.
- Per-function slices, content symbols, current-callee fallback, and immutable direct sets map to Task 3.
- Module naming, 32 buckets, idempotency, conflict protection, Generate/Verify map to Task 4.
- Real project module and AOT provider proof map to Task 5.
- Editor/PIE authority, explicit Live Coding, optional/failure behavior, and safe refresh map to Task 6.
- Route-aware UASFunction and soft-reload safety map to Task 7.
- Stable diagnostics, cooked behavior, and old global-state removal map to Task 8.
- Performance, Chinese-first docs, scans, affected tests, package, All suite, OpenSpec, and diff gates map to Task 9.
