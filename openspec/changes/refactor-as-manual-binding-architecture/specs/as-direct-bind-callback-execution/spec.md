## ADDED Requirements

### Requirement: Bind files self-register direct callback metadata

The system SHALL let a bind source file declare one or more file-static `FAngelscriptBind` objects. Each object SHALL have a required logical name, required `EAngelscriptBindPhase`, and non-capturing `void(*)(FAngelscriptBinds&)` callback. Construction SHALL automatically capture owner module and call-site source location, append one compact record to the single process collection, and SHALL NOT access reflection, BindDB, a subsystem, an AngelScript engine, or an engine-owned store.

#### Scenario: File declares an ordinary manual bind

- **WHEN** `Bind_FVector.cpp` constructs `Bind_FVector` with phase `ExplicitBindings`
- **THEN** the process collection contains its name, phase, module, source, and callback pointer
- **AND** construction does not execute the callback or call an AngelScript registration API

#### Scenario: File owns several phases

- **WHEN** one source file needs type declaration, ordinary method registration, and finalization work
- **THEN** it declares separate `FAngelscriptBind` objects with `TypeDeclarations`, `ExplicitBindings`, and `Finalization`
- **AND** the file does not submit those binds through `StartupModule()` or a central manifest

#### Scenario: Outer callback captures state

- **WHEN** an author attempts to use a capturing outer lambda as the `FAngelscriptBind` callback
- **THEN** the source does not satisfy the required function-pointer signature
- **AND** supported callable capture inside a specific binding API remains governed by that API's ownership contract

#### Scenario: Provider lambda and runtime callable have separate roles

- **WHEN** a production `Bind_<Name>.cpp` uses a non-capturing lambda as its file-static `FAngelscriptBind` callback and registers a project-owned runtime callable
- **THEN** the outer lambda remains a metadata-discovered provider executed during engine binding
- **AND** the runtime callable is a stable named `FAngelscript<Name>Binds` function rather than an inline lambda at the AS registration call site
- **AND** no function-level callable record is added to the process collection

### Requirement: The subsystem finalizes one global collection without storing it

`UAngelscriptSubsystem` SHALL load every generated module listed by `BindModules.Cache` on the Game Thread and SHALL then request one idempotent validate/sort/seal operation on the existing global bind collection before primary-engine binding begins. The subsystem SHALL NOT own a bind array, pointer view, expanded registration data, or a copy of the collection.

#### Scenario: Generated modules load before seal

- **WHEN** subsystem initialization begins and `BindModules.Cache` lists generated binding modules
- **THEN** all listed modules load before collection finalization
- **AND** their file-static `FAngelscriptBind` records participate in the same sort and seal

#### Scenario: Subsystem initializes the primary engine

- **WHEN** collection finalization succeeds
- **THEN** the subsystem proceeds to primary-engine initialization
- **AND** it does not retain a binding collection member after coordinating the transition

#### Scenario: Compatibility bootstrap has no subsystem

- **WHEN** the supported RuntimeModule compatibility path initializes without `GEngine`
- **THEN** it uses the same idempotent module-load/finalize operation
- **AND** no second process bind collection is created

#### Scenario: Native bind arrives after seal

- **WHEN** static/native module code attempts to append another bind after finalization
- **THEN** the append is rejected with module, name, phase, source, and restart-required context
- **AND** no late replay, rebuild, or already-published-engine mutation occurs

### Requirement: Seven explicit phases replace integer bind order

Every `FAngelscriptBind` SHALL explicitly select exactly one of `TypeDeclarations`, `TypeInfrastructure`, `ExplicitBindings`, `GeneratedBindings`, `ReflectionBindings`, `PostReflectionBindings`, or `Finalization`. The collection SHALL sort by that fixed phase order and then by stable owner module, logical name, source file, and source line. Stable identity SHALL be exactly `(OwnerModule, BindName, Phase)`; source file and line SHALL remain ordering tie-breakers and diagnostics only. The completed architecture SHALL NOT contain integer `BindOrder`, `FAngelscriptBinds::EOrder`, `Early` / `Normal` / `Late` offsets, author priorities, or dependency strings.

