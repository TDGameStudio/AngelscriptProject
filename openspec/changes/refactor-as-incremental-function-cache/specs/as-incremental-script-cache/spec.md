## ADDED Requirements

### Requirement: Cache V2 is logically segmented and physically packed

The Runtime SHALL represent six reusable semantic record kinds—source indexes, module interfaces, type schemas, module state, function bodies, and debug sidecars—as independent versioned content-addressed records. A content-addressed ModuleSnapshot assembly record SHALL bind one complete module activation from those records. The Runtime MUST aggregate multiple records into bounded immutable pack files and MUST NOT require one file per function, type, global, or module.

#### Scenario: One function body is updated

- **WHEN** a changed FunctionBody is published while other module/type/state/function records remain valid
- **THEN** the new generation references the existing unchanged records and packs
- **AND** only new content requires new pack bytes

#### Scenario: Store contents are inspected

- **WHEN** a project contains thousands of cached functions
- **THEN** the physical store consists of generation manifests and aggregated packs
- **AND** it does not contain one independent filesystem file for every function

### Requirement: Module activation is atomic

The Runtime MUST assemble each active module from one validated ModuleInterface, its ordered TypeSchema records, one ModuleState, ordered FunctionBody records, optional DebugSidecars, and dependency metadata. It MUST complete imports, globals, dependency checks, module swap, and ClassGenerator/reflection validation before publishing that ModuleSnapshot as active.

#### Scenario: One referenced record is invalid

- **WHEN** any required TypeSchema, ModuleState, FunctionBody, dependency, or stable reference fails validation
- **THEN** no partial form of that ModuleSnapshot mutates the active engine
- **AND** the planner compiles a safe miss closure or fails the transaction

#### Scenario: Complete module restore succeeds

- **WHEN** every referenced record resolves against current declarations/environment and ClassGenerator validation succeeds
- **THEN** the complete module transaction becomes active atomically

### Requirement: Exact source snapshots bypass preprocess parse and compile

The cache service SHALL discover and content-hash the complete configured loose-source inventory, including additions and deletions. When SourceIndex, profile, environment dependencies, and ModuleSnapshots match exactly, it SHALL restore eligible modules without invoking the preprocessor, parser, or function compiler.

#### Scenario: Second unchanged launch

- **WHEN** source bytes, source inventory, settings, compatible environment symbols, and cache schema are unchanged after a successful launch
- **THEN** eligible modules restore from matching ModuleSnapshots
- **AND** preprocess, parse, and function-compiler invocation counters are zero
- **AND** no replacement generation is written solely for that launch

#### Scenario: A new source file appears

- **WHEN** a loose `.as` file is added under a configured source root
- **THEN** the complete SourceIndex no longer matches
- **AND** the affected source/module closure enters preprocess and planning

### Requirement: Changed modules retain unchanged function bodies

When a SourceIndex or module input changes, the Runtime SHALL preprocess/parse only the affected closure, compute each candidate `FunctionInputDigest` before compilation, attach validated hits, and invoke the compiler only for misses. It MUST include ordinary functions, methods, constructors, destructors, factories, generated default constructors, and `__InitDefaults`.

#### Scenario: One body changes without structural change

- **WHEN** one function body changes and all other declarations, type schemas, module state, options, and actual dependencies remain equal
- **THEN** exactly that FunctionBody is a compile miss
- **AND** the other FunctionBodies remain hits at their existing content coordinates

#### Scenario: Formatting changes only

- **WHEN** comments or whitespace change source/debug mapping without changing execution inputs
- **THEN** the affected module may be reparsed and DebugSidecar updated
- **AND** execution FunctionBodies remain eligible hits

### Requirement: Type schemas invalidate structural dependency closure

Class, struct, interface, enum, delegate, inheritance, property, method declaration, trait, metadata, reflection, and layout information SHALL be persisted in TypeSchema records. A TypeSchema change MUST invalidate the owning ModuleSnapshot and every dependent module/entity selected by existing structural dependency semantics.

#### Scenario: Property is added to a script class

- **WHEN** a script class gains a reflected or runtime property
- **THEN** its TypeSchema and owning module assembly change
- **AND** structural dependents enter the required invalidation closure
- **AND** unrelated modules remain eligible hits

#### Scenario: Method body changes but class shape does not

- **WHEN** a method implementation changes without changing its declaration or class layout
- **THEN** the TypeSchema remains reusable
- **AND** invalidation is limited to the affected FunctionBody and actual dependencies

