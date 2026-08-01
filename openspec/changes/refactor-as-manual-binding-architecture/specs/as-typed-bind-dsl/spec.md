## MODIFIED Requirements

### Requirement: Typed class binding facade

The system SHALL provide a descriptor-first typed fluent API rooted at a move-only `FAngelscriptBind` for C++ classes and structs. `FAngelscriptBind` SHALL directly own package metadata and mutable draft descriptors; it SHALL NOT delegate new registrations to the immediate, ambient-engine `FAngelscriptBinds` backend.

There SHALL be no separate public `FAngelscriptBindingPackageBuilder` or `FAngelscriptBindBuilder`, and providers SHALL NOT need to call `.Build()` or `.Finalize()`.

Root configuration methods such as `Phase`, `Requires`, `Before`, and `After` SHALL return `FAngelscriptBind&`. Type/global/enum entry points SHALL return non-owning views into that same root, so package configuration and descriptor construction remain one fluent public abstraction.

#### Scenario: Binding a member method through FAngelscriptBind

- **GIVEN** an AngelScript type such as `FColor`
- **WHEN** a provider calls `Bind.ExistingClass<FColor>("FColor").Method<&FColor::ToHex>("FString ToHex() const")`
- **THEN** the draft SHALL contain a method descriptor whose owner, C++ callable, original AS declaration, and draft-local node key can be inspected before engine application
- **AND** its normalized declaration and final stable NodeId SHALL be inspectable after Registry parse/normalize/freeze
- **AND** applying the package SHALL preserve existing script code calling `FColor.ToHex()`.

#### Scenario: Binding a class namespace static function

- **GIVEN** a C++ static or free function that appears under an AngelScript class namespace
- **WHEN** the provider adds it through a `TAngelscriptBindType<T>` or `FAngelscriptBindGlobals` view
- **THEN** the descriptor SHALL record the `FColor` namespace explicitly
- **AND** the applier SHALL restore the previous namespace after registering that node.

#### Scenario: Binding a property through a Bind view

- **GIVEN** a supported C++ data member or explicit offset
- **WHEN** a provider calls `.Property("DWColor", &FColor::DWColor)` or the explicit declaration/offset overload
- **THEN** the descriptor SHALL retain the typed member/offset and resolved AS declaration
- **AND** property registration SHALL not occur until an explicit engine applies the package.

### Requirement: Complete AngelScript declarations are authoritative

Every callable entry point in the fluent `FAngelscriptBind` API SHALL require one complete AngelScript declaration containing the script-visible return type, function name, parameter types, reference directions, method `const`, and declaration attributes where applicable, including parameter names and default expressions wherever the declaration defines them.

The Bind API SHALL NOT expose `ASParam`, `ASParams`, automatic declaration generation, or separate `MethodDecl`/`FunctionDecl`/`BehaviourDecl` escape-hatch families. Ordinary and complex signatures SHALL use the same complete-declaration entry points.

Callable validation level SHALL be derived from callable/descriptor capability. Typed callables with a complete mapping require `Full`; `Partial` is limited to documented adapter/type-mapping gaps and validates every comparable field; `SyntaxOnly` is limited to generic/native-erased call paths; `Custom` is limited to explicit custom nodes. A provider SHALL NOT downgrade validation to suppress a detectable mismatch.

#### Scenario: Complete member declaration is parsed

- **WHEN** a provider supplies `.Method<&FVector::Equals>("bool Equals(const FVector& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const")`
- **THEN** the descriptor SHALL retain that complete declaration as the apply-time authority
- **AND** preflight SHALL parse `bool`, `Equals`, both parameter types/names, the default expression, and the method `const`
- **AND** the normalized declaration SHALL participate in stable NodeId and catalog fingerprint generation.

#### Scenario: Complex declaration uses the same entry point

- **GIVEN** a declaration containing `?&`, template placeholders, object-first/object-last adaptation, or a generic call interface
- **WHEN** the provider adds it through `Method`, `Function`, `Behaviour`, `Constructor`, `Factory`, or the applicable callable entry point
- **THEN** the parser SHALL preserve and normalize the complete declaration through the same descriptor model
- **AND** the descriptor SHALL record whether callable comparison is `Full`, `Partial`, `SyntaxOnly`, or `Custom`.

