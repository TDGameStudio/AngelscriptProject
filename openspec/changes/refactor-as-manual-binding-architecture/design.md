# Direct Explicit Binding Callback Architecture

## Context

The maintained plugin already discovers manual bindings through process-static objects and executes them for every full AngelScript engine. That shape is efficient: registration declarations and callable metadata are consumed immediately by `asIScriptEngine`, so the runtime does not retain a second expanded description of the binding surface.

The problems are elsewhere. The global array is copied and sorted on every call; integer `EOrder` offsets hide semantic intent; many APIs locate `FAngelscriptEngine::GetCurrent()` or fallback state; PreviousBind helpers mutate an implicit last result; generated modules use several arrival paths; and module startup can own binding submission rather than the bind source file.

This design keeps direct execution, makes the target engine explicit, and turns the existing global callback array into one stable process-lifetime collection. `UAngelscriptSubsystem` coordinates when the collection becomes complete but does not cache or own binding content.

The earlier Registry/package design and the later deferred-description design are retained only as decision history in `review-2026-07-30.md` and `research.md`. They are not implementation alternatives within this change.

## Goals / Non-Goals

### Goals

- Keep every logical binding next to its implementation in a `Bind_*.cpp` or generated source file.
- Keep static initialization metadata-only and ordinary C++ tooling-friendly.
- Maintain exactly one compact process-wide callback collection.
- Load generated modules, validate, sort, and seal that collection once before engine binding begins.
- Execute callbacks directly for every full engine creation with one explicit `FAngelscriptBinds` target.
- Replace integer ordering with seven explicit semantic phases.
- Preserve existing pointer, macro, overload, native, and lambda callable forms.
- Give production hand-written runtime callables stable, source-owned C++ names without adding a runtime tracing or descriptor layer.
- Replace implicit PreviousBind mutation with exact direct-result values.
- Keep AS ids, objects, databases, formatters, finders, BindDB state, and other resolved state engine-owned.
- Converge manual, generated, reflection, editor-generated, GameplayTags, and GAS paths without `StartupModule()` submission.

### Non-Goals

- Caching expanded types, declarations, methods, properties, traits, reflection output, or callable descriptions between engines.
- Avoiding callback replay when a second full AngelScript engine is deliberately created.
- A public Registry, central source manifest, dependency graph, priority system, or runtime disable/filter surface.
- Redesigning NativeModuleFunctionAddress dynamic arrival/unload transport; its current POD/`IModularFeatures` bridge remains a documented exception until `refactor-as-native-module-binding-preseal-transport`.
- Dynamic unload, late arrival, unregister, or in-process replacement for direct callback providers after seal.
- Extracting an engine-independent AngelScript declaration parser.
- Removing lambda overloads from the DSL or mechanically rewriting type-finder, local-algorithm, UE delegate, and async lambdas that are not direct AngelScript callable entries.
- Changing parser, compiler, VM, Standalone host, or generated native POD layout without separate evidence.

## Architecture Overview

```text
Bind_*.cpp / generated source
        |
        | file-static FAngelscriptBind constructor
        | metadata only: name, phase, module, source, function pointer
        v
single process callback collection (mutable during native module load)
        |
        | UAngelscriptSubsystem on Game Thread:
        | load BindModules.Cache modules -> validate -> sort -> seal
        v
single process callback collection (immutable)
        |
        | each full FAngelscriptEngine creation
        v
FAngelscriptBinds(explicit engine) -> callback -> asIScriptEngine::Register*
        |
        v
engine-owned BindState / TypeDatabase / BindDB / ToString / AS ids and objects
```

Static discovery, process finalization, and per-engine execution are different operations:

- Static discovery appends a compact callback record and does not touch runtime state.
- Process finalization makes the one global collection deterministic and immutable; it does not copy it into the subsystem.
- Per-engine execution directly performs registration and records only resolved engine-owned results.

## Decisions

### 1. `FAngelscriptBind` is a file-static registration declaration

The authoring form is:

