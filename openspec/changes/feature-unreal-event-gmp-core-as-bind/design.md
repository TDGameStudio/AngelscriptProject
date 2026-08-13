## Context

The product is a small reusable event bus for native Unreal code and the maintained AngelScript integration. `D:\Workspace\UnrealEvent` provides behavior/tests but uses a process-global, name-map-based handwritten Hub; `W:\TDGame\Plugins\TD\TDEvent` provides the desired compact AS spelling but directly subclasses GMP; `Reference\GenericMessagePlugin` provides the mature Hub mechanisms to port. The new plugin must own its product surface and configuration under UnrealEvent names while deriving only the bounded GMP core required for dispatch.

V1 is synchronous and Game Thread only. It must remain deterministic during recursive mutation, safe through UObject/World/GameInstance teardown, isolated across simultaneous PIE GameInstances, explicit about its type ABI, and measurable against the native delegate baseline.

## Goals / Non-Goals

**Goals:**

- Deliver one `UnrealEvent.uplugin` with engine-only Runtime, AngelScript adapter, and Editor test modules.
- Port/adapt the GMP Hub core: SBO erased callable, signal element/store, raw borrowed-address fire, weak listeners, ordered mutation-safe dispatch, configured direct-store path, and optional Monolithic inline dispatch.
- Own one complete Hub per GameInstance and support Game, World, and Object scopes.
- Let projects select hot events in `DefaultUnrealEvent.ini` by exact FName Key and structured payload signature.
- Pre-create configured symbols and one contiguous configured Store array per GameInstance; keep unconfigured events on a dynamic route.
- Accept ordinary FName names in C++ and AS and select the configured path automatically, without a Fast API, key macro, or generated C++ file.
- Transparently specialize configured AS literal calls through reserved typed adapters without changing the public `Event::*` source spelling.
- Support deterministic Times/Order, stable handles, exact signatures, weak lifetimes, recursive mutation, Shipping-safe validation, JIT-aware callback invocation, and Hot Reload invalidation.
- Define structural performance gates and a repeatable Monolithic Shipping target at or below `1.2x` an equivalent UE native multicast delegate workload.

**Non-Goals:**

- Store/replay, Once aliases, remove-by-key, request/response, collection hubs, K2 nodes, Blueprint libraries, editor graph tooling, or call-site trace graphs.
- GameplayTag/MessageTags keys, redirects, networking, replication, asynchronous dispatch, background-thread queues, latent callbacks, or cross-process messages.
- Script closures, script-only non-`UFUNCTION` methods, output/non-const-reference callback parameters, arbitrary FFI, containers, or more than eight AS payloads.
- Configured fast signatures containing AS-defined types or unloaded Blueprint-generated types; v1 does not add two-stage AS compilation or synchronous asset loading.
- Compiling from `Reference/GenericMessagePlugin`, linking the GMP plugin, retaining GMP public/product names, or copying the GMP peripheral product layers.
- `DefaultGMPMeta.ini`, `UGMPMeta`, MessageTags settings, generated `.as` stubs, generated C++ headers/translation units, or a UBT/UHT config-codegen hook.
- A public `UNREAL_EVENT_KEY`, `SendFast`, `ListenFast`, resolved Store, SymbolIndex, or internal adapter API.

## Decisions

### One plugin contains a script-independent core and a separate AS adapter

The planned layout is:

```text
Plugins/UnrealEvent/
├── Config/DefaultUnrealEvent.ini
├── UnrealEvent.uplugin
├── LICENSE
├── NOTICE
├── SourceProvenance.md
└── Source/
    ├── UnrealEventRuntime/
    ├── UnrealEventAngelscript/
    └── UnrealEventTest/
```

