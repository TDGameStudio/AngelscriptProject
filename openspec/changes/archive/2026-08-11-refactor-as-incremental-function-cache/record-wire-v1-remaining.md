# Cache V2 Task 2B-2 Remaining Record Wire V1

## Status and authority

This document is the normative Task 2B-2 contract for `TypeSchema`,
`ModuleState`, `FunctionBody`, `DebugSidecar`, `ModuleSnapshot`, the VM-opaque
payload validation seam, and per-module graph validation. It incorporates the
following exhaustive, co-normative matrices by reference:

- `type-schema-matrix-v1.md` for every TypeSchema kind, payload, relation,
  property/layout, method, behavior, reflection, dependency, and precedence
  row;
- `type-layout-authority-v1.md` for pointer-free property/layout-input numeric
  evidence, immutable replay, current-layout comparison, TS-SCR budgets, and
  physical-decode precedence; and
- `module-state-matrix-v1.md` for every ModuleState global, initialization,
  scalar value, cleanup, hard-value, initializer, post-init, opaque, hash, and
  precedence row.

The matrices have been promoted into OpenSpec authority. ModuleState is
independently approved, and the combined TypeSchema/layout authority received
the required explicit independent approval recorded in `verification.md` on
2026-08-08. Task 2B-2 byte-golden RED is therefore authorized; that approval
does not claim any RED/GREEN implementation or runtime acceptance.
Where the compact summaries below omit a row, the corresponding exhaustive
matrix wins; there is no permissive gap.

`record-wire-v1.md` remains the authority for the record envelope with its fixed
56-byte header followed by the declared canonical payload, canonical scalar and
collection encoding, common values, `SourceIndex`, `ModuleInterface`, errors
`0..43`, and Task 2B-1 byte layout. The TypeSchema review previously reopened
that common contract for the additive generated-delegate owner-matrix
correction. The correction, semantic-offset closure, allocator-authoritative
scratch accounting, fresh regressions/builds, and final independent Task 2B-1
approval are now recorded and tasks 2.2/2.3 are closed. Zero-flag reflected-function
membership requires no common declaration bit: the explicit TypeSchema
`ReflectionSchema.OrderedUFunctionMembers` authority below owns that fact and
order. All other common values named below use the Task 2B-1 document byte-for-
byte. This document adds record-kind-specific payloads and errors without
silently redefining any 2B-1 field, number, comparator, or byte.

If an abbreviated C++ sketch in `implementation-plan.md` or an earlier prose
summary conflicts with this document, this document wins for Task 2B-2. The
implementation MUST still be pointer-free and value-only. Task 2B-2 constructs
no live AngelScript engine, UObject, source provider, filesystem store,
manifest, pack, or StaticJIT provider.

### Task 2B-2 RED blockers

Task 2B-2 RED MUST NOT begin until both gates below are closed. The absence of
an approved row is not permission for an implementer to infer behavior from
current compiler code, legacy `.cache` data, or a convenient DTO shape.

1. **Task 2B-1 approval gate — closed.** An earlier snapshot had fresh GREEN
   evidence and an independent `APPROVED — 0 Critical / 0 Important / 0 Minor`
   review, and Slice 0 subsequently extracted only private canonical
   cursor/codec helpers with all existing bytes/hashes/errors preserved. The
   promoted TypeSchema review then proved that generated declarations actually
   owned by delegates were rejected; it also required explicit zero-mask
   UFunction membership, which is now represented in this TypeSchema wire rather
   than by changing ModuleInterface. A later ModuleInterface rereview found an
   enclosing-field semantic-offset gap. The Delegate owner, semantic-offset,
   and allocator-capacity corrections now have genuine RED/GREEN evidence,
   complete regression prefixes, fresh enabled/disabled 105-action builds, and
   final independent `APPROVED — 0 Critical / 0 Important / 0 Minor`; tasks 2.2
   and 2.3 are checked.
2. **Remaining-matrix approval gate — closed.** The complete TypeSchema and
   ModuleState tables plus the numeric layout authority live in the
   co-normative documents named above. ModuleState is independently approved;
   the fresh independent combined TypeSchema/layout review returned
   `APPROVED — 0 Critical / 0 Important / 0 Minor` and is recorded in
   `verification.md`. The focused layout-source audit returned
   `APPROVED — 0 Critical / 0 Important / 1 Minor`; the sole Minor is downstream
   production CompatibilityKey assembler work and does not block RED.

This preflight record did not itself complete implementation tasks; later
evidence has closed 2.2/2.3. Tasks 2.4/2.5 remain open.

## Independent schema and codec axes

The following payload versions are five independent constants. They all begin
at `1`; equal initial values do not make them one shared version.

```text
TypeSchemaPayloadSchemaVersion     = 1
ModuleStatePayloadSchemaVersion    = 1
FunctionBodyPayloadSchemaVersion   = 1
DebugSidecarPayloadSchemaVersion   = 1
ModuleSnapshotPayloadSchemaVersion = 1
```

A future change MAY increment one record kind without incrementing the other
four. The fixed record envelope schema and each VM-private codec version are
separate axes again. Compatibility selection may exclude incompatible codec
families early, but a decoder still validates the explicit record payload and
codec versions it receives.

ModuleInterface and TypeSchema are profile-independent semantic declarations
and MUST NOT acquire ProfileKey fields in V1. ModuleState, FunctionBody
identity, and DebugSidecar carry the profile needed by their execution/debug
codec and graph; ModuleSnapshot derives consistency from those children rather
than storing a second profile authority.

`UnsupportedPayloadSchema` retains value `12`. Its result MUST carry the
established record kind and `PayloadDecode` stage, with `ByteOffset=0` at the
payload-version field. The diagnostic validation stage is not serialized:

```text
EAngelscriptCacheValidationStage
  None=0
  EnvelopeDecode=1
  PayloadDecode=2
  LocalSemantic=3
  OpaqueCodec=4
  ModuleGraph=5
  CurrentResolver=6
```

The enum is append-only: existing values are never inserted, reordered, or
renumbered. `FAngelscriptCacheValidationResult(Error, RecordKind, ByteOffset)`
remains the existing three-argument constructor and its third argument remains
`ByteOffset`; it initializes `Stage=None`. New code creates staged failures
through a distinctly named factory such as
`FAngelscriptCacheValidationResult::AtStage(Error, RecordKind, Stage,
ByteOffset)`. A new stage parameter MUST NOT be inserted into the old positional
constructor.

Every new 2B-2 public failure result contains `Error`, the exhaustive `Class`,
`RecordKind`, `Stage`, and first failing `ByteOffset`. Result construction
derives `Class` from `Error`; callers do not choose a class. Outputs are reset
before validation and published only after complete success. Stage/offset rules
are fixed as follows:

- `EnvelopeDecode` offsets are from byte zero of the complete serialized
  envelope. The payload begins at offset 56; failures in magic/schema/kind/
  reserved/size/hash point to the start of those header fields.
- `PayloadDecode` and `LocalSemantic` offsets are from byte zero of the
  canonical payload. Decode failures point to the first unread/invalid field;
  local presence, ordering, or derived-hash failures point to the enclosing
  field start captured by the decoder.
- `OpaqueCodec` reports the owning record kind and the canonical-payload offset
  of the enclosing opaque byte-array field. Fixture-private instruction offsets
  are not exposed as record offsets.
- `ModuleGraph` reports the offending reachable record kind and the captured
  payload offset of its link/owner/declaration/dependency field. For a missing
  child it reports the referring link field. A context failure with no record
  field uses ModuleSnapshot and offset zero.
- `CurrentResolver` reports the owning record kind and the captured offset of
  the canonical semantic dependency target passed to the resolver.

These offsets are why a graph input must be produced by the validated token
factory below; graph code MUST NOT reconstruct offsets by searching payload
bytes or accept caller-authored offset tables.

## Common canonical rules inherited from Task 2B-1

Unless this document explicitly says otherwise:

- integers, booleans, optionals, hashes, strings, byte arrays, and arrays use
  the scalar encoding in `record-wire-v1.md`;
- strict UTF-8 rejects embedded NUL and performs no Unicode normalization;
- every stable key and semantic hash is the complete 256-bit value;
- set/map-like arrays are canonicalized by the public writer and must already
  be canonical when decoded;
- semantic sequences carry explicit contiguous ordinals and are never sorted
  by an unordered-container implementation;
- common `CanonicalDataType`, `StableReference`, `SemanticDependency`,
  `MetadataEntry`, `Declaration`, and keyed record values reuse the 2B-1
  definitions exactly; and
- all local hashes are recomputed before a decoded DTO is published. The
  enclosing `RecordId` still covers the complete payload, including stored
  derived hashes.

### Local deserialize boundary and validated record token

All five remaining-record private physical/local decoder paths accept
`const FAngelscriptCacheReadLimits&` plus the caller-owned
`FAngelscriptCacheReadBudget&`. They perform only wire decoding, local
canonical/presence/matrix validation, and locally recomputable hash checks.
They do **not** accept or invoke `IAngelscriptCacheOpaquePayloadValidator`.
TypeSchema and ModuleSnapshot have no opaque field; ModuleState initializer,
FunctionBody execution, and DebugSidecar bytes remain opaque after local
deserialize. Their stored payload hashes are recomputed over the exact bytes,
but codec structure and summaries are validated only once for actually
reachable payloads in graph step 1.

`FAngelscriptDecodedCacheRecord` is an immutable validated token rather than a
publicly writable `{RecordId, bytes, DTO}` aggregate. Its constructors, typed
variant, canonical payload bytes, and field-offset table are private. A single
fail-closed factory accepts `{declared RecordId, canonical payload, Limits,
Budget}`, recomputes the RecordId, dispatches the decoder by RecordId kind,
captures each field/nested-element start offset while decoding, and publishes
the token only after local success. It exposes const typed accessors and const
offset lookup only; it exposes no mutable DTO, mutable byte array, mutable
variant, or caller-supplied offset path. Factory failure clears the output.

The private record storage shape is fixed before the token class is defined.
All seven DTO types, all seven typed coordinate types, and all seven complete
private captured-offset storage types MUST be complete first. The token then
owns one in-place by-value `TVariant` whose alternatives are seven private
per-kind aggregates, each containing that kind's DTO plus its complete offset
tables. Canonical payload bytes remain the token's one separate owned byte
array. A pimpl, type-erased heap object, per-kind shared owner, nested owning
handle, or later-growing partial token is forbidden: each would add an
unbudgeted persistent allocation or change the sole public ownership model.

Consequently a public/common token implementation cannot be published after
only SourceIndex and ModuleInterface exist. Task 2B-2 first completes the
declarations and final in-place storage layout for all seven kinds; only then
does it freeze the intrusive controller size and implement `TryDecode`.
SourceIndex/ModuleInterface private candidate plumbing and Budget/codec work
may be prepared earlier, but no two-kind compatibility token is exposed.

The token has a public destructor so the shared controller can destroy it, but
its copy constructor, move constructor, copy assignment, and move assignment
are all deleted. Callers copy only
`FAngelscriptDecodedCacheRecordHandle`; they cannot copy or move `*Handle` into
a second token object outside the factory. Implementation convenience for
`MakeShared` MUST NOT make a normal token constructor public. Use the UE
private-token pattern: a private nested construction-token type plus the
otherwise callable constructor signature required by `MakeShared`. External
code cannot name or construct that token; the public destructor remains
available to the shared controller and every token copy/move special member
remains deleted.

The factory publishes the token through the only V1 owning handle type:

```cpp
class FAngelscriptDecodedCacheRecord;

using FAngelscriptDecodedCacheRecordHandle =
	TSharedRef<const FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>;

class ANGELSCRIPTRUNTIME_API FAngelscriptDecodedCacheRecord
{
public:
	~FAngelscriptDecodedCacheRecord();
	FAngelscriptDecodedCacheRecord(const FAngelscriptDecodedCacheRecord&) = delete;
	FAngelscriptDecodedCacheRecord(FAngelscriptDecodedCacheRecord&&) = delete;
	FAngelscriptDecodedCacheRecord& operator=(
		const FAngelscriptDecodedCacheRecord&) = delete;
	FAngelscriptDecodedCacheRecord& operator=(
		FAngelscriptDecodedCacheRecord&&) = delete;

	static FAngelscriptCacheValidationResult TryDecode(
		const FAngelscriptCacheRecordId& DeclaredRecordId,
		TConstArrayView<uint8> CanonicalPayload,
		const FAngelscriptCacheReadLimits& Limits,
		FAngelscriptCacheReadBudget& Budget,
		TOptional<FAngelscriptDecodedCacheRecordHandle>& OutRecord);

	const FAngelscriptCacheRecordId& GetRecordId() const;
	TConstArrayView<uint8> GetCanonicalPayload() const;
	const FAngelscriptCachedSourceIndex* TryGetSourceIndex() const;
	const FAngelscriptCachedModuleInterface* TryGetModuleInterface() const;
	const FAngelscriptCachedTypeSchema* TryGetTypeSchema() const;
	const FAngelscriptCachedModuleState* TryGetModuleState() const;
	const FAngelscriptCachedFunctionBody* TryGetFunctionBody() const;
	const FAngelscriptCachedDebugSidecar* TryGetDebugSidecar() const;
	const FAngelscriptCachedModuleSnapshot* TryGetModuleSnapshot() const;

	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptSourceIndexFieldCoordinate& Coordinate) const;
	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptModuleInterfaceFieldCoordinate& Coordinate) const;
	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptTypeSchemaFieldCoordinate& Coordinate) const;
	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptModuleStateFieldCoordinate& Coordinate) const;
	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptFunctionBodyFieldCoordinate& Coordinate) const;
	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptDebugSidecarFieldCoordinate& Coordinate) const;
	TOptional<uint64> FindCapturedOffset(
		const FAngelscriptModuleSnapshotFieldCoordinate& Coordinate) const;

private:
	FAngelscriptDecodedCacheRecord();
};
```

