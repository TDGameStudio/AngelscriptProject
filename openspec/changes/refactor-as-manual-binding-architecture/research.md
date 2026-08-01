# Manual Binding Architecture Research

## Executive Finding

The current API has fluent-looking class wrappers, but the binding system itself is still global and order-sensitive:

1. static C++ objects discover opaque callbacks before module startup;
2. those callbacks resolve a current `FAngelscriptEngine` implicitly;
3. registration writes an engine-scoped "previous function/property" slot;
4. later macros and helper calls mutate whichever AngelScript object that slot identifies;
5. StaticJIT, documentation, diagnostics, and tests depend on this temporal coupling.

The selected replacement is not another thin wrapper over `FAngelscriptBinds`. It is a descriptor-first model with deterministic snapshot expansion and explicit engine application:

```text
module-owned move-only FAngelscriptBind draft
        -> Registry.Register(FAngelscriptBind&&)
        -> immutable package definitions, auxiliary metadata, and expansion definitions
        -> AcquireSnapshot(explicit reflection/config/bind-database inputs)
        -> deterministic generated children + validated immutable catalog snapshot
        -> explicit ordinary/auxiliary engine applier
        -> per-node apply report
```

This combines the useful ergonomics of ASBind-style typed generators with the descriptor-first registration model used by the local UnrealCSharp reference.

## Current Source Inventory

The following counts were refreshed on 2026-07-30 with `rg` over `Plugins/**.{h,cpp}`. They are planning evidence rather than permanent acceptance constants; task 0.1 refreshes them immediately before implementation.

| Pattern | Occurrences | Files |
|---|---:|---:|
| `FAngelscriptBinds::FBind` | 249 | 138 |
| `BindGlobalFunction` | 734 | 68 |
| `GetPreviousBind` | 34 | 4 |
| `SetPreviousBind` | 242 | 59 |
| `DeprecatePreviousBind` | 10 | 6 |
| `CompileOutPreviousBind` | 7 | 3 |
| `SCRIPT_BIND_DOCUMENTATION` | 86 | 15 |
| `SCRIPT_GLOBAL_DOCUMENTATION` | 34 | 2 |

Manual bind files:

| Plugin | `Bind_*.cpp` files |
|---|---:|
| `Angelscript` | 121 |
| `AngelscriptGameplayTags` | 1 |
| `AngelscriptGAS` | 5 |
| **Total** | **127** |

The all-Plugins counts include tests and compatibility fixtures in addition to production bind files. Implementation tasks must classify every match rather than mechanically deleting every occurrence.

## Current Architecture

### Static discovery

`FAngelscriptBinds::FBind` constructors append `FBindFunction` records to a function-local static array. `CallBinds()` copies, sorts, filters, observes, and invokes the callbacks. The source filename or an explicit name becomes the bind name, while `EOrder` supplies `Early`, `Normal`, or `Late`.

Consequences:

- provider discovery occurs through static initialization rather than module ownership;
- registration presence can depend on force-link and translation-unit behavior;
- callbacks have no explicit input context;
- same-tier dependencies are not declared;
- external module ownership and unloading are not represented in the registry.

### Implicit engine and temporal metadata

The binding wrappers ultimately call `FAngelscriptEngine::Get()` and register directly into its `asIScriptEngine`. `OnBind()` stores the last returned function ID; global-property registration stores a similar property ID. Trait setters, documentation helpers, compile-out helpers, and native-form macros then look up and mutate that previous object.

Although the mutable slots now live in `FAngelscriptBindState` when an engine is available, the coupling is still implicit and sequential. A fallback `LegacyBindState` also remains available. This is engine scoping of a global protocol, not elimination of the protocol.

### Consumers coupled to registration order

- StaticJIT/native-form macros attach native metadata to the most recently bound function.
- Documentation macros attach text to the most recently bound member or global.
- Compile-out, deprecation, editor-only, property-accessor, no-discard, world-context, generated-accessor, output-type, and script-object/script-function forwarding traits use PreviousBind helpers.
- Bind execution timing observes opaque callback names and `int32 BindOrder`.
- Some tests and metadata consumers are sensitive to the legacy registration sequence and raw AS IDs. `Binds.Cache` is not: its current serialized reflection-binding records contain neither raw AS registration IDs nor package/catalog identity.
- Disabled bind configuration uses the legacy bind name.

### Existing positive foundations

- `FAngelscriptBindState` is already engine-owned on the normal path.
- Bind names, disabled-bind filtering, timing observation, state dumps, and multi-engine tests provide useful compatibility evidence.
- `FAngelscriptEngineDependencies` and testing factories provide a place to inject an explicit catalog source.
- Engine-owned runtime state specifications already allow process-level replayable descriptors as long as they do not cache engine-owned AngelScript objects.