`UnrealEventRuntime` depends only on Core, CoreUObject, Engine, and DeveloperSettings. It owns settings, public handles/subsystem, configured registry/router, private Hub/store/callable/signature implementation, and the erased bridge; no header includes AngelScript or GMP types. `UnrealEventAngelscript` depends on Runtime and AngelscriptRuntime and owns all AS registrations, preprocessor rewrites, generic marshalling, typed adapter contexts, UASFunction caches, and reload lifecycle. `UnrealEventTest` is Editor-only and does not depend on GMP. The project-owned performance suite stages the pinned upstream GMP plugin only into a transient, independently built comparison host; GMP never enters the deliverable plugin or normal host build graph.

The descriptor declares Angelscript required because the delivered plugin includes the adapter, while Runtime remains independently reusable. The plugin starts as a normal sibling directory because no separate remote exists.

Alternative rejected: link GMP and wrap its Hub. That retains unwanted product/config/global-store behavior and makes UnrealEvent availability depend on GMP.

### The GMP core is ported through an explicit source map

`gmp-core-port-map.md` is the design inventory. Before substantially derived source is added, plugin-owned `LICENSE`, `NOTICE`, and `SourceProvenance.md` must identify upstream commit/path/symbol, destination, retained notices, and local changes.

The implementation derives only:

- `GMPFunction.h` SBO erased/weak callable mechanics;
- `GMPSignalsImpl.*` signal element/store and raw fire mechanics;
- direct/static Key/Store concepts from `GMPMessageKey*` and `GMPHub*`;
- the bounded inline-fire decision from `GMPHubOpt.h`;
- signature safety/diagnostic separation from `GMPMacros.h`.

All GMP names, Store/Once/Request/RPC/collection paths, Meta/tag systems, Blueprint/K2 surfaces, script-backend abstractions, and tracing graphs are removed. `Reference/` is never a build input.

### Process metadata is immutable; all event state is per GameInstance

`UUnrealEventSubsystem : UGameInstanceSubsystem` owns one `FUnrealEventHub` for the GameInstance lifetime. Listener, callback, signature state, source buckets, handles, Times/Order, dynamic Stores, and configured Stores never live in a process singleton.

A process-wide `FUnrealEventConfiguredRegistry` is allowed only because it contains frozen immutable metadata derived from project configuration:

```text
FUnrealEventConfiguredRegistry
  ├── Configured Key -> SymbolIndex router
  └── Metadata[SymbolIndex]
        ├── FName Key
        ├── canonical configured signature
        ├── compact SignatureFingerprint
        └── reflected type/marshalling descriptors
```

Each subsystem constructs:

```text
UUnrealEventSubsystem
  └── FUnrealEventHub
        ├── TArray<FUnrealEventSignalStore> ConfiguredStores
        └── TMap<FName, TUniquePtr<FUnrealEventSignalStore>> DynamicStores
```

`ConfiguredStores.Num()` equals the valid frozen metadata count. `ConfiguredStores[SymbolIndex]` belongs only to that GameInstance. Registry teardown/rebuild is not supported in v1; settings require restart. Deinitialization increments the subsystem generation, invalidates every handle/token/cache that targets that Hub, and destroys all Stores.

Alternative rejected: GMP's process-unique static `FSignalStore` per Key. It violates multi-PIE isolation even if listener maps are manually partitioned.

### DefaultUnrealEvent.ini is the high-performance allowlist and signature authority

The public settings schema is:

```cpp
UENUM()
enum class EUnrealEventConfiguredTypeKind : uint8
{
    Bool,
    Int8, UInt8,
    Int16, UInt16,
    Int32, UInt32,
    Int64, UInt64,
    Float, Double,
    Name, String,
    Enum, Object, Struct,
};

USTRUCT()
struct FUnrealEventConfiguredParameter
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, Config)
    EUnrealEventConfiguredTypeKind Kind = EUnrealEventConfiguredTypeKind::Bool;

    UPROPERTY(EditAnywhere, Config)
    FTopLevelAssetPath TypePath;
};

USTRUCT()
struct FUnrealEventPerformanceEventConfig
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, Config)
    FName Key;

    UPROPERTY(EditAnywhere, Config)
    TArray<FUnrealEventConfiguredParameter> Parameters;
};

UCLASS(Config=UnrealEvent, DefaultConfig, meta=(DisplayName="Unreal Event"))
class UUnrealEventSettings final : public UDeveloperSettings
{
    GENERATED_BODY()

public:
    virtual FName GetContainerName() const override { return FName("Project"); }
    virtual FName GetCategoryName() const override { return FName("Plugins"); }

    UPROPERTY(EditAnywhere, Config, Category="Performance",
              meta=(ConfigRestartRequired=true))
    TArray<FUnrealEventPerformanceEventConfig> HighPerformanceEvents;
};
```

