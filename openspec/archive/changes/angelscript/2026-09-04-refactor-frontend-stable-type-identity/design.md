## Context

The current tree already contains useful pieces, but their ownership is fragmented:

- root-level `asCDecl::stableKey` and `asCType::stableKey` are strings and are sometimes treated as both identity and recoverable structure;
- `FAngelscriptStableTypeKey` is a BLAKE3-256 hash without a typed canonical witness in the public value;
- `asSTypeABIKey` mixes a stable-key string with target profile, native environment, kind, qualifiers, layout, and behavior facts;
- artifact relocations and runtime binding tables correctly avoid persisting pointers in some paths, yet dynamic `typeId`, `TypeInfo*`, offsets, and function/property pointers remain necessary after current-generation resolution.

The new model makes these phases explicit rather than attempting to eliminate dynamic runtime values.

## Goals / Non-Goals

**Goals:**

- Define deterministic and exact nominal declaration identity.
- Define recursive structural type-use identity without string parsing.
- Separate semantic schema and target ABI compatibility from nominal identity.
- Deduplicate complete artifact requirements behind compact local slots.
- Make generation-local runtime identifiers explicit without resolving or publishing them.
- Adapt current artifact/runtime boundaries to one canonical producer.
- Permit UE core implementation types inside ThirdParty without allowing their internals into canonical identity.

**Non-Goals:**

- New VM opcodes or steady-state runtime hash lookup.
- A complete Cache V2 migration, sidecar version bump, legacy bytecode V5, or persistence facade.
- Stable function/property/global/resource identities beyond the minimum adapter work required for types.
- Rename redirects, anonymous structural record identity, or automatic stable IDs for generated declarations.
- Engine-free VM execution or live `UObject` publication from the frontend.

## Decisions

### Put the authority in lowercase `frontend`

