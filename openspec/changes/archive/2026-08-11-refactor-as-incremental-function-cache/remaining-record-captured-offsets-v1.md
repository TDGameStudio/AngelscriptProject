# Remaining Record Captured Offsets V1

Status: normative for Task 2.4d / IC-095. This document freezes the public,
append-only, non-wire diagnostic coordinate API for ModuleState, FunctionBody,
DebugSidecar, and ModuleSnapshot before the final seven-alternative decoded-record
storage is declared.

Header GREEN remains gated on independent exact-SHA review reaching `0C/0I`; the
coordinate authority exists, but review acceptance is not implied by its existence.

These coordinates identify semantic wire fields. They do not enter a payload,
RecordId, hash stream, manifest, pack, CompatibilityKey, or ContextKey.

## Common coordinate contract

All four field enums have underlying type `uint16`. Published values are never
inserted, deleted, reused, reordered, or renumbered. Future fields append after the
last value of the corresponding enum.

```cpp
struct FAngelscriptModuleStateFieldCoordinate
{
	EAngelscriptModuleStateCapturedField Field =
		EAngelscriptModuleStateCapturedField::Invalid;
	uint32 PrimaryIndex = MAX_uint32;
	uint32 SecondaryIndex = MAX_uint32;
	uint32 TertiaryIndex = MAX_uint32;
};

struct FAngelscriptFunctionBodyFieldCoordinate
{
	EAngelscriptFunctionBodyCapturedField Field =
		EAngelscriptFunctionBodyCapturedField::Invalid;
	uint32 PrimaryIndex = MAX_uint32;
	uint32 SecondaryIndex = MAX_uint32;
	uint32 TertiaryIndex = MAX_uint32;
};

struct FAngelscriptDebugSidecarFieldCoordinate
{
	EAngelscriptDebugSidecarCapturedField Field =
		EAngelscriptDebugSidecarCapturedField::Invalid;
	uint32 PrimaryIndex = MAX_uint32;
	uint32 SecondaryIndex = MAX_uint32;
	uint32 TertiaryIndex = MAX_uint32;
};

struct FAngelscriptModuleSnapshotFieldCoordinate
{
	EAngelscriptModuleSnapshotCapturedField Field =
		EAngelscriptModuleSnapshotCapturedField::Invalid;
	uint32 PrimaryIndex = MAX_uint32;
	uint32 SecondaryIndex = MAX_uint32;
	uint32 TertiaryIndex = MAX_uint32;
};
```

Tables below use `U` for `MAX_uint32`. A Field accepts exactly its documented
indexes. Missing a required index, supplying a non-`U` unused index, using an
out-of-range index, supplying `Invalid` or an unpublished numeric Field, requesting
an inactive optional value, or calling the overload on the wrong active RecordKind
returns unset. Wrong RecordKind is checked before Field and index applicability.
Lookup is allocation-free and Budget-free. It consults only the immutable table
retained by the decoder; it never scans payload bytes or searches by a semantic key.
A captured offset whose numeric value is zero returns a set optional containing
zero.

Container Fields point to the `u32` element-count prefix and remain set for an empty
container. Row Fields point to the first field of the row. String Fields point to
their `u32` UTF-8 byte-count prefix. Byte-payload Fields point to their `u64`
byte-count prefix and remain set for an empty payload. There is no separate public
coordinate for an encoding-only count/length token or an individual byte.

Optional `*Presence` Fields point to the tag. The value Field is set only when the
optional is present and points to the value start. Enclosing values without their
own prefix may share an offset with their first child while remaining distinct
logical coordinates. In particular:

- a CanonicalDataType Node shares the Kind byte;
- a StableReference shares the ReferenceKind byte;
- a SemanticDependency row shares DependencyKind, and its Target shares
  TargetReferenceKind;
- a RecordId shares RecordIdKind;
- an inline link shares its first entity key; and
- a row shares its first stored field.

Applicability is an exact-occurrence decoder rule, never a caller-provided Boolean.
An occurrence identity is `{optional family, PrimaryIndex, SecondaryIndex}`; unused
axes are `U`. For CanonicalDataType optionals, Secondary is the exact root-local
preorder node, so two nodes in one root, two rows in one family, and Global versus
HardValue roots never share presence. Every Presence coordinate remains available
whether its own tag says absent or present and regardless of unrelated tags. When
an exact occurrence is absent, every coordinate for its controlled enclosing value
and all subfields returns unset; enabling another occurrence in the same family or
any occurrence in another family cannot make it applicable. When that exact
occurrence is present, each otherwise-valid coordinate resolves. V1 defines these
independent optional families:

