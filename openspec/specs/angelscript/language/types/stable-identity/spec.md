## Purpose

Define deterministic type declaration and type-use identities that survive compilation boundaries while keeping semantic compatibility and runtime projection explicit.

## Requirements

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
  > Boundaries: A future explicit stable generator key or redirect policy may make a named class of generated declarations cacheable, but this capability does not guess one.

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
  > Boundaries: Unreal value types may hold data in memory, but their implementation representation is not the canonical equality contract. A persisted wire format remains a later capability.

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
  > Boundaries: Artifact publication and relocation are deferred to a later capability.

#### Scenario: Represent two runtime generations
- **GIVEN** two synthetic generation scopes assign different `RuntimeTypeId` values to the same stable type witness
- **WHEN** the scoped values are compared or serialized
- **THEN** each runtime ID is valid only with its owning generation and is rejected from every durable key encoding
  > Verification: No live `asCScriptEngine` is created or mutated by the identity test.
- **BUT** this contract does not define Engine lookup or atomic publication
  > Boundaries: Runtime resolution, candidate validation, and transactional publication belong to a later Builder/Engine batch.

### Requirement: One canonical type identity authority

The reconstructed frontend SHALL have one producer for canonical type identity, with legacy artifact and runtime structures acting only as checked adapters during migration.

#### Scenario: Consume identity from an existing boundary
- **WHEN** the Unreal artifact identity builder or runtime type binding code needs a stable type reference
- **THEN** it consumes or projects the canonical `TypeDeclKey`/`TypeUseKey` witness produced by `frontend` identity code
  > Observables: Production logic does not independently normalize a declaration string or parse `stableKey` to rediscover ordered type structure.
- **BUT** the migration does not require a second synchronized identity graph or a permanent legacy/new shadow authority
  > Boundaries: Old fields may remain as compatibility projections until their consumers migrate, but they cannot originate conflicting semantic facts or trigger live Engine publication in this capability.

### Requirement: Authenticated schema and layout fingerprints preserve nominal identity

The SDK SHALL expose distinct deterministic schema and layout fingerprints for authenticated frozen definitions without changing their stable declaration identity or strengthening the existing shell-freeze contract.

#### Scenario: Observe identity before compatibility is available

- **WHEN** a caller creates an actual detached ObjectType with a stable declaration key
- **THEN** the object exposes that key immediately, without an Engine or runtime ID
- **BUT** a fingerprint request for an incomplete or unauthenticated definition returns an explicit failure and no digest

  > A nonzero caller-supplied key and successful low-level shell freeze are not proof of a canonical definition. Existing shell freeze remains usable independently.

#### Scenario: Distinguish identity from definition and storage changes

- **GIVEN** independently created versions of the same nominal declaration
- **WHEN** a member, callable contract, target representation or body changes
- **THEN** each comparison changes only in its declared domain

  | Change | Stable declaration key | Schema fingerprint | Layout fingerprint |
  |---|---|---|---|
  | Field name or callable return contract | Unchanged | Changes | Changes only if physical storage changes |
  | Field storage type or order | Unchanged | Changes | Reflects the resulting representation |
  | Target pointer width or storage ABI | Unchanged | Unchanged | Changes |
  | Function body or source location | Unchanged | Unchanged | Unchanged |

- **AND** ordinary callable keys alone do not authenticate complete signatures

  > Return type, parameter direction and relevant definition traits are compared even when an ordinary FunctionKey is equal.

#### Scenario: Recheck a frozen definition at admission

- **GIVEN** a previously fingerprinted definition whose exposed fields were subsequently corrupted
- **WHEN** a consumer authenticates it for executable linking
- **THEN** validation compares the actual definition with its complete canonical contract and rejects the mismatch
- **BUT** a stale cached digest cannot authorize publication

### Requirement: Fingerprint dependencies have explicit cycle and equality rules

The SDK SHALL compute local semantic fingerprints and target layout fingerprints with distinct dependency rules, preserving exact canonical witnesses and rejecting invalid value cycles without partial output.

#### Scenario: Fingerprint recursive handle types

- **GIVEN** types A and B that refer to each other through handles
- **WHEN** their schemas and layouts are fingerprinted
- **THEN** local schema records reference canonical type keys and handle layout uses pointer representation

  > The dependency requirement closure authenticates each referenced definition separately; neither fingerprint recursively embeds the entire handle graph.

- **AND** equivalent definitions created in reversed registration order produce equal canonical witnesses and digests
- **BUT** a by-value A-to-B-to-A cycle returns an invalid-layout result without publishing partial fingerprints

#### Scenario: Reject a digest collision

- **GIVEN** distinct schema or layout witnesses mapped to one injected digest
- **WHEN** a consumer compares compatibility
- **THEN** exact domain, version and witness comparison reports the collision rather than accepting equality

  > Raw memory images, pointers, Engine IDs, FName indices and incidental iteration order are never canonical input.

#### Scenario: Inspect retired metadata without authorizing execution

- **WHEN** an external lease retains an authentic immutable definition after its Engine retires
- **THEN** its semantic identity and fingerprints remain inspectable
- **BUT** fingerprint availability does not grant attachment, executable binding or access to retired runtime IDs