## Reference Comparison

### asbind20

Reference: <https://github.com/HenryAWE/asbind20>

Useful patterns:

- the target `asIScriptEngine*` is passed explicitly to a generator;
- typed `value_class`, `ref_class`, `global`, `enum_`, and interface generators expose a fluent API;
- template traits validate C++ callable shapes;
- complete AngelScript declaration strings remain authoritative for the script-visible contract;
- registration listeners receive the generator context and returned AS IDs, enabling metadata and diagnostics without a global previous-function slot;
- append/try-append modes make duplicate or extension behavior explicit.

Not adopted directly:

- immediate registration is incompatible with this change's requirement for package-level validation, ordering, lifecycle ownership, and immutable per-engine snapshots;
- asbind20 is not added as a dependency;
- its exact API and type system do not model UE reflection, existing StaticJIT metadata, disabled bind names, or module ownership.

### Local UnrealCSharp

Primary reference:

`Reference/UnrealCSharp/Source/UnrealCSharp/Public/Binding/Class/TBindingClassBuilder.inl`

Useful patterns:

- `TBindingClassBuilder<T>` and related builders collect constructor, function, property, inheritance, and metadata descriptions;
- descriptor/register records are materialized later rather than relying on "the previous function";
- ownership and registration data are explicit values that can be inspected before runtime materialization;
- C++ fluent ergonomics do not require introducing a new language parser.

Not adopted directly:

- UnrealCSharp still uses its own static builder instantiation pattern;
- its CLR marshalling and managed-domain lifecycle are unrelated to AngelScript engine registration;
- its descriptor types cannot be reused as a dependency.

### Local SigilProject language-core boundary

Reference root:

`D:/Workspace/SigilProject/Plugins/Sigil/Sigil/`

Relevant evidence:

- `Source/SigilCore/Public/SigilTokenizer.h` exposes value tokens, source locations, lexer state, and structured diagnostics;
- `Source/SigilCore/Public/SigilParser.h` consumes text/tokens and returns value-model output plus diagnostics;
- `Source/SigilCore/Public/SigilLanguageService.h` consumes parsed/schema values rather than reaching into editor state;
- `Source/SigilCore/SigilCore.Build.cs` records the language/model layer as pure C++ with no Editor API;
- `Standalone/Base/CMakeLists.txt` compiles the same `SigilCore` private sources into a standalone static library and native tests.

The reusable lesson is the dependency direction, not the Sigil grammar or its concrete types:

```text
shared language source
    -> language-owned value syntax + diagnostics
    -> host adapter/model
    -> engine/editor/runtime consumers
```

For this change, the maintained AngelScript fork should similarly own its engine-independent declaration syntax value and diagnostics. The Runtime binding layer adapts that syntax into `FAngelscriptParsedFunctionDeclaration`; the fork must not depend upward on plugin binding descriptors. The normal AS builder and engine-free package preflight share the same lower frontend, just as Sigil's UE and standalone surfaces share the same language core.

## Prior OpenSpec Records

### `refactor-as-typed-bind-dsl`

The archived change produced `openspec/specs/as-typed-bind-dsl/spec.md`. It proposed a typed class facade that delegated directly to `FAngelscriptBinds` and required only a representative `FColor` migration. That facade does not remove static `FBind`, implicit engine lookup, callback discovery, or PreviousBind.

The capability identifier contains `dsl`, but the public authoring surface is a C++ fluent API rather than a new textual DSL. This change retains the identifier only because OpenSpec deltas must target the archived canonical capability. Internally, the new API deliberately reuses the maintained AngelScript declaration frontend.

### `refactor-as-bind-eliminate-previously-bound-function`

The archived change produced `as-bind-trait-fluent-api` and `as-bind-execution-timing`. It proposed returning AS-ID handles from immediate registration, but explicitly kept `OnBind()` writing `PreviouslyBoundFunction` for legacy compatibility. The current source does not contain the proposed completed `FBoundFunction` architecture.

This change supersedes that intermediate design: the new handle identifies a descriptor node before engine application; per-engine AS IDs appear only in the apply report.

## Complete Declaration Parser Finding

The existing `asCBuilder::ParseFunctionDeclaration` already parses the complete application declaration used by `RegisterObjectMethod`, `RegisterGlobalFunction`, behaviors, and related registration paths. Its output includes function name, return/parameter types, parameter names, default-expression text, in/out modifiers, member `const`, and fork-specific method traits.

The syntax parser is not currently engine-free:

- `asCParser` obtains tokenizer and engine properties from `asCScriptEngine`;
- template-name classification calls `engine->IsTemplateType`;
- type-existence checks and diagnostics call `asCBuilder`;
- semantic conversion in `ParseFunctionDeclaration` resolves types to `asCDataType` / engine type objects.

The direct coupling is concentrated around tokenizer/options/template lookup/type lookup/diagnostics, but the refactor is not restricted to those call sites. `ThirdParty/Angelscript` is this project's maintained fork source. A cohesive extraction may reorganize the parser, builder, tokenizer, declaration syntax representation, type-query abstraction, and related internal frontend APIs. The constraint is one shared grammar with behavior parity, not a small diff or a pre-approved file list.

The reusable fork entry must return AS-owned engine-independent syntax values and structured diagnostics. A narrow Runtime adapter materializes plugin-owned parsed values and must not leak `asCScriptNode`, `asCDataType`, `asCScriptFunction`, or resolved AS objects into descriptors. Engine registration remains the final semantic authority and receives the retained original declaration.

Declaration-literal formatting has two enforcement layers:

- descriptor validation rejects declaration values containing carriage returns/newlines;
- a token-aware source architecture test rejects adjacent literal fragments, raw multiline literals, and runtime-composed author-written declarations because literal shape is no longer observable after C++ compilation. The test does not require the surrounding C++ call or fluent chain to remain on one line.

## Re-review Findings: Derived Declarations

The current source does not consist exclusively of author-written literal declarations. Production providers derive declarations from reflected classes, struct/delegate names, generated property names, and enumerated value-type names:

- `Bind_AActor.cpp` builds spawn declarations from a reflected `UClass`;
- `Bind_UActorComponent.cpp` builds create/get declarations from reflected component class names;
- `Bind_Delegates.cpp` builds copy/assignment and delegate signature declarations;
- `Bind_UStruct.cpp` builds copy/assignment/property declarations from reflected struct metadata;
- `Bind_Primitives.cpp` builds boolean accessor declarations from property names;
- `Bind_FString.cpp` builds operator/constructor declarations across a table of value types.

Consequently, the one-token literal rule is sound for ordinary author-written callsites but cannot be the complete migration model. Raw dynamic `FString` overloads would weaken identity and preflight. The selected path is a restricted expansion definition that materializes ordinary children before snapshot freeze.

The deeper source pass found that expansion must run at snapshot materialization rather than only inside `Registry.Register()`. `Bind_FString_Conversion` iterates the current ToString list and generates methods for entries contributed by many earlier bind callbacks. Optional packages can also contribute metadata after the `FString` package definition is registered. Only a complete enabled-catalog view can expand that family without restoring registration-order coupling.

## Re-review Findings: Auxiliary Provider Side Effects

A focused `rg -l` scan over `AngelscriptRuntime` production headers/sources found:

| Pattern | Files |
|---|---:|
| `FAngelscriptType::Register(` | 43 |
| `FToStringHelper::Register` | 33 |
| `RegisterTypeFinder` | 13 |
| `FAngelscriptBindDatabase::Get` | 9 |

For example, `Bind_FVector.cpp` registers its AS surface and also registers an `FToStringHelper`, an `FAngelscriptType`, and a type finder. A deeper source inspection classifies the known high-volume stores:

- `GetTypeDatabase()` routes to `FAngelscriptEngine::GetTypeDatabase()` and otherwise a static `LegacyDatabase`;
- `GetToStringList()` routes to `FAngelscriptEngine::GetToStringList()` and otherwise a metadata-only `LegacyToStringList`; resolved `asITypeInfo*` is explicitly engine-local;
- `FAngelscriptBindDatabase::Get()` routes to `FAngelscriptEngine::GetBindDatabase()` and otherwise a static `LegacyBindDatabase`.

Therefore the selected classification is:

- known type/alias/finder/well-known-slot/ToString/bind-database operations -> auxiliary descriptors applied to explicit engine-owned stores;
- genuine process/module-scoped services found by the remaining full inventory -> ordinary module bootstrap and registration/removal handles outside Bind construction;
- exceptional engine-aware behavior -> narrowly allowlisted custom node.

The new path must use instance APIs rather than current-engine resolution. Each engine gets fresh `FAngelscriptType` adapter instances, finder closures resolving those instances, independent ToString entries/type infos, and its own bind-database contributions. Executing these operations implicitly while constructing `FAngelscriptBind` would violate the side-effect-free draft contract and make isolated registry/multi-engine tests non-deterministic.

## Re-review Finding: `Binds.Cache`

`FAngelscriptBindDatabase::Serialize` writes `Structs` and `Classes` behind `CacheMagic` and `CacheVersion`. The current records do not contain PackageId, NodeId, catalog fingerprint, raw AngelScript function/property IDs, or callback-order identity.