- Global.Type.TypeReference: Reference, ReferenceKind, StableKey and ExpectedAbi;
- HardValue.Type.TypeReference: Reference, ReferenceKind, StableKey and ExpectedAbi;
- HardValue.CanonicalValue: enclosing value, ValueKind and FixedWidthValueBytes;
- Initializer.OwnerGlobal;
- InitializationAction dependency ExpectedContentOrValue;
- ModuleState dependency ExpectedContentOrValue;
- FunctionBody actual dependency ExpectedContentOrValue; and
- FunctionBody.DebugSidecar RecordId: enclosing RecordId, Kind and ContentHash.

For each two-axis repeated family, the declaration-first matrix uses at least
`A={0,0}`, `B={0,1}`, and `C={1,0}`. Relative to A, B changes only Secondary and C
changes only Primary, so a controlled enclosing value and every subfield must be
present only in A's one-hot state and remain absent in the same-primary/other-secondary,
other-primary/same-secondary, and every unrelated-family one-hot state. The Presence
coordinate remains queryable in all of those states. The same own-only checks are
also applied to the B and C controlled coordinates. One-axis repeated families use
two distinct Primary occurrences with the equivalent own/other/unrelated isolation.
This includes mixed Global/HardValue roots and different DataType nodes. DebugSidecar
is a singleton top-level optional with `{U,U}` and therefore has one coordinate
identity, but its absent and present states plus every unrelated one-hot state are
all tested.

Every independent CanonicalDataType root owns a separate continuous pre-order
ordinal space. The decoder assigns the root ordinal zero, then visits
`OrderedSubTypes` depth-first and left-to-right in wire order. No caller path or
per-depth index is accepted. Root identity is the pair `{owning field family,
PrimaryIndex}`: Global.Type and HardValue.Type are different families, and every
row in either family is a different root. The decoder retains a node count for each
exact root identity. Its Secondary bound is resolved only from that identity; an
adjacent row or the other family can neither donate its larger bound nor continue
the previous root's ordinal. Consequently every root starts again at Secondary
zero, roots may have different bounds, and a missing root identity fails closed.

## ModuleState fields

```cpp
enum class EAngelscriptModuleStateCapturedField : uint16
{
	Invalid = 0,

	PayloadSchemaVersion = 1,
	ModuleKey = 2,
	Profile = 3,
	StateInputHash = 4,

	OrderedGlobals = 5,
	Global = 6,
	GlobalStorageOrdinal = 7,
	GlobalKey = 8,
	GlobalCanonicalNamespace = 9,
	GlobalCanonicalName = 10,
	GlobalTypeNode = 11,
	GlobalTypeKind = 12,
	GlobalTypePrimitive = 13,
	GlobalTypeReferencePresence = 14,
	GlobalTypeReference = 15,
	GlobalTypeReferenceKind = 16,
	GlobalTypeReferenceStableKey = 17,
	GlobalTypeReferenceExpectedAbi = 18,
	GlobalTypeQualifierFlags = 19,
	GlobalTypeOrderedSubTypes = 20,
	GlobalTraitFlags = 21,
	GlobalInitializationKind = 22,
	GlobalCleanupPolicy = 23,
	GlobalStorageLayoutFingerprint = 24,

	HardValues = 25,
	HardValue = 26,
	HardValueKind = 27,
	HardValueOwner = 28,
	HardValueOwnerReferenceKind = 29,
	HardValueOwnerStableKey = 30,
	HardValueOwnerExpectedAbi = 31,
	HardValueTypeNode = 32,
	HardValueTypeKind = 33,
	HardValueTypePrimitive = 34,
	HardValueTypeReferencePresence = 35,
	HardValueTypeReference = 36,
	HardValueTypeReferenceKind = 37,
	HardValueTypeReferenceStableKey = 38,
	HardValueTypeReferenceExpectedAbi = 39,
	HardValueTypeQualifierFlags = 40,
	HardValueTypeOrderedSubTypes = 41,
	HardValueCanonicalValuePresence = 42,
	HardValueCanonicalValue = 43,
	HardValueCanonicalValueKind = 44,
	HardValueCanonicalValueFixedWidthValueBytes = 45,
	HardValueHash = 46,

	Initializers = 47,
	Initializer = 48,
	InitializerKind = 49,
	InitializerKey = 50,
	InitializerOwnerGlobalPresence = 51,
	InitializerOwnerGlobal = 52,
	InitializerVmInitializerCodecVersion = 53,
	InitializerExecutionHash = 54,
	InitializerCanonicalExecutionPayload = 55,

	OrderedInitializationActions = 56,
	InitializationAction = 57,
	InitializationActionOrdinal = 58,
	InitializationActionKind = 59,
	InitializationActionTarget = 60,
	InitializationActionTargetReferenceKind = 61,
	InitializationActionTargetStableKey = 62,
	InitializationActionTargetExpectedAbi = 63,
	InitializationActionDependencies = 64,
	InitializationActionDependency = 65,
	InitializationActionDependencyKind = 66,
	InitializationActionDependencyTarget = 67,
	InitializationActionDependencyTargetReferenceKind = 68,
	InitializationActionDependencyTargetStableKey = 69,
	InitializationActionDependencyTargetExpectedAbi = 70,
	InitializationActionDependencyExpectedContentOrValuePresence = 71,
	InitializationActionDependencyExpectedContentOrValue = 72,

	OrderedPostInitFunctions = 73,
	PostInitFunction = 74,
	PostInitOrdinal = 75,
	PostInitFunctionReference = 76,
	PostInitFunctionReferenceKind = 77,
	PostInitFunctionStableKey = 78,
	PostInitFunctionExpectedAbi = 79,

	Dependencies = 80,
	Dependency = 81,
	DependencyKind = 82,
	DependencyTarget = 83,
	DependencyTargetReferenceKind = 84,
	DependencyTargetStableKey = 85,
	DependencyTargetExpectedAbi = 86,
	DependencyExpectedContentOrValuePresence = 87,
	DependencyExpectedContentOrValue = 88,
};
```