All DTO and coordinate types above are declared before the class in the real
header; the compact sketch omits those forward declarations. `TryGet*` returns
the const pointer for exactly the active record kind and null for every other
kind. No unchecked reference accessor exists.

Captured-offset lookup is record-specific and non-wire. Each coordinate has
`{typed Field enum, PrimaryIndex, SecondaryIndex, TertiaryIndex}` with every
index defaulting to `MAX_uint32`. A field defines which indices it consumes;
recursive CanonicalDataType nodes use a stored pre-order ordinal rather than a
variable-length caller path. Wrong token kind, invalid/unapplicable field, or
out-of-range index returns unset. A captured offset of zero returns a set
optional containing zero. Lookup is allocation-free and consults only the
private immutable table built by the decoder; it never scans payload bytes,
searches by semantic value/key, accepts an offset/table from the caller, or
reconstructs a missing coordinate. Graph code treats a missing coordinate for
one of its already-validated DTO rows as an internal invariant failure, not a
fallback to payload scanning or offset zero.

The TypeSchema coordinate enum is append-only and frozen for this slice:

```text
EAngelscriptTypeSchemaCapturedField : u16
  Invalid=0
  PayloadSchemaVersion=1, ModuleKey=2, TypeKey=3, TypeKind=4,
  CanonicalNamespace=5, CanonicalName=6, CanonicalDeclaration=7,
  TypeSemanticFlags=8, Metadata=9, MetadataEntry=10,
  Relation=11, RelationTarget=12,
  LayoutInput=13, LayoutInputTarget=14, LayoutExpectation=15,
  OrderedProperty=16, PropertyKey=17, PropertyType=18,
  PropertyMetadata=19, OrderedMethod=20, MethodFunction=21,
  MethodDeclaringOwner=22, VirtualFunctionSlot=23, VirtualFunction=24,
  VirtualDeclaringOwner=25, VirtualImplementingOwner=26,
  BehaviorSlot=27, BehaviorTarget=28, BehaviorDeclaringOwner=29,
  KindPayload=30, EnumEnumerator=31, EnumEnumeratorMetadata=32,
  CallableSignature=33, Reflection=34, ReflectedFunctionMember=35,
  ReflectedFunctionTarget=36, Dependency=37, DependencyTarget=38,
  ReflectionKind=39, ClassReflectionFlags=40. The append-only subfields retain
  exact intrinsic enum/unknown-flag diagnostics; top-level Reflection remains
  the form-closure fallback.
```

The TypeSchema P/S/T consumption is also frozen here. `U` means
`MAX_uint32`; every unused index MUST be `U` and a non-`U` surplus index
returns unset. Required indices must be present and in range.

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---|---|---|---|
| `0` | `U` | `U` | `U` | `Invalid`; always unset. |
| `1..9` | `U` | `U` | `U` | Top-level scalar/string/Metadata-array-count coordinates. |
| `10` | top-level Metadata ordinal | `U` | `U` | `Metadata[Primary]`, pointing to the entry's first field. |
| `11..12` | Relations ordinal | `U` | `U` | Relation row and its Target. |
| `13..14` | LayoutInputs ordinal | `U` | `U` | LayoutInput row and its Target. |
| `15` | `U` | `U` | `U` | Top-level LayoutExpectation. |
| `16..17` | property ordinal | `U` | `U` | OrderedProperty row and PropertyKey. |
| `18` | property ordinal | CanonicalDataType pre-order ordinal | `U` | Property Type node; each property's root starts at pre-order zero. |
| `19` | property ordinal | property Metadata ordinal | `U` | `OrderedProperties[Primary].Metadata[Secondary]`, pointing to the entry's first field. The nested array-count offset remains decoder-internal and is not a second public coordinate. |
| `20..22` | method ordinal | `U` | `U` | OrderedMethod row, FunctionKey and DeclaringOwner. |
| `23..26` | VFT ordinal | `U` | `U` | VirtualFunctionSlot row, FunctionKey, DeclaringOwner and ImplementingOwner. |
| `27..29` | behavior ordinal | `U` | `U` | BehaviorSlot row, Target and optional DeclaringOwner value. Field 29 is unset when the optional is absent. |
| `30` | `U` | `U` | `U` | KindPayload region start. It is set for every TypeKind, including an empty Class/Struct/Interface arm. |
| `31` | enum enumerator ordinal | `U` | `U` | Enum enumerator row; unset for non-Enum TypeKinds. |
| `32` | enum enumerator ordinal | enumerator Metadata ordinal | `U` | `OrderedEnumerators[Primary].Metadata[Secondary]`, pointing to the entry's first field; unset for non-Enum TypeKinds. The nested array-count offset remains decoder-internal. |
| `33` | `U` | `U` | `U` | CallableSignature region; set only for Delegate/Funcdef. |
| `34` | `U` | `U` | `U` | Top-level Reflection schema. |
| `35..36` | reflected-member ordinal | `U` | `U` | ReflectedFunctionMember row and Target. |
| `37..38` | dependency ordinal | `U` | `U` | Dependency row and Target. |

`PropertyMetadata=19`, `BehaviorDeclaringOwner=29`, and
`EnumEnumeratorMetadata=32` therefore have no implementation-selected
interpretation. Their exact roles above are part of the append-only public
diagnostic API. An absent optional or inapplicable TypeKind/row returns unset;
captured offset zero remains a set optional. Public lookup is allocation-free
and Budget-free.

After complete field-local validation, TypeSchema cross-field failures select
only these existing coordinates; no top-level Relations/LayoutInputs/Properties/
Methods/VFT/Behavior container coordinate exists:

| Failure | Captured field and indices |
|---|---|
| form-dependent semantic-flag contradiction | `TypeSemanticFlags,{U,U,U}` |
| present forbidden Relation | `Relation,{physical-index,U,U}` at the lowest proving index |
| required TypeKind+Reflection Relation absent | `Reflection,{U,U,U}` |
| present forbidden LayoutInput | `LayoutInput,{physical-index,U,U}` at the lowest proving index |
| required TypeKind+Reflection LayoutInput absent | `Reflection,{U,U,U}` |
| form-dependent layout scalar mismatch | `LayoutExpectation,{U,U,U}` |
| forbidden Property/Method/VFT/Behavior row | respectively `OrderedProperty`, `OrderedMethod`, `VirtualFunctionSlot`, or `BehaviorSlot` at the lowest proving physical primary index |
| forbidden reflected member | `ReflectedFunctionMember,{physical-index,U,U}` at the lowest proving index |
| required statics reflected member absent | `Reflection,{U,U,U}` |
| illegal TypeKind+Reflection form, known form flags, or Reflection optional-string presence/value | `Reflection,{U,U,U}` |
| Class Construct/Factory count mismatch | `BehaviorSlot,{physical-index,U,U}` at the first unmatched Construct ordinal `FactoryCount` or Factory ordinal `ConstructCount` row |
| HasDefaultConstructor set/no Construct or HasDestructor set/no Destruct | `TypeSemanticFlags,{U,U,U}` |
| HasDestructor clear/Destruct present | `BehaviorSlot,{physical-index,U,U}` at Destruct ordinal zero |
| script CopyConstruct/CopyFactory alias mismatch | `BehaviorSlot,{physical-index,U,U}` at the Copy row |

A missing required row has no captured row offset. `Reflection` is therefore the
unique fallback only when the validated TypeKind+Reflection form requires that
row; this covers ordinary UClass ShadowSuper/CodeSuper/CodeRoot, UStruct
StructHeader, statics CodeSuper/member and every other legal form. A Base relation
requiring a missing BaseType LayoutInput instead uses that existing `Relation`
row during the later pairing phase; an extra input uses its `LayoutInput` row.

A repeated singleton Relation or LayoutInput coordinate is not a closure failure:
the field-local canonical pass returns `DuplicateKey` or `ConflictingKey` at the
second matching physical row. Behavior optional-owner diagnostics are similarly
exact: ScriptFunction present-zero uses `BehaviorDeclaringOwner` at the row index;
ScriptFunction absent uses `BehaviorSlot` because field 29 is unset; and any
EnvironmentSymbol owner present uses `BehaviorDeclaringOwner` without
interpreting its inactive value.

Locally derivable Dependency set equality is a later local cross-field phase, not
ModuleSnapshot graph work. A missing derived row returns
`MissingCoverage/LocalSemantic` at the physical Dependencies-array/enclosing-field
error offset; no absent-row public coordinate is invented. An extra row returns
`UnexpectedRecord/LocalSemantic` at its indexed `Dependency` physical row. The
earlier field-local pass already owns Dependency duplicate/conflict. Graph resolves
each locally exact target's existence/entity/actual owner/module/ABI and owns
separate ModuleInterface/snapshot record-declaration coverage.

The equally append-only SourceIndex `0..89` and ModuleInterface `0..88` enums,
their exact Primary/Secondary/Tertiary index meanings, recursive DataType
pre-order ordinals, diagnostic routing, and exact-fast-path wrong-kind result
are normative in `source-interface-captured-offsets-v1.md`. They freeze before
the transitional Task 2B-1 public decoder/token APIs are removed.

The SourceIndex, ModuleInterface, ModuleState, FunctionBody, DebugSidecar, and
ModuleSnapshot corrected RED slices freeze equivalent exhaustive enums before
their GREEN. Numeric values are diagnostic API values, not serialized wire;
they still remain append-only once published.

`TOptional<FAngelscriptDecodedCacheRecordHandle>` is only the atomic output
slot; it is not another owning-handle type. Before resetting that slot,
`TryDecode` copies any old handle into a local lifetime guard. This reference-
count-only copy allocates and charges nothing and remains alive until all input
bytes have been consumed. The guard is required because `CanonicalPayload` may
be a view into the old token's canonical or nested owned bytes; clearing its
last public handle first would make the input view dangle. After installing the
guard, `TryDecode` resets the output before validation and leaves it unset on
every failure. A nullable `TSharedPtr`, a raw owning pointer, or a per-record
owning wrapper is forbidden. On success the optional contains exactly one
instance of the sole `TSharedRef` handle above.
The static factory is the only public record deserialize entry point, including
SourceIndex and ModuleInterface after their Task 2B-1 migration;
record-specific physical/local decoders are private implementation details.

The token allocation, shared-control allocation, canonical bytes, DTO-owned
arrays/strings, and field-offset table are charged exactly once by that factory
to the caller's persistent decoded/resident budget before publication. Copying
the handle changes only the existing thread-safe reference count and performs
no allocation or DTO copy. No API may reconstruct a second token from a DTO,
publish a raw owning pointer, or charge the same token bytes again merely
because another graph retains the handle.

The SourceIndex supplied to graph validation is also one of these immutable
tokens and must have `RecordKind=SourceIndex`; graph context MUST NOT accept a
standalone writable `FAngelscriptCachedSourceIndex*`. This removes the trust
hole in which a caller could decode valid bytes, then mutate either the DTO or
its claimed RecordId before graph validation.

The Task 2B-1 `FAngelscriptValidatedSourceIndex` was an implementation-slice
boundary before this common factory existed. Final V1 removes its public
owning/graph role rather than wrapping it. SourceIndex local decoding becomes a
private candidate dispatched by `TryDecode`; exact-fast-path eligibility reads
the common token's const SourceIndex accessor and rejects any other RecordKind.
ModuleInterface likewise no longer publishes a mutable DTO from a public
decoder. There is no legacy compatibility adapter and no second charge when a
SourceIndex or ModuleInterface is retained by a candidate graph.

Signed `int32` enum values and signed canonical scalar values below are encoded
as their two's-complement fixed-width little-endian bit patterns. This is a
specific signed-value rule, not a change to the unsigned scalar conventions in
the common wire document.

## Stable V1 enums and flags

Zero is invalid unless explicitly listed as a valid value.

### Type schema enums