### Requirement: Globals and initializer order are one module-state cache unit

The Runtime SHALL persist globals, constants, enum values, global storage layout, initializer bytecode/order/dependencies, post-init functions, and hard-value dependency metadata as one ModuleState record per module. V1 MUST NOT independently activate a subset of global initializer artifacts.

#### Scenario: Global initializer changes

- **WHEN** one global value or initializer changes
- **THEN** the owning ModuleState is a miss
- **AND** the module's complete global dependency-solving pass is rebuilt
- **AND** hard-value dependent modules enter the required closure

#### Scenario: Function body changes without global dependency change

- **WHEN** an ordinary function body changes and ModuleState inputs remain equal
- **THEN** ModuleState remains a cache hit

### Requirement: Invalidation uses typed semantic dependencies

The planner MUST distinguish source/include/preprocessor, declaration/signature, type/property layout, global/hard-value, import, compile option, debug mapping, and environment-symbol ABI dependencies. It SHALL produce deterministic hit/miss reasons and the minimum complete closure that preserves correctness.

#### Scenario: Function signature changes

- **WHEN** a function's signature, owner, qualifiers, or traits change
- **THEN** its logical key and ModuleInterface change
- **AND** callers/importers referring to the old declaration enter the miss closure

#### Scenario: Unrelated binding changes

- **WHEN** a bound symbol not named by any record in a module changes
- **THEN** that module remains eligible for cache hits

#### Scenario: Include changes

- **WHEN** a shared include or preprocessor input changes
- **THEN** SourceIndex identifies the affected source/module closure
- **AND** entity-level comparison is applied after preprocessing rather than blindly invalidating every module

### Requirement: Cache V2 is a Saved-only immutable generation store

The cache service SHALL store profile/context namespaces only under `Saved/Angelscript/CacheV2/<CompatibilityKey>/<ContextKey>/`. Each namespace MUST contain immutable content-addressed packs, immutable generation manifests, and atomic Current/Previous pointers; it MUST NOT require a packaged Cache V2 baseline.

#### Scenario: First launch has no cache namespace

- **WHEN** a valid loose source tree starts without a matching Cache V2 namespace
- **THEN** source compiles normally
- **AND** a successful transaction publishes the first Saved generation
- **AND** the process continues rather than exiting for cache generation

#### Scenario: Compatibility or context differs

- **WHEN** compiler/bytecode ABI, platform, target, configuration, preprocessor settings, or source mounts select another compatibility/context key
- **THEN** the service uses a distinct namespace
- **AND** it neither consumes nor deletes incompatible namespaces

### Requirement: Generation publication is atomic and recoverable

The writer MUST publish new immutable pack data and a validated generation manifest before atomically replacing Current. It MUST retain a valid Previous generation and readers MUST observe one immutable generation for an entire read session.

#### Scenario: Process stops during pack or manifest write

- **WHEN** cancellation, crash, or shutdown occurs before Current is replaced
- **THEN** the previous Current remains selected on the next launch
- **AND** incomplete temporary files are never accepted as records

#### Scenario: Two processes publish concurrently

- **WHEN** two engines target the same store
- **THEN** writers serialize through a store-path system-wide lock
- **AND** the later writer rereads/rebases Current before publication
- **AND** readers never observe a half-published generation

### Requirement: Cache preparation is bounded parallel and deterministic

The service SHALL use bounded worker tasks for source scanning/hashing, manifest/pack I/O and validation, decompression, pure hit planning, digest preparation, compression, and pack construction. Current-engine declaration creation, reference attachment, globals, module swap, ClassGenerator, and active generation selection MUST remain serialized on the owning lifecycle.

#### Scenario: Serial and parallel output are compared

- **WHEN** identical generation input is prepared in forced-serial and normal bounded-parallel modes
- **THEN** record ordering, hashes, manifest bytes, pack indexes, pack bytes, and generation ID are identical

#### Scenario: Worker completion order changes

- **WHEN** workers complete in different or randomized orders
- **THEN** output order still derives from canonical full keys
- **AND** no worker mutates the active engine

#### Scenario: Multiple engines read one store

- **WHEN** two engines open immutable cache data concurrently
- **THEN** they may share file bytes
- **AND** their FunctionId routing, module state, cancellation, diagnostics, and reload state remain engine-owned and isolated

### Requirement: Loose source is authoritative over stale cache

A cache generation SHALL be eligible only when its SourceIndex exactly matches the discovered source snapshot or after the changed source has successfully compiled into a new transaction. If changed current source fails fresh-start compilation, the system MUST NOT activate a different-source previous generation as fallback.