### ModuleState indexes

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---:|---:|---:|---|
| `1..5` | `U` | `U` | `U` | Top-level scalars and OrderedGlobals count. |
| `6..10` | global ordinal | `U` | `U` | Global row and direct fields before Type. |
| `11..20` | global ordinal | Global.Type node pre-order ordinal | `U` | Global CanonicalDataType node and fields. |
| `21..24` | global ordinal | `U` | `U` | Remaining direct Global fields. |
| `25` | `U` | `U` | `U` | HardValues count. |
| `26..31` | hard-value ordinal | `U` | `U` | HardValue row, kind, and Owner reference. |
| `32..41` | hard-value ordinal | HardValue.Type node pre-order ordinal | `U` | HardValue CanonicalDataType node and fields. |
| `42..46` | hard-value ordinal | `U` | `U` | CanonicalValue optional and stored hash. |
| `47` | `U` | `U` | `U` | Initializers count. |
| `48..55` | initializer ordinal | `U` | `U` | Initializer row and fields. |
| `56` | `U` | `U` | `U` | OrderedInitializationActions count. |
| `57..64` | action ordinal | `U` | `U` | Action row/direct fields and its Dependencies count. |
| `65..72` | action ordinal | action-dependency ordinal | `U` | Nested action dependency and common-value fields. |
| `73` | `U` | `U` | `U` | OrderedPostInitFunctions count. |
| `74..79` | post-init ordinal | `U` | `U` | Post-init row and Function StableReference. |
| `80` | `U` | `U` | `U` | Top-level Dependencies count. |
| `81..88` | top-level dependency ordinal | `U` | `U` | Top-level dependency and common-value fields. |

Primary and Secondary indexes above are canonical array positions, never the stored
`StorageOrdinal`, `ActionOrdinal`, or `PostInitOrdinal` values. TypeReference
Presence exists at every DataType node; Reference and its component Fields are set
only when present. HardValueCanonicalValuePresence exists for every HardValue;
Fields `43..45` are set only when present. InitializerOwnerGlobalPresence exists for
every Initializer; Field `52` is set only when present. Dependency
ExpectedContentOrValuePresence exists for every dependency row; the value Field is
set only when present.

## FunctionBody fields

