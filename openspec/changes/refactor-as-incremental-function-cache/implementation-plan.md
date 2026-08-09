# Incremental AngelScript Script Cache V2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` only when the user explicitly authorizes delegated execution; otherwise use `superpowers:executing-plans`. Use `superpowers:test-driven-development` for every task marked TDD, `angelscript-test-guide` before C++ automation work, `superpowers:systematic-debugging` for unexpected failures, and `superpowers:verification-before-completion` before checking off a milestone.

**Goal:** Replace the monolithic pre-generated `PrecompiledScript.Cache` with a Runtime-owned, Saved-only Cache V2 that restores unchanged modules, reuses unchanged functions/types/state after edits, continuously serves Editor/PIE, and is generated on first Development/Shipping launch from loose authoritative `.as` source.

**Architecture:** `Core/Artifacts` owns stable entity/function/profile identity and a read-only environment symbol catalog. `Cache/` owns logical records, explicit serialization, content-addressed aggregated packs, immutable generations, invalidation planning, lifecycle, runtime reload and diagnostics. Persistent data is entity-granular, but active-engine restore/publication is module-atomic. Pure source/hash/I/O/pack work is bounded-parallel; builder/type/global/swap/ClassGenerator work remains serialized.

**Tech Stack:** Unreal Engine host currently configured for 5.8, Unreal C++, maintained AngelScript fork, `FBlake3`, `FArchive`, `FCompression`/Zlib, UE Tasks/`ParallelFor`, `FSystemWideCriticalSection`, CQTest/UE Automation, PowerShell project runners, OpenSpec.

## Global Constraints

- Work in the current main checkout. Do not create/use a worktree unless the user explicitly requests it.
- `Plugins/Angelscript` is a submodule and may already contain unrelated user edits, including `Core/AngelscriptEngine.*`. Recheck both parent/submodule status before each task, preserve unrelated changes, and stop if an unavoidable overlap cannot be separated.
- Do not commit, push, archive the OpenSpec, or alter the parent gitlink unless the user explicitly requests that action.
- Follow red-green-refactor: production behavior is not added until a focused test has failed for the expected missing behavior.
- Do not implement a legacy reader, migrator, dual-format switch, packaged baseline, or automatic conversion for `PrecompiledScript.Cache`.
- Do not modify `Binds.Cache` format/ownership; observe bound symbols through per-symbol ABI fingerprints.
- Do not change business `.as` syntax or require script-authored IDs/annotations. The only language-engine change is an internal maintained-fork builder artifact hook.
- Full BLAKE3-256 values are authoritative; derived GUIDs/truncated text are display-only.
- Never invoke builder/type/layout/global/code-generation operations concurrently inside one `asCScriptEngine` beyond the existing proven parallel parse path.
- Current source is authoritative. A changed source snapshot that fails fresh-start compilation cannot run an older different-source generation.
- Editor/PIE structural semantics remain authoritative. Packaged live reload defaults Disabled and accepts code-only changes only.
- New C++ automation files start with `Angelscript` and use `Angelscript.TestModule.Cache.*`.
- Build/test only through `Tools/RunBuild.ps1`, `Tools/RunTests.ps1`, and `Tools/RunTestSuite.ps1`. Package only through `Tools/RunPackage.ps1` or the new wrapper that calls it.
- Real PIE and Development/Shipping package multi-launch tests are the last implementation milestone, after focused unit/integration coverage is green.
- Update Chinese guidance before English guidance when implementation changes architecture/build/test behavior.

---

## File Map

