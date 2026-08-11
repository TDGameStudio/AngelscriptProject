# as-script-artifact-identity Specification

## Purpose
TBD - created by archiving change refactor-as-incremental-function-cache. Update Purpose after archive.
## Requirements
### Requirement: Persisted script entities have deterministic full-width identities

The Runtime SHALL derive module, type, function, global, and property identities from versioned, domain-separated canonical descriptions and BLAKE3-256. Persisted identity MUST NOT include process addresses, temporary AngelScript FunctionIds, compilation or registration order, random values, absolute filesystem paths, source line/column, or Unreal `FName` comparison indices.

#### Scenario: Identical entities are built in different processes

- **WHEN** identical logical scripts are compiled in processes with different addresses, FunctionIds, worker completion order, or map insertion order
- **THEN** every complete module, type, function, global, and property stable key is identical

#### Scenario: Source lines move without declaration changes

- **WHEN** comments or blank lines move a declaration without changing its logical module, namespace, owner, kind, declaration, or traits
- **THEN** that entity's stable key remains identical

### Requirement: Module identity uses canonical logical source coordinates

The Runtime MUST build a stable module key from the logical source mount, normalized virtual path, and explicit or derived module name. It MUST preserve logical case, normalize separators and dot segments, reject case-insensitive logical-path collisions, and exclude the host machine's absolute source path.

#### Scenario: Project is moved to another absolute directory

- **WHEN** the same logical script tree is compiled from a different project or drive path
- **THEN** stable module and descendant entity keys remain identical

#### Scenario: Two paths differ only by filesystem case

- **WHEN** source discovery observes two logical paths that compare equal case-insensitively but are not byte-identical
- **THEN** the source snapshot is rejected as ambiguous
- **AND** no cache generation is selected or published from that snapshot

### Requirement: Every type and callable kind has a canonical owner

The identity encoder MUST define stable owner and kind fields for classes,
structs, interfaces, enums, delegates, typedefs, funcdefs, globals, properties,
global functions, methods, constructors, destructors, factories, delegate
signatures, module initializers, global initializers, generated default
constructors, and `__InitDefaults`. Generated default destructor SHALL retain
the existing Destructor entity kind and Type owner, with the generated nature
represented by the canonical Generated trait and invocation coordinate; V1
MUST NOT add or renumber a shared entity discriminator for it.

#### Scenario: Overloads and owner types differ

- **WHEN** two functions share a name but differ by owner, namespace, function kind, return, parameters, qualifiers, or traits
- **THEN** their complete stable function keys differ

#### Scenario: Synthetic function receives an identity

- **WHEN** the builder generates a factory, default constructor, module initializer, global initializer, or `__InitDefaults` function
- **THEN** its key derives from its semantic module/type/global owner and function kind
- **AND** it does not derive from an allocation ordinal, source line, or random value

#### Scenario: Generated default destructor receives an identity

- **WHEN** the compiler captures a generated default destructor
- **THEN** its stable identity uses existing `EntityKind::Destructor=35`, its Type owner, and canonical Generated trait
- **AND** the FunctionBody invocation coordinate distinguishes it from an ordinary destructor without changing shared enum numbers

### Requirement: Pre-compile function input is independent from logical identity

The Runtime SHALL compute a canonical `FunctionSourceDigest` from the function token/AST slice, invocation-kind semantics and compile/preprocessor options. A cold or missed compile SHALL instrument compiler/artifact capture to persist the actual stable declaration/type/global/property/environment dependency set in canonical order. For a later matching source digest, the Runtime SHALL resolve that persisted dependency set against current ABI fingerprints and compute `FunctionInputDigest` before deciding whether to invoke the compiler. A changed source digest MUST miss without requiring a duplicate semantic-analysis pass. A function body change MUST NOT change `StableFunctionKey` but MUST change the source/input digest when compiled semantics can change.

#### Scenario: One function body changes

- **WHEN** function B changes without changing function A's canonical body, declaration, options, or semantic dependencies
- **THEN** A retains both its stable key and input digest
- **AND** B retains its stable key but receives a different input digest

#### Scenario: Referenced type or binding ABI changes

- **WHEN** a type layout, property/global declaration, or bound environment symbol actually referenced by a function changes ABI
- **THEN** resolving the function's persisted actual dependency set changes that function's input digest
- **AND** its old FunctionBody cannot be selected as a hit

### Requirement: Compiled execution and debug content are validated separately

The Runtime SHALL compute a post-compile execution content hash from canonical bytecode, literals/operands, stack and local layout, exception cleanup, and stable symbolic references. It SHALL represent source maps, line cues, and debug-only names in a separate debug hash/sidecar.

#### Scenario: Formatting changes only debug mapping

- **WHEN** formatting or comments change source lines while execution bytecode and stable runtime dependencies remain equivalent
- **THEN** the execution content hash may remain equal
- **AND** a debug-enabled context receives changed debug content

#### Scenario: Restored execution bytes are corrupt