```cpp
enum class EAngelscriptFunctionBodyCapturedField : uint16
{
	Invalid = 0,

	PayloadSchemaVersion = 1,
	ModuleKey = 2,
	Identity = 3,
	IdentityFunctionKey = 4,
	IdentityContent = 5,
	IdentityContentExecution = 6,
	IdentityContentDebug = 7,
	IdentityProfile = 8,
	ExpectedDeclarationAbi = 9,
	FunctionSourceDigest = 10,
	FunctionInputDigest = 11,
	InvocationKind = 12,
	VmExecutionCodecVersion = 13,
	CanonicalExecutionPayload = 14,
	ActualDependencies = 15,
	ActualDependency = 16,
	ActualDependencyKind = 17,
	ActualDependencyTarget = 18,
	ActualDependencyTargetReferenceKind = 19,
	ActualDependencyTargetStableKey = 20,
	ActualDependencyTargetExpectedAbi = 21,
	ActualDependencyExpectedContentOrValuePresence = 22,
	ActualDependencyExpectedContentOrValue = 23,
	DebugSidecarPresence = 24,
	DebugSidecar = 25,
	DebugSidecarKind = 26,
	DebugSidecarContentHash = 27,
};
```

### FunctionBody indexes

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---:|---:|---:|---|
| `1..15` | `U` | `U` | `U` | Top-level and nested identity fields; ActualDependencies is its count. |
| `16..23` | actual-dependency ordinal | `U` | `U` | Dependency row and common-value fields. |
| `24..27` | `U` | `U` | `U` | DebugSidecar optional tag, present RecordId, kind, and content hash. |

Identity and IdentityFunctionKey share the FunctionKey start. IdentityContent and
IdentityContentExecution share the Execution start. DebugSidecarPresence always
exists; Fields `25..27` exist only for a present RecordId. The production DTO member
names are exactly `FunctionSourceDigest` and `FunctionInputDigest`; the shortened
plan-only names `SourceDigest` and `InputDigest` are not aliases and are forbidden.

## DebugSidecar fields

```cpp
enum class EAngelscriptDebugSidecarCapturedField : uint16
{
	Invalid = 0,

	PayloadSchemaVersion = 1,
	FunctionKey = 2,
	Profile = 3,
	DebugHash = 4,
	VmDebugCodecVersion = 5,
	Sources = 6,
	Source = 7,
	SourceFileKey = 8,
	SourceLogicalSectionKey = 9,
	SourceCanonicalLogicalSection = 10,
	CanonicalDebugPayload = 11,
};
```

### DebugSidecar indexes

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---:|---:|---:|---|
| `1..6` | `U` | `U` | `U` | Top-level fields; Sources is its count. |
| `7..10` | source ordinal | `U` | `U` | DebugSourceReference row and fields. |
| `11` | `U` | `U` | `U` | CanonicalDebugPayload byte payload. |

Source and SourceFileKey share the first hash start. Typed key wrappers are the
semantic field; their internal `Hash` member is not another public coordinate.

## ModuleSnapshot fields

```cpp
enum class EAngelscriptModuleSnapshotCapturedField : uint16
{
	Invalid = 0,

	PayloadSchemaVersion = 1,
	ModuleKey = 2,
	ModuleInterface = 3,
	ModuleInterfaceModuleKey = 4,
	ModuleInterfaceRecordId = 5,
	ModuleInterfaceRecordIdKind = 6,
	ModuleInterfaceRecordIdContentHash = 7,
	TypeSchemas = 8,
	TypeSchemaLink = 9,
	TypeSchemaLinkTypeKey = 10,
	TypeSchemaLinkRecordId = 11,
	TypeSchemaLinkRecordIdKind = 12,
	TypeSchemaLinkRecordIdContentHash = 13,
	ModuleState = 14,
	ModuleStateModuleKey = 15,
	ModuleStateRecordId = 16,
	ModuleStateRecordIdKind = 17,
	ModuleStateRecordIdContentHash = 18,
	FunctionBodies = 19,
	FunctionBodyLink = 20,
	FunctionBodyLinkFunctionKey = 21,
	FunctionBodyLinkRecordId = 22,
	FunctionBodyLinkRecordIdKind = 23,
	FunctionBodyLinkRecordIdContentHash = 24,
};
```

### ModuleSnapshot indexes

| Values | Primary | Secondary | Tertiary | Meaning |
|---|---:|---:|---:|---|
| `1..8` | `U` | `U` | `U` | Top-level header, required ModuleInterface link, and TypeSchemas count. |
| `9..13` | type-schema-link ordinal | `U` | `U` | TypeSchemaLink row, entity key, and RecordId fields. |
| `14..19` | `U` | `U` | `U` | Required ModuleState link and FunctionBodies count. |
| `20..24` | function-body-link ordinal | `U` | `U` | FunctionBodyLink row, entity key, and RecordId fields. |

