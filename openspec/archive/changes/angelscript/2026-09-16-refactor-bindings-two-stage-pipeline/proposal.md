## Delivery boundary

This delivery creates the Change and its planning artifacts only. Product implementation, provider migration, renaming, instrumentation, builds and Automation are future unchecked tasks. The user's instruction to implement the accepted plan authorizes creating these documents, not executing the product tasks described by them.

## Why

The reconstructed Runtime already records bindings without a script engine and installs detached metadata into explicitly owned engines. Its current organization still exposes the old execution phases to providers, requires a declaration prepass, mixes recording and immediate engine operations in FAngelscriptBinds, and concentrates template, reflection, delegate and native behavior in one installation class.

The recorded surface is also stronger than the demonstrated executable surface. Template members are skipped when constructing functions; concrete container operations do not prove VM-callable container methods. Delegate subscriptions retain ungoverned external storage addresses, payload callbacks retain references into a mutable array across ProcessEvent, and native prevalidation accepts descriptive recipes that the connector cannot execute. Type adapter registration records a name while TypeFinder callbacks are discarded in recording mode; the per-engine adapter database is not automatically reconstructed by that route.

These gaps need explicit behavioral acceptance alongside the structural refactor. A single engine-free binding database, complete type providers, independently registered extensions and an observable installation pipeline give the new and dormant legacy systems a controlled migration boundary.

## What Changes

1. Expose exactly two main phases: Record produces a sealed FAngelscriptBindingDatabase; Install consumes it to produce one engine-owned FAngelscriptBindingInstance. Internal synchronization and validation steps do not become extra provider authoring phases.
2. Record each built-in type through one primary Register function. It supplies the type definition, lifecycle, properties, methods, adapter/native descriptions and effects together. Resolve references after collection rather than executing declaration providers before member providers.
3. Preserve external function/lambda registration. Extensions can add members and provide native targets, including future UHT-generated targets. Keep contribution origin separate from call transport and validate enrichment of an existing member explicitly.
4. Separate immutable semantic descriptions from process-local host target storage and retained reflection. Support reuse within one process; executable disk persistence is not part of this Change.
5. Assign AS declaration semantics, canonical identity, generic template substitution, metadata ownership and publication invariants to the SDK. Keep UE exposure policy, reflection capture, scheduling and concrete native/UE adaptation in the integration layer.
6. Complete adapter/TypeFinder reconstruction, callable template specialization, delegate storage ownership, reentrant payload lifetime and executable-target validation. Every repair has actual execution and cleanup acceptance.
7. Support Serial and Parallel modes for recording and detached metadata preparation, with explicit task-local output and barriers. Initial default remains Serial. Measure contention and real wall-clock benefit before any subsequent default-policy change; final image attachment remains a controlled transaction.
8. Split the framework into Registration, Recording, Metadata, Runtime, Adapters and Diagnostics; organize built-in registration under Core, Math, Containers, Objects and Engine. Publish only the extension-facing headers. Rename classes by responsibility and retain bounded compatibility shims for dormant consumers.
9. Measure phase time, work counts, memory ownership/capacity and temporary peaks; integrate CPU scopes, counters and LLM/Memory Insights evidence. Collect a current baseline and paired serial/parallel results rather than treating historical whole-test durations as phase measurements.

## Success criteria

- Every eligible current Runtime provider and independently expected member is accounted for after the complete, batched migration. Reflection generators may produce multiple types, but each resulting type has one primary definition and explicit supplemental contributions.
- A provider executes once per capture, irrespective of how many engines later consume its database. External extension lambdas retain a familiar registration model.
- Record creates no engine or engine-associated runtime type/function objects. Installing a database never reruns its providers or rescans reflection.
- Serial and Parallel modes expose equivalent declarations, diagnostics, call transport and observable results. Completion order cannot choose an overload or override.
- Real VM execution proves template methods and constructors/destructors; real host callbacks prove delegate cleanup and reentrancy; adapter lookup and property conversion work after automatic installation.
- Missing executable targets fail before native engine allocation. One immutable preparation can create multiple Engines with independent mutable installation state. Failed publication leaves no usable partial owner.
- A shared database counts once in memory reports. Shared BindInfo/database records are charged once; uniquely materialized TypeInfo, per-Engine indexes and mutable adapters are charged to each receiving Engine, and measured owned resources return to their documented baseline after release.
- Default startup and disabled legacy tests remain dormant throughout migration.