#### Scenario: Callable disagrees with the declaration

- **WHEN** a provider pairs a typed callable with a declaration whose supported return type, parameter count/type/ref qualifiers, or member `const` disagrees
- **THEN** package validation SHALL fail before engine application
- **AND** diagnostics SHALL identify the PackageId, draft node provenance and declaration, final NodeId if one was assigned, parsed AS shape, callable C++ shape, and each mismatch.

#### Scenario: Provider attempts to weaken validation

- **GIVEN** a typed callable whose mapped return/argument/member-const shape is fully comparable
- **WHEN** a provider attempts to mark it `Partial` or `SyntaxOnly`
- **THEN** package validation SHALL reject the unsupported downgrade
- **AND** the provider SHALL NOT be able to hide a declaration/callable mismatch.

#### Scenario: Function traits identify callable shape

- **GIVEN** a free function, non-const member function, const member function, or supported captureless lambda
- **WHEN** callable traits are instantiated
- **THEN** tests SHALL observe the callable category, return type, argument count/types, and const-member status used by declaration validation.

### Requirement: Declaration parsing reuses the AngelScript grammar without an engine target

Registry preflight SHALL parse complete declarations through a reusable dependency-inverted form of the existing AngelScript declaration grammar. The binding path SHALL NOT create a separate grammar and SHALL NOT require a current or target `FAngelscriptEngine` merely to parse syntax.

The reusable maintained-fork frontend SHALL return AngelScript-owned engine-independent syntax values and structured diagnostics. A narrow Runtime adapter SHALL convert those values into plugin-owned parsed declaration records. Fork code SHALL NOT depend on Runtime binding descriptor types, and AngelScript parser nodes, resolved engine type objects, functions, or registration IDs SHALL NOT escape into `FAngelscriptBind` or immutable packages.

`ThirdParty/Angelscript` SHALL be treated as maintained fork source rather than an immutable vendor boundary. The implementation MAY refactor or reorganize the relevant parser, builder, tokenizer, declaration syntax model, type-query, diagnostic, and internal frontend code needed to establish the shared parser. Acceptance SHALL be based on ownership boundaries and observable parser/registration behavior, not a changed-file allowlist.

#### Scenario: Registry parses with no engine

- **WHEN** a valid package containing complete method/global/behavior declarations is registered while no `FAngelscriptEngine` exists
- **THEN** syntax parsing, normalization, and supported callable comparison SHALL succeed without invoking an `asIScriptEngine::Register*` API.

#### Scenario: Reusable and engine parser remain compatible

- **WHEN** the parser parity corpus is processed by the reusable declaration entry and by the existing engine registration parser
- **THEN** accepted and rejected syntax, parsed names/parameters/defaults/const/attributes, and diagnostic source locations SHALL remain equivalent for the covered declarations.

#### Scenario: Shared frontend refactor spans maintained fork files

- **WHEN** a cohesive engine-independent declaration frontend requires coordinated changes across multiple maintained AngelScript parser, builder, tokenizer, syntax-model, or type-query files
- **THEN** those source changes SHALL be permitted without a file allowlist
- **AND** the declaration parity corpus and native AngelScript SDK suite SHALL determine compatibility.

#### Scenario: Apply performs final semantic validation

- **WHEN** a frozen descriptor is applied to an explicit engine
- **THEN** the applier SHALL pass the retained complete declaration to the AngelScript registration API without generating a replacement
- **AND** the target engine SHALL remain authoritative for type resolution, name conflicts, calling conventions, and final registration validity.

### Requirement: Author-written declaration text stays inside one non-multiline literal

Each ordinary author-written callable declaration SHALL be fully contained in one ordinary C++ string literal whose text has no physical or embedded line break. This requirement applies only to the declaration literal. The surrounding C++ call, template/callable expression, closing parenthesis, and fluent option chain MAY wrap freely across source lines. New-path author-written callsites SHALL NOT use adjacent string-literal concatenation, raw multiline literals, embedded line breaks, or runtime-composed declaration fragments.