A representative config is:

```ini
[/Script/UnrealEventRuntime.UnrealEventSettings]
+HighPerformanceEvents=(Key="Game.Ready",Parameters=())
+HighPerformanceEvents=(Key="Player.Hurt",Parameters=((Kind=Int32),(Kind=Object,TypePath="/Script/Engine.Actor")))
+HighPerformanceEvents=(Key="Movement.Updated",Parameters=((Kind=Struct,TypePath="/Script/CoreUObject.Vector"),(Kind=Float)))
```

The INI is declarative input only. It produces frozen in-memory metadata, per-GameInstance Store slots, and AS binding registrations; it never produces a checked-in or Intermediate C++ source file.

`TypePath` must be empty for primitive/Name/String kinds. Enum/Object/Struct require an exact `/Script/Module.Type` path that resolves before AS bindings. Object paths resolve to native UClass, Struct to native UScriptStruct, and Enum to native UEnum. Exact configured type identity is used; no numeric or reflected-type coercion occurs.

At startup, all entries are independently validated. Empty Keys, duplicate Keys, invalid kind/path pairs, unresolved/wrong reflected types, unsupported types, or more than eight parameters invalidate their entries. Every entry for a duplicated Key is invalid. Valid entries are sorted lexically by Key before dense indexes are assigned.

Configured metadata is the signature authority before any operation. A configured listener is validated immediately; a configured send must match exactly and never establishes or changes its signature. Unconfigured Keys retain first-accepted-send signature establishment and provisional-listener behavior.

Editor/Development emits detailed errors, excludes invalid entries from the frozen registry, and lets those names use the dynamic route. Cook/Commandlet fails if any invalid entry exists. If invalid data reaches a non-commandlet packaged runtime, it is rejected from the configured registry rather than creating an unsafe binding.

Alternative rejected: use `DefaultGMPMeta.ini` or string-only GMP parameter names. That leaks GMP product identity and permits ambiguous aliases/module collisions.

### The native facade uses the same ordinary names and Stores

The public subsystem has one typed C++ family with this semantic shape:

```cpp
template <typename Callable>
FUnrealEventHandle Listen(FName Key, UObject* Listener, Callable&& Callback,
                          FUnrealEventListenOptions Options = {});

template <typename Callable>
FUnrealEventHandle ListenWorld(UWorld* World, FName Key, UObject* Listener,
                               Callable&& Callback, FUnrealEventListenOptions Options = {});

template <typename Callable>
FUnrealEventHandle ListenObject(UObject* Source, FName Key, UObject* Listener,
                                Callable&& Callback, FUnrealEventListenOptions Options = {});

template <typename... Args> bool Send(FName Key, Args&&... Values);
template <typename... Args> bool SendWorld(UWorld* World, FName Key, Args&&... Values);
template <typename... Args> bool SendObject(UObject* Source, FName Key, Args&&... Values);

bool Unlisten(FUnrealEventHandle Handle);
int32 UnlistenAll(UObject* Listener);
```

Implementation details may use constrained member-function/lambda overloads, but these names, ordinary FName input, explicit native World/source context, weak listener ownership, options behavior, and return semantics are the contract. The AS adapter supplies its execution context separately and calls the same Hub/Store operations. A configured native call is not a different public overload: its Key is automatically classified behind `Send`/`Listen`.