- **WHEN** a cached FunctionBody's canonical execution payload does not match its full content hash
- **THEN** the artifact is rejected before it is attached to a current-engine function

### Requirement: Debug absence is a shared profile-specific identity value

The common artifact-identity layer SHALL expose one function that builds an
absent-debug hash with `FAngelscriptArtifactCanonicalWriter` domain
`function-debug-absent` and exactly one field: the complete 32-byte
ArtifactProfileKey. Cache V2 and the sibling StaticJIT provider SHALL consume
that same API and full-hash golden vectors. Neither consumer MAY substitute a
zero hash, a zero RecordId, a raw BLAKE3 call, or the `function-debug` hash of
an empty payload.

#### Scenario: Editor and Shipping omit debug bytes

- **WHEN** the same stable function has no DebugSidecar in two distinct Editor and Shipping profiles
- **THEN** the shared API produces the frozen full-hash absence vector for each complete ProfileKey
- **AND** the two profile-specific values differ without changing the StableFunctionKey

#### Scenario: Cache and StaticJIT compare absent debug

- **WHEN** both consumers represent no debug payload for one profile
- **THEN** they compare the same shared identity result and golden bytes
- **AND** neither component owns a second absence algorithm

### Requirement: Compatibility, compilation context, and environment symbols are distinct

The Runtime MUST derive a `CompatibilityKey` from Cache/encoder schema, compiler and bytecode ABI, required UE ABI, platform, architecture, endian and pointer-width inputs. It MUST derive a `ContextKey` from target/configuration, engine properties, compile/preprocessor settings, source mounts, source-provider configuration, and debug policy. `ArtifactProfileKey` SHALL combine those keys, while bound type/function/global/property ABI changes SHALL be tracked as per-record environment-symbol dependencies rather than one global binding-surface profile hash.

#### Scenario: Editor and Shipping contexts coexist

- **WHEN** the same logical function is compiled for Editor and Shipping contexts
- **THEN** its stable function key remains the same
- **AND** its artifact profiles are distinct and coexist in separate cache namespaces

#### Scenario: Unrelated binding changes

- **WHEN** a binding not referenced by a cached record is added or changes
- **THEN** that record's profile and dependency match remain valid

#### Scenario: Referenced binding changes

- **WHEN** a cached record names an environment symbol whose ABI fingerprint changed
- **THEN** that record is a typed dependency miss
- **AND** unrelated records remain eligible hits

### Requirement: Full 256-bit hashes are authoritative

Persistence, equality, collision detection, cache matching, and StaticJIT route matching MUST compare the complete 256-bit value. A derived `FGuid` or truncated text MAY be displayed but MUST NOT be the sole match key.

#### Scenario: Display GUID collides

- **WHEN** two test hashes share the same derived display GUID but differ in their remaining bytes
- **THEN** the system treats them as distinct full identities or reports a collision
- **AND** it never aliases them or increments an ID to resolve the condition

#### Scenario: Full hash has conflicting canonical metadata

- **WHEN** one generation contains the same full key with conflicting canonical identity metadata
- **THEN** the generation is rejected as corrupt before engine mutation

### Requirement: Numeric FunctionId remains current-engine state

AngelScript numeric FunctionIds MAY be used only inside an engine-owned routing table. Manifests, records, dependency edges, persisted diagnostics, and StaticJIT provider entries MUST use stable artifact identity.

#### Scenario: Hot reload replaces a function object

- **WHEN** hot reload creates a new `asCScriptFunction` and numeric FunctionId for the same logical function
- **THEN** the current engine rebuilds stable-key routing for the replacement
- **AND** persistent Cache/StaticJIT lookup continues through the stable key

#### Scenario: Two engines reuse a numeric FunctionId

- **WHEN** two engines assign the same numeric FunctionId to different logical functions
- **THEN** their engine-owned maps remain isolated
- **AND** neither engine selects an artifact by numeric ID alone

### Requirement: StaticJIT consumes identity without owning Cache V2

The stable function key, execution/debug content hash, artifact profile, and environment ABI coordinates SHALL be usable by `refactor-as-static-jit-external-module` without exposing Cache V2 manifests, packs, generations, pointers, source-authority policy, filesystem store, codec, publication, or compaction state. Cache RecordId/RawChecksum/PackId/GenerationId and StaticJIT ProviderGeneration SHALL remain distinct domains; a Cache physical repack or pointer rotation MUST NOT change Native route identity or eligibility.

#### Scenario: Native provider entry is missing or stale

- **WHEN** Cache V2 restores a valid AS FunctionBody but no StaticJIT provider entry exactly matches its stable key, selected content hash, profile, and ABI
- **THEN** the function remains valid for VM execution
- **AND** Cache V2 is not invalidated or deleted

#### Scenario: Cache physical layout changes only

- **WHEN** Cache V2 repacks equal semantic records or rotates a generation pointer without changing shared function/content/profile/environment coordinates
- **THEN** StaticJIT provider matching and route selection remain unchanged
- **AND** the provider does not consume or alias the Cache GenerationId