```text
EAngelscriptCachedTypeKind : u8
  Invalid=0
  Class=1, Struct=2, Interface=3, Enum=4, Delegate=5,
  Typedef=6, Funcdef=7

EAngelscriptCachedTypeRelationKind : u8
  Invalid=0
  Base=1, ShadowSuper=2, CodeSuper=3,
  ImplementedInterface=4, Compose=5

EAngelscriptCachedMemberAccess : u8
  Invalid=0, Public=1, Protected=2, Private=3

EAngelscriptCachedMethodSlotKind : u8
  Invalid=0
  LocalMethod=1, VirtualDeclaration=2,
  VirtualOverride=3, Inherited=4

EAngelscriptCachedBehaviorKind : u8
  Invalid=0
  Construct=1, ListConstruct=2, Destruct=3,
  Factory=4, ListFactory=5, AddRef=6, Release=7,
  GetWeakRefFlag=8, TemplateCallback=9, GetRefCount=10,
  SetGcFlag=11, GetGcFlag=12, EnumRefs=13, ReleaseRefs=14,
  Copy=15, CopyConstruct=16, CopyFactory=17

EAngelscriptCachedReflectionKind : u8
  None=1, UClass=2, UStruct=3, UEnum=4, UDelegate=5
```

Type semantic flags are a `u32` mask:

```text
Abstract=0x00000001
Final=0x00000002
Shared=0x00000004
Generated=0x00000008
HasDefaultConstructor=0x00000010
HasDestructor=0x00000020
ValueType=0x00000040
ReferenceType=0x00000080
KnownMask=0x000000ff
```

The complete per-kind required/allowed/forbidden predicate is normative in
`type-schema-matrix-v1.md` section 4. In particular Delegate is a generated
value type and requires `Final|Generated|ValueType`, not `ReferenceType`;
Class requires `ReferenceType`; Struct requires `Final|ValueType`; Interface
requires `Abstract|ReferenceType`; Enum requires `Final|ValueType`; Typedef
sets none; and Funcdef requires `ReferenceType`. `Abstract|Final` and
`ValueType|ReferenceType` are always contradictory. A producer that cannot
represent a maintained-fork semantic flag in this mask marks the complete
snapshot NotCacheable; it never drops or masks the flag.

Class reflection flags are a separate `u32` mask:

```text
SuperIsCodeClass=0x00000001
StaticsClass=0x00000002
Abstract=0x00000004
Transient=0x00000008
HideDropdown=0x00000010
DefaultToInstanced=0x00000020
EditInlineNew=0x00000040
Deprecated=0x00000080
Placeable=0x00000100
IsStruct=0x00000200
KnownMask=0x000003ff
```

Property semantic flags are a `u32` mask:

```text
HasUnrealProperty=0x00000001
BlueprintReadable=0x00000002
BlueprintWritable=0x00000004
EditableOnDefaults=0x00000008
EditableOnInstance=0x00000010
EditConst=0x00000020
InstancedReference=0x00000040
PersistentInstance=0x00000080
AdvancedDisplay=0x00000100
Transient=0x00000200
Replicated=0x00000400
SkipReplication=0x00000800
SkipSerialization=0x00001000
SaveGame=0x00002000
RepNotify=0x00004000
Config=0x00008000
Interp=0x00010000
AssetRegistrySearchable=0x00020000
NoClear=0x00040000
KnownMask=0x0007ffff
```

Member access is always the separate `EAngelscriptCachedMemberAccess`; no
public/protected/private bit is duplicated in property flags.

```text
EAngelscriptCachedReplicationCondition : u8
  None=0
  InitialOnly=1, OwnerOnly=2, SkipOwner=3, SimulatedOnly=4,
  AutonomousOnly=5, SimulatedOrPhysics=6, InitialOrOwner=7,
  Custom=8, ReplayOrOwner=9, ReplayOnly=10,
  SimulatedOnlyNoReplay=11, SimulatedOrPhysicsNoReplay=12,
  SkipReplay=13, Dynamic=14, Never=15, NetGroup=16
```

A property without `Replicated` MUST use `None`. `NetGroup` is forbidden for
script property records in V1. Unknown values and unknown flag bits reject.

Property storage and TypeSchema layout inputs use these remaining-wire enums:

```text
EAngelscriptCachedPropertyStorageKind : u8
  Invalid=0, InlineValue=1, ObjectHandle=2

EAngelscriptCachedTypeLayoutInputKind : u8
  Invalid=0, BaseType=1, CodeRoot=2, StructHeader=3
```

Their exact canonical-type predicate, role/presence matrix, producer evidence,
and current comparison are normative in `type-layout-authority-v1.md`. Unknown
or zero stored values reject with `UnknownEnumValue`.

### State, value, and lifecycle enums

```text
EAngelscriptCachedGlobalInitializationKind : u8
  Invalid=0, Default=1, PureConstant=2, VmInitializer=3

EAngelscriptCachedGlobalCleanupPolicy : u8
  Invalid=0, None=1, DestroyValue=2, ReleaseHandle=3

EAngelscriptCachedHardValueKind : u8
  Invalid=0, GlobalConstant=1, EnumAuthority=2

EAngelscriptCachedInitializerKind : u8
  Invalid=0, Global=1, Module=2

EAngelscriptCachedInitializationActionKind : u8
  Invalid=0, DefaultConstructGlobal=1, ExecuteInitializer=2

EAngelscriptCacheValueStorageKind : u8
  Invalid=0, Trivial=1, OwningValue=2, ReferenceCounted=3

EAngelscriptCachedCanonicalValueKind : u8
  Invalid=0
  Bool=1, SignedInteger=2, UnsignedInteger=3,
  Float32=4, Float64=5, EnumInt32=6
```

The three initialization states are mutually exclusive. No old trio of
`bIsDefaultInit`, `bIsPureConstant`, and `bHasInitFunction` booleans is
persisted.

Cleanup policy is validated from the canonical global type:

- a non-void primitive uses `None`;
- a resolved ScriptType Class/Interface/Funcdef uses `ReleaseHandle`;
- a resolved ScriptType Struct/Delegate uses `DestroyValue`;
- a resolved Enum or primitive-only Typedef uses `None`;
- an EnvironmentType uses the current resolver's explicit
  `ValueStorageKind={Trivial,OwningValue,ReferenceCounted}` mapping to
  `{None,DestroyValue,ReleaseHandle}`; an opaque ABI hash never implies the
  category;
- an explicit object handle is legal only for a reference/ReferenceCounted
  semantic type and uses `ReleaseHandle`;
- `Auto`, `Void`, reference globals, and any type whose ownership cannot be
  determined are NotCacheable; and
- every other policy/type combination is `InvalidPresence`.

There is no opaque module-lifetime field and no persisted equivalent of
`isGlobalVarInitialized`.

### Function and opaque payload enums

```text
EAngelscriptCachedFunctionInvocationKind : u8
  Invalid=0
  GlobalFunction=1, Method=2, Constructor=3, Destructor=4,
  Factory=5, GeneratedDefaultConstructor=6,
  GeneratedDefaultDestructor=7, InitDefaults=8,
  PublicSingleFunction=9, Lambda=10

EAngelscriptCacheOpaquePayloadKind : u8
  Invalid=0
  FunctionExecution=1, InitializerExecution=2, Debug=3
```

`NotCacheable` is a capture/lookup outcome and is not a wire invocation kind.
Public single functions and lambdas are persisted only when the producer can
provide the complete stable module/owner/function identity required by the
common declaration contract.

## Hash domains and exact streams

Every hash in this section uses the existing
`FAngelscriptArtifactCanonicalWriter`. Therefore the prefix, identity schema
version, domain length, little-endian scalar encoding, string encoding, hash
width, optional tags, and array counts are exactly those already frozen by
Task 1. Each stream excludes its own stored result.

Nested common values are written field-by-field in their normative wire order.
Canonical sets are written with their count and canonical rows. Semantic
sequences are written with count, kind where applicable, explicit ordinal, and
row fields.

```text
StorageLayoutHash = H("cache-data-type-storage-layout-v1",
  CanonicalDataType,
  StorageKind,
  SemanticStorageSize,
  SemanticStorageAlignment)

LayoutInputHash = H("cache-type-layout-input-v1",
  InputKind,
  Target.ReferenceKind,
  Target.StableKey,
  Target.ExpectedAbi,
  BoundaryContribution presence/value,
  AlignmentContribution presence/value)

PropertyLayoutFingerprint = H("cache-property-layout-v1",
  OwnerTypeKey,
  PropertyKey,
  CanonicalName,
  CanonicalDataType,
  StorageKind,
  SemanticStorageSize,
  SemanticStorageAlignment,
  StorageLayoutHash,
  MemberAccess,
  LayoutOrdinal,
  SemanticByteOffset,
  PropertySemanticFlags,
  ReplicationCondition,
  canonical Metadata)

TypeLayoutHash = H("cache-type-layout-v1",
  TypeKey,
  TypeKind,
  canonical relation-kind sections including SemanticOrdinal presence/value,
  canonical LayoutInputs including each stored LayoutInputHash,
  SemanticSize,
  SemanticAlignment,
  BasePropertyBoundary,
  ordered PropertyLayoutFingerprints,
  exact OrderedMethods,
  exact VirtualFunctionTable,
  BehaviorSlots grouped by ascending BehaviorKind and ordinal,
  TypeSemanticFlags,
  ReflectionKind,
  ClassReflectionFlags,
  ConfigName presence and bytes,
  StaticClassGlobalName presence and bytes,
  exact OrderedUFunctionMembers)

EnumAuthorityHash = H("cache-enum-authority-v1",
  TypeKey,
  for each ordered enumerator:
    DeclarationOrdinal,
    CanonicalName,
    SignedInt32Value,
    canonical Metadata)

GlobalStorageLayoutFingerprint = H("cache-global-storage-layout-v1",
  ModuleKey,
  GlobalKey,
  StorageOrdinal,
  CanonicalNamespace,
  CanonicalName,
  CanonicalDataType,
  GlobalTraitFlags,
  InitializationKind,
  CleanupPolicy)

HardValueHash = H("cache-hard-value-v1",
  HardValueKind,
  Owner StableReference,
  CanonicalDataType,
  canonical value)

InitializerExecutionHash = H("cache-initializer-execution-v1",
  ModuleKey,
  ArtifactProfileKey,
  InitializerKey,
  VmInitializerCodecVersion,
  CanonicalExecutionPayload)

StateInputHash = H("cache-module-state-input-v1",
  ModuleStatePayloadSchemaVersion,
  ModuleKey,
  ArtifactProfileKey,
  all canonical GlobalSchema fields including storage fingerprints,
  all canonical HardValue fields and hashes,
  all canonical InitializerUnit fields including codec versions, payload bytes
    and execution hashes,
  all ordered InitializationAction fields including targets and dependencies,
  all ordered PostInitFunction fields,
  all canonical ModuleState dependencies)
```

For `GlobalConstant`, the hard-value stream's canonical value is the stored
scalar `CanonicalValue`. For `EnumAuthority`, the canonical value is the
linked TypeSchema's complete `cache-enum-authority-v1` input stream. The
ModuleState stores only the resulting `HardValueHash`; it does not duplicate
the enum members. Consequently a GlobalConstant hash is locally recomputable,
while an EnumAuthority hash is recomputed during graph validation against its
single TypeSchema authority.

Function execution and present-debug hashes deliberately retain the Task 1
payload-only domains:

```text
ExecutionHash = H("function-execution", CanonicalExecutionPayload)
PresentDebugHash = H("function-debug", CanonicalDebugPayload)
```

Codec version and profile are separate stored coordinates. They MUST NOT be
silently added to either payload-only stream. A profile or codec change can
make a record ineligible even when its raw payload hash is equal.

### Shared profile-specific debug absence

An absent debug sidecar uses the shared identity-layer operation:

```text
DebugAbsentHash = H("function-debug-absent",
  ArtifactProfileKey)
```

The stream writes exactly the complete 32-byte `ArtifactProfileKey` and no
other value. It uses `FAngelscriptArtifactCanonicalWriter`, not a raw BLAKE3
call. The shared public API and full-hash Editor/Shipping golden vectors are a
Task 2B-2 RED/GREEN obligation in the common artifact-identity layer. The
sibling StaticJIT change MUST consume this API/vector rather than implement a
second absence algorithm.

An unset `DebugSidecar` optional plus this profile-specific hash represents
absence. Zero hashes, zero RecordIds, an empty-debug sentinel, and
`H("function-debug", empty payload)` are all different values and are
forbidden substitutes.

### Typed logical section identity

`FAngelscriptCachedLogicalSectionKey` is a distinct wrapper around one nonzero
full hash. It is computed as:

```text
LogicalSectionKey = H("cache-debug-logical-section",
  SourceFileKey,
  exact CanonicalLogicalSection UTF-8 bytes)
```

`CanonicalLogicalSection` is a historical field name: its bytes are exact
validated strict UTF-8 bytes supplied by the compiler/debug codec. No path,
case, separator, Unicode, whitespace, or other normalization is performed.
Numeric script section indices are process-local and cannot appear in a
public DTO, hash stream, or wire payload.

## TypeSchema V1 payload

### Wire order

```text
PayloadSchemaVersion:u32 = TypeSchemaPayloadSchemaVersion
ModuleKey:StableModuleKey
TypeKey:StableTypeKey
TypeKind:u8
CanonicalNamespace:string
CanonicalName:string
CanonicalDeclaration:string
TypeSemanticFlags:u32
Metadata:array<MetadataEntry>
Relations:array<TypeRelation>
LayoutInputs:array<TypeLayoutInput>
Layout:TypeLayoutExpectation
OrderedProperties:array<PropertySchema>
OrderedMethods:array<MethodEntry>
VirtualFunctionTable:array<VirtualFunctionSlot>
OrderedBehaviorSlots:array<BehaviorSlot>
KindPayload:payload selected by TypeKind
Reflection:ReflectionSchema
Dependencies:array<SemanticDependency>
```