### Ordinary FName operations automatically select the route

No caller chooses a Fast API. Every C++ and generic AS operation passes FName. The frozen registry builds an immutable open-addressed router with a low maximum load factor; entries contain full FName and SymbolIndex and perform no string conversion, allocation, or mutable-map access during lookup.

```text
FName Key
  ├── configured-router hit -> ConfiguredStores[SymbolIndex]
  └── miss                  -> DynamicStores.Find/FindOrAdd(Key)
```

A configured Key passed through a variable FName reaches the configured Store and cannot create a same-name dynamic Store. Game/World/Object operations, C++ and AS, typed and generic routes all converge on the same store. The selector probe remains part of an ordinary FName route; a configured AS literal adapter bypasses it by retaining SymbolIndex in function user data.

Alternative rejected: `UNREAL_EVENT_KEY("...")`, generated named constants, or `SendFast`. They achieve a compile-time call-site identity but violate the required simple/default-name API and are unnecessary for the configured AS path.

Alternative rejected: generate `.gen.h/.gen.cpp` from config. It adds UBT ordering, stale artifact, source-control, and incremental build obligations without eliminating the need to classify an arbitrary runtime FName.

### SignalStore preserves the GMP hot-loop shape without global ownership

The private callable is a renamed, bounded derivative of GMP's SBO erased callable: common native adapters occupy inline storage, callback entry is one stored function pointer plus a Self address, and no vtable is used. Weak UObjects are checked without strong ownership. Oversized callables may allocate during registration, never during warm fire.

Each SignalStore owns the exact signature plus preordered Game, World, and Object source buckets. Registration/removal is the cold path and maintains `(Order, RegistrationSequence)` order; Send never sorts. Common dispatch snapshots use inline storage and store slot id/generation rather than copying callback objects. Heap allocation in the warm configured benchmark path is forbidden.

Raw payload ABI is synchronous borrowed addresses plus canonical descriptors. No argument address survives Send. Reflected callback buffers use property initialization/copy/destruction only when required. The direct native thunk consumes the address array without building a generic variant/message object.

`UNREALEVENT_WITH_INLINE_DISPATCH` is private, defaults to `0`, and may be effective only for supported Monolithic targets. Inline/out-of-line and modular/Monolithic paths must have identical behavior. Direct configured storage, Order, weak lifetime, and compact Shipping validation are not optional macros.

### Scope propagation is staged and deterministic

| Operation | Required context | Dispatch stages |
|---|---|---|
| `Listen` / `Send` | Current/listener GameInstance | Game only |
| `ListenWorld` / `SendWorld` | Authoritative World in current GameInstance | World, then Game |
| `ListenObject` / `SendObject` | Valid source UObject with authoritative World/GameInstance | Object, then World, then Game |

Every stage completes before the next. Within one stage, lower Order runs first and equal Order follows registration sequence. Object listeners match exact weak source identity. All scopes for a Key share one Store/signature in a Hub.

AS context comes from the active execution world when available and otherwise authoritative listener/source ownership. `GEngine->GetCurrentPlayWorld()` is forbidden. Invalid or cross-GI combinations reject instead of guessing.

### Dispatch is synchronous, snapshot-based, and mutation-safe

Every public entry checks Game Thread. Off-thread calls fail and never enqueue.

Each stage snapshots ordered slot handles. Before invocation the Store revalidates active state, slot generation, weak source/listener, scope, and signature. Therefore:

- removing a later listener prevents its current snapshot invocation;
- new registration does not enter the current outer snapshot;
- nested send sees current active state in a new snapshot;
- positive Times is consumed before callback entry, so Times=1 cannot recursively execute itself;
- callback failure does not stop later listeners or restore Times;
- dead/inactive slots compact after the Store's outermost dispatch.

Times=0 rejects, negative is unlimited, and positive values are exact budgets.

### Dynamic signatures and configured signatures share one compatibility contract

