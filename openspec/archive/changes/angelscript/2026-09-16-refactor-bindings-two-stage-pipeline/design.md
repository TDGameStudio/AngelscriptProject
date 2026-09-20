# Two-stage Runtime binding design

## Status and inputs

This is an accepted planning design, not implemented behavior. Read proposal.md for authorization and exclusions, tasks.md for execution state, and attachments/INDEX.md for evidence. The starting plugin commit is `7f26e86451a5857fb7096fb4321743f51ac22dd0`; the pre-existing Bind_FName.cpp working edit is not owned by this delivery. Current source observations are distinguished from target APIs below.

## 1. Two public stages

```text
Built-in primary providers       External extension lambdas / native batches
             |                                  |
             +------------- Registry -----------+
                               |
RECORD                         v
  Snapshot provider list, target policy and required UE reflection on GameThread
                               |
  Execute each eligible provider once -> independent record fragments
                               |
  Merge -> canonical references -> stable order -> validate -> seal
                               |
                    BindingDatabase (shared const)
                    + semantic descriptions
                    + separate retained HostTargets
                               |
INSTALL                        v
  Prepare all nominal types -> dependency/layout completion -> members/templates
                               |
  Resolve executable targets -> validate -> freeze PreparedBindings
                               |
  Reuse prepared records -> unique definitions per Engine -> register -> native -> adapters
                               |
                    BindingInstance (one engine)
```

Input snapshotting and record finalization are internal steps of Record. Metadata preparation, attachment and publication are internal steps of Install. There is no third provider phase and no replay of Record callbacks during Install.

The database owns copied semantic values and a separate immutable host-target table. Records contain binding target IDs, native signature facts and lifetime categories; no asCObjectType, asCScriptFunction, engine IDs, live adapter instances or mutable host state. HostTargets holds process-local native entries/factories, borrowed global storage contracts and retained reflection. Database immutability does not freeze external UObject state. Code/borrowed global storage must outlive every consumer; module unloading while such targets are retained is outside this Change.

One capture result is reusable within its process. It is not an executable disk format. The canonical semantic dump excludes addresses and execution order; host target IDs are not promises of persistence across builds.

## 2. SDK and integration boundary

| Owner | Inputs and responsibilities | Explicit boundary |
| --- | --- | --- |
| Maintained AS SDK | Declaration parsing, canonical identity, type-use substitution, unique DefinitionSet materialization and transfer into the receiving Engine, native ABI validation and atomic engine publication | No Runtime provider catalogue, UClass exposure decisions, ProcessEvent, UE container implementation or delegate storage policy |
| UE Recording framework | Provider identities, policies, UE snapshots, fragments, merge, source precedence, target inventory and diagnostics | Never instantiate/query an AS engine; consume SDK parsing/identity instead of a second AS parser |
| UE Metadata/Installer | Project descriptions translated to SDK metadata and typed native requests; task scheduling, reusable preparation and exact-owner installation | Do not write legacy SDK fields around the protected metadata API or duplicate SDK type/layout semantics |
| UE Runtime/Adapters | UProperty/UFunction conversion, UObject lifetimes, typed C++ calls, UE templates, delegate subscriptions and owner-local caches | SDK receives explicit types and executable call requests; UE behavior remains in the plugin |
| UE Registry | Complete primary descriptions and policy for concrete exposed APIs | Generic framework does not contain World/collision/provider-specific convenience methods |

The SDK is currently built inside AngelscriptRuntime and already uses UE foundation types. This Change establishes semantic/code boundaries without pretending it is a standalone binary or purging all UE container dependencies. Generic metadata memory/count snapshots may be SDK APIs; binding LLM categories and exporters are host responsibilities. Existing generic allocation integration is adapted only where required to preserve binding attribution, never replaced with a new allocator.

## 3. Public model and names

These are target interfaces to implement, not claims about existing declarations:

```cpp
enum class EAngelscriptBindingExecutionMode : uint8 { Serial, Parallel };
enum class EAngelscriptProviderThreadPolicy : uint8 { GameThread, SnapshotOnly };
enum class EAngelscriptBindingContribution : uint8 { Primary, Extension, Generated, Reflection };
enum class EAngelscriptBindingSection : uint8 { Type, Lifecycle, Property, Function, Adapter, Effect };
enum class EAngelscriptBindingCallTransport : uint8 { NativeDirect, NativeThunk, UFunction, MetadataOnly };

using FAngelscriptBindingCallback = void (*)(FAngelscriptBindingContext&);

// Registration accepts a function or captureless lambda, as the existing static pattern does.
FAngelscriptBindingRegistration(
    FName OwnerModule, FName ProviderName,
    FAngelscriptBindingCallback Callback,
    EAngelscriptProviderThreadPolicy ThreadPolicy = EAngelscriptProviderThreadPolicy::GameThread);

static bool FAngelscriptBindingRecorder::Capture(
    const FAngelscriptBindingRegistry& Registry,
    const FAngelscriptBindingCaptureOptions& Options,
    TSharedPtr<const FAngelscriptBindingDatabase>& OutDatabase,
    FAngelscriptBindingDiagnostic& OutDiagnostic);

static bool FAngelscriptBindingInstaller::Prepare(
    TSharedRef<const FAngelscriptBindingDatabase> Database,
    const FAngelscriptBindingInstallOptions& Options,
    TSharedPtr<const FAngelscriptPreparedBindings>& OutPrepared,
    FAngelscriptBindingDiagnostic& OutDiagnostic);
```

`CaptureOptions` owns effective target/reflection policy, execution mode, optional worker limit and an optional provider-module allowlist. With no allowlist, capture admits all eligible registered Runtime and external extension providers; it does not inherit the old Runtime-only filter that would silently drop extensions. Explicit module exclusions have recorded dispositions. `InstallOptions` owns execution mode and optional worker limit; policy comes from the database, never ambient settings. Both default to Serial; worker limit zero means the available UE task worker count. Diagnostics carry public phase, internal step, stable symbol, provider/module and source, plus deterministic reason/category.

`FAngelscriptBindingContext` owns a provider-local builder, current source and namespace, and read-only capture inputs. `ValueType<T>(Name)`, `ReferenceType(Name)`, `EnumType(Name)` and `ExtendType(Name)` return a `FAngelscriptTypeBindingBuilder`; `Method`, `Property`, `Constructor`, `Destructor`, `Adapter`, `TypeFinder` and `ToString` append typed descriptions. Function/property modifiers update that builder's own record in place rather than repeatedly copying entire member records. Reference-only `ExtendType` needs no already-created type handle; unresolved names reject during merge/finalization.

`FAngelscriptBindingDatabaseBuilder` owns mutable fragments and finalization. `FAngelscriptBindingDatabase` exposes const type/member/provider/target views and semantic lookup after sealing. `FAngelscriptBindingHostTargets` is a separate immutable storage component retained by the database; descriptions refer to entries through validated typed IDs. Database construction is private to its builder.

`FAngelscriptBindingValidator::Validate` performs read-only structural and executable-descriptor readiness checks using the same target admission code as Prepare; it creates no throwaway definitions. Task 2.4 introduces the proposed shared const `FAngelscriptPreparedBindings` wrapper over database/HostTargets, record mappings, validated native request descriptions and adapter recipes. It contains no TypeInfo, Function or shared DefinitionSet. Prepare resolves immutable recipes once; each Install uniquely materializes its DefinitionSet/TypeInfo and independent mutable state, then registers with the receiving Engine. Keep the existing full-capture/store-input CreateForBindings forms and add the proposed prepared-input overload in 2.4. Validate required descriptors and materialization prerequisites before native Engine allocation. A failed attempt destroys only its unpublished owner and leaves shared records usable.

| Existing name | Final responsibility/name |
| --- | --- |
| FAngelscriptBind / FAngelscriptBindCollection | FAngelscriptBindingRegistration / FAngelscriptBindingRegistry |
| FAngelscriptTypeBindInfoRecorder | FAngelscriptBindingRecorder |
| FAngelscriptBinds | FAngelscriptBindingContext plus type/member builders; legacy immediate operations isolated |
| FAngelscriptTypeBindInfoStore | FAngelscriptBindingDatabase plus private FAngelscriptBindingDatabaseBuilder |
| FAngelscriptTypeBindInfoCatalog | Transitional declaration bridge; removed from the new path after migration |
| FAngelscriptTypeBindInfoDraft | FAngelscriptBindingMetadataBuilder; preparation ownership is explicit |
| FAngelscriptTypeBindInfoApply / Installation | FAngelscriptBindingInstaller / FAngelscriptBindingInstance |
| FAngelscriptType / TypeDatabase | FAngelscriptTypeAdapter / FAngelscriptTypeAdapterRegistry for new consumers |
| FAngelscriptTypeBindInfoInspection / Validation | FAngelscriptBindingInspector / FAngelscriptBindingValidator |
| FAngelscriptBindDatabase | Dormant legacy reflection-cache implementation; not an alias or serializer for the new database |