```cpp
AS_FORCE_LINK const FAngelscriptBind Bind_FVector(
    TEXT("FVector"),
    EAngelscriptBindPhase::ExplicitBindings,
    [](FAngelscriptBinds& Binds)
    {
        auto FVector_ = Binds.ExistingClassForTarget(TEXT("FVector"));

        FVector_.Method("float64 Size() const", METHOD_TRIVIAL(FVector, Size))
            .NoDiscard()
            .Documentation(TEXT("Returns the vector length."));
    });
```

`FAngelscriptBind` accepts a required logical name, required phase, and non-capturing function compatible with:

```cpp
using FFunction = void(*)(FAngelscriptBinds&);
```

The constructor automatically captures `UE_MODULE_NAME` and call-site source location through the project-supported mechanism. The existing file-level `Bind_FVector` naming convention remains; file-static objects do not gain a `G` prefix.

A file may own multiple static binds. This is required when one legacy callback combines operations that belong to different phases; physical legacy callback boundaries are not compatibility requirements.

### 2. Static construction appends one compact record

The internal process record contains only:

- required `BindName`;
- required `EAngelscriptBindPhase`;
- owner module name;
- source file and line;
- process-lifetime function pointer.

Static construction must not:

- access `GEngine`, `UAngelscriptSubsystem`, `FAngelscriptEngine::GetCurrent()`, reflection iteration, BindDB, ToString/type stores, or generated tables that require module loading;
- call an AngelScript API;
- allocate or cache an engine-owned AS object;
- submit through `StartupModule()`;
- create an unregister handle or module lifetime lease.

The global collection is internal, append-only before finalization, and process-lifetime. It is the only process-wide copy of callback metadata.

### 3. The subsystem coordinates finalization but stores no binding data

`UAngelscriptSubsystem::Initialize()` performs the normal production sequence on the Game Thread:

1. Read `BindModules.Cache`.
2. Load every listed generated binding module.
3. Ask the global bind collection to finalize.
4. Initialize the primary AngelScript engine.

Finalization validates required fields and duplicate stable identities, sorts the existing collection in place, and seals it permanently. Stable identity is exactly `(OwnerModule, BindName, Phase)`; source file and line are deterministic sort tie-breakers and diagnostic provenance, not identity. It is idempotent so the existing no-`GEngine` compatibility bootstrap can use the same entry point when the subsystem is unavailable.

`UAngelscriptSubsystem` has no `Binds`, `BindingInfos`, callback pointer view, or expanded registration member. It is a lifecycle coordinator, not a binding repository.

After seal, append attempts fail with a diagnostic containing module, logical name, phase, and source. Native Live Coding or loading a new direct callback module requires process restart. No direct-callback late replay or collection rebuild is supported. NativeModuleFunctionAddress remains on its existing dynamic bridge as the sole temporary exception.

### 4. Seven required phases replace integer order

Every file-static bind declares exactly one phase:

| Phase | Direct callback responsibility |
|---|---|
| `TypeDeclarations` | typedefs, enums, funcdefs, and object/value/interface type declarations |
| `TypeInfrastructure` | behaviours required to complete types (including an AngelScript template method surface that must exist before its first specialization), string factory, default array type, type adapters/finders, well-known slots, interface scaffolding, and formatter contributions needed by later consumers |
| `ExplicitBindings` | hand-written methods, constructors, properties, behaviours, globals, and namespace functions |
| `GeneratedBindings` | UHT runtime-linked tables, editor CodeGen output, and the Runtime-side NativeModuleFunctionAddress bridge bootstrap |
| `ReflectionBindings` | reflected class/struct/property/UFunction bindings and reflective fallbacks |
| `PostReflectionBindings` | reflection-dependent function-library mixins and actor/component/subsystem callable synthesis that continues registering script functions |
| `Finalization` | ToString contribution completeness checks, BindDB finalization/save inputs, metadata finalizers, and consistency checks |

The collection sorts by phase first, then stable owner module, logical bind name, source file, and source line. Static initialization and module load order never define execution order.

`FAngelscriptBinds::EOrder`, integer offsets, priorities, and dependency strings are absent from the completed architecture.