The descriptor validator SHALL reject declaration values containing `\r` or `\n`. A token-aware source architecture test SHALL enforce that exactly one non-multiline string token contains each author-written complete signature, which is not observable after C++ compilation. The architecture test SHALL NOT require the complete C++ call expression to occupy one line. Long declaration literals SHALL remain intact inside one `"..."` token even when they exceed the ordinary C++ line-width preference.

Reflection-, bind-database-, table-, and catalog-derived declarations are not author-written literal callsites. They SHALL use the deterministic snapshot expansion requirement below; every materialized declaration still passes the same complete-declaration parser, normalization, identity, diagnostics, and apply path.

#### Scenario: Wrapped call with intact declaration literal is accepted

- **WHEN** a provider wraps `.Method<&FVector::Equals>(`, the declaration argument, the closing parenthesis, and `.TrivialNative()` across separate source lines
- **AND** the complete `bool Equals(const FVector& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const` declaration remains inside one non-multiline string literal
- **THEN** formatting validation SHALL accept the callsite.

#### Scenario: Adjacent fragments are rejected

- **WHEN** a provider splits one declaration across two adjacent C++ string literal tokens
- **THEN** the source architecture test SHALL fail with the provider path and declaration callsite.

#### Scenario: Declaration value contains a line break

- **WHEN** a declaration reaches the descriptor validator with an embedded carriage return or newline
- **THEN** package validation SHALL return `InvalidPackage` with the PackageId, node provenance, and declaration-literal requirement.

### Requirement: Derived declarations materialize through restricted snapshot expansion

`FAngelscriptBind` SHALL expose an advanced expansion-definition entry with a stable ExpansionId, integer revision, provenance, declared input capabilities, and non-capturing/static expansion function. `Registry.Register()` SHALL validate and freeze the definition without executing it.

Catalog snapshot materialization SHALL execute expansions only after enabled-package/phase/dependency resolution and explicit reflection/config/loaded-bind-database input capture. The read-only expansion context SHALL expose no current/target AS engine, mutable registry/package, arbitrary service locator, clock, random source, or filesystem query.

The restricted expansion writer SHALL emit ordinary child descriptor families and approved auxiliary descriptors using a stable SourceKey and contributing PackageId. It SHALL create `FAngelscriptDerivedDeclaration` values that are not publicly or implicitly constructible from `FString`. The ordinary fluent type/global views SHALL continue to reject runtime-composed declaration strings.

#### Scenario: Catalog aggregate expansion sees all enabled contributors

- **GIVEN** multiple enabled packages contribute stable ToString auxiliary descriptors
- **WHEN** the `FString.ToStringConversions` expansion materializes a snapshot
- **THEN** it SHALL enumerate those descriptors through the read-only catalog view in stable contributor/SourceKey order
- **AND** emit ordinary `FString` conversion child descriptors before snapshot freeze
- **AND** a disabled contributor SHALL produce no conversion child.

#### Scenario: Reflection-derived function becomes an ordinary child

- **WHEN** an Actor/component/delegate/struct expansion consumes a reflected record with a stable object path and SourceKey
- **THEN** the writer SHALL emit the complete generated declaration plus callable/adapter evidence
- **AND** the shared AS frontend and policy-derived callable validator SHALL process it exactly like an author-written child before application
- **AND** its final NodeId, provenance, and apply result SHALL be independently observable.

#### Scenario: Expansion attempts an opaque escape

- **WHEN** an expansion attempts recursive expansion, custom apply emission, missing/duplicate SourceKey, ambient engine lookup, or an arbitrary raw dynamic-declaration path
- **THEN** compilation, architecture validation, or snapshot preflight SHALL reject it
- **AND** no target AS engine or auxiliary engine store SHALL be mutated.

#### Scenario: Equivalent inputs are deterministic

