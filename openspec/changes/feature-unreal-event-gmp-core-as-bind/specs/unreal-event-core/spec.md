## ADDED Requirements

### Requirement: UnrealEvent is a self-contained sibling plugin
The repository SHALL provide `Plugins/UnrealEvent/UnrealEvent.uplugin` containing `UnrealEventRuntime`, `UnrealEventAngelscript`, and `UnrealEventTest`. Runtime SHALL depend only on Core, CoreUObject, Engine, and DeveloperSettings and MUST NOT include or link GMP or AngelScript. The AS adapter SHALL depend on Runtime and AngelscriptRuntime, and the descriptor SHALL declare Angelscript required.

#### Scenario: Runtime dependency graph is inspected
- **WHEN** descriptor, Build.cs, include, compile, and link inputs are inspected
- **THEN** Runtime has no GMP or AngelScript dependency
- **AND** only the AS/Test modules cross the AngelScript boundary

#### Scenario: Reference repositories are unavailable
- **WHEN** `Reference/GenericMessagePlugin`, `D:/Workspace/UnrealEvent`, and `W:/TDGame` are absent from compiler search paths
- **THEN** UnrealEvent compiles exclusively from plugin-owned source
- **AND** no Build.cs input points into a reference checkout

### Requirement: The bounded GMP Hub-core port is attributable and auditable
Any source copied or substantially derived from GMP SHALL identify commit `85283fbec0edba1a04c1cff8181455c5d97ba60a`, preserve Apache-2.0 obligations, and record upstream path/symbol, destination, and local modifications. The implementation MUST remain within the disposition recorded by `gmp-core-port-map.md` unless that record is updated before the source change.

#### Scenario: Derived core source is reviewed
- **WHEN** a reviewer selects a file identified as derived from GMP callable, signal, Key-slot, or Hub code
- **THEN** plugin `LICENSE`, `NOTICE`, and `SourceProvenance.md` identify the pinned source and destination
- **AND** the local summary explains the per-GameInstance and product-surface adaptations

#### Scenario: Peripheral GMP code is searched
- **WHEN** shipped source and APIs are scanned for GMPMeta, MessageTags, K2, Store/Once, request/response, RPC, collections, or other script-backend code
- **THEN** none of those areas is present in Runtime
- **AND** no GMP product name remains in public UnrealEvent APIs/configuration

### Requirement: UnrealEvent owns a dedicated structured performance configuration
Runtime SHALL provide `UUnrealEventSettings : UDeveloperSettings` with `Config=UnrealEvent`, `DefaultConfig`, Project/Plugins placement, and restart-required `HighPerformanceEvents`. Settings SHALL persist in `Config/DefaultUnrealEvent.ini` under `/Script/UnrealEventRuntime.UnrealEventSettings` and MUST NOT read or emit `DefaultGMPMeta.ini` or MessageTags configuration.

Each entry SHALL contain one non-empty FName Key and zero through eight structured parameter descriptors. Supported kinds SHALL be Bool, signed/unsigned 8/16/32/64-bit integers, Float, Double, Name, String, Enum, Object, and Struct. Enum/Object/Struct SHALL require an exact startup-registered native `/Script/Module.Type` path of the matching reflected category; other kinds SHALL require an empty TypePath.

#### Scenario: Valid configured event is loaded
- **WHEN** `DefaultUnrealEvent.ini` declares `Player.Hurt` with Int32 and native Object parameters
- **THEN** settings expose the entry in Project Settings → Plugins → Unreal Event
- **AND** startup resolves one exact configured signature before listeners or sends

#### Scenario: Unsupported configured type is declared
- **WHEN** a configured parameter names a container, non-UObject pointer, AS-defined type, unloaded Blueprint-generated type, unresolved path, or reflected field of the wrong category
- **THEN** the entry is invalid
- **AND** no partial configured symbol or typed binding is published for it

#### Scenario: Configuration is changed in Editor
- **WHEN** a user edits `HighPerformanceEvents`
- **THEN** the setting indicates restart is required
- **AND** the frozen registry is not live-rebuilt in v1

### Requirement: Configuration validation is deterministic and fail-safe
Startup SHALL independently validate entries, invalidate every participant in a duplicate Key, sort valid Keys lexically, assign dense SymbolIndex values from zero, and compute exact canonical signatures and compact fingerprints. One invalid entry MUST NOT disable another valid Key.

Editor/Development SHALL report invalid entries and route their Keys dynamically. Cook/Commandlet SHALL fail when any configured entry is invalid. A non-commandlet packaged runtime receiving invalid data SHALL exclude it from the configured registry rather than constructing an unsafe Store.

