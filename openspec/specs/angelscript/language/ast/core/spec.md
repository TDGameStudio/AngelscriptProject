# AST Core

## Purpose

Record the core structures and invariants of the AngelScript abstract syntax tree: node classification, ownership and lifetime, traversal contracts, and the AST shape expected by parser, semantic analysis, and backend consumers.

## Requirements

### Requirement: Genuine typed AST node hierarchies

The frontend SHALL represent declarations, statements, expressions, types, and attributes with concrete C++ subclasses whose storage and APIs admit only payload valid for their semantic kind.

#### Scenario: Construct a concrete semantic node
- **WHEN** the context constructs a function declaration, call expression, conditional statement, qualified type use, or declaration attribute
- **THEN** the returned object's C++ type exposes the required payload for that node and does not expose unrelated wide-record fields
  > Observables: A function owns its parameters and body edge, a call owns its callee and ordered arguments, and neither allocates payload reserved for unrelated node kinds.
- **AND** the family base retains a compact kind discriminator suitable for checked casts and exhaustive dispatch
  > Verification: NativeEngine compile-time and runtime fixtures exercise positive and negative family/subclass relationships.
- **AND** concrete expression nodes participate in the exact `asCStmt -> asCValueStmt -> asCExpr` lineage
  > Boundaries: Value-producing statements share statement traversal while expression-only APIs remain on `asCExpr`; a direct `asCExpr -> asCStmt` shortcut does not satisfy the hierarchy.
- **BUT** a `kind` value is not permission to reinterpret arbitrary storage as another concrete class
  > Boundaries: Construction is context-controlled, and cast helpers verify the declared hierarchy.

#### Scenario: Add a node kind to the language
- **WHEN** a maintainer adds a declaration, statement/expression, type, or attribute kind
- **THEN** one family taxonomy entry drives its kind, forward declaration, hierarchy relation, cast range, visitor dispatch, and diagnostic name
  > Observables: Missing visitor/verifier handling is a compile-time or focused-test failure rather than a silently ignored default branch.

#### Scenario: A declaration owns a lexical declaration context
- **WHEN** a translation unit, namespace, record, or function can contain declarations
- **THEN** it participates in the explicit `asCDeclContext` ownership and lookup structure in addition to its concrete `asCDecl` type
  > Observables: Owned declaration order, semantic lookup membership, and parent context are represented without placing child collections on every declaration kind.
- **BUT** `DeclContext` is not replaced by a generic node bag or inferred from source nesting after parsing
  > Boundaries: Parser/Sema populate the typed context through context-owned APIs.

### Requirement: AST context ownership and freeze boundary

The frontend SHALL allocate and own all AST nodes through one non-copyable `asCASTContext` declared directly in the scope selected by `BEGIN_AS_NAMESPACE`, and SHALL make the graph immutable after successful structural sealing.

#### Scenario: Retain and release a typed AST snapshot
- **GIVEN** a root frontend artifact that owns the AST context and its immutable source snapshot lease
- **WHEN** consumers traverse nodes before the root artifact is released
- **THEN** node addresses and snapshot-local handles remain stable and all source ranges resolve through the matching snapshot
  > Context: The implementation may use an arena and UE containers; individual nodes do not require shared ownership.
- **AND** releasing the root artifact releases the context, arena, node payload, attributes, and source lease as one lifetime unit
  > Verification: Lifetime fixtures prove no node or borrowed string/range view remains valid independently of its owner.

#### Scenario: Attempt mutation after sealing
- **WHEN** a builder or semantic action invokes a mutating context API after the graph has sealed
- **THEN** the operation fails with a stable post-seal-mutation diagnostic and leaves the graph byte-for-byte unchanged
  > Observables: A successful seal is a one-way state transition; readers receive const nodes and views.
- **BUT** sealing does not publish runtime objects or prove target ABI compatibility
  > Boundaries: Runtime publication is a later transaction with separate verification.