#### Scenario: Fresh packaged startup has invalid changed source

- **WHEN** loose source differs from Current and fails parsing, compilation, or ClassGenerator validation
- **THEN** no new generation is published
- **AND** stale cached script behavior is not activated
- **AND** packaged initialization exits with a failure result

#### Scenario: Editor fresh startup has invalid changed source

- **WHEN** Editor source differs from Current and initial script compilation fails
- **THEN** Editor exposes an explicit AngelScript initialization failure state
- **AND** it does not activate the stale different-source scripts

#### Scenario: Hot reload fails after a valid module is active

- **WHEN** an Editor or enabled runtime reload attempt fails
- **THEN** the currently active last-good module remains active
- **AND** Current is not advanced to the failed source generation

### Requirement: Editor and PIE continuously maintain Cache V2

Every successful Editor initial compile, soft reload, or full structural reload SHALL capture immutable artifacts and schedule generation preparation. The service MUST publish Current only after the corresponding active module/ClassGenerator transaction succeeds.

#### Scenario: Editor body hot reload succeeds

- **WHEN** a code-only script edit successfully soft reloads
- **THEN** the new FunctionBody and updated ModuleSnapshot are prepared asynchronously
- **AND** a valid generation becomes Current without waiting for Editor shutdown

#### Scenario: Structural reload succeeds outside PIE

- **WHEN** a class/property/signature change completes full reload and reinstancing outside PIE
- **THEN** Current advances only after ClassGenerator and reflected type replacement succeed

#### Scenario: Structural source is compiled during PIE

- **WHEN** a structural edit is valid for a fresh engine but cannot safely replace active PIE instances
- **THEN** active Current remains aligned with the live PIE modules
- **AND** the compiled artifacts may be published only as PendingColdStart
- **AND** PendingColdStart is promoted only by a later successful cold/full transaction

### Requirement: Shutdown performs a bounded flush without late compilation

`FAngelscriptEngine::Shutdown()` MUST ask its Cache service to flush completed/prepared work before releasing AngelScript engine data. It SHALL wait no longer than the configured timeout and MUST NOT discover, preprocess, or compile unprocessed source during shutdown.

#### Scenario: Pending write completes before timeout

- **WHEN** Editor or game shutdown begins with a prepared valid generation
- **THEN** the generation is committed before engine data is released

#### Scenario: Flush exceeds timeout

- **WHEN** cache preparation/write does not finish within the default 5-second shutdown timeout
- **THEN** known work and temporary files are cancelled/cleaned
- **AND** the previous committed generation remains valid
- **AND** shutdown continues without compiling source

### Requirement: Packaged runtime reload is configurable and code-only

The plugin SHALL provide `Disabled`, `Manual`, and `Automatic` runtime reload modes, with `Disabled` as the default. Manual and automatic requests MUST run through one game-thread safe-point pipeline. A packaged live reload SHALL activate only code-only soft changes and SHALL return `RequiresRestart` for structural changes.

#### Scenario: Runtime reload is disabled

- **WHEN** Blueprint, C++, or console requests a reload under the default Disabled mode
- **THEN** the request returns `Disabled`
- **AND** no source scan or active module change occurs

#### Scenario: Code-only runtime reload succeeds

- **WHEN** Manual or Automatic mode discovers a valid body-only change
- **THEN** the change is applied through the existing soft-reload transaction
- **AND** the result is `AppliedCodeOnly`
- **AND** successful cache records are published

#### Scenario: Runtime structural change is discovered

- **WHEN** a signature, property, inheritance, class/global layout, interface, delegate, enum, or structural dependency changes while a packaged process is live
- **THEN** the result is `RequiresRestart`
- **AND** old modules remain active
- **AND** the attempted structural generation is not published as Current

#### Scenario: Automatic mode is enabled in a packaged target

- **WHEN** Automatic mode is configured
- **THEN** Runtime periodically content-hashes loose source using the configured interval
- **AND** it does not depend on the Editor DirectoryWatcher module

### Requirement: Runtime reload and cache controls are exposed through stable APIs

The Runtime SHALL expose reload mode, request status, reload outcome, and result types to C++ and Blueprint; `UAngelscriptSubsystem` SHALL expose `RequestRuntimeReload()` and a completion delegate. It SHALL also expose `as.ReloadScripts`, `as.Cache.Status`, `as.Cache.Flush`, `as.Cache.Verify`, and `as.Cache.Compact` console commands.