#### Scenario: Duplicate Key entries exist
- **WHEN** two or more settings entries declare the same FName Key
- **THEN** every duplicate entry is invalid and no first/last precedence is used
- **AND** Editor routes that Key dynamically while Cook fails validation

#### Scenario: Valid input order changes
- **WHEN** the same valid configured Keys are stored in a different INI array order
- **THEN** lexical sorting produces the same SymbolIndex order and signature fingerprints

#### Scenario: One invalid and one valid entry exist
- **WHEN** Editor loads an invalid `Bad.Event` and valid `Good.Event`
- **THEN** `Good.Event` retains its configured route
- **AND** `Bad.Event` uses the dynamic route with a detailed diagnostic

### Requirement: Configured metadata is global-only metadata and event state is per GameInstance
A frozen process-wide registry MAY own only configured Key, SymbolIndex, signature fingerprint, and immutable type/marshalling metadata. `UUnrealEventSubsystem` SHALL derive from `UGameInstanceSubsystem`, own one Hub, and construct one contiguous configured SignalStore for each valid SymbolIndex. Listener, signature mutation, handle, Times, Order, source, callback, and Store state MUST NOT be process-global or shared across GameInstances.

#### Scenario: Two GameInstances use one configured SymbolIndex
- **WHEN** two PIE/GameInstances listen and send the same configured Key
- **THEN** both use the same immutable metadata index but different per-GI SignalStores
- **AND** listener, handle, Times, Order, scope, and teardown state remain isolated

#### Scenario: A GameInstance shuts down
- **WHEN** its subsystem deinitializes
- **THEN** its generation changes, handles/tokens/caches targeting it become invalid, and all its Stores are released
- **AND** immutable registry metadata remains unable to reach the retired listeners

### Requirement: Ordinary FName operations automatically select configured or dynamic storage
Every public C++ and generic script core operation SHALL accept FName and automatically resolve the Store. A frozen low-load immutable router SHALL map configured full FNames to SymbolIndex without string conversion, allocation, or general `TMap<FName, Store>` access; misses SHALL use the owning Hub's dynamic Store map. The public API MUST NOT require `UNREAL_EVENT_KEY`, generated Key constants, Fast-suffixed methods, generated C++ source, or a caller-visible SymbolIndex/token.

`UUnrealEventSubsystem` SHALL provide typed C++ `Listen`, `ListenWorld`, `ListenObject`, `Send`, `SendWorld`, `SendObject`, `Unlisten`, and `UnlistenAll` families. Native World/source contexts SHALL be explicit. Listen SHALL weakly associate a UObject listener with a direct typed callable and Order/Times options; Send SHALL accept zero through eight exact payload arguments and return whether the operation was accepted, even when no listener matches. These families and the erased AS bridge SHALL converge on the same Hub/Store.

#### Scenario: Configured Key is sent through normal C++ API
- **WHEN** C++ calls the ordinary `Send` with a configured FName variable
- **THEN** the router selects `ConfiguredStores[SymbolIndex]`
- **AND** no same-name dynamic Store is created

#### Scenario: Native typed listener receives a configured event
- **WHEN** C++ registers a weak UObject listener and direct compatible callable through ordinary `Listen`
- **AND** ordinary `Send(FName, Values...)` is accepted for that configured Key
- **THEN** the callable receives the exact compatible payload prefix without ProcessEvent
- **AND** its handle, Order, Times, and removal state belong only to the current subsystem

#### Scenario: Unconfigured Key is sent
- **WHEN** ordinary `Send` receives a valid Key absent from configuration
- **THEN** the current Hub creates or finds its dynamic Store
- **AND** the event remains fully functional without a configuration entry

#### Scenario: Build inputs are inspected for config code generation
- **WHEN** plugin source, generated directories, UBT/UHT hooks, and build actions are inspected
- **THEN** no UnrealEvent config-to-`.h`/`.cpp` generator or generated Key wrapper is required

### Requirement: Event scopes propagate in fixed stages
The core SHALL support Game, World, and Object listener scopes. Game is local to one GameInstance. `Send` SHALL dispatch only Game listeners, `SendWorld` SHALL dispatch World then Game listeners, and `SendObject` SHALL dispatch exact-source Object then World then Game listeners.

#### Scenario: Game event is sent
- **WHEN** `Send` accepts a Key and payload
- **THEN** matching Game listeners run
- **AND** World and Object listeners do not run

