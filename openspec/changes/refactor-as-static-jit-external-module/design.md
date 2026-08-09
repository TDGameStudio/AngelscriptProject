## Context

Current StaticJIT generation assigns a `uint32 FunctionId` through `FAngelscriptPrecompiledData::CreateFunctionId()`, emits that ID into registration C++, and looks entries up through process-wide `FJITDatabase`. One `FStaticJITCompiledInfo::ActiveInfo` carries a random `PrecompiledDataGuid`; when the cache GUID differs, the runtime clears all registered functions. Editor builds also define `AS_SKIP_JITTED_CODE`, so the production path is effectively immutable cooked AOT rather than a route that can follow Editor recompilation.

That model cannot meet the requested behavior. An AS hot reload creates new function objects and often new FunctionIds; a body-only edit should invalidate one Native implementation rather than the whole provider; and an independent game module must register with Runtime without Runtime depending back on the game. Current generated script-to-script calls also call content-specific C++ symbols directly, so leaving an unchanged Native caller attached after changing its callee could execute old semantics.

The companion `refactor-as-incremental-function-cache` change establishes `FAngelscriptStableFunctionKey`, `FAngelscriptFunctionContentHash`, `FAngelscriptArtifactProfileKey`, and their combined `FAngelscriptFunctionArtifactIdentity` under the `as-script-artifact-identity` capability. This change consumes those value types after their identity task group lands. It does not depend on Cache V2 manifests, packs, generations, source-authority policy, or runtime reload lifecycle.

UE 5.8 provides `ILiveCodingModule::Compile()` and `GetOnPatchCompleteDelegate()`. Patch completion occurs after Live Coding's UObject reload/reinstancing work, making it a useful refresh backend, but only for modules that already belong to the active Editor target. Therefore the external module must be scaffolded and fully built once before an Editor Live Coding session, and correctness cannot depend on Live Coding succeeding.

## Goals / Non-Goals

**Goals:**

- Move generated StaticJIT ownership into a project Runtime module usable by Game and Editor.
- Match and invalidate Native entries per stable function identity/content/profile/ABI.
- Keep route state engine-owned and support multiple AS engines without FunctionId cross-contamination.
- Let exact matches execute Native in Editor/PIE while changed or missing functions execute the current VM implementation.
- Make unchanged Native callers observe the current callee rather than a stale content-specific symbol.
- Generate/update deterministic fixed buckets and explicitly refresh them through Live Coding when available.
- Prevent soft-reloaded UASFunction wrappers from retaining stale JIT entry pointers.
- Preserve deterministic cooked AOT and its direct-call optimization under a stricter immutable provider-set match.

**Non-Goals:**

- Automatic Native generation on every `.as` save.
- Running UBT, a compiler, or Live Coding at packaged end-user startup.
- Making Live Coding work on platforms/configurations where UE does not provide it.
- Removing AngelScript VM fallback.
- Reusing the NativeModuleFunctionAddress POD layout or solving its Runtime-independent pre-seal transport.
- Making structured compilation-event payloads mutable.

## Decisions

### Provider identity uses full stable hashes, never persisted FunctionId

Each generated entry is identified by:

```text
StableFunctionKey
+ FunctionContentHash selected by the provider profile
+ EntryAbiHash
+ NativeEnvironmentFingerprint
```

The provider-wide Native environment fingerprint includes platform, architecture, target/configuration, UE build/version, Unreal AngelScript runtime/fork ABI, StaticJIT generator version, bridge/layout version, compiler/toolchain identity, and debug/optimization profile. Each entry's `EntryAbiHash` additionally covers the actual bound/environment symbols used by that generated entry, using the per-symbol fingerprints supplied by `as-script-artifact-identity`. An unrelated binding change therefore does not invalidate the whole provider. Full 256-bit values are compared; any 128-bit GUID form is diagnostic display only.

AngelScript FunctionId remains a current-engine field. The route manager constructs a temporary stable-key map after each successful AS compile and never serializes that map.

Alternative rejected: preserving the current 32-bit ID and adding a module prefix. It remains collision-prone and changes when dependency hashes or compilation order change.

