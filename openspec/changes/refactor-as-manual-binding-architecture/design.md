## Context

The existing hand-written binding system has three different forms of global/implicit coupling:

1. **Discovery coupling:** static `FAngelscriptBinds::FBind` objects append opaque callbacks to a process-wide array before module startup.
2. **Target coupling:** callbacks and `FAngelscriptBinds` wrappers resolve `FAngelscriptEngine::Get()` instead of receiving the target engine.
3. **metadata coupling:** the last AS function/property ID is stored in `FAngelscriptBindState`, and later helpers/macros mutate that object through a PreviousBind protocol.

This shape makes a normal binding appear fluent at the callsite while hiding package ownership, target engine, ordering dependencies, returned IDs, failure handling, extension lifetime, and cache identity. It also makes removal of the legacy path difficult because StaticJIT, documentation, timing, configuration, and tests consume its implicit state.

The repository already supports multiple `FAngelscriptEngine` instances and has engine-owned runtime state. The new architecture must build on that direction: replayable C++ metadata can be process-level, but all `asITypeInfo*`, `asIScriptFunction*`, function/property IDs, and applied state must belong to one explicit engine.

The capability identifier `as-typed-bind-dsl` is historical. The public authoring surface is a C++ **fluent Bind API**, not a new textual DSL; its implementation deliberately reuses/refactors the maintained AngelScript declaration frontend so complete AS declarations are parsed consistently.

## Goals / Non-Goals

**Goals:**

- Make every manual provider, package owner, package identity, dependency, target engine, descriptor node, registration result, and module-lifetime relationship explicit.
- Build and validate descriptors without mutating an AngelScript engine.
- Preserve fluent typed C++ registration ergonomics without global PreviousBind state.
- Make complete AngelScript declarations authoritative for every callable descriptor, require ordinary author-written declarations to remain in one non-multiline string literal, parse declarations before catalog freeze, and validate them against typed C++ callables without having the fluent API generate declarations.
- Materialize reflection-, bind-database-, and catalog-derived declarations through deterministic snapshot-time expansion rather than raw dynamic declaration overloads or apply-time callbacks.
- Represent engine-scoped type adapters, aliases, type finders, ToString metadata, well-known type slots, and bind-database contributions as replayable auxiliary descriptors applied to explicit engine-owned stores.
- Give every engine an immutable, reproducible catalog snapshot.
- Preserve existing script-visible declarations and behavior while making catalog and diagnostic identity deterministic.
- Migrate all in-tree Runtime, GameplayTags, and GAS manual binds in one OpenSpec lifecycle.
- Keep the old API temporarily source-compatible and make its eventual deletion mechanical.

**Non-Goals:**

- Intentionally adding or changing AngelScript syntax, preprocessing directives, compiler semantics, VM behavior, bytecode, or calling conventions. `ThirdParty/Angelscript` is maintained fork source and its relevant parser, builder, tokenizer, declaration-model, type-query, and internal frontend code may be refactored or reorganized to preserve that behavior through one reusable declaration frontend.
- Replacing UHT-generated function bindings, reflective fallback, native-module function-address shards, or RPC routing.
- Replacing `FAngelscriptEngineExtensionRegistry`; dynamic extension replay remains a separate lifecycle.
- Unbinding declarations or native function addresses from a live AngelScript engine.
- Automatically destroying/recreating engines, worlds, or script state when a module changes its packages.
- Making package registration or engine application callable from arbitrary threads in v1.
- Creating a generic process-global service registry for arbitrary provider side effects. Genuine module-scoped services remain ordinary module lifecycle code with explicit handles.
- Removing the legacy compatibility source in this change.
- Redesigning `Binds.Cache` into binding-catalog persistence. Its existing reflection-binding schema and create/load behavior remain a separate compatibility surface.

## Decisions

### 1. Runtime module owns an explicit registry service

`FAngelscriptRuntimeModule` SHALL contain an `FAngelscriptBindingRegistry` member. Core providers return `FAngelscriptBind` drafts, which module startup submits to that member before primary-engine creation.

External modules obtain the Runtime module instance through `FModuleManager`, call its instance method `GetBindingRegistry()`, register their owned `FAngelscriptBind` drafts, and retain the returned handle:

```cpp
auto& Runtime = FModuleManager::LoadModuleChecked<FAngelscriptRuntimeModule>(
    TEXT("AngelscriptRuntime"));

FAngelscriptBindingRegistrationResult Result =
    Runtime.GetBindingRegistry().Register(CreateBind_FGameplayTag());

GameplayTagsBindingHandle = MoveTemp(Result.Handle);
```

There is no new `FAngelscriptBindingRegistry::Get()` singleton. Registry mutation is game-thread-only and guarded with explicit runtime checks.

**Alternatives rejected:**

- A free static registry would preserve the ownership problem under a new name.
- One registry per engine would require every module to replay packages manually and would not provide a stable pre-engine catalog.
- Reusing `FAngelscriptEngineExtensionRegistry` would incorrectly permit active-engine replay of native declarations.

### 2. Engine dependencies receive the catalog source explicitly

`FAngelscriptEngineDependencies` SHALL carry an explicit shared catalog-source interface. Production subsystem/factory paths receive the Runtime module registry; tests can inject an isolated registry.

At `FAngelscriptEngine::Initialize()`:

1. the engine constructs its owned type, ToString, and bind-database stores;
2. it loads `Binds.Cache` under the existing configuration and captures explicit reflection/config/bind-database expansion inputs;
3. it requests a materialized catalog snapshot lease from the injected source;
4. the registry validates the package graph, runs deterministic expansions, and freezes the snapshot;
5. the engine retains the lease until teardown;
6. the applier receives `FAngelscriptEngine&`, its explicit auxiliary stores, and that snapshot;
7. teardown releases engine-owned AS/auxiliary results before releasing the lease.

The current no-argument engine constructor may remain as a legacy compatibility wrapper while the gate is enabled, but it must construct explicit dependencies before entering the applier. The new applier and fluent Bind types never call `FAngelscriptEngine::Get()` or `TryGetCurrentEngine()`.

**Alternative rejected:** resolving the registry inside `Initialize()` would hide the dependency and make isolated multi-engine tests unreliable.