#### Scenario: World event is sent
- **WHEN** `SendWorld` accepts an authoritative World, Key, and payload
- **THEN** matching listeners for that exact World run before matching Game listeners
- **AND** Object listeners do not run

#### Scenario: Object event is sent
- **WHEN** `SendObject` accepts a source, Key, and payload
- **THEN** exact-source Object listeners run before its World listeners
- **AND** World listeners complete before Game listeners

#### Scenario: Same Order spans multiple scopes
- **WHEN** Object, World, and Game listeners have equal Order
- **THEN** stage order remains Object, World, Game
- **AND** registration sequence orders listeners only within each stage

### Requirement: Context resolution is authoritative and Game Thread only
All registration, send, and removal entries SHALL execute synchronously on the Game Thread. Game/World context MUST come from an explicit Runtime context, the active AS execution context, or authoritative source/listener ownership and MUST NOT use `GEngine->GetCurrentPlayWorld()`.

#### Scenario: Operation is called off the Game Thread
- **WHEN** a public operation is invoked off-thread
- **THEN** it rejects with a diagnostic
- **AND** it does not enqueue or mutate state

#### Scenario: Source and context disagree
- **WHEN** an Object operation supplies a source from another GameInstance
- **THEN** the operation is rejected
- **AND** neither Hub gains listener/signature state

#### Scenario: No authoritative context exists
- **WHEN** a Game or World operation cannot resolve an active GameInstance/World
- **THEN** it fails without consulting an ambient editor play world

### Requirement: Handles and UObject ownership are weak and generation-safe
Every successful registration SHALL return an opaque `FUnrealEventHandle` identifying its weak owning subsystem, slot id, and generation. Listener and Object-source ownership SHALL be weak. Default, stale, foreign-Hub, and removed handles MUST NOT remove an active unrelated slot.

#### Scenario: Active handle is removed
- **WHEN** `Unlisten` receives the current active handle
- **THEN** it deactivates exactly that slot and returns true
- **AND** later sends do not invoke it

#### Scenario: Slot storage is reused
- **WHEN** removed storage is reused by a later registration
- **THEN** the later slot has a new generation
- **AND** the old handle cannot affect it

#### Scenario: Listener or source dies
- **WHEN** a weak listener or Object source becomes invalid before/during dispatch
- **THEN** its slot is skipped and compacted safely
- **AND** no stale UObject/callback pointer is invoked

#### Scenario: All registrations for one listener are removed
- **WHEN** `UnlistenAll` receives a valid listener
- **THEN** it removes that listener's Game, World, and Object slots in the same Hub
- **AND** it returns the exact count without affecting others

### Requirement: Times and Order are deterministic under recursive mutation
Within each stage, lower Order SHALL execute first and equal Order SHALL follow monotonically increasing registration sequence. Registration SHALL maintain this order so Send performs no sorting. `Times=0` MUST reject, negative Times SHALL be unlimited, positive Times SHALL decrement before callback entry, and dispatch SHALL snapshot slot handles using inline storage for the common path and revalidate immediately before invocation.

#### Scenario: Ordered listeners are dispatched
- **WHEN** Orders `-10`, `0`, `0`, and `20` are registered in sequence
- **THEN** invocation order is `-10`, first `0`, second `0`, `20`
- **AND** dispatch performs no listener sort

#### Scenario: Times-one callback recursively sends
- **WHEN** a Times=1 listener sends the same event from its callback
- **THEN** its budget reaches zero before the nested send
- **AND** it is not invoked recursively

#### Scenario: Later snapshot listener is removed
- **WHEN** an earlier callback removes a later handle
- **THEN** immediate revalidation skips the later slot

#### Scenario: Listener is added during dispatch
- **WHEN** a callback adds a listener without nested send
- **THEN** it is absent from the current snapshot
- **AND** it is eligible on the next send

#### Scenario: Nested send observes current state
- **WHEN** a callback removes one listener, adds another, and sends recursively
- **THEN** the nested snapshot excludes the removed and includes the added slot
- **AND** the outer snapshot never invokes an inactive slot

### Requirement: Configured and dynamic signatures follow one exact compatibility contract
Each Key SHALL have one signature across all scopes in one Hub. A configured Key SHALL use the frozen project signature before any operation and MUST NOT change it. An unconfigured Key's first accepted Send SHALL establish exact argument count/types even without listeners. Later sends MUST match exactly. A callback SHALL return void and declare an exact prefix of the payload.

