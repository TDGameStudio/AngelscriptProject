## MODIFIED Requirements

### Requirement: Deterministic nominal type declaration identity

The frontend SHALL admit cacheable nominal identities through one versioned canonical registry and SHALL expose each admitted identity as the fixed `asSStableKey` value. The registry SHALL retain exact canonical descriptions to reject conflicting admissions.

#### Scenario: Rebuild the same logical declaration
- **GIVEN** equivalent declarations built in different processes, worktrees, source discovery orders, or runtime registration orders
  > Inputs: Stable module/provider scope, namespace, semantic owner identity, declaration kind, canonical name and generic arity are the nominal coordinates.
- **WHEN** their registries admit the declarations under the same encoding version and domain
- **THEN** their public BLAKE3-256 keys are byte-for-byte equal
  > Observables: Workspace paths, source lines, traversal ordinals, addresses and Engine registration order cannot change the key.
- **BUT** a matching key cannot authenticate a different candidate definition without its owning registry
  > Boundaries: Exact canonical admission and definition/layout validation remain distinct from copying or comparing the fixed key.

#### Scenario: Distinguish nominally different declarations
- **GIVEN** declarations with the same short name but different scope, owner, namespace, kind or generic arity
- **WHEN** their nominal descriptors are admitted
- **THEN** their identities differ, or an actual digest collision is rejected without ambiguous publication
  > Observables: Typed descriptor resolution retains the semantic coordinates; callers do not parse a hash string to recover them.

#### Scenario: Encounter a declaration without stable semantic ownership
- **WHEN** a local, anonymous, generated or recovery declaration lacks an explicit stable declared origin
- **THEN** it remains non-cacheable instead of receiving a persistent key derived from an address or incidental source position
- **AND** a generated nominal can become cacheable only through its explicit stable generator identity
  > Boundaries: Source-local observation coordinates may still identify a local node in diagnostics; they are not durable entity keys.

### Requirement: Structural type-use identity

The frontend SHALL represent a canonical type use by a fixed stable key whose registry-owned descriptor references admitted child keys. It SHALL NOT reconstruct type structure from display strings or recursively copy canonical witnesses into each use.

#### Scenario: Encode nested and qualified type uses
- **GIVEN** ordered generic arguments, nested type uses or legal const/reference/handle qualifiers
- **WHEN** the registry admits their structured type-use descriptor
- **THEN** argument order, canonical child identity and legal qualifiers are preserved deterministically
  > Examples: `Container<A,B>` differs from `Container<B,A>`; structural callable signatures preserve return type and ordered parameter type/passing-mode pairs.
- **AND** equivalent graphs admitted in different insertion orders produce the same key
  > Verification: Typed resolution and independent order fixtures prove structure without exposing an owned recursive witness graph.

#### Scenario: Preserve alias spelling without changing canonical semantics
- **GIVEN** a weak alias whose canonical target is another type declaration
- **WHEN** semantic identity and authored spelling are recorded
- **THEN** the type-use key identifies the target while TypeLoc or equivalent source data retains the alias
- **BUT** an explicitly distinct typedef retains its own nominal identity
  > Boundaries: Alias policy is a semantic decision, never string normalization.

#### Scenario: Reject qualifiers in the wrong semantic domain
- **WHEN** parameter direction, ownership transfer or target lowering is submitted as a type-use qualifier
- **THEN** admission returns an invalid-role result and publishes no key
  > Details: Parameter passing mode is carried by the ordered signature parameter, not by a direction bit on the parameter's canonical type.

### Requirement: Separate identity, schema, ABI, artifact, and runtime domains

The system SHALL use one public stable-key value for entity and type-use identity while keeping definition, layout, artifact-local addressing and Engine binding facts in their owning domains. It SHALL NOT require separate public recursively owned schema, ABI or requirement key families.

#### Scenario: Derive compatibility records for one type
- **GIVEN** admitted nominal and structural type-use identities
- **WHEN** a definition or target binding is validated
- **THEN** only the owning domain determines whether the changed facts remain compatible

  | Domain | Relevant facts | Not a durable identity input |
  |---|---|---|
  | Nominal identity | Scope, owner, kind, name, generic arity | Members, bodies, target layout |
  | Type-use identity | Canonical target, ordered arguments/signature, legal qualifiers | Runtime IDs, target lowering |
  | Definition validation | Members, signatures, semantic capabilities | Current Engine IDs |
  | Layout admission | Target profile, size, offsets, alignment | Source spelling |
  | Local projection/binding | Owner-scoped index or Engine-local address/ID | Any cross-owner persistent equality |

- **AND** changing a body or tooltip does not change nominal identity
- **BUT** unchanged identity cannot bypass incompatible definition or layout validation
  > Boundaries: The key answers which declared entity is referenced, not whether an executable artifact is reusable.

### Requirement: Canonical encoding and exact witness validation

The identity registry SHALL own versioned, domain-separated, length-framed canonical descriptions and SHALL reject invalid candidates or conflicting hashes before publication. Exact witness data is an internal admission concern, not a public recursive value carried by every consumer.

#### Scenario: Admit a detached canonical requirement
- **WHEN** a producer submits a typed descriptor or validates actual metadata against an admitted key
- **THEN** the registry checks the descriptor's role, enum/qualifier values, bounded structure, owned child keys and exact canonical description before accepting it

  - Unknown or wrong-role keys cannot authenticate metadata.
  - Descriptor mismatch, return-only conflict and digest collision remain distinct failures.
  - Validation does not mutate or overwrite a previously admitted record.