#### Scenario: Blueprint queues a manual reload

- **WHEN** Blueprint calls `RequestRuntimeReload()` while Manual mode is idle
- **THEN** it receives `Queued`
- **AND** the completion delegate later reports `NoChanges`, `AppliedCodeOnly`, `RequiresRestart`, `CompileFailed`, or `Cancelled` with module and cache diagnostics

#### Scenario: Flush command is used by package smoke

- **WHEN** `as.Cache.Flush` is executed after startup compilation
- **THEN** it waits for valid prepared cache work to commit or reports a typed failure
- **AND** shutdown can follow without losing an already completed generation

### Requirement: Cache settings have safe deterministic defaults

`UAngelscriptCacheSettings` MUST be an Engine default-config object with incremental cache enabled, runtime reload Disabled, automatic scan interval 1.0 second, and shutdown flush timeout 5.0 seconds unless explicitly configured otherwise.

#### Scenario: Project provides no cache settings

- **WHEN** Editor, Development, or Shipping starts without project overrides
- **THEN** Cache V2 reads/writes are enabled
- **AND** packaged runtime live reload remains disabled
- **AND** shutdown uses the 5-second bounded flush

### Requirement: Cache data is validated before allocation and engine mutation

The loader MUST validate magic, schema, profile/context, integer arithmetic, counts, offsets, stored/raw lengths, codecs, checksums, canonical order, duplicate/conflicting keys, dependency kinds/targets, logical root containment, and configured memory budgets before resolving records into active engine objects. It MUST NOT deserialize native pointers, UObjects, function addresses, vtables, FName indices, or numeric FunctionIds.

#### Scenario: Pack range is out of bounds

- **WHEN** a manifest references bytes outside a pack or arithmetic overflows
- **THEN** that generation is rejected before allocating the declared payload or resolving stable references

#### Scenario: Current generation is corrupt

- **WHEN** Current or one of its required packs fails validation
- **THEN** the loader may use a source-snapshot-matching valid Previous or PendingColdStart generation
- **AND** otherwise compiles matching current source
- **AND** it never treats corruption as permission to execute different-source stale behavior

### Requirement: Legacy PrecompiledScript cache has no production path

After Cache V2 becomes active, the plugin MUST NOT read, migrate, dual-write, or silently fall back to `PrecompiledScript.Cache`, random `DataGuid` pairing, old pointer maps, or persisted numeric FunctionIds. `Binds.Cache` SHALL remain independently supported.

#### Scenario: Only a legacy script cache exists

- **WHEN** source is present, Cache V2 is missing, and `PrecompiledScript.Cache` exists
- **THEN** the legacy file is ignored/rejected with a precise diagnostic
- **AND** current source compiles and writes Cache V2

#### Scenario: Legacy file is found in a package

- **WHEN** packaged validation inspects staged files
- **THEN** it fails the package/smoke check as an obsolete script artifact
- **AND** `Binds.Cache` remains accepted

### Requirement: Diagnostics prove incremental behavior with stable identifiers

The service SHALL provide a deterministic diagnostic snapshot and optional JSON report containing compatibility/context/profile, source snapshot, generation before/after, record/module/type/state/function hit and miss counts, typed reasons, preprocess/parse/compiler calls, bytes read/written, validation/fallback/publication result, reload outcome, and stage timings. Persistent ordering and identifiers MUST use full stable keys.

#### Scenario: One body edit is reported

- **WHEN** a fixture changes exactly one function body
- **THEN** the report shows one FunctionBody compile miss
- **AND** unchanged TypeSchema and ModuleState records remain hits
- **AND** no process address is used as a persistent identifier

#### Scenario: Exact warm launch is reported

- **WHEN** an unchanged source snapshot restores successfully
- **THEN** the report shows zero preprocess, parse, and compiler calls
- **AND** the generation remains unchanged

### Requirement: Unreachable content is reclaimed outside startup

Normal startup and incremental publication MUST NOT rewrite valid packs solely to remove unreachable records. Explicit compaction SHALL copy only records reachable from Current, Previous, and eligible PendingColdStart manifests into a new atomic store state.

#### Scenario: Function is renamed or deleted

- **WHEN** a generation no longer references an old FunctionBody
- **THEN** the immutable old pack remains available while retained manifests reference it
- **AND** explicit compaction can later remove it after reachability validation

#### Scenario: Startup sees unreachable packs

- **WHEN** the store contains packs not reachable from retained manifests
- **THEN** startup does not block on compaction