### 3. `FAngelscriptBind` is the move-only public draft; packages are internal immutable values

`FAngelscriptBind` directly owns package metadata and descriptor construction. It is a move-only draft object:

```cpp
FAngelscriptBind(FAngelscriptBind&& Other);
FAngelscriptBind& operator=(FAngelscriptBind&& Other);
FAngelscriptBind(const FAngelscriptBind&) = delete;
FAngelscriptBind& operator=(const FAngelscriptBind&) = delete;
```

Move construction/assignment must advance or replace the draft owner-generation token so every view previously obtained from the source is deterministically invalid. The implementation therefore must not rely on a defaulted move unless its storage/token design proves that invariant.

There is no public `FAngelscriptBindingPackageBuilder`, `FAngelscriptBindBuilder`, `.Build()`, or `.Finalize()` step. The only commit boundary is:

```cpp
FAngelscriptBindingRegistrationResult
FAngelscriptBindingRegistry::Register(FAngelscriptBind&& Bind);
```

`Register` consumes the draft, parses/normalizes author-written declarations, validates package-local ordinary/auxiliary/expansion definitions, and freezes them into an internal immutable `FAngelscriptBindingPackage`. Invalid input returns a structured `InvalidPackage` result and does not mutate the catalog. Expansion definitions are not executed during package registration. Cross-package dependency validation, explicit input capture, deterministic expansion, generated-child validation, sorting, and final snapshot fingerprinting occur when the registry materializes a catalog snapshot.

An internal package contains:

- stable `PackageId`;
- `OwnerModuleId`;
- `EAngelscriptBindingPhase`;
- `Requires`, `Before`, and `After` package relationships;
- optional legacy bind-name aliases;
- provenance/source location for diagnostics;
- ordered descriptor nodes;
- a deterministic fingerprint excluding process addresses and telemetry.

Node kinds include:

- value/reference/existing-class registration;
- behavior, constructor, factory, destructor, method, and property;
- namespace and global function/property;
- enum and enum value;
- funcdef;
- engine-scoped type-adapter factory, type alias, type finder, well-known type slot, ToString metadata, and bind-database contribution;
- snapshot expansion definition, whose generated children become ordinary frozen snapshot nodes;
- explicit custom apply node for registrations not representable by the ordinary typed surface.

Descriptors may contain native function pointers/call adapters required for replay in the same process. Those addresses do not participate in stable identities, serialized cache identities, state dumps, or cross-process artifacts.

Registry consumption moves descriptors into the immutable internal value. Applying a registered package more than once to different engines does not mutate it.

### 4. Stable identity is derived from semantic binding data

Package IDs use the format:

```text
<OwnerModule>.<TypeOrFeature>
```

Examples:

```text
AngelscriptRuntime.FVector
AngelscriptRuntime.Global.Math
AngelscriptGameplayTags.FGameplayTag
AngelscriptGAS.AbilitySystemComponent
```

Ordinary node IDs are derived from:

```text
PackageId + NodeKind + normalized owner/namespace + normalized AS declaration
```

Custom nodes require an explicit unique node name because no canonical declaration exists. Duplicate semantic IDs are validation errors.

Auxiliary and expansion-definition node IDs use:

```text
PackageId + NodeKind + explicit stable AuxiliaryId/ExpansionId
```

An expansion definition also declares an integer `ExpansionRevision`. Generated child nodes use the ordinary semantic NodeId rule after their complete declarations are materialized and normalized. Their provenance additionally records the source ExpansionId, stable source key, contributing PackageIds, and input fingerprint; those provenance fields affect catalog fingerprinting but do not replace the child's declaration-based NodeId.

The catalog fingerprint hashes the sorted, normalized package/node identities, phases, dependencies, AS declarations, trait values, compile-out/native metadata identities, auxiliary metadata identities, expansion IDs/revisions, explicit expansion-input fingerprint, materialized child identities, and relevant binding configuration. It excludes pointer values, raw AS IDs, registration duration, source absolute paths, and process-local addresses.

Raw AS function/property IDs remain per-engine apply results and are never used as cross-engine package identity.

### 5. `FAngelscriptBind` directly provides the descriptor-first fluent API

The public construction family is:

- `FAngelscriptBind`: move-only root that owns PackageId, OwnerModuleId, phase, dependencies, and every descriptor;
- `TAngelscriptBindType<T>`: lightweight typed view into one type owned by the root;
- `FAngelscriptBindGlobals`: lightweight global/namespace view into the root;
- `FAngelscriptBindEnum`: lightweight enum view into the root;
- `FAngelscriptBindNode`: lightweight view that identifies one descriptor node and exposes its traits.

The longer architecture names remain on lifecycle and result types where the extra precision is useful: `FAngelscriptBindingPackage` is an internal frozen value, while `FAngelscriptBindingRegistry`, `FAngelscriptBindingCatalogSnapshot`, `FAngelscriptBindingCatalogLease`, `FAngelscriptBindingApplier`, and `FAngelscriptBindingApplyReport` describe system roles.

Representative usage:

```cpp
FAngelscriptBind CreateBind_FVector()
{
    FAngelscriptBind Bind(
        TEXT("AngelscriptRuntime.FVector"),
        TEXT("AngelscriptRuntime"));

    Bind.Phase(EAngelscriptBindingPhase::Foundation)
        .Requires(TEXT("AngelscriptRuntime.Primitives"));

    auto FVector_ = Bind.ValueClass<FVector>("FVector")
        .POD()
        .BasicMathType();

    FVector_.Constructor("void f()", [](FVector* Address)
    {
        new(Address) FVector(0.f);
    })
        .NoDiscard()
        .TrivialNativeConstructor("FVector", "0.f");

    FVector_.Method<&FVector::Size>("float64 Size() const")
        .TrivialNative();

    FVector_.Method<&FVector::Equals>(
        "bool Equals(const FVector& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const")
        .TrivialNative();

    FVector_.Method(
        "FVector opAdd(const FVector& Other) const",
        static_cast<FVector(FVector::*)(const FVector&) const>(&FVector::operator+))
        .TrivialNative();

    return Bind;
}

FAngelscriptBindingRegistrationResult Result =
    Registry.Register(CreateBind_FVector());
```