Use `FAngelscriptTypeBindingDesc`, `FAngelscriptMemberBindingDesc`, `FAngelscriptBindingSource` and `FAngelscriptNativeTargetDesc` for the principal data records. Do not mechanically rename every old Bind-family type or create wrapper classes without a distinct owner. Keep necessary old include/API shims explicitly indexed until dormant consumers can be retired.

## 4. Primary providers and extensions

The Registry is an appendable, synchronized provider catalogue. Each successful registration advances a generation. Capture takes an immutable copy under its registry lock; callbacks run after the lock is released. A registration made during/after a capture appears only in a later capture. Reject duplicate `(OwnerModule, ProviderName)` identity and keep the original catalogue intact. Neither capture nor old collection sealing permanently prevents new external registrations.

One built-in type has one primary Register function, including its lifecycle and ToString contribution. A reflection generator can emit many types; it supplies a fallback primary only where no explicit primary exists. Module/global service providers have their own stable identities. Primary is an ownership role, not a ban on additional providers contributing to the same type.

```cpp
AS_FORCE_LINK const FAngelscriptBindingRegistration BindProjectVectorExtras(
    TEXT("ProjectModule"), TEXT("VectorExtras"),
    [](FAngelscriptBindingContext& Binds)
    {
        Binds.ExtendType("FVector").Method("double ExtraLength() const", &ExtraLength);
    });
```

Support captureless lambdas/function pointers in the static registration API; capturing lambdas are not promised by the old callback type. SnapshotOnly providers can opt into parallel recording and must use only the context's immutable inputs. Existing-style external callbacks default to GameThread.

Merge defines all primary identities before resolving supplements. An extension may add properties/methods/overloads/effects but cannot redefine primary native layout or lifecycle. Exact repeated contributions from the same stable identity may be coalesced only when all semantic facts agree; duplicate provider registration is always rejected. Different providers defining the same callable need explicit target-enrichment intent or fail with both sources. Preserve manual/generated/reflection source priority for fallback declarations; no thread scheduling or incidental array position supplies priority. Explicit exclusions and compiler-only entries remain visible in accounting.

`ExtendType(...).NativeTarget(MemberSignature, TargetDesc)` enriches an existing declared member. The typed C++ helper constructs asSFuncPtr/caller/call-convention facts; it never treats a C++ member pointer as an untyped `void*`. Batch submission uses the same MemberKey/signature schema and imports the existing native-module function map transport. `TargetDesc` carries origin, NativeDirect/NativeThunk/UFunction transport, signature/layout version, parameter directions, receiver mode and lifetime. JIT/text recipes remain descriptive attachments; MetadataOnly must be explicit for interface/template/compiler-only declarations.

Manual explicit target selection wins over generated candidates. In its absence, a validated generated target may replace the reflective fallback only when the declaration permits that dispatch. Blueprint-event/override-sensitive calls retain reflective dispatch unless the API explicitly exposes a different native-only member. Optional generated entries without an eligible implementation retain the declared fallback and a diagnostic disposition; incompatible supplied targets fail instead of silently falling back. Full member identity includes owner, namespace, kind, parameter type uses and qualifiers, with return/layout compatibility checked separately by the SDK.

No external lambda directly mutates a published engine. New extension generations require a new database and fresh engine; automatic hot replacement is not implemented here.

## 5. Parallel work and ordering

Record first captures loaded UE identities, policy and required metadata on GameThread, retaining host objects there. Workers never traverse live UObject registries, mutate UClass metadata, access ambient TypeDatabase or create/destroy their own uncoordinated strong UObject pins. Each provider produces an independent fragment; target references use the retained input snapshot or explicit immutable native descriptors. Join before deterministic merge. Merge errors are sorted by stable source/symbol identity, not the first worker to finish.

Store `Section`, source role and explicit dependency facts in records. During transition the old EAngelscriptBindPhase appears only in the legacy bridge and diagnostic provenance. The new path does not run TypeDeclarations callbacks then rerun the same type provider. Stable sorting groups records; a dependency graph rejects inheritance and by-value cycles, while handle/reference cycles remain legal.

