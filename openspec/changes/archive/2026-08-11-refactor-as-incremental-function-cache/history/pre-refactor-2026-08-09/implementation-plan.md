# Incremental AngelScript Script Cache V2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` only when the user explicitly authorizes delegated execution; otherwise use `superpowers:executing-plans`. Use `superpowers:test-driven-development` for every task marked TDD, `angelscript-test-guide` before C++ automation work, `superpowers:systematic-debugging` for unexpected failures, and `superpowers:verification-before-completion` before checking off a milestone.

**Goal:** Replace the monolithic pre-generated `PrecompiledScript.Cache` with a Runtime-owned, Saved-only Cache V2 that restores unchanged modules, reuses unchanged functions/types/state after edits, continuously serves Editor/PIE, and is generated on first Development/Shipping launch from loose authoritative `.as` source.

**Architecture:** `Core/Artifacts` owns stable entity/function/profile identity and a read-only environment symbol catalog. `Cache/` owns logical records, explicit serialization, content-addressed aggregated packs, immutable generations, invalidation planning, lifecycle, runtime reload and diagnostics. Persistent data is entity-granular, but active-engine restore/publication is module-atomic. Pure source/hash/I/O/pack work is bounded-parallel; builder/type/global/swap/ClassGenerator work remains serialized.

**Tech Stack:** Unreal Engine host currently configured for 5.8, Unreal C++, maintained AngelScript fork, `FBlake3`, `FArchive`, `FCompression`/Zlib, UE Tasks/`ParallelFor`, `FSystemWideCriticalSection`, CQTest/UE Automation, PowerShell project runners, OpenSpec.

## Global Constraints

- Work only in the user-requested isolated worktree `D:\Workspace\AngelscriptProject\.worktree\as-cache`; do not switch checkout or copy source edits from the dirty main workspace. Recheck both parent and nested `Plugins/Angelscript` worktree status before each task.
- `Plugins/Angelscript` is a nested submodule worktree and the OpenSpec/Tools/Config live in the parent worktree. Keep the two repositories' changes separate. If commits are later authorized, commit the submodule first and update the parent gitlink second; without authorization, commit neither.
- Do not commit, push, archive the OpenSpec, or alter the parent gitlink unless the user explicitly requests that action.
- Follow red-green-refactor: production behavior is not added until a focused test has failed for the expected missing behavior.
- Do not implement a legacy reader, migrator, dual-format switch, packaged baseline, or automatic conversion for `PrecompiledScript.Cache`.
- Do not modify `Binds.Cache` format/ownership; observe bound symbols through per-symbol ABI fingerprints.
- Do not change business `.as` syntax or require script-authored IDs/annotations. Maintained-fork changes are limited to the internal kind-tagged builder artifact hook, actual-dependency capture, and VM-private FunctionBody codec/restore adapter required by that hook.
- Full BLAKE3-256 values are authoritative; derived GUIDs/truncated text are display-only.
- Never invoke builder/type/layout/global/code-generation operations concurrently inside one `asCScriptEngine` beyond the existing proven parallel parse path.
- Current source is authoritative. A changed source snapshot that fails fresh-start compilation cannot run an older different-source generation.
- Editor/PIE structural semantics remain authoritative. Packaged live reload defaults Disabled and accepts code-only changes only.
- New C++ automation files start with `Angelscript` and use `Angelscript.TestModule.Cache.*`.
- Build/test only through `Tools/RunBuild.ps1`, `Tools/RunTests.ps1`, `Tools/RunTestSuite.ps1`, and the fixture-generating `Tools/RunStaticJITTests.ps1` workflow for AOT coverage. Package only through `Tools/RunPackage.ps1` or the new wrapper that calls it.
- Real PIE and Development/Shipping package multi-launch tests are the last implementation milestone, after focused unit/integration coverage is green.
- Update Chinese guidance before English guidance when implementation changes architecture/build/test behavior.

---

## File Map

### Plugin Runtime — create

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h/.cpp` — hash/key/profile value types, canonical writer, entity descriptors, input/content builders, display GUID/hex.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptEnvironmentSymbolCatalog.h/.cpp` — current bind/type/function/global/property observation, stable environment keys, ABI fingerprints, dependency lookup.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypes.h` — schema constants, record kinds, typed records, manifests, pack index, validation/planning/publication outcomes.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheArchive.h/.cpp` — explicit-field canonical serialization, bounds/checksum/compression validation, stable references.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/Private/AngelscriptCacheMemoryView.h` — checked input-view/output-allocation range construction and overlap preflight shared by envelope and semantic primitives; it is Runtime Private and adds no public alias API.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheSemanticRecords.h/.cpp` — Task 2B-1 producer DTOs/encoders and private SourceIndex/ModuleInterface candidate decoders; the transitional validated SourceIndex token/public raw decoders are removed in Task 2B-2, and the free exact-eligibility query consumes only the common immutable decoded-record token.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypeSchema.h/.cpp` — complete TypeSchema DTO/producer/private candidate decoder plus exhaustive local semantic/hash/layout replay and typed captured offsets.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheModuleState.h/.cpp` — profile-keyed ModuleState DTO/producer/private candidate decoder and initializer/global lifecycle authority.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheFunctionBody.h/.cpp` — FunctionBody DTO/producer/private candidate decoder; execution bytes remain opaque outside the VM codec seam.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheDebugSidecar.h/.cpp` — profile-keyed DebugSidecar DTO/producer/private candidate decoder and typed logical-source storage.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheModuleSnapshot.h/.cpp` — redundant keyed ModuleSnapshot DTO/private candidate decoder and immutable graph validation/output types.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheDecodedRecord.h/.cpp` — umbrella included only after all seven complete record DTO/coordinate headers; owns the final in-place seven-alternative `{DTO, captured offsets}` variant, sole immutable handle/factory, exact final intrusive-controller oracle, record dispatch and const typed/offset accessors. It has no pimpl or per-kind owner allocation and must not be introduced as a partial two-kind token.
- `openspec/changes/refactor-as-incremental-function-cache/source-interface-captured-offsets-v1.md` — append-only SourceIndex/ModuleInterface typed captured-field enums, P/S/T index semantics, nested common-value routing and exact eligibility wrong-kind result.
- `openspec/changes/refactor-as-incremental-function-cache/remaining-record-captured-offsets-v1.md` — append-only ModuleState/FunctionBody/DebugSidecar/ModuleSnapshot field enums, exact P/S/T/preorder/optional applicability and wrong-kind/zero-offset rules.
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheRemainingRecordCoordinateTests.cpp` — small declaration-first RED for the four remaining coordinate domains and exact nested DTO member API, kept separate from the TypeSchema allocation matrix.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptFunctionArtifactCodec.h/.cpp` — VM-private freeze/restore of canonical function execution DTOs, opcode operands, scriptData, stack/locals/object/cleanup/debug metadata and stable-reference relocation.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheCompileSnapshot.h/.cpp` — pointer-free immutable publication DTO and `FreezeSuccessfulCompileArtifacts()` producer contract.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptEngineMutationGate.h/.cpp` — per-engine owner token, startup/runtime ownership transition, reentrancy/ordering and lifecycle cancellation.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheStore.h/.cpp` — Saved roots, immutable read sessions, aggregated packs, Current/Previous/Pending, writer lock, atomic publication, compaction.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCachePlanner.h/.cpp` — SourceIndex comparison, typed dependency graph, exact fast path, record hit/miss closure.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheService.h/.cpp` — engine lifecycle, builder hook adapter, async preparation, module assembly, publish/flush/cancellation.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheSettings.h/.cpp` — `UAngelscriptCacheSettings` and defaults.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptRuntimeReloadTypes.h` — Blueprint/C++ reload mode, request, outcome, result and delegate types.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheDiagnostics.h/.cpp` — stable counters/snapshots, JSON report, console commands, verification and compaction entry points.

### Plugin Runtime / maintained fork — modify or retire

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h/.cpp` — engine-owned service/routing, initial fast path, compile planner, successful capture, module activation, pending/current handling, shutdown flush; retire old flags/pointers.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.h/.cpp` — public reload request/delegate, safe-point queue and lifecycle.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineSubsystem.h/.cpp` — typed startup result propagation and default nonzero unattended packaged failure.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h/.cpp` — per-builder host artifact callback immediately around function compiler invocations.
- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` — new Runtime sources/dependencies without adding Editor-only dependencies.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h/.cpp` and legacy helpers — comparison adapter first; remove script-cache ownership after V2 parity.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h/.cpp`, `AngelscriptBytecodes.cpp`, `StaticJITDiagnostics.*`, `StaticJITHeader.*` and generated registration surfaces — consume the explicit compatibility bridge; retain the legacy numeric transport until the sibling external provider has parity.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp` and `AngelscriptStateSnapshot.cpp` — replace old DataGuid/precompile fields with Cache V2 observer data.
- `Tools/Diagnostics/ParseAngelscriptCache.py`, StaticJIT AOT/archive tests, relevant config and package validators — retire or reclassify legacy cache assumptions only after V2 parity.

### Plugin tests — create/modify

- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptArtifactIdentityTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheArchiveTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheStoreTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCachePlannerTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheCompilerReuseTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheLifecycleTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheRuntimeReloadTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheStaticJITBridgeTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCachePIELifecycleTests.cpp`
- Existing `StaticJIT/AngelscriptPrecompiled*` and AOT fixtures — migrate shared identity/behavior assertions; remove legacy-only expectations after parity.

### Parent repository — create/modify

- `Config/DefaultGame.ini` — stage `../Script` as NonUFS instead of UFS.
- `Tools/RunPackage.ps1` — remove old precompile process/parameters; validate loose Script, `Binds.Cache` and legacy absence.
- `Tools/RunAngelscriptCachePackageSmoke.ps1` — package then execute the real Development/Shipping multi-launch matrix.
- `Tools/Shared/AngelscriptCachePackageSmoke.psm1` — pure archive/fixture/process/report helpers.
- `Tools/Diagnostics/TestAngelscriptCachePackageSmoke.ps1` — focused helper self-tests using temporary directories/process doubles.
- `Tools/Shared/TestSuiteDefinitions.ps1` and `TestSuiteEntryRunner.ps1` — `Cache`, `CachePackage` and typed `PackageSmoke` entries.
- `openspec/changes/refactor-as-incremental-function-cache/benchmarks/` and `verification.md` — raw metrics/schema and verified command evidence.
- Chinese then English cache/build/test/package/plugin architecture guides — only after behavior is implemented and measured.

---

### Task 1: Pure Stable Values, Canonical Writer, And Artifact Identity

**Files:**

- Create only `Core/Artifacts/AngelscriptArtifactIdentity.h/.cpp`; environment catalog capture is Task 4.
- Create `AngelscriptArtifactIdentityTests.cpp`.
- Do not modify live engine/builder/cache-lifecycle code in this task.

**Interfaces produced:**

```cpp
struct ANGELSCRIPTRUNTIME_API FAngelscriptHash256
{
	FBlake3Hash Value;
	bool IsZero() const;
	FString ToHexString() const;
	FGuid ToDisplayGuid() const;
	friend bool operator==(const FAngelscriptHash256&, const FAngelscriptHash256&);
	friend bool operator<(const FAngelscriptHash256&, const FAngelscriptHash256&);
};

struct FAngelscriptStableModuleKey { FAngelscriptHash256 Hash; };
struct FAngelscriptStableTypeKey { FAngelscriptHash256 Hash; };
struct FAngelscriptStableFunctionKey { FAngelscriptHash256 Hash; };
struct FAngelscriptStableGlobalKey { FAngelscriptHash256 Hash; };
struct FAngelscriptStablePropertyKey { FAngelscriptHash256 Hash; };
struct FAngelscriptFunctionSourceDigest { FAngelscriptHash256 Hash; };
struct FAngelscriptFunctionInputDigest { FAngelscriptHash256 Hash; };

struct FAngelscriptFunctionContentHash
{
	FAngelscriptHash256 Execution;
	FAngelscriptHash256 Debug;
};

struct FAngelscriptCacheCompatibilityKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCacheContextKey { FAngelscriptHash256 Hash; };
struct FAngelscriptArtifactProfileKey { FAngelscriptHash256 Hash; };