This is intentionally one public concept rather than a `Bind`/`BindBuilder` pair. `FAngelscriptBind` is the thing a provider authors and returns; the registry is the component that turns it into a package. The name `Package` is not used for the high-frequency public construction type, avoiding confusion with Unreal's `UPackage`.

Root-level package configuration methods such as `Phase`, `Requires`, `Before`, `After`, and legacy-alias migration metadata return `FAngelscriptBind&`, so package configuration and descriptor creation belong to the same fluent object.

Every callable entry point (`Method`, global `Function`, `Behaviour`, `Constructor`, `Factory`, and funcdef-related declarations) requires one complete AngelScript declaration. The declaration is the sole authority for the script-visible return type, name, parameter types/names/default expressions, reference directions, method `const`, and declaration attributes. The callable supplies the native target and typed compatibility evidence; fluent node options supply documentation, StaticJIT/native form, compile-out, editor-only, and other plugin metadata.

There is no `ASParam`, `ASParams`, automatic declaration generation, or separate ordinary-versus-`*Decl` API split. Complex declarations such as `?&`, template placeholders, object-first/object-last adapters, and generic call interfaces use the same full-declaration entry points. Validation level is derived from the descriptor/callable category and the available type mapping; it is not a provider-controlled downgrade switch.

The exact macro-free callable wrapper may use non-type template parameters, an explicit `static_cast`, or an equivalent typed overload helper. The required behavior is:

- the complete AS declaration is never inferred from the C++ callable;
- C++ overload selection is explicit at compile time and is never selected from the declaration string;
- callable category, return type, argument types, and const-member status are compared with the parsed declaration where the binding type resolver has an exact mapping;
- typed callables with complete mappings require `Full`; `Partial` is allowed only for documented adapter/type-mapping gaps and still validates every comparable field; `SyntaxOnly` is limited to generic/native-erased call paths; `Custom` is limited to explicit custom nodes with dedicated validation;
- a provider cannot choose a weaker validation level to suppress a detectable mismatch;
- the original declaration is retained for engine application, while a token-normalized declaration is used for stable identity and diagnostics.

**Alternative rejected:** structured `ASParam` metadata still duplicates parameter names/defaults from the existing declarations, makes migration more verbose, and creates a second declaration-generation system whose output could diverge from the AngelScript parser.

### 6. Complete declarations are parsed through one reusable language boundary

The current AngelScript frontend already parses function declarations through `asCParser` / `asCBuilder::ParseFunctionDeclaration`, including parameter names, default expressions, reference directions, method `const`, and fork-specific method attributes. That parser currently reads tokenizer/configuration/type information through `asCScriptEngine` and reports diagnostics through `asCBuilder`.

`ThirdParty/Angelscript` is source owned by this project; the directory name does not make it an immutable vendor boundary. Implementation SHALL extract or refactor one reusable, engine-independent declaration frontend inside the maintained AS fork rather than create an unrelated binding-only grammar. It may change and reorganize the relevant parser, builder, tokenizer, declaration syntax model, type-query abstraction, and internal frontend APIs wherever that produces the cleanest shared language-processing boundary.

The existing builder/registration path SHALL consume that shared frontend through its engine-aware semantic-resolution and diagnostic context. The binding-catalog path SHALL consume the same frontend through an engine-free textual/catalog type-query and structured-diagnostic context. The design is judged by ownership, purity, reuse, and behavior parity—not by minimizing the count of changed `ThirdParty/Angelscript` files.

The reusable frontend returns an AngelScript-fork-owned, engine-independent syntax value plus structured syntax diagnostics. A narrow Runtime adapter converts that value into a plugin-owned pure record such as `FAngelscriptParsedFunctionDeclaration`. Fork code does not depend upward on Runtime binding types, and `asCScriptNode`, `asCDataType`, `asCScriptFunction`, resolved engine objects, and registration IDs do not escape into public or frozen binding descriptors.

Registration-time processing is:

```text
complete declaration text with no embedded line break
    -> syntax parse through reusable AS declaration grammar
    -> AS-owned engine-independent syntax value
    -> Runtime-owned parsed declaration value
    -> token normalization
    -> typed callable compatibility validation
    -> immutable descriptor/package freeze
```

Apply-time processing still passes the retained complete declaration to the target AngelScript engine. The engine performs its normal semantic type resolution, name-conflict checks, calling-convention checks, property validation, and registration. The binding parser does not replace final engine validation and does not re-render a new declaration for application.

Intentional parser-language behavior changes are out of scope for this binding redesign: the refactor must preserve the current grammar, tokens, configuration switches, default-expression handling, error locations, and registration results. Parser parity tests run both the reusable declaration entry and the existing engine registration path over the same declaration corpus. If implementation reveals a real parser bug worth fixing, it is recorded as an explicit behavior delta with its own positive/negative tests instead of being hidden inside the architectural refactor.

### 7. Complete declaration text stays inside one non-multiline literal

Every ordinary author-written full declaration argument in a migrated/new binding callsite is contained in one ordinary C++ string literal whose text has no physical or embedded line break. This rule applies only to the declaration literal: the surrounding `Method`/`Function` call, template/callable expression, closing parenthesis, and fluent options may wrap across as many source lines as normal C++ formatting requires. Adjacent string-literal concatenation, raw multiline literals, embedded `\r`/`\n`, and author-written declaration fragments assembled at runtime are forbidden because the complete signature would no longer be visibly contained in one `"..."` literal.

Several current production providers derive declarations from reflection, bind-database records, enumerated type tables, or auxiliary metadata. They use the snapshot expansion model in section 7B and cannot bypass descriptor preflight through arbitrary `FString` overloads.

Required:

```cpp
FVector_.Method<&FVector::Equals>(
    "bool Equals(const FVector& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const")
    .TrivialNative();
```

Forbidden:

```cpp
FVector_.Method<&FVector::Equals>(
    "bool Equals(const FVector& Other, "
    "float64 Tolerance = KINDA_SMALL_NUMBER) const");
```

The descriptor validator rejects declaration values containing line breaks. A source architecture test performs the literal-shape check that runtime values cannot observe: exactly one non-multiline string token contains each ordinary author-written complete declaration. It does not enforce a single-line C++ call expression. This binding-declaration rule is separate from `Documents/Rules/ASInlineFormattingRule.md`, which governs multiline AngelScript programs embedded in C++ tests.