### Plugin Runtime — create

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h/.cpp` — hash/key/profile value types, canonical writer, entity descriptors, input/content builders, display GUID/hex.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptEnvironmentSymbolCatalog.h/.cpp` — current bind/type/function/global/property observation, stable environment keys, ABI fingerprints, dependency lookup.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypes.h` — schema constants, record kinds, typed records, manifests, pack index, validation/planning/publication outcomes.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheArchive.h/.cpp` — explicit-field canonical serialization, bounds/checksum/compression validation, stable references.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheStore.h/.cpp` — Saved roots, immutable read sessions, aggregated packs, Current/Previous/Pending, writer lock, atomic publication, compaction.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCachePlanner.h/.cpp` — SourceIndex comparison, typed dependency graph, exact fast path, record hit/miss closure.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheService.h/.cpp` — engine lifecycle, builder hook adapter, async preparation, module assembly, publish/flush/cancellation.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheSettings.h/.cpp` — `UAngelscriptCacheSettings` and defaults.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptRuntimeReloadTypes.h` — Blueprint/C++ reload mode, request, outcome, result and delegate types.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheDiagnostics.h/.cpp` — stable counters/snapshots, JSON report, console commands, verification and compaction entry points.

### Plugin Runtime / maintained fork — modify or retire

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h/.cpp` — engine-owned service/routing, initial fast path, compile planner, successful capture, module activation, pending/current handling, shutdown flush; retire old flags/pointers.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.h/.cpp` — public reload request/delegate, safe-point queue and lifecycle.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h/.cpp` — per-builder host artifact callback immediately around function compiler invocations.
- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` — new Runtime sources/dependencies without adding Editor-only dependencies.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h/.cpp` and legacy helpers — comparison adapter first; remove script-cache ownership after V2 parity.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp` and `AngelscriptStateSnapshot.cpp` — replace old DataGuid/precompile fields with Cache V2 observer data.

### Plugin tests — create/modify

- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptArtifactIdentityTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheArchiveTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheStoreTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCachePlannerTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheCompilerReuseTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheLifecycleTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheRuntimeReloadTests.cpp`
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

### Task 1: Stable Entity, Function, Profile, And Environment Identity

**Files:**

- Create the two `Core/Artifacts` pairs.
- Create `AngelscriptArtifactIdentityTests.cpp`.
- Modify `AngelscriptEngine.h` only for the engine-owned current-function route.

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

The canonical writer exposes only fixed-width little-endian integers, bool, full hash, and length-prefixed UTF-8. Entity builder functions accept typed descriptors and never infer absolute paths/source positions.

- [ ] **Step 1: Write identity red tests**

Use one CQTest class with class-level engine lifecycle and scenario methods:

```cpp
TEST_CLASS_WITH_FLAGS(FAngelscriptArtifactIdentityTests,
	"Angelscript.TestModule.Cache.Identity",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(EntityKeysIgnoreProcessAndEnumerationState);
	TEST_METHOD(ProjectRelocationPreservesLogicalKeys);
	TEST_METHOD(CaseInsensitiveVirtualPathCollisionIsRejected);
	TEST_METHOD(OverloadsAndSyntheticOwnersAreDistinct);
	TEST_METHOD(BodyChangesInputAndContentButNotFunctionKey);
	TEST_METHOD(DebugAndExecutionContentAreIndependent);
	TEST_METHOD(ProfileAndEnvironmentDependenciesInvalidateIndependently);
	TEST_METHOD(FullHashRejectsDisplayGuidCollision);
	TEST_METHOD(TwoEnginesOwnIndependentFunctionRoutes);
};
```

- [ ] **Step 2: Run RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-identity-red -TimeoutMs 1800000
```

Expected: build fails only because the new identity/catalog/route interfaces do not exist, or a deliberately compiling scaffold fails focused assertions. Resolve unrelated compile errors before proceeding.

- [ ] **Step 3: Implement canonical identity and golden vectors**

Use domain strings `module`, `type`, `function`, `global`, `property`, `function-input`, `function-execution`, `function-debug`, `compatibility`, `context` and `profile`. Normalize logical paths before encoding; reject case-fold collisions during SourceIndex construction rather than folding identity case.

- [ ] **Step 4: Implement environment catalog and current-engine route**