The cache is therefore a regression surface, not the persistence layer for the new binding catalog. This change should preserve create/load behavior and its reflection-binding meaning. Package/catalog identity belongs in registry snapshots, apply reports, diagnostics, and state dumps. Adding a catalog fingerprint to `Binds.Cache` would be an unrelated schema migration unless implementation later demonstrates a concrete dependency and the OpenSpec is revised.

## Chosen Direction

- Descriptor-first packages, not immediate registration.
- A move-only public `FAngelscriptBind` owns fluent construction; no separate public Builder or explicit `.Build()`/`.Finalize()` object.
- `FAngelscriptBindingRegistry::Register(FAngelscriptBind&&)` is the consume/validate/freeze boundary that creates an internal immutable `FAngelscriptBindingPackage`.
- Complete AngelScript declarations are mandatory and authoritative for every callable. Ordinary author-written declarations remain in one non-multiline string literal; the surrounding C++ expression may wrap normally. There is no `ASParam`, `ASParams`, declaration generation by the ordinary fluent API, or separate `*Decl` API family.
- Reflection-, bind-database-, table-, and catalog-derived declarations use selected snapshot-time expansion definitions, explicit read-only inputs, stable SourceKeys, a restricted writer, and ordinary generated children validated before snapshot freeze.
- Known `FAngelscriptType`, TypeFinder, ToString, and bind-database writes become auxiliary descriptors applied to explicit engine-owned stores; ambient fallbacks remain Legacy-only.
- Reuse the current AS declaration grammar through a parse-context dependency refactor; do not create a binding-only grammar.
- Typed callable traits validate parsed declarations and overload identity but never select, infer, or rewrite the script-visible declaration.
- Runtime-module-owned registry, not a free global singleton.
- Explicit module submission, not static discovery.
- Explicit core manifest, not Build.cs source scanning or generated aggregation.
- Explicit `FAngelscriptEngine&` application, not current-engine lookup.
- Stable node IDs and apply results, not PreviousBind.
- Immutable engine snapshots; late package changes affect new engines only.
- Unregistration is blocked while an active engine lease uses the package.
- Semantic phases and dependency graph for new packages; legacy ordering exists only inside the compatibility adapter.
- Full in-tree manual-bind migration and legacy-off verification in this one change.
- Legacy source remains temporarily available behind one default-on compile gate.

## AngelScript Fork Assessment

The existing AngelScript registration API already returns function/property IDs and supports the required object type, behavior, method, property, global, enum, and funcdef registration calls. The plugin already applies fork-specific traits and native metadata after registration.

The architecture treats the AngelScript fork as a first-class implementation area. The preferred result is a reusable declaration frontend owned by the fork and consumed by both the existing builder/registration path and binding preflight:

- parser, builder, tokenizer, declaration syntax representation, type-query abstractions, and internal frontend APIs may be refactored together;
- current parser grammar and tokenizer behavior remain the compatibility baseline unless an intentional bug fix is separately recorded;
- engine-aware semantic resolution and engine-free catalog validation are supplied through explicit contexts/adapters;
- the reusable syntax value remains AngelScript-fork-owned, while Runtime descriptors, adapted parsed records, and the catalog remain plugin-owned values;
- the applier continues to call existing registration APIs with the retained declaration;
- the apply report records existing return IDs;
- module unload is handled by preventing unload while engines retain native addresses, not by inventing AS unregistration.

Task 0.7 records the current dependency graph and proposed source ownership so the refactor is deliberate, but it is not a feasibility stop gate and does not limit changed fork files. Parser parity remains a required acceptance criterion. A second declaration grammar is not an accepted fallback without revising this OpenSpec.

## Generated Binding Boundary

`refactor-function-binding-strategy` already owns:

- `NativeRuntimeLinked`;
- `BlueprintCallableReflectiveFallback`;
- `NativeModuleFunctionAddress`;
- UHT-emitted shards and layout-version contracts.

This change does not merge those paths into manual Binding Packages. The manual package applier occupies the current hand-written-bind stage and preserves the relative generated-binding stages. Generated binding statistics, RPC routing, cross-module signature restrictions, and layout-version rules remain unchanged.

## Extension Registry Boundary

`FAngelscriptEngineExtensionRegistry` supports attach, detach, and replay against active engines. That behavior is appropriate for stateful optional services and dynamic data such as GameplayTag replay.

Binding Packages have a stricter contract because they install native code addresses and type/function declarations:

- late packages do not mutate an active engine;
- removed packages cannot be unbound from an active engine;
- a package owner cannot unload while an engine lease uses its native addresses.

GameplayTags type/function descriptors migrate to the package registry, while cached tag-value replay remains on the extension registry.
