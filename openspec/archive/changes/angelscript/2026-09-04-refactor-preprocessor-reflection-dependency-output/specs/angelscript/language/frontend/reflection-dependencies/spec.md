## Purpose

Define how the reconstructed AngelScript frontend exposes UE reflection descriptions and deterministic module dependencies without creating a second parsing or runtime-publication authority.

## ADDED Requirements

### Requirement: The preprocessor facade returns one concrete semantic result

The fork-internal `asCPreprocessor` SHALL return `FAngelscriptPreprocessResult` as the concrete owner-visible result of preprocessing and declaration semantics for one frozen source configuration.

New fork-internal result and consumer leaves SHALL live under `ThirdParty/angelscript/source/frontend/` and SHALL be declared, inside `BEGIN_AS_NAMESPACE`, in the lowercase `frontend` namespace with final names and no `V2` counterparts.

#### Scenario: A source set completes declaration semantics
- **WHEN** a caller preprocesses a source set and declaration Sema succeeds
  > Inputs: Immutable source snapshots, one frozen frontend configuration, and the read-only semantic environment established by prerequisite frontend capabilities.
- **THEN** the caller receives one successful `FAngelscriptPreprocessResult`
  > Observables: The result contains the source/typed-AST lease, retained directive/preprocessing record, resolved module descriptors, declaration dependency graph, separate body invalidation graph, and structured diagnostics.

  | Result surface | Durable meaning |
  |---|---|
  | Source/AST lease | Keeps every descriptor range and stable source anchor queryable |
  | Directive/preprocessing record | Retains active-configuration routing, inactive ranges, and AST source backquery without becoming a second semantic graph |
  | `FAngelscript*Desc` collection | Concrete UE-facing descriptions for declarations selected by this configuration |
  | Declaration graph | Typed cross-module semantic dependencies and SCC information |
  | Body invalidation graph | Non-layout body references kept outside declaration scheduling |
- **AND** every reflection and dependency fact is derived from the same typed Parser/Sema declarations
  > Verification: NativeEngine Reflection and ModuleGraph tests compare result facts with the owning typed declarations and attributes.
- **BUT** the result does not contain a parallel generic reflection IR, an annotation property bag, or a source-reparsed DTO
  > Boundaries: The typed AST remains the semantic authority and the concrete descriptors are its UE-facing projection.

#### Scenario: A caller names the reconstructed preprocessing API
- **WHEN** code includes a reconstructed leaf from `ThirdParty/angelscript/source/frontend/`
- **THEN** it refers to that leaf through the lowercase `frontend` namespace inside `BEGIN_AS_NAMESPACE`
  > Observables: There is no parallel `Frontend` namespace, `V2` leaf, or compatibility alias for the same responsibility.

#### Scenario: Conditional source selects one active declaration surface
- **WHEN** the same source snapshots are processed under a particular frozen conditional configuration
  > Details: The prerequisite preprocessing capability retains inactive ranges and directive history but sends only active tokens to Parser/Sema.
- **THEN** descriptors and declaration dependency edges are emitted only for declarations in the selected active branch
  > Observables: A different configuration produces a separate result whose declarations can be compared through stable keys.
- **BUT** inactive declarations are not emitted as partially resolved descriptors or graph vertices
  > Boundaries: Inactive-source tooling remains available through the preprocessing record, not the reflection result.

#### Scenario: Declaration semantics fail
- **WHEN** Parser/Sema reports an unresolved type, invalid reflection attribute, conflicting declaration, or another declaration error
- **THEN** the result reports failure with structured source diagnostics and exposes no publishable resolved descriptor set
  > Observables: Callers cannot mistake partial candidates for a materialization input.
- **AND** no runtime or reflection object is created or mutated
  > Verification: Runtime pointer fields remain null and the live Engine and UE reflection registries are unchanged.

### Requirement: Reflection descriptors have one semantic producer and one definition

The frontend SHALL populate the existing `FAngelscriptModuleDesc`, `FAngelscriptClassDesc`, `FAngelscriptEnumDesc`, `FAngelscriptDelegateDesc`, `FAngelscriptFunctionDesc`, `FAngelscriptArgumentDesc`, and `FAngelscriptPropertyDesc` family through one typed Sema consumer and SHALL keep one definition of that family within the plugin.

#### Scenario: Reflected declarations are accepted by Sema
- **WHEN** Sema accepts a typed declaration and its concrete `UCLASS`, `USTRUCT`, `UENUM`, `UFUNCTION`, `UPROPERTY`, or `UMETA` attributes
  > Inputs: The exact `Decl`, `Attr`, canonical type-use keys, source ranges, and stable declaration identities accepted by Sema.
- **THEN** the descriptor consumer populates the corresponding concrete descriptor fields from those semantic objects
  > Observables: Names, resolved type identities, flags, metadata, ownership, and stable source anchors agree with the typed AST.
