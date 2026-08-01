# Manual Binding Architecture Impact Matrix

## Summary

The implementation is broad in call-site count but concentrated in one architectural seam: hand-written native registration. It does not require a new UE module, a new third-party dependency, a new AngelScript dialect, or a generated-binding redesign.

The primary risk is not the descriptor container itself. The risk is preserving registration semantics currently encoded indirectly in static initialization order, current-engine scope, PreviousBind mutation, native-form macros, documentation macros, and optional-module lifetime.

## Subsystem Matrix

| Area | Planned change | Compatibility authority | Risk |
|---|---|---|---|
| Runtime binding core | Add move-only fluent Bind construction, complete-declaration parsing/callable validation, descriptors, registry, snapshots, leases, validation, applier, and apply report | Existing script-visible declarations and traits | High |
| Derived declaration expansion | Replace raw reflection/type-derived `FString` registration with selected snapshot-time expansion definitions, explicit inputs, restricted writer, generated child descriptors, and catalog build report | Existing generated declarations and reflected type coverage | High |
| Auxiliary registrations | Replace ambient type/ToString/type-finder/bind-database writes with auxiliary descriptors applied to explicit engine-owned stores; keep genuine module services handle-owned outside Bind construction | Existing type conversion, formatting, type resolution, and reflected binding behavior | High |
| Runtime module startup | Own registry and explicitly submit core manifest | Runtime initializes before primary engine | Medium |
| Engine dependencies/lifecycle | Construct/load engine metadata stores, inject catalog source plus explicit expansion inputs, acquire/release materialized immutable snapshot lease | Multi-engine creation, initialization, bind-cache ordering, and teardown tests | High |
| Core `Bind_*.cpp` | Replace static `FBind` callback with named `CreateBind_*` provider returning `FAngelscriptBind` | Binding CQTests and script behavior | High by volume |
| Ordering/config | Add package phases/dependencies, deterministic node bands/edges, expansion SourceKeys, stable IDs; retain legacy names as aliases | Disabled bind tests and startup observations | High |
| Trait metadata | Store traits on descriptor node, apply to returned AS object | Existing trait bits and compile behavior | High |
| StaticJIT/native form | Consume explicit node/result instead of previous function | StaticJIT diagnostics, generated output, AOT tests | High |
| Documentation | Attach documentation to descriptor nodes | Docs tests and generated documentation surface | Medium |
| Execution timing | Record snapshot expansion timings in catalog build report and ordinary/auxiliary node timings in apply report | Existing observation accessors and stats output | Medium |
| Bind cache | Preserve the separate reflected `Structs`/`Classes` database contract; regression-test create/load and do not add catalog identity without new evidence | Successful cache create/load and script behavior | Medium |
| State dump/diagnostics | Observe registry generation, expansion inputs/results, generated-child provenance, catalog snapshot, auxiliary/ordinary apply results, owners/blockers, and legacy status | Existing state-dump contracts | Medium |
| GameplayTags | Package owns type/functions; extension registry retains tag replay | GameplayTags tests and late data replay | High |
| GAS | Explicitly register five manual bind providers from module lifecycle | GAS script surface | Medium |
| Legacy downstream binds | Opaque adapter behind default-on gate | Existing external source compatibility | High |
| UHT/generated binding | No execution or schema change; regression only | Current strategy tests/statistics | Low |
| Maintained AngelScript frontend | Extract/refactor a reusable engine-independent declaration frontend across parser/builder/tokenizer/declaration-model/type-query internals as needed; make existing registration and new preflight share it | Parser parity corpus + native SDK suite | High |

## Planned File Map

The implementation tasks use these grouped destinations; exact class/file splits may be adjusted only within the stated ownership.

### Binding core

Planned under `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Binding/`:

- `AngelscriptBindingDescriptors.*`: ordinary/auxiliary/expansion descriptor, identity, node-band/dependency, provenance, option, diagnostic, and result values;
- `AngelscriptBindingDeclaration.*`: plugin-owned parsed declaration records, token normalization, callable compatibility policy, literal/derived declaration wrappers;
- `AngelscriptBindingExpansion.*`: `FAngelscriptBindingExpansionContext`, restricted writer, input recording/fingerprinting, generated-child diagnostics;
- `AngelscriptBind.*`: move-only `FAngelscriptBind` root plus typed class/global/enum/node views and advanced auxiliary/expansion entries;
- `AngelscriptBindingRegistry.*`: module-owned registration handles, immutable package definitions, package/node validation;
- `AngelscriptBindingCatalog.*`: snapshot request/explicit input views, dependency/node-band sorting, expansion materialization, build report, lease;
- `AngelscriptBindingApplier.*`: explicit ordinary/auxiliary engine targets, fail-closed apply, apply report;
- explicit observer/listener interfaces for StaticJIT, documentation, timing, and diagnostics;
- `Legacy/`: isolated old registrar, ambient current-engine/PreviousBind forwarding, and compatibility scheduler.