ModuleInterface and ModuleInterfaceModuleKey share the first key start; ModuleState
and ModuleStateModuleKey do likewise. Each array link row shares its entity-key
start, and each RecordId shares its Kind byte. RecordId Kind has a distinct Field so
a wrong stored linked kind is diagnosed at that byte rather than only at the
enclosing link. Required module links consume no array index.

## Wrong-kind and applicability precedence

For every overload of `FAngelscriptDecodedCacheRecord::FindCapturedOffset`:

1. check the active token RecordKind against the coordinate type;
2. reject Invalid/unpublished Field values;
3. enforce required and unused axes exactly;
4. enforce row and DataType pre-order bounds; and
5. enforce optional/presence applicability.

Every rejection returns unset without allocation or Budget mutation. A valid
coordinate is allowed to resolve to offset zero. The four record types currently use
at most Primary and Secondary; Tertiary remains part of the common public shape and
must be `U` for every V1 Field. It is not assigned an artificial meaning merely to
consume the axis.

The declaration-first failure matrix is complete for each of the four coordinate
types. Each type must prove: wrong active kind; `Invalid`; `LastPublished + 1` as an
unpublished numeric value; valid set-zero; non-`U` values on every unused P/S/T
axis; missing Primary on one Primary field; Primary equal to its count; and surplus
Secondary/Tertiary on a Primary-only field. ModuleState additionally proves missing
Secondary, Secondary equal to the exact nested/root count, and surplus Tertiary on
a P/S field. These cover every axis that is used by any V1 remaining-record field;
Tertiary has no V1 user and is exhaustively negative.

The public API contains only the four const typed one-argument overloads. For each
coordinate type, dependent `requires` negative compilation contracts cover const
and non-const record lvalue receivers crossed with const-lvalue, mutable-lvalue, and
rvalue coordinates: 6 call shapes per type, 24 shapes total. Every callable
`FindCapturedOffset(Coordinate, bool)` form is rejected; production must not recreate
optional applicability as a caller Boolean, including through a generic or defaulted
two-argument overload.

## Design decisions frozen by Task 2.4d

- These records use the exhaustive ModuleInterface-style common-value breakdown,
  not the coarser already-published TypeSchema coordinate families. Existing
  TypeSchema values cannot be renumbered; future TypeSchema detail, if needed, must
  append.
- CanonicalValue has separate Presence, enclosing value, ValueKind, and byte-payload
  Fields. The enclosing value and kind share an offset. Scalar bytes are not split.
- OwnerGlobal is an optional typed key, so Presence plus value is complete; there is
  no encoding-only `OwnerGlobalHash` Field.
- VM execution/debug/initializer codec internals remain opaque. Their canonical byte
  arrays expose exactly one byte-payload Field each.
- `PostInitFunctionReference` names the wire `Function:StableReference` field and
  avoids collision with the `PostInitFunction` row Field.
- FunctionBody keeps enclosing Identity and IdentityContent Fields even though they
  share first-child offsets. This preserves an append-only route for whole-value
  diagnostics.
- Debug source typed keys do not expose wrapper-internal Hash coordinates.
- ModuleSnapshot splits every RecordId into enclosing, Kind, and ContentHash Fields.
  The manifest-only `FAngelscriptCachedModuleSnapshotLink` remains outside the
  ModuleSnapshot record DTO/header ownership.

## Remaining DTO C++ value contract

The exact member names, types, and wire order are those in
`remaining-record-declaration-inventory.md`. All remaining record and nested DTOs
are pointer-free owning aggregates. Each is default constructible, copy
constructible/assignable, move constructible/assignable, and destructible. This is a
value-semantic capture/producer contract; it does not freeze `sizeof`, alignment,
padding, member offsets, triviality, or a C++ object-layout wire format.

The RED compilation contract decomposes each of the four coordinate aggregates and
all fifteen remaining record/nested DTO aggregates with a structured binding of
exact arity. The binding type tuple freezes declaration order and the direct named
member expressions freeze every public member name and type. Because structured
binding arity must equal aggregate element count, an extra member fails compilation
even when it has a default initializer. A closed owned-member trait rejects raw
pointers directly and recursively through `TArray` and `TOptional`; every remaining
DTO used as a container element is also decomposed and checked, so the combination
cannot hide a pointer in a nested remaining DTO. Existing common value wrappers are
the explicit leaf allow-list; arbitrary new member types fail closed.