Implementation lives under `ThirdParty/angelscript/source/frontend/` inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`. Final public implementation names do not carry `V2` suffixes. The central types are:

```text
frontend::asCCanonicalEncoding
frontend::asSTypeDeclDescriptor -> frontend::asSTypeDeclKey
frontend::asSTypeUseDescriptor  -> frontend::asSTypeUseKey
frontend::asSTypeSchemaDigest
frontend::asSTypeABIKey
frontend::asSTypeRequirement
frontend::asSTypeSlot
frontend::asCTypeIdentityRegistry
```

These descriptors are deliberately established before the sibling typed-AST Change, which consumes them when it defines canonical `asCType`/`asCQualType` nodes. The NativeEngine CQTest foundation and immutable logical-source contract are external implementation prerequisites and are not entries in this Change's `task_graph`.

### Use one deterministic canonical encoder

`asCCanonicalEncoding` writes a fixed schema version and domain tag, then length-framed values in a prescribed order. Strings are canonical UTF-8 values; unordered semantic sets are normalized and sorted by encoded bytes, while sequences such as owner paths and generic arguments retain order. Container enumeration order never defines bytes.

Each key contains or owns:

- schema and domain identity;
- complete canonical witness bytes or an equivalent exact immutable descriptor;
- BLAKE3-256 digest for maps, indexes, and quick rejection.

Equality compares schema/domain and the complete witness after any digest match. Tests provide a digest-injection seam to prove collision handling.

### Separate nominal declaration identity from type use

`TypeDeclKey` is nominal. Its stable components are:

```text
stable module/provider scope
semantic namespace and owner path
declaration kind
canonical declaration name
generic arity
explicit stable generator identity when applicable
```

It excludes member lists, bodies, target layout, source position, display spelling, current engine data, and allocator state.

`TypeUseKey` references a canonical declaration and recursively records ordered type arguments and legal use qualifiers. Weak alias spelling remains in source/type-location provenance; a strong distinct typedef owns a separate declaration key. Parameter passing and lifetime ownership are edge contracts, not qualifier bits smuggled into the type key.

### Make compatibility layers independently typed

| Layer | Equality purpose | Lifetime |
|---|---|---|
| `TypeDeclKey` | Same nominal declaration | Cross snapshot/artifact |
| `TypeUseKey` | Same structural semantic use | Cross snapshot/artifact |
| `TypeSchemaDigest` | Same durable semantic shape | Cross snapshot/artifact |
| `TypeABIKey` | Compatible target representation/behavior | Target/profile scoped |
| `TypeSlot` | Compact reference inside one artifact | Artifact scoped |
| runtime binding | Efficient engine values | Generation scoped |

This avoids the two common errors: putting layout into nominal identity, which causes needless key churn, and treating stable identity as proof of ABI compatibility, which can execute stale artifacts.

### Deduplicate detached artifact requirements without publishing them

An artifact stores one table of unique `asSTypeRequirement` values. Bytecode or other artifact records refer to a compact `TypeSlot`; the full witness and ABI requirement are not repeated per use. Another artifact may assign different slot values without changing stable identity.

`RuntimeTypeId` becomes an explicitly generation-owned wrapper rather than an integer that can be mistaken for stable identity. The existing `asSTypeABIKey` and runtime type-binding declarations may expose checked projections of canonical identity, but their live lookup, candidate validation, relocation, and publication behavior does not change here.

Production VM instructions continue using their existing current-generation values, so this design adds no steady-state key lookup and no new publication path.

### Use existing UE hashing through a representation-independent seam

The current Unreal artifact layer already exposes BLAKE3. The frontend encoder may use that implementation and UE containers because ThirdParty is part of the same module. Nevertheless:

- `FName` contributes its canonical string, never its comparison index;
- `FString` is explicitly encoded as canonical UTF-8, never copied as `TCHAR` memory;
- `TMap` iteration is sorted or replaced by prescribed sequence order;
- pointers, `TSharedPtr` addresses, and allocator layout never enter bytes.

### Migrate by checked adapters, not dual authority

`FAngelscriptArtifactIdentityBuilder` becomes an adapter over canonical descriptors for stable type identity. `asSTypeABIKey` and runtime binding declarations consume or retain a checked projection rather than parsing root-level strings. Existing hash values may remain API projections, but a hash-only value cannot originate or authenticate semantic structure.

No sidecar/cache wire format or Engine resolution behavior changes in this Change. A later persistence Change will serialize these canonical records with an explicit version and budgets. Unknown old/new combinations clean-miss; they are never silently reinterpreted.

## Failure Modes and Isolation

- Missing or unstable owner identity makes a declaration explicitly non-cacheable.
- Invalid qualifier roles, excessive recursion/count/bytes, unknown tags, malformed child references, and corrupted witness data fail before registry insertion.
- A digest collision enters an exact-comparison bucket and never binds by hash alone.
- Artifact-local slots and generation-local runtime IDs fail owner validation when used outside their scope.
- This Change performs no live Engine resolution or publication, so identity validation failure has no runtime mutation to roll back.

## Risks / Trade-offs

- Complete witnesses cost more memory than hash-only keys. Interning and artifact-local deduplication contain this cost and are required for correctness under collision or producer drift.
- Canonical encoding becomes a compatibility contract. Version and domain tags make intentional evolution explicit.
- Adapters temporarily expose old and new shapes. The frontend remains the only producer, and tests reject reverse parsing or divergent normalization.
- Generated/anonymous declarations without stable ownership lose cacheability. Failing closed is safer than a source-line or ordinal identity that changes under unrelated edits.
- Cross-Change readiness is not visible in the local DAG; the coordinator must gate Task 1.1 on the CQTest and source foundations, and the later typed-AST Change must consume this verified identity contract.

## Rejected Alternatives

- Treat numeric runtime `typeId`, `TypeInfo*`, function IDs, or registration order as stable identity.
- Use short name or canonical declaration text alone without stable scope, owner, kind, and arity.
- Use a digest as the full equality witness.
- Include member layout, function bodies, source line, absolute path, or tooltip metadata in `TypeDeclKey`.
- Parse `stableKey` strings to recover nested type arguments or qualifier semantics.
- Store `FName` indices, `FString` memory, pointer values, or `TMap` iteration order in canonical bytes.
- Define live runtime lookup or publication behavior before the later Builder/Engine Change.
- Copy Clang's in-memory pointer-based `QualType` identity or its module-local serialized numeric `TypeID` as a cross-artifact key.
- Expand this Change into a cache, sidecar, bytecode-format, or VM-kernel rewrite.