struct FAngelscriptFunctionArtifactIdentity
{
	FAngelscriptStableFunctionKey FunctionKey;
	FAngelscriptFunctionContentHash Content;
	FAngelscriptArtifactProfileKey Profile;
};
```

The canonical writer exposes only fixed-width little-endian integers, bool, full hash, and length-prefixed UTF-8. Every stream begins with ASCII `UEAS-ARTIFACT`, one NUL byte, a fixed-width little-endian schema version, and a length-prefixed domain string. Entity builder functions accept pure typed descriptors and never infer absolute paths/source positions. Module inputs are logical mount + normalized virtual path + module name; type/function/global/property inputs use the stable owner/module key plus namespace, explicit kind, canonical declaration/type and traits. This first vertical slice is intentionally value-only: it must run without constructing `FAngelscriptEngine`, `asCBuilder`, TypeDatabase, source discovery or disk store state.

- [ ] **Step 1: Write identity red tests**

Use one CQTest class with pure value fixtures and scenario methods; do not create an AngelScript engine:

```cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptArtifactIdentityTests,
	"Angelscript.TestModule.Cache.Identity",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(EntityKeysIgnoreProcessAndEnumerationState);
	TEST_METHOD(ProjectRelocationPreservesLogicalKeys);
	TEST_METHOD(OverloadsAndSyntheticOwnersAreDistinct);
	TEST_METHOD(BodyChangesInputAndContentButNotFunctionKey);
	TEST_METHOD(DebugAndExecutionContentAreIndependent);
	TEST_METHOD(ProfileInputsRemainSeparated);
	TEST_METHOD(FullHashRejectsDisplayGuidCollision);
	TEST_METHOD(CanonicalWriterHasByteExactGoldenVector);
};
```

- [ ] **Step 2: Run RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-identity-red -TimeoutMs 1800000
```

Expected: build fails only because the new pure identity/writer interfaces do not exist, or a deliberately compiling scaffold fails focused assertions. Resolve unrelated compile errors before proceeding.

- [ ] **Step 3: Implement canonical identity and golden vectors**

Use domain strings `module`, `type`, `function`, `global`, `property`, `function-source`, `function-input`, `function-execution`, `function-debug`, `compatibility`, `context` and `profile`. Normalize logical paths before encoding; reject case-fold collisions during SourceIndex construction rather than folding identity case. The `FunctionInputDigest` value/golden test supplies an already canonical ordered dependency-fingerprint vector; live dependency collection is deliberately absent from Task 1.

- [ ] **Step 4: Run GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-identity-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Identity" -Label as-cache-identity-green -TimeoutMs 600000
```

Expected: build exit 0; all pure identity scenarios execute and pass; canonical bytes and golden full hashes are stable in forced insertion-order variations. Environment capture and current-engine routes remain unimplemented until Task 4.

### Task 2: Cache V2 Records, Archive, And In-Memory Manifest/Pack Format

**Files:**

- Extend `AngelscriptCacheTypes.h` and `AngelscriptCacheArchive.*`; create
  `AngelscriptCacheSemanticRecords.h/.cpp` and later
  `AngelscriptCachePack.*`.
- Create `AngelscriptCacheSemanticPrimitiveTests.cpp`,
  `AngelscriptCacheSourceInterfaceTests.cpp`, and later
  `AngelscriptCachePackFormatTests.cpp`.
- Adapt `StaticJIT/PrecompiledData.*` only through a test comparison adapter; do not select V2 at startup yet.
- Treat `record-schema.md` as the normative semantic field, ordering, ABI,
  link, budget, and error contract for this task.
- Treat `record-wire-v1.md` as the sole Task 2B-1 byte authority; abbreviated
  types below must not redefine its enum values, field order, key domains,
  presence matrices, hashes, comparators, or error classification.
- Treat `record-wire-v1-remaining.md` together with the co-normative
  `type-schema-matrix-v1.md`, `type-layout-authority-v1.md`, and
  `module-state-matrix-v1.md` as the sole Task 2B-2 byte/graph authority; split
  remaining record codecs, opaque-payload validation and module-graph validation
  by responsibility rather than growing one monolithic archive implementation.
  They reuse the 2B-1 primitives unchanged.
- Treat `manifest-pack-wire-v1.md` as the sole Task 2B-3 byte/physical-identity
  authority. Abbreviated DTOs below do not serialize native layout and cannot
  add an embedded GenerationId, whole-pack codec, nested record envelope,
  alternate checksum/hash stream, or filesystem publication field.

**Interfaces produced:**

```cpp
enum class EAngelscriptCacheCodec : uint8
{
	None = 0,
	Zlib = 1,
};

enum class EAngelscriptCacheRecordKind : uint8
{
	SourceIndex = 1,
	ModuleInterface = 2,
	TypeSchema = 3,
	ModuleState = 4,
	FunctionBody = 5,
	DebugSidecar = 6,
	ModuleSnapshot = 7,
};

enum class EAngelscriptCacheReferenceKind : uint8
{
	ScriptModule = 1,
	ScriptType = 2,
	ScriptFunction = 3,
	ScriptGlobal = 4,
	ScriptProperty = 5,
	ScriptImport = 6,
	EnvironmentSymbol = 7,
	CanonicalName = 8,
	StringLiteral = 9,
};

enum class EAngelscriptCachedTypeKind : uint8
{
	Class,
	Struct,
	Interface,
	Enum,
	Delegate,
	Typedef,
	Funcdef,
};

enum class EAngelscriptCacheDeclarationKind : uint8
{
	Type = 1,
	Function = 2,
	Global = 3,
	Property = 4,
};

enum class EAngelscriptCachePreprocessorInputKind : uint8
{
	IncludeFile = 1,
	Define = 2,
	ConditionalSymbol = 3,
	GeneratedSource = 4,
};

struct FAngelscriptCacheRecordId
{
	EAngelscriptCacheRecordKind Kind;
	FAngelscriptHash256 ContentHash;
};

struct FAngelscriptCachePackLocation
{
	FAngelscriptHash256 PackId;
	uint64 PackOffset;
	uint64 StoredSize;
	uint64 RawSize;
	EAngelscriptCacheCodec Codec;
	FAngelscriptHash256 RawChecksum;
};

struct FAngelscriptCacheStableReference
{
	EAngelscriptCacheReferenceKind Kind;
	FAngelscriptHash256 StableKey;
	FAngelscriptHash256 ExpectedAbi;
};

enum class EAngelscriptCacheSemanticDependencyKind : uint8
{
	Import = 1,
	Declaration = 2,
	Signature = 3,
	Inheritance = 4,
	ValueLayout = 5,
	PropertyLayout = 6,
	GlobalStorage = 7,
	HardValue = 8,
	Initializer = 9,
	CompileOption = 10,
	EnvironmentAbi = 11,
};

struct FAngelscriptCacheSemanticDependency
{
	EAngelscriptCacheSemanticDependencyKind Kind;
	FAngelscriptCacheStableReference Target;
	TOptional<FAngelscriptHash256> ExpectedContentOrValue;
};

enum class EAngelscriptCachedDataTypeKind : uint8
{
	Primitive = 1,
	ScriptType = 2,
	EnvironmentType = 3,
	Auto = 4,
};

struct FAngelscriptCachedDataType
{
	EAngelscriptCachedDataTypeKind Kind;
	EAngelscriptCachedPrimitiveType Primitive;
	TOptional<FAngelscriptCacheStableReference> Type;
	EAngelscriptCachedTypeQualifier Qualifiers;
	TArray<FAngelscriptCachedDataType> OrderedSubTypes;
};

struct FAngelscriptCacheDeclarationRecord
{
	EAngelscriptCacheDeclarationKind Kind;
	EAngelscriptArtifactEntityKind EntityKind;
	EAngelscriptCacheSchemaCoverage SchemaCoverage;
	EAngelscriptCacheBodyCoverage BodyCoverage;
	FAngelscriptHash256 StableKey;
	EAngelscriptFunctionOwnerKind OwnerKind;
	FAngelscriptHash256 OwnerKey;
	FAngelscriptStableModuleKey ModuleKey;
	FString CanonicalNamespace;
	FString CanonicalName;
	FString CanonicalDeclaration;
	TArray<FString> CanonicalIdentityTraits;
	TOptional<FString> CanonicalTypeSpelling;
	TOptional<FAngelscriptCachedDataType> DeclaredType;
	TArray<FAngelscriptCachedParameter> OrderedParameters;
	uint32 TraitFlags;
	uint32 ReflectionFlags;
	TArray<FAngelscriptCachedMetadataEntry> Metadata;
	TArray<FAngelscriptCachedDeclarationSlot> Slots;
	FAngelscriptHash256 SignatureHash;
	FAngelscriptHash256 TraitsHash;
};

struct FAngelscriptCachedSourceMountKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCachedSourceProviderKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCachedPreprocessHookKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCachedSourceFileKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCachedPreprocessorInputKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCachedSourceEdgeKey { FAngelscriptHash256 Hash; };
struct FAngelscriptCachedLogicalSectionKey { FAngelscriptHash256 Hash; };

struct FAngelscriptCachedSourceIndex
{
	uint32 PayloadSchemaVersion;
	FAngelscriptHash256 SourceSnapshot;
	FAngelscriptCachedSourceDiscoveryPolicy DiscoveryPolicy;
	TArray<FAngelscriptCachedSourceMount> Mounts;
	TArray<FAngelscriptCachedSourceProvider> Providers;
	TArray<FAngelscriptCachedPreprocessHook> PreprocessHooks;
	TArray<FAngelscriptCachedSourceFile> Files;
	TArray<FAngelscriptCachedPreprocessorInput> PreprocessorInputs;
	TArray<FAngelscriptCachedSourceEdge> Edges;
	TArray<FAngelscriptCachedFastPathIneligibleScope> IneligibleScopes;
};

struct FAngelscriptCachedModuleInterface
{
	uint32 PayloadSchemaVersion;
	FAngelscriptStableModuleKey ModuleKey;
	FString CanonicalModuleName;
	FAngelscriptHash256 InterfaceAbi;
	TArray<FString> CanonicalNamespaces;
	TArray<FAngelscriptCacheDeclarationRecord> Declarations;
	TArray<FAngelscriptCachedImportDeclaration> Imports;
	TArray<FAngelscriptCacheSemanticDependency> Dependencies;
};

struct FAngelscriptCachedTypeSchema
{
	uint32 PayloadSchemaVersion;
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptStableTypeKey TypeKey;
	EAngelscriptCachedTypeKind TypeKind;
	FString CanonicalNamespace;
	FString CanonicalName;
	FString CanonicalDeclaration;
	uint32 TypeSemanticFlags;
	TArray<FAngelscriptCachedMetadataEntry> Metadata;
	TArray<FAngelscriptCachedTypeRelation> Relations;
	TArray<FAngelscriptCachedTypeLayoutInput> LayoutInputs;
	FAngelscriptCachedLayoutExpectation Layout;
	TArray<FAngelscriptCachedPropertySchema> OrderedProperties;
	TArray<FAngelscriptCachedMethodEntry> OrderedMethods;
	TArray<FAngelscriptCachedVirtualFunctionSlot> VirtualFunctionTable;
	TArray<FAngelscriptCachedBehaviorSlot> OrderedBehaviorSlots;
	FAngelscriptCachedTypeKindPayload KindPayload;
	FAngelscriptCachedReflectionSchema Reflection;
	TArray<FAngelscriptCacheSemanticDependency> Dependencies;
};

struct FAngelscriptCachedInitializerUnit
{
	EAngelscriptCachedInitializerKind InitializerKind;
	FAngelscriptStableFunctionKey InitializerKey;
	TOptional<FAngelscriptStableGlobalKey> OwnerGlobal;
	uint32 VmInitializerCodecVersion;
	FAngelscriptHash256 InitializerExecutionHash;
	TArray<uint8> CanonicalExecutionPayload;
	// Canonical byte authority only; execution order and dependencies live on
	// the matching InitializationAction.
};

struct FAngelscriptCachedInitializationAction
{
	uint32 ActionOrdinal;
	EAngelscriptCachedInitializationActionKind ActionKind;
	FAngelscriptCacheStableReference Target;
	TArray<FAngelscriptCacheSemanticDependency> Dependencies;
};

struct FAngelscriptCachedPostInitFunction
{
	uint32 PostInitOrdinal;
	FAngelscriptCacheStableReference Function;
};