Planned explicit auxiliary-store refactors:

- `Core/AngelscriptType.*`: add instance registration/lookup on `FAngelscriptTypeDatabase`; retain static ambient forwarding only for Legacy;
- `Core/Binding/AngelscriptToStringRegistry.*`: extract the engine-owned ToString list/duplicate lookup/type-info resolution from `Bind_FString.cpp`;
- `Core/AngelscriptBindDatabase.*`: add explicit instance/view/contribution APIs while preserving serialized `Structs`/`Classes` schema/version;
- `Binds/Helper_ToString.h`: remain only as the default-on Legacy forwarding surface after migrated providers use `Bind.ToString(...)`.

Planned beneath a narrow Runtime language/declaration boundary:

- plugin-owned parsed declaration/type/parameter/attribute value records;
- an engine-free binding-catalog parse-context adapter;
- token normalization and structured diagnostics;
- parser-parity fixtures shared with the existing engine registration path.

`ThirdParty/Angelscript/source/` is maintained fork source, not an immutable vendor drop. The implementation may modify or reorganize all relevant parser, builder, tokenizer, declaration syntax model, type-query, diagnostic, and internal frontend files needed for a cohesive shared parser. Task 0.7 records the proposed source ownership and dependency graph for review, but it does not create a file allowlist. Review and verification constrain observable language/registration behavior, not diff location or file count.

Dependency direction is explicit: the maintained fork produces AS-owned engine-independent declaration syntax values and diagnostics; a Runtime adapter converts them into plugin-owned parsed records. ThirdParty frontend code does not include or depend on Runtime binding descriptor types.

The current public compatibility header `Core/AngelscriptBinds.h` becomes a forwarding legacy surface while the new public headers remain independent from it.

Focused tests are planned under `Plugins/Angelscript/Source/AngelscriptTest/Core/`:

- `AngelscriptBindingDescriptorTests.cpp`;
- `AngelscriptBindingDeclarationTests.cpp`;
- `AngelscriptBindingExpansionTests.cpp`;
- `AngelscriptBindingAuxiliaryTests.cpp`;
- `AngelscriptBindingRegistryTests.cpp`;
- `AngelscriptBindingApplierTests.cpp`;
- `AngelscriptBindingArchitectureTests.cpp`.

### Engine and module integration

Planned changes are concentrated in:

- `Core/AngelscriptRuntimeModule.*` for registry ownership and core provider submission;
- `Core/AngelscriptEngine.*` and dependency/factory paths for explicit store construction/cache load, expansion-input snapshot request, catalog-source injection, lease, apply, save/clear, and teardown;
- `Binds/AngelscriptCoreBindingPackages.def` as the authoritative built-in provider manifest.

The no-argument/default engine construction path remains only as a compatibility route and must construct explicit dependencies before initialization; the applier itself never resolves an ambient engine.

### Consumer migration

- `AngelscriptRuntime/Binds/Bind_*.cpp`: 121 files.
- `AngelscriptGameplayTags/.../Binds/Bind_FGameplayTag.cpp`: one file, plus module registration ownership.
- `AngelscriptGAS/.../Binds/Bind_*.cpp`: five files, plus module registration ownership.
- StaticJIT/native macros, documentation helpers, bind config, state dump, and tests migrate to stable descriptor/result identities.

## Public API Impact

New public plugin-side concepts:

- `FAngelscriptBindingRegistry`
- `FAngelscriptBind`
- `TAngelscriptBindType<T>`
- `FAngelscriptBindGlobals`
- `FAngelscriptBindEnum`
- `FAngelscriptBindNode`
- `FAngelscriptBindingCatalogSnapshot`
- `FAngelscriptBindingCatalogLease`
- `FAngelscriptBindingSnapshotRequest`
- `FAngelscriptBindingExpansionInputs`
- `FAngelscriptBindingExpansionContext`
- `FAngelscriptBindingExpansionWriter`
- `FAngelscriptBindingCatalogBuildReport`
- `FAngelscriptBindingApplier`
- `FAngelscriptBindingApplyReport`
- `FAngelscriptBindingRegistrationHandle`
- explicit instance APIs on `FAngelscriptTypeDatabase` and `FAngelscriptBindDatabase`
- engine-owned `FAngelscriptToStringRegistry`

`FAngelscriptBindingPackage` is an internal immutable catalog value produced only when `FAngelscriptBindingRegistry::Register(FAngelscriptBind&&)` consumes a draft. There is no public `FAngelscriptBindingPackageBuilder`, `FAngelscriptBindBuilder`, `.Build()`, or `.Finalize()` API.

`FAngelscriptDerivedDeclaration` is an opaque generated-child value created only by the restricted expansion boundary. It is not publicly/implicitly constructible from `FString`, so it does not reopen a raw dynamic ordinary-binding overload.