#### Scenario: Manual callback declares a phase

- **WHEN** an author declares a callback containing ordinary methods and properties
- **THEN** the `FAngelscriptBind` constructor explicitly receives `ExplicitBindings`
- **AND** the phase is visible at the source declaration site

#### Scenario: Ordinary legacy callback mixes responsibilities

- **WHEN** a legacy callback contains a non-template type declaration and ordinary methods that can be installed after type completion
- **THEN** migration splits it into at least a `TypeDeclarations` bind and an `ExplicitBindings` bind in the owning source file
- **AND** neither replacement uses an integer order

#### Scenario: Template callable surface must precede specialization

- **WHEN** an AngelScript template may be specialized by another provider before `ExplicitBindings`
- **THEN** its object declaration remains in `TypeDeclarations` and its required constructor, method, behaviour, and template-callback surface is installed by a separate `TypeInfrastructure` bind
- **AND** stable semantic bind names order template completion before the owning type-adapter/finder contribution without adding a dependency or priority API

#### Scenario: Same-phase registration is permuted

- **WHEN** native static construction or module load discovers same-phase binds in different orders
- **THEN** the finalized collection has the same module/name/source order
- **AND** engine execution does not depend on discovery order

#### Scenario: Stable identity is duplicated

- **WHEN** two records have the same owner module, logical bind name, and phase
- **THEN** collection finalization fails before engine initialization
- **AND** different source locations do not make the duplicate identity legal

#### Scenario: Reflection-derived callable synthesis is scheduled

- **WHEN** function-library mixins or actor/component/subsystem helpers require completed reflection data and continue registering script methods
- **THEN** they execute in `PostReflectionBindings`
- **AND** `Finalization` performs no new type, function, method, or property registration

#### Scenario: Migration exposes an irreducible dependency

- **WHEN** a producer/consumer relationship cannot be expressed by phase selection, callback splitting, or merging tightly coupled same-phase operations
- **THEN** the case is recorded for a separate OpenSpec
- **AND** this implementation does not add an integer, priority, `Requires`, `Before`, or `After` escape hatch

### Requirement: Every full engine directly executes the sealed callbacks

For each full `FAngelscriptEngine` creation, `BindScriptTypes()` SHALL construct one `FAngelscriptBinds` bound to that explicit engine and SHALL directly execute every sealed callback in finalized order. Execution SHALL NOT copy or re-sort the global collection and SHALL NOT construct or retain an expanded registration representation.

#### Scenario: First engine binds successfully

- **WHEN** a full engine reaches `BindScriptTypes()` after collection seal
- **THEN** each callback receives an `FAngelscriptBinds&` targeting that engine
- **AND** its registration calls immediately mutate that engine's `asIScriptEngine` and engine-owned stores

#### Scenario: Second engine is created

- **WHEN** another full engine is initialized in the same process
- **THEN** it replays the same sealed callbacks without copying or sorting the collection
- **AND** it creates fresh AS ids, objects, and auxiliary state rather than reusing the first engine's results

#### Scenario: Dump code inspects binding state

- **WHEN** state dump or diagnostics reads bind metadata
- **THEN** it observes the sealed record collection and stored per-engine execution results
- **AND** it does not invoke a callback or synthesize registration work

### Requirement: Direct callback execution fails closed

`FAngelscriptBinds` SHALL check direct registration outcomes and retain the first required failure with provider, phase, source, declaration/target, and AngelScript diagnostic. After that failure, later registration calls in the callback SHALL NOT mutate the target, later providers SHALL NOT run, and the partial engine SHALL NOT be published.

#### Scenario: AngelScript rejects a method declaration

- **WHEN** a direct `Method` call returns an AngelScript error
- **THEN** the explicit binding context records the active provider, phase, source, declaration, and error
- **AND** execution stops before the next provider
- **AND** `PostInitialize_GameThread()` does not publish the engine

#### Scenario: Bound-result trait follows a failed registration

- **WHEN** a failed function registration produces an invalid `FAngelscriptBoundFunction`
- **THEN** subsequent fluent operations preserve the first failure and do not mutate another function
- **AND** no implicit previous-function fallback is used