Configured Keys use their frozen exact signature. Dynamic Keys start without a signature; the first accepted Send records exact canonical argument count/types even with zero listeners. Later sends must match. Listener callbacks return void and may declare the first N exact payload types; trailing payloads may be ignored, but reordering, skipping, output/non-const-ref, return values, and implicit conversion are invalid.

Dynamic listeners registered before first Send are provisional and incompatible slots deactivate when the signature is established. Configured listeners are never provisional because the signature already exists.

The generic v1 type matrix remains bool/numeric primitives, FName, FString, enums, UObject handles, and reflected USTRUCT values. The configured subset requires startup-registered native reflected types so typed AS bindings can be registered before compilation.

### AngelScript keeps one public Event surface and reserved configured adapters

The stable AS declarations remain:

```cpp
FUnrealEventHandle Listen(FName Key, UObject Listener, FName Method,
                          int Order = 0, int Times = -1);
FUnrealEventHandle ListenWorld(FName Key, UObject Listener, FName Method,
                               int Order = 0, int Times = -1);
FUnrealEventHandle ListenObject(UObject Source, FName Key, UObject Listener,
                                FName Method, int Order = 0, int Times = -1);

bool Send(FName Key, [Arg0 ... Arg7]);
bool SendWorld(FName Key, [Arg0 ... Arg7]);
bool SendObject(UObject Source, FName Key, [Arg0 ... Arg7]);

bool Unlisten(FUnrealEventHandle Handle);
int UnlistenAll(UObject Listener);
```

Each Send family has nine public generic overloads. `__UnrealEventInternal` is a reserved implementation namespace, not a supported consumer contract. During the file-static `FAngelscriptBind` phases, before preprocessing/initial compilation, the adapter enumerates the already-frozen Runtime registry and registers typed Listen/Send functions in memory for every valid configured Key. Names use sanitized Key text plus a deterministic hash of the full canonical Key string. It emits no source files.

The declaration path MUST NOT rely on `IAngelscriptExtension::OnEngineAttached`: the maintained engine invokes that callback only after initial compilation. `UnrealEventAngelscript` module startup therefore installs the `OnPostProcessCode` hook and contributes its file-static bind records before `FAngelscriptBind::PrepareForEngineInitialization` seals the registry. Runtime module ordering freezes configuration first. A recreated AS engine replays the static bind phases and gets a fresh adapter context set; the extension owns post-attach generation/cache invalidation only.

`FAngelscriptPreprocessor::OnPostProcessCode` rewrites only syntactically valid configured FName literals: it renames the call and removes the Key argument. Unconfigured literals and variable expressions remain public generic calls. The reserved adapter user data stores SymbolIndex, configured signature, resolved AS/native types, marshalling/property operations, and engine generation. Warm typed fire bypasses configured-name routing and repeated type/property discovery.

The public source remains:

```angelscript
FUnrealEventHandle Handle =
    Event::Listen(n"Player.Hurt", this, n"OnPlayerHurt", 0, -1);
Event::Send(n"Player.Hurt", 25, Causer);
Event::Unlisten(Handle);
```

No per-Key user API, generated declaration file, SymbolIndex, Store pointer, or Fast spelling is documented or compatibility-stable.

### AS callback caches follow current engine and Hot Reload generations

Declarations use the current file-static `FAngelscriptBind` pattern; post-publication cache lifecycle uses `IAngelscriptExtension`. Slot identity remains weak Listener + Method; `UFunction`/`UASFunction` is only a cache.

Current `UASFunction::JitFunction_ParmsEntry` is used with its exact ABI when valid. Otherwise the adapter constructs/destroys the UFunction parameter buffer and calls `ProcessEvent`. On reload, module discard, engine teardown, adapter shutdown, or settings/registry generation mismatch, relevant caches are invalidated. Missing/incompatible methods deactivate once and never call stale addresses.

### Diagnostics and performance are explicit product contracts

Shipping retains compact arity/type/signature validation and safe rejection. Detailed canonical type names, source/call-site text, and verbose context compile out in Shipping. GMP's default Shipping removal of dynamic safety checks is not copied.