#### Scenario: Configured listener registers before first send
- **WHEN** a compatible listener registers for a configured Key
- **THEN** it is validated immediately against the configured signature
- **AND** it is not provisional

#### Scenario: Configured send mismatches
- **WHEN** a configured Key receives a different count or canonical type
- **THEN** the send is rejected without changing metadata or Store signature
- **AND** no listener runs

#### Scenario: Dynamic first send has no listeners
- **WHEN** a valid unconfigured two-argument send occurs first
- **THEN** it is accepted and records both canonical types
- **AND** later mismatch is rejected

#### Scenario: Compatible callback ignores trailing values
- **WHEN** signature is `(int32, AActor, FName)` and callback declares `(int32, AActor)`
- **THEN** registration succeeds and receives only the prefix

#### Scenario: Provisional dynamic listener conflicts
- **WHEN** a dynamic provisional listener conflicts with the first valid send
- **THEN** the send establishes its signature and continues to compatible listeners
- **AND** the incompatible slot is diagnosed and deactivated

### Requirement: The GMP-derived erased fire path is synchronous and non-owning
The Runtime bridge SHALL pass borrowed argument addresses plus exact canonical descriptors for one synchronous Send. Signal slots SHALL use a bounded SBO erased thunk with no callback vtable on the hot path. No payload address may be retained and no variant/message object may be required by configured native fire. Reflected buffers SHALL use correct UE construction/copy/destruction.

#### Scenario: Common native callable is registered
- **WHEN** the callable fits the configured inline capacity
- **THEN** registration stores it inline with one erased thunk and Self address
- **AND** warm dispatch allocates no heap memory

#### Scenario: Reflected struct is dispatched
- **WHEN** a supported USTRUCT value reaches multiple reflected listeners
- **THEN** every listener observes the correct value
- **AND** required temporaries have balanced construction/destruction

#### Scenario: Send returns
- **WHEN** callbacks finish or none match
- **THEN** no Store/slot retains an argument address

#### Scenario: Subsystem generation expires a resolved route
- **WHEN** a private cached route is used after subsystem deinitialization/generation change
- **THEN** it rejects without dereferencing retired Store storage

### Requirement: Callback failures are isolated
A callback failure SHALL be diagnosed without preventing later active snapshot listeners from running. A positive Times budget consumed before entry MUST remain consumed.

#### Scenario: First callback reports an exception
- **WHEN** the first of three listeners fails
- **THEN** the second and third remain eligible in deterministic order
- **AND** the failed listener's finite Times is not restored

### Requirement: Shipping retains safety while verbose diagnostics compile out
Invalid thread, context, Key, source, listener, handle, callback, count, and signature operations SHALL fail safely. Development/Editor diagnostics SHALL include Key, scope, expected/actual types, and callback/source context. Shipping SHALL retain compact arity/type/fingerprint checks and rejection while removing detailed type names and call-site text.

#### Scenario: Development signature mismatch occurs
- **WHEN** a later send uses a mismatched type
- **THEN** the diagnostic identifies Key, scope, argument index, expected type, and actual type
- **AND** no callback runs

#### Scenario: Shipping implementation is inspected
- **WHEN** Runtime is compiled for Shipping
- **THEN** compact mismatch branches remain active
- **AND** guarded verbose type/call-site strings are absent

### Requirement: Configured dispatch has structural and timing performance gates
The warm configured public FName path SHALL avoid general Store TMap lookup, string conversion, Store allocation, hot sorting, payload-variant construction, and heap allocation for the benchmark's common listener/snapshot sizes. Instrumentation SHALL prove those structural facts.

The primary benchmark SHALL use a pre-resolved subsystem, Game scope, one Int32 payload, eight native listeners, Monolithic Shipping, 100,000 warmups, 1,000,000 measured sends, seven rounds, and median ratio. The ordinary configured `Send(FName)` median MUST be no slower than `1.2x` an equivalent UE native multicast delegate. The same report SHALL record the pinned GMP direct/static route without making GMP a Runtime dependency.

#### Scenario: Warm configured path is instrumented
- **WHEN** the configured benchmark runs after warmup
- **THEN** general Store-map lookup, string conversion, Store allocation, dispatch sort, reflected-name resolution, and hot heap-allocation counters remain zero

#### Scenario: Primary Shipping benchmark completes
- **WHEN** the seven-round delegate/configured/GMP workload runs under the specified environment
- **THEN** the configured public FName median ratio is at most `1.2x` native delegate
- **AND** raw measurements, environment, counters, and GMP comparison are stored under the change benchmarks directory