Install creates nominal identities and publishes an immutable name/type lookup at a barrier. Independent type shells and per-type member/signature work may be dispatched to workers. One task owns a type's ordered property/method additions; global namespaces form separate deterministic groups. Use SDK setters/factories and thread-safe identity interning; do not read array views of a draft while another task mutates it. Wait for all producers before layout finalization, Freeze and attachment.

Current DefinitionSet and canonical identity APIs determine mutation ownership and synchronization; inspect their current contracts rather than inheriting the removed MetadataImage mutex model. Parallel record/recipe work uses independent task-local output, and installation materializes one uniquely owned set per Engine. Mutually referring types remain within the supported definition owner; no shared mutable TypeInfo graph spans installations. Measure actual contention and do not promise lock-free creation or a default parallel speedup.

Serial and Parallel must match semantic manifests, selected call transports, exact errors and runtime outputs. Process-local numeric IDs are not stable semantic identities; shared external definitions keep one ID across admitting Engines while private definitions remain scoped. The initial Serial default avoids making a speed claim before measurement; both modes must remain usable and tested at completion.

## 6. Installation, adapters and templates

BindingInstance retains shared const preparation and owns its Engine-specific indexes, native auxiliary resources, TypeAdapterRegistry and template/reflection/delegate state. Immutable record-to-definition maps belong to preparation. Runtime state uses the prerequisite's exact-owner sidecars and never frozen TypeInfo user data. Specific World/collision helpers belong to Registry/Engine, not BindingInstance. Destroy contexts and executable resources before owned definitions/engine and release snapshot pins only after all consumers stop.

Adapter recording stores a typed factory plus immutable construction data, supported lifecycle/property-conversion operations and ordered TypeFinder recipes in HostTargets. No mutable adapter instance is shared across engines. After its metadata is attached, an unpublished owner constructs adapters with its explicit BindingInstance and registers them by canonical AS identity, name, UClass/data identity and property finder. Only successful completion publishes the owner. Factories cannot re-execute providers or obtain an ambient default engine. Stateless function pointers can be shared; owner-dependent state cannot.

The SDK owns substitution of generic parameter type uses and canonical function identities. UE's template component supplies TArray/TMap/TSet/TOptional and object-wrapper layout/lifetime/native adapters. For each requested concrete type, construct the complete member signature set, function/behavior metadata and independent native request facts before freezing its unique definition set; operation storage is created per installation. Initial signature-required instances are described by shared immutable preparation and materialized uniquely for each Engine; a later requested instance creates one complete Engine-private definition set through current registration. Reserve instance identity while preparing; publish cache entries only after registration and native linking succeed. Failed preparation leaves existing types and cache entries unchanged. Repeated requests reuse the admitted instance. Engines materializing the same published specialization share its publication ID and immutable description, never its TypeInfo pointer or mutable call state. Private specializations also remain Engine-owned.

Validation must distinguish a generic template declaration from a required concrete callable. A supported template recipe must identify a concrete target builder; a free-form recipe alone is not executable readiness. This repairs the current skip of template members without changing the backend or reviving old Register* callbacks.

## 7. Delegate and payload lifetime

The new delegate component uses `FAngelscriptDelegateStorageScope` and move-only `FAngelscriptDelegateSubscriptionToken`. A native storage scope must be declared after the native delegate so it expires before that storage; it is the unique lifetime authority for that location and rejects overlapping independent scopes. A reflected-property scope stores a weak UObject locator plus validated property identity and resolves storage only while the host is valid. Binding never retains a naked external address without its scope.

A storage scope owns shared validity/generation state. The installation holds weak scope references; tokens hold their subscription identity, weak installation state and storage generation. Scope destruction removes valid subscriptions and invalidates access before host storage ends. Engine teardown unbinds only still-valid matching subscriptions. Rebinding advances the storage generation; an old token or engine cannot remove the new binding, even when function/object names match. Unsubscribe is idempotent. Multicast cleanup removes only the owned occurrence, preserving pre-existing/native subscriptions. Since FMulticastScriptDelegate identifies listeners by object/function, reject a duplicate live owned subscription for that same pair within one storage scope rather than claiming independently removable indistinguishable entries.