Structural configured-path gates are:

- public configured FName path performs no general `TMap<FName, Store>` lookup, string conversion, Store allocation, hot sort, or payload-variant construction;
- warm native configured fire performs no heap allocation;
- warm configured AS literal performs no Key routing, `PropertyFromString`, `FindFunction`, or parameter-layout discovery;
- JIT-compatible AS callback performs no `ProcessEvent`;
- dynamic fallback remains behaviorally identical even though it has name-map/generic costs.

The primary timing target is measured with a pre-resolved subsystem, Game scope, one int32 payload, eight native listeners, Monolithic Shipping, 100,000 warmups, 1,000,000 measured sends, seven rounds, and median comparison. The normal public configured `Send(FName)` path must be no slower than `1.2x` an equivalent UE native multicast delegate. The same report records pinned GMP direct/static results. AS JIT and ProcessEvent are separate measurements and do not inherit the C++ ratio gate.

## Risks / Trade-offs

- **GMP code is copied too broadly** → Enforce `gmp-core-port-map.md`, plugin provenance, architecture tests, and reject every unlisted peripheral subsystem.
- **Global configured metadata grows into global event state** → Registry types expose immutable metadata/indexes only; tests inspect ownership and run two GIs with identical SymbolIndex values.
- **Automatic FName routing misses the target** → Freeze a low-load immutable router, expose probe counters, benchmark the actual public name path, and do not substitute a private direct token for acceptance.
- **Configured and dynamic routes split one Key** → Centralize store resolution; configured-name variable/generic calls must resolve to the configured array and tests compare handle/signature identity.
- **Bad config silently loses performance** → Detailed Editor diagnostics plus dynamic fallback; Cook/Commandlet failure; restart-required frozen settings.
- **Configured type cannot exist before AS compile** → Restrict configured reflected types to startup-registered native fields; leave AS/Blueprint-generated types on dynamic generic paths.
- **Runtime accidentally depends on AngelScript/GMP** → Build.cs/include/link architecture tests; erased Runtime bridge uses UE/Core types only.
- **Recursive mutation causes duplicate/stale calls** → Preordered buckets, inline handle snapshots, immediate generation revalidation, pre-entry Times consumption, outermost compaction.
- **Hot Reload invokes obsolete code** → Weak name identity plus engine/reload generation and extension invalidation.
- **Performance benchmark is noisy** → Fixed workload/warmup/round count, median ratio, observed sink, environment record, structural counters, and separate modular/Monolithic results.
- **Shipping removes safety with diagnostics** → Compile out only verbose strings; keep compact fingerprints and fail-closed branches.

## Migration Plan

1. Record GMP provenance/port map and scaffold Runtime, AS, and Test modules without external build inputs.
2. Add `UUnrealEventSettings`, deterministic validation/freeze, automatic configured router, and per-GI configured/dynamic Store ownership through TDD.
3. Port the bounded GMP callable/SignalStore/Hub slice through allocation, raw ABI, scope, Times/Order, reentrancy, and isolation tests.
4. Implement exact configured/dynamic signatures and Shipping-safe diagnostics.
5. Implement public generic AS bindings, configured typed adapters, transparent rewrite, JIT/ProcessEvent routes, and Hot Reload invalidation.
6. Add modular/Monolithic behavior tests, configured-path counters, Shipping delegate/GMP benchmark, host All-suite entry, and Chinese-first documentation.

Rollback is disabling/removing the sibling plugin and its host test configuration. AngelscriptRuntime and the GMP reference require no data migration because neither gains a reverse dependency and no generated source is produced.

## Open Questions

None for v1. The following are explicitly deferred: Blueprint/K2 APIs, GameplayTags, Store/Request, networking, async dispatch, runtime config reload, configured AS-defined/Blueprint-generated payload types, generated named C++ wrappers, and a separate UnrealEvent remote/submodule.