struct FAngelscriptCachedModuleState
{
	uint32 PayloadSchemaVersion;
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptArtifactProfileKey Profile;
	FAngelscriptHash256 StateInputHash;
	TArray<FAngelscriptCachedGlobalSchema> OrderedGlobals;
	TArray<FAngelscriptCachedHardValue> HardValues;
	TArray<FAngelscriptCachedInitializerUnit> Initializers;
	TArray<FAngelscriptCachedInitializationAction> OrderedInitializationActions;
	TArray<FAngelscriptCachedPostInitFunction> OrderedPostInitFunctions;
	TArray<FAngelscriptCacheSemanticDependency> Dependencies;
};

struct FAngelscriptCachedFunctionBody
{
	uint32 PayloadSchemaVersion;
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptFunctionArtifactIdentity Identity;
	FAngelscriptHash256 ExpectedDeclarationAbi;
	FAngelscriptFunctionSourceDigest SourceDigest;
	FAngelscriptFunctionInputDigest InputDigest;
	EAngelscriptCachedFunctionInvocationKind InvocationKind;
	uint32 VmExecutionCodecVersion;
	TArray<uint8> CanonicalExecutionPayload;
	TArray<FAngelscriptCacheSemanticDependency> ActualDependencies;
	TOptional<FAngelscriptCacheRecordId> DebugSidecar;
};

struct FAngelscriptCachedDebugSidecar
{
	uint32 PayloadSchemaVersion;
	FAngelscriptStableFunctionKey FunctionKey;
	FAngelscriptArtifactProfileKey Profile;
	FAngelscriptHash256 DebugHash;
	uint32 VmDebugCodecVersion;
	TArray<FAngelscriptCachedDebugSourceReference> Sources;
	TArray<uint8> CanonicalDebugPayload;
};