```cpp
struct FAngelscriptEnvironmentSymbol
{
	FAngelscriptHash256 StableKey;
	FAngelscriptHash256 AbiFingerprint;
	EAngelscriptEnvironmentSymbolKind Kind;
};

class FAngelscriptEnvironmentSymbolCatalog
{
public:
	static TUniquePtr<FAngelscriptEnvironmentSymbolCatalog> Capture(const FAngelscriptEngine& Engine);
	const FAngelscriptEnvironmentSymbol* Find(const FAngelscriptHash256& StableKey) const;
};

class FAngelscriptCurrentFunctionRouteMap
{
public:
	bool Rebuild(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules, FString& OutError);
	asIScriptFunction* Resolve(const FAngelscriptStableFunctionKey& Key) const;
};
```

Catalog capture occurs after binds are sealed; route maps are one-per-engine and rebuilt only after successful declaration/module replacement.

- [ ] **Step 5: Run GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-identity-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Identity" -Label as-cache-identity-green -TimeoutMs 600000
```

Expected: build exit 0; all identity scenarios execute and pass; golden full hashes are stable in forced insertion-order variations.

### Task 2: Cache V2 Records, Archive, Packs, And Immutable Generations

**Files:**

- Create `AngelscriptCacheTypes.h`, `AngelscriptCacheArchive.*`, `AngelscriptCacheStore.*`.
- Create `AngelscriptCacheArchiveTests.cpp` and `AngelscriptCacheStoreTests.cpp`.
- Adapt `StaticJIT/PrecompiledData.*` only through a test comparison adapter; do not select V2 at startup yet.

**Interfaces produced:**

```cpp
enum class EAngelscriptCacheCodec : uint8
{
	None,
	Zlib,
};

enum class EAngelscriptCacheRecordKind : uint8
{
	SourceIndex,
	ModuleInterface,
	TypeSchema,
	ModuleState,
	FunctionBody,
	DebugSidecar,
	ModuleSnapshot,
};

enum class EAngelscriptCacheReferenceKind : uint8
{
	ScriptModule,
	ScriptType,
	ScriptFunction,
	ScriptGlobal,
	ScriptProperty,
	ScriptImport,
	EnvironmentSymbol,
	CanonicalName,
	StringLiteral,
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
	Type,
	Function,
	Global,
	Property,
	Import,
	Delegate,
	Funcdef,
};

enum class EAngelscriptCacheModuleDependencyKind : uint8
{
	Include,
	Import,
	Inheritance,
	ValueLayout,
	Signature,
	Initializer,
};

enum class EAngelscriptCachePreprocessorInputKind : uint8
{
	IncludeFile,
	Define,
	ConditionalSymbol,
	GeneratedSource,
};

struct FAngelscriptCacheRecordId
{
	EAngelscriptCacheRecordKind Kind;
	FAngelscriptHash256 ContentHash;
};