#### Scenario: Compatible type declaration already exists

- **WHEN** a type or enum registration returns `asALREADY_REGISTERED`
- **THEN** the result is accepted only after the existing declaration's kind, size, flags, and other applicable compatibility fields are verified
- **AND** duplicate function, method, property, or global registration remains a failure unless the provider probes and skips before registration

### Requirement: Generated and reflection paths use direct callbacks where module dependencies permit

UHT `NativeRuntimeLinked`, editor CodeGen, and reflection binding sources SHALL converge on file-static or runtime-owned direct callbacks assigned to `GeneratedBindings`, `ReflectionBindings`, or `PostReflectionBindings`. Generated module `StartupModule()` implementations SHALL NOT submit bindings. NativeModuleFunctionAddress target shards SHALL retain their Runtime-independent POD/`IModularFeatures` transport in this change, while their Runtime consumer SHALL use explicit engine access where it intersects the new facade.

#### Scenario: Runtime-linked shard is generated

- **WHEN** UHT emits a RuntimeLinked shard
- **THEN** generated source contains a file-static `FAngelscriptBind` in `GeneratedBindings`
- **AND** its callback directly consumes the generated table for the explicit engine
- **AND** its already-named generated thunks do not require hand-written `_Functions.h/.cpp` companions

#### Scenario: Native module function-address shard is generated

- **WHEN** UHT emits a NativeModuleFunctionAddress shard
- **THEN** its generated POD payload and native binding layout remain byte-for-byte compatible
- **AND** its target UE module does not gain a dependency on `AngelscriptRuntime`
- **AND** the existing `IModularFeatures` arrival/unload bridge remains covered until `refactor-as-native-module-binding-preseal-transport`

#### Scenario: Generated CodeGen module starts

- **WHEN** an editor CodeGen-produced module loads
- **THEN** its file-static callback has already appended its record
- **AND** its `StartupModule()` performs no bind submission

#### Scenario: Reflective fallback handles RPC

- **WHEN** a generated direct thunk is ineligible or the UFunction is RPC/Net
- **THEN** `ReflectionBindings` preserves `BlueprintCallableReflectiveFallback`
- **AND** direct native binding does not bypass Unreal RPC routing

### Requirement: Runtime filtering is absent and direct providers have no dynamic lifecycle

The completed architecture SHALL NOT expose runtime disabled-bind settings, per-engine callback filters, dependency-cascade skip behavior, provider aliases, registration handles, unregister, collection leases, direct-provider module unload replay, or an in-process direct-callback rebuild. A direct source/plugin change SHALL require rebuild and process restart. NativeModuleFunctionAddress is the single documented dynamic-transport exception in this change.

#### Scenario: User removes a source-provided binding

- **WHEN** a source consumer no longer wants a binding
- **THEN** they edit or remove the source provider and rebuild
- **AND** no runtime disable configuration is evaluated

#### Scenario: Provider module requests unload

- **WHEN** a module owning callback/native addresses attempts to unload after seal
- **THEN** binding lifecycle reports the unsupported lifetime
- **AND** no callback is unregistered or replayed into existing engines

#### Scenario: NativeModuleFunctionAddress provider changes lifecycle state

- **WHEN** the retained native-module transport publishes or withdraws its POD payload
- **THEN** its existing `IModularFeatures` behavior remains unchanged
- **AND** no other direct callback provider adopts that exception

### Requirement: Diagnostics report finalization and direct execution

Development/test diagnostics SHALL expose collection finalization status and each engine's ordered provider execution. Records SHALL include owner module, logical name, source, phase, status, actionable failure context, and publication result; timing-enabled builds SHALL additionally include callback duration, per-phase totals, and top-N callbacks.

#### Scenario: State dump observes a successful engine

- **WHEN** dump capture runs after successful initialization
- **THEN** it lists the sealed provider identities in deterministic phase order
- **AND** it reports the engine's execution/publication status without a second binding-data model

#### Scenario: Stats summarize slow callbacks

- **WHEN** binding stats are enabled
- **THEN** logs report top-N provider callback durations and totals for all seven phases
- **AND** no build/apply-node timing category is emitted