Type tuples and independent named-member expressions are insufficient when two
aggregate positions have the same type. The RED therefore aggregate-initializes all
fifteen DTOs in declaration order with position-unique sentinel values and reads
every value back through its required concrete member name. Reordering same-typed
members changes which name receives each sentinel and fails mechanically. This
explicitly covers the two Global FString members, ModuleState container slots,
FunctionBody scalar/digest/identity positions, DebugSidecar's two `uint32` members,
ModuleSnapshot's two `FAngelscriptCachedModuleRecordLink` members, and every other
member position rather than relying only on a duplicate-type shortlist.

Default construction is fail closed:

- every stored enum/tag is its explicit `Invalid=0` value;
- every payload schema version, codec version, ordinal, flag mask, and other numeric
  scalar is zero;
- every hash, stable key, digest, profile, identity component, and RecordId
  ContentHash is zero;
- every RecordId Kind is numeric zero/Invalid;
- every FString and TArray is empty;
- every TOptional is unset;
- every StableReference has Invalid ReferenceKind plus zero key/ABI;
- every CanonicalDataType has Invalid Kind/Primitive, absent TypeReference, zero
  qualifier flags, and no subtypes; and
- no default-constructed DTO is locally valid or publishable.

FunctionBody owns members named exactly `FunctionSourceDigest` and
`FunctionInputDigest`, with types `FAngelscriptFunctionSourceDigest` and
`FAngelscriptFunctionInputDigest`. It has no `SourceDigest` or `InputDigest` member
alias. ModuleSnapshot owns exactly the two required module links plus TypeSchemas and
FunctionBodies arrays from the record wire. It has no `ModuleSnapshots` manifest
member; the manifest-only `FAngelscriptCachedModuleSnapshotLink` is not a record DTO
member or remaining-record declaration.

Exact aggregate arity makes these exclusions structural rather than spelling-only:
FunctionBody has exactly eleven members, so it cannot acquire a third digest under
any name. ModuleSnapshot has exactly six members, so it cannot acquire an extra,
renamed, or otherwise disguised manifest link under any name.

## RED acceptance

`AngelscriptCacheRemainingRecordCoordinateTests.cpp` freezes:

- every named numeric enum value and continuous range;
- the exact four-member coordinate arity, declaration order, names, types and
  defaults;
- exact P/S/T coverage with no overlapping or uncovered published Field;
- a per-coordinate declaration-first matrix covering wrong-kind, Invalid,
  Last+1-unpublished, set-zero, every missing/unused P/S/T case, and each used-axis
  out-of-range case;
- exact-occurrence `{family,Primary,Secondary/root-node}` optional authorities with
  Presence always applicable, `A={0,0}` / `B={0,1}` / `C={1,0}` matrices for every
  two-axis family, two Primary occurrences per one-axis family, mixed DataType
  roots/nodes, absent/present coverage for every controlled enclosing value and
  subfield, mechanically separate Primary/Secondary identity isolation, and every
  unrelated family enabled one at a time; no naked caller `bFieldApplicable` seam
  exists;
- explicit `{root family,row identity,node count}` DataType-preorder authorities
  proving ordinal-zero restart, different per-root bounds, cross-row/cross-family
  isolation, and missing-root failure;
- four const typed one-argument `FindCapturedOffset` overloads returning
  `TOptional<uint64>`, plus four negative `requires` matrices (24 const/non-const
  receiver and const-lvalue/mutable-lvalue/rvalue coordinate call shapes) forbidding
  a caller Boolean overload; and
- exact structured-binding arity/order plus direct names/types for all fifteen
  ModuleState, FunctionBody, DebugSidecar, and ModuleSnapshot record/nested DTOs,
  position-unique aggregate sentinels read back by every concrete member name,
  recursively owned member-value checks, owned-aggregate default/copy/move traits,
  and fail-closed default values;
- the exact FunctionBody members `FunctionSourceDigest` and
  `FunctionInputDigest`, with the shortened names absent; and
- absence of a manifest-only `ModuleSnapshots` member from the record DTO.

This RED is declaration-first. It intentionally includes the planned
`Cache/AngelscriptCacheRemainingRecordTypes.h` and decoded-record API before either
exists. Its first expected build failure is the missing production header, not a
test-local substitute declaration. Later per-record physical decoder tests must
compare retained token offsets against independently scanned wire offsets; this
attachment does not authorize a public test-only token constructor or mutable offset
table.