If a legacy callback spans phases, split it into multiple `FAngelscriptBind` declarations in the same source file. If operations have a tight local sequence within one phase, keep them in one callback. If migration finds a real dependency that cannot be expressed by phase selection, callback splitting, or local merging, record it for a separate OpenSpec rather than add an escape hatch here.

### 5. Every engine directly replays the sealed callbacks

`FAngelscriptEngine::BindScriptTypes()` constructs an explicit context and executes the immutable collection:

```cpp
FAngelscriptBinds Binds(*this);
FString BindDiagnostic;
FAngelscriptBind::ExecuteRegisteredBinds(Binds, BindDiagnostic);
```

Execution does not copy or sort the collection. Each callback immediately invokes target-engine registration APIs through `FAngelscriptBinds`.

A second full engine executes the same callback functions again because it must create its own AngelScript types and functions. This is intentional. The architecture optimizes the normal path by eliminating repeat array sorting and by retaining no expanded registration model, rather than optimizing test-heavy multi-engine creation at process-lifetime memory cost.

### 6. `FAngelscriptBinds` owns an explicit target

`FAngelscriptBinds` is the direct binding facade for one `FAngelscriptEngine`. Its methods resolve the target engine, type database, bind database, bind state, ToString collection, interface-signature registry, StaticJIT/native state, and other auxiliary stores from that explicit instance.

The new path does not use an ambient current engine or unpartitioned fallback store to choose a mutation target. Temporary `FAngelscriptEngineScope` support may remain for unrelated legacy consumers during migration, but no completed binding helper depends on it.

`ValueClassForTarget`, `ReferenceClassForTarget`, `ExistingClassForTarget`, `EnumForTarget`, the `BindGlobal*ForTarget` family, the explicit-engine namespace guard, and the returned class facade's methods, constructors, factories, destructors, behaviours, functions, and properties perform registration immediately. The removed targetless static authoring surface cannot select a mutation target implicitly.

### 7. Callable compatibility remains direct

The outer provider callback is non-capturing, and the DSL retains all forms accepted by the current API:

- free function pointers;
- non-const, const, and ref-qualified member pointers;
- explicit overload casts and `METHODPR`-style helpers;
- `METHOD`, `METHOD_TRIVIAL`, `FUNC`, `FUNC_TRIVIAL`, and custom-native forms;
- supported non-capturing method/global/constructor lambdas;
- direct and generic AngelScript call paths;
- ASAutoCaller/native caller, call convention, user data, and StaticJIT metadata;
- capturing TFunction-like values only in existing auxiliary families that explicitly own them safely, such as supported type finders.

Production hand-written bind files use named entry points for project-owned runtime callables, but the supported lambda overloads remain part of the facade and are exercised by focused compatibility fixtures. The explicit complete AngelScript declaration remains authoritative. This change does not attempt to infer all declarations from C++ types or parse declaration text independently.

### 8. Hand-written runtime callables have named, colocated owners

The registration source and runtime implementation form one sortable file family whenever a bind owns custom callable code:

```text
Bind_FVector.cpp
Bind_FVector_Functions.h
Bind_FVector_Functions.cpp
```

`Bind_<Name>.cpp` contains `FAngelscriptBind` declarations, explicit phases, typed DSL calls, complete AngelScript declarations, and fluent traits. `Bind_<Name>_Functions.h` declares one primary `FAngelscript<Name>Binds` owner. `Bind_<Name>_Functions.cpp` contains its non-template callable implementations. A pointer-only bind that forwards only existing UE member/free functions does not gain empty companion files.

```cpp
struct FAngelscriptFVectorBinds
{
    static bool IsNearlyZero(const FVector* Vector, double Tolerance);
};

FVector_.Method(
    "bool IsNearlyZero(float64 Tolerance = KINDA_SMALL_NUMBER) const",
    &FAngelscriptFVectorBinds::IsNearlyZero);
```