Subrecords are encoded in this order:

```text
TypeRelation:
  RelationKind:u8
  SemanticOrdinal:optional<u32>
  Target:StableReference

TypeLayoutInput:
  InputKind:u8
  Target:StableReference
  BoundaryContribution:optional<u32>
  AlignmentContribution:optional<u32>
  LayoutInputHash:hash256

TypeLayoutExpectation:
  SemanticSize:u64
  SemanticAlignment:u32
  BasePropertyBoundary:u32
  TypeLayoutHash:hash256

PropertySchema:
  LayoutOrdinal:u32
  SemanticByteOffset:u32
  PropertyKey:StablePropertyKey
  CanonicalName:string
  Type:CanonicalDataType
  StorageKind:u8
  SemanticStorageSize:u32
  SemanticStorageAlignment:u32
  StorageLayoutHash:hash256
  Access:u8
  PropertySemanticFlags:u32
  ReplicationCondition:u8
  Metadata:array<MetadataEntry>
  PropertyLayoutFingerprint:hash256

MethodEntry:
  EntryKind:u8
  MethodOrdinal:u32
  FunctionKey:StableFunctionKey
  DeclaringOwner:StableTypeKey
  ExpectedDeclarationAbi:hash256

VirtualFunctionSlot:
  SlotKind:u8
  VftOrdinal:u32
  FunctionKey:StableFunctionKey
  DeclaringOwner:StableTypeKey
  ImplementingOwner:StableTypeKey
  ExpectedDeclarationAbi:hash256

BehaviorSlot:
  BehaviorKind:u8
  SlotOrdinal:u32
  Target:StableReference
  DeclaringOwner:optional<StableTypeKey>

ReflectionSchema:
  ReflectionKind:u8
  ClassReflectionFlags:u32
  ConfigName:optional<string>
  StaticClassGlobalName:optional<string>
  OrderedUFunctionMembers:array<ReflectedFunctionMember>

ReflectedFunctionMember:
  ReflectionOrdinal:u32
  Target:StableReference
```

### Type-kind payload

The enclosing `TypeKind` is the union tag. No second tag is written.

```text
Class, Struct, Interface:
  no kind-payload bytes

Enum:
  OrderedEnumerators:array<EnumEnumerator>
  EnumAuthorityHash:hash256

EnumEnumerator:
  DeclarationOrdinal:u32
  CanonicalName:string
  Value:signed-int32 little-endian bits
  Metadata:array<MetadataEntry>

Delegate, Funcdef:
  SignatureFunctionKey:StableFunctionKey
  ExpectedSignatureAbi:hash256
  bMulticast:bool

Typedef:
  AliasedType:CanonicalDataType
```

`bMulticast` may be true only for `Delegate`; it MUST be false for `Funcdef`.
The signature key must resolve to the single `DelegateSignature` declaration
owned by this TypeKey and have exactly the stored declaration ABI. A Typedef's
aliased type is reconstructible and cannot be `Auto`.

Enum ordinals are exactly `0..N-1`. Enumerator names are nonempty and unique.
Numeric aliases are allowed, so two distinct names MAY share one signed
`int32` value. Values outside signed `int32` are not representable in V1.
Enumerator metadata participates in `EnumAuthorityHash`.

### Relation, slot, reflection, and authority rules

Relations are canonical relation-kind sections. `Base`, `ShadowSuper`,
`CodeSuper`, and `Compose` each have cardinality zero or one, forbid
`SemanticOrdinal`, and retain the common target-reference comparator. The
`ImplementedInterface` section contains only directly declared unique targets,
requires stored-position-equal `SemanticOrdinal=0..N-1`, and preserves that
semantic order instead of sorting by target key/ABI. The transitive interface
closure is derived base-first in direct-list order with first-visit diamond
deduplication; closure rows are never serialized as direct relations. No
separate super/interface/compose fields exist in reflection data.

Properties form one local-only semantic sequence with `LayoutOrdinal=0..N-1`,
stored position equal to ordinal, exact `SemanticByteOffset` authority, and a
pointer-free StorageKind/size/alignment witness whose StorageLayoutHash binds
the complete CanonicalDataType. `LayoutInputs` is a canonical singleton-per-kind
set that supplies only the numeric BaseType, UClass CodeRoot, and UStruct
StructHeader contributions actually consumed by the maintained layout path.
Boundary/alignment optional presence is semantic; zero is never an absence
sentinel. The exact matrix and replay algorithm are co-normative in
`type-layout-authority-v1.md`.
Inherited storage remains authoritative through the Base TypeSchema.
`OrderedMethods` is the exact public `asCObjectType::methods` sequence with its
own `MethodOrdinal=0..N-1`; `VirtualFunctionTable` is the distinct exact VFT /
`vfTableIdx` sequence with its own `VftOrdinal=0..N-1`. Neither sequence is
sorted by kind/key or derived by reordering the other. The precise local-prefix,
inherited-suffix, cloned-base/override/append reconstruction predicates are the
co-normative TypeSchema matrix section 8. Behavior slots remain grouped by
ascending `BehaviorKind`, with a contiguous ordinal domain inside each group.
There are no `OrderedConstructors` or `OrderedFactories` arrays: constructor and
factory VM order exists only in their behavior-slot groups.

`ModuleInterface` is the sole stable type-identity authority. A TypeSchema
does not rerun a second type-key construction algorithm. Graph validation
requires its `{ModuleKey, TypeKind, namespace, name, declaration}` coordinate
to equal the corresponding ModuleInterface declaration and rejects duplicate
or conflicting authorities.

Reflection presence is the closed allowlist in
`type-schema-matrix-v1.md` section 5. Typedef, Funcdef, and Interface require
`None`; Enum permits `None` or `UEnum`; Delegate requires `UDelegate`; Struct
permits `None` or `UStruct`; and Class permits `None` or `UClass`. No omitted
pair is accepted. `UClass` cannot assert `IsStruct`; `UStruct` requires it.

`ConfigName` and `StaticClassGlobalName` use this exact presence matrix:

| Type/reflection form | ConfigName | StaticClassGlobalName |
|---|---|---|
| `ReflectionKind::None`, `UEnum`, `UDelegate`, or `UStruct` | forbidden | forbidden |
| ordinary non-statics `UClass` | optional nonempty; absence means inherit the resolved superclass `ClassConfigName` | required nonempty |
| generated statics `UClass` with `StaticsClass` flag | forbidden | forbidden |

`StaticsClass` is therefore a bidirectional discriminator, not merely a hint:
it is set iff this is the synthetic module statics class, and then TypeKind is
Class, ReflectionKind is UClass, and `Generated|ReferenceType`,
`SuperIsCodeClass|StaticsClass` are set. An ordinary UClass must clear
`StaticsClass` and carry the global variable name used by
`SetScriptStaticClass`. No other type/reflection form may set `StaticsClass` or
carry either optional string. Empty present strings are malformed.

`OrderedUFunctionMembers` is permitted only for `ReflectionKind::UClass` and
has stored-position-equal `ReflectionOrdinal=0..N-1`. Every row is one nonzero
ScriptFunction StableReference with nonzero ExpectedAbi. Ordinary UClass rows
resolve to local Type-owned `Method` declarations; StaticsClass rows resolve to
local Module-owned `GlobalFunction` declarations. Presence and order in this
array are the sole UFunction-membership authority: `ReflectionFlags == 0` is
legal positive evidence when a row is present and is never an absence sentinel.
StaticsClass requires at least one member and keeps both VM method sequences
empty; all non-UClass forms require the reflected-member array empty.

Type metadata, super/interface/compose relations, and their order have one
authority in the common TypeSchema fields and are never duplicated inside
ReflectionSchema. Executable default construction belongs to a declared
`InitDefaults` FunctionBody; reflection contains no raw default blob or source
string.

Every local property key, method/function key, behavior key, required owner key or
behavior-owner optional shape, ExpectedAbi, flag mask, fingerprint,
TypeLayoutHash, and EnumAuthorityHash is validated before publication. Exact
behavior declaration owner/module/entity/ABI and declaration-signature meaning
are graph checks performed later.

## ModuleState V1 payload

### Wire order

```text
PayloadSchemaVersion:u32 = ModuleStatePayloadSchemaVersion
ModuleKey:StableModuleKey
Profile:ArtifactProfileKey
StateInputHash:hash256
OrderedGlobals:array<GlobalSchema>
HardValues:array<HardValue>
Initializers:array<InitializerUnit>
OrderedInitializationActions:array<InitializationAction>
OrderedPostInitFunctions:array<PostInitFunction>
Dependencies:array<SemanticDependency>
```

Subrecords are encoded as:

```text
GlobalSchema:
  StorageOrdinal:u32
  GlobalKey:StableGlobalKey
  CanonicalNamespace:string
  CanonicalName:string
  Type:CanonicalDataType
  GlobalTraitFlags:u32
  InitializationKind:u8
  CleanupPolicy:u8
  StorageLayoutFingerprint:hash256

HardValue:
  HardValueKind:u8
  Owner:StableReference
  Type:CanonicalDataType
  CanonicalValue:optional<CanonicalValue>
  HardValueHash:hash256

CanonicalValue:
  ValueKind:u8
  FixedWidthValueBytes:bytes selected by declared type and ValueKind

InitializerUnit:
  InitializerKind:u8
  InitializerKey:StableFunctionKey
  OwnerGlobal:optional<StableGlobalKey>
  VmInitializerCodecVersion:u32
  InitializerExecutionHash:hash256
  CanonicalExecutionPayload:bytes

InitializationAction:
  ActionOrdinal:u32
  ActionKind:u8
  Target:StableReference
  Dependencies:array<SemanticDependency>

PostInitFunction:
  PostInitOrdinal:u32
  Function:StableReference
```

`GlobalTraitFlags` are the ModuleInterface global declaration trait flags from
the common V1 mask; no new unbounded native mask is introduced.

### Canonical scalar values

The declared canonical data type fixes the value width:

- `Bool`: one byte, exactly `0` or `1`;
- `SignedInteger`: the declared 8/16/32/64-bit two's-complement little-endian
  representation;
- `UnsignedInteger`: the declared 8/16/32/64-bit little-endian representation;
- `Float32`: exactly four IEEE-754 binary32 bytes;
- `Float64`: exactly eight IEEE-754 binary64 bytes; and
- `EnumInt32`: exactly four signed-int32 little-endian bytes and a declared
  enum ScriptType.

The producer persists the compiler-evaluated bit pattern. Floating-point NaN
payloads and signed zero are preserved exactly; no numeric or NaN
canonicalization is performed. Strings, objects, handles, UObject references,
mutable globals, host pointers, and variable-width host values are not
PureConstant and cannot appear as a CanonicalValue.

A `GlobalConstant` HardValue requires a present CanonicalValue, a ScriptGlobal
owner, and a locally recomputable HardValueHash. An `EnumAuthority` HardValue
requires an absent CanonicalValue, a ScriptType owner for a local enum, and is
recomputed from the linked TypeSchema during graph validation.

### Initialization and cleanup coverage

Globals are one semantic storage sequence with `StorageOrdinal=0..N-1`.
Initializer units are a canonical set ordered by complete InitializerKey and
carry bytes but no execution ordinal. InitializationActions are the one
dependency-solved semantic execution sequence with `ActionOrdinal=0..N-1`;
they interleave type-driven `DefaultConstructGlobal` with
`ExecuteInitializer`. Post-init functions are another semantic sequence with
`PostInitOrdinal=0..N-1`. HardValues and dependencies are canonical sets.

For each InitializerUnit, local deserialize recomputes
`H("cache-initializer-execution-v1", ModuleKey, Profile, InitializerKey,
VmInitializerCodecVersion, CanonicalExecutionPayload)` and requires equality with
InitializerExecutionHash. It does not invoke the initializer codec. Graph step
1 invokes the codec exactly once for each reachable initializer in ascending
`ExecuteInitializer` ActionOrdinal, stops at the first failing call, and retains
the validated hash/relocation/owned-byte summary in the candidate graph. After
the first codec failure, every later action receives zero calls; caller token/
map insertion order cannot change the first error or the call prefix.

Coverage is exact:

- a `Default` global has no GlobalConstant HardValue and no Global initializer;
  it has exactly one DefaultConstructGlobal action iff its cleanup is
  DestroyValue, otherwise zero;
- a `PureConstant` global has exactly one GlobalConstant HardValue and no
  Global initializer/action;
- a `VmInitializer` global has no GlobalConstant HardValue and exactly one
  `InitializerKind::Global` unit whose `OwnerGlobal` is that GlobalKey plus one
  matching ExecuteInitializer action;
- a module has zero or one `InitializerKind::Module` unit and one matching
  ExecuteInitializer action iff present;