- **AND** nested property types, parameters, returns, generic arguments, and delegate signatures retain resolved type-use identity
  > Verification: Tests compare descriptor type keys with the canonical type keys attached to the source declarations.
- **BUT** no regular expression, chunk scanner, string search, or second declaration parser may author or repair a descriptor
  > Boundaries: A semantic error remains a diagnostic; the consumer never guesses missing facts from source text.

#### Scenario: Existing Runtime code includes descriptor declarations
- **WHEN** an existing Runtime consumer includes the established Engine header or the new descriptor owner header
- **THEN** both include paths refer to the same descriptor definitions and ABI within `AngelscriptRuntime`
  > Observables: There is no copied ThirdParty descriptor family and no conversion between duplicate UE descriptor types.

### Requirement: Descriptor publication is explicitly staged

Every reflection descriptor SHALL expose the lifecycle `Parsed`, `Resolved`, and `Materialized`, and this frontend capability SHALL complete no stage later than `Resolved`.

#### Scenario: A valid source set reaches resolved output
- **WHEN** all declaration names, type uses, attributes, ownership relationships, and declaration dependencies have resolved successfully
- **THEN** every returned descriptor is marked `Resolved`
  > Observables: Stable declaration/type-use keys and source anchors are complete and deterministic.
- **AND** every runtime-only field remains null or its documented pre-materialization default

  - No `UClass`, `UStruct`, `UEnum`, `UFunction`, `UDelegateFunction`, or `FProperty` is created.
  - No `asITypeInfo`, `asIScriptFunction`, or `asCModule` is attached.
  - No mutable `asCScriptEngine`, `GEngine`, editor global, or reflection registry is read or changed.
- **BUT** a `Resolved` descriptor is not advertised as `Materialized`
  > Boundaries: Runtime object creation, pointer attachment, validation against a live generation, and atomic Engine publication belong to a later publisher Change.

### Requirement: Declaration dependencies are typed and cycle aware

The preprocessing result SHALL derive cross-module declaration dependencies from resolved semantic type uses without relying on source `import` declarations.

#### Scenario: A declaration references a type owned by another script module
- **WHEN** Sema resolves a base, interface, property type, function return, function parameter, nested generic argument, or delegate-signature type to a declaration in another source module
- **THEN** the declaration dependency graph contains a typed edge from the consuming module to the providing module
  > Observables: Each use-site edge records its source and target stable module identities, dependency reason, exact authored source range, and completeness requirement.

  | Reference kind | Dependency reason | Typical completeness |
  |---|---|---|
  | Base class or implemented interface | `Base` or `Interface` | Complete definition |
  | Stored property type | `PropertyType` | Complete definition when layout requires it |
  | Function return or parameter | `ReturnType` or `ParameterType` | Declaration-only unless the semantic type rules require completion |
  | Nested generic argument | `GenericArgument` | Inherited from the enclosing type-use rule |
  | Delegate signature | `DelegateSignature` | Signature declaration |
- **AND** multiple distinct source uses remain traceable even when they connect the same two modules
  > Details: SCC adjacency may collapse duplicate module pairs, but use-site evidence is not discarded.
- **BUT** same-module references and resolved host/builtin types do not create fake cross-module vertices
  > Boundaries: An unresolved host or script type is a Sema diagnostic rather than an invented module dependency.

#### Scenario: Declaration dependencies contain a cycle
- **WHEN** two or more source modules form a cycle in the typed declaration graph
- **THEN** the result preserves the original typed edges and exposes deterministic strongly connected components plus a condensation DAG
  > Observables: Members and components use stable-key ordering, independent of file enumeration or worker completion order.
- **AND** completeness validation remains a Sema responsibility
  > Details: The graph does not reject every cycle. A layout-invalid incomplete-type cycle fails through the semantic rule that requires completion, while a legal declaration cycle remains representable.

### Requirement: Body invalidation facts remain separate and deterministic

The preprocessing result SHALL keep function-body reference invalidation facts separate from declaration-layout dependencies and SHALL produce byte-equivalent ordered results for equivalent semantic input.

#### Scenario: A function body references another module
- **WHEN** body semantic facts identify a call, global reference, or non-layout type reference owned by another module
- **THEN** the fact is recorded in the body invalidation graph and not promoted to a declaration completeness edge
  > Observables: Declaration SCCs and condensation order are unchanged by body-only reference changes.
- **AND** the body graph may be empty when body semantic fragments are not supplied
  > Boundaries: This Change defines and returns the separate graph; the body-Sema Change may populate its input concurrently without changing declaration graph semantics.

#### Scenario: Equivalent inputs arrive in a different order
- **WHEN** source files, semantic events, or body-reference facts are supplied in a different enumeration or worker-completion order
- **THEN** descriptors, dependency edges, SCC membership, condensation order, and body invalidation facts have the same canonical ordering and stable identities
  > Verification: NativeEngine fixtures compare serialized observations from permuted inputs and one-worker versus multi-worker producers.