The owner name is derived from the bind-file stem, including Unreal type prefixes for newly introduced owners. One registration file has one primary owner even when it binds several related UE types; semantic function names identify the receiver or argument variant. Existing names such as `FAngelscriptActorBinds`, `FAngelscriptMapBinds`, `FAngelscriptSetBinds`, and `FAngelscriptOptionalBinds` are not renamed merely to normalize the stem. If an existing owner spans several registration files, split direct callable ownership only where needed: keep the established name with its primary bind and introduce a new `FAngelscript<Name>Binds` owner for the other bind.

All project-owned functions directly registered as AngelScript methods, constructors, implicit constructors, factories, destructors, behaviours, template callbacks, global functions, or global generic functions move to the owner, regardless of whether the old spelling was an inline lambda, file-local free function, namespace function, or static wrapper. Function names are semantic and unambiguous at the address-taking site: use forms such as `ConstructDefault`, `ConstructCopy`, `ConstructFromString`, `GetByIndex`, `GetByName`, or `OpEqualsObject`, not numeric suffixes. Implementation-only helpers remain private or in the `_Functions.cpp` anonymous namespace.

Non-template bodies belong in `_Functions.cpp`. Template bodies that must be visible at their instantiation point remain in `_Functions.h`; existing container operations/support types and specialized support headers are not mechanically collapsed into the new owner. Type finders, local algorithms, and UE delegate/async callbacks are not direct AS entries and keep their existing capture/lifetime forms.

Visibility follows actual consumers. A newly named former lambda is module-internal and is registered with `&FAngelscript<Name>Binds::Function`, preserving its prior lack of StaticJIT native form. A callable already registered through `FUNC`, `FUNC_TRIVIAL`, a custom-native form, or `SCRIPT_NATIVE_TEMPLATED_CALL` retains the same native/trivial classification, required export visibility, generated C++ spelling, and StaticJIT include reachability after moving. The migration does not blanket-apply `FORCENOINLINE`, disable optimization, add a debug trampoline, or retain function-level source metadata.

### 9. Fluent traits use direct bound-result values

Function-like registrations return `FAngelscriptBoundFunction`; property registrations return `FAngelscriptBoundProperty`. These small temporary values identify the explicit engine and exact result just returned by AngelScript.

```cpp
FVector_.Method(...).NoDiscard().Documentation(...);
Binds.GlobalFunction(...).Deprecated(...);
FVector_.Property(...).PureConstant(...);
```

Applicable fluent operations cover editor-only, deprecation, property accessor, no-discard, world context, callable/generated accessor, implicit constructor, compile-out forms, forced-const arguments, output-type selection, script-function/object injection, documentation, native/trivial form, and pure-constant data.

Discarding a bound-result return remains valid. The values are not registration handles, do not enter the global callback collection, and do not outlive their target engine.

Registration-chain layout is deterministic. A registration followed by exactly one fluent trait stays on one physical line when the combined raw line length is at most 120 columns. Longer registrations and registrations with multiple traits close the registration call on its own line, then place each chained trait on a separately indented line. Source-layout coverage scans hand-written Runtime `Bind_*.cpp` files so later migration waves preserve this convention.

`FAngelscriptFunctionBinding` retains its existing native-callable payload responsibility and is not reused as a fluent result.

`PreviouslyBoundFunction`, `PreviouslyBoundGlobalProperty`, and their getter/setter/free-function ecosystem are removed after migration.

### 10. Auxiliary work remains direct and engine-scoped

Type adapters/finders, well-known type slots, ToString contributions, BindDB contributions, string factory/default array selection, interface signatures/user data, generated tables, reflection bindings, and finalizers execute in their declared phase and write to explicit engine-owned targets.

Producer/consumer helpers are split at their semantic boundary. In particular, ToString formatter contributions are collected in `TypeInfrastructure`, before the `FString` consumer registers script-visible conversion methods in `ExplicitBindings`. `Finalization` may validate contribution completeness and metadata, but it registers no new type, function, or property. This matches the phase invariant and preserves ordering without relying on bind-name sorting inside one phase.

No auxiliary contribution is cached in a process-level expanded model. A second engine repeats the callback and creates a fresh auxiliary result. Process-global callback records never store resolved AS type/function/object pointers or registration ids.