#### Scenario: Request an equivalent canonical type twice
- **WHEN** the context is asked to construct semantically equivalent canonical type forms with the same stable identity inputs
- **THEN** it returns the same uniqued canonical `asCType` object while preserving separate authored `TypeLoc` values for distinct spellings and ranges
  > Observables: Pointer equality is permitted only as a context-local optimization; durable equality remains owned by stable type keys.

### Requirement: Checked casts and deterministic traversal

The frontend SHALL provide null-aware checked casts and exhaustive visitors that traverse semantic children in a documented deterministic order.

#### Scenario: Cast within and across node families
- **WHEN** a consumer applies `isa`, `dyn_cast`, or checked `cast` to a node
- **THEN** valid base/derived relationships succeed, nullable casts preserve null, and invalid family or subclass casts fail through the documented checked behavior
  > Observables: Consumers do not compare unrelated numeric kinds or use unchecked C-style reinterpret casts.

#### Scenario: Traverse a complete translation unit
- **GIVEN** a sealed graph containing nested declarations, attributes, statements, expressions, types, and recovery nodes
- **WHEN** the canonical visitor walks it
- **THEN** every owning semantic child is visited exactly once in stable source/semantic order, while non-owning cross references are exposed separately and do not create traversal cycles
  > Observables: Repeated traversals produce identical node-kind and source-range sequences.
- **BUT** an unknown or unhandled concrete kind never falls through as successful traversal
  > Boundaries: Exhaustive dispatch reports or fails the missing handler.

### Requirement: Typed type-use and attribute facts

The AST SHALL keep canonical type objects, use-site qualification, and attributes as separate typed facts rather than strings or unrelated flag fields on every node.

#### Scenario: Attach a qualified type use
- **WHEN** a declaration or expression records a type
- **THEN** it references a context-owned concrete `asCType` through an `asCQualType` value that contains only qualifiers legal for that role
  > Observables: `asCQualType` is not an `asCType` subclass; ordered generic arguments are structural type uses, and no consumer parses a stable/display string to recover their shape.
- **AND** authored spelling and component ranges are retained separately through `asCTypeLoc` or `asCTypeSourceInfo`
  > Verification: Two spellings of the same canonical type share semantic type identity while preserving distinct source-facing structure.
- **BUT** parameter direction, ownership transfer, and target ABI lowering remain contracts on their owning semantic edge
  > Boundaries: They are not silently folded into general type qualifiers.

#### Scenario: Attach a declaration annotation
- **WHEN** Parser or Sema associates a language/UE annotation with its target
- **THEN** the context creates a concrete typed `asCAttr` that preserves its authored range and typed arguments or normalized facts allowed by that attribute kind
  > Observables: The target exposes an ordered attribute view and the verifier checks allowed target kinds.
- **BUT** the AST does not store an arbitrary string map or execute UE reflection/runtime policy while constructing the attribute
  > Boundaries: Later Sema and reflection projection own legality and runtime descriptor effects.

### Requirement: Source and preprocessing separation

Every source-backed AST node SHALL carry its normal half-open UTF-8 source range and SHALL obtain preprocessing or generated-origin explanations through its owning snapshot's query products.

#### Scenario: Explain the conditional context of a node
- **GIVEN** a node created from the active token stream and a preprocessing result from the same snapshot
- **WHEN** a consumer asks which conditional branch affected the node
- **THEN** the consumer queries by the node's source range and receives the matching snapshot-owned preprocessing records
  > Observables: Ordinary nodes do not duplicate the directive tree or carry a preprocessing record pointer/ID.

#### Scenario: Represent a synthesized node
- **WHEN** a later producer creates a node without a one-to-one authored range
- **THEN** it supplies an explicit snapshot-owned origin relation or authored anchor according to the source model
- **BUT** it cannot fabricate a normal authored range, retain a foreign-snapshot handle, or use a line number as identity
  > Boundaries: Durable source anchors are defined by the source/diagnostics capability, not by AST pointer addresses.

### Requirement: Structural verification and recovery isolation

The AST SHALL verify concrete-node invariants, ownership, source ranges, type roles, attribute targets, child edges, and recovery reachability before a graph is accepted as sealed.