### 7B. Derived declarations use deterministic snapshot expansion

Ordinary authoring entry points accept only the compile-time/literal declaration form; they do not add a general `FString` overload. Reflection-, bind-database-, table-, or catalog-derived declarations use a separate advanced expansion definition owned by the same `FAngelscriptBind` root:

```cpp
using FAngelscriptBindingExpansionFunction = void(*)(
    const FAngelscriptBindingExpansionContext&,
    FAngelscriptBindingExpansionWriter&);

Bind.Expansion(
    TEXT("FString.ToStringConversions"),
    /* ExpansionRevision = */ 1,
    &ExpandFStringToStringConversions);
```

`Expansion` returns an `FAngelscriptBindNode` like other root entries; it does not introduce another builder/finalizer. The expansion function is a non-capturing/static function pointer. Process addresses are retained only so this process can execute the expansion and are excluded from identity. The owning registration handle and every snapshot containing its output retain the contributing package/module lease, so the code cannot unload while an expansion or derived native callable remains reachable.

`Registry.Register()` validates and freezes the expansion definition—PackageId, ExpansionId, revision, provenance, declared input capabilities, and function category—but does not run it. Expansion runs while materializing a catalog snapshot because some outputs depend on the complete enabled catalog. `Bind_FString` is the representative case: its generated conversion methods consume ToString metadata contributed by many packages, including optional packages registered after the `FString` package itself.

`FAngelscriptBindingExpansionContext` is read-only and contains only explicit inputs:

- the enabled, phase/dependency-sorted package and auxiliary-descriptor catalog view;
- normalized binding configuration and disabled-package selection;
- a game-thread-captured reflection query/input view whose consumed records have stable object paths, field/type names, flags, and declaration-relevant metadata;
- an optional immutable view of the selected engine's already-loaded `FAngelscriptBindDatabase` input;
- stable source keys and fingerprint recording for every input record consumed.

It exposes no `FAngelscriptEngine&`, `asIScriptEngine*`, current-engine lookup, mutable registry, mutable package, filesystem query, clock, random source, or arbitrary service locator.

`FAngelscriptBindingExpansionWriter` is the only way an expansion emits output. It may emit ordinary callable/property/type/enum descriptors and approved auxiliary descriptors, but it cannot:

- register anything into an engine or module service;
- mutate a registered package definition;
- submit another package or recursively invoke an expansion;
- emit a custom apply callback;
- omit a stable `SourceKey` and contributing PackageId for a generated child.

The writer creates an opaque `FAngelscriptDerivedDeclaration` value from complete generated text plus ExpansionId, SourceKey, input fingerprint, and provenance. Its constructor is private to the expansion boundary; it is not implicitly constructible from `FString` and cannot be passed through the ordinary author-written literal overload. Generated child entry points remain the same semantic families (`Method`, `Function`, `Behaviour`, `Constructor`, `Factory`, and property/enum equivalents) on the restricted writer rather than introducing `MethodDecl`/`FunctionDecl` APIs.

Snapshot materialization is:

```text
registered immutable package definitions
    -> select enabled packages
    -> validate phase/dependency graph
    -> capture explicit reflection/config/bind-database inputs
    -> index auxiliary descriptor metadata
    -> run expansions by package order, then lexical ExpansionId
    -> order each expansion's source records by stable SourceKey
    -> materialize ordinary child descriptors
    -> parse every complete generated declaration through the shared AS frontend
    -> normalize + policy-derived callable validation
    -> assign child NodeIds + detect authored/generated collisions
    -> fingerprint definitions + explicit inputs + materialized outputs
    -> freeze immutable FAngelscriptBindingCatalogSnapshot
```

Expansion errors—missing declared input capability, unstable/duplicate SourceKey, recursive expansion, line break, invalid declaration, callable mismatch, duplicate child identity, or different outputs from equivalent inputs—fail snapshot acquisition before any target AS registration or auxiliary engine-store mutation. Diagnostics identify PackageId, ExpansionId/revision, SourceKey, contributing package, original generated declaration, input provenance, and parse/validation location.

Equivalent package definitions and explicit input snapshots must produce byte-equivalent normalized child records and the same catalog fingerprint even when registration order, UObject addresses, native function addresses, or process absolute paths differ. A changed reflection/bind-database/config input that changes emitted semantics changes the expansion-input/catalog fingerprint. A leased snapshot never changes in place; the changed input is visible only to a later snapshot/engine.

### 7C. Auxiliary registrations are explicit engine-scoped descriptors

The focused source review shows that the highest-volume "non-AS" operations are already intended to be engine-owned:

- `FAngelscriptType::Register`, aliases, type finders, and well-known type slots route to the current engine's `FAngelscriptTypeDatabase`;
- `FToStringHelper::Register` routes to the current engine's ToString list, whose entries may cache an engine-local `asITypeInfo*`;
- `FAngelscriptBindDatabase::Get` routes to the current engine's bind database for loaded cache inputs and generated reflection-bind outputs.

Their defect is ambient target selection plus a no-current-engine fallback—not that they should become process-global. The new fluent root therefore supports explicit auxiliary descriptor entries such as:

```cpp
Bind.TypeAdapter(...);
Bind.TypeAlias(...);
Bind.TypeFinder(...);
Bind.WellKnownType(...);
Bind.ToString(...);
Bind.BindDatabaseContribution(...);
```

These are advanced entries on `FAngelscriptBind`, return `FAngelscriptBindNode`, carry an explicit stable AuxiliaryId, and participate in package/node ordering, duplicate validation, fingerprinting, diagnostics, apply results, and module leases. They do not mutate a database while the draft or registered package is constructed.

The apply context exposes explicit engine-owned targets:

- `FAngelscriptTypeDatabase&`;
- a new `FAngelscriptToStringRegistry&` extracted from the raw engine-owned `TArray<FToStringType>`;
- `FAngelscriptBindDatabase&`;
- `FAngelscriptEngine&` / `asIScriptEngine&` only for descriptor kinds that genuinely need AS registration or post-registration resolution.