- **BUT** canonical identity contains no raw pointer, numeric Engine ID, `FName` comparison index, absolute workspace path or container memory image
  > Boundaries: Serialized AST decoding is a separate versioned structural gate; decoding 32 key bytes alone never authenticates a semantic definition.

#### Scenario: Force a digest collision in a test seam
- **GIVEN** distinct canonical descriptors mapped to one injected digest
- **WHEN** the second candidate is admitted
- **THEN** exact comparison rejects it as a collision and retains the first unambiguous record
  > Verification: The real registry admission path uses an explicit digest dependency; no alternate permissive test registry is involved.

### Requirement: Artifact slots and runtime identifiers are explicitly local

Any artifact-local index and Engine/generation-local numeric identifier SHALL remain scoped to its owner and SHALL NOT become an alternate durable identity. This capability does not require a public artifact-slot or ABI-key family.

#### Scenario: Assign slots inside one detached artifact
- **GIVEN** a bounded pointer-free projection with local relationship indices and fixed stable references
- **WHEN** another projection chooses different local indices
- **THEN** its stable keys remain unchanged and each index resolves only inside its own projection
- **BUT** raw local index equality cannot prove cross-artifact entity equality
  > Boundaries: Executable artifact publication and relocation remain separate capabilities.

#### Scenario: Represent two runtime generations
- **GIVEN** separate Engine/generation scopes referring to the same stable semantic key
- **WHEN** their numeric identifiers are queried or compared
- **THEN** each identifier is meaningful only within its owning live binding and is excluded from canonical encoding
  > Verification: Identity tests use synthetic generation scopes; registration tests separately prove real Engine binding and retirement.
- **BUT** a detached object's numeric query cannot trigger implicit registration
  > Boundaries: Transactional publication and retirement are owned by the detached-definition registration capability.

### Requirement: One canonical type identity authority

All active reconstructed frontend and Core semantic consumers SHALL obtain stable identity from the explicit shared registry. Projection adapters MAY copy the fixed value but SHALL NOT originate identity from declaration strings or maintain a synchronized shadow identity graph.

#### Scenario: Consume identity from an existing boundary
- **WHEN** AST, dependency, host descriptor, Core artifact or metadata binding consumers need a stable reference
- **THEN** they consume the same admitted fixed key and retain or explicitly select the registry needed for semantic validation
  > Details: Lossless Core projections are value adapters, not authenticators; a binding admission checks actual name/kind/signature against the registry.
- **BUT** compiled-but-dormant legacy compatibility code cannot be used as an active identity producer or parser fallback
  > Boundaries: Its removal is coordinated with isolation of its legacy consumers, not inferred from renaming the new key.

## ADDED Requirements

### Requirement: One public stable hash with centrally owned canonical identity
The system SHALL expose stable type/function identity as one fixed BLAKE3-256 value and SHALL keep canonical identity descriptions and compatibility validation internal.

#### Scenario: Preserve nominal identity across definition changes
- **WHEN** a type's members or a function's body, parameter names or formatting change without changing its nominal or overload identity
- **THEN** its public stable key remains unchanged
- **BUT** definition or layout incompatibility is still detected by the registry or binding admission checks

#### Scenario: Derive a function identity
- **WHEN** a function declaration has resolved its owner and canonical parameter types
- **THEN** identity comes from semantic signature inputs rather than a printed declaration string
  > Inputs: Ordinary overloads use the semantic owner, name, ordered canonical parameters and overload-relevant modifiers; parameter names, defaults and bodies are excluded.
- **AND** an ordinary function's return-only overload conflict remains an error instead of acquiring an unrelated identity
  > Boundaries: A conversion operator is a distinct declaration category whose destination participates in selection; it does not weaken the ordinary-function rule.

#### Scenario: Distinguish conversion destinations without synthetic overloads
- **GIVEN** maintained conversion methods named `opConv`, `opImplConv`, `opCast` or `opImplCast`
  > Context: Their canonical destination type is part of their semantic conversion identity, not an unrelated ordinary return-only overload.
- **WHEN** the same owner declares valid conversions to different destination types
- **THEN** the registry admits distinct Function identities using each actual destination TypeUse edge

  - The public key remains the same fixed BLAKE3-256 value family.
  - No synthetic name, hidden parameter, display-text parse or Engine ID is introduced.

- **AND** conversion selection respects destination, receiver qualifiers, inherited candidates and explicit-versus-implicit availability
  > Observables: An ambiguous or unavailable conversion reports a source diagnostic rather than selecting by insertion order.
- **BUT** equal destination and overload coordinates cannot bypass duplicate-definition or incompatible-definition checks

#### Scenario: Reject an injected hash collision
- **GIVEN** distinct canonical identities mapped to the same digest
- **WHEN** the identity registry admits the second candidate
- **THEN** it reports a collision and does not publish an ambiguous hash-only reference
  > Observables: Descriptions are retained once by their owner; callers do not duplicate recursively nested witness objects.

#### Scenario: Reference a recursive nominal type
- **WHEN** a declaration refers to itself or another nominal shell
- **THEN** its stable identity is available without recursively expanding members
- **BUT** Engine IDs, addresses, allocation order and target layout are not part of the identity input