### 11. Generated and reflection paths use direct callbacks where module dependencies permit

- UHT `NativeRuntimeLinked` shards emit `FAngelscriptBind` with `GeneratedBindings` and directly register their table when executed.
- UHT `NativeModuleFunctionAddress` target-module shards retain their Runtime-independent POD/`IModularFeatures` transport, arrival/unload hooks, and current layout. Their Runtime consumer adopts the explicit-engine API and new outer provider form only where needed to compile with the new architecture. Removing this bridge is deferred to `refactor-as-native-module-binding-preseal-transport` because target modules cannot depend on `AngelscriptRuntime` without a circular dependency.
- Editor CodeGen output emits file-static `FAngelscriptBind`; generated module `StartupModule()` is empty of binding submission.
- Reflection work executes through one or more `ReflectionBindings` callbacks.
- Reflection-dependent callable synthesis executes through `PostReflectionBindings`; `Finalization` performs no new type/function/property registration.
- RPC/Net UFunctions retain `BlueprintCallableReflectiveFallback`; direct raw native thunk registration must not bypass Unreal routing.
- `FAngelscriptNativeModuleFunctionBinding` and `FAngelscriptNativeModuleFunctionBindingView` layouts remain unchanged unless implementation evidence proves otherwise.
- UHT-generated thunks are already named generated entries and do not receive hand-written `_Functions.h/.cpp` companions.

### 12. Runtime disabling and dependencies are absent; one transport exception remains

`UAngelscriptSettings::DisabledBindNames`, engine disabled collections, filter/merge logic, aliases, dependency cascade, skip reasons, and related dumps/tests are removed. Source consumers edit or remove source and rebuild.

The completed direct-callback architecture has no `Requires`, `Before`, `After`, priority, registration handle, unregister, snapshot lease, unload blocker, or late replay. Modules owning direct callback/native addresses must load before seal and remain loaded for the process. NativeModuleFunctionAddress retains its existing binding-specific modular-feature lifecycle only until its recorded follow-up change.

### 13. Failure, publication, and diagnostics are fail-closed

`FAngelscriptBinds` records the first registration failure with provider, phase, source, declaration/target identity, and AngelScript code/message. After failure, later registration attempts in that callback do not mutate the engine, execution does not enter later providers, and `PostInitialize_GameThread()` does not publish the partial engine.

Development/test observation records:

- one-time collection finalization status, provider count, phase counts, and duplicate/late errors;
- per-engine provider identity, phase, status, and callback duration;
- first failure and engine publication result;
- per-phase totals and top-N callback durations when stats are enabled.

The state dump observes the sealed callback metadata and engine-owned execution/state results. It never invokes callbacks or reconstructs binding work. Shipping/Test builds without observation defines avoid per-provider clocks and detailed timing storage.

## Lifecycle and Thread Contract

### Subsystem / compatibility bootstrap — Game Thread

- Load generated binding modules.
- Finalize and seal the one global callback collection.
- Do not retain a second collection or expanded binding data.
- Begin full engine initialization only after successful finalization.

### `PreInitialize_GameThread`

- Create the target AS engine and acquire required process packages/settings.
- Require that the global bind collection is sealed, or use the idempotent compatibility finalizer when the supported no-subsystem path applies.

### `Initialize_AnyThread`

- Create engine-owned binding stores before they are consumed.
- Construct `FAngelscriptBinds` for the explicit engine.
- Execute the sealed callbacks directly in phase/stable order.
- Abort on the first required registration failure.

### `PostInitialize_GameThread`

- Require complete successful binding execution.
- Publish the engine, attach observers/extensions, and notify consumers.
- Never retry or fill missing bindings here.

## Invariants