- a Global initializer requires `OwnerGlobal`; a Module initializer forbids it;
- every InitializerKey resolves to the matching same-module initializer
  declaration in ModuleInterface, and initializer keys never appear in
  ModuleSnapshot FunctionBody links; and
- every initializer declaration is a compiler-generated, zero-parameter
  `void()` function with exactly the common `Generated` trait, zero reflection
  and identity flags, no metadata/slots, and `BodyCoverage::Forbidden`; and
- every post-init target is a module-owned, non-abstract, zero-parameter
  GlobalFunction with `BodyCoverage::Required` whose ExpectedAbi equals the
  ModuleInterface declaration ABI. Its return value, if non-void, is discarded.

ModuleState contains exactly one `EnumAuthority` HardValue for every local
Enum TypeSchema, whether or not another function currently uses the value.
Missing, extra, duplicate, or mismatched enum authority rejects the complete
ModuleSnapshot.

The loader lifecycle is policy, not an opaque field: allocate/zero all global
storage and install pure-constant bits; execute
`OrderedInitializationActions` exactly; execute `OrderedPostInitFunctions`;
then publish the module active. Before a global-owning action attempt, push its
non-None global once on a transient cleanup stack. Failure and normal release
pop the stack in exact reverse action-attempt order using each GlobalSchema
CleanupPolicy. StorageOrdinal never substitutes for ActionOrdinal. No cleanup
stack or initialization bit is restored from disk.

`ModuleState.Profile` selects the initializer codec family and must equal the
selected graph profile. Profile mismatch between immutable records is
`ProfileGraphMismatch`; mismatch against the current selected profile after a
self-consistent graph is `ProfileMismatch`/Ineligible.

## FunctionBody V1 payload

### Wire order

```text
PayloadSchemaVersion:u32 = FunctionBodyPayloadSchemaVersion
ModuleKey:StableModuleKey
Identity:
  FunctionKey:StableFunctionKey
  Content:
    Execution:hash256
    Debug:hash256
  Profile:ArtifactProfileKey
ExpectedDeclarationAbi:hash256
FunctionSourceDigest:hash256
FunctionInputDigest:hash256
InvocationKind:u8
VmExecutionCodecVersion:u32
CanonicalExecutionPayload:bytes
ActualDependencies:array<SemanticDependency>
DebugSidecar:optional<RecordId>
```

`Identity.FunctionKey` is the sole function-key authority. No duplicated
FunctionKey is added for a decode shortcut. `ActualDependencies` is the
complete canonical semantic dependency set captured by compilation; it is not
only the relocation list.

Local validation requires nonzero module/function/profile/source/input/
execution/debug/declaration-ABI coordinates, a supported invocation value, and
a `DebugSidecar` optional whose present RecordId declares kind DebugSidecar.
Local deserialize recomputes `H("function-execution", payload)` and requires it
to equal `Identity.Content.Execution`; it does not invoke the execution codec.
Graph step 1 later invokes the codec exactly once for each reachable body,
requires its validated hash to equal the same coordinate, and retains the
relocation/owned-byte summary in the validated graph.

Invocation kind must agree with the ModuleInterface entity and compile-capture
kind. The graph uses this exact matrix; `Generated` means the existing common
declaration TraitFlags bit, not a new EntityKind:

| InvocationKind | ModuleInterface EntityKind / owner | Generated trait |
|---|---|---|
| GlobalFunction | GlobalFunction / Module | forbidden |
| Method | Method / local Class, Struct, or Interface Type | forbidden |
| Constructor | Constructor / Type | forbidden |
| Destructor | Destructor / Type | forbidden |
| Factory | Factory / Type | forbidden |
| GeneratedDefaultConstructor | GeneratedDefaultConstructor / Type | required |
| GeneratedDefaultDestructor | Destructor / Type | required |
| InitDefaults | InitDefaults / Type | required |
| PublicSingleFunction | GlobalFunction / Module plus canonical identity trait `public-single-function` | required |
| Lambda | GlobalFunction/Module or Method/Type according to the stable lexical declaration, plus canonical identity trait `lambda` | required |

In particular, V1 does not add or renumber a
`GeneratedDefaultDestructor` Task 1 EntityKind. It deliberately reuses
`EntityKind::Destructor=35` and distinguishes the generated default path by the
required Generated trait plus InvocationKind. A lambda or public single
function without the stable declaration/owner/identity trait required by this
matrix is NotCacheable rather than an undeclared body. Invocation validation is
a graph invariant because the declaration is not duplicated in FunctionBody.

## DebugSidecar V1 payload

### Wire order

```text
PayloadSchemaVersion:u32 = DebugSidecarPayloadSchemaVersion
FunctionKey:StableFunctionKey
Profile:ArtifactProfileKey
DebugHash:hash256
VmDebugCodecVersion:u32
Sources:array<DebugSourceReference>
CanonicalDebugPayload:bytes

DebugSourceReference:
  SourceFileKey:CachedSourceFileKey
  LogicalSectionKey:CachedLogicalSectionKey
  CanonicalLogicalSection:string
```

Sources are a canonical set ordered by SourceFileKey, LogicalSectionKey, then
exact logical-section UTF-8 bytes. Duplicate keys reject; the same key with
different bytes conflicts. Every logical-section key is recomputed locally.

Local deserialize recomputes `H("function-debug", payload)` and requires it to
equal stored DebugHash; it does not invoke the debug codec. Graph step 1 invokes
the debug codec exactly once for each reachable body-owned sidecar. Debug opaque
codec V1 returns zero relocations; its validated summary returns the exact
source set observed, and common graph validation requires exact equality with
the explicit Sources array. A sidecar cannot exist without a body-owned
optional link in the validated module graph.

## ModuleSnapshot V1 payload

### Wire order

```text
PayloadSchemaVersion:u32 = ModuleSnapshotPayloadSchemaVersion
ModuleKey:StableModuleKey
ModuleInterface:
  ModuleKey:StableModuleKey
  RecordId:RecordId(kind=ModuleInterface)
TypeSchemas:array<TypeSchemaLink>
ModuleState:
  ModuleKey:StableModuleKey
  RecordId:RecordId(kind=ModuleState)
FunctionBodies:array<FunctionBodyLink>

TypeSchemaLink:
  TypeKey:StableTypeKey
  RecordId:RecordId(kind=TypeSchema)

FunctionBodyLink:
  FunctionKey:StableFunctionKey
  RecordId:RecordId(kind=FunctionBody)
```

The interface and state links redundantly carry ModuleKey so the decoder and
graph validator can reject a wrong owner rather than infer it. Both are
required and nonzero, including the ModuleState link for a module with no
globals. Type and function links are canonical sets ordered by their complete
entity key, then RecordId. Duplicate/conflicting entity links reject.

ModuleSnapshot has no profile field, direct DebugSidecar link, initializer
link, source link, manifest link, or reachability index. Profile consistency
comes from ModuleState, every FunctionBody identity, every present sidecar, and
the selected graph context. FunctionBody remains the only DebugSidecar owner.

## VM-opaque payload validation seam

Only the three payload byte arrays may remain opaque to common cache code. The
common validator never parses VM instructions, initializer instructions,
program positions, or debug locals. Task 2B-2 freezes this injectable Runtime
interface:

```cpp
struct FAngelscriptCacheOpaquePayloadValidationRequest
{
	EAngelscriptCacheOpaquePayloadKind Kind;
	uint32 CodecVersion;
	FAngelscriptStableModuleKey ModuleKey;
	FAngelscriptHash256 OwnerKey;
	FAngelscriptArtifactProfileKey Profile;
	TConstArrayView<uint8> CanonicalPayload;
};

struct FAngelscriptCacheRelocationUse
{
	uint32 InstructionOrdinal;
	uint16 OperandSlot;
	EAngelscriptCacheSemanticDependencyKind DependencyKind;
	EAngelscriptCacheReferenceKind ReferenceKind;
	FAngelscriptHash256 StableKey;
	FAngelscriptHash256 ExpectedAbi;
	TOptional<FAngelscriptHash256> ExpectedContentOrValue;
};

struct FAngelscriptCacheOwnedOpaqueBytes
{
	EAngelscriptCacheReferenceKind ReferenceKind;
	FAngelscriptHash256 StableKey;
	TArray<uint8> CanonicalUtf8Bytes;
};

struct FAngelscriptCacheOpaquePayloadSummary
{
	FAngelscriptHash256 ValidatedPayloadHash;
	TArray<FAngelscriptCacheRelocationUse> OrderedRelocations;
	TArray<FAngelscriptCachedDebugSourceReference> ExactDebugSources;
	TArray<FAngelscriptCacheOwnedOpaqueBytes> OwnedCanonicalBytes;
};

class IAngelscriptCacheOpaquePayloadValidator
{
public:
	virtual FAngelscriptCacheValidationResult Validate(
		const FAngelscriptCacheOpaquePayloadValidationRequest& Request,
		const FAngelscriptCacheReadLimits& Limits,
		FAngelscriptCacheReadBudget& Budget,
		IAngelscriptCacheCandidateChargeSink& GraphCandidate,
		FAngelscriptCacheOpaquePayloadSummary& OutSummary) const = 0;
};
```

`Budget` remains the authority for codec-local temporary parsing scratch.
`GraphCandidate` is a narrow charge sink backed by the one private module-graph
output transaction: before allocating
any array or nested byte capacity that will be returned in `OutSummary`, the
codec computes the actual allocator capacity and successfully extends this
sink. It cannot begin, promote, close, or inspect the private transaction and
does not independently promote those output bytes. The graph
adds its own summary/table capacities to the same transaction and promotes the
whole candidate exactly once at step 11. A codec error, later immutable-graph
error, current-eligibility miss, or budget failure destroys the candidate,
releases all temporary resident charge, and publishes no retained summary.
This extra parameter is an intentional development-phase correction; there is
no compatibility overload.

The test fixture codec is a tiny deterministic codec with the exact eight ASCII
magic bytes `UEASOPQ1` and explicit fixture format version `1`. Its byte order
is:

```text
magic:u8[8] = ASCII "UEASOPQ1"
fixture-format-version:u8 = 1
opaque-kind-echo:u8
reserved:u16 = 0
semantic-byte-count:u32; semantic-bytes:u8[count]
relocation-count:u32; relocation rows
debug-source-count:u32; debug-source rows
owned-byte-count:u32; owned-byte rows
```

The row layouts are the public summary value layouts below; the fixture is only
test evidence for common plumbing, malformed/budget paths, relocation matching,
debug source equality, and owned-byte validation. It is not AngelScript
bytecode. The real VM codec and live attachment arrive in the later compiler/
restore task group through this same interface.

A summary is reset on entry and published only after the codec fully validates
the payload. `ValidatedPayloadHash` uses `function-execution`,
`cache-initializer-execution-v1`, or `function-debug` as applicable. Relocations
are a semantic sequence ordered by instruction ordinal and operand slot; gaps
are not required across instructions, but duplicate coordinates conflict.
FunctionExecution and InitializerExecution may return relocations. Debug V1
MUST return an empty relocation array; nonempty debug relocations are
`OpaquePayloadMalformed`. Because owned bytes exist only for name/string
relocations, Debug V1 also returns no owned-byte rows.

Every relocation must match one owning record dependency on the complete
coordinate:

```text
DependencyKind
Target.ReferenceKind
Target.StableKey
Target.ExpectedAbi
ExpectedContentOrValue presence
ExpectedContentOrValue hash when present
```

The relocation set is a subset, not an equality: compile-option, overload,
layout, and other semantic dependencies may have no final operand.

`CanonicalName` and `StringLiteral` relocations have zero ExpectedAbi and
bypass the current-symbol resolver. For every such relocation the codec summary
owns exactly one strict-UTF-8 byte entry. Its full key is recomputed as:

```text
CanonicalName key = H("cache-canonical-name-v1", exact UTF-8 bytes)
StringLiteral key = H("cache-string-literal-v1", exact UTF-8 bytes)
```

Missing bytes, duplicate/conflicting bytes, nonzero ABI, wrong reference kind,
or a domain hash unequal to StableKey rejects before graph publication.
`OwnedCanonicalBytes` has the canonical unique key and comparator
`{numeric ReferenceKind, complete StableKey bytes}`. Equal keys with equal
CanonicalUtf8Bytes are duplicates; equal keys with different bytes conflict.
CanonicalUtf8Bytes are compared byte-for-byte for equality but are not a third
sorting key. The public writer sorts by that comparator and the codec/graph
reader rejects noncanonical input rather than silently reordering it.

For an InitializerExecution summary, owned rows are an exact set: there is one
and only one row for every distinct CanonicalName/StringLiteral relocation in
that initializer, and no row for a key without such a relocation. Missing,
extra, duplicate, or conflicting rows are `OpaquePayloadMalformed`; equality of
the dependency subset is not permission to retain unused owned bytes.

## Current symbol resolver contract

Current-environment comparison is deliberately separate from immutable graph
self-consistency:

```cpp
struct FAngelscriptCacheCurrentSymbol
{
	FAngelscriptHash256 CurrentAbi;
	TOptional<FAngelscriptHash256> CurrentContentOrValue;
	TOptional<EAngelscriptCacheValueStorageKind> CurrentValueStorageKind;
};

class IAngelscriptCacheCurrentSymbolResolver
{
public:
	virtual TOptional<FAngelscriptCacheCurrentSymbol> Resolve(
		EAngelscriptCacheReferenceKind ReferenceKind,
		const FAngelscriptHash256& StableKey) const = 0;
};
```

Exact numeric layout comparison is intentionally a separate service and is
never called during local or immutable stored-graph validation:

```cpp
struct FAngelscriptCacheResolvedDataTypeLayout
{
	EAngelscriptCachedPropertyStorageKind StorageKind;
	uint32 SemanticStorageSize;
	uint32 SemanticStorageAlignment;
};

struct FAngelscriptCacheResolvedTypeLayoutInput
{
	TOptional<uint32> BoundaryContribution;
	TOptional<uint32> AlignmentContribution;
};

struct FAngelscriptCacheProspectiveTypeLayout
{
	EAngelscriptCachedTypeKind TypeKind;
	uint64 SemanticSize;
	uint32 SemanticAlignment;
};

class IAngelscriptCacheProspectiveTypeLayoutView
{
public:
	virtual TOptional<FAngelscriptCacheProspectiveTypeLayout>
	FindLocalScriptTypeLayout(
		const FAngelscriptStableTypeKey& TypeKey) const = 0;
};

class IAngelscriptCacheCurrentLayoutResolver
{
public:
	virtual TOptional<FAngelscriptCacheResolvedDataTypeLayout>
	ResolveDataTypeLayout(
		const FAngelscriptCachedDataType& DataType,
		const IAngelscriptCacheProspectiveTypeLayoutView& LocalLayouts) const = 0;

	virtual TOptional<FAngelscriptCacheResolvedTypeLayoutInput>
	ResolveTypeLayoutInput(
		EAngelscriptCachedTypeLayoutInputKind InputKind,
		EAngelscriptCacheReferenceKind ReferenceKind,
		const FAngelscriptHash256& StableKey) const = 0;
};
```

Lookup identity excludes stored ExpectedAbi, stored numeric layout values,
stored hashes, stored optional-presence bits, and display strings. The current-
layout resolver locates only an eligible cross-module ScriptType, fully
instantiated EnvironmentType, or external layout role by stable identity and
returns numeric coordinates only. Primitive, selected-module graph-closed, and
fixed ObjectHandle routes never call it. For TypeLayoutInput its optionals are
raw role capabilities: BaseType and CodeRoot return boundary plus alignment,
while StructHeader returns boundary only. The validator first proves the stored
form/presence matrix, applies that stored consumer mask to the raw current
result, then recomputes the current StorageLayoutHash/LayoutInputHash. An
unconsumed raw CodeRoot boundary is not a presence mismatch for a script-derived
UClass.

The prospective view is a zero-allocation non-owning façade over the validated
selected-module TypeKey index. It exposes only immutable local TypeKind, size,
and alignment. The production current-layout resolver is per-engine, can run
before the selected module is materialized, and consumes sealed environment
layout recipes plus already selected imported-module layouts. An environment
template containing a local ScriptType obtains that subtype layout through the
prospective view, never through a live selected-module type lookup. No resolver
uses the process-global type-database fallback. The pure fixture is an injected
deterministic map/recipe set and creates no AS engine or UObject.
`type-layout-authority-v1.md` is the exact API/eligibility/ordering authority.

`IAngelscriptCacheCurrentSymbolResolver` accepts eligible ScriptModule,
ScriptType, ScriptFunction, ScriptGlobal, ScriptProperty, ScriptImport, and
EnvironmentSymbol coordinates. Selected-module Script* coordinates already
represented by immutable declaration/content authorities are graph-closed and
are not passed; an import's external target remains a separate eligible
dependency. External Script* and EnvironmentSymbol coordinates are passed.
The resolver returns the current declaration/layout/storage/route/environment
ABI and optional current content or hard value. CanonicalName and StringLiteral
are never passed to it.

`CurrentValueStorageKind` is an independent typed coordinate, not a derivation
from `CurrentAbi`. It is required and non-Invalid when an EnvironmentSymbol is
being resolved as the top-level storage authority for an EnvironmentType
global, and forbidden for every other resolver request. Its exact cleanup map
is `Trivial -> None`, `OwningValue -> DestroyValue`, and
`ReferenceCounted -> ReleaseHandle`; an object handle additionally requires
`ReferenceCounted`. Missing, unexpected, or cleanup-incompatible storage kind
is `CurrentAbiMismatch`/Ineligible after immutable graph closure.

After the immutable graph is self-consistent:

- no resolver result is `CurrentSymbolMissing`/Ineligible;
- unequal CurrentAbi is `CurrentAbiMismatch`/Ineligible; and
- when a dependency carries ExpectedContentOrValue, absent or unequal current
  content is `CurrentContentMismatch`/Ineligible.

After that canonical eligible current-symbol dependency walk succeeds, current
layout comparison visits TypeSchemas in ModuleSnapshot link order, eligible
LayoutInputs in numeric kind order, then eligible properties in LayoutOrdinal
order. The exact selection is:

- selected-module BaseType and InlineValue ScriptType use the graph-validated
  TypeSchema index and produce zero current-layout calls;
- Primitive InlineValue and every ObjectHandle slot use versioned selected
  Compatibility/Profile constants and produce zero current-layout calls; a
  ScriptType handle retains Declaration authority and an EnvironmentType handle
  retains EnvironmentAbi authority through the current-symbol/graph walk;
- cross-module BaseType, CodeRoot, StructHeader, external InlineValue
  ScriptType, and InlineValue EnvironmentType are eligible calls; and
- Auto/Void/Reference/unresolved storage has already failed local validation.

The versioned build-layout table and its required future CompatibilityKey inputs
are literal section 7.1 of `type-layout-authority-v1.md`: bool size, pointer byte
width, int64/double alignment, handle alignment, object initial alignment, and
type-info initial alignment. It is an engine-free Runtime-build value, not a
resolver result. After selected Profile equality, constant-route inequality is
`CurrentAbiMismatch/Ineligible` before any eligible numeric-layout call.

Exact duplicate eligible CanonicalDataType/storage coordinates and exact
eligible `{InputKind,ReferenceKind,StableKey}` raw layout-input coordinates are
memoized and resolved once at first occurrence. The prospective local view
aliases the already validated TypeKey index and allocates nothing. An eligible
environment recipe may read that view for nested local value subtypes without
turning those subtypes into resolver calls. Each layout-input consumer applies
its already-validated stored presence mask to the shared raw result. A missing
eligible resolver result is `CurrentSymbolMissing`/Ineligible; an invalid raw
role shape, missing stored-required raw coordinate, or unequal storage kind,
size, alignment, or validator-recomputed masked layout hash is
`CurrentAbiMismatch`/Ineligible. No current-layout call may win over a local,
hash, ownership, coverage, or linked stored-layout contradiction.

Step 10 first compares selected source snapshot, then selected profile, then
walks eligible dependencies in their canonical owning-record/dependency order.
Eligibility is decided before lookup from validated ownership: selected-module
Script* authorities are skipped, external Script* and EnvironmentSymbol rows
are called, and CanonicalName/StringLiteral are never called. A selected-module
required target missing from the immutable graph fails graph coverage and cannot
fall through into this walk.
For each dependency the observable resolver order is exactly: call once;
missing result; ABI equality; required content/value presence and equality.
The first failure wins. CanonicalName and StringLiteral are validated against
codec-owned bytes before step 10 and are never passed to the resolver.

These are normal cache misses. They do not relabel a contradictory stored graph
as stale-but-valid.

## Per-module graph API and boundary

Task 2B-2 exposes a per-module validator, not a manifest validator:

```cpp
struct FAngelscriptCacheModuleGraphValidationContext
{
	FAngelscriptArtifactProfileKey SelectedProfile;
	FAngelscriptHash256 SelectedSourceSnapshot;
	const FAngelscriptDecodedCacheRecord* SourceIndex;
	const IAngelscriptCacheCurrentSymbolResolver* CurrentSymbols;
	const IAngelscriptCacheCurrentLayoutResolver* CurrentLayouts;
	const IAngelscriptCacheOpaquePayloadValidator* OpaquePayloads;
};

FAngelscriptCacheValidationResult ValidateModuleSnapshotGraph(
	const FAngelscriptCacheRecordId& ModuleSnapshotRecordId,
	TConstArrayView<FAngelscriptDecodedCacheRecordHandle> LocallyValidatedRecords,
	const FAngelscriptCacheModuleGraphValidationContext& Context,
	const FAngelscriptCacheReadLimits& Limits,
	FAngelscriptCacheReadBudget& Budget,
	FAngelscriptValidatedModuleGraph& OutGraph);
```

`SourceIndex`, `CurrentSymbols`, `CurrentLayouts`, and `OpaquePayloads` are all required non-null;
`SourceIndex` must be an immutable validated SourceIndex token; SelectedProfile
and SelectedSourceSnapshot must be nonzero. A null pointer, wrong SourceIndex
kind, zero selection, or zero requested ModuleSnapshot RecordId fails before
codec/resolver work with `ContextMismatch`, `RecordKind=ModuleSnapshot`,
`Stage=ModuleGraph`, and `ByteOffset=0`, leaving OutGraph empty. A negative/
unset record view is `InvalidArrayView` at the same stage/offset. Duplicate
same-RecordId tokens are `DuplicateKey`; the same ID with different canonical
bytes is `ConflictingKey`. No nullable default service or zero-value selection
is inferred.

The API follows only the requested ModuleSnapshot's interface/state/type/body/
sidecar links. It neither accepts nor validates a generation manifest and does
not reject unrelated records in the caller's pool. Exact manifest reachability,
unreachable extras, record-index locations, packs, and generation roots belong
exclusively to Task 2B-3.

## Normative 11-step graph validation

Validation order is observable and deterministic. The first failure wins.

1. **Validated-token index, reachability, and opaque validation.** Accept only
   immutable tokens created by the factory above; each has already completed
   wire/local/hash validation, but no codec validation. Build full-hash record
   lookup indexes while charging the shared budget, resolve the requested root,
   and structurally walk only its interface/state/type/body links plus each
   body-owned optional sidecar. Then invoke the injected validator exactly once
   for every opaque payload actually reachable through that walk: each
   ModuleState InitializerUnit in ascending ExecuteInitializer ActionOrdinal,
   then each linked FunctionBody, and then each present body-owned DebugSidecar
   in the frozen record/link order. Calls are fail-fast within that order: after
   the first error no later opaque payload is invoked. Unrelated input records
   receive zero codec calls.
   Store every validated summary in the candidate graph keyed by opaque kind
   and complete owner key; steps 5, 7, and 8 consume those stored summaries and
   MUST NOT reinvoke the codec. A requested missing record is `MissingRecord`;
   a present ID of another role is `WrongRecordKind`.
2. **Snapshot root and owner.** Resolve the requested ModuleSnapshot, validate
   redundant ModuleKey links, keyed-link ordering, and same-module interface/
   state ownership.
3. **ModuleInterface declaration graph.** Resolve the required interface and
   build unique indexes for local type, function, global, property, import,
   initializer, and slot declarations. Any duplicate namespace/name/
   declaration authority must be graph-equal; a second differing authority is
   a graph failure, never a second stable-key algorithm.
4. **TypeSchema exact coverage.** Compare the ModuleInterface
   `SchemaCoverage::Required` TypeKey set with the snapshot TypeSchema link set
   for exact equality. Validate kind/name/namespace/declaration equality,
   ownership, direct-interface semantic order and derived closure, properties,
   the distinct public-method and VFT sequences, behavior function
   declarations and their actual owners/entities/ABI, Class Construct/Factory
   parameter/default/return agreement, unique zero-parameter default-constructor
   parity, compatible script Copy/opAssign, signature ABI, explicit
   reflected-UFunction membership/order
   including zero-mask and StaticsClass globals, exact layout/tail alignment
   replayed from persisted Property storage evidence and LayoutInputs, linked
   same-module Base/inline-value layout equality, and reflection compatibility.
   Legal external targets remain single persisted witnesses here. Required missing entries are
   `MissingCoverage`; forbidden or undeclared entries are `UnexpectedRecord`
   or `UndeclaredEntity`. These are TypeSchema record/declaration coverage errors,
   not a second derivation of the already locally exact per-TypeSchema Dependency
   row set.
5. **ModuleState and global coverage.** Require one state even when empty.
   Compare ordered globals with the complete local global declaration set and
   validate GlobalKey, namespace/name/type/traits/storage ABI, initialization
   tag, locally allowed cleanup candidates and the unique cleanup selected by
   primitive/ScriptType authority, HardValue, initializer-unit, ordered
   initialization-action, dependency, and post-init coverage. EnvironmentType
   storage category is deliberately not resolved here. Enforce the exact declaration /
   unit / ExecuteInitializer-action set equality, exact DefaultConstructGlobal
   action coverage, zero or one module initializer, owner and callable-shape
   rules, declaration ABI, action-to-action ordering edges, initializer
   relocation subset plus exact owned-byte set, and no independent initializer
   FunctionBody. Post-init functions require BodyCoverage::Required.