#### Scenario: Verify a valid graph
- **WHEN** the context seals a graph in which every required payload and owning edge is present and every reference belongs to the context
- **THEN** verification succeeds and exposes an immutable root suitable for later Sema or consumer stages
  > Observables: Verification reports the exact concrete node and invariant on failure rather than a generic malformed-record result.

#### Scenario: Reach an error or recovery node from a publishable root
- **WHEN** an error type, recovery declaration, or recovery expression remains reachable from an exported declaration, resolved body, or another future publication root
- **THEN** verification fails closed and identifies the owning path
  > Context: Recovery nodes may remain in the arena for diagnostics when unreachable from semantic publication roots.
- **BUT** the verifier never replaces missing semantic facts with runtime IDs, pointers, default kinds, or guessed children
  > Boundaries: Recovery is explicit, typed, and non-publishable.

### Requirement: Single reconstructed AST authority

The reconstructed frontend SHALL use the reconstructed typed hierarchy as its sole semantic AST authority and SHALL expose legacy or external consumers only through explicit read-only projections.

#### Scenario: Consume AST facts at a subsystem boundary
- **WHEN** diagnostics, reflection, stable identity, serialization, or a future code generator requests AST information
- **THEN** it traverses typed nodes or a projection derived from the same sealed graph
  > Observables: The projection cannot mutate the AST and does not become a second owner of semantic decisions.
- **BUT** the system does not maintain a synchronized root-level wide record graph, `asCScriptNode` shadow, or generic sidecar IR as another truth
  > Boundaries: Dormant legacy sources remain reference material until removed or migrated by an explicitly scoped Change.

#### Scenario: Inspect a sealed node for runtime state
- **WHEN** a consumer reads the typed AST before publication
- **THEN** no node payload contains a live `FAngelscriptEngine`, `UObject`, runtime function ID, numeric runtime `typeId`, generation-local offset, or runtime pointer
  > Observables: Runtime resolution is performed later through explicit stable identity and publication adapters.

### Requirement: AST projection and serialization use a new versioned contract

The frontend SHALL derive flat and serialized representations from a sealed, verified typed graph using explicit versions, bounded pointer-free records and fixed stable identity references. Wire decoding SHALL remain distinct from authenticating the referenced semantic definitions.

#### Scenario: Round-trip a sealed typed graph
- **GIVEN** a sealed AST whose source snapshot and owning identity registry are available
- **WHEN** the versioned codec writes and reads its flat projection
- **THEN** the projection preserves node kinds, owning-child order, source anchors, typed attributes, type references and declared cross-reference identities

  | Field domain | Representation |
  |---|---|
  | Node relationships | Validated projection-local indices |
  | Source | Logical source anchors and byte ranges |
  | Types/declarations | Fixed 32-byte keys, not recursive witnesses or Engine IDs |
  | Runtime state | Never serialized |

- **AND** an equivalent graph re-encodes deterministically
  > Verification: Codec fixtures cover ordering, bounded counts/bytes/edges, truncation and corruption; merely setting the sealed flag cannot make an invalid node publishable.
- **BUT** structurally decoding a key does not prove its registry role or agreement with an actual type/signature
  > Details: Consumers explicitly select a matching registry for reference validation. Actual definition admission additionally compares typed semantic facts; hash-byte decoding cannot replace that check.

#### Scenario: Encounter an old Canonical AST sidecar or unknown version
- **WHEN** decoding encounters an obsolete wide-record/witness format or an unknown future version
- **THEN** it returns an explicit incompatible-old-version or unsupported-version result and publishes no partial projection
- **BUT** it does not recreate old records or silently fall back to either retired AST
  > Boundaries: The fixed-key projection has its own version; a future migration utility would be a separate explicit operation.

### Requirement: Replacement cutover removes competing AST implementations
The active language pipeline SHALL use only the typed frontend AST, without retaining either obsolete AST implementation or a conversion fallback.