- There is exactly one process-wide callback record collection.
- The subsystem stores no binding record copy, pointer view, or expanded registration data.
- Static construction does not touch engine/reflection/runtime state.
- Every `FAngelscriptBind` explicitly declares one phase.
- The sealed collection is not copied or re-sorted per engine.
- Every full engine creation directly replays every required callback.
- Every callback mutation targets the `FAngelscriptEngine` held by its `FAngelscriptBinds` context.
- Process callback records contain no engine-owned AS pointer or id.
- Bound-result values identify exact direct results and do not use PreviousBind state.
- Every project-owned direct runtime callable in a production hand-written bind has a stable named owner function; DSL lambda support remains available to compatibility tests and external authors.
- Named callable extraction does not add function-level process metadata or per-call tracing/dispatch state.
- Failed engines are never published.
- There is no runtime disable, dependency graph, or dual direct-callback architecture in the target state; NativeModuleFunctionAddress is the single explicit dynamic-transport exception.

## Risks / Trade-offs

- **Multiple engines repeat reflection and callback work.** This is accepted to keep the normal single-primary-engine path memory-light; multi-engine creation is mainly a validation scenario.
- **Phase migration can expose hidden integer-order dependencies.** Audit every non-default order, split mixed callbacks, and merge tightly coupled same-phase work locally. Escalate irreducible dependencies to a separate change.
- **A direct callback may perform several registrations before one fails.** Keep the engine unpublished, stop further mutation after the first failure, and destroy the partial engine.
- **Permanent seal restricts native Live Coding.** Emit a restart-required diagnostic; do not add replay complexity.
- **Explicit target migration touches auxiliary helpers.** Migrate and test each store family before deleting ambient/fallback access.
- **Generated paths may diverge.** Assert emitted phase/callback shape in UHT RuntimeLinked and CodeGen golden fixtures, preserve the NativeModuleFunctionAddress bridge contract, and verify runtime behavior separately.
- **Moving a native-form callable can break generated StaticJIT C++ names or includes.** Inventory every existing native/trivial/template form first, preserve its classification and visibility, and compile representative generated precompiled output after each sensitive migration wave.
- **Template specializations can freeze an incomplete callable surface.** Keep the template declaration in `TypeDeclarations`, but register any constructor/method/template callback required before the first specialization as a separate, stably named `TypeInfrastructure` contribution ahead of legacy or generated consumers. `TOptional<int>` regression coverage guards this timing requirement.
- **A broad source rule could reject valid auxiliary lambdas.** Limit the guard to lambdas directly supplied to AS callable registration APIs and keep explicit fixtures proving DSL lambda support.
- **Optimized builds may still coalesce frames or move source lines.** Stable named functions improve symbols and breakpoint targets, but the change deliberately avoids blanket no-inline/optimization controls that would penalize high-frequency bindings.

## Migration Plan

1. Capture source inventories, current ordering, direct callable lambdas and wrappers, native/StaticJIT forms, generated output, state dumps, startup timing, and representative binding behavior.
2. Add the new direct callback record/collection behind focused tests, including local collection fixtures that do not mutate the production global collection.
3. Move generated-module loading before collection finalization and add permanent seal behavior.
4. Add explicit-engine `FAngelscriptBinds`, direct bound-result values, and fail-closed execution.
5. Migrate `FColor` and `FVector` as reference providers with `_Functions.h/.cpp` owners, while separately proving the DSL still accepts supported lambdas.
6. Migrate all other project-owned hand-written callable implementations in semantic waves, preserve native/StaticJIT forms, and complete the order-to-phase audit.
7. Migrate auxiliary, UHT RuntimeLinked, reflection, post-reflection, editor CodeGen, GameplayTags, and GAS paths; generated UHT thunks remain named generated sources rather than hand-written companion families, while NativeModuleFunctionAddress keeps its recorded transport exception.
8. Remove `EOrder`, PreviousBind, disabled binds, direct-provider module submission/late replay, ambient binding targets, and any intermediate compatibility code.
9. Update diagnostics and Chinese-first/English documentation, run focused/full regressions, and verify both removed-concept guards and the production callable-lambda guard.

This is a source migration rather than a staged runtime rollout. The completed target ships one direct callback architecture without a long-lived compatibility switch.

## Open Questions

No architecture-blocking questions remain. A concrete cross-provider dependency that cannot be expressed by the seven phases or local callback structure requires a separate OpenSpec and must not be solved through an implementation-only ordering escape hatch.