### The project module publishes a versioned Runtime-owned interface

Add a public Runtime header `StaticJIT/AngelscriptStaticJITArtifactProvider.h`:

```cpp
struct FAngelscriptStaticJITArtifactEntry
{
	FAngelscriptStableFunctionKey FunctionKey;
	FAngelscriptFunctionContentHash Content;
	FAngelscriptHash256 EntryAbiHash;
	asJITFunction VMEntry;
	asJITFunction_Raw RawEntry;
	asJITFunction_ParmsEntry ParmsEntry;
	const TCHAR* DiagnosticDeclaration;
};

struct FAngelscriptStaticJITProviderView
{
	uint32 StructSize;
	uint32 AbiVersion;
	const TCHAR* ProviderName;
	FAngelscriptHash256 ProviderGeneration;
	FAngelscriptArtifactProfileKey Profile;
	FAngelscriptHash256 NativeEnvironmentFingerprint;
	const FAngelscriptStaticJITArtifactEntry* Entries;
	uint32 EntryCount;
	uint32 BucketCount;
};

class IAngelscriptStaticJITArtifactProvider : public IModularFeature
{
public:
	static FName GetModularFeatureName();
	virtual bool GetProviderView(FAngelscriptStaticJITProviderView& OutView) const = 0;
};
```

The exact typedef names may use the maintained AngelScript fork's current pointer aliases, but their calling conventions and nullability are fixed by the provider ABI tests. `StructSize` and `AbiVersion` are validated before later fields are read. Runtime copies and validates the entire view synchronously; it never retains a provider-owned view pointer after `GetProviderView()` returns.

The generated module depends privately on `AngelscriptRuntime`, so using a typed Runtime-owned interface creates no cycle: project module → Runtime is legal and Runtime discovers the provider through `IModularFeatures`. This differs from NativeModuleFunctionAddress target shards, which cannot depend on Runtime and are owned by the separate pre-seal transport change.

Alternative rejected: a single static POD `ActiveInfo`. It cannot represent multiple providers/generations/engines or refresh safely after Live Coding.

### Provider catalog is process-visible; routes are engine-owned

`FAngelscriptStaticJITProviderCatalog` enumerates modular features and copies validated provider manifests. It contains no active AS function pointers and makes no selection for an engine.

Each `FAngelscriptEngine` owns `FAngelscriptStaticJITRouteManager` and an immutable `FAngelscriptStaticJITRouteSnapshot` keyed by full stable function key. Snapshot construction compares current compiled functions with validated provider entries and records exact hit or a typed miss reason:

- `MissingFunctionKey`
- `ContentMismatch`
- `ProfileMismatch`
- `EnvironmentMismatch`
- `EntryAbiMismatch`
- `ProviderAbiMismatch`
- `StaleGeneration`
- `DuplicateOrCollision`

Provider arrival, departure, AS compile handoff, and Live Coding patch complete request a refresh. Refresh builds a new snapshot off to the side, validates it completely, and publishes it only under the engine compilation/safe-point lock. Old immutable snapshots remain referenced until in-flight calls release them. Provider departure changes affected routes to VM; it does not invalidate another provider or the AS function cache.

Alternative rejected: one process-global map from FunctionId to pointer. It makes two engines share transient IDs and cannot atomically express a per-engine compile generation.

### Hot-reloadable calls use route handles

Every compiled function in the hot-reloadable profile receives an engine-owned route handle containing its stable key and an atomic reference to the current immutable route entry. Normal AS JIT entry and reflected UASFunction dispatch load through that handle.

Generated script-to-script calls in this profile emit a Runtime route invocation using the callee stable key and current call-frame shape instead of a direct content-specific implementation symbol. The invocation selects the current matching Native entry or enters the current AS VM function using the existing context/stack contract. Exceptions, return values, references, object lifetimes, virtual resolution, and debug callstack metadata must match interpreter behavior.

The route layer performs virtual/override resolution before selecting a Native entry. A missing changed callee therefore causes only that callee invocation to use VM; an unchanged Native caller remains valid.