- **WHEN** equivalent package definitions and explicit expansion inputs are materialized twice with different registration order, UObject/native addresses, or absolute process paths
- **THEN** normalized generated child records, final NodeIds, and catalog fingerprints SHALL match
- **AND** a declaration-relevant input change SHALL change the expansion-input/catalog fingerprint only for a later immutable snapshot.

#### Scenario: Generated declaration is invalid

- **WHEN** an expansion emits a declaration with a line break, invalid syntax, callable mismatch, or authored/generated identity collision
- **THEN** snapshot acquisition SHALL fail before application
- **AND** diagnostics SHALL identify PackageId, ExpansionId/revision, SourceKey, contributor, generated text, input provenance, and parse/validation location.

### Requirement: Explicit overload support

The fluent `FAngelscriptBind` API SHALL support overloaded C++ functions through a non-type template parameter, explicit typed overload helper, or equivalent compile-time cast API.

#### Scenario: Overloaded method binding is explicit

- **GIVEN** an overloaded C++ member function or operator
- **WHEN** a provider registers one overload
- **THEN** the callsite SHALL explicitly identify the desired C++ signature
- **AND** the Bind API SHALL NOT choose an overload based on the complete AS declaration string.

#### Scenario: Complete declaration disagrees with typed overload

- **WHEN** a provider pairs a supported typed overload with an incompatible complete AS declaration
- **THEN** package validation SHALL report the mismatch before engine application.

### Requirement: Chainable bind options

The fluent `FAngelscriptBind` API SHALL expose chainable options on an explicit `FAngelscriptBindNode` view. Each option SHALL mutate only the node identified by that view and SHALL preserve the corresponding applied AngelScript trait, metadata, documentation, compile-out, or StaticJIT/native behavior.

#### Scenario: No-discard option

- **WHEN** a provider writes `.Method(...).NoDiscard()`
- **THEN** the no-discard value SHALL be stored on that method descriptor
- **AND** the applied script function SHALL have the same no-discard behavior as the current binding surface.

#### Scenario: Multiple members remain chainable without End

- **WHEN** a provider writes `.Method(A).NoDiscard().Documentation(...).Method(B).Deprecated(...)`
- **THEN** the first options SHALL belong only to A and the final option SHALL belong only to B
- **AND** no global or engine-scoped previous-node slot SHALL be read or written.

#### Scenario: Trivial native option

- **GIVEN** a method or constructor descriptor
- **WHEN** the provider applies its trivial/native option
- **THEN** the node SHALL contain the native metadata before application
- **AND** StaticJIT SHALL consume that descriptor together with the explicit per-engine node result.

### Requirement: Representative migration parity

All in-tree hand-written Runtime, GameplayTags, and GAS binding providers SHALL migrate to explicit packages. Existing script-visible declarations and behavior SHALL remain compatible, and the repository SHALL pass a build with the Legacy adapter disabled.

The migration SHALL include reflection/type-derived declaration families and SHALL relocate non-AS provider side effects into the approved explicit lifetime/ownership paths. Neither category MAY remain as an opaque Legacy dependency in the legacy-disabled build.

#### Scenario: Representative value-type parity

- **GIVEN** migrated `FColor` or equivalent representative value-type bindings
- **WHEN** automation tests compile and execute constructors, properties, member methods, namespace/static functions, overloads, and native forms
- **THEN** those calls SHALL compile and behave as before migration.

#### Scenario: Registration-kind matrix is covered

- **WHEN** the representative migration stage completes
- **THEN** tests SHALL cover a value type, UObject/reference type, enum, namespace/global, constant property, constructor/operator, compile-out/custom node, StaticJIT/native form, documentation, and optional-plugin package.

#### Scenario: In-tree source compiles without legacy bindings

- **WHEN** the plugin builds with `WITH_ANGELSCRIPT_LEGACY_BINDS=0`
- **THEN** every in-tree production manual provider SHALL use the new `FAngelscriptBind` API
- **AND** no migrated source SHALL include or invoke the Legacy adapter.

#### Scenario: Downstream compatibility remains temporarily available

- **WHEN** the plugin builds with the default legacy value `1`
- **THEN** downstream source that still uses the old raw binding API SHALL remain buildable through the isolated compatibility surface.