6. **Enum authority.** Require exactly one EnumAuthority HardValue for every
   local Enum TypeSchema and no extras. Recompute from the TypeSchema's ordered
   signed-int32 enumerators and metadata. Missing, duplicate, extra, or unequal
   authority is `EnumAuthorityMismatch`.
7. **FunctionBody exact coverage.** Compare the ModuleInterface
   `BodyCoverage::Required` FunctionKey set with snapshot FunctionBody links
   for exact equality. Validate owner, identity key, ExpectedDeclarationAbi,
   InvocationKind, source/input coordinates, profile, payload hash, and the
   complete relocation-to-ActualDependency subset. Forbidden/initializer/
   abstract/delegate-signature or undeclared bodies reject.
8. **Debug ownership and source equality.** For an absent optional require the
   shared profile-specific debug-absent hash. For a present optional require a
   DebugSidecar record with the same FunctionKey, profile, and debug hash;
   require explicit Sources to equal the codec summary and resolve every
   SourceFileKey/logical-section key against SourceIndex. One sidecar RecordId
   may have only one FunctionBody owner in the validated graph.
9. **Immutable dependency self-consistency.** Validate dependency targets that
   are represented inside the module graph, every stored ExpectedAbi/content
   coordinate, cross-owner rules, and source/profile equality among immutable
   records, plus the Base/value-layout DAG and every linked duplicate numeric
   layout authority. Internal declaration ABI, profile, source, or layout
   contradictions are `GraphOrOwnership`, not normal misses. A legal external
   target is not pulled from unrelated caller records merely to manufacture a
   second authority.
10. **Current source/profile/symbol eligibility.** Only after steps 1-9 succeed,
    compare the self-consistent graph with selected SourceSnapshot/Profile,
    skip graph-closed selected-module Script* coordinates, invoke the current-
    symbol resolver only for the frozen eligible set, then invoke the separate
    current-layout resolver only for the frozen eligible set above. The latter
    receives the allocation-free prospective local TypeSchema view for nested
    environment recipes and never requires selected-module live types. Source/
    profile/current ABI/current content/layout/symbol absence become the
    distinct Ineligible results defined below. This is the first stage allowed
    to consume an EnvironmentType
    `CurrentValueStorageKind`; missing/Invalid or cleanup-incompatible storage
    kind is `CurrentAbiMismatch`/Ineligible. No EnvironmentType current-storage
    lookup or failure may be relabeled `GlobalCoverageMismatch` in step 5.
11. **Atomic publish.** Move the fully indexed immutable graph into OutGraph
    only after all prior work succeeds. Any error leaves OutGraph empty. No
    type, global, function, debug view, initializer state, or engine mutation is
    exposed independently.

`FAngelscriptValidatedModuleGraph` retains shared handles for exactly the
reachable remaining-record tokens, never unrelated input handles. Its
`ReachableRecords` order is ModuleSnapshot root, ModuleInterface, ModuleState,
TypeSchema links in snapshot order, FunctionBody links in snapshot order, then
present DebugSidecars in owning-body order. It publishes the following compact
owning arrays and no hidden retained hash map:

- sorted `{RecordId, RecordOrdinal}` entries over every retained record;
- sorted `{TypeKey, TypeSchemaRecordOrdinal}` type views;
- sorted `{GlobalKey, ModuleStateGlobalOrdinal}` global views;
- sorted `{FunctionKey, DeclarationOrdinal, optional BodyRecordOrdinal,
  optional DebugRecordOrdinal, optional body/debug SummaryOrdinal}` function
  views;
- sorted `{InitializerKey, UnitOrdinal, ExecuteActionOrdinal, SummaryOrdinal}`
  initializer views; and
- opaque summaries in step-1 invocation order plus a sorted
  `{OpaqueOwnerCoordinate, SummaryOrdinal}` index.

All ordinals index graph-owned arrays or immutable retained records. There are
no pointers/views into the caller's handle array, validator scratch, local
decode DTOs, or temporary validation indexes. The graph's public lookups use
binary search over these sorted tables. Validation-only maps/sets from steps
1-10 remain temporary and are destroyed after publication; “fully indexed”
means exactly the retained tables above, not those temporary maps.

The graph copies shared handles only for reachable records. Because handle copy
does not allocate, token/control/DTO resident bytes remain the factory's one
existing persistent charge; graph construction charges only the capacity of
`ReachableRecords`, the published tables, and graph-owned summaries. Dropping
the caller's input-handle array after success cannot invalidate OutGraph, while
an unrelated input token's reference count and lifetime are unchanged.

Graph construction must not add an O(n^2) path. Record IDs, declarations,
entity owners, source keys, debug owners, dependencies, relocations and owned
bytes use full-key maps/sets or one canonical sort plus adjacent comparison.
After existing canonical-array sorting, lookups and the reachability walk are
expected O(1) per edge and O(N+E+R) overall; no child loop may linearly rescan
the whole record/declaration/dependency pool. RED evidence uses lookup/call
counters on large adversarial value fixtures, not wall-clock timing.

Cross-module semantic dependencies are valid and need not have a child record
inside this ModuleSnapshot. They resolve through current symbol catalogs or
other validated module graphs at their owning integration layer. A TypeSchema
therefore persists the exact numeric layout witness it consumes: when another
linked stored authority is present it must graph-match, and when it is absent
the witness is current-compared only after stored graph success.
`CrossModuleOwner` applies when a record or
entity claims the wrong owner, not merely because a legal dependency target is
external.

## Validation errors and exact classification

Errors `0..43` and all previous classifications remain byte-for-byte and
number-for-number as frozen in `record-wire-v1.md`. Append only:

```text
UnsupportedCodecVersion=44
OpaquePayloadMalformed=45
OpaquePayloadHashMismatch=46
RelocationDependencyMismatch=47
WrongRecordKind=48
MissingRecord=49
MissingCoverage=50
UnexpectedRecord=51
UndeclaredEntity=52
DuplicateDebugOwner=53
DebugLinkMismatch=54
EnumAuthorityMismatch=55
InitializerOwnershipMismatch=56
GlobalCoverageMismatch=57
ProfileGraphMismatch=58
SourceGraphMismatch=59
GraphAbiMismatch=60
InvocationKindMismatch=61
DebugSourceMismatch=62
CurrentContentMismatch=63
CurrentSymbolMissing=64
```

The exhaustive classification table becomes:

| Class | Errors |
|---|---|
| Success | None |
| Malformed | BadMagic, UnsupportedSchema, UnsupportedPayloadSchema, UnknownRecordKind, UnknownEnumValue, UnknownFlags, InvalidBoolean, InvalidOptionalTag, NonZeroReserved, InvalidUtf8, EmbeddedNul, InvalidLogicalPath, TrailingData, InvalidArrayView, AliasedInputOutput |
| ArithmeticOrBudget | Overflow, BudgetExceeded, OutOfBounds, ImpossibleCount, NestingDepthExceeded |
| CodecOrIntegrity | ChecksumMismatch, RecordIdMismatch, UnsupportedCodecVersion, OpaquePayloadMalformed, OpaquePayloadHashMismatch |
| CanonicalSemantic | NonCanonicalOrder, DuplicateKey, ConflictingKey, CaseCollision, ZeroStableKey, MissingExpectedAbi, ForbiddenExpectedAbi, InvalidPresence, InvalidQualifierCombination, OrdinalGap, DuplicateOrdinal, DerivedHashMismatch |
| GraphOrOwnership | MissingOwner, CrossModuleOwner, MissingGraphTarget, WrongReferenceKind, RelocationDependencyMismatch, WrongRecordKind, MissingRecord, MissingCoverage, UnexpectedRecord, UndeclaredEntity, DuplicateDebugOwner, DebugLinkMismatch, EnumAuthorityMismatch, InitializerOwnershipMismatch, GlobalCoverageMismatch, ProfileGraphMismatch, SourceGraphMismatch, GraphAbiMismatch, InvocationKindMismatch, DebugSourceMismatch |
| Ineligible | CompatibilityMismatch, ContextMismatch, ProfileMismatch, SourceSnapshotMismatch, CurrentAbiMismatch, CurrentContentMismatch, CurrentSymbolMissing |

`BudgetExceeded` remains the one budget result for scalar decode, record decode,
graph indexing, resident DTOs, codec payloads, codec summaries, relocations,
debug sources, and owned canonical bytes.

### Validation precedence

The fixed precedence is:

1. local envelope/payload decode, arithmetic, budget, canonical semantic,
   derived-hash, and RecordId validation when creating immutable tokens;
2. graph-step-1 reachable opaque-codec/integrity validation;
3. immutable ModuleSnapshot graph ownership, coverage, profile/source/ABI,
   initializer, enum, debug, and relocation self-consistency; then
4. current source/profile/ABI/content resolver eligibility.

An internally contradictory record set MUST NOT fall through to a normal miss.
For example, FunctionBody versus ModuleInterface ABI disagreement is
`GraphAbiMismatch`; only a self-consistent stored ABI versus the current
resolver is `CurrentAbiMismatch`.

Within item 1, complete physical payload decode includes an immediate
`Reader.IsAtEnd()` check before canonical semantic or derived-hash validation.
Thus trailing data always wins over a simultaneous TypeLayoutHash,
EnumAuthorityHash, state/body/debug/snapshot hash, or other local semantic
mutation. A decoder may capture enclosing-field offsets during physical decode,
but it may not publish or semantically validate a partial DTO before payload
exhaustion.

After TypeSchema payload exhaustion, its field-local semantic pass is exact
top-level wire order: identity/strings/flags, Metadata, Relations, LayoutInputs,
Layout scalars, OrderedProperties, OrderedMethods, VirtualFunctionTable,
OrderedBehaviorSlots, KindPayload, Reflection, Dependencies. LayoutInputHash is
checked in each LayoutInput row; each property checks StorageLayoutHash then
PropertyLayoutFingerprint; EnumAuthorityHash is checked in Enum KindPayload.
Earlier fields apply only intrinsic/TypeKind-local rules and never inspect the
later Reflection discriminator. Only after every field-local check do
`ReflectionFormClosure` including Class Construct/Factory count, Behavior copy
aliases, flag/Behavior coupling,
relation/LayoutInput pairing, locally derivable Dependency set equality, and full
layout replay run in that order. `ReflectionFormClosure` derives the legal
TypeKind+Reflection form and applies deferred flags, prior-field form presence/
cardinality and Reflection membership/string rules in top-level wire order.
TypeLayoutHash is checked last despite its earlier physical position inside
Layout. Paired failures assert exact captured ByteOffset. This unique order is
co-normative with sections 10/12 of `type-layout-authority-v1.md` and section 11
of `type-schema-matrix-v1.md`.

Method/VFT/Behavior arrays use the same subphase precedence after PayloadDecode:
active key/ABI values in stored-row order; ordinal duplicate/gap/order; role and
optional-tag shape; duplicate FunctionKey; then cross-field closure. A present
ScriptFunction Behavior owner is active and checked nonzero before ordinals. A
missing ScriptFunction owner or any present EnvironmentSymbol owner is checked
only after ordinals; the Environment value is inactive and never interpreted.

At the pairing phase, an individually valid `BaseType` target that differs from
Base, or an individually valid `CodeRoot` target that differs from either stored
ShadowSuper or CodeSuper over `{ReferenceKind, StableKey, ExpectedAbi}`, returns
`InvalidQualifierCombination/LocalSemantic` at the offending LayoutInput
enclosing-field offset. This is raw stored-coordinate equality only; resolved
target/category/owner/ABI/code-root semantics remain ModuleGraph work.

## One caller-owned read budget

The caller creates one `FAngelscriptCacheReadBudget` and passes both
`const FAngelscriptCacheReadLimits&` and that same budget through envelope
decode, every token/child decode, every opaque `Validate`, and
`ValidateModuleSnapshotGraph`. The budget is monotonic even on failure; no
layer rolls it back. `DeserializeRecordEnvelope` therefore adds the mandatory
budget-taking overload:

```cpp
DeserializeRecordEnvelope(Bytes, Limits, Budget, OutEnvelope);
```

The existing `DeserializeRecordEnvelope(Bytes, Limits, OutEnvelope)` overload
remains source-compatible and retains its standalone behavior by using a fresh
local budget internally. Any multi-record/graph/session path MUST use the new
overload and may not call the convenience overload. The same counters charge:

- canonical payload/string/array bytes and decoded owning DTO resident bytes;
- the immutable token/control allocation exactly once at token-factory time;
- temporary record lookup/validation indexes and the candidate graph's
  reachable-handle, published-view/index, and opaque-summary capacities;
- opaque payload bytes before codec invocation;
- relocation, debug-source, and owned-byte summaries returned by the codec,
  extended through the same module-graph candidate sink before their allocations;
  and
- all nested common values.

No envelope decoder, token factory, record decoder, child loop, opaque codec,
graph phase, or retry resets the budget. A record may fit its local per-record
limit while the full graph still returns `BudgetExceeded`. Budget failure
clears the current output and occurs before the allocation or codec call that
would exceed the limit.