Cooked immutable providers may emit direct script-to-script calls only when the full provider artifact-set digest and environment fingerprint match. If an immutable set is incomplete, all functions that rely on direct links are disabled as one set rather than mixed unsafely.

Alternative rejected: letting unchanged callers keep direct links in Editor. A changed callee could retain the same logical symbol and old caller semantics would be wrong. Transitive caller invalidation was considered, but route indirection preserves more function-granular reuse and gives a direct VM fallback.

### Native implementation symbols are content-addressed

Generated implementation symbols use:

```text
ASJIT_<FullStableFunctionKeyHex>_<FullFunctionContentHashHex>_<EntryKind>
```

Logical route stubs/manifest keys are stable, but implementation symbols always include content. A new body therefore creates a new symbol rather than allowing Live Coding to patch the old symbol while an old validated route still names it. Duplicate emitted symbols or truncated-hash collisions are generation failures.

### Generated code uses fixed project-module buckets

The tool derives `<ProjectName>AngelscriptStaticJIT` from the `.uproject` name and creates:

```text
Source/<Module>/<Module>.Build.cs
Source/<Module>/Private/<Module>Module.cpp
Source/<Module>/Private/Generated/Bucket_000.cpp ... Bucket_031.cpp
Source/<Module>/Private/Generated/Bucket_000.generated.inl ... Bucket_031.generated.inl
Source/<Module>/Private/Generated/Functions/<Key>_<Content>.jit.inl
Source/<Module>/Private/Generated/StaticJITProvider.generated.inl
```

The default bucket count is 32. `ReadLE64(StableFunctionKey.Bytes[0..7]) mod BucketCount` assigns a function; the StableFunctionKey is already a domain-separated BLAKE3-256 value and is not hashed again. Bucket `.cpp` files are created during scaffolding and never added during an active Live Coding session; their generated aggregators change as slices are added/removed. Changing bucket count changes the scaffold layout/provider profile and requires a full build.

Files and entries are sorted by full key/content hash. Generate writes only byte-different files through temporary-file replacement. Removed functions disappear from aggregators/manifest but old content-addressed slices may be pruned only by explicit Generate cleanup after verifying they are no longer referenced.

Alternative rejected: one translation unit per function, which creates excessive UBT/compiler overhead; and one monolithic generated `.cpp`, which rebuilds all functions after every edit.

### Scaffolding updates only structured project state

Provide a shared generator service used by commandlet and Editor action:

```text
-run=AngelscriptStaticJIT -Mode=Scaffold
-run=AngelscriptStaticJIT -Mode=Generate
-run=AngelscriptStaticJIT -Mode=Verify
```

`Scaffold` reads the project descriptor, derives the module name, creates missing owned files, and adds a Runtime/PostDefault module descriptor to `.uproject`. UE 5.8 `UEBuildTarget.SetupProjectModules()` adds all valid `.uproject` modules to Game and Editor targets, so the tool does not parse or rewrite Target.cs. It validates the generated Build.cs dependency on `AngelscriptRuntime` and reports that one full Editor/Game build is required before Live Coding can update buckets.

The tool refuses to overwrite non-owned files, validates an embedded scaffold version marker, and is idempotent for identical input. Updating an old owned scaffold writes a reviewable diff/backup manifest and never rewrites arbitrary user source.

`Generate` requires an existing valid scaffold and successful current AS compilation. `Verify` generates into a temporary directory and compares paths/content/manifest semantically without modifying source.

### Editor source compilation stays authoritative

Remove the blanket Editor skip only for the new route/provider path; do not enable the old global FunctionId database in Editor. The normal source/preprocessor compile and hot reload completes first. `GetPreGenerateClasses().Broadcast(CompiledModules)` is the attach point after AS code generation and before ClassGenerator. Structured compilation events remain read-only diagnostics.

After a save:

- current AS modules/functions are swapped according to existing hot-reload rules;
- exact provider hits attach Native routes;
- changed/missing entries attach VM routes;
- no C++ generation or Live Coding starts automatically.

### Live Coding is an explicit optional backend