Type-adapter descriptors retain a factory/adapter definition and create a fresh `TSharedRef<FAngelscriptType>` for each engine. The frozen catalog never reuses an adapter object that may acquire engine-local state. Type-alias, type-finder, and well-known-slot descriptors reference stable type-adapter node identities; apply resolves those references to the adapter instance created for the selected engine. A type finder factory creates an engine-local closure capturing only that engine's resolved adapter instances.

ToString descriptors contain stable TypeName, ToStringId, flags, and the native conversion function. They serve two roles without ambient state:

1. catalog metadata consumed by the `FString.ToStringConversions` expansion;
2. an engine apply node that creates the selected engine's ToString registry entry.

Any resolved `asITypeInfo*` stays in the engine-owned registry/result and is populated only after its AS object type exists. It never enters the package, expansion input, NodeId, or catalog fingerprint.

`FAngelscriptBindDatabase` keeps its current serialized `Structs`/`Classes` contract. Engine initialization constructs it and loads `Binds.Cache` before requesting a snapshot, then passes an immutable view as explicit expansion input. In non-cache/generation modes, expansion may emit bind-database contribution descriptors; the applier writes those records to the selected engine database before the existing save/clear stage. `BoundEnums`, `BoundDelegateFunctions`, and header-link contributions remain engine-local non-catalog results. Catalog identity is not serialized into `Binds.Cache`.

The new core calls instance APIs on these explicit engine stores. Static `FAngelscriptType::*`, `FToStringHelper::*`, and `FAngelscriptBindDatabase::Get()` ambient forwarding remains only inside the Legacy compatibility surface while `WITH_ANGELSCRIPT_LEGACY_BINDS=1`; migrated production providers cannot call it.

The full provider inventory must still classify any genuinely process/module-scoped registration it finds. Such a service is initialized once from the owning module's `StartupModule()`, returns a module-owned removal handle, and is unwound in `ShutdownModule()` after package unregistration succeeds. It is not replayed per engine and is not hidden inside `FAngelscriptBind` construction. The change does not add a generic arbitrary-service callback framework.

Known type/ToString/finder/bind-database operations are not eligible for the custom-node allowlist. A duplicate AuxiliaryId, unresolved referenced type adapter, null per-engine factory result, or auxiliary apply failure is a structured required-node failure; engine initialization remains fail-closed and does not publish the partial engine.

### 8. Chainability uses explicit Bind views, not PreviousBind

Every member/global/property registration call returns an `FAngelscriptBindNode` containing:

- a reference/index to the owning `FAngelscriptBind` storage;
- a draft-local node slot/key identifying the descriptor being configured;
- the owner kind/identity needed to resume the corresponding type/global/enum fluent surface without retaining a pointer to a temporary view object.

Trait methods mutate that node and return the view. The node view forwards subsequent `Method`, `Property`, `Constructor`, and related calls to its owner and returns a view for the new node. This permits:

```cpp
.Method(...).NoDiscard().Documentation(...).Method(...)
```

without `.EndMember()`.

There is no process-wide or engine-wide active-node slot. A copied node view continues to address the same descriptor node; it cannot be rebound by another registration call. Type/global/enum/node views do not own descriptors and are valid only while the originating `FAngelscriptBind` remains in the same draft instance. Moving the root or consuming it through `Register` invalidates all prior views. Development checks SHALL use an owner/generation token or equivalent mechanism to diagnose view use after root move or registration.

For author-written and auxiliary draft nodes, the final semantic NodeId is assigned when `Register` parses/normalizes as applicable and freezes the immutable package definition. For expansion-generated children, the final NodeId is assigned during snapshot materialization after the complete derived declaration exists. Earlier diagnostics identify PackageId, draft node ordinal/key or ExpansionId/SourceKey, provenance, and original declaration; they include a final NodeId only when one has actually been assigned.

`FAngelscriptBind` itself remains the owner of all chaining capability: the view types are navigation cursors, not separately finalized builders. This preserves concise chaining without introducing a second public object whose relationship to `FAngelscriptBind` must be explained.

The state transition is explicit:

```text
mutable Draft
    -> move construction: new Draft; source and its prior views invalid
    -> Register(FAngelscriptBind&&): source consumed; all prior views invalid
        -> success: internal immutable FAngelscriptBindingPackage enters catalog
        -> failure: structured diagnostics; no catalog mutation
```

No destructor, RAII scope, view lifetime, or provider return performs registration implicitly.

Traits cover the current feature set:

- editor-only;
- deprecation message;
- property accessor;
- callable/not-callable;
- no-discard;
- world-context requirement;
- generated accessor;
- implicit constructor;
- compile-out and method-chain compile-out;
- force-constant argument expressions;
- argument-determines-output-type;
- pass script function/object type;
- pure constant global property;
- documentation;
- StaticJIT/native form.

### 9. Catalog ordering uses phases and a dependency graph

New phases are:

```cpp
enum class EAngelscriptBindingPhase : uint8
{
    Foundation,
    Default,
    Late,
};
```

New packages express relationships with stable package IDs:

- `Requires(X)`: X must exist and execute first.
- `After(X)`: if X exists, execute after it.
- `Before(X)`: if X exists, execute before it.

Validation rejects:

- missing required packages;
- self-dependencies;
- dependency cycles;
- a relationship that would require a later phase to execute before an earlier phase;
- duplicate package or node identities;
- owner/handle mismatches;
- invalid declarations, declaration values containing line breaks, or callable-incompatible declarations;
- new/legacy collisions that are not an intentional alias replacement.

New-package deterministic ordering is:

1. phase ordinal;
2. topological dependency order;
3. stable PackageId lexical order for otherwise independent packages.

Within one materialized package, apply nodes use deterministic bands:

```cpp
enum class EAngelscriptBindingNodeBand : uint8
{
    DeclareTypes,
    RegisterMembersAndGlobals,
    PublishAuxiliaryMetadata,
    FinalizeAuxiliaryMetadata,
};
```