Every callable API requires a complete declaration. Ordinary author-written declarations are contained in one ordinary, non-multiline C++ string literal; the surrounding call expression and fluent chain may wrap normally. `ASParam`, `ASParams`, automatic declaration-generation overloads, and separate `MethodDecl`/`FunctionDecl`/`BehaviourDecl` families are intentionally absent. Parsed declaration records and parser internals are implementation details, not additional high-frequency public construction concepts.

Reflection/type/catalog-derived declarations are an exception to source-literal authorship, not to complete-declaration parsing or descriptor identity. The selected mechanism is snapshot-time expansion: `Register()` freezes the expansion definition, while `AcquireSnapshot(Request)` materializes, parses, validates, identifies, and freezes its ordinary children before any engine apply.

Existing legacy source APIs remain temporarily available when `WITH_ANGELSCRIPT_LEGACY_BINDS=1`. New in-tree code is forbidden from including the legacy header or creating `FAngelscriptBinds::FBind`.

## Compilation and Configuration Impact

One temporary public compile definition is planned:

```text
WITH_ANGELSCRIPT_LEGACY_BINDS=0|1
```

Rules:

- default to `1` only when UBT global definitions do not already specify it;
- accept `-Define:WITH_ANGELSCRIPT_LEGACY_BINDS=0` as a UBT extra argument for the removal-readiness build (`Tools\RunBuild.ps1 ... -- -Define:WITH_ANGELSCRIPT_LEGACY_BINDS=0`);
- do not add a `.uplugin` field, Project Setting, runtime CVar, config-file key, or AngelScript compiler define;
- new registry/fluent-Bind/applier code always compiles and is not selected by the legacy macro;
- only compatibility declarations, opaque callbacks, PreviousBind state, and adapter tests are gated.

## Compatibility and Cache Impact

The following must remain unchanged:

- script-visible type, method, behavior, global, property, enum, and funcdef declarations;
- callable behavior, traits, deprecation messages, metadata, and native form;
- disabled-bind configuration using current names;
- RPC routing and generated binding categories;
- multi-engine isolation and teardown safety.

The following may intentionally change:

- raw AS function/property IDs where deterministic package ordering differs from static initialization order;
- diagnostic records that gain PackageId, NodeId, OwnerModuleId, phase, dependency, and result fields.

`Binds.Cache` remains a separate reflection-binding database. Its current schema has no PackageId, NodeId, catalog fingerprint, raw AS registration ID, or callback-order identity. This change regression-tests create/load behavior but does not add binding-catalog identity to that cache. Any later schema change requires a concrete producer/consumer dependency and an explicit OpenSpec revision.

## Module Lifetime Impact

External modules create and submit `FAngelscriptBind` values during `StartupModule()` and retain the resulting registration handle. Before unloading they call `TryUnregisterPackage`.

If an active engine lease includes the package:

- unregistration returns `InUseByEngine`;
- the catalog is not modified;
- diagnostics list blocking engine IDs;
- the module must not unload;
- engines must be destroyed or recreated before retrying.

The registry cannot retroactively remove native addresses from an existing AngelScript engine. In-tree binding-owner modules therefore opt out of uncoordinated dynamic reload until a caller provides the required engine-recreation sequence.

Expansion definitions and derived child callables may retain code addresses from the owner or a contributing package. Snapshot provenance records every contributor, and the lease blocks unregistration/unload of each contributing package while the snapshot is active. A genuine module-scoped auxiliary service additionally releases its own module handle only after package unregistration succeeds.

## Explicit Non-Impact

This change does not modify:

- intentional changes to AngelScript grammar, accepted declaration syntax, compiler semantics, VM behavior, bytecode behavior, registration behavior, or calling conventions; internal maintained-fork source layout and parser/builder APIs are explicitly in scope, and any intentional parser bug fix requires a recorded behavior delta and focused tests;
- UE-AngelScript source preprocessing or language syntax;
- UHT C# generation schemas, shard emission, native-module binding layout, or layout-version file;
- Blueprint reflective fallback eligibility;
- RPC/Net function routing;
- the standalone compiler OpenSpec;
- `FAngelscriptEngineExtensionRegistry` attach/replay behavior;
- host project gameplay logic.

## Removal Readiness

The change is complete only when:

- every in-tree manual provider uses explicit packages;
- no non-legacy production file references static `FBind`, PreviousBind helpers, ambient `FAngelscriptType`/ToString/bind-database target selection, raw dynamic ordinary declarations, or implicit-engine registration;
- all derived declarations materialize through snapshot expansion and all known auxiliary registrations target explicit engine-owned stores;
- all tests pass with the legacy gate enabled;
- the plugin builds and its applicable tests pass with the legacy gate disabled;
- old source remains isolated so a later removal deletes the compatibility directory, forwarding declarations, macro default, and legacy-only tests without redesigning the new core.