struct FAngelscriptCachePackLocation
{
	FAngelscriptHash256 PackId;
	uint64 Offset;
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

struct FAngelscriptCacheDeclarationRecord
{
	EAngelscriptCacheDeclarationKind Kind;
	FAngelscriptHash256 StableKey;
	FAngelscriptHash256 SignatureHash;
	FAngelscriptHash256 TraitsHash;
};

struct FAngelscriptCacheModuleDependency
{
	EAngelscriptCacheModuleDependencyKind Kind;
	FAngelscriptStableModuleKey TargetModule;
	FAngelscriptHash256 ExpectedInterfaceHash;
};

struct FAngelscriptCachePreprocessorInput
{
	EAngelscriptCachePreprocessorInputKind Kind;
	FString CanonicalName;
	FAngelscriptHash256 ContentHash;
};

struct FAngelscriptCachedSourceFile
{
	FString LogicalMount;
	FString VirtualPath;
	FAngelscriptHash256 RawContentHash;
	FAngelscriptStableModuleKey ModuleKey;
	TArray<FAngelscriptCachePreprocessorInput> PreprocessorInputs;
};

struct FAngelscriptCachedSourceIndex
{
	FAngelscriptHash256 SourceSnapshot;
	TArray<FAngelscriptCachedSourceFile> Files;
};

struct FAngelscriptCachedModuleInterface
{
	FAngelscriptStableModuleKey ModuleKey;
	FString CanonicalModuleName;
	TArray<FAngelscriptStableModuleKey> Imports;
	TArray<FAngelscriptCacheDeclarationRecord> Declarations;
	TArray<FAngelscriptCacheModuleDependency> Dependencies;
};

struct FAngelscriptCachedTypeSchema
{
	FAngelscriptStableTypeKey TypeKey;
	EAngelscriptCachedTypeKind TypeKind;
	FAngelscriptHash256 LayoutHash;
	TArray<uint8> CanonicalSchemaPayload;
	TArray<FAngelscriptCacheStableReference> Dependencies;
};

struct FAngelscriptCachedModuleState
{
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptHash256 StateHash;
	TArray<uint8> CanonicalStatePayload;
	TArray<FAngelscriptCacheStableReference> Dependencies;
};

struct FAngelscriptCachedFunctionBody
{
	FAngelscriptFunctionArtifactIdentity Identity;
	FAngelscriptFunctionInputDigest InputDigest;
	TArray<uint8> CanonicalExecutionPayload;
	TArray<FAngelscriptCacheStableReference> Dependencies;
	TOptional<FAngelscriptCacheRecordId> DebugSidecar;
};

struct FAngelscriptCachedDebugSidecar
{
	FAngelscriptStableFunctionKey FunctionKey;
	FAngelscriptHash256 DebugHash;
	TArray<uint8> CanonicalDebugPayload;
};

struct FAngelscriptCachedModuleSnapshot
{
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptCacheRecordId ModuleInterface;
	TArray<FAngelscriptCacheRecordId> TypeSchemas;
	FAngelscriptCacheRecordId ModuleState;
	TArray<FAngelscriptCacheRecordId> FunctionBodies;
	TArray<FAngelscriptCacheRecordId> DebugSidecars;
};

struct FAngelscriptCacheRecordIndexEntry
{
	FAngelscriptCacheRecordId RecordId;
	FAngelscriptCachePackLocation Location;
};

struct FAngelscriptCacheGenerationManifest
{
	uint32 SchemaVersion;
	FAngelscriptCacheCompatibilityKey Compatibility;
	FAngelscriptCacheContextKey Context;
	FAngelscriptArtifactProfileKey Profile;
	FAngelscriptHash256 GenerationId;
	FAngelscriptHash256 SourceSnapshot;
	TArray<FAngelscriptCacheRecordIndexEntry> Records;
	TArray<FAngelscriptCacheRecordId> ModuleSnapshots;
};
```

`ModuleSnapshot` is the atomic activation envelope over the six reusable semantic
record kinds; it is not a seventh compiler artifact. Writers sort declaration,
dependency, preprocessor-input, record-index and snapshot arrays by their specified
enum discriminator followed by the complete 256-bit key. `ExpectedAbi` is zero only
for references whose kind has no ABI contract; environment-symbol and executable
script references must carry the exact ABI/content expectation. A missing debug
sidecar is represented by an unset `TOptional`, never by a zero hash. Canonical
name/string bytes stay inside their owning explicit payload; their reference key is
the domain-separated hash used to validate and deduplicate those bytes, not an
FName index or process-local string-table offset.

Every serializer writes fields explicitly. No `Ar << Struct` for layout-dependent structs and no raw-memory dump is accepted.

- [ ] **Step 1: Write archive RED tests**

Cover byte-exact golden encodings and round trips for every record kind and these independent failures: wrong magic/schema/profile, truncation, integer overflow, impossible count, pack range, stored/raw size budget, unknown codec, checksum, non-canonical ordering, duplicate/conflicting key, wrong dependency kind, missing dependency, path escape, and disallowed pointer/FunctionId field.

- [ ] **Step 2: Run archive RED**

```powershell
Tools\RunBuild.ps1 -Label as-cache-archive-red -TimeoutMs 1800000
```

Expected: missing record/archive interfaces or focused golden mismatch.

- [ ] **Step 3: Implement records and validated canonical archive**

The reader returns typed results and validates before allocation:

```cpp
enum class EAngelscriptCacheValidationError : uint8
{
	None,
	BadMagic,
	UnsupportedSchema,
	ProfileMismatch,
	Overflow,
	BudgetExceeded,
	OutOfBounds,
	UnsupportedCodec,
	ChecksumMismatch,
	NonCanonicalOrder,
	DuplicateKey,
	MissingDependency,
	WrongDependencyKind,
	PathEscapesRoot,
};

FAngelscriptCacheValidationResult DeserializeGeneration(
	TConstArrayView<uint8> Bytes,
	const FAngelscriptCacheReadLimits& Limits,
	FAngelscriptCacheGenerationManifest& OutManifest);
```

Use BLAKE3 of canonical uncompressed payloads for record/pack/generation identity. Support deterministic `None` and `Zlib`; select Zlib only when its bytes are smaller.

- [ ] **Step 4: Write store RED tests**

Use one per-test temporary root and inject filesystem crash points:

```text
BeforePackTempWrite
AfterPackTempFlush
AfterPackRename
AfterManifestTempFlush
AfterManifestRename
BeforeCurrentReplace
AfterPreviousReplace
```

Assert immutable read sessions, Current/Previous/Pending selection, source-snapshot-aware fallback, cross-context isolation, multi-writer rebase, cancelled writes, and absence of partial visibility.

- [ ] **Step 5: Implement pack/store reader and writer**

```cpp
struct FAngelscriptCacheStoreRoot
{
	FString RootDirectory;
	FAngelscriptCacheCompatibilityKey Compatibility;
	FAngelscriptCacheContextKey Context;
};

class FAngelscriptCacheReadSession
{
public:
	const FAngelscriptCacheGenerationManifest& GetManifest() const;
	TValueOrError<TArray<uint8>, FAngelscriptCacheValidationResult> ReadRecord(
		const FAngelscriptCacheRecordId& RecordId) const;
};

class FAngelscriptCacheStore
{
public:
	TValueOrError<TSharedRef<const FAngelscriptCacheReadSession>, FAngelscriptCacheOpenResult>
		OpenMatchingGeneration(const FAngelscriptCacheOpenRequest& Request);
	TFuture<FAngelscriptCachePublishResult> PublishAsync(FAngelscriptPreparedGeneration Generation);
	FAngelscriptCacheCompactResult Compact();
};
```

Use `FSystemWideCriticalSection` named from a full normalized-root hash. Commit rereads Current, reuses existing content hashes, writes same-volume temporary files, flushes/validates, renames immutable data, writes Previous, and replaces Current last.

Keep Current, Previous, PendingColdStart and all referenced packs. Pack target is 64 MiB uncompressed; this value is writer policy and is not written into CompatibilityKey.

- [ ] **Step 6: Prove deterministic parallel preparation**

Inject serial, forward, reverse, and seeded-random completion policies; compare complete manifest and pack bytes, not only hashes. Cancellation before Current replacement must leave the exact previous on-disk pointer bytes.

- [ ] **Step 7: Run archive/store GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-store-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Archive" -Label as-cache-archive-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Store" -Label as-cache-store-green -TimeoutMs 900000
```

Expected: every record round-trips, every malformed case is rejected before attachment/allocation, all crash points preserve a complete generation, and serial/parallel bytes match exactly.

### Task 3: Source Planner, Function Compiler Hook, ModuleState, And Atomic Restore

**Files:**

- Create `AngelscriptCachePlanner.*`, `AngelscriptCachePlannerTests.cpp` and `AngelscriptCacheCompilerReuseTests.cpp`.
- Modify maintained fork `as_builder.h/.cpp`.
- Extend Cache types/service adapter and `AngelscriptEngine.cpp` stage integration.

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
```

- [ ] **Step 1: Write SourceIndex and invalidation RED tests**

Create deterministic fixtures for:

```text
unchanged exact snapshot
source add/delete/rename/case collision
comment/whitespace/line movement
one body
signature/owner/trait/add/delete function
property/inheritance/class metadata
interface/delegate/enum
global/constant/initializer order
import/include/preprocessor option
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

Source discovery always hashes raw bytes and compares the complete logical inventory. Exact match bypasses preprocess/parse. A changed inventory uses existing include/preprocessor/module ownership to preprocess only the affected closure, then compares ModuleInterface, TypeSchema, ModuleState, FunctionInputDigest and environment dependencies.

Persist existing `FModuleDependencyInfo` normal/hard/structural semantics in ModuleInterface. Sort all plans by stable module/entity key.

- [ ] **Step 4: Write builder-hook RED tests before production hook**

Tests install a fake artifact provider into one builder and assert:

- miss invokes the real compiler once;
- hit attaches executable bytecode and invokes it zero times;
- corrupt hit becomes a diagnosed miss;
- another builder/engine is unaffected;
- normal function, method, constructor/destructor, factory, generated default and `__InitDefaults` all pass through the hook;
- globals do not pass through the function hook.

- [ ] **Step 5: Add the maintained-fork hook**

Keep the generic AS interface Unreal-free:

```cpp
enum asEBuildArtifactLookupResult
{
	asBUILD_ARTIFACT_MISS,
	asBUILD_ARTIFACT_RESTORED,
	asBUILD_ARTIFACT_REJECTED,
};

class asIBuildArtifactCache
{
public:
	virtual ~asIBuildArtifactCache() = default;
	virtual asEBuildArtifactLookupResult TryRestoreFunction(
		asCBuilder& Builder,
		const sFunctionDescription& Description,
		asCScriptFunction& Function) = 0;
	virtual void CaptureCompiledFunction(
		asCBuilder& Builder,
		const sFunctionDescription& Description,
		const asCScriptFunction& Function) = 0;
};
```

`asCBuilder` stores one non-owning callback set by the host for that compilation transaction. `CompileFunctions()` and the factory/generated paths call `TryRestoreFunction` immediately before compiler invocation and `CaptureCompiledFunction` only after successful compile. No process-global callback is allowed.

- [ ] **Step 6: Implement UE adapter and stable bytecode references**

The adapter computes FunctionInputDigest from the canonical AST/token slice and actual stable dependencies. A hit uses declaration-first current-engine maps to translate stable function/type/global/property/environment references into this engine's objects and attaches the complete validated FunctionBody. Never restore old pointer tokens, FName indices, or persisted numeric IDs.

- [ ] **Step 7: Implement TypeSchema, ModuleState, and atomic ModuleSnapshot assembly**

Type schemas are created/resolved before properties/methods. ModuleState restores or recompiles the entire global storage/initializer/order unit. A module can become active only after all referenced records, imports, globals, dependency edges, module swap, and ClassGenerator/reflection steps succeed.

- [ ] **Step 8: Run planner/compiler GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-compiler-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Planner" -Label as-cache-planner-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.CompilerReuse" -Label as-cache-compiler-green -TimeoutMs 900000
```

Expected: exact snapshot uses zero preprocess/parse/compiler calls; the controlled body fixture compiles exactly one function; type/global mutation closures match the spec; warm/cold execution and reflection observations are equal.

### Task 4: Engine-Owned Cache Lifecycle, Editor/PIE Publication, And Shutdown

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
	void OnCompileTransactionSucceeded(const FAngelscriptCacheCompileSuccess& Success);
	void OnCompileTransactionFailed();
	void PublishPendingColdStart(const FAngelscriptCacheCompileSuccess& Success);
	FAngelscriptCacheFlushResult Flush(FTimespan Timeout);
	void Shutdown(FTimespan Timeout);
};
```

Service state and callbacks are per `FAngelscriptEngine`. Captured records must be immutable before worker work starts.

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
- two engines have isolated service/route state.

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

### Task 5: Settings, Public Runtime Reload, Diagnostics, And StaticJIT Isolation

**Files:**

- Create `AngelscriptCacheSettings.*`, `AngelscriptRuntimeReloadTypes.h`, `AngelscriptCacheDiagnostics.*` and `AngelscriptCacheRuntimeReloadTests.cpp`.
- Modify `AngelscriptSubsystem.h/.cpp`, Cache service and dump observers.
- Modify focused StaticJIT tests only to consume stable identity and prove independent fallback.

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

Assert UEnum/UClass/UFunction/property reflection names and defaults, Disabled request, Manual queue/completion, Automatic debounce/hash, busy/shutdown statuses, NoChanges, successful code-only application, compile failure, cancellation, and structural RequiresRestart with old module/Current retained.

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

Add focused assertions for no provider, provider removal, stable-key miss, content mismatch, profile mismatch and ABI mismatch. Each case must select VM while Cache generation/source/record counters stay unchanged.

- [ ] **Step 8: Run GREEN**

```powershell
Tools\RunBuild.ps1 -Label as-cache-runtime-reload-green -TimeoutMs 1800000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.RuntimeReload" -Label as-cache-runtime-reload-green -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.Diagnostics" -Label as-cache-diagnostics-green -TimeoutMs 600000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label as-cache-staticjit-isolation -TimeoutMs 1200000
```

Expected: reflected API/defaults are exact; code-only live reload works; structural live reload is rejected without active/cache mutation; diagnostics are deterministic; StaticJIT failures affect routes only.

### Task 6: Direct Legacy Removal, Loose-Source Packaging, And Package Smoke Runner

**Files:**

- Retire old `PrecompiledData` ownership/helpers/flags/commands/tests and update state dumps.
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
- persisted old FunctionId and old pointer relocation maps;
- `PrecompiledScript.Cache` load/save and command-line generation;
- script-cache ownership from StaticJIT;
- legacy-only allocator/archive tests after equivalent V2 tests pass.

Keep only deliberate rejection/history strings asserted by tests. Do not delete generic helpers still used by StaticJIT until their consumers have moved to the proper shared boundary.

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

### Task 7: Final Real PIE And Development/Shipping Multi-Launch Acceptance

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

- [ ] **Step 2: Run real PIE RED then GREEN**

Run RED immediately after registering the tests and before the final missing PIE cache behavior is implemented; confirm focused expected failures. After implementation:

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

Expected: both typed entries pass, with separate package archives, cache roots, reports and summaries. If either fails, preserve all artifacts and do not mark Task 7 complete.

### Task 8: Benchmarks, Documentation, Full Verification, And Handoff

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
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label as-cache-final-staticjit -TimeoutMs 1800000
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
- `FunctionInputDigest` is available before compile; `FunctionContentHash` is post-compile/StaticJIT validation.
- Binding changes are per-symbol dependencies, not a whole-profile invalidator.
- Six logical records plus ModuleSnapshot cover type/global/class semantics.
- Physical layout uses aggregated packs, never one file per function.
- Exact warm and changed-module/per-function paths are both specified and counted.
- ModuleState is atomic; active module publication is atomic.
- Current/Previous/PendingColdStart semantics are unambiguous.
- Source-authoritative startup failure and hot-reload last-good behavior are distinct.
- Editor/PIE and packaged runtime use one Runtime service.
- Runtime reload public APIs/defaults and structure guard are exact.
- Shipping first launch compiles loose source; no packaged baseline/pre-step remains.
- StaticJIT and Live Coding are optional consumers and cannot invalidate AS Cache.
- Real PIE and both real package configurations are final mandatory acceptance.
- No implementation decision, placeholder, or old baseline/overlay assumption remains.