Structural edges are inferred where unambiguous: an object/enum declaration precedes its members/values, a type finder or well-known slot requires its referenced type-adapter node, and post-registration `asITypeInfo*` resolution follows its AS type declaration. `FAngelscriptBindNode::RequiresNode(OtherView)` may add an explicit same-package edge using draft-local keys; `Register` resolves it to frozen NodeIds. Expansion-generated children use stable SourceKeys for equivalent writer-local edges. Cross-package relationships continue to use `Requires`/`Before`/`After`.

Within a band, node dependencies are topologically sorted and otherwise independent nodes use stable NodeId lexical order. Source construction order, pointer value, and expansion emission order do not choose apply order. Validation rejects node self-dependencies, cycles, cross-Bind draft views, band inversions, and references to a disabled/missing required node.

Expansion-definition nodes are snapshot-build inputs rather than apply nodes and do not occupy an apply band.

`FAngelscriptBinds::EOrder` is not exposed by the new API. The Legacy adapter maps `Early`, `Normal`, and `Late` to `Foundation`, `Default`, and `Late`.

During gradual migration, an intentional legacy alias can occupy the old callback's compatibility slot so replacing one provider does not reorder the remaining legacy callback pass. Registration ordinal is allowed only inside the Legacy adapter. After all in-tree migration, the legacy-disabled path uses only the deterministic new ordering. Any previously implicit same-tier dependency discovered by characterization tests must become an explicit package relationship.

### 10. Core providers use one explicit manifest

The authoritative built-in list is:

```text
Plugins/Angelscript/Source/AngelscriptRuntime/Binds/AngelscriptCoreBindingPackages.def
```

The manifest contains one stable entry for every built-in provider and is included with controlled macros to declare and submit providers. It records package ID/provider symbol and, during migration only, its legacy bind alias/compatibility position.

Every migrated bind file exposes a predictable function:

```cpp
FAngelscriptBind CreateBind_FVector();
```

The provider returns one move-only draft and has no registry dependency. Module startup expands the manifest and explicitly passes each returned value to `FAngelscriptBindingRegistry::Register(FAngelscriptBind&&)`. The provider does not finalize, auto-submit, or create a static registrar.

Adding or removing a core bind requires an explicit manifest diff. Architecture tests compare production providers with manifest entries and reject missing, duplicate, or stale entries.

**Alternatives rejected:**

- Build.cs directory scanning/generated aggregation hides registration membership in build logic.
- A manually repeated declaration/call list creates two sources of truth.
- Static constructor discovery retains the original problem.

### 11. Preflight precedes application; application is fail-closed

Snapshot creation performs catalog-level preflight without mutating an AS engine:

- identity and owner validation;
- dependency and phase validation;
- deterministic sorting;
- explicit reflection/config/loaded-bind-database input capture and fingerprinting;
- auxiliary metadata indexing;
- deterministic expansion execution and child materialization;
- complete author-written and generated-declaration syntax parsing and token normalization;
- declaration-value line-break validation;
- callable/declaration compatibility using the strongest policy-derived `Full`, `Partial`, `SyntaxOnly`, or `Custom` validation level permitted by the descriptor/callable category;
- catalog-visible type-resolution availability where preflight can resolve textual AS types;
- expansion SourceKey/contributor/collision/determinism validation;
- legacy/new collision checks;
- disabled-package resolution;
- catalog fingerprint generation.

Some AngelScript registration errors can only be known while materializing types in sequence. The applier therefore:

1. applies only to a fresh, not-yet-published engine;
2. passes an explicit `FAngelscriptBindingApplyContext` to every node;
3. records each AS return code/ID;
4. stops on the first required-node failure;
5. marks the report failed and destroys the incomplete engine;
6. never reports partial registration as usable and never attempts rollback.

Optional custom nodes must declare whether failure is required or intentionally skipped by configuration. An arbitrary ignored negative AS registration result is prohibited.

### 12. Apply results replace raw-ID and PreviousBind consumers

`FAngelscriptBindingApplyReport` contains:

- engine identity and catalog generation/fingerprint;
- ordered package results;
- ordered node results;
- PackageId, NodeId, node kind, normalized declaration, phase, owner, status;
- AS return code and per-engine function/property/type ID when applicable;
- auxiliary engine-store result identity/status when applicable;
- structured diagnostics;
- optional development timing.

An internal observer/listener interface receives `(Descriptor, NodeResult, ApplyContext)` after each successful registration. StaticJIT/native form, documentation, bind state observation, and diagnostic/state-dump consumers attach data through this explicit tuple.

Observers cannot query a "previous" node. A consumer requiring `asCScriptFunction*` resolves it from the current apply context and that node's returned ID.

`FAngelscriptBindExecutionObservation` remains as a compatibility/diagnostic facade during migration but reads the most recent apply report. It reports package/node identity and derives the old bind-name/phase fields where available.

Snapshot construction separately emits `FAngelscriptBindingCatalogBuildReport` containing the expansion-input fingerprint, ordered expansion results, generated child counts/identities, diagnostics, and optional timing. Apply reports reference the build report/snapshot fingerprint but do not treat expansion as an AS apply callback.

### 13. Late registration changes only future engines

The registry tracks a monotonically increasing catalog generation. Registering a valid package:

- fails without mutation on duplicate/invalid identity;
- succeeds immediately in the catalog;
- returns `Registered` when no active engine snapshot predates it;
- returns `RegisteredRequiresEngineRecreate` plus affected engine IDs when active snapshots do not include it.

Active engines are never incrementally mutated. A new or recreated engine obtains the latest snapshot.

Required registration statuses:

```text
Registered
RegisteredRequiresEngineRecreate
InvalidPackage
DuplicatePackageId
OwnerMismatch
```

The registration result includes diagnostics and a movable `FAngelscriptBindingRegistrationHandle` only on success.

**Alternatives rejected:**

- Incremental application cannot be transactional and changes type/function IDs under live scripts.
- Rejecting all late registration prevents optional modules from becoming available to a later engine.

### 14. Snapshot leases make module unload safety explicit

Each engine holds an `FAngelscriptBindingCatalogLease`. The registry can therefore identify which active engines use each package.

`TryUnregisterPackage(Handle)` returns:

```text
Unregistered
InUseByEngine
UnknownHandle
OwnerMismatch
```

If no active lease includes the package, the registry removes it from future generations and returns `Unregistered`.

If any lease includes it:

- the operation returns `InUseByEngine`;
- the package remains registered;
- diagnostics include the blocking engine IDs;
- the owning module must not unload;
- the caller destroys/recreates those engines and retries.

Registration-handle destruction does not attempt an implicit unregister because unregister can fail. In development, destroying a still-registered handle or entering owner shutdown with an in-use package produces a hard diagnostic. In-tree package-owning modules reject uncoordinated dynamic reload while a handle exists. Normal shutdown order is:

```text
detach/destroy AS engines
    -> release catalog leases
    -> unregister external packages
    -> destroy registry
    -> unload modules
```

The registry cannot intercept every arbitrary third-party call to `FModuleManager::UnloadModule`; safe unload is a documented participation contract and is enforced at all in-tree unload entry points.

### 15. Legacy compatibility is isolated behind one build gate

The temporary public definition is:

```text
WITH_ANGELSCRIPT_LEGACY_BINDS
```

`AngelscriptRuntime.Build.cs` behavior:

- if UBT global definitions already contain the symbol, honor its `0/1` value;
- otherwise add `WITH_ANGELSCRIPT_LEGACY_BINDS=1` as the public default;
- reject non-boolean values in compile-settings validation.

The gate is not a `.uplugin` field, config setting, Project Setting, CVar, or AngelScript compile macro.

The Legacy adapter owns:

- `FAngelscriptBinds` forwarding behavior;
- `FBind` static callbacks and force-link compatibility;
- the callback array and compatibility ordering;
- `PreviouslyBoundFunction` / `PreviouslyBoundGlobalProperty`;
- old trait setters and PreviousBind macros;
- temporary ambient-engine scope needed while invoking an opaque callback.

Naming deliberately distinguishes the paths:

- singular `FAngelscriptBind` is the new move-only fluent draft;
- plural `FAngelscriptBinds` is the temporarily compatible legacy facade;
- `FAngelscriptBinds::FBind` is the legacy static callback registrar.

All plural/inner-`FBind` forms remain behind `WITH_ANGELSCRIPT_LEGACY_BINDS`; a later removal does not rename or redesign the singular API.

Only Legacy files can include the old implementation header or use the ambient scope. New registry, fluent Bind API, applier, provider, StaticJIT, and documentation code must compile when the gate is zero and must not depend on Legacy types.

The compatibility scheduler wraps old callbacks as opaque legacy packages. An intentional migrated package with the same legacy alias replaces that callback exactly once; accidental legacy/new duplicates fail before application.

After all in-tree providers migrate:

- the default remains `1` temporarily for downstream source compatibility;
- the repository contains no production use of the old surface outside Legacy;
- build and applicable tests pass with `-Define:WITH_ANGELSCRIPT_LEGACY_BINDS=0`;
- a future cleanup can delete the adapter, forwarding declarations, gate, and legacy-only tests without redesigning the new core.

### 16. `Binds.Cache` remains separate from catalog identity

`FAngelscriptBindDatabase::Serialize` currently persists its reflected `Structs` and `Classes` records behind the existing cache magic/version header. The records do not contain raw AngelScript function/property IDs, PackageIds, NodeIds, callback-order identity, or a binding-catalog fingerprint.

This change therefore does not add catalog identity to `Binds.Cache` and does not use it to persist immutable packages or per-engine apply results. Catalog generation/fingerprint belongs to the registry snapshot, apply report, diagnostics, and state dump.

The migration records a create/load baseline and proves:

- existing reflection-binding records are still produced and loaded successfully;
- equivalent input remains behaviorally deterministic;
- manual-package ordering does not cause the cache to be interpreted as an AS registration-ID map;
- any incidental byte/order difference is characterized rather than silently promoted into a new cache schema.

If implementation later discovers a concrete cache dependency that requires a field or version change, work pauses and this design/spec is revised with the exact producer, consumer, stale-data behavior, and focused tests. A speculative catalog-fingerprint migration is not part of this change.

### 17. Generated bindings and engine extensions remain separate

Manual packages execute at the same initialization stage currently occupied by `CallBinds`. The relative stages for generated native-runtime-linked tables, reflective fallback, native-module function addresses, and RPC handling remain unchanged.

No UHT record, shard, layout, eligibility, or statistics schema changes in this work. Regression tests verify the boundary.

`FAngelscriptEngineExtensionRegistry` remains responsible for attach/detach/replay services. GameplayTags uses:

- Binding Package registry for its type/method/global declarations;
- Engine extension registry for replaying cached tag values or other dynamic engine-local data.

### 18. Validation and architecture enforcement are first-class

New tests cover pure descriptor behavior, registry lifecycle, ordering, application, multi-engine snapshots, module unload, consumers, representative bindings, and complete migration.

Architecture scans fail when non-legacy production sources contain:

- `FAngelscriptBinds::FBind`;
- `GetPreviousBind`, `SetPreviousBind*`, `DeprecatePreviousBind`, or `CompileOutPreviousBind*`;
- new use of PreviousBind documentation/native macros;
- implicit current-engine resolution inside the new binding core;
- a core provider absent from the manifest;
- a Legacy header include from migrated code;
- `WITH_ANGELSCRIPT_LEGACY_BINDS` outside the allowlisted Build.cs, Legacy, compile-validation, and legacy-specific test files.

The migration architecture checks also distinguish ordinary author-written literal declarations from the approved derived-declaration expansion path, and reject unclassified non-AS side effects inside package construction.

## Data Flow

### Module registration

```text
Runtime StartupModule
    -> construct registry
    -> expand AngelscriptCoreBindingPackages.def
    -> provider returns move-only FAngelscriptBind draft
    -> Register(FAngelscriptBind&&) consumes, validates, and freezes it

Optional module StartupModule
    -> Runtime.GetBindingRegistry()
    -> create owned FAngelscriptBind draft
    -> Register(MoveTemp(Bind))
    -> retain registration handle
```

### Engine initialization