Payload lookup returns a strong execution lease by value before ProcessEvent. The lease holds immutable target/signature/payload state; parameter initialization, copy and destruction use a stable RAII frame. Unbind removes registry visibility but does not reset the payload out from under an active lease. Newly started calls cannot find a removed handle; an admitted call finishes and cleans its frame exactly once. Nested calls, self-unbind, removal of earlier entries and array growth cannot invalidate its cleanup inputs. This does not promise arbitrary engine destruction from inside an active callback; the existing execution-owner lifetime must outlive admitted calls.

## 8. Directories and transition

```text
AngelscriptRuntime/
  Public/Bindings/                 registration, recording and extension contracts
  Private/Bindings/
    Framework/
      Registration/ Recording/ Metadata/ Runtime/ Adapters/ Diagnostics/
    Registry/
      Core/ Math/ Containers/ Objects/ Engine/
  angelscript/                     SDK semantics, definitions and native publication
```

Core includes names/strings/text/time/identity and UE nominal/reflection generators. Objects owns UObject wrappers, pointer policies and class constraints. Specific type adapters remain next to their type's Register function. Mechanism shared by providers lives in Framework. Bindings/Registry is built-in API content; Framework/Registration contains the catalogue mechanism.

First introduce the public contract and a bounded legacy recording bridge. Move framework responsibility owners, then migrate complete provider families and their includes. Build.cs generation lists and native wrapper aggregators must follow the moves; forced-link registration remains discoverable. Other modules may consume Public/Bindings or a documented compatibility header, never Private/Bindings. Do not remove the broad Core include path while unrelated dormant consumers still require it; stop new binding code depending on it and retain a consumer ledger.

The authoritative current source-site inventory is attached to this Change. It groups source registrations, including conditionally compiled candidates, into six migration families: Core, Math, Containers, ObjectsReflection, EngineGameplay and EngineServices. These acceptance families are not the five final Registry directory categories. The first task reconciles them with runtime capture and independent expected symbols; counts from a source scan are not active-provider counts. Every new-path primary is complete before its old phase fragments are retired. The final new path must have zero declaration-prepass execution and zero phase-dependent primary registrations. Dormant legacy code may remain with indexed shims, without becoming a selectable supported runtime.

## 9. Observation and performance decisions

Use a single `FAngelscriptBindingMetrics` snapshot with explicit coverage and units. Counters are produced from owned events/storage, not independently recomputed by each exporter. Stable phase names are Record.Inputs, Record.Providers, Record.Merge, Record.Resolve, Record.Validate, Install.Types, Install.Layouts, Install.Members, Install.Templates, Install.Targets, Install.Freeze, Install.Attach, Install.Native, Install.Adapters and Release. Include capture ID, database generation and engine/installation ID to correlate observations; exclude those transient IDs from semantic comparison.

Report wall-clock nanoseconds per phase, aggregate worker CPU nanoseconds and wait nanoseconds separately. Report eligible/excluded providers, types, members, instantiated templates and resolved targets by transport. Basic timers use fixed names; per-provider detail is opt-in. Worker events explicitly enter the parent capture/installation measurement context.

Memory categories are record fragments, database records, strings/index capacity, HostTargets, SDK metadata, per-engine adapters/native sidecars and temporary preparation. Report owned used/capacity bytes, peak observed owned bytes, allocation coverage, and counts of retained host references. One database and shared BindInfo records count once across multiple Engines; each Engine's uniquely materialized TypeInfo and installation storage count separately. Do not charge referenced UE assets as AS-owned allocations; unavailable SDK allocation coverage is explicit, not zero. Consume the prerequisite SDK GetMemoryStats for metadata/publication/Engine storage and add host attribution without duplicating SDK accounting.

Extend existing LLM/Trace facilities with binding categories and phase scopes. Ensure generic SDK allocation tagging does not overwrite an active binding category; task-local scopes must survive worker attribution and cross-thread release. Native FMemory allocation events already feed Memory Insights: do not emit duplicate manual malloc/free trace events or install another global allocator. Exact physical allocation/callstack data comes from Memory Insights, while capacity/semantic counters document their narrower accounting basis.

