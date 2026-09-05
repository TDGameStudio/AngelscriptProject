## ADDED Requirements

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

The frontend SHALL allocate and own all AST nodes through one non-copyable `frontend::asCASTContext`, and SHALL make the graph immutable after successful structural sealing.

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

The reconstructed frontend SHALL use the `frontend` typed hierarchy as its sole semantic AST authority and SHALL expose legacy or external consumers only through explicit read-only projections.

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

The frontend SHALL derive any flat or serialized AST representation from one sealed typed graph using an explicit version, bounded pointer-free records, and stable source/type identities.

#### Scenario: Round-trip a sealed typed graph
- **GIVEN** a sealed AST whose source snapshot and stable identities are available
- **WHEN** the versioned codec writes and reads its flat projection
- **THEN** the reconstructed projection preserves node kinds, owning-child order, source anchors, typed attributes, type references, and declared cross-reference identities
  > Observables:
  >
  > | Field domain | Serialized representation |
  > |---|---|
  > | Node relationships | Validated projection-local indices |
  > | Source | Stable logical anchors and explicit byte ranges |
  > | Types/declarations | Stable typed witnesses or table references |
  > | Runtime state | Never serialized |
- **AND** re-encoding an equivalent sealed graph produces byte-identical output
  > Verification: NativeEngine codec fixtures cover round-trip, ordering, count/depth budgets, and corruption rejection.

#### Scenario: Encounter an old Canonical AST sidecar or unknown version
- **WHEN** the new codec is asked to decode the current wide-record Sidecar/Public View wire shape or an unsupported future version
- **THEN** it returns an explicit incompatible-version result and constructs no partial typed graph
- **BUT** it does not preserve layout compatibility by recreating the old wide records
  > Boundaries: A future migration tool may read an old artifact separately, but the new AST contract has no implicit legacy wire compatibility.