```text
FAngelscriptEngine::Initialize
    -> construct explicit engine-owned type/ToString/bind-database stores
    -> load Binds.Cache when configured
    -> capture FAngelscriptBindingExpansionInputs
    -> BindingCatalogSource.AcquireSnapshot(Request)
       -> resolve disabled packages + validate graph + deterministic sort
       -> index auxiliary metadata
       -> run snapshot expansions
       -> parse/normalize/validate generated children
       -> freeze build report + catalog fingerprint
    -> retain immutable catalog lease
    -> create fresh AS engine
    -> Apply(FAngelscriptEngine&, Snapshot)
       -> apply ordinary or auxiliary node to explicit target
       -> capture AS ID or auxiliary result
       -> run explicit descriptor/result observers
       -> append apply report
    -> save/clear bind database under existing configuration
    -> publish engine only after full success
```

### Package removal

```text
owner TryUnregisterPackage(handle)
    -> query active leases
       -> none: remove from future catalog generation
       -> present: return InUseByEngine + EngineIds, no mutation
    -> destroy/recreate blocking engines
    -> retry unregister
    -> unload owner module
```

## Risks / Trade-offs

- **Large mechanical migration can hide semantic changes** → characterize current surface first, migrate by behavior category, and run focused tests after every batch.
- **Legacy same-tier order may encode undocumented dependencies** → retain compatibility slots during mixed migration, then express every discovered dependency explicitly before legacy-off.
- **A broad owned-fork frontend refactor could alter accepted declarations** → keep full declarations authoritative, make both consumers share one frontend, compare reusable-parser results with existing engine registration across the characterized declaration corpus, and separately specify any intentional parser bug fix instead of hiding it in the refactor.
- **Literal concatenation can hide that a signature was split** → reject runtime line breaks in descriptors and add a token-aware source architecture test proving the complete signature is contained in one non-multiline string token, without constraining how the surrounding C++ expression wraps.
- **The typed fluent Bind surface may increase template compile cost** → keep heavy validation/storage non-template in `.cpp`, isolate traits/views, and add representative compile-time measurements before bulk migration.
- **Catalog identity could be conflated with `Binds.Cache`** → keep the reflection bind database schema separate, regression-test create/load behavior, and store package fingerprints only in catalog/report/diagnostic surfaces.
- **Module manager cannot universally veto arbitrary third-party unload** → expose preflight/unregister results, guard in-tree unload paths, disable uncoordinated reload, and hard-diagnose contract violations.
- **A custom apply node could recreate opaque callbacks** → require stable explicit identity, explicit context/result recording, no ambient engine access, architecture review, and an allowlist for custom-node use.
- **Mixed legacy/new scheduling is temporarily complex** → confine compatibility ordering to the adapter, test duplicate replacement, and delete all in-tree legacy uses before the off build.
- **Raw AS IDs may change** → treat them as engine-local results and migrate consumers to stable descriptor identity.
- **External plugins may depend on old headers indefinitely** → default the gate on for the compatibility window, document migration, and prove the new core is independent with a gate-off build.
- **Derived declarations can bypass the literal/full-declaration model** → ordinary APIs accept only literals; the selected restricted snapshot expansion writer is the sole generated-declaration path, and every child passes the same parse/identity/apply reporting path.
- **Aggregate expansions could depend on registration order** → execute only after enabled-package graph resolution, index inputs by stable identities, sort expansions/SourceKeys deterministically, and fingerprint both inputs and outputs.
- **Expansion callbacks could recreate opaque global reads** → require non-capturing/static functions, expose only the restricted explicit context/writer, prohibit engine/service locators, run deterministic replay tests, and architecture-scan migrated providers.
- **Provider callbacks mix AS registration with auxiliary engine state** → represent known type/ToString/finder/bind-database work as explicit auxiliary descriptors and engine-owned targets; keep ambient fallback APIs in Legacy only.
- **Some side effects may genuinely be module-scoped** → classify them during inventory and require ordinary module registration/removal handles outside Bind construction; do not create a generic arbitrary service callback.

## Migration Plan

1. Capture current package names/order, disabled behavior, counts, declarations, traits, `Binds.Cache` create/load behavior, auxiliary provider registrations, StaticJIT/native metadata, documentation, and multi-engine results.
2. Implement pure descriptor identity, typed declarations, node-handle ownership, expansion definitions/writer, auxiliary descriptors, registry validation, snapshots, and unload leases under failing tests.
3. Implement snapshot requests, explicit reflection/config/bind-database inputs, deterministic expansion, catalog build reports, and generated-child validation without connecting production engine startup.
4. Refactor engine-owned type, ToString, and bind-database stores to explicit instance APIs while retaining ambient forwarding only in Legacy.
5. Add explicit catalog-source/input injection and ordinary/auxiliary apply reports to isolated test engines.
6. Add the Legacy adapter/combined compatibility scheduler and prove existing behavior before migrating a provider.
7. Migrate a representative matrix covering every registration kind, the `FString` catalog-aggregate expansion, one reflection/bind-database expansion, every known auxiliary engine-store category, module-scoped classification, and each metadata consumer.
8. Introduce the full core manifest and migrate Runtime providers in dependency-aware batches.
9. Migrate GameplayTags and GAS module-owned providers while retaining dynamic extension replay.
10. Remove in-tree PreviousBind consumers, switch StaticJIT/docs/timing/dump to stable node results, preserve the separate cache contract, and enforce architecture scans.
11. Run the default-on build/tests, then build and test with `WITH_ANGELSCRIPT_LEGACY_BINDS=0`.
12. Restore/verify the default-on build, update Chinese-first documentation, and record final counts/results.
13. Leave the isolated compatibility source present and default-on; remove it only in a later explicitly approved cleanup.

Rollback during implementation is package-granular while the legacy gate is enabled: restore one provider's legacy callback and manifest compatibility entry without reverting the new core or unrelated migrated packages. After legacy-off acceptance, rollback of the new architecture requires reverting this complete change rather than mixing the two cores.

## Open Questions

None. The prior A/B questions are closed as snapshot-time descriptor expansion and explicit lifetime-classified auxiliary registration, with the known type/ToString/finder/bind-database paths applied to explicit engine-owned stores.

Relevant maintained-fork source may change wherever the shared declaration frontend requires it. Any implementation finding that requires an intentional language/registration behavior change, adds an unrestricted dynamic declaration/service callback, changes the `Binds.Cache` schema, or contradicts the module-lifetime/descriptor-identity model requires an explicit design/spec revision before work continues.