## Capabilities

### New Capabilities

- `angelscript/bindings/extensions`: provider/lambda extension, immutable capture generations, contribution identity and native transport enrichment.
- `angelscript/bindings/observability`: binding phase/work/memory accounting, optional UE tracing and reproducible measurements.

### Modified Capabilities

- `angelscript/bindings/runtime`: complete two-phase records, deterministic optional concurrency, executable template members and installation-ready native targets.
- `angelscript/runtime/binding-engine`: shared immutable preparation, automatic adapter reconstruction, explicit delegate storage/subscription ownership and stable reentrant execution.

## Impact

Planning changes belong only to this directory in the parent repository. Future implementation belongs to the Plugins/Angelscript submodule: AngelscriptRuntime integration/framework/providers, the maintained Source/AngelscriptRuntime/angelscript SDK, AngelscriptTest/NewVersion tests, the existing BindingInspection tools, and the necessary include/build wiring. Source/AngelscriptProject stays minimal. Other plugin consumers receive only compatibility/include adaptations when enumerated by the migration task; their business bindings are not added to the Runtime coverage claim.

The existing `angelscript/feature-delegates-ue-interop` owns new delegate language and broader Blueprint/cooked integration. This Change repairs the already implemented binding bridge only. `angelscript/feature-memory-gc-observability` owns general allocator/GC observation; this Change owns binding phases and binding-owned resource measurements and does not introduce a second global allocator or collector policy.

## Non-goals and transition policy

No restoration of legacy startup, BindDatabase cache loading, old Register* engine mutation, or the disabled legacy test pool. No disk/cooked binding cache, UHT generator implementation, JIT backend rewrite, live alteration of an already published engine, independent SDK binary/module extraction, or wholesale merge from the reference worktree. New registration after a capture participates in a later capture and fresh engine.

Keep necessary legacy symbols as isolated forwarding/adaptation boundaries until their consumers are migrated. Remove the declaration-prepass bridge and phase-dependent authoring from the new Runtime path before this Change completes; retained dormant compatibility code is not a supported alternate product path. Commit, integration, push and workspace deletion remain separate actions.

## SDK prerequisite

The completed ownership predecessor is `openspec/archive/changes/angelscript/2026-09-11-feature-types-explicit-ownership/` (UID `change_6f58d4ea-1ff3-48f6-8680-df1b32635270`). Its source-hashed handoff describes that historical snapshot, including the subsequently deleted Image helper. The completed `2026-09-12-refactor-sdk-compile-lifecycle` archive supersedes that helper with `asCModuleDefinitionSet`; do not run the old source hashes as a current acceptance gate.

The shared object is sealed BindInfo/database records and process publication IDs. Each installation materializes distinct TypeInfo/Function objects on a unique DefinitionSet and transfers them to its receiving Engine through current registration. `asCTypeIdRegistry` issues numeric IDs only; it is not a shared TypeInfo owner or an Engine-admission bypass. No `asCMetadataImage`, `Registry.Register(Image)` or cross-Engine TypeInfo pointer sharing is reintroduced.

Task 0.1 owns current binding-consumer adaptation and a fresh small two-Engine proof before migration baseline 1.1. It must produce current source/binary evidence, not reuse archived pass counts. The existing store-input `FAngelscriptEngine::CreateForBindings` overload is the consumed API; the named PreparedBindings wrapper below is a future product of task 2.4 and retains immutable records/recipes only.
