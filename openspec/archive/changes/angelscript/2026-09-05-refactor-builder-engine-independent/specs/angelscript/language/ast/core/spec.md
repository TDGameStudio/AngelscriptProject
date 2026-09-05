## MODIFIED Requirements

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

## ADDED Requirements

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
  > Context: Source directory organization is independent of C++ scope. Headers may remain under ThirdParty/angelscript/source/frontend/.
- **WHEN** the consumer names asCTokenizer, asCPreprocessor, asCParser, asCASTContext or asCCompilationSession
  > Inputs: Consumers outside the library may use AS_NAMESPACE_QUALIFIER; code inside BEGIN_AS_NAMESPACE uses the direct type name.
- **THEN** those names resolve to the sole reconstructed definitions in the existing AS scope

  | Existing configuration | Canonical qualified form |
  |---|---|
  | AS_USE_NAMESPACE defined | AngelScript::asCParser |
  | AS_USE_NAMESPACE absent | ::asCParser |

- **BUT** the migration does not remove the outer AS namespace macros or add a new configuration switch
  > Boundaries: A directory named frontend is not a compatibility namespace. Legacy declarations must not reappear through transitive includes, aliases, or a fallback parser.

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