#### Scenario: Build the reconstructed language pipeline
- **WHEN** the Runtime and replacement NativeEngine tests are built
- **THEN** active consumers obtain syntax and semantic facts from the typed frontend
- **BUT** old asCScriptNode and root Canonical AST implementations cannot supply missing language behaviour
  > Boundaries: Unmigrated VM/cache/JIT consumers remain isolated reference source; isolation does not claim that their execution paths work.

#### Scenario: Own canonical types separately from authored spelling
- **WHEN** multiple source spellings denote an equivalent type within a compilation context
- **THEN** canonical type identity is shared while TypeLoc and declaration/source relationships remain inspectable
- **AND** semantic definition metadata does not become another independently maintained AST

### Requirement: Canonical AngelScript C++ names
The reconstructed lexer, preprocessor, parser, AST, compilation, identity and definition APIs SHALL use one canonical C++ naming surface directly inside the scope selected by BEGIN_AS_NAMESPACE. They SHALL NOT retain an additional frontend namespace, a replacement Frontend/V2 naming layer, or aliases that preserve the retired qualified surface.

#### Scenario: Include the reconstructed language headers
- **GIVEN** a consumer includes the maintained headers and uses the repository's existing AS namespace configuration

    Source directory organization is independent of C++ scope. Reconstructed language headers live under `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/`. That folder name is not a C++ namespace.

- **WHEN** the consumer names asCTokenizer, asCPreprocessor, asCParser, asCASTContext or asCCompilationSession

    Consumers outside the library may use AS_NAMESPACE_QUALIFIER; code inside BEGIN_AS_NAMESPACE uses the direct type name.

- **THEN** those names resolve to the sole reconstructed definitions in the existing AS scope

    | Existing configuration | Canonical qualified form |
    |---|---|
    | AS_USE_NAMESPACE defined | AngelScript::asCParser |
    | AS_USE_NAMESPACE absent | ::asCParser |

- **BUT** the migration does not remove the outer AS namespace macros or add a new configuration switch

    A directory named frontend is not a compatibility namespace. Legacy declarations must not reappear through transitive includes, aliases, or a fallback parser.

#### Scenario: Compose compilation and detached metadata consumers
- **WHEN** Builder, MetadataImage, ScriptFunction, Engine registration and the UE descriptor consumer exchange asSStableKey or asCTypeContext
  > Inputs: These are the same identity/configuration types used by the reconstructed syntax pipeline, not frontend-only copies.
- **THEN** all consumers refer to the same canonical AS definitions without an intermediate namespace or adapter type
  > Observables: Cross-module declarations agree at compile/link time; same-pointer definitions, retained image leases and single-engine registration keep their existing behavior.
- **BUT** a namespace alias or using declaration cannot stand in for migrating the real declaration and its consumers
  > Boundaries: Rebuilding dependent C++ modules is required; old exported C++ symbol compatibility is not promised.

#### Scenario: Preserve semantic identities while changing C++ qualification
- **GIVEN** the same authored source, language configuration and semantic identity inputs
- **WHEN** the pipeline is rebuilt with the canonical C++ naming surface
- **THEN** stable key bytes, source provenance, diagnostics and typed projection/codec content retain their established semantic results
  > Verification: Existing golden-key, codec, stage and lifetime cases remain regression controls. C++ spelling is not a new hash input or a reason to bump a wire version.
- **BUT** AS script namespace declarations and lookup semantics are not renamed
  > Boundaries: This is C++ API consolidation, not a language change or restoration of the dormant runtime.

### Requirement: Removed anonymous-function products cannot enter semantic artifacts

The maintained AST and definition projection SHALL expose no constructible Lambda-only node or origin product and SHALL reject incompatible persisted anonymous-function representations.

#### Scenario: Decode a retired anonymous-function representation
- **WHEN** a consumer receives a prior incompatible AST format or a reserved retired Lambda kind
- **THEN** decoding or verification rejects it before publishing a valid semantic graph
- **BUT** a retired numeric kind is not reinterpreted as a different supported node

#### Scenario: Preserve ordinary typed AST operations
- **WHEN** a supported named-function AST is projected, serialized, decoded and verified
- **THEN** declaration identity, type information, source ranges and lifetime facts retain their supported behavior
