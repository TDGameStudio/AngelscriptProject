## Purpose

Define deterministic type declaration and type-use identities that survive compilation boundaries while keeping semantic compatibility and runtime projection explicit.

## ADDED Requirements

### Requirement: Deterministic nominal type declaration identity

The frontend SHALL derive each cacheable type declaration identity from one versioned canonical descriptor and SHALL compare complete canonical witnesses before treating two declarations as equal.

#### Scenario: Rebuild the same logical declaration
- **GIVEN** equivalent declarations built in different processes, worktrees, source discovery orders, or runtime registration orders
  > Inputs: The descriptor contains the stable module or provider scope, namespace and semantic owner path, declaration kind, canonical name, and generic arity.
- **WHEN** each producer encodes the declaration with the same identity schema and domain
- **THEN** the canonical bytes and BLAKE3-256 digest are byte-for-byte equal
  > Observables: Absolute workspace paths, source line numbers, traversal ordinals, allocation addresses, and runtime registration order do not affect the result.
- **BUT** the digest alone never establishes equality
  > Boundaries: A hash match is followed by exact schema-version, domain, and canonical-witness comparison.

#### Scenario: Distinguish nominally different declarations
- **GIVEN** declarations that share a short name but differ by stable module/provider scope, semantic owner, namespace, declaration kind, or generic arity
- **WHEN** their `TypeDeclKey` values are built
- **THEN** their canonical witnesses and identities differ
  > Observables: Diagnostics can identify the exact differing descriptor field instead of reporting only a hash mismatch.

#### Scenario: Encounter a declaration without stable semantic ownership
- **WHEN** a local, anonymous, generated, or recovery declaration has no specified stable owner path or generator-provided stable identity
- **THEN** the frontend marks it non-cacheable rather than deriving identity from a pointer, source line, or incidental ordinal
  > Boundaries: A future explicit stable generator key or redirect policy may make a named class of generated declarations cacheable, but this Change does not guess one.

### Requirement: Structural type-use identity

The frontend SHALL represent a type use as a canonical declaration target plus explicit use-site structure, and SHALL NOT recover semantic structure by parsing a display or stable-key string.

#### Scenario: Encode nested and qualified type uses
- **GIVEN** a type use containing ordered generic arguments, nested uses, and legal const/reference/handle forms
- **WHEN** its `TypeUseKey` is encoded
- **THEN** argument order, canonical child identities, and each legal use-site qualifier are preserved structurally and deterministically
  > Observables: `Container<A,B>` differs from `Container<B,A>`, and nested generic structure round-trips without parsing a mangled name.
- **AND** repeated equivalent type-use graphs encode to the same canonical bytes
  > Verification: Golden-vector and registration-order fixtures compare complete witnesses and digests.

#### Scenario: Preserve alias spelling without changing canonical semantics
- **GIVEN** a weak alias whose canonical target is another type declaration
- **WHEN** semantic identity and source-facing spelling are recorded
- **THEN** the `TypeUseKey` identifies the canonical target while a separate type-location or spelling field retains the authored alias
  > Observables: Semantic equality does not erase diagnostics or refactoring spelling information.
- **BUT** a strong/distinct typedef remains its own nominal declaration identity
  > Boundaries: Alias policy is explicit; string normalization does not silently decide it.

#### Scenario: Reject qualifiers in the wrong semantic domain
- **WHEN** parameter direction, ownership transfer, or target ABI lowering bits are supplied as canonical type-use qualifiers
- **THEN** validation returns a typed invalid-role result and no key is published
  > Context: Parameter contracts and edge-owned lifetime contracts are separate from canonical type-use identity.

### Requirement: Separate identity, schema, ABI, artifact, and runtime domains

The system SHALL preserve distinct typed records for nominal identity, semantic schema, target ABI compatibility, artifact-local requirement references, and current-generation runtime bindings.