struct FAngelscriptCachedModuleRecordLink
{
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCachedTypeSchemaLink
{
	FAngelscriptStableTypeKey TypeKey;
	FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCachedFunctionBodyLink
{
	FAngelscriptStableFunctionKey FunctionKey;
	FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCachedModuleSnapshot
{
	uint32 PayloadSchemaVersion;
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptCachedModuleRecordLink ModuleInterface;
	TArray<FAngelscriptCachedTypeSchemaLink> TypeSchemas;
	FAngelscriptCachedModuleRecordLink ModuleState;
	TArray<FAngelscriptCachedFunctionBodyLink> FunctionBodies;
};

struct FAngelscriptCachedModuleSnapshotLink
{
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptCacheRecordId RecordId;
};

struct FAngelscriptCacheRecordIndexEntry
{
	FAngelscriptCacheRecordId RecordId;
	FAngelscriptCachePackLocation Location;
};

struct FAngelscriptCacheGenerationManifest
{
	uint32 ManifestSchemaVersion;
	uint32 ManifestFlags;
	FAngelscriptCacheCompatibilityKey Compatibility;
	FAngelscriptCacheContextKey Context;
	FAngelscriptArtifactProfileKey Profile;
	FAngelscriptHash256 SourceSnapshot;
	FAngelscriptCacheRecordId SourceIndexRecordId;
	TArray<FAngelscriptCachedModuleSnapshotLink> ModuleSnapshots;
	TArray<FAngelscriptCacheRecordIndexEntry> Records;
};

struct FAngelscriptEncodedCacheGenerationManifest
{
	FAngelscriptCacheGenerationManifest Value;
	FAngelscriptHash256 ComputedGenerationId;
	TArray<uint8> CompleteBytes;
};
```

`ComputedGenerationId` is result metadata computed over `CompleteBytes`; it is
not a field serialized inside `Value` or the manifest file.

These type names are implementation targets; nested payloads MUST follow the
field requirements in `record-schema.md`. Task 2B-1 source mount/provider/hook/
file/input/edge subrecords, capability/filter/target flags, primitive and slot
enums, declaration/import presence rules, exact wire order, source-key
algorithms, hash exclusion rules, and comparators MUST follow
`record-wire-v1.md`; omitted sketch fields are not optional. These sketches are
not permission to use reflection-driven struct serialization. Every serializer
writes each field explicitly. The five remaining records, every nested enum,
flag, field order, type/reflection presence matrix, hash stream, lifecycle,
error and graph phase MUST follow `record-wire-v1-remaining.md`; omitted sketch
fields are not optional. Canonical data type/declaration/type/global values are
common archive fields. Only the three versioned VM execution, initializer and
debug byte arrays are opaque to the common reader. Task 2B-2 uses the injected
deterministic fixture codec; the actual VM codec and live restore arrive with
the later compiler/attachment work, not the filesystem-store task.

`ModuleSnapshot` and manifest roots are keyed links, not bare RecordId arrays.
Each FunctionBody is the sole optional DebugSidecar owner. V1 initializer units
are embedded in ModuleState as a canonical payload set, while one distinct
OrderedInitializationActions sequence interleaves default construction and VM
initializer execution with its dependency edges. TypeSchema owns enum shape/
value; ModuleState owns only the derived hard-value fingerprint and validates
agreement. ModuleState and DebugSidecar carry ProfileKey. TypeSchema preserves
ordered direct interfaces, distinct public-method and VFT sequences, grouped
behavior slots, and explicit reflected-UFunction membership/order, with no
duplicate constructor/factory arrays. ModuleState has explicit per-global
cleanup and no ModuleLifetime/initialized state. The manifest record index is
exactly the transitive reachable set.

SourceIndex has no global eligibility flag and no separate source-to-module
array. `SourceFile.ModuleKey` is the wire authority; lookup checks
`IneligibleScopes` against only the target module's file/mount/provider/hook/
module scopes. Declaration Import is forbidden: imports live only in Imports;
Delegate, Typedef, and Funcdef are Type declarations with entity kinds 5, 6,
and 7; delegate/funcdef signatures are separate Function declarations with
DelegateSignature owned by the TypeKey. Stable declaration keys are recomputed
by the existing Task 1 identity builder. Existing entity-kind numbers remain
unchanged; Task 2B-1 adds only Typedef=6 and Funcdef=7.

The reader exposes exact error plus classification and consumes a session-wide
budget:

```cpp
enum class EAngelscriptCacheValidationClass : uint8
{
	Success = 0,
	Malformed = 1,
	ArithmeticOrBudget = 2,
	CodecOrIntegrity = 3,
	CanonicalSemantic = 4,
	GraphOrOwnership = 5,
	Ineligible = 6,
};

constexpr EAngelscriptCacheValidationClass Classify(
	EAngelscriptCacheValidationError Error);

struct FAngelscriptCacheValidationResult
{
	EAngelscriptCacheValidationError Error;
	EAngelscriptCacheValidationClass Class;
	EAngelscriptCacheRecordKind RecordKind;
	EAngelscriptCacheValidationStage Stage;
	uint64 ByteOffset;
};

struct FAngelscriptCacheReadLimits
{
	uint64 MaxCanonicalRecordPayloadBytes;
	uint64 MaxStoredRecordBytes;
	uint64 MaxManifestBytes;
	uint64 MaxPackBytes;
	uint64 MaxPackIndexEntries;
	uint64 MaxStringBytes;
	uint64 MaxArrayElements;
	uint64 MaxNestingDepth;
	uint64 MaxGenerationRecords;
	uint64 MaxModuleSnapshots;
	uint64 MaxGenerationPacks;
	uint64 MaxReferencesAndRelocations;
	uint64 MaxTotalStoredBytes;
	uint64 MaxTotalDecompressedBytes;
	uint64 MaxTotalDecodedBytes;
	uint64 MaxResidentDecodedBytes;
};

class FAngelscriptCacheReadBudget;

class IAngelscriptCacheOpaquePayloadValidator;
class IAngelscriptCacheCurrentSymbolResolver;
class IAngelscriptCacheProspectiveTypeLayoutView;
class IAngelscriptCacheCurrentLayoutResolver;

using FAngelscriptDecodedCacheRecordHandle =
	TSharedRef<const FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>;

struct FAngelscriptCacheModuleGraphValidationContext
{
	FAngelscriptArtifactProfileKey SelectedProfile;
	FAngelscriptHash256 SelectedSourceSnapshot;
	const FAngelscriptDecodedCacheRecord* SourceIndex;
	const IAngelscriptCacheCurrentSymbolResolver* CurrentSymbols;
	const IAngelscriptCacheCurrentLayoutResolver* CurrentLayouts;
	const IAngelscriptCacheOpaquePayloadValidator* OpaquePayloads;
};

FAngelscriptCacheValidationResult ValidateModuleSnapshotGraph(
	const FAngelscriptCacheRecordId& ModuleSnapshotRecordId,
	TConstArrayView<FAngelscriptDecodedCacheRecordHandle> LocallyValidatedRecords,
	const FAngelscriptCacheModuleGraphValidationContext& Context,
	const FAngelscriptCacheReadLimits& Limits,
	FAngelscriptCacheReadBudget& Budget,
	FAngelscriptValidatedModuleGraph& OutGraph);
```

Keep Task 2A envelope error values `0..11` unchanged and add the semantic
errors/classes `12..43` exactly as `record-wire-v1.md` specifies, then append
only the Task 2B-2 values `44..64` from `record-wire-v1-remaining.md`.
`Classify(Error)` is exhaustive and is the only class authority; result
construction verifies the stored Class, reports the record kind/stage and first
failing ByteOffset, and clears output on every failure. One caller-owned budget
and the same limits continue through the budget-taking envelope overload,
immutable token/child decode, graph indexing/resident DTOs and opaque-codec
summaries; no child resets it. The existing three-argument result constructor
keeps its third argument as ByteOffset; 2B-2 staged failures use a named factory.
A `FAngelscriptCacheScopedScratchReservation` (or equivalently named move-only
RAII guard) reserves checked live scratch bytes against retained decoded bytes
before every temporary `Reserve`/`SetNum*`/index/queue allocation and releases
only that temporary reservation on destruction. Stored, decompressed, decoded,
retained-resident, and reference counters remain monotonic; a failed scratch
reservation changes no counter and allocates nothing. Every decode, immutable
token factory, graph validator, and query receives the same `Limits` and
caller-owned `Budget` rather than creating an internal default.
A sole all-record factory dispatches all seven kinds and returns the sole
thread-safe shared const token. A private Budget-friended candidate transaction
aggregates controller, canonical-payload, DTO and captured-offset capacities as
Temporary before publication, extending atomically at each physical site. The
single canonical reader receives a constructor-owned semantic-blind charge sink:
standalone primitive calls consume Retained, while factory calls extend that
candidate transaction without duplicating codec logic or consulting global state.
The handle charges each physical allocation exactly once and promotes the complete
aggregate once immediately before publication. The candidate
module graph retains handles for reachable records only and publishes only the
compact ordinal-based RecordId/type/global/function/initializer/opaque-owner
tables frozen in `record-wire-v1-remaining.md`; validation maps remain temporary.
Candidate table/summary capacity consumes monotonic total-decoded budget plus
live scratch before allocation, then the scratch reservation is atomically
promoted to retained resident at step 11 without double charge. Late failure
releases candidate scratch and publishes nothing. Handle copies do not allocate
or deep-copy records.
A later Task 2B-3 generation validator composes
this per-module API with manifest exact reachability rather than making 2B-2
depend on a manifest.

### Task 2A: finish the minimal record envelope boundary

The first RED/GREEN slice already established the fixed envelope, semantic
RecordId and basic corruption behavior. Preserve that evidence but do not mark
the complete Task 2 checklist finished. Close the independent-review boundary
findings before layering semantic readers:

- make public RecordId construction fail closed for zero/unknown kinds and
  invalid negative/intrusive-unset views while retaining empty payload support;
- define and test serialization/deserialization alias behavior so resetting or
  reallocating output never invalidates input; and
- retain the byte-exact envelope and full-hash goldens.

Run:

```powershell
Tools\RunBuild.ps1 -Label as-cache-archive-envelope-review-red -TimeoutMs 1800000
Tools\RunBuild.ps1 -Label as-cache-archive-envelope-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.Envelope" -Label as-cache-archive-envelope-green -TimeoutMs 600000
```

Expected: public invalid inputs return typed failures with empty outputs;
empty, non-alias and defined alias cases are safe; frozen bytes remain stable.

### Task 2B-1: canonical primitives, SourceIndex, and ModuleInterface

- [ ] **Step 1: write pure semantic primitive and record RED tests**

Add value-only fixtures for canonical data types, declarations, metadata,
stable references, typed content/hard-value dependencies, SourceIndex and
ModuleInterface. Begin from `record-wire-v1.md`; freeze every V1 enum/flag,
scalar/field order, source sub-key domain, complete record payload, derived
hash, RecordId, and envelope golden. Freeze each of the six public typed
fail-closed source-key builders with an independent full-hash vector and
zero-output failure cases. Freeze public identity-only `TryBuildImportKey`,
including the same key across ExpectedAbi/slot variants and separate full-
Import ABI/slot failures. Construct equivalent fixtures in forward/reverse/map
insertion order and require identical bytes.

Required invalid fixtures include unknown kind/tag/qualifier, invalid UTF-8,
embedded NUL, drive/UNC/slash-rooted/escaping path, ASCII case collision plus a
non-ASCII BMP simple-fold vector and a true supplementary-plane traversal
vector, zero StableKey, missing/forbidden
ExpectedAbi, every ExpectedContent/presence matrix violation, duplicate
identity traits, empty/duplicate namespace-table entry, declaration tagged-
union mismatch, key/SignatureHash/TraitsHash/InterfaceAbi/SourceSnapshot
mismatch, invalid or contradictory Required/Forbidden schema/body coverage,
every callable owner-kind/local Type/Global/DelegateSignature resolution and
CrossModuleOwner/WrongReferenceKind/MissingOwner precedence, Global/Property
type-spelling/DeclaredType presence+hash mutation without pretending pure
semantic equality, per-kind slot and parameter ordinal gap/duplicate, noncanonical set
order, DuplicateKey, ConflictingKey, capability/fingerprint and input-target
presence mismatch, Provider/Hook capability↔same-scope missing-reason
bidirectional mismatch, SourceEdge group SemanticOrdinal mixed/gap/duplicate,
every SourceIndex typed mount/provider/scope/input/edge/generated/module
reference missing/wrong-kind/authority-conflict path, and field/record/session
tiny-budget failure before allocation. Freeze graph-reference phase order as
`Mount -> Hook -> File -> Input -> Edge -> Ineligible`, including Hook-vs-File,
Input-vs-Ineligible and Edge-vs-Ineligible combination failures before any
resolved-authority conflict. Assert no dangling source ref publishes
and distinct Files sharing one GeneratedSourceKey fail as ConflictingKey, then
add competing full-256 duplicate groups whose smallest second wire occurrence
chooses DuplicateKey versus ConflictingKey. Assert public SourceIndex and
ModuleInterface serializer semantic failures retain their established
RecordKind with ByteOffset zero, while decoded failures retain the enclosing
field offset. Add the pure eligibility query with two modules, direct/transitive hook
base-to-dependent closure, a detached Hook chain, canonical matching reasons,
missing-module empty-output failure, and an ineligible scope that leaves the
unrelated module eligible. Add manually forged Hook self/multi-node cycles and
require derived-key validation to return existing `DerivedHashMismatch` before
the query; do not add a cycle error or HookKey hash solver. Obtain the query
input only through SourceIndex decode/factory move-publication, freeze that a
raw DTO cannot call the API, and instrument zero whole-SourceIndex copy during
decode publication/query. Cover exact-limit scratch success, one-byte-short
failure before allocation with unchanged counters, and RAII release after both
success and every injected early failure.

- [ ] **Step 2: run Task 2B-1 RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-record-primitives-red -TimeoutMs 1800000
```

Expected: missing pure interfaces or intentionally unfrozen record goldens.

- [ ] **Step 3: implement explicit primitive and first-record serializers**

Use fixed-width little-endian fields, canonical UTF-8, explicit per-payload
versions, checked reader cursors and session budget consumption. Preserve
semantic sequences through explicit ordinals; sort only set/map-like arrays by
wire discriminator/canonical bytes/full keys. Reuse the Task 1 canonical writer
and its exact six source-key domains; never duplicate its prefix/version/domain
encoding. Implement one public `TryBuild*Key` API for mount/provider/hook/file/
input/edge using identity-only inputs, zero-on-failure typed outputs and the
shared writer; encoders, tests and Task 4 producers all call it and no unchecked
public alternative exists. SourceIndex uses typed mount/provider/hook/source-file/input/edge
wrappers, full raw-byte hashes, explicit capability/filter/target flags,
File.ModuleKey-only mapping, and IneligibleScopes-only per-target eligibility.
Enforce each capability's exact same-scope reason in both directions, group
SourceEdge SemanticOrdinal as all absent or all present contiguous, and resolve
the complete local SourceIndex typed graph before publication with fixed
UnknownEnum/InvalidPresence then WrongReferenceKind/MissingGraphTarget then
resolved-authority ConflictingKey precedence. Enforce one File authority per
present GeneratedSourceKey; distinct Files sharing it conflict before lookup.
Within the graph-reference phase visit exactly Mount, Hook, File, Input, Edge,
then Ineligible enclosing fields; only after all references resolve may File/
Mount authority disagreement return ConflictingKey. At the public record
boundary, wrap every serializer semantic failure with its already established
SourceIndex/ModuleInterface RecordKind and ByteOffset zero; decoded semantic
failures use the captured enclosing-field start.

Task 2B-1 first implemented a factory-only immutable
`FAngelscriptValidatedSourceIndex` as a temporary slice boundary. Task 2B-2
removes that public owning type and routes SourceIndex through the sole common
`FAngelscriptDecodedCacheRecord::TryDecode` factory. Decode into one private
candidate, capture field offsets, complete local/hash/order/duplicate/graph
validation and retained index construction, then publish the common const
handle. On failure publish neither DTO nor partial index. There is no public
raw-DTO-to-token constructor, mutable token access, compatibility wrapper, or
second budget charge. Implement `QueryExactFastPathEligibility` only over a
const view of a common record whose kind is SourceIndex, and require the same
explicit `const FAngelscriptCacheReadLimits&` plus caller-owned
`FAngelscriptCacheReadBudget&`:

```cpp
FAngelscriptCacheValidationResult QueryExactFastPathEligibility(
	const FAngelscriptDecodedCacheRecord& SourceIndexRecord,
	const FAngelscriptStableModuleKey& ModuleKey,
	const FAngelscriptCacheReadLimits& Limits,
	FAngelscriptCacheReadBudget& Budget,
	FAngelscriptCacheExactFastPathEligibility& OutEligibility);
```

The query does not copy or re-prepare the SourceIndex. It
derives module files/mounts/providers, computes affected Hook closure to a fixed
point, filters canonical matching IneligibleScopes/reasons without reordering,
returns true only for an empty set, clears output on failure, and returns
MissingGraphTarget for an absent module. This is transitive set closure over an
already valid authority chain, not iterative HookKey hashing. HookKey contains
AffectedScopeStableKey, so producers build from non-Hook base scopes outward;
forged cycles fail key recomputation as `DerivedHashMismatch` before graph/query
use. Never store a global eligibility bool.
ModuleInterface carries the exact declaration tagged union, imports-only import
authority, multi-slots, strict namespaces, default-expression ABI semantics,
explicit Required/Forbidden TypeSchema/FunctionBody coverage, and typed entity/
environment dependencies. Resolve all local declaration owners through the
frozen callable matrix, including Method→Class/Struct/Interface,
Property→Class/Struct, and DelegateSignature→Delegate/Funcdef only.
Locally validate CanonicalTypeSpelling/DeclaredType presence, shape and hashes;
require the producer to derive both from one compiler type and defer semantic
spelling equality to a resolved TypeSchema/current catalog rather than parsing
text in the 2B-1 decoder. Implement ImportKey through one public zero-on-failure
identity-only builder that excludes route ExpectedAbi/ReferenceKind/Slots;
full Import preparation validates those non-key fields independently. V1 has
no inferred or Optional coverage: a producer
unable to capture a required body makes the complete snapshot NotCacheable.
Implement the exhaustive validation classifier while preserving Task 2A error
values. Do not modify the current
source provider in this slice. Charge every semantic-validation/query scratch
array, typed index, sorted authority view, visited set and Hook queue through
the shared live-resident RAII reservation before allocation. Persistent budget
counters remain monotonic; scratch release never refunds them.

- [ ] **Step 4: run Task 2B-1 GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-record-primitives-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.Primitives" -Label as-cache-record-primitives-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.SourceInterface" -Label as-cache-source-interface-green -TimeoutMs 600000
```

Expected: byte-exact round trips, insertion-order determinism and every local
schema/path/ABI/budget rejection are green without a live engine, provider, or
disk. SourceSnapshot, stable keys, SignatureHash, TraitsHash, InterfaceAbi,
payload RecordIds, and complete envelopes match their independent full goldens.
The RED methods for graph wire precedence, serializer kind/offset, validated-
token-only query, no-copy move publication, live scratch reservation/release,
supplementary-plane traversal and competing wire-first duplicate groups are all
GREEN before requesting a fresh independent Task 2B-1 review.

### Task 2B-2: remaining records and in-memory graph validation

**Pre-RED gate:** Task 2B-1 and ModuleState already have fresh independent
approval, and Slice 0 has mechanically extracted the private canonical codec/
cursor helper under unchanged Primitives and SourceInterface goldens. Do not
begin the remaining RED below until the combined TypeSchema matrix plus
`type-layout-authority-v1.md` receives fresh independent approval. Do not infer
missing rows or combine the already-closed Slice 0 extraction with 2B-2
semantics.

The common token is deliberately sequenced after declaration of every final
record DTO and captured-offset storage type. Step 5 first freezes all seven
complete alternatives and the final `AngelscriptCacheDecodedRecord.h` in-place
variant shape. A temporary SourceIndex/ModuleInterface-only token is forbidden:
adding later alternatives would change the intrusive-controller size/charge,
while pimpl/type erasure would add an unauthorized persistent allocation.

- [ ] **Step 5: write TypeSchema/ModuleState/Function/Debug/Snapshot RED tests**

Freeze a full golden and round trip for each remaining record. Tests require:

- five independent payload-version constants and UnsupportedPayloadSchema
  record-kind/stage diagnostics;
- every `record-wire-v1-remaining.md` enum/flag/presence/hash stream, including
  property/type/global/state/initializer fingerprints and unchanged Task 1
  payload-only execution/debug hashes;
- explicit TypeSchema property/layout/relation/behavior slots, ordered direct
  interfaces, independent public-method/VFT sequences, TypeKind union,
  signed-int32 enum aliases/metadata, reflection matrix, zero-mask UFunction and
  StaticsClass-global membership/order, exact initial/terminal-aligned layout,
  ConfigName/StaticClassGlobalName/StaticsClass rules and no duplicate
  constructor/factory arrays;
- pointer-free Property StorageKind/semantic storage size/alignment/hash and
  BaseType/CodeRoot/StructHeader LayoutInputs in exact wire order; immutable
  layout replay with a present-zero boundary distinct from absence, boundary-
  only UStruct header, shadow alignment for UClass both with and without Script
  Base, linked same-module layout disagreement before current resolution, a cold
  exact hit with no selected-module resolver entries/calls, an allocation-free
  prospective validated-local-layout view for environment templates nested over
  local values, the exact graph/profile-closed versus external/environment call
  table, the engine-free V1 bool/integer/float/ObjectHandle build-layout table
  plus required future CompatibilityKey canonical inputs, and raw eligible
  current-layout role results masked by each validated
  consumer presence shape (including one CodeRoot reused by root and derived
  UClasses), plus
  Typedef `{alias size, alignment 4}` versus expanded primitive property layout;
- physical payload exhaustion, exact top-level field-local order, cross-field
  pairing/coverage/layout-replay order, and unique LayoutInputHash → per-property
  StorageLayoutHash/PropertyLayoutFingerprint → EnumAuthorityHash → final
  TypeLayoutHash order, including exact-ByteOffset paired winner tests, plus the
  complete allocator-authoritative `TS-SCR-01..22` exact-limit/one-byte-short/
  release/promotion matrix;
- TypeSchema enum authority plus exactly one matching ModuleState derived
  hard-value for every local enum;
- one atomic profile-keyed ModuleState global table with fixed-width canonical
  constants, resolved type/storage cleanup policy, canonical keyed initializer
  units, one dependency-solved OrderedInitializationActions sequence that
  interleaves DefaultConstructGlobal and ExecuteInitializer, exact declaration/
  unit/action/module/post-init coverage, reverse action-attempt cleanup, and no
  independent initializer FunctionBody or opaque ModuleLifetime/init bit;
- FunctionBody invocation/declaration ABI/source/input/content coordinates and
  complete actual dependencies, including every invocation-to-EntityKind/
  owner/Generated-trait matrix row and the non-renumbering generated default
  destructor mapping to `EntityKind::Destructor=35 + Generated`;
- deterministic injectable execution/initializer/debug fixture codecs that
  return validated payload hashes, ordered relocations, exact debug sources and
  owned CanonicalName/StringLiteral bytes without common code parsing VM bytes;
  freeze `UEASOPQ1`, Debug V1 zero relocations, and the exact owned-byte
  `{ReferenceKind, StableKey}` comparator;
- relocation dependencies being a complete-coordinate subset of actual
  dependencies, including ABI/content presence/hash and codec-owned string/name
  domain-key validation;
- profile-keyed present DebugSidecar, typed exact logical sections, shared
  profile-specific debug-absent identity API plus Editor/Shipping goldens; and
- redundant keyed module interface/state plus keyed TypeSchema/FunctionBody
  links in ModuleSnapshot.

Add one complete in-memory graph and a mutation fixture for every appended
error `44..64`, exact type/body/global/enum/initializer coverage, direct/
duplicate debug ownership, source-set equality and atomic empty output. Prove
local/integrity then immutable graph then current-resolver precedence:
record-to-record profile/source/ABI contradictions are GraphOrOwnership, while
a self-consistent record versus current source/profile/ABI/content/missing
  symbol/layout is Ineligible. Use separate required current-symbol and current-
  layout resolvers; classify selected-module Script* dependencies/layouts,
  primitive slots, and ObjectHandle slots as graph/profile closed before lookup,
  and allow only the frozen external/environment set to call. Supply the current-
  layout resolver an immutable prospective local TypeSchema view for nested
  environment recipes. No current-layout call may supply immutable replay inputs
  or win over a stored contradiction. Share one caller-owned budget across
every child decode, graph index/DTO and codec summary, and prove every exact
TS-SCR-01..22 allocation family; a generic tiny cumulative-budget case is only
an additional aggregate control and cannot replace that matrix. Every one of
the five remaining-record private decoder paths is wire/local/hash-only. Create
graph/SourceIndex inputs only through the immutable token factory that
recomputes RecordId, dispatches decode and captures offsets.
Graph step 1 invokes opaque validation exactly once per actually reachable
initializer/body/body-owned sidecar and stores summaries; unrelated records get
zero calls. Freeze required Limits propagation, the envelope budget overload,
null-context/zero-selection behavior, named staged-result construction, current
source→profile→dependency missing→ABI→content order, and counter-proved full-key
indexes without O(n^2) rescans.

- [ ] **Step 6: run Task 2B-2 RED**

Precondition: the combined `type-schema-matrix-v1.md` plus
`type-layout-authority-v1.md` has a fresh independent approval recorded in
`verification.md`; ModuleState's prior independent approval remains valid. Use
those co-normative authorities together with `record-wire-v1-remaining.md`;
compact prose does not authorize omitted rows.

```powershell
Tools\RunBuild.ps1 -Label as-cache-record-graph-red -TimeoutMs 1800000
```

Expected: missing remaining-record/graph interfaces or golden mismatch.

- [ ] **Step 7: implement remaining semantic records and graph validator**

Serialize TypeSchema and ModuleState descriptors explicitly; do not introduce
`CanonicalSchemaPayload` or one undifferentiated `CanonicalStatePayload`.
Implement the exact `record-wire-v1-remaining.md` DTO/wire/hash/lifecycle
contract. Store only versioned VM execution/initializer/debug bytes as opaque
fields. Local decoders recompute stored payload hashes but never invoke
`IAngelscriptCacheOpaquePayloadValidator`; graph step 1 validates each reachable
opaque owner exactly once through the seam and later common phases consume the
retained graph-owned summaries only.
Implement `ValidateModuleSnapshotGraph`, the current-symbol and distinct
current-layout resolver contracts, the normative 11-step order and exhaustive
`Classify` additions without a manifest dependency. Persist and hash every
Property storage witness and TypeLayoutInput, replay local layout before current
resolution, cross-check linked same-module layout authorities, expose those
validated layouts through a non-owning prospective view, skip all frozen graph/
profile-closed coordinates, and compare legal external/environment witnesses
only in current eligibility. The production resolver must work before the
selected module has live script types and may use prospective local values only
inside a sealed environment recipe. Validate every local record and immutable graph before current eligibility or any later engine
attachment. A malformed required record rejects the complete ModuleSnapshot;
an eligibility mismatch produces a typed miss and never partial state.

- [ ] **Step 8: run Task 2B-2 GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-record-graph-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.Records" -Label as-cache-records-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive.Graph" -Label as-cache-record-graph-green -TimeoutMs 600000
```

Expected: every record golden/round trip and every ownership/coverage/link/
debug/initializer/enum/relocation/resolver/budget invariant is green in memory
only, including shared debug-absent identity evidence consumed by the sibling
StaticJIT contract.

### Task 2B-3: keyed manifest and deterministic in-memory pack format

**Normative contract:** `manifest-pack-wire-v1.md` overrides the abbreviated
types/sketches below for all Task 2B-3 bytes, IDs, codecs, limits, stages,
errors and validation precedence. This slice remains engine-free and
filesystem-free.

- [ ] **Step 9: write pure manifest/pack-format RED tests**

Freeze `UEASCV2M` schema 1 and `UEASCV2P` schema 1, the 33-byte RecordId,
65-byte manifest root, 122-byte manifest location, 32-byte pack header and
96-byte pack-index entry. Assert packs store canonical semantic payload rather
than nested record envelopes. Freeze `RawChecksum` as direct payload BLAKE3,
PackId/GenerationId as whole-final-file BLAKE3 values that are not serialized
inside their own file, and keyed ModuleSnapshot roots with exactly one
SourceIndex and exact transitive manifest reachability. Pack-only historical
extras remain valid; manifest-index extras do not.

Add malformed pack/index cases for overflow, range, overlap, impossible count,
unsupported codec, stored/raw/decompressed/session budgets, short/excess or
noncanonical/trailing Zlib, raw checksum, semantic RecordId, physical PackId,
GenerationId, duplicate/conflicting locations, wrong linked record kind and
unreachable/extra manifest entries. Freeze stages `PackDecode=7`,
`ManifestDecode=8`, `ManifestGraph=9` and only errors `65..71`. Prove
`MaxGenerationPacks=4096` is enforced by writer and decoder before any pack
source lookup/open.

- [ ] **Step 10: implement manifest values and in-memory pack codec**

Implement the pure interfaces equivalent to
`BuildAngelscriptCachePacks`, `ReadAngelscriptCacheRecordFromPack`,
`EncodeAngelscriptCacheGenerationManifest`, and
`ValidateAngelscriptCacheGeneration` in `manifest-pack-wire-v1.md`. Pack reads
receive complete pack bytes plus expected PackId and the exact manifest entry;
a location-only reader is insufficient.

Production `Auto` uses per-record `None` or Unreal `NAME_Zlib` with
`COMPRESS_BiasMemory`, bit window 15, no dictionary and one stream per record.
Zlib is selected only when strictly smaller; `None` remains valid regardless
of Auto choice. A reader decompresses to exact RawSize and canonical-
recompresses for byte equality. CompatibilityKey includes the pack/manifest
schema and compressor ABI inputs. The caller-owned read budget remains one
monotonic object across manifest, packs, records, opaque summaries,
reachability and module graphs. Task 2 does not choose paths, open files,
publish generations, or own Current/Previous/Pending state.

- [ ] **Step 11: prove deterministic parallel preparation**

Inject serial, forward, reverse, and seeded-random completion policies; compare
complete manifest and in-memory pack bytes, not only hashes.

- [ ] **Step 12: run Task 2B-3 and complete Task 2 GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-pack-format-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive" -Label as-cache-archive-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.PackFormat" -Label as-cache-pack-format-green -TimeoutMs 900000
```

Expected: every explicit record round-trips, the keyed graph and exact reachable
manifest validate, every malformed/budget/eligibility case has the intended
typed result before engine attachment, and serial/parallel manifest and pack
bytes match exactly without touching the filesystem.

The legacy comparison adapter may translate existing precompiled
module/function fixtures into the new explicit values for parity assertions,
but it is test-only. It never writes old IDs/pointers into Cache V2 and does not
make `PrecompiledScript.Cache` a reader, migration, fallback, or production
input. Filesystem temporary roots, immutable disk read sessions,
 Current/Previous/Pending, crash recovery, system-wide locking/rebase,
cancellation, source-aware fallback, and compaction remain task group 3 in
`tasks.md`. Live source discovery, environment capture, VM codec
implementation, builder hooks, and engine attachment remain later work.

### Task 3: Content-Addressed Disk Store And Publication

**Normative contract:** `store-publication-v1.md` is the sole V1 authority for
filesystem paths, pointer bytes, atomic operations, locking/rebase,
cancellation/commit states, immutable read sessions, candidate fallback,
retention, compaction and store errors. It consumes, but does not redefine,
`manifest-pack-wire-v1.md`.

**Files:**

- Create/complete `AngelscriptCacheStore.h/.cpp` and
  `AngelscriptCacheStoreTests.cpp`.
- Use injectable filesystem, atomic-file, system-wide-lock, cancellation and
  fault seams. Production platform implementations must expose their actual
  old-or-new pointer atomicity and delete-sharing capabilities.

- [ ] **Step 13: freeze roots, names and 80-byte pointers in RED**

Assert default `<ProjectSavedDir>/Angelscript/CacheV2`, complete replacement by
`-as-cache-root`, canonical containment, lower-case full-hash namespace/final
names, and pointer-schema participation in CompatibilityKey. Freeze
`UEASCV2C`, schema 1, pointer kind, reserved bytes, nonzero GenerationId and
checksum as an exact 80-byte golden for Current, Previous and
PendingColdStart; reject wrong filename kind, schema, size, reserved bytes,
zero ID, checksum and trailing bytes as store/pointer failures.

- [ ] **Step 14: implement immutable object and platform atomic seams**

Use exact same-directory temp names
`.tmp.<decimal-pid>-<32-lower-hex-nonce>`. Write/full-flush/close, reopen and
validate before every no-replace immutable rename or pointer replace; sync the
parent directory and reopen final immutable objects. Reuse an existing final
only when expected ID and complete bytes match. Reject a generic
delete-destination-then-move implementation with
`UnsupportedPlatformAtomicity`.

- [ ] **Step 15: freeze namespace lock, rebase and publication state machine**

Derive one system-wide lock from the canonical absolute namespace path, poll
cancellation/deadline at most every 100 ms, and preserve engine-gate-before-
store-lock ordering. After lock acquisition reread Current/Previous/Pending and
rebase: same source+semantics is `AlreadyCurrent`, same source+different
semantics is `RebaseSemanticConflict`, and changed source is
`NeedsSourceRevalidation`. Install Previous then Current; successful Current
atomic replacement is the irreversible Current commit point. Pending-only
publication never rotates Current/Previous.

- [ ] **Step 16: prove every crash and cancellation boundary**

Inject every frozen fault point from `BeforePackTempWrite` through
`AfterPendingReplace`. Assert exact visible temps/finals/pointers, no temp read,
orphan immutable allowance, indeterminate atomic-result reread, and commit-
state correctness. Cancellation before the relevant pointer commit is
NotCommitted; after successful Current/Pending/compaction pointer commit it is
ignored and no rollback deletes immutable content.

- [ ] **Step 17: implement immutable handle-pinned read sessions and fallback**

Under the namespace lock validate a candidate pointer/manifest, count distinct
PackIds, enforce `MaxGenerationPacks` before pack open, then pin the manifest
and every referenced pack handle before releasing the lock. One cumulative
budget spans Current→Previous→Pending attempts. Selection order is exactly
Current, Previous, then cold-eligible Pending. Every candidate independently
matches compatibility/context/profile/source; corruption never permits stale
different-source execution.

- [ ] **Step 18: implement physical retention and two-phase compaction**

Treat every presently valid Current/Previous/Pending pointer as a physical
root regardless of selection eligibility. Normal startup/publication never
repacks or sweeps. Explicit compaction first revalidates source/profile, rebuilds
the reachable union, finalizes replacement packs/manifests and switches
Previous/Pending/Current slot pointers without deleting old objects; then it
reacquires the lock, remarks current roots and sweeps strict-name unmarked
finals. Pinned-reader deletion failure is `DeleteDeferred` and is retried later.

- [ ] **Step 19: keep store errors separate and run Task Group 3 GREEN**

Freeze `EAngelscriptCacheStoreError 0..21`, store stages and commit states as
control-plane diagnostics. `ContentValidationFailed` must carry the nested
archive result; path/lock/I/O/atomic/cancellation outcomes never consume
archive error values.

```powershell
Tools\RunBuild.ps1 -Label as-cache-store-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Store" -Label as-cache-store-green -TimeoutMs 900000
```

Expected: all fake-store/fault/concurrency/cancellation/pinning/fallback/
compaction cases pass and serial/random immutable outputs remain byte-identical.
Real PIE and Development/Shipping multi-process acceptance remains the final
milestone.

### Task 4: Source Planner, Function Compiler Hook, ModuleState, And Atomic Restore

**Files:**

- Create `AngelscriptCachePlanner.*`, `AngelscriptCachePlannerTests.cpp` and `AngelscriptCacheCompilerReuseTests.cpp`.
- Modify maintained fork `as_builder.h/.cpp`, compiler/function internals required by the VM-private artifact adapter, and focused fork tests.
- Extend Cache types/service adapter and `AngelscriptEngine.cpp` stage integration, including both initialization paths and active-function route rebuilding.

**Interfaces produced:**

```cpp
enum class EAngelscriptCacheMissReason : uint8
{
	MissingRecord,
	SourceChanged,
	DeclarationChanged,
	TypeSchemaChanged,
	ModuleStateChanged,
	DependencyChanged,
	EnvironmentAbiChanged,
	ProfileMismatch,
	DebugChanged,
	CorruptRecord,
};

struct FAngelscriptCachePlan
{
	bool bExactSourceSnapshot;
	TArray<FAngelscriptCacheModulePlan> Modules;
	TArray<FAngelscriptCacheHit> Hits;
	TArray<FAngelscriptCacheMiss> Misses;
};

FAngelscriptCachePlan BuildAngelscriptCachePlan(
	const FAngelscriptSourceInventory& Source,
	const FAngelscriptCompileContextSnapshot& Context,
	const FAngelscriptEnvironmentSymbolCatalog& Environment,
	const FAngelscriptCacheReadSession* Cache);

enum asEBuildArtifactInvocationKind
{
	asBUILD_ARTIFACT_REGULAR,
	asBUILD_ARTIFACT_FACTORY,
	asBUILD_ARTIFACT_DEFAULT_CONSTRUCTOR,
	asBUILD_ARTIFACT_DEFAULT_DESTRUCTOR,
	asBUILD_ARTIFACT_INIT_DEFAULTS,
	asBUILD_ARTIFACT_SINGLE_FUNCTION,
	asBUILD_ARTIFACT_LAMBDA,
};

struct asSBuildArtifactInvocation
{
	asEBuildArtifactInvocationKind Kind;
	// Canonical module/namespace/owner/declaration and source/token/node data.
	// Generated traits/context are explicit; no Unreal type is exposed here.
};
```

- [ ] **Step 1: Write SourceIndex and invalidation RED tests**

Create deterministic fixtures for:

```text
unchanged exact snapshot
mount/root/provider-version or generated-source change
source kind/mount/provider/filter/hook/memory/generated-source change
source add/delete/rename/case collision
comment/whitespace/line movement
one body
signature/owner/trait/add/delete function
property/inheritance/class metadata
interface/delegate/enum
global/constant/initializer order
import/include graph/define/conditional/preprocessor option
referenced vs unrelated bound symbol ABI
Editor/Game/Development/Shipping context
```

Each scenario asserts exact module/record/function full keys and typed reasons. Do not assert only aggregate counts.

- [ ] **Step 2: Run planner RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-planner-red -TimeoutMs 1800000
```

Expected: missing SourceIndex/planner/dependency interfaces or focused hit/miss mismatch.

- [ ] **Step 3: Implement SourceIndex and typed closure planning**

Source discovery always produces the exact `record-wire-v1.md` value: Game/
Plugin/Memory source kind, typed mount/provider/hook/file/input/edge keys, root
descriptor, provider/hook stable identity/version/configuration/content
capabilities, development/editor filters, memory/loose/generated raw bytes,
typed logical path, include/generated graph, effective define/conditional/
preprocessor option, preprocess-hook fingerprint, and File.ModuleKey. Extend the
producer boundary to provide raw-byte BLAKE3-256 and explicit fingerprints;
never substitute its existing 64-bit source-state hash. A provider/hook without
a required stable fingerprint adds only its affected IneligibleScope. Exact
lookup derives eligibility for the target module and leaves unrelated scopes
eligible. A changed inventory uses existing include/preprocessor/module
ownership to preprocess only the affected closure, then compares
ModuleInterface, TypeSchema, ModuleState, FunctionSourceDigest, resolved
FunctionInputDigest and environment dependencies.

Persist existing `FModuleDependencyInfo` normal/hard/structural semantics in ModuleInterface. Sort all plans by stable module/entity key.

Capture `FAngelscriptEnvironmentSymbolCatalog` from each concrete engine after `Binds.Cache`/normal binding and `BindScriptTypes` complete in both `Initialize` and `InitializeWithoutInitialCompile`. Tests must demonstrate that no lookup falls back to the process-global `FAngelscriptTypeDatabase` and that two engines remain isolated.

- [ ] **Step 4: Write builder-hook RED tests before production hook**

Tests install a fake artifact provider into one builder and assert:

- miss invokes the real compiler once;
- hit attaches executable bytecode and invokes it zero times;
- corrupt hit becomes a diagnosed miss;
- another builder/engine is unaffected;
- normal function, method, constructor/destructor, factory, generated default, `__InitDefaults`, public single-function compilation and generated lambdas all pass through a kind-tagged invocation hook;
- public snippets/debug expressions/lambdas without stable persistent module coordinates return `NotCacheable`, compile normally, and are never captured;
- globals do not pass through the function hook.

- [ ] **Step 5: Add the maintained-fork hook**

Keep the generic AS interface Unreal-free:

```cpp
enum asEBuildArtifactLookupResult
{
	asBUILD_ARTIFACT_MISS,
	asBUILD_ARTIFACT_RESTORED,
	asBUILD_ARTIFACT_REJECTED,
	asBUILD_ARTIFACT_NOT_CACHEABLE,
};

class asIBuildArtifactCache
{
public:
	virtual ~asIBuildArtifactCache() = default;
	virtual asEBuildArtifactLookupResult TryRestoreFunction(
		asCBuilder& Builder,
		const asSBuildArtifactInvocation& Invocation,
		asCScriptFunction& Function) = 0;
	virtual void CaptureCompiledFunction(
		asCBuilder& Builder,
		const asSBuildArtifactInvocation& Invocation,
		const asCScriptFunction& Function) = 0;
};
```

`asCBuilder` stores one non-owning callback set by the host for that compilation transaction. The normal/generated `CompileFunctions()` loop, separate factory loop, and public `CompileFunction()`/lambda loop each construct the descriptor, call `TryRestoreFunction` immediately before compiler invocation, and call `CaptureCompiledFunction` only after a cacheable successful compile. `NotCacheable` bypasses capture. No process-global callback is allowed.

- [ ] **Step 6: Implement UE adapter and stable bytecode references**

The adapter first computes `FunctionSourceDigest` from canonical AST/token slice, invocation kind and options. On a matching prior artifact, it resolves that artifact's persisted, canonically sorted actual dependency keys against current declaration/environment fingerprints to compute `FunctionInputDigest` before the compiler decision. A source-digest change is an immediate miss. Cold/miss compilation instruments compiler/bytecode capture to collect the actual dependency set; successful capture stores that set and the recomputed input digest. Do not add a duplicate semantic-analysis pass.

A hit then uses declaration-first current-engine maps and `AngelscriptFunctionArtifactCodec` to reconstruct instruction operands, `scriptData`, stack/local object/cleanup metadata, line/debug metadata, and stable function/type/global/property/environment/string/system-function references. Maintain an opcode/reference coverage table matching every legacy relocation category. Never raw-attach bytecode or restore old pointer tokens, FName indices, or persisted numeric IDs. Unit tests corrupt each metadata/reference family independently and assert rejection before mutation.

- [ ] **Step 7: Implement live attachment from validated TypeSchema, ModuleState, and ModuleSnapshot values**

Consume the pointer-free values and graph proven by Task 2. Type schemas are created/resolved before properties/methods. ModuleState restores or recompiles the entire global storage/initializer/order unit through the VM-private initializer codec. A module can become active only after all referenced records, imports, globals, dependency edges, module swap, and ClassGenerator/reflection steps succeed.

After successful activation, rebuild the engine-owned stable-function route by enumerating ordinary, class/method, generated and factory functions from active modules only. Exclude temporary `_NEW_`/`_OLD_` modules and prove two-engine/numeric-FunctionId isolation.

- [ ] **Step 8: Run planner/compiler GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-compiler-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Planner" -Label as-cache-planner-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.CompilerReuse" -Label as-cache-compiler-green -TimeoutMs 900000
```

Expected: exact snapshot uses zero preprocess/parse/compiler calls; the controlled body fixture compiles exactly one function; type/global mutation closures match the spec; warm/cold execution and reflection observations are equal.

### Task 5: Engine-Owned Cache Lifecycle, Editor/PIE Publication, And Shutdown

**Files:**

- Create `AngelscriptCacheService.*` and `AngelscriptCacheLifecycleTests.cpp`.
- Modify `AngelscriptEngine.h/.cpp`, `AngelscriptSubsystem.cpp` and Runtime build rules.
- Use existing Editor watcher/reload flow; do not create an Editor-owned store.

**Interfaces produced:**

```cpp
class FAngelscriptCacheService
{
public:
	explicit FAngelscriptCacheService(FAngelscriptEngine& Owner);
	FAngelscriptCacheStartupPlan BeginStartup(const FAngelscriptCacheStartupRequest& Request);
	void InstallBuilderHook(asCBuilder& Builder, const FAngelscriptCacheModulePlan& Plan);
	void OnCompileTransactionSucceeded(FAngelscriptCachePublicationDto&& Publication);
	void OnCompileTransactionFailed();
	void PublishPendingColdStart(FAngelscriptCachePublicationDto&& Publication);
	FAngelscriptCacheFlushResult Flush(FTimespan Timeout);
	void Shutdown(FTimespan Timeout);
};
```

`FAngelscriptCachePublicationDto` contains compile run ID/type/final result, profile/context, explicit SourceIndex record, Current/Pending disposition, stable module keys, module interfaces, type schemas, module state, canonical function execution/debug payloads, and canonically ordered actual dependency/environment fingerprints. It contains no `asCScriptFunction*`, `asCModule*`, UObject, mutable descriptor, address-derived token or shared mutable map.

Service state and callbacks are per `FAngelscriptEngine`. Add a real `FAngelscriptEngineMutationGate` around startup restore, hook lifetime, declarations/layout/globals, swap/ClassGenerator, stable routes, runtime reload, Current/Pending selection, provider route refresh and shutdown; do not reuse the existing diagnostic `CompilationLock` as a correctness mutex. Define initialization-thread ownership, game-thread safe-point transition, explicit-token reentrancy and engine-gate-before-store-lock ordering. In `CompileModules()`, `FreezeSuccessfulCompileArtifacts()` runs after final success, swap/dependency/ClassGenerator/reinstancing, but before temporary compiled state is moved/released. `PartiallyHandled` PIE may produce distinct active-Current and cold-start-candidate DTOs. `CompileEnd` remains diagnostic-only. Workers may consume only DTOs and immutable store sessions; they may not reread module descriptors or call AS engine APIs.

- [ ] **Step 1: Write lifecycle RED tests**

Use isolated store/source roots and class-level engine fixtures. Cover:

- no-cache source compile continues and publishes;
- unchanged second engine restores;
- changed fresh-start source compile failure does not activate old source;
- hot-reload failure preserves active last-good and Current;
- successful body reload publishes after swap;
- structural reload publishes only after ClassGenerator success;
- structural PIE result creates PendingColdStart, not Current;
- post-PIE/full reload promotes or replaces Pending;
- writer cancellation and engine destruction;
- two engines have isolated service/route/gate state;
- reload versus shutdown, publish completion versus engine destruction, and provider refresh versus compile handoff serialize or cancel without stale access;
- engine/module/function destruction after DTO freeze does not prevent deterministic pack construction.

- [ ] **Step 2: Run lifecycle RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-lifecycle-red -TimeoutMs 1800000
```

Expected: missing service/lifecycle callbacks or focused publication-state failure.

- [ ] **Step 3: Integrate startup and successful compile handoff**

Replace old `bUsePrecompiledData` startup selection with the Cache service. The service first hashes source and selects exact restore or compile planning. Do not publish from read-only compile events. Call `OnCompileTransactionSucceeded` only after module swap and ClassGenerator/reflection success; failure paths call `OnCompileTransactionFailed` and retain current state.

- [ ] **Step 4: Implement async preparation and serialized publication**

Workers canonicalize/hash/compress/build packs from immutable captures. The engine owner receives completion, validates its lifetime/cancellation token, and requests store publication. No worker retains `asCScriptFunction*`, `asCModule*`, UObject, descriptor reference, or mutable engine map.

- [ ] **Step 5: Implement Editor/PIE current versus pending policy**

Use existing compile result/class reload classifications:

```text
FullyHandled body/soft reload             -> publish Current after success
full structural reload outside PIE       -> publish Current after reinstancing success
PartiallyHandled structural change in PIE -> publish PendingColdStart only
ErrorNeedFullReload in PIE                -> no Current publication; retain diagnostics
compile/ClassGenerator error              -> no publication
```

PendingColdStart stores a source-correct AS artifact generation but cannot become Current in the active PIE engine. A later cold/full transaction revalidates source/environment/ClassGenerator before promotion.

- [ ] **Step 6: Implement bounded shutdown flush**

At the beginning of `FAngelscriptEngine::Shutdown()`, before `ShutDownAndRelease` and old descriptor/function teardown, call service shutdown with configured timeout. Flush only already captured/prepared work. Timeout cancels known work/temp files and returns; never start source discovery or compile in shutdown.

- [ ] **Step 7: Run lifecycle GREEN and affected hot-reload subset**

```powershell
Tools\RunBuild.ps1 -Label as-cache-lifecycle-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Lifecycle" -Label as-cache-lifecycle-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label as-cache-hotreload-compat -TimeoutMs 1200000
```

Expected: lifecycle tests pass; affected HotReload tests have zero failures/timeouts; shutdown leaves no selected temp generation and no released-engine pointer in worker data.

### Task 6: Settings, Public Runtime Reload, Diagnostics, And StaticJIT Isolation

**Files:**

- Create `AngelscriptCacheSettings.*`, `AngelscriptRuntimeReloadTypes.h`, `AngelscriptCacheDiagnostics.*`, `AngelscriptCacheRuntimeReloadTests.cpp`, and `AngelscriptCacheStaticJITBridgeTests.cpp`.
- Modify `AngelscriptSubsystem.h/.cpp`, `AngelscriptEngineSubsystem.h/.cpp`, Cache service and dump observers.
- Modify the Cache-owned compatibility bridge/tests; do not implement or fake the sibling external provider here.

**Interfaces produced:**

```cpp
UENUM(BlueprintType)
enum class EAngelscriptRuntimeReloadMode : uint8
{
	Disabled,
	Manual,
	Automatic,
};

UENUM(BlueprintType)
enum class EAngelscriptRuntimeReloadRequestStatus : uint8
{
	Queued,
	Disabled,
	Busy,
	ShuttingDown,
};

UENUM(BlueprintType)
enum class EAngelscriptRuntimeReloadOutcome : uint8
{
	NoChanges,
	AppliedCodeOnly,
	RequiresRestart,
	CompileFailed,
	Cancelled,
};

enum class EAngelscriptRuntimeInitializationStatus : uint8
{
	NotStarted,
	Succeeded,
	SourceCompileFailed,
	ClassGenerationFailed,
	Cancelled,
};

USTRUCT(BlueprintType)
struct ANGELSCRIPTRUNTIME_API FAngelscriptRuntimeReloadResult
{
	GENERATED_BODY()
	UPROPERTY(BlueprintReadOnly) EAngelscriptRuntimeReloadOutcome Outcome;
	UPROPERTY(BlueprintReadOnly) TArray<FString> ChangedModules;
	UPROPERTY(BlueprintReadOnly) int32 FunctionHits;
	UPROPERTY(BlueprintReadOnly) int32 FunctionMisses;
	UPROPERTY(BlueprintReadOnly) int32 CompiledFunctions;
	UPROPERTY(BlueprintReadOnly) FString GenerationId;
	UPROPERTY(BlueprintReadOnly) FString Diagnostic;
};
```

`UAngelscriptCacheSettings` contains only the four approved public settings/defaults. Worker limits/memory budgets remain internal policy/CVars until benchmarks justify a public setting.

- [ ] **Step 1: Write API/settings/runtime-policy RED tests**

Assert UEnum/UClass/UFunction/property reflection names and defaults, Disabled request, Manual queue/completion, Automatic debounce/hash, busy/shutdown statuses, NoChanges, successful code-only application, compile failure, cancellation, structural RequiresRestart with old module/Current retained, typed startup status, and default nonzero unattended packaged failure independent of `-as-exit-on-error`.

- [ ] **Step 2: Run RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-runtime-reload-red -TimeoutMs 1800000
```

Expected: missing reflected settings/types/subsystem methods or focused state-machine failure.

- [ ] **Step 3: Implement settings and subsystem queue**

```cpp
UCLASS(Config=Engine, DefaultConfig, meta=(DisplayName="AngelScript Cache"))
class ANGELSCRIPTRUNTIME_API UAngelscriptCacheSettings : public UObject
{
	GENERATED_BODY()
public:
	UPROPERTY(Config, EditDefaultsOnly, Category="Cache")
	bool bEnableIncrementalCache = true;
	UPROPERTY(Config, EditDefaultsOnly, Category="Runtime Reload")
	EAngelscriptRuntimeReloadMode RuntimeReloadMode = EAngelscriptRuntimeReloadMode::Disabled;
	UPROPERTY(Config, EditDefaultsOnly, Category="Runtime Reload", meta=(ClampMin="0.1"))
	float AutomaticReloadIntervalSeconds = 1.0f;
	UPROPERTY(Config, EditDefaultsOnly, Category="Cache", meta=(ClampMin="0.0"))
	float ShutdownFlushTimeoutSeconds = 5.0f;
};
```

`UAngelscriptSubsystem::RequestRuntimeReload()` returns immediate request status and queues one generation-safe request. Tick processes it only at an engine safe point. Automatic scanning schedules the same request path; it does not call Editor DirectoryWatcher APIs.

- [ ] **Step 4: Enforce packaged structure guard**

Run existing reload analysis before active swap. Only the code-only/soft result may activate. Any class/property/inheritance/signature/global/interface/delegate/enum/structural dependency result emits `RequiresRestart`, retains old active modules and Current, and discards the attempted live generation.

For cold non-editor startup, the engine subsystem records `EAngelscriptRuntimeInitializationStatus` from the authoritative compile/ClassGenerator result. In unattended packaged execution, `SourceCompileFailed` or `ClassGenerationFailed` requests process exit with a nonzero status by default. Editor records/exposes the status without forcing process exit. This is a new explicit contract, not the old optional `-as-exit-on-error` branch.

- [ ] **Step 5: Write diagnostics RED tests**

Assert exact stable JSON keys/order and console behavior for no store, cold compile, warm hit, one-body miss, corruption/fallback, publish failure, PendingColdStart, runtime outcomes, and two processes with different addresses.

Required JSON shape:

```json
{
  "schemaVersion": 1,
  "compatibilityKey": "",
  "contextKey": "",
  "profileKey": "",
  "sourceSnapshot": "",
  "generationBefore": "",
  "generationAfter": "",
  "records": {
    "moduleInterface": {"hits": 0, "misses": 0},
    "typeSchema": {"hits": 0, "misses": 0},
    "moduleState": {"hits": 0, "misses": 0},
    "functionBody": {"hits": 0, "misses": 0},
    "debugSidecar": {"hits": 0, "misses": 0}
  },
  "pipeline": {
    "sourceFilesHashed": 0,
    "preprocessedModules": 0,
    "parsedModules": 0,
    "compiledFunctions": 0
  },
  "io": {"bytesRead": 0, "bytesWritten": 0},
  "publication": {"outcome": "", "fallbackReason": ""},
  "reload": {"outcome": ""},
  "timingsMs": {}
}
```

- [ ] **Step 6: Implement commands and report**

Register `as.ReloadScripts`, `as.Cache.Status`, `as.Cache.Flush`, `as.Cache.Verify` and `as.Cache.Compact` through Runtime. Parse `-as-cache-root` before store construction and `-as-cache-report` before shutdown/flush reporting. Normalize/validate override roots and never let a manifest escape them.

- [ ] **Step 7: Prove StaticJIT isolation**

Add focused compatibility-bridge assertions for stable-key miss, absent legacy/native route, content mismatch, profile mismatch and ABI mismatch. Each case must select VM while Cache generation/source/record counters stay unchanged. Do not require or simulate the sibling external provider in this change; cache-side tests exercise the bridge contract and retained legacy route only.

- [ ] **Step 8: Run GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-runtime-reload-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.RuntimeReload" -Label as-cache-runtime-reload-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Diagnostics" -Label as-cache-diagnostics-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.StaticJITBridge" -Label as-cache-staticjit-isolation -TimeoutMs 1200000
```

Expected: reflected API/defaults are exact; code-only live reload works; structural live reload is rejected without active/cache mutation; diagnostics are deterministic; StaticJIT failures affect routes only.

### Task 7: Direct Legacy Removal, Loose-Source Packaging, And Package Smoke Runner

**Files:**

- Retire old `PrecompiledScript.Cache` ownership/helpers/flags/commands/tests and update state dumps while retaining an inventoried StaticJIT numeric compatibility transport until the sibling provider has parity.
- Modify `Config/DefaultGame.ini` and `Tools/RunPackage.ps1`.
- Create package smoke module/runner/self-test scripts.
- Modify suite definitions/dispatcher.

- [ ] **Step 1: Write legacy rejection RED test**

Place only a valid-looking old `PrecompiledScript.Cache` beside valid source and an empty V2 root. Assert the old file cannot satisfy V2, source compiles, V2 publishes, and `Binds.Cache` remains unaffected. Add a source-free harness case that fails clearly rather than reading legacy data.

- [ ] **Step 2: Run legacy RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-legacy-red -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Legacy" -Label as-cache-legacy-red -TimeoutMs 600000
```

Expected before removal: focused test demonstrates the old production path can still be selected.

- [ ] **Step 3: Remove legacy production behavior in one reviewable pass**

Remove:

- `bGeneratePrecompiledData`, `bUsePrecompiledData` and forced-exit cache-generation selection;
- `PrecompiledDataGuid`/`DataGuid` pairing;
- persisted old cache FunctionId/pointer relocation maps after `AngelscriptFunctionArtifactCodec` parity;
- `PrecompiledScript.Cache` load/save and command-line generation;
- script-cache ownership from StaticJIT;
- legacy-only allocator/archive tests after equivalent V2 tests pass.

Do not delete `FJITDatabase`, StaticJITHeader/generated registration, numeric bytecode routing or diagnostics transport still used by the sibling external-provider path. Publish a per-file/per-symbol bridge inventory covering `PrecompiledData.*`, `AngelscriptStaticJIT.*`, `AngelscriptBytecodes.cpp`, `StaticJITHeader.*`, `StaticJITDiagnostics.*`, AOT fixtures, diagnostics parser, state dumps and config. This change removes their Cache correctness ownership; the sibling change removes the transport only after provider parity. Keep deliberate rejection/history strings asserted by tests and classify every retained match.

- [ ] **Step 4: Write packaging preflight RED checks**

Before changing config/tools, add the smoke helper self-test with a temporary staged tree that fails when:

- Script is missing or located only in a simulated Pak/UFS tree;
- `Binds.Cache` is missing;
- `PrecompiledScript.Cache` or packaged `Script/AngelscriptCache` is present;
- executable discovery is ambiguous;
- report schema/launch sequence is incomplete.

Run:

```powershell
Tools\Diagnostics\TestAngelscriptCachePackageSmoke.ps1
```

Expected: missing module/script or focused assertion failure.

- [ ] **Step 5: Change staging and package entry**

In `DefaultGame.ini` remove:

```ini
+DirectoriesToAlwaysStageAsUFS=(Path="../Script")
```

and add the maintained equivalent:

```ini
+DirectoriesToAlwaysStageAsNonUFS=(Path="../Script")
```

In `RunPackage.ps1` remove `GeneratePrecompiledData`, cache-generation-specific `ForcePreprocessEditorCode` behavior, Editor-Cmd pre-step, old cache existence check, and metadata fields for that phase. Retain mutex, timeout, BuildCookRun, `-pak` for cooked assets, archive/report layout, and add post-stage validation for loose Script/`Binds.Cache`/legacy absence.

- [ ] **Step 6: Implement pure package-smoke helpers and self-tests**

`AngelscriptCachePackageSmoke.psm1` provides:

```powershell
Resolve-AngelscriptPackagedExecutable
Resolve-AngelscriptPackagedScriptRoot
Assert-AngelscriptLoosePackageLayout
New-AngelscriptCacheSmokeFixture
Set-AngelscriptCacheSmokeFixtureScenario
Invoke-AngelscriptPackagedCacheLaunch
Read-AngelscriptCacheReport
Assert-AngelscriptCacheScenarioReport
```

All mutation targets are resolved and verified inside the disposable archive root before writes. The module never edits the workspace `Script` directory.

- [ ] **Step 7: Implement the actual smoke wrapper**

`RunAngelscriptCachePackageSmoke.ps1` parameters:

```powershell
param(
    [ValidateSet('Development','Shipping')]
    [string]$Configuration,
    [string]$Label = 'cache-package',
    [string]$OutputRoot = '',
    [int]$TimeoutMs = 3600000,
    [switch]$SkipPackage
)
```

It calls `RunPackage.ps1` unless `SkipPackage` is explicitly used with a verified archive, creates a dedicated source fixture under the archived loose `Script/Game/CacheSmoke/`, allocates one isolated cache root, then runs:

```text
01-cold
02-unchanged-warm
03-one-body-edit
04-invalid-source
05-restored-last-good
06-structural-cold-start
```

Normal launches use `-nullrhi -unattended -as-cache-root=... -as-cache-report=... -ExecCmds="as.Cache.Flush,quit"` and must exit zero. Invalid-source launch must exit nonzero. Every phase gets an independent log/report and one combined Summary JSON.

- [ ] **Step 8: Add typed suites**

Add `Cache` with `Angelscript.TestModule.Cache` as a Heavy UnrealAutomation entry and add that entry to `All`. Add `CachePackage` with two Heavy `PackageSmoke` entries for Development and Shipping, and teach `TestSuiteEntryRunner.ps1` to call the wrapper with normal timeout/output/dry-run metadata. Do not add `CachePackage` to `All`.

- [ ] **Step 9: Run tooling GREEN without building real packages yet**

```powershell
Tools\Diagnostics\TestAngelscriptCachePackageSmoke.ps1
Tools\RunTestSuite.ps1 -Suite CachePackage -DryRun
Tools\RunTestSuite.ps1 -ListSuites
```

Expected: helper self-tests exit 0; dry run prints exactly one Development and one Shipping PackageSmoke entry; normal All contains Cache automation but no package build.

### Task 8: Final Real PIE And Development/Shipping Multi-Launch Acceptance

**Files:**

- Create `AngelscriptCachePIELifecycleTests.cpp`.
- Reuse `AngelscriptTest/Editor/AngelscriptPIETestUtils.h` and patterns from `HotReload/AngelscriptHotReloadPIESessionTests.cpp`.
- Use the completed package smoke wrapper; do not add Shipping-only test hooks to production Cache behavior.

- [ ] **Step 1: Write real PIE scenarios**

Use `TEST_CLASS_WITH_FLAGS`, class-level engine lifecycle, actual `FStartPIEForAutomationCommand`/PIE World lookup/`EndPIE`, and per-test cleanup. Tests must observe runtime/reflection/instance behavior, not only compile results:

```text
ColdThenWarmPIESessionsRestoreEquivalentBehavior
BodyEditUpdatesLivePIEInstanceAndOneFunctionBody
StructuralEditKeepsLiveInstanceAndCreatesPendingColdStart
EndPIEFullReloadPromotesStructureAndNextPIESeesIt
CompileFailureKeepsLastGoodAndDoesNotAdvanceGeneration
PIEEndDuringAsyncPreparationReleasesNoStalePointers
```

- [ ] **Step 2: Run real PIE acceptance**

Focused lifecycle/service behavior already followed RED/GREEN in Task 5. Register these real Editor PIE scenarios only as the user-requested final acceptance layer, then run:

```powershell
Tools\RunBuild.ps1 -Label as-cache-pie-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.PIE" -Label as-cache-pie-green -TimeoutMs 1200000
```

Expected: every PIE session starts/ends, externally observed body/class behavior is correct, Pending/Current transitions match diagnostics, and cleanup leaves no PIE World/module/delegate/temp root.

- [ ] **Step 3: Run real Development package matrix**

```powershell
Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Development -Label as-cache-package-development -TimeoutMs 3600000
```

Required report assertions:

- cold: no generation before, compile count greater than zero, valid generation after;
- unchanged warm: same generation, exact snapshot, zero preprocess/parse/compiler;
- one body: one FunctionBody compile miss, zero TypeSchema/ModuleState miss;
- invalid: process nonzero, Current unchanged;
- restored last-good: valid Current selected and behavior restored;
- structural cold: ModuleInterface/TypeSchema miss and new generation after successful start.

- [ ] **Step 4: Run real Shipping package matrix**

```powershell
Tools\RunAngelscriptCachePackageSmoke.ps1 -Configuration Shipping -Label as-cache-package-shipping -TimeoutMs 3600000
```

Apply the identical assertions. Additionally verify scripts are loose outside Pak, runtime reload default reports Disabled, `PrecompiledScript.Cache`/packaged baseline are absent, and first launch uses the Shipping Runtime compiler path.

- [ ] **Step 5: Run maintained suite wrapper**

```powershell
Tools\RunTestSuite.ps1 -Suite CachePackage -LabelPrefix as-cache-package-final -TimeoutMs 3600000 -ContinueOnFail
```

Expected: both typed entries pass, with separate package archives, cache roots, reports and summaries. If either fails, preserve all artifacts and do not mark Task 8 complete.

### Task 9: Benchmarks, Documentation, Full Verification, And Handoff

**Files:**

- Add raw benchmark CSV/JSON and update `verification.md`.
- Update Chinese then English project/plugin guides identified by the actual final implementation diff.
- Update sibling StaticJIT OpenSpec cross-contract if implementation names/golden vectors differ from the recorded contract; do not merge its tasks into this change.

- [ ] **Step 1: Capture benchmark evidence**

Use at least one warmup and three measured runs per scenario:

```text
cold-no-cache
exact-warm
one-body-edit
type-schema-edit
module-state-edit
forced-serial-generation
bounded-parallel-generation
```

Write raw rows with:

```csv
timestampUtc,commit,engineVersion,platform,configuration,scenario,isWarmup,runIndex,sourceFilesHashed,preprocessedModules,parsedModules,compiledFunctions,moduleHits,moduleMisses,typeHits,typeMisses,stateHits,stateMisses,functionHits,functionMisses,bytesRead,bytesWritten,totalMs,sourceHashMs,readValidateMs,restoreMs,compileMs,classGeneratorMs,prepareWriteMs
```

Record median/min/max in a separate summary. Do not introduce a flaky millisecond pass threshold in V1; exact work counters and semantic parity are hard assertions.

- [ ] **Step 2: Update documentation in language order**

Document:

- logical records versus physical packs;
- Saved-only paths and compatibility/context namespaces;
- source-authoritative first launch;
- Editor/PIE Current/Pending behavior and shutdown flush;
- packaged reload modes and structural restart rule;
- loose Shipping source/security tradeoff;
- commands/settings/report fields;
- package/suite commands;
- StaticJIT/Live Coding independence;
- legacy rejection and `Binds.Cache` separation.

- [ ] **Step 3: Classify legacy references**

```powershell
rg -n "PrecompiledScript\.Cache|DataGuid|CreateFunctionId|OldFunctionId|Old.*Pointer|as-generate-precompiled-data|bUsePrecompiledData|bGeneratePrecompiledData" Plugins/Angelscript Tools Config Documents openspec/changes/refactor-as-incremental-function-cache
```

Expected: production selection/generation/relocation references are absent. Remaining matches are explicit rejection tests, research/history, or unrelated identifiers individually classified in `verification.md`.

- [ ] **Step 4: Run focused and full verification**

```powershell
Tools\RunBuild.ps1 -Label as-cache-final-build -TimeoutMs 1800000
Tools\RunTestSuite.ps1 -Suite Cache -LabelPrefix as-cache-final -TimeoutMs 1200000
Tools\RunTestSuite.ps1 -Suite HotReload -LabelPrefix as-cache-final-hotreload -TimeoutMs 1800000
Tools\RunStaticJITTests.ps1 -LabelPrefix as-cache-final-staticjit-aot
Tools\RunTestSuite.ps1 -Suite CachePackage -LabelPrefix as-cache-final-package -TimeoutMs 3600000 -ContinueOnFail
Tools\RunTestSuite.ps1 -Suite All -LabelPrefix as-cache-final-all -TimeoutMs 3600000 -ContinueOnFail
openspec validate "refactor-as-incremental-function-cache" --strict
git diff --check
```

Expected: every command exits 0; automation/package summaries report zero failure/skip/not-run/timeout; package scenarios meet exact counters; strict validation and diff check are clean.

- [ ] **Step 5: Final self-review and record**

Map every requirement/scenario in the three delta specs to a task/test/report, verify all `tasks.md` checkboxes reflect real evidence, list the exact submodule and parent working-tree changes without disturbing unrelated work, and record final command timestamps/result paths in `verification.md`. Do not archive, commit, push, or update the gitlink unless explicitly requested.

---

## Self-Review Checklist

- Stable identity covers module/type/function/global/property, not functions alone.
- `FunctionSourceDigest` is compared first; matching persisted actual dependencies produce pre-decision `FunctionInputDigest`; `FunctionContentHash` is post-compile/StaticJIT validation.
- Binding changes are per-symbol dependencies, not a whole-profile invalidator.
- One explicit generation SourceIndex plus module-scoped ModuleSnapshots cover type/global/class/function semantics; FunctionBody is the sole DebugSidecar link authority.
- Hook eligibility uses transitive set closure over validated derived keys; forged cycles fail DerivedHashMismatch before query and never invoke a HookKey hash solver.
- Physical layout uses aggregated packs, never one file per function; semantic RecordId and byte-exact physical PackId are distinct.
- Manifest/pack V1 exact bytes, whole-file IDs, canonical Zlib, reachability, `MaxGenerationPacks`, stages and errors come only from `manifest-pack-wire-v1.md`.
- Exact warm and changed-module/per-function paths are both specified and counted.
- ModuleState is atomic; active module publication is atomic.
- Current/Previous/PendingColdStart semantics are unambiguous.
- Pointer bytes, true atomic replacement, commit points, handle pinning, physical roots and two-phase compaction come only from `store-publication-v1.md`; store errors never extend archive validation.
- Source-authoritative startup failure and hot-reload last-good behavior are distinct.
- Editor/PIE and packaged runtime use one Runtime service.
- Runtime reload public APIs/defaults and structure guard are exact.
- Shipping first launch compiles loose source; no packaged baseline/pre-step remains.
- StaticJIT and Live Coding are optional consumers and cannot invalidate AS Cache.
- Real PIE and both real package configurations are final mandatory acceptance.
- No implementation decision, placeholder, or old baseline/overlay assumption remains.
## Progressive implementation issue record

All confirmed design, test, build, integration, performance, PIE, packaging,
and multi-start problems discovered while executing this plan are appended to
`implementation-issues.md`. Normative corrections must also update the owning
design/wire/spec artifact; exact commands and results remain in
`verification.md`. Do not hide a resolved-in-session issue by omitting it from
the ledger.