Benchmark contract: fixed small fixture and full Runtime surface, plus capture-once/create-two-engines and repeated template instances. Within each measured scenario/mode use three warmups and ten measured iterations; keep the first cold-in-process observation separately and do not call it OS-cold. Run the two modes in both orders, with a fresh managed process for each order. Compare 1, 2 and 4 worker limits where available, recording actual worker availability. Export raw per-iteration CSV and aggregate JSON with median/p95, work counts, memory peaks, machine/build policy, source/binary hashes and input semantic digest. Every timed iteration validates semantic/call results; no skipped case contributes to a successful sample. Benchmark tests use the separate Angelscript.UnitTest.BindingPerformance prefix so ordinary RuntimeBindings regression does not accidentally require a trace session or benchmark arguments. ASBindingBenchmarkOrder is a future test-owned command-line option, not a new Harness parameter.

Manifest schema 2 makes call transport/origin/selection and adapter categories explicit; unsupported version combinations reject. Baseline/final measurements compare an independently defined common symbol/call projection, not raw version-1/version-2 documents. New executable template workloads have no equivalent old VM baseline and are labeled final-only; report their additional work instead of claiming a like-for-like speedup. Serial/Parallel within the final version still require identical complete semantics.

Baseline collection precedes structural migration and repeats on the final implementation. No speed percentage is promised. Completion requires exact correctness, a populated comparison and explanation of regressions/contention; Parallel stays opt-in even if a measured case improves. Basic/detailed observation overhead is measured separately from optimization benefit. Trace-disabled builds preserve behavior and do not fabricate measurements. A real bounded .utrace session must expose phase/counter and allocation/tag evidence, including one worker allocation; raw traces stay in ignored Saved/Harness paths and trimmed evidence is indexed here.

## 10. Failure, compatibility and scope controls

Registry/merge failure returns no new database. Validation/Prepare failure returns no engine and no reusable partially prepared object. The database stays inspectable. Failed installation owns and tears down everything allocated for that attempt. Conflicting target enrichment, missing adapter factories, illegal type dependencies and unsupported template element operations carry source and symbol diagnostics.

The existing binding-runtime requirement for deterministic serial dependency order changes to deterministic dependency-correct results with an optional concurrent preparation mode. The current shared-record/publication-ID versus unique Engine TypeInfo contract is retained. The API intentionally improves ownership of native delegate storage; old raw-reference runtime binding entry points require migration rather than an unsafe permanent forwarding overload.

New UHT generation, disk relocation/cache format, arbitrary module unload, live engine extension, runtime activation and general collector changes are excluded. Existing delegate-language and memory/GC Changes are referenced as neighboring owners, not edited or marked done. Completion will require normal verification/spec synchronization and closure, but this creation delivery stops after planning validation with all product tasks unchecked.

The planning correction scopes a later formatting-only repair during task 6.4 to the six preserved Scenario quote blocks named in that card in the current angelscript/bindings/runtime spec. Their two-space ownership fails OpenSpec 0.9.0; use four-space ownership and blank-line separation without changing text, parentage or behavior. This does not authorize migration of other records or historical archives. Validate the four affected current capabilities individually, including their baseline before synchronization, rather than adopting all-spec validation as an unconditional gate. The present planning update does not synchronize unimplemented product behavior.

## 11. External type SDK prerequisite

The completed ownership predecessor is `openspec/archive/changes/angelscript/2026-09-11-feature-types-explicit-ownership/` (UID `change_6f58d4ea-1ff3-48f6-8680-df1b32635270`). Its source-hashed handoff describes that historical snapshot, including the subsequently deleted Image helper. The completed `2026-09-12-refactor-sdk-compile-lifecycle` archive supersedes that helper with `asCModuleDefinitionSet`; do not run the old source hashes as a current acceptance gate.

The shared object is sealed BindInfo/database records and process publication IDs. Each installation materializes distinct TypeInfo/Function objects on a unique DefinitionSet and transfers them to its receiving Engine through current registration. `asCTypeIdRegistry` issues numeric IDs only; it is not a shared TypeInfo owner or an Engine-admission bypass. No `asCMetadataImage`, `Registry.Register(Image)` or cross-Engine TypeInfo pointer sharing is reintroduced.

Task 0.1 owns current binding-consumer adaptation and a fresh small two-Engine proof before migration baseline 1.1. It must produce current source/binary evidence, not reuse archived pass counts. The existing store-input `FAngelscriptEngine::CreateForBindings` overload is the consumed API; the named PreparedBindings wrapper below is a future product of task 2.4 and retains immutable records/recipes only.