The Editor `Generate/Refresh StaticJIT` action:

1. Rejects execution while AS compilation has errors or a prior generation/Live Coding request is active.
2. Generates changed slices, aggregators, and provider manifest.
3. If Live Coding is available/enabled, calls `ILiveCodingModule::Compile()`.
4. Waits for `GetOnPatchCompleteDelegate()` and verifies a newer provider generation.
5. Re-enumerates providers, builds a route snapshot, and publishes it at an engine safe point.
6. Reports generation, Live Coding result, hit/miss counts, and every rejected provider reason.

If Live Coding is unavailable, generation succeeds but routes remain VM/previous exact hits until a full build/restart. If compile/patch/provider validation fails, no new snapshot is published. The user can retry; ordinary Editor/PIE execution continues.

### Hot-reloadable UASFunction dispatch never owns stale entries

The current specialized `_JIT` wrappers cache entry pointers. In hot-reloadable profiles, wrapper selection uses variants that retain the current ScriptFunction/route handle and load the Native/VM entry at call time. Soft reload updates the ScriptFunction/route handle and does not copy old `JitFunction`, `JitFunction_Raw`, or `JitFunction_ParmsEntry` into a long-lived UFunction field.

Generic, specialized primitive/reference/object return, static/world-context, virtual, and thread-safe shapes obey the same current-route rule. Immutable cooked profiles may retain direct pointer wrappers only after complete immutable provider-set validation.

### Diagnostics use stable identities and typed results

Extend `as.StaticJIT.DumpDiagnostics` and the non-Shipping diagnostics API with provider count/name/generation, engine route generation, full/display keys, content/profile/environment hashes, entry kinds, Native/VM state, miss reason, bucket/slice path, and execution counters. Function lookup accepts canonical declaration or stable-key hex; transient FunctionId may be printed only as current-engine context.

## Risks / Trade-offs

- **Route indirection reduces Editor Native call performance** → limit it to hot-reloadable profiles; benchmark and preserve immutable direct calls for fully matched cooked sets.
- **VM fallback from generated callers has ABI/lifetime edge cases** → add parity tests for arguments, references, object returns, exceptions, virtual dispatch, and thread-safe calls before enabling Editor Native routing.
- **Live Coding registers duplicate static provider objects** → select by validated provider name/generation, reject ambiguity, and unregister on module shutdown.
- **Patch publication races active calls** → publish immutable snapshots only at engine safe points and retain old snapshots/symbols for in-flight calls.
- **Generated module is missing from the active target** → Scaffold updates `.uproject`, Verify checks UBT target discovery, and Generate explains the required first full build.
- **Public provider ABI drifts** → validate struct size/version/hash layout and update generator/Runtime/tests atomically.
- **Adjacent NativeModule transport work changes examples** → audit that active change before implementation, but keep the StaticJIT ABI independent because dependency constraints differ.

## Migration Plan

1. Consume the stable identity types from the Cache change and add provider ABI/golden layout tests.
2. Add engine-owned provider catalog/routes while retaining the old cooked test path behind test-only comparison seams.
3. Generate content-addressed entries and route hot-reloadable calls; prove per-function hit/miss and VM parity.
4. Add project-module Scaffold/Generate/Verify and convert AOT fixtures to provider registration.
5. Enable new provider routing in Editor/PIE and replace pointer-caching hot-reloadable UASFunction selection.
6. Add explicit Live Coding Generate/Refresh and safe provider-generation publication.
7. Validate Game/Editor/PIE/cooked profiles, then remove `FJITDatabase`, `ActiveInfo`, persisted FunctionId registration, DataGuid coupling, and the blanket Editor skip.
8. Update Chinese documentation first, then English plugin/build/StaticJIT guidance and final verification evidence.

During intermediate development, the VM is the rollback path. Production switches away from old global registration only after provider tests prove equivalent immutable cooked behavior.

## Open Questions

None. Module naming, bucket count, provider ownership, identity source, Editor update policy, Live Coding role, cross-call strategy, fallback behavior, and UASFunction policy are fixed by this design.