`FAngelscriptCacheReadBudget` has no public session-counter `Reset()` in V1.
The development-phase transitional method is removed: it could erase a live
token's conservative retained charge while checking only temporary scratch.
An isolated convenience call constructs a fresh local Budget and a new
session/retry follows its owning protocol with a fresh or continuing Budget.
This does not remove the move-only scratch reservation's RAII `Reset()`, which
releases only its currently active temporary bytes and refunds no monotonic
counter.

V1 also removes the split decoded/live acquisition shape. One physical
retained allocation calls `TryConsumeRetainedDecoded(Bytes, Limits)`, which
preflights both `MaxTotalDecodedBytes` and the combined
`ResidentDecodedBytes + TemporaryResidentDecodedBytes` limit before changing
either counter, then increments Total and Resident and samples combined live
peak. One physical temporary allocation calls
`TryReserveTemporaryDecoded(Bytes, Limits, Reservation)`, which performs the
same atomic Total plus combined-live preflight, increments Total and Temporary,
and installs the move-only guard. A failed call changes no target counter and
the allocation is not attempted. The transitional public
`TryConsumeDecoded` + `TryConsumeResidentDecoded` sequence and
`TryReserveTemporaryResidentDecoded` API are removed rather than retained as
ways to create half-charged allocations.

Zero-byte acquisition is an explicit allocation-free boundary. A zero-byte
`TryConsumeRetainedDecoded` succeeds and changes no counter or peak. A
zero-byte `TryReserveTemporaryDecoded` requires an inactive output guard,
succeeds with no counter or peak change, and leaves that guard inactive with
zero reserved bytes; its `Reset()` and destructor are no-ops. An already active
output guard rejects every acquisition, including zero bytes, without changing
either the existing guard or the Budget. `PromoteToRetained()` on an inactive
or zero-byte guard returns false and changes no state. This prevents a
lifetime-bearing reservation from representing no physical allocation and
prevents a zero-byte call from silently replacing live scratch ownership.

Decoded-token storage and candidate graph containers are not persistent until
their respective atomic publication point. One private Budget-friended candidate
transaction owns each candidate's aggregate temporary decoded bytes; it may extend
an already-active private transaction after each independently preflighted physical
allocation site, while the public `TryReserveTemporaryDecoded` active-output
rejection remains unchanged. Before token/controller construction or any candidate
`Reserve`/growth, the exact allocator-capacity bytes atomically consume the
monotonic total-decoded counter and extend that transaction's Temporary live charge.
No allocation is attempted before the extension succeeds. A pre-publication failure
releases only the aggregate Temporary live bytes; monotonic TotalDecoded consumption
is not refunded. Atomic publication calls the transaction's single private
`PromoteToRetained()`:
it transfers the same live bytes from active scratch to retained resident
without a second live-resident charge or allocation, consumes no second
total-decoded charge, and then moves the candidate arrays into OutGraph. The
promotion is all-or-nothing and precedes exposure of any output view. The
retained charge is conservative and is not refunded through this Budget even
if the graph is later destroyed.

The one private canonical reader takes a required semantic-blind decoded-allocation
charge sink. Canonical primitive calls and the sole all-record factory bind the
active aggregate decoded-candidate transaction and promote once after the complete
operation-specific validation boundary. The reader never selects a mode from
global/thread-local state, never duplicates wire logic, and never exposes the
private candidate extension through its public semantic archive wrappers.

The Budget records `PeakLiveResidentDecodedBytes` directly as the maximum of
`ResidentDecodedBytes + TemporaryResidentDecodedBytes` observed after every
successful retained consume, temporary acquire/release, and promotion.
`final ResidentDecodedBytes + PeakTemporaryResidentDecodedBytes` is not a
valid oracle because those maxima may occur at different times.

V1 Budget mutation is thread-affine and single-owner. "Atomic" in this section
means one logical call commits all affected counters or none of them; it does not
promise a lock-free cross-thread transaction. Envelope/decode/candidate/scratch/
graph/query work using one Budget is sequential on its bound owner thread. Only the
published `ESPMode::ThreadSafe` immutable handle may cross threads. Development
builds bind the first mutation thread and reject cross-thread mutation, promotion,
release or destruction with an active candidate.

The immutable token and its thread-safe shared controller are one physical
allocation created through private-token `MakeShared`. Before allocation the
factory charges the allocator-quantized size of that exact intrusive
controller/object allocation once to TotalDecoded and the active decoded-token
candidate transaction's Temporary bytes; the final publication promotion moves
that charge to Resident. The unit-test probe verifies the observed allocator size.
Charging only `sizeof(Token)`,
using `MakeShareable(new ...)`, or allocating a separate object and controller
is nonconforming.

Predicted allocator charge is never corrected after allocation. Supported targets
prove `QuantizeSize`/typed allocator capacity equals controller-base `GetAllocSize`
or container `GetAllocatedSize`; divergence is a development/test fail-fast and an
unsupported production combination, because post-allocation charging cannot satisfy
the preflight guarantee. The token interior pointer is not an allocation base.

For the exact final token type:

```cpp
using FController =
    SharedPointerInternals::TIntrusiveReferenceController<
        FAngelscriptDecodedCacheRecord,
        ESPMode::ThreadSafe>;

constexpr SIZE_T ControllerNewAlignment =
    alignof(FController) > __STDCPP_DEFAULT_NEW_ALIGNMENT__
        ? alignof(FController)
        : (sizeof(FController) <= 8
            ? SIZE_T(8)
            : SIZE_T(__STDCPP_DEFAULT_NEW_ALIGNMENT__));

ControllerCharge = FMemory::QuantizeSize(
    sizeof(FController), ControllerNewAlignment);
```

This mirrors UE 5.8's replacement `operator new`: ordinary allocations use
alignment 8 only for sizes at most 8 and otherwise the standard default-new
alignment; over-aligned controller types use their declared alignment. Using
`alignof(Token)` or blindly passing `alignof(FController)` is not the frozen
allocator oracle. `TSharedRef` exposes only the token's interior object pointer,
not the controller allocation base, so passing `Handle.Get()` to
`FMemory::GetAllocSize` is forbidden. Under `WITH_ANGELSCRIPT_UNITTESTS`, a
narrow measurement hook allocates and destroys one instance of the same exact
`FController` through
`SharedPointerInternals::NewIntrusiveReferenceController`, retains its base
pointer, and confirms `FMemory::GetAllocSize` equals the independent
precomputed charge. That measurement never publishes a handle and never
substitutes for production: the real factory is still required to call
private-token `MakeShared` exactly once. Constructor/allocation counters,
shared object/DTO/payload/offset identity, and zero-delta handle copies prove
the factory did not add a second token/object allocation.

TypeSchema specifically adopts the exhaustive TS-SCR-01..22 allocation-family
inventory in `type-schema-matrix-v1.md` section 12.10 and
`type-layout-authority-v1.md` section 11. Each decoded owning string/array,
actual local index, graph index/set/queue, current-layout memo, and candidate/
published type view has an allocator-authoritative exact-limit, one-byte-short,
no-allocation, lifetime, release, and promotion row. A generic cumulative-budget
test cannot replace that inventory. TS-SCR-21 and MS-SCR-21 name the same
physical output sites and authorize one reservation/promotion, never two.

The other all-record-factory decode families are frozen here; each nested
string/array/byte container named inside one row is parameterized independently
and in every simultaneously-live combination. The first retained row for each
kind also owns that token's object/control allocation, canonical-payload array,
flat fixed-offset block, and per-element parallel captured-offset arrays. Those
bytes are not a hidden common allocation and are not charged again by a graph.

| ID | Retained decode family | Exact allocation oracle |
|---|---|---|
| AR-SCR-SI-01 | SourceIndex discovery options, mounts, providers, hooks, files, inputs, edges, ineligible scopes, every nested string/array, token canonical bytes, and all parallel captured offsets | migrate the approved SourceIndex cases to actual allocator capacity; empty/one/slack/many, exact and one-byte-short per nested family |
| AR-SCR-MI-01 | ModuleInterface namespaces, declarations, parameters/types/metadata/slots, imports/dependencies, every nested string/array, token canonical bytes, and all parallel captured offsets | empty/one/slack/many plus nested and combined exact/one-byte-short |
| AR-SCR-FB-01 | FunctionBody canonical execution payload, ActualDependencies, optional DebugSidecar storage, token canonical bytes, and all parallel captured offsets | each byte/array/optional family independently and combined at exact allocator capacity/one-byte-short |
| AR-SCR-DS-01 | DebugSidecar Sources, each logical-section string, canonical debug payload, token canonical bytes, and all parallel captured offsets | zero/one/slack/many sources and payload sizes, nested/combined exact/one-byte-short |
| AR-SCR-MSNP-01 | ModuleSnapshot TypeSchema and FunctionBody link arrays, token canonical bytes, and all parallel captured offsets | each link family and their simultaneous maximum at exact/one-byte-short |

ModuleState maps its decoded DTO and offset capacities to MS-SCR-01/02 in
`module-state-matrix-v1.md`. TypeSchema maps them to TS-SCR-01..11; the flat
token/header block is TS-SCR-01. An offset table that survives publication but
is missing from these rows is an unbudgeted allocation and fails V1.

For every retained allocation above, the exact capacity is consumed once in
both semantic counters that describe it: monotonic `TotalDecodedBytes` and
live/conservative `ResidentDecodedBytes`. That is one physical allocation with
two different limit dimensions, not a duplicate charge in either counter.
Payload input consumption alone cannot satisfy `MaxTotalDecodedBytes`.
`ReadArrayCount` performs only count/minimum-wire checks; immediately before
each `Reserve`, grow, `SetNum*`, or string buffer allocation, the typed helper
uses the actual allocator's `CalculateSlackReserve`, checked byte multiply,
budget acquisition, and a test assertion/probe that the resulting
`GetAllocatedSize` equals the charged capacity. Requested count times element
size is not an allocator oracle. This rule also applies recursively to common
CanonicalDataType and to FString character buffers.

## Task 2B-2 executable evidence

Only after both RED blockers are closed, pure in-memory tests MUST freeze:

- one full payload, full RecordId, and complete serialized-envelope golden for
  each of the five record kinds; each envelope has a fixed 56-byte header plus
  its complete canonical payload, not a 56-byte total size;
- each enum, flag mask, tagged-union, optional, semantic sequence, set
  comparator, local hash stream, and independent payload schema version;
- class, enum, delegate, typedef, and funcdef TypeSchema variants;
- signed enum aliases, metadata-sensitive enum authority, reflection presence,
  ordered direct interfaces and diamond closure, exact initial/tail-aligned
  layout from persisted property/LayoutInput evidence, independent public-method/VFT order, explicit zero-mask UFunction and
  StaticsClass-global membership, property replication, and no duplicate
  constructor/factory arrays;
- empty and nonempty ModuleState, every CanonicalValue width/bit pattern,
  exhaustive ScriptType/EnvironmentType cleanup and ValueStorageKind mapping,
  exact declaration/unit/action/default-construction/post-init coverage and
  ordering, and one EnumAuthority per local enum;
- present debug, profile-specific absent debug, logical-section identity,
  debug-source equality, and sibling-shared identity goldens;
- deterministic `UEASOPQ1` fixture codecs for all three opaque kinds,
  unsupported codec, malformed/hash mismatch, complete relocation-coordinate
  subset, Debug V1 zero-relocation behavior, Execute-action-order/fail-fast
  initializer calls, the exact owned-byte comparator and exact owned-byte set,
  owned name/string bytes, and cumulative budget failures;
- redundant keyed ModuleSnapshot links and compile-time DTO-shape evidence that
  direct debug/initializer links cannot be encoded;
- immutable token factory RecordId recomputation/dispatch/offset capture,
  mutable-DTO/bytes rejection, shared immutable handle lifetime, reachable-only
  handle retention, validated SourceIndex token, and mandatory Limits plus
  monotonic-budget propagation through envelope/token/codec/graph;
- one valid complete module graph plus a mutation matrix for every appended
  error, null context/zero selection, exact current-resolver order, graph
  anti-O(n^2) lookup counters, reachable-only exactly-once opaque calls, stored
  validated summaries, exact candidate output-container capacity/one-byte-short
  behavior, scratch-to-retained atomic promotion, late-failure release, input
  array destruction, unrelated-handle non-retention, and record-to-record
  versus record-to-current precedence, the complete TS-SCR-01..22 matrix, cold
  exact-hit zero-call coverage for every selected-module graph/profile-closed
  route, missing-local-child graph failure, prospective local layout use by a
  nested environment recipe, and pure eligible current-layout order/at-most-
  once calls;
- TypeSchema paired failures covering physical exhaustion, exact top-level
  field-local order, deferred cross-field replay, and the unique
  LayoutInputHash/property hashes/EnumAuthorityHash/final TypeLayoutHash order,
  asserting exact Error, Stage, RecordKind, and captured ByteOffset; and
- atomic empty OutGraph on every failure.

These tests remain engine-free and disk-free. Passing them completes only the
remaining record/interface and per-module graph slice. It does not complete
manifest reachability, pack/store publication, source capture, live compiler
codec, engine attachment, PIE, packaging, or Shipping startup acceptance.