#### Scenario: Derive compatibility records for one type
- **GIVEN** one stable `TypeDeclKey` and one structural `TypeUseKey`
- **WHEN** semantic and target-specific compatibility are computed
- **THEN** each layer changes only for facts in its declared domain

  | Layer | Includes | Excludes |
  |---|---|---|
  | `TypeDeclKey` | Stable nominal scope, owner, kind, name, arity | Members, bodies, target layout, runtime IDs |
  | `TypeUseKey` | Canonical target, ordered arguments, legal use qualifiers | Parameter direction, ownership events, target lowering |
  | `TypeSchemaDigest` | Durable members, signatures, semantic capabilities | Target pointer size and current runtime IDs |
  | `TypeABIKey` | Target profile, layout, offsets, alignment, calling/behavior requirements | Source spelling and editor-only presentation |
  | `TypeSlot` | Artifact-local index of one complete requirement | Cross-artifact or cross-generation identity |
  | runtime binding | Current-generation type info, numeric ID, offsets, callable pointers | Persistence outside its generation lease |

- **AND** changing a function body or tooltip does not change nominal type declaration identity
  > Verification: Layer-isolation fixtures mutate one fact at a time and compare all resulting keys.
- **BUT** a schema or ABI change invalidates reuse at its corresponding admission gate
  > Boundaries: Stable nominal identity means “same declared type,” not “compatible artifact.”

### Requirement: Canonical encoding and exact witness validation

The identity system SHALL use a versioned, domain-separated, length-framed canonical encoding and SHALL retain enough witness data to reject collisions, corruption, and producer drift.

#### Scenario: Admit a detached canonical requirement
- **WHEN** a consumer admits a detached canonical type identity or artifact requirement candidate
- **THEN** it validates schema version, domain tag, enum values, lengths, counts, nesting budget, child references, and the complete witness before registry insertion or slot assignment
  > Observables: Unknown versions produce an explicit unsupported-version result; malformed or inconsistent candidates produce typed corruption diagnostics and no mutation.
- **BUT** no canonical field contains a raw pointer, numeric runtime `typeId`, function ID, `FName` comparison index, absolute workspace path, registration ordinal, or container memory image
  > Boundaries: Unreal value types may hold data in memory, but their implementation representation is not the canonical equality contract. A persisted wire format remains a later Change.

#### Scenario: Force a digest collision in a test seam
- **GIVEN** two different canonical witnesses mapped to the same injected digest
- **WHEN** equality or resolution compares them
- **THEN** exact witness comparison rejects equality and reports a collision or ambiguous bucket
  > Verification: The collision fixture proves that hashing is an accelerator rather than an authority.

### Requirement: Artifact slots and runtime identifiers are explicitly local

The identity system SHALL represent artifact-local `TypeSlot` and generation-local `RuntimeTypeId` as distinct scoped values that cannot be used as durable type identity.

#### Scenario: Assign slots inside one detached artifact
- **GIVEN** an artifact requirement table containing unique complete type-use, schema, and ABI requirements
- **WHEN** the detached artifact assigns compact `TypeSlot` values
- **THEN** each slot addresses exactly one requirement within that artifact and may be renumbered independently in another artifact
  > Observables: Slot ordering does not change any `TypeDeclKey`, `TypeUseKey`, schema digest, or ABI key.
- **BUT** a slot cannot be compared across artifacts without first resolving its complete requirement
  > Boundaries: Artifact publication and relocation are deferred to a later Change.

#### Scenario: Represent two runtime generations
- **GIVEN** two synthetic generation scopes assign different `RuntimeTypeId` values to the same stable type witness
- **WHEN** the scoped values are compared or serialized
- **THEN** each runtime ID is valid only with its owning generation and is rejected from every durable key encoding
  > Verification: No live `asCScriptEngine` is created or mutated by the identity test.
- **BUT** this contract does not define Engine lookup or atomic publication
  > Boundaries: Runtime resolution, candidate validation, and transactional publication belong to the later Builder/Engine batch.

### Requirement: One canonical type identity authority

The reconstructed frontend SHALL have one producer for canonical type identity, with legacy artifact and runtime structures acting only as checked adapters during migration.

#### Scenario: Consume identity from an existing boundary
- **WHEN** the Unreal artifact identity builder or runtime type binding code needs a stable type reference
- **THEN** it consumes or projects the canonical `TypeDeclKey`/`TypeUseKey` witness produced by `frontend` identity code
  > Observables: Production logic does not independently normalize a declaration string or parse `stableKey` to rediscover ordered type structure.
- **BUT** the migration does not require a second synchronized identity graph or a permanent legacy/new shadow authority
  > Boundaries: Old fields may remain as compatibility projections until their consumers migrate, but they cannot originate conflicting semantic facts or trigger live Engine publication in this Change.
