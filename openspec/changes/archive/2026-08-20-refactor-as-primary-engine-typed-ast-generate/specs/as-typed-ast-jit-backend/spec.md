## MODIFIED Requirements

### Requirement: TypedASTJIT generation uses a complete side-effect-free source build

Matching-profile Editor Generate SHALL consume the primary Engine's complete compiled graph without creating another Engine. `"typed-ast"` matching Generate SHALL consume verified HIR from that primary Engine. Non-matching Editor Generate and isolated commandlet Generate SHALL create exactly one generation-only `FAngelscriptEngine` for that target profile, replay the complete sealed Bind collection into that Engine, compile the complete Provider source graph exactly once from source, and perform ClassGenerator descriptor analysis without materializing script reflection. A `"typed-ast"` generation Engine SHALL enable typed-HIR capture; a `"bytecode"` generation Engine SHALL not. In both paths the immutable backend input SHALL expose the full result as `CompiledSourceGraph` and carry a separate `EmitModuleSet`. `FAngelscriptTypedASTJIT` MUST NOT trigger compilation itself, create another Engine beyond the path above, or read/write a serialized HIR dump file.

#### Scenario: Reflected scripts are compiled for generation

- **WHEN** the source graph declares UCLASS, USTRUCT, delegate, UPROPERTY, and UFUNCTION surfaces
- **THEN** `CompiledSourceGraph` resolves descriptors, function roots, receivers, signatures, shared Entry Plans, artifact dependencies, and external native-call descriptors
- **AND** a generation Engine creates no script UClass, UScriptStruct, UDelegateFunction, UFunction, CDO, class redirect, reload, or reinstancing state
- **AND** matching-profile Editor Generate reads already-existing primary reflection and does not create additional script UClass/CDO state

#### Scenario: Isolated Engine has a complete native type surface

- **WHEN** a generation Engine's TypedASTJIT source compilation resolves a native bound type or callable
- **THEN** that declaration and its native-call metadata come from the complete target-profile Bind replay into that process's `asIScriptEngine`
- **AND** existing native UE reflection is observed rather than recreated or rebound as new `UClass` objects
- **AND** classification does not call `GetDefaultObject()` when doing so would create a CDO
- **AND** a route that cannot be proven from already-existing reflection fails closed rather than materializing reflection state

#### Scenario: Complete graph is compiled but selected modules are emitted

- **WHEN** one generation request selects a subset of modules from a Provider source domain
- **THEN** Bind, overload, import, global, and helper semantics come from one complete target-profile compiled graph
- **AND** Provider packaging emits only `EmitModuleSet`

#### Scenario: Isolated compile purpose suppresses runtime and editor services

- **WHEN** a generation Engine is initialized for a TypedASTJIT artifact request
- **THEN** it does not attach DebugServer, CodeCoverage/crash extensions, Hot Reload watchers/threads, script test discovery, post-engine bootstrap delegates, runtime Provider refresh/publication, or writable BindDB/cache publication into a live Editor
- **AND** Cache V2 ExactStartup may restore TypedHIR sidecars but MUST NOT substitute dump files for HIR

#### Scenario: Matching-profile Generate does not create a temporary Engine

- **WHEN** Editor Generate requests the primary Engine target profile
- **THEN** orchestration does not construct `EAngelscriptEnginePurpose::StaticJITGeneration`
- **AND** HIR, when the backend is `"typed-ast"`, comes from primary function-owned verified IR or ExactStartup-restored sidecars

#### Scenario: Primary package and global state remain externally owned

- **WHEN** matching-profile Generate or a generation Engine compiles, analyzes, emits, or finishes
- **THEN** it does not acquire or sweep shared `/Script/Angelscript` or `/Script/AngelscriptAssets` package ownership on the live Editor
- **AND** it does not clear or replace `GBlueprintEventsByScriptName`, Editor class caches, primary route/module/type registries, global descriptor caches, or pooled contexts owned by another Engine

#### Scenario: Successful generation releases only request-owned state

- **WHEN** synchronous analysis, emission, and packaging succeed
- **THEN** destroying the generation Engine releases only that Engine/modules/functions/types, generation-local contexts, descriptor/HIR arenas, and explicitly request-owned database/snapshot state
- **AND** matching-profile Editor Generate leaves the primary Engine alive, with HIR intact when capture is on
- **AND** primary Engine packages, registries, caches, routes, UObjects, delegates, worlds, and contexts are observably unchanged except owned Provider files

#### Scenario: Failed generation has the same containment boundary

- **WHEN** Bind replay, source compilation, HIR verification, descriptor analysis, backend emission, or packaging fails
- **THEN** every early-exit path applies the same request-owned cleanup boundary as successful completion
- **AND** before/after containment snapshots show no primary package, registry, cache, route, UObject, delegate, world, or pooled-context mutation

#### Scenario: Isolated generation Engine is destroyed

- **WHEN** synchronous generation-Engine analysis/emission and Provider packaging finish
- **THEN** all generation-owned HIR, type/function objects, descriptors, and Engine-local IDs are destroyed with that Engine
- **AND** output retains only stable identity, stable references, generated C++, provenance, and diagnostics

### Requirement: Editor TypedASTJIT refresh is freshness-gated and does not compile the primary Engine

An Editor Generate/Refresh action SHALL treat current primary-Engine source state as a read-only prerequisite for the matching profile. Matching-profile Generate SHALL read that state after it is current and SHALL NOT force-clean, compile, reload, reinstance, or create a generation Engine as part of that matching request. Non-matching profiles SHALL use sequential contained generation Engines in the Editor or in a commandlet process.

#### Scenario: Current Editor state requires no extra compile

- **WHEN** the primary Engine's authoritative source inventory, content identity, and target profile are current
- **THEN** matching-profile Generate/Refresh emits from that compiled graph
- **AND** no primary-Engine compile/reload occurs before or after emit

#### Scenario: Stale Editor state is rejected without mutation

- **WHEN** the primary Engine source state is stale or its profile cannot be proven current
- **THEN** Generate/Refresh returns `AuthoritativeEngineStale` and directs the caller to the existing normal Hot Reload/recompile path
- **AND** it does not call `ForceCleanCacheModules`, clear primary compiler caches, create a generation Engine, or begin Provider packaging

#### Scenario: Commandlet source request is isolated authority

- **WHEN** a non-Editor Commandlet performs an explicit StaticJIT artifact request for one source domain and concrete profile
- **THEN** that request is authoritative for its isolated invocation and uses exactly one contained Engine in that process
- **AND** it does not initialize or mutate a live Editor primary Engine merely to establish freshness
