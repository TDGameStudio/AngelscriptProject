# Cache V2 TypeSchema V1 Exhaustive Matrix

> Status: normative Task 2B-2 correction authority, **combined matrix/layout
> authority independently approved for RED on 2026-08-08**. The required
> shared-document amendments incorporate `type-layout-authority-v1.md` across
> the remaining wire, semantic schema, delta spec, design, implementation plan,
> tasks, traceability, and verification record. The Generated Delegate common
> owner amendment and final
> allocator-authoritative Task 2B-1 snapshot are independently approved; the
> ModuleState authority is also independently approved. The combined review is
> recorded in `verification.md` as `APPROVED — 0 Critical / 0 Important /
> 0 Minor`; Task 2B-2 RED may now begin. This approval does not claim RED/GREEN
> implementation or downstream runtime acceptance.

## 1. Scope, decision log, and notation

This matrix closes the specification gap for only `TypeSchema`. It does not design
`ModuleState`, implement a serializer, change the maintained AngelScript fork,
or reinterpret legacy `.cache` bytes as a specification.

Every subsection uses these labels:

- **Evidence (E):** observed maintained-fork/compiler/ClassGenerator behavior or
  an already-frozen common-wire fact.
- **Design choice (D):** the normative V1 normalized contract. This is the one
  rule an implementation and its RED fixtures must use.
- **Open question (OQ):** a remaining live-product evidence gap. It does not
  leave the wire predicate unresolved and never creates an implicit permissive
  branch: the stated fail-closed rule is the normative V1 behavior.

Normative decisions frozen by this matrix:

1. Delegate is a value/no-inherit semantic type, not a reference type.
2. Reflection forms are closed to the current product entry points.
3. `Copy=15`, `CopyConstruct=16`, and `CopyFactory=17` are explicit append-only
   behavior values; no VM ordinal is persisted or inferred.
4. Properties are local-only. Inherited storage is authoritative through the
   `Base` relation and the base TypeSchema, never copied into a derived schema.
5. Direct implemented-interface order is semantic. Closure is derived
   base-first from that ordered direct list and is never persisted as if direct.
6. `asCObjectType::methods`, `virtualFunctionTable`, and reflected UFunction
   membership are three different observable sequences. V1 represents each
   independently; a zero declaration `ReflectionFlags` mask does not mean
   “not a UFunction”.
7. Exact property/base/code-root/struct-header numeric layout inputs are
   persisted and hash-bound. They replay immutable layout before a separate
   current-layout resolver is permitted to classify environment drift.

## 2. Evidence boundary

### 2.1 Positive evidence

| Area | Evidence | Consequence |
|---|---|---|
| Common wire | `record-wire-v1.md` freezes type/function/property entity kinds, stable references, semantic dependencies, owner precedence, and errors `0..43`. | TypeSchema must resolve against ModuleInterface; it cannot invent a second declaration authority. |
| Remaining wire | `record-wire-v1-remaining.md` freezes TypeKind `1..7`, relation `1..5`, method-slot `1..4`, behavior `1..17`, reflection `1..5`, flags, and errors `44..64`, but its unimplemented TypeSchema field shape is still provisional. | This matrix supplies the exhaustive predicates and required pre-RED field corrections. Existing numeric values stay fixed; no golden exists for the corrected relation/method/VFT/UFunction fields yet. |
| Class/struct compiler shape | `as_builder.cpp::RegisterClass` creates classes as reference/script objects and structs as value/no-inherit script objects. | `Class` requires `ReferenceType`; `Struct` requires `ValueType|Final`. |
| Delegate compiler shape | `AngelscriptPreprocessor.cpp::ProcessDelegates` emits a generated `struct` with `_Inner`, constructors, `opAssign`, and generated methods; ClassGenerator tags that ScriptType as a delegate. | `Delegate` requires `ValueType|Final|Generated`, may own generated local properties/methods/behaviors, and requires `UDelegate`. |
| Layout | `as_builder.cpp::LayoutClass` starts at base/shadow boundary, aligns each local property, stores its byte offset, advances by semantic property size, and later appends inherited descriptors. | Store only local properties, but persist their exact offsets and validate the base boundary separately. |
| Method table | `as_builder.cpp` first retains local registration order in `asCObjectType::methods`, appends non-overridden base methods in base-method order, separately clones a base VFT, replaces an overridden global `vfTableIdx`, and appends new VFT slots. | The public method list and VFT have independent exact ordinal domains. One `MethodSlot` array cannot represent both. |
| Behavior storage | `asSTypeBehaviour` has constructor/factory arrays plus singleton `copy`, `copyconstruct`, and `copyfactory`. `GetBehaviourCount()` omits factories and all three copy singletons. | Capture must read the internal behavior structure explicitly. Public enumeration is not exhaustive. |
| Reflection | Preprocessor/ClassGenerator materialize UCLASS as UClass, USTRUCT as UStruct, UENUM as UEnum, and delegate/event as UDelegate. There is no maintained UINTERFACE materialization path. | The V1 reflection matrix is closed; Interface is `None` only. |
| Statics class | `GetOrCreateStaticsClass` creates a reflection-only synthetic UClass for module global functions; it is not an AngelScript class declaration. | Statics is a generated UClass schema with no VM property/method/behavior table. |
| UFunction membership | Preprocessor membership in `FAngelscriptClassDesc::Methods`, not a nonzero reflection bit, causes ClassGenerator to create a UFunction. `UFUNCTION(NotBlueprintCallable)` is reflected with a zero V1 `ReflectionFlags` mask. Statics-class `Methods` contains reflected module global functions in semantic order. | ReflectionSchema needs an explicit ordered UFunction-membership sequence. It must work for both ordinary UClass methods and module-owned StaticsClass globals and must not change declaration ownership. |
| Implemented interfaces | `FAngelscriptClassDesc::ImplementedInterfaces` is an order-sensitive `TArray`; reload planning compares it in order, and ClassGenerator traverses it in that order while recursively adding base interfaces. | Store only the ordered direct list with semantic ordinals. Derive base/interface closure deterministically; do not canonical-set-sort the direct list. |
| Typedef | `RegisterTypedef` stores primitive byte size but leaves common `asITypeInfo::alignment` at `4`. | V1 accepts only an unqualified non-void primitive alias and preserves descriptor layout `{alias size, alignment 4}` rather than copying primitive alignment. |
| Funcdef | `asCFuncdefType` is `REF|GC|FUNCDEF`, leaves live descriptor `{size=0, alignment=4}`, and signature completion may mark it shared. | `Funcdef` requires `ReferenceType`, may carry `Shared`, has no object members/behaviors, and is forbidden as a V1 property because zero-size live storage conflicts with safe exact restore. |
| Compose | ClassGenerator analysis currently rejects `ComposeOntoClass` because materialization is not implemented. | Relation enum value `Compose=5` remains reserved, but valid TypeSchema V1 has zero Compose rows. |

### 2.2 Negative evidence: legacy cache is not authority

Legacy `StaticJIT/PrecompiledData.*` is useful only as an inventory. In
particular it stores a fixed seven-element behavior reference tuple plus
constructor/factory arrays, does not exhaustively preserve all `asSTypeBehaviour`
fields, derives layout again during restore, and uses process-era references.
Those omissions are reasons to replace the format, not V1 presence rules.

**D — unique rule:** no V1 required/allowed/forbidden decision may cite “legacy
did not store it” as proof that the semantic is absent. Legacy fields may only
trigger an evidence search in compiler/ClassGenerator/current public product
entry points.

**OQ:** none. This boundary is closed.

## 3. Required wire corrections before Task 2B-2 RED

The current partial wire cannot represent exact restored layout and all current
behavior targets. These corrections must be merged before byte goldens are
authored.

### 3.1 Append-only behavior values

```text
EAngelscriptCachedBehaviorKind : u8
  Invalid=0
  Construct=1, ListConstruct=2, Destruct=3,
  Factory=4, ListFactory=5, AddRef=6, Release=7,
  GetWeakRefFlag=8, TemplateCallback=9, GetRefCount=10,
  SetGcFlag=11, GetGcFlag=12, EnumRefs=13, ReleaseRefs=14,
  Copy=15, CopyConstruct=16, CopyFactory=17
```

**E:** the three copy fields are independent `asSTypeBehaviour` singleton
coordinates and are not returned by `GetBehaviourCount()`.

**D — unique rule:** values `15..17` are written explicitly and are never
computed from `asEBehaviours`, field position, function id, declaration order,
or presence in constructor/factory arrays. Unknown values fail with
`UnknownEnumValue`.

**OQ:** none; the numbering and order are confirmed.

### 3.2 Property byte-offset authority

Replace `PropertySchema` with:

```text
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
```

Insert the four storage-layout fields immediately after CanonicalDataType and
before MemberAccess in `PropertyLayoutFingerprint`; retain
`SemanticByteOffset` immediately after `LayoutOrdinal` in the wire row and as
the exact stored offset coordinate in that fingerprint. The separate
`StorageLayoutHash` stream and legal storage-kind matrix are literal from
`type-layout-authority-v1.md`.

**E:** the live VM and ClassGenerator consume exact property offsets;
`LayoutClass` may insert alignment gaps, and ClassGenerator asserts the UE
property offset equals the script property offset.

**D — unique rule:** exact captured byte offset is authority. A restore computes
its candidate offset and must compare it to the stored value before publishing
the type. Storing only order plus final size is insufficient because two
different per-property layouts can have the same terminal size.

**OQ:** none. The maintained VM uses signed `int` offsets, therefore V1 stores a
nonnegative `u32` and additionally rejects values above `INT32_MAX`.

### 3.3 Separate public method-list and VFT authority

Replace `OrderedMethodSlots:array<MethodSlot>` with two fields in this exact
TypeSchema position:

```text
OrderedMethods:array<MethodEntry>
VirtualFunctionTable:array<VirtualFunctionSlot>

MethodEntry:
  EntryKind:u8                    # LocalMethod or Inherited only
  MethodOrdinal:u32               # exact asCObjectType::methods index
  FunctionKey:StableFunctionKey
  DeclaringOwner:StableTypeKey    # owner of FunctionKey
  ExpectedDeclarationAbi:hash256

VirtualFunctionSlot:
  SlotKind:u8                     # VirtualDeclaration/VirtualOverride/Inherited
  VftOrdinal:u32                  # exact virtualFunctionTable/vfTableIdx index
  FunctionKey:StableFunctionKey  # implementation installed in this VFT slot
  DeclaringOwner:StableTypeKey   # type that originally introduced the slot
  ImplementingOwner:StableTypeKey# owner of FunctionKey
  ExpectedDeclarationAbi:hash256 # ABI of installed declaration and slot
```

The existing append-only `MethodSlotKind` values remain numerically fixed.
`LocalMethod=1` and `Inherited=4` are the only values legal in `MethodEntry`;
`VirtualDeclaration=2`, `VirtualOverride=3`, and `Inherited=4` are the only
values legal in `VirtualFunctionSlot`. The same inherited function may appear
once in each sequence because those rows index different maintained VM arrays.

**E:** `methods` is the public `GetMethodCount/GetMethodByIndex` sequence. It
starts with local registration order and then receives non-overridden base
methods in resolved base `methods` order. `virtualFunctionTable` instead clones
the complete base table, replaces an overridden `vfTableIdx`, and appends new
local virtual slots. A derived class containing a new method, an override, and
an inherited method generally has different orders in the two arrays.

**D — unique rule:** each array has its own exact contiguous `0..N-1` ordinal
domain and its own field in `TypeLayoutHash`. No serializer sorts either array
by kind, and no restore derives one array by reordering the other. Section 8
defines their independent reconstruction predicates.

**OQ:** none. Both arrays and their orders are directly observable in the
maintained fork.

### 3.4 Behavior target may be script or environment owned

Replace BehaviorSlot with:

```text
BehaviorSlot:
  BehaviorKind:u8
  SlotOrdinal:u32
  Target:StableReference
  DeclaringOwner:optional<StableTypeKey>
```

The ABI is `Target.ExpectedAbi`; no duplicate
`ExpectedDeclarationAbi` field is written.

**E:** maintained script types begin with engine-provided default behaviors
(notably copy), while constructors/destructors and user `opAssign` may be local
script functions. A `StableFunctionKey` alone cannot name the engine-owned
case.

**D — unique rule:** `Target.ReferenceKind` is either `ScriptFunction` or
`EnvironmentSymbol`. Local TypeSchema validation requires a ScriptFunction
`DeclaringOwner` optional to be present and nonzero, and requires an
EnvironmentSymbol owner optional to be absent. A nonzero ScriptFunction owner
unequal to the enclosing TypeKey is locally admissible: exact declaration owner,
module, entity kind and ABI are ModuleSnapshot graph authority. Both target kinds
require a nonzero key and nonzero `ExpectedAbi`. Every behavior target has one
matching semantic dependency row; no restore silently substitutes the current
engine default. Local owner equality is required only by the explicit
CopyConstruct/CopyFactory alias tuple in section 9.3.

**OQ:** none. Omitting an engine behavior and relying only on CompatibilityKey
would hide which behavior coordinate changed; the explicit stable reference is
the fail-closed representation.

### 3.5 Delegate-generated declaration ownership requires a common-contract amendment

The original Task 2B-1 declaration-owner matrix forbade the owners in this
table. Therefore these rows required a common amendment rather than a
TypeSchema-local exception. `record-wire-v1.md`, `record-schema.md`, the owner
validator, and their exhaustive Task 2B-1 fixtures now adopt these rows, and the
final common snapshot has received fresh independent regression approval.

| Entity kind | Additional legal owner | Additional constraint |
|---|---|---|
| Property | Delegate | owner Type declaration is `Generated`; property declaration carries `Generated` trait |
| Method | Delegate | both type and declaration carry `Generated` |
| Constructor | Delegate | both type and declaration carry `Generated` |
| Destructor | Delegate | existing `Destructor=35`; both type and declaration carry `Generated` |
| GeneratedDefaultConstructor | Delegate | declaration carries `Generated` |
| InitDefaults | Delegate | declaration carries `Generated` |

Factory remains forbidden for Delegate because Delegate is a value type.
`DelegateSignature` remains the single non-executable signature declaration
owned by Delegate.

**E:** generated delegate structs have `_Inner`, constructors, `opAssign`, and
generated Execute/Broadcast/binding methods whose bodies are required for a
parse-free warm restore.

**D — unique rule:** those generated members are normal declaration/body
authorities owned by the Delegate TypeKey. The signature payload does not
duplicate or implicitly regenerate their VM bodies. `DelegateSignature` has
FunctionBody coverage forbidden; executable generated member declarations use
their ordinary required body coverage. A TypeSchema decoder may not weaken the
approved common owner validator locally. The common amendment is now merged and
approved; Delegate TypeSchema capture must match it exactly rather than encode
a second owner rule.

**OQ:** none after choosing exact capture over replaying preprocessor text.

### 3.6 Hash stream corrections

Replace these two fragments:

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
```

**D — unique rule:** a schema-version-1 golden is not written until these
fields and stream orders are normative. There is no compatibility obligation
to a not-yet-implemented partial V1.

### 3.7 Direct implemented-interface semantic order

Replace `TypeRelation` with:

```text
TypeRelation:
  RelationKind:u8
  SemanticOrdinal:optional<u32>
  Target:StableReference
```

`SemanticOrdinal` is required only for `ImplementedInterface`, where stored
position equals ordinal and ordinals are exactly `0..N-1`. It is forbidden for
`Base`, `ShadowSuper`, `CodeSuper`, and `Compose`. The Relations field remains
canonically encoded in RelationKind order; singleton kinds contain at most one
row, while the contiguous ImplementedInterface subsequence is ordered by
SemanticOrdinal, never by target key or ABI.

Only interfaces written directly in `FAngelscriptClassDesc::ImplementedInterfaces`
or the equivalent direct script-interface list are stored. The transitive
closure is derived deterministically: visit each direct target in ordinal
order; for a target, visit its resolved interface superclass first, then its
own direct implemented interfaces in their semantic order, then the target;
deduplicate by the full resolved interface identity at first visit. Derived
closure rows are never written back as direct relations.

**E:** reload planning compares `ImplementedInterfaces` as an ordered array,
and ClassGenerator consumes it in that order with base-first recursive closure.
Canonical target sorting would change both reload semantics and the emitted
`UClass::Interfaces` sequence.

**D — unique rule:** direct order is a stored structural semantic. Reordering
otherwise identical direct targets changes TypeLayoutHash. Closure order is a
validated derivation, not a second wire authority.

**OQ:** none.

### 3.8 Ordered reflected-UFunction membership

Extend `ReflectionSchema` with its final field:

```text
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

The array is permitted only for `ReflectionKind::UClass`. Stored position
equals `ReflectionOrdinal`, and ordinals are exactly `0..N-1`. Every Target is
a nonzero `ScriptFunction` reference with nonzero ExpectedAbi. For an ordinary
UClass it resolves to a local `Method` declaration owned by the enclosing
TypeKey. For a StaticsClass it resolves to a local `GlobalFunction` declaration
owned by ModuleKey. Statics reflection-container membership does not change
that declaration's Module owner.

Presence in this array is the sole UFunction-membership authority. A target
whose declaration `ReflectionFlags` is zero remains reflected when present;
an otherwise equal declaration absent from the array remains an ordinary AS
function. The order is the exact `FAngelscriptClassDesc::Methods` order consumed
by ClassGenerator. UDelegate signature materialization is already selected by
the Delegate kind payload and does not create a row here.

Each distinct reflected target has one `Declaration` semantic dependency;
when the same target is also present in OrderedMethods or VirtualFunctionTable,
the canonical dependency set still contains one coordinate, not one row per
consumer.

**E:** `UFUNCTION(NotBlueprintCallable)` creates a UFunction even though none
of the V1 function reflection bits need be set. Statics classes likewise hold
an ordered reflected subset of module global functions despite having no VM
object-type method table.

**D — unique rule:** zero ReflectionFlags is data, not an absence sentinel.
After capture, this array defines membership; a decoder never infers an absent
row from ModuleInterface flags. Duplicate/ordinal-invalid rows, wrong
owner/entity, or a non-ScriptFunction target are rejected before ClassGenerator
mutation. Omission relative to the producer's ClassDesc is caught by capture-
conformance coverage and changes TypeLayoutHash/RecordId; it is not “recovered”
by reflection-flag inference.

**OQ:** none.

### 3.9 Required shared-authority merge gate

Before any TypeSchema RED or schema-1 golden, all rows below are mandatory:

| Shared authority | Amendment status | Remaining regression action |
|---|---|---|
| `record-wire-v1.md` and `record-schema.md` | Approved: Delegate is a legal generated owner exactly as section 3.5; non-generated Delegate ownership remains forbidden; common Cartesian/validator and final Task 2B-1 rereview pass. | Closed. |
| `record-wire-v1-remaining.md` | Reconciled: exact TypeRelation/method/VFT/reflection subrecords plus pointer-free Property storage witnesses, LayoutInputs, graph-closed/current-eligible resolver split with prospective local layout view, physical-decode precedence, and TS-SCR inventory. | Freeze field-order, comparator, hash, budget, malformed-presence, cold-hit call selection, and byte goldens after approval. |
| `type-layout-authority-v1.md` | Reconciled correction: pointer-free persisted property/layout-input evidence; linked stored authorities compare before a separate eligible current-layout resolver; selected-module types require no live lookup; exhaustive TS-SCR inventory and physical-decode/derived-hash precedence. | Obtain one fresh independent review of the combined authority. |
| `record-schema.md`, delta spec, design/plan/task traceability | Reconciled: ordered direct interfaces, independent methods/VFT, ordered UFunction membership including zero flags and StaticsClass globals, approved Delegate ownership, and the selected layout evidence/resolver/budget rules are explicit. | Keep strict OpenSpec validation green and obtain this matrix's independent re-review. |

This matrix is the normative correction source for those amendments. Shared
document reconciliation alone does not close the gate. The common Delegate
validator/tests/builds and ModuleState matrix are now approved; serializers/
deserializers and TypeSchema RED remain blocked until the layout correction is
reconciled and the resulting combined authority passes independent re-review.

### 3.10 Persisted layout evidence and separate current comparison

`type-layout-authority-v1.md` is co-normative and supplies the exact correction
for the previously unconsumable layout requirements. In summary:

- insert canonical `LayoutInputs:array<TypeLayoutInput>` after Relations for
  `BaseType`, UClass `CodeRoot`, and UStruct `StructHeader` numeric inputs;
- add `StorageKind`, `SemanticStorageSize`, `SemanticStorageAlignment`, and
  `StorageLayoutHash` to every PropertySchema immediately after Type;
- include all new fields in PropertyLayoutFingerprint, TypeLayoutHash, semantic
  payload, and RecordId;
- replay every offset and terminal AlignUp from persisted evidence without a
  live engine;
- compare a linked same-module Base/value TypeSchema as an independent stored
  authority and return GraphAbiMismatch on disagreement;
- permit a legal cross-module/environment target to remain a single persisted
  witness and compare it only during current eligibility; and
- add required non-global `IAngelscriptCacheCurrentLayoutResolver` calls only
  after immutable graph validation.

The complete field order, hash domains, presence matrix, API, error winners,
allocator families, and RED fixtures in that document are literal requirements,
not implementation notes or alternatives.

## 4. Exhaustive TypeKind payload and semantic-flag matrix

### 4.1 Flag predicate

The following table is exhaustive over the known eight bits. “Allowed” means
optional unless also required. Every known bit not listed under Required or
Allowed is forbidden.

| TypeKind | Required flags | Allowed flags | Forbidden flags | Kind payload |
|---|---|---|---|---|
| Class | `ReferenceType` | `Abstract`, `Final`, `Shared`, `Generated`, `HasDefaultConstructor`, `HasDestructor` | `ValueType` | none |
| Struct | `Final|ValueType` | `Shared`, `Generated`, `HasDefaultConstructor`, `HasDestructor` | `Abstract`, `ReferenceType` | none |
| Interface | `Abstract|ReferenceType` | `Shared` | `Final`, `Generated`, `HasDefaultConstructor`, `HasDestructor`, `ValueType` | none |
| Enum | `Final|ValueType` | `Shared` | `Abstract`, `Generated`, `HasDefaultConstructor`, `HasDestructor`, `ReferenceType` | Enum payload |
| Delegate | `Final|Generated|ValueType` | `HasDefaultConstructor`, `HasDestructor` | `Abstract`, `Shared`, `ReferenceType` | callable payload, `bMulticast` either value |
| Typedef | none | none | all eight flags | aliased primitive payload |
| Funcdef | `ReferenceType` | `Shared` | `Abstract`, `Final`, `Generated`, `HasDefaultConstructor`, `HasDestructor`, `ValueType` | callable payload, `bMulticast=false` |

Cross-bit rules:

1. `Abstract|Final` is always invalid.
2. `ValueType|ReferenceType` is always invalid.
3. Local validation can prove only the necessary direction for
   `HasDefaultConstructor`: a set flag requires at least one Construct row; for
   Class it also requires a Factory row and the locally visible Construct/Factory
   counts to match. A clear flag with one or more opaque Construct rows is locally
   admissible because TypeSchema stores no parameter/default signature. After
   declaration resolution, ModuleSnapshot graph proves the complete
   bidirectional rule: the flag is set iff exactly one Construct declaration has
   zero parameters, and Class also has its corresponding zero-parameter Factory.
4. `HasDestructor` is locally true iff the Destruct group has exactly one row;
   Destruct carries no parameter-based ambiguity.
5. `Shared` is accepted only for kinds shown above. A capture of a reused
   engine-global shared type whose ModuleKey/TypeKey owner cannot be proved is
   NotCacheable rather than reassigned to the current module.

**E:** class/struct/enum/funcdef raw maintained types support the listed
value/reference/shared shapes. Delegate is a generated struct. Typedef is a
primitive alias with no independent object flags.

**D — unique rule:** validation is the literal predicate above, not “best
effort” flag masking. Unknown bits return `UnknownFlags`; known but forbidden
or missing-required combinations return `InvalidQualifierCombination`.

**OQ:** `asCObjectType::IsInterface()` is currently non-functional in the
maintained fork even though builder code creates interface-shaped objects. The
wire matrix remains defined and locally testable, but live capture/restore of
Interface is NotCacheable until a dedicated live conformance test proves the
kind can be classified and recreated without guessing.

### 4.2 Kind-payload presence and local rules

| TypeKind | Enum payload | Callable payload | Typedef payload | Additional rule |
|---|---:|---:|---:|---|
| Class | forbidden | forbidden | forbidden | no payload bytes |
| Struct | forbidden | forbidden | forbidden | no payload bytes |
| Interface | forbidden | forbidden | forbidden | no payload bytes |
| Enum | required | forbidden | forbidden | at least zero enumerators; ordinals `0..N-1`; unique nonempty names; signed-int32 values; numeric aliases allowed |
| Delegate | forbidden | required | forbidden | one nonzero signature key/ABI; `bMulticast` is canonical bool |
| Typedef | forbidden | forbidden | required | alias is unqualified `CreatePrimitive`-compatible scalar; not Auto/Void/reference/handle/object |
| Funcdef | forbidden | required | forbidden | one nonzero signature key/ABI; `bMulticast=false` |

For Delegate/Funcdef, graph validation requires exactly one corresponding
`DelegateSignature` declaration, matching owner TypeKey and ABI. Enum metadata
is part of `EnumAuthorityHash`; Type metadata remains only in the common
Metadata field.

**D — unique rule:** wrong payload presence is `InvalidPresence`; true
`Funcdef.bMulticast` is `InvalidQualifierCombination`; a missing/zero signature
key or ABI uses the common `ZeroStableKey`/`MissingExpectedAbi` errors before
graph lookup.

**OQ:** none.

## 5. Exhaustive reflection matrix

### 5.1 Legal forms and class-reflection flags

Every `(TypeKind, ReflectionKind)` pair not listed is forbidden.

| Form | Required reflection flags | Allowed optional flags | Forbidden flags |
|---|---|---|---|
| Class + None | none | none | complete KnownMask |
| ordinary Class + UClass | parity rules below | `SuperIsCodeClass`, `Abstract`, `Transient`, `HideDropdown`, `DefaultToInstanced`, `EditInlineNew`, `Deprecated`, `Placeable` | `StaticsClass`, `IsStruct` |
| statics Class + UClass | `SuperIsCodeClass|StaticsClass` | `Placeable` | `Abstract`, `Transient`, `HideDropdown`, `DefaultToInstanced`, `EditInlineNew`, `Deprecated`, `IsStruct` |
| Struct + None | none | none | complete KnownMask |
| Struct + UStruct | `IsStruct` | none | every other known bit |
| Interface + None | none | none | complete KnownMask |
| Enum + None | none | none | complete KnownMask |
| Enum + UEnum | none | none | complete KnownMask |
| Delegate + UDelegate | none | none | complete KnownMask |
| Typedef + None | none | none | complete KnownMask |
| Funcdef + None | none | none | complete KnownMask |

Ordinary UClass parity rules:

- reflection `Abstract` is set iff TypeSemanticFlags contains `Abstract`;
- `SuperIsCodeClass` is set iff the ordinary UClass has no Base relation and
  directly declares an environment code super;
- `Placeable` and the remaining allowed class flags preserve the captured
  ClassDesc value; the cache layer does not normalize defaults.

Statics rules:

- TypeSemanticFlags contains `Generated|ReferenceType`;
- TypeSemanticFlags forbids `Abstract`, `Shared`, `HasDefaultConstructor`,
  `HasDestructor`, and `ValueType`; `Final` is the only additional optional
  semantic bit;
- it has zero properties, OrderedMethods, VirtualFunctionTable rows, and
  behavior slots, but one or more OrderedUFunctionMembers naming reflected
  module globals;
- `Placeable` is allowed because current `FAngelscriptClassDesc` defaults it to
  true; changing that product behavior is outside cache capture;
- it is reflection-only and therefore has no ShadowSuper relation.

**E:** these are the current product materialization entry points. Delegate is
always created as UDelegate; the previous “Delegate permits None” rule would
admit a form no product producer can create.

**D — unique rule:** the table is a closed allowlist. Wrong form or a known flag
outside its row returns `InvalidPresence`; abstract parity and statics
bidirectionality violations return `InvalidQualifierCombination`. Unknown bits
still win as `UnknownFlags`.

**OQ:** Interface reflection remains `None` even if a future UINTERFACE feature
is implemented; adding UClass/UStruct compatibility requires a schema revision,
not reinterpretation of V1.

### 5.2 ConfigName and StaticClassGlobalName

| Form | ConfigName | StaticClassGlobalName |
|---|---|---|
| ordinary Class + UClass | absent or present nonempty; absence means inherit resolved superclass config | required present nonempty |
| statics Class + UClass | forbidden | forbidden |
| every other legal form | forbidden | forbidden |

**D — unique rule:** an empty present string is `InvalidPresence`; strings are
strict UTF-8/no embedded NUL before presence semantics. The statics discriminator
is the `StaticsClass` flag in both directions.

**OQ:** none.

### 5.3 Reflected UFunction membership and order matrix

| Form | OrderedUFunctionMembers | Target entity/owner | Declaration ReflectionFlags |
|---|---:|---|---|
| ordinary Class + UClass | `0..N`, exact ClassDesc Methods order | local `Method`, Type-owned by enclosing TypeKey | any known valid mask, including exactly zero |
| statics Class + UClass | `1..N`, exact ClassDesc Methods order | local `GlobalFunction`, Module-owned by ModuleKey | any known valid mask, including exactly zero |
| every other legal form | exactly empty | forbidden | not applicable |

Every reflected target appears exactly once. The array may select a subset of
ordinary UClass OrderedMethods, but it never changes their VM order; a statics
target need not and cannot appear in a VM method array. A reflected ordinary
method remains subject to its normal method/VFT membership independently.

Graph validation resolves each row to its exact ModuleInterface declaration,
owner, entity kind, and ExpectedAbi. There is deliberately no inference from
`ReflectionFlags != 0`, metadata, function name, or declaration spelling.

**D — unique rule:** the array's explicit presence and ordinal are the
ClassGenerator authority. A self-consistent zero-mask row is positive evidence,
not malformed data. A statics UClass with no reflected member is
`InvalidPresence`, because no current product producer creates an empty
synthetic statics reflection container.

**OQ:** none.

## 6. Relation target/owner/ABI matrix

The enclosing TypeKey is the implicit relation owner and is never repeated in
a TypeRelation row.

### 6.1 Allowed cardinality and target form

| Enclosing form | Base | ShadowSuper | CodeSuper | ImplementedInterface | Compose |
|---|---|---|---|---|---|
| Class + None | `0..1 ScriptType(Class)` | forbidden | forbidden | `0..N ScriptType(Interface)` | forbidden |
| ordinary Class + UClass | `0..1 ScriptType(Class+UClass)` | exactly `1 EnvironmentSymbol(code class AS shadow type)` | exactly `1 EnvironmentSymbol(UClass code root)` | `0..N EnvironmentSymbol(UInterface)` | forbidden |
| statics Class + UClass | forbidden | forbidden | exactly `1 EnvironmentSymbol(UObject code super)` | forbidden | forbidden |
| Struct + None/UStruct | forbidden | forbidden | forbidden | forbidden | forbidden |
| Interface + None | forbidden | forbidden | forbidden | `0..N ScriptType(Interface)` | forbidden |
| Enum + None/UEnum | forbidden | forbidden | forbidden | forbidden | forbidden |
| Delegate + UDelegate | forbidden | forbidden | forbidden | forbidden | forbidden |
| Typedef + None | forbidden | forbidden | forbidden | forbidden | forbidden |
| Funcdef + None | forbidden | forbidden | forbidden | forbidden | forbidden |

For an ordinary UClass:

- ShadowSuper and CodeSuper identify the same code-root class and must have the
  same stable environment key and ABI.
- If Base is absent, `SuperIsCodeClass` is set.
- If Base is present, `SuperIsCodeClass` is clear; the Base target must be an
  ordinary UClass whose CodeSuper equals this row's CodeSuper.
- Base/implemented ScriptType references may target another module; target
  ownership is resolved from ModuleInterface and is not rewritten locally.

General relation rules:

1. Every target key is nonzero and every allowed target kind here is ABI
   bearing, so ExpectedAbi is nonzero.
2. A ScriptType target cannot equal the enclosing TypeKey.
3. ImplementedInterface rows contain only directly declared targets. Their
   SemanticOrdinal values equal stored position inside the relation-kind
   subsequence and are exactly `0..N-1`; targets are unique, but target order is
   never canonicalized by key or ABI.
4. The effective interface closure is derived base-first and first-visit
   deduplicated by the section 3.7 traversal. Closure entries do not create
   extra TypeRelation rows.
5. Each relation has exactly one matching `Inheritance` semantic dependency
   coordinate; no duplicate relation authority appears in ReflectionSchema.
6. Compose cardinality is exactly zero in valid V1, despite its reserved enum
   value.

**E:** pre-class data uses the code-root registered AS type as ShadowType and
the UE code root as CodeSuperClass. USTRUCT uses a fixed payload boundary but
no shadow type. Compose currently hard-errors.

**D — unique rule:** local validation checks relation-kind presence/cardinality,
the per-kind wire sections, required/forbidden SemanticOrdinal, direct-interface
ordinal continuity, reference structural validity, and the raw stored-coordinate
equality required by the LayoutInput pairing phase. Graph validation checks
resolved target category, whether that common stored coordinate resolves to the
actual same code-root class, owner module/type, linked ABI, and deterministic
closure. Live capture seeing Compose marks the module NotCacheable; an explicit
TypeSchema DTO or payload containing Compose is a disallowed relation kind and
returns `InvalidPresence` through the serializer/decoder contract below.

**OQ:** script interface runtime classification is not proven. Its relation
rows are wire-valid but live eligibility remains fail-closed as described in
section 4.1.

### 6.2 Relation validation and error mapping

| Failure | Error/stage |
|---|---|
| unknown relation enum | `UnknownEnumValue` / PayloadDecode |
| noncanonical row order | `NonCanonicalOrder` / LocalSemantic |
| repeated identical row | `DuplicateKey` / LocalSemantic |
| same singleton kind with different target | `ConflictingKey` / LocalSemantic |
| missing/extra SemanticOrdinal on a relation kind | `InvalidPresence` / LocalSemantic |
| direct-interface ordinal gap/duplicate | `OrdinalGap` or `DuplicateOrdinal` / LocalSemantic |
| disallowed relation kind/cardinality for enclosing form | `InvalidPresence` / LocalSemantic |
| zero key / missing required ABI / forbidden ABI | existing common reference error / LocalSemantic |
| individually valid LayoutInput target disagrees with its required Base or ShadowSuper/CodeSuper relation target over ReferenceKind/key/ABI | `InvalidQualifierCombination` / LocalSemantic at the offending LayoutInput enclosing-field offset |
| resolved target has wrong reference/entity/type/reflection category | `WrongReferenceKind` / ModuleGraph |
| target absent | `MissingGraphTarget` / ModuleGraph |
| owner/base/code-root relationship wrong | `MissingOwner` or `CrossModuleOwner` using common precedence, otherwise `InvalidPresence` / ModuleGraph |
| stored target ABI differs from linked graph declaration | `GraphAbiMismatch` / ModuleGraph |

## 7. Property schema and layout rules

### 7.1 Property owner and locality

| TypeKind/form | OrderedProperties |
|---|---|
| Class + None | local script properties allowed |
| ordinary Class + UClass | local script properties allowed |
| statics Class + UClass | exactly empty |
| Struct + None/UStruct | local script properties allowed |
| Delegate + UDelegate | generated local properties allowed |
| Interface, Enum, Typedef, Funcdef | exactly empty |

“Local” is defined by compiler ownership (`localProperties` / not inherited),
not by comparing names or source files. Derived TypeSchema never repeats a base
property. Each local row has stored position equal to `LayoutOrdinal`, and the
sequence is exactly `0..N-1`.

Every property row resolves to exactly one ModuleInterface Property declaration
with the same owner TypeKey, name, canonical type, access, flags, metadata, and
ABI-bearing property key authority. Delegate ownership uses the additive matrix
in section 3.5.

**D — unique rule:** any inherited row is `UnexpectedRecord`; missing or extra
local declaration coverage is `MissingCoverage`/`UnexpectedRecord` at graph
validation. Local array gaps/duplicates use `OrdinalGap`/`DuplicateOrdinal`.

### 7.2 Property semantic flags

The following implications are mandatory:

1. If `HasUnrealProperty` is clear, the complete property KnownMask is zero and
   ReplicationCondition is `None`.
2. If any other property flag is set, `HasUnrealProperty` is set.
3. `BlueprintWritable` implies `BlueprintReadable`.
4. `RepNotify` implies `Replicated` and one nonempty canonical metadata value
   for `ReplicatedUsing`.
5. A non-`None` ReplicationCondition implies `Replicated`.
6. If `Replicated` is clear, ReplicationCondition is `None`.
7. `SkipReplication` is incompatible with `Replicated`, `RepNotify`, and every
   non-None replication condition.
8. `NetGroup=16` is always forbidden in V1.

`PersistentInstance` and `InstancedReference` are independent known bits.
Current `Instanced` syntax sets PersistentInstance without requiring
InstancedReference, while DefaultComponent/OverrideComponent paths may set
InstancedReference separately. Either bit still requires HasUnrealProperty and
must pass the type-sensitive capability check below.

Reflection-specific allowlist:

| Owner form | Unreal-property rule |
|---|---|
| ordinary UClass | all known flags except `SkipReplication`; `Config` permitted |
| UStruct | all common editor/serialization flags plus `SkipReplication`; `Replicated`, `RepNotify`, and `Config` forbidden |
| Class/Struct + None | complete mask zero |
| Delegate + UDelegate | complete mask zero for generated VM wrapper members |
| statics UClass | no properties |

Type-sensitive flags (`InstancedReference`, `PersistentInstance`, `NoClear`,
`AssetRegistrySearchable`, `Config`) are validated after canonical property
type resolution. If the current type adapter cannot prove the corresponding UE
property capability, the snapshot is ineligible; it is never silently cleared.

**E:** the preprocessor distinguishes reflected and ordinary properties;
`ReplicatedUsing` supplies both Replicated/RepNotify and metadata, while
`NotReplicated` is struct-only.

**D — unique rule:** unknown bits return `UnknownFlags`; contradictory known
bits return `InvalidQualifierCombination`; a flag forbidden by owner/reflection
form returns `InvalidPresence`.

**OQ:** UE may add future lifetime conditions or property flags. They require an
append-only enum/flag schema revision; raw UE integer values are never accepted.

### 7.3 Exact layout invariants

Common arithmetic rules:

1. `V1ObjectInitialAlignment` is the schema constant `8`, matching the
   maintained `asCObjectType` constructor. It is not host `alignof` and is not a
   producer-selected value. A maintained fork with a different initial value
   requires a schema/CompatibilityKey revision before it can read or write V1.
2. For every VM object type (Class, Struct, Interface, Delegate, excluding the
   reflection-only StaticsClass), compute alignment as the maximum of `8`, all
   local property `SemanticStorageAlignment` values, resolved Base alignment
   when present, and CodeRoot shadow alignment for every ordinary UClass.
   Shadow alignment enters earlier when PreClassData creates the object type;
   `LayoutClass` later adds Base alignment through its derivedFrom branch. A
   UStruct header contributes no separate alignment because its PreClassData has
   no ShadowType. The result must equal stored `SemanticAlignment`, be a nonzero
   power of two, and be representable by maintained VM arithmetic.
3. The local layout cursor begins at `BasePropertyBoundary`.
4. For each property in ordinal order, consume its persisted and hash-bound
   `StorageKind`, `SemanticStorageSize`, and `SemanticStorageAlignment`;
   `SemanticByteOffset` equals `AlignUp(cursor, SemanticStorageAlignment)` using
   checked arithmetic; cursor becomes offset plus SemanticStorageSize.
5. After the last local property, `SemanticSize` equals checked
   `AlignUp(cursor, SemanticAlignment)`. This terminal tail alignment is
   mandatory even for an empty local-property suffix and is part of the exact
   maintained `LayoutClass` result.
6. `BasePropertyBoundary <= SemanticSize` and both are `<= INT32_MAX` for
   object-like maintained VM types.
7. Every property offset is `>= BasePropertyBoundary`; no property overlaps;
   zero-sized, unresolved, Auto, Void, or reference-qualified storage is
   NotCacheable.

Kind/form rules:

| Form | Size/alignment/boundary rule |
|---|---|
| Class + None | BaseType LayoutInput is required iff Base exists; boundary/alignment come from that input, otherwise boundary is zero |
| ordinary UClass without Base | exactly one CodeRoot LayoutInput has present code-super property boundary and shadow alignment |
| ordinary UClass with Base | BaseType has present boundary/alignment; CodeRoot remains required with boundary absent and shadow alignment present because PreClassData installs it before LayoutClass |
| statics UClass | normalized reflection-only layout `{size=0, alignment=1, boundary=0}` |
| Struct + None | boundary zero; common cursor follows |
| Struct + UStruct | exactly one StructHeader LayoutInput has present persisted `UASStruct::ScriptValueOffset` and absent alignment contribution because the header is boundary-only; one EnvironmentAbi dependency covers it |
| Interface | zero size, zero boundary, no properties; alignment is exact V1 object initial alignment `8` |
| Enum | exact maintained type layout `{size=1, alignment=1, boundary=0}` |
| Delegate | zero boundary; generated value-struct properties determine size/alignment |
| Typedef | size equals primitive alias bytes; alignment is exact `V1TypeInfoInitialAlignment=4`; boundary zero |
| Funcdef | live non-object descriptor layout `{size=0, alignment=4, boundary=0}`; Funcdef property storage is NotCacheable |

`TypeLayoutHash` covers the canonical LayoutInputs and exact offsets through the
corrected property fingerprints. Local validation replays the entire stored
layout without a live engine. Graph validation compares any linked same-module
Base/value TypeSchema as a second immutable authority; current comparison of a
legal external single witness is deferred to step 10 as specified by
`type-layout-authority-v1.md`.

**E:** these rules mirror maintained `LayoutClass` rather than C++ `sizeof`
assumptions. Enum's maintained type descriptor explicitly stores size/alignment
`1/1`; typedef stores primitive byte size; funcdef is a reference descriptor,
not an object instance layout.

**D — unique rule:** malformed power-of-two/range/boundary/cursor relationships
return `InvalidQualifierCombination`; checked overflow returns the existing
`Overflow`; mismatch of a stored fingerprint/hash returns
`DerivedHashMismatch`. Disagreement between two linked stored layout authorities
is `GraphAbiMismatch` before current resolver eligibility. A self-consistent
single cross-module/environment witness that differs from the current catalog
is `CurrentAbiMismatch`, not a fabricated stored-graph contradiction.

**OQ:** none. The V1 value `8` is an executable schema constant, not an
unresolved live default.

## 8. Public method-list and VFT matrices

### 8.1 Sequence presence by type form

| Type form | OrderedMethods | VirtualFunctionTable |
|---|---:|---:|
| Class + None | `0..N` local-prefix plus derived inherited suffix | `0..N` exact VFT |
| ordinary Class + UClass | `0..N` local-prefix plus derived inherited suffix | `0..N` exact VFT |
| statics Class + UClass | exactly empty | exactly empty |
| Struct + None/UStruct | `0..N` local only | exactly empty |
| Interface + None | `0..N` local-prefix plus derived inherited suffix | `0..N` exact VFT |
| Delegate + UDelegate | `0..N` generated local only | exactly empty |
| Enum/Typedef/Funcdef | exactly empty | exactly empty |

Each sequence independently has stored position equal to its ordinal and exact
ordinals `0..N-1`. There is no cross-array ordinal equality requirement.

### 8.2 Exact `asCObjectType::methods` order

| MethodEntry.EntryKind | DeclaringOwner / FunctionKey owner | Required position semantics |
|---|---|---|
| LocalMethod | enclosing TypeKey | part of the initial local prefix in exact maintained registration order |
| Inherited | strict resolved Base ancestor | part of the suffix appended in the resolved base OrderedMethods order |

`VirtualDeclaration` and `VirtualOverride` are forbidden MethodEntry kinds.
Every FunctionKey resolves to a `Method` or legal `InitDefaults` declaration;
constructors, destructors, factories, and DelegateSignature are forbidden.
ExpectedDeclarationAbi is nonzero and equals the resolved declaration ABI.

The exact derived-list reconstruction algorithm is:

1. Emit every local Method/InitDefaults in maintained registration order.
2. If there is a Base, traverse its OrderedMethods in ordinal order.
3. Skip a base system function (which is not persistable as ScriptFunction).
4. Skip a base row when one local declaration has the maintained
   signature/return/property equivalence that makes it an override.
5. Append every remaining base row unchanged as Inherited, preserving base
   order and original FunctionKey/owner/ABI.

No target-key sort, SlotKind grouping, or VFT order participates in this
algorithm. Struct and Delegate permit only the local prefix.

### 8.3 Exact `virtualFunctionTable` order

| VirtualFunctionSlot.SlotKind | DeclaringOwner | ImplementingOwner / FunctionKey owner | Required graph constraint |
|---|---|---|---|
| VirtualDeclaration | enclosing TypeKey | enclosing TypeKey | newly introduced local function appended after the cloned base table |
| VirtualOverride | strict ancestor/interface introduction owner | enclosing TypeKey | replaces the same inherited VftOrdinal; signature/ABI is override-compatible |
| Inherited | strict ancestor/interface introduction owner | resolved base implementation owner | identical FunctionKey/ABI remains at the cloned base VftOrdinal |

`LocalMethod` is forbidden in VirtualFunctionTable. For a type with Base, start
with the complete resolved base VFT. Replace exactly the slots overridden by
local functions, without moving them. Then visit local OrderedMethods in local
registration order and append each local function that did not receive an
inherited VFT ordinal. Every VftOrdinal is therefore exact and global only
inside this VFT sequence.

The introduction owner found by walking the Base/interface graph must equal
DeclaringOwner. An override may change FunctionKey and ImplementingOwner, but
not the inherited slot ABI. Every installed FunctionKey resolves to a
ScriptFunction declaration owned by ImplementingOwner with the stored nonzero
ExpectedDeclarationAbi.

### 8.4 Cross-sequence aliasing and errors

The same FunctionKey may legally appear in OrderedMethods, in one VFT slot, in
OrderedUFunctionMembers, and as BehaviorKind Copy. These are indices into
different maintained structures, not duplicate declarations. Inside one
OrderedMethods array or one VFT array, a second row carrying the same FunctionKey
at a distinct valid ordinal is always `DuplicateKey`; different owner or ABI bytes
do not create a second local coordinate and do not change that literal.

Required owner keys are validated as nonzero before role predicates. Invalid
locally visible self/nonself role shapes are `InvalidQualifierCombination`.
Actual declaration owner/module/entity/ABI, ancestor/interface membership,
inherited suffix reconstruction and VFT slot ownership remain graph validation.
Ordinal duplicates, gaps and exact-set row reorder return respectively
`DuplicateOrdinal`, `OrdinalGap` and `NonCanonicalOrder` before role and duplicate-
FunctionKey scans. Missing/wrong declarations use common owner precedence in
graph validation; method-list reconstruction disagreement or VFT ancestor/ABI
disagreement is `GraphAbiMismatch`.

**E:** `GetMethodByIndex` reads `methods`; virtual dispatch reads
`virtualFunctionTable`. The maintained builder constructs them with the two
different algorithms above.

**D — unique rule:** both exact arrays are serialized, hashed, validated, and
restored independently. Neither is a projection of the other.

**OQ:** maintained Interface live classification remains gated, but its two
stable sequence predicates are fully specified for pure record tests.

## 9. Behavior groups, targets, declarations, and cardinality

### 9.1 Allowed owner/cardinality matrix

`0..N` ordinals are contiguous inside one BehaviorKind group. `0..1` means a
singleton group whose only valid ordinal is zero. Empty is always encoded as no
row, never a zero key.

| BehaviorKind | Class | Struct | Delegate | Interface/Enum/Typedef/Funcdef |
|---|---:|---:|---:|---:|
| Construct | `0..N` | `0..N` | `0..N` | forbidden |
| ListConstruct | forbidden | `0..1` | `0..1` | forbidden |
| Destruct | `0..1` | `0..1` | `0..1` | forbidden |
| Factory | `0..N` | forbidden | forbidden | forbidden |
| ListFactory | `0..1` | forbidden | forbidden | forbidden |
| AddRef | `0..1` | forbidden | forbidden | forbidden |
| Release | `0..1` | forbidden | forbidden | forbidden |
| GetWeakRefFlag | `0..1` | forbidden | forbidden | forbidden |
| TemplateCallback | forbidden | forbidden | forbidden | forbidden |
| GetRefCount | `0..1` | forbidden | forbidden | forbidden |
| SetGcFlag | `0..1` | forbidden | forbidden | forbidden |
| GetGcFlag | `0..1` | forbidden | forbidden | forbidden |
| EnumRefs | `0..1` | forbidden | forbidden | forbidden |
| ReleaseRefs | `0..1` | forbidden | forbidden | forbidden |
| Copy | `0..1` | `0..1` | `0..1` | forbidden |
| CopyConstruct | forbidden | `0..1` | `0..1` | forbidden |
| CopyFactory | `0..1` | forbidden | forbidden | forbidden |

Statics Class is an exception to the Class column: every group is empty because
it has no VM object type. Abstract ordinary Class still records captured
constructor/factory groups; call-time instantiability is a separate semantic.

`TemplateCallback` is reserved but forbidden because V1 has no local template
TypeKind or template-parameter shape. A producer encountering a local type with
that behavior is NotCacheable.

### 9.2 Target reference and declaration matrix

| BehaviorKind | ScriptFunction target entity | EnvironmentSymbol target | Owner optional |
|---|---|---:|---|
| Construct | `Constructor` or `GeneratedDefaultConstructor` | forbidden | required for script |
| ListConstruct | `Constructor` | forbidden | required for script |
| Destruct | `Destructor` (Generated trait distinguishes generated form) | allowed | required only for script |
| Factory | `Factory` | forbidden | required for script |
| ListFactory | `Factory` | forbidden | required for script |
| Copy | `Method` (`opAssign` semantic) | allowed | required only for script |
| CopyConstruct | `Constructor` | allowed | required only for script |
| CopyFactory | `Factory` | allowed | required only for script |
| AddRef/Release/GetWeakRefFlag | `Method` | allowed | required only for script |
| GetRefCount/SetGcFlag/GetGcFlag/EnumRefs/ReleaseRefs | `Method` | allowed | required only for script |
| TemplateCallback | none in valid V1 | none in valid V1 | absent |

Local validation of a ScriptFunction target requires only owner-present/nonzero;
self and nonself nonzero owners are both locally admissible. EnvironmentSymbol
requires owner-absent. ModuleSnapshot graph resolves the exact declaration or
compatibility-selected engine behavior coordinate, actual owner/module/entity and
ABI; it never accepts merely a function with an equal declaration string.

### 9.3 Constructor/factory ordering and alias rules

1. Construct ordinals are the exact `beh.constructors` order.
2. Factory ordinals are the exact `beh.factories` order.
3. For Class, local TypeSchema validation proves only equal Construct and Factory
   counts. After resolving declarations, graph row `i` proves identical parameter
   canonical types, in/out modes and defaults; Construct returns void with owner
   object semantics, while Factory returns the owning Class handle.
4. For Struct/Delegate, Factory is empty.
5. The legacy singleton `beh.construct` is not another wire row. Graph validation
   derives it as the unique zero-parameter Construct declaration, or zero if none;
   TypeSchema local validation cannot identify it by key, name or ordinal.
6. The legacy singleton `beh.factory` is graph-derived as the corresponding
   unique zero-parameter Factory declaration, or zero if none.
7. Graph validation proves `HasDefaultConstructor` equals presence of that unique
   zero-parameter Construct declaration; for Class the corresponding
   zero-parameter Factory is also required. Local validation owns only the
   necessary flag-set/group-presence and Class count conditions in section 4.1.
8. A script-owned CopyConstruct, when present, repeats the exact
   `{ScriptFunction key, ExpectedAbi, DeclaringOwner}` of one Construct row. A
   script-owned CopyFactory analogously repeats one Factory row. These script
   alias rows do not create another Function declaration.
9. An EnvironmentSymbol CopyConstruct or CopyFactory is an independent
   compatibility-selected singleton coordinate. It cannot alias a
   ScriptFunction row or be required to appear in the script-only
   Construct/Factory groups; its exact environment key/ABI and EnvironmentAbi
   dependency are the complete authority.
10. Copy, when script-owned, points to exactly one compatible `opAssign` Method
   declaration and may also appear in OrderedMethods and VirtualFunctionTable;
   compatibility is graph-owned.
11. Destruct cardinality equals the `HasDestructor` flag locally as specified
   earlier.

**E:** maintained storage has both overload arrays and selected singleton
fields. The singleton default construct/factory coordinates are array aliases.
Copy coordinates are independent fields otherwise invisible to public
enumeration; a script-owned copy coordinate may name an existing script
constructor/factory, while an engine-owned coordinate has no FunctionKey to
alias.

**D — unique rule:** Behavior arrays remain grouped by ascending BehaviorKind;
within each group ordinals are `0..N-1`. This grouping is correct for behavior
families and deliberately differs from both exact OrderedMethods order and
exact VFT order.

**OQ:** script copy aliases are uncommon in current generated code. The split
script-alias/environment-singleton rule remains explicit and RED-tested so
neither form can be silently coerced into the other.

## 10. Dependencies and single-authority rules

TypeSchema.Dependencies is a canonical set and may not duplicate payload
tables. At minimum:

- each relation has one dependency with an identical target, selected by the
  stored target domain: a `ScriptType` target uses `Inheritance`, while an
  `EnvironmentSymbol` target uses `EnvironmentAbi`;
- each ScriptType/EnvironmentType reference recursively present in a property
  CanonicalDataType has one `ValueLayout` dependency with an identical target;
  primitive leaves add none;
- each distinct script function targeted by OrderedMethods,
  VirtualFunctionTable, OrderedUFunctionMembers, or script-owned behavior has
  one `Declaration` dependency regardless of how many of those sequences index
  it; callable-payload signature targets use `Signature` instead;
- each EnvironmentSymbol behavior has one `EnvironmentAbi` dependency;
- UStruct's `UASStruct::ScriptValueOffset` basis has one `EnvironmentAbi`
  dependency;
- Delegate callable signature has one `Signature` dependency.

`PropertyLayout` is not emitted merely because a property is declared in its
own TypeSchema. It is used by a consumer record that embeds/depends on a
resolved property offset; TypeSchema itself owns that offset and fingerprint.

The list above is also the complete set of dependency kinds that a TypeSchema may
derive: `Inheritance`, `ValueLayout`, `Declaration`, `Signature`, and
`EnvironmentAbi`. `PropertyLayout`, `DefaultExpression`, `GlobalValue`,
`GlobalInitializer`, `GlobalStorage`, `HardValue`, `Initializer`, `CompileOption`
and any later common dependency kind belong to their consuming records. If present
in TypeSchema they are extra DTO-derived coverage and return
`UnexpectedRecord/LocalSemantic`; they are never used as locally valid TS-SCR-11
Required allocation fixtures or deferred to graph validation.

No dependency can replace exact member/slot presence, and no member/slot can
omit its dependency. Equal coordinates are duplicates; equal semantic owner
coordinates with unequal ABI/content are conflicts.

**D — unique rule:** the Dependencies field-local pass validates row/reference
shape, canonical set order and duplicate/conflict structure. After every field-
local check and the earlier reflection/alias/flag/relation-input closures, local
cross-field validation derives the exact Dependency set from the TypeSchema DTO
itself. A missing derived row is `MissingCoverage/LocalSemantic`; an extra row is
`UnexpectedRecord/LocalSemantic`. ModuleSnapshot graph does not repeat that set-
equality rule: it resolves each locally exact target's existence, entity/category,
actual owner/module and stored declaration ABI, where disagreement is the common
graph owner/reference error or `GraphAbiMismatch`. Separate ModuleInterface versus
snapshot record/declaration coverage also remains graph-owned.

**OQ:** none. Recursive CanonicalDataType traversal uses the already-frozen
Task 2B-1 field order and adds no new dependency enum.

## 11. Deterministic validation and error priority

### 11.1 Local TypeSchema order

The first failure wins. Within one TypeSchema payload, validation proceeds in
these exact phases:

1. Physically decode every field recursively: scalar width/version, enum
   values, booleans, optional tags, UTF-8, NUL, array bounds, and cumulative
   budget. Errors are the existing malformed or resource errors at the
   offending field.
2. Immediately require trailing-data exhaustion at the first extra byte. This
   completes PayloadDecode before any canonical semantic or derived-hash rule.
3. Run one field-local pass in exact top-level wire order. No earlier field may
   inspect a later top-level field to choose its error. Rules selected by the
   later Reflection discriminator are deliberately deferred:
   - validate version, ModuleKey, TypeKey, TypeKind, namespace, name,
     declaration, and TypeSemanticFlags;
   - validate Metadata canonical order/duplicates;
   - validate Relations stable references, raw kind sections, duplicate/conflict,
     SemanticOrdinal rules and direct-interface order; apply only TypeKind-local
     presence rules here and defer Reflection-selected cardinality/form;
   - validate LayoutInputs ordering, role/targets and duplicates and recompute each
     LayoutInputHash in stored order; defer Reflection-selected presence/form;
   - validate Layout scalar ranges/presence, but defer TypeLayoutHash;
   - validate OrderedProperties in LayoutOrdinal order: each row's stable/type/
     flag/storage semantics, then StorageLayoutHash, then
     PropertyLayoutFingerprint. Only scalar offset shape is local here; complete
     cursor replay is deferred;
   - validate OrderedMethods, then VirtualFunctionTable, then grouped
     OrderedBehaviorSlots. Validate form-independent raw/scalar/reference,
     ordinal/order, role and duplicate rules here; apply TypeKind-only presence
     rules but defer every Reflection-selected presence/cardinality rule;
   - validate the TypeKind-selected KindPayload and recompute
     EnumAuthorityHash when present;
   - validate Reflection raw enums/unknown flags and intrinsic member-row
     structure/order, while deferring the TypeKind+Reflection closed-form
     allowlist, known form flags, optional-string presence and form-selected
     member cardinality; and
   - validate Dependencies canonical order, stable references, and duplicates.
4. After all field-local checks pass, run cross-field rules in this exact order:
   - `ReflectionFormClosure`: derive exactly one legal form from TypeKind plus the
     validated Reflection discriminator, then apply form-dependent semantic flags,
     Relations, LayoutInputs, Layout expectation, Properties, Methods, VFT,
     Behaviors (including Class Construct/Factory count) and Reflection
     membership/string rules in that top-level order;
   - script CopyConstruct/CopyFactory exact local alias tuples;
   - HasDefaultConstructor necessary conditions and complete HasDestructor
     flag/row parity;
   - relation-to-LayoutInput exact pairing;
   - locally derivable dependency coverage; and
   - complete Base/header/property cursor, aggregate alignment, exact offset and
     terminal-size replay.
5. Recompute TypeLayoutHash last, after every value it covers and every earlier
   derived hash is valid.
6. Publish the decoded DTO only after all checks succeed.

The unique derived-hash order is LayoutInputHash rows; for each property,
StorageLayoutHash then PropertyLayoutFingerprint; EnumAuthorityHash;
TypeLayoutHash last. TypeLayoutHash's physical position in `Layout` does not
move it before properties, KindPayload, Reflection, or Dependencies. A later-
field local error wins over an earlier-field cross-field contradiction; paired
tests assert the winner's captured enclosing-field ByteOffset.

This local ordering refines, but does not override, the already-frozen global
order: complete physical payload decode including trailing-data precedes local
canonical/derived failures, and all local failures precede graph lookup.

### 11.2 Exact array phases and closure diagnostics

Raw Method/VFT/Behavior enum values outside their closed domains are
`UnknownEnumValue` during decoder PayloadDecode; the normal producer performs a
DTO-domain preflight over the same fields in wire order before canonical-local
validation. Each array then uses these phases:

1. In stored-row/subfield order validate active keys and ABIs. Method/VFT owner
   keys are required and active. For Behavior, validate Target key/ABI and, only
   when Target is ScriptFunction and DeclaringOwner is present, validate that
   active owner value as nonzero. Do not reject a missing Script owner or inspect
   any Environment owner value yet.
2. Scan ordinal domains: duplicate wins `DuplicateOrdinal`; otherwise a set not
   exactly `0..N-1` is `OrdinalGap`; otherwise an exact set stored out of ordinal
   position is `NonCanonicalOrder`. After all Behavior subgroups pass, wrong
   ascending BehaviorKind group order is `NonCanonicalOrder`.
3. Validate Method/VFT roles and locally visible self/nonself shapes. For Behavior,
   validate the allowed target arm and then the optional tag: Script absent or
   Environment present is `InvalidPresence`; an Environment present value is
   inactive and is never interpreted.
4. Scan duplicate Method/VFT FunctionKeys, then enter the cross-field phases in
   section 11.1.

Thus a Script owner present-zero wins `ZeroStableKey` before a later ordinal
fault. Missing Script owner and Environment owner present (zero or nonzero) lose
to duplicate/gap/order and then return `InvalidPresence`. Duplicate ordinal wins
gap/order; gap wins order; order wins role/duplicate-key/alias. A later
Dependencies field-local failure wins every reflection-form, alias or flag
closure.

Cross-field failures use only the append-only public captured coordinates below;
every unused index is `MAX_uint32`:

| Failure | Decoder captured coordinate |
|---|---|
| form-dependent semantic-flag contradiction | `TypeSemanticFlags` |
| present forbidden Relation | `Relation` at the lowest proving physical array index |
| required `(TypeKind,ReflectionKind)` Relation absent | `Reflection` |
| present forbidden LayoutInput | `LayoutInput` at the lowest proving physical array index |
| required `(TypeKind,ReflectionKind)` LayoutInput absent | `Reflection` |
| form-dependent size/alignment/boundary mismatch | `LayoutExpectation` |
| forbidden property/Method/VFT/Behavior row | respectively `OrderedProperty`, `OrderedMethod`, `VirtualFunctionSlot` or `BehaviorSlot` at the lowest proving physical array index |
| forbidden reflected member | `ReflectedFunctionMember` at the lowest proving physical array index |
| required statics reflected member absent | `Reflection` |
| illegal TypeKind+Reflection pair, known form flags, ConfigName or StaticClassGlobalName presence/value | `Reflection` |
| Class Construct/Factory count mismatch | `BehaviorSlot` at the first unmatched physical row: Construct ordinal `FactoryCount` or Factory ordinal `ConstructCount` |
| HasDefaultConstructor set with no Construct, or HasDestructor set with no Destruct | `TypeSemanticFlags` |
| HasDestructor clear with Destruct present | `BehaviorSlot` at the physical Destruct-ordinal-zero row |
| script CopyConstruct/CopyFactory alias mismatch | `BehaviorSlot` at the physical Copy row |

When a form-selected required row is absent there is no row offset; `Reflection`
is the unique captured discriminator fallback. This covers ordinary UClass
ShadowSuper/CodeSuper/CodeRoot, UStruct StructHeader, statics CodeSuper/member and
all other legal forms. A Base-relation-driven missing BaseType input instead uses
the existing requiring `Relation` row during relation/LayoutInput pairing; an
extra present input uses its `LayoutInput` row.

A second singleton Relation or LayoutInput authority coordinate never reaches
`ReflectionFormClosure`: the field-local canonical pass returns `DuplicateKey` or
`ConflictingKey` at the second matching physical row. This incorporates the
accepted Minor from the Slice-5 authority-proposal review.

For locally derived Dependency set equality, a missing row has no public indexed
coordinate; the decoder reports `MissingCoverage/LocalSemantic` at the physical
Dependencies array-count/enclosing-field error offset already retained by its
decode trace and does not invent a captured field. An extra row reports
`UnexpectedRecord/LocalSemantic` at its indexed `Dependency` physical row. A
duplicate/conflicting coordinate has already failed in the earlier field-local
canonical pass.

### 11.3 Graph order for TypeSchema

Inside the normative ModuleSnapshot graph steps:

1. Resolve enclosing Type declaration and common owner precedence.
2. Check exact TypeSchema coverage and TypeKind/name/declaration equality.
3. Resolve relations/base/code-root/ordered direct interfaces and their ABI;
   derive and verify the base-first interface closure.
4. Resolve local Property declarations and exact coverage.
5. Resolve and reconstruct exact OrderedMethods declarations/owners/order/ABI.
6. Resolve and reconstruct exact VirtualFunctionTable
   declarations/owners/ancestor slots/order/ABI.
7. Resolve behavior targets/owners/entities/ABI; prove Class Construct/Factory
   parameter/default/return agreement, compatible script Copy/opAssign, and the
   unique zero-parameter Construct plus corresponding Class Factory used for
   complete `HasDefaultConstructor` parity.
8. Resolve reflected UFunction members, including zero-reflection-flag and
   StaticsClass global rows, then resolve every already locally exact Dependency
   target's graph existence/entity/owner/module/ABI without re-deriving the local
   set.
9. Recheck every LayoutInput/property storage coordinate against any linked
   same-module Base or inline-value TypeSchema authority, validate the value-
   layout/Base DAG, and prove stored layout/dependency self-consistency. Legal
   cross-module/environment targets need not have a child TypeSchema and are
   not resolved from the current engine in this step.
10. Resolve Delegate/Funcdef signature and Enum authority.
11. Only after the stored graph is self-consistent may current eligibility run.
    Selected-module Script* dependencies, BaseType inputs, InlineValue
    ScriptType storage, primitive storage, and every ObjectHandle slot are
    graph/profile closed and produce zero current resolver calls. External
    Script* and EnvironmentSymbol dependencies remain eligible current-symbol
    calls. Cross-module BaseType, CodeRoot, StructHeader, external InlineValue
    ScriptType, and InlineValue EnvironmentType remain eligible
    `CurrentLayouts` calls. The validator supplies an allocation-free read-only
    prospective view over validated local TypeSchemas so an environment recipe
    nested over a local value type can resolve before that live type exists.
    Layout-input lookup is memoized by
    `{InputKind,ReferenceKind,StableKey}` and returns raw role coordinates; each
    consuming TypeSchema applies its already-validated stored optional-presence
    mask before comparison/hash recomputation. An unconsumed CodeRoot boundary
    therefore cannot invalidate a script-derived UClass. Failures produce
    `CurrentAbiMismatch`, `CurrentContentMismatch`, or `CurrentSymbolMissing`.

**D — unique rule:** stored graph contradictions never degrade to a normal
cache miss. `GraphAbiMismatch` wins over current-environment errors.

## 12. Exhaustive RED test matrix

All tests below are pure in-memory Task 2B-2 tests. They do not construct a
live AS engine or UObject. Each mutation starts from a complete valid fixture,
uses a sentinel output, expects the exact error/stage/field offset, and proves
the output is empty after failure.

### 12.1 Enum and bitset exhaustion

| RED group | Exhaustive rows | Expected result |
|---|---|---|
| TypeKind | raw `0`, `1..7`, `8`, `0xff` | only `1..7` decode; others `UnknownEnumValue` |
| RelationKind | raw `0`, `1..5`, `6`, `0xff` | only `1..5`; others `UnknownEnumValue` |
| MemberAccess | raw `0`, `1..3`, `4`, `0xff` | only `1..3`; others `UnknownEnumValue` |
| MethodSlotKind | raw `0`, `1..4`, `5`, `0xff` | only `1..4`; others `UnknownEnumValue` |
| BehaviorKind | raw `0`, `1..17`, `18`, `0xff` | only `1..17`; others `UnknownEnumValue`; prove exact `15/16/17` |
| ReflectionKind | raw `0`, `1..5`, `6`, `0xff` | only `1..5`; others `UnknownEnumValue` |
| Type semantic masks | for each of 7 TypeKinds, iterate all `0..0xff` masks plus one case for each high unknown bit | validity equals the literal section 4 predicate; high bit is `UnknownFlags`, known invalid is `InvalidQualifierCombination` |
| Class reflection masks | for each legal reflection form, iterate all `0..0x3ff` masks plus each high unknown bit | validity equals section 5 predicate; unknown wins over form semantics |
| Property masks | iterate all `0..0x7ffff` masks under each property owner form, with canonical replication fixtures | validity equals section 7.2 implications/allowlist |
| ReplicationCondition | raw `0..16`, `17`, `0xff` under replicated/nonreplicated/struct/class owners | exact allowed matrix; NetGroup invalid; unknown values fail enum decode |

### 12.2 Seven TypeKind positive/gap rows

| Fixture | Positive evidence | Required negative mutations |
|---|---|---|
| Class.None | reference class, one local property, exact local+inherited methods and VFT, constructor/factory, copy | remove ReferenceType; add ValueType; conflate method/VFT order; add reflection flag; wrong payload; forbidden relation |
| Class.UClass ordinary | code-root relations, ordered direct interfaces, reflected local property, StaticClassGlobalName, one zero-ReflectionFlags NotBlueprintCallable UFunction row | remove Shadow/Code; mismatch code roots; swap direct targets while retaining old ordinal/hash; flip SuperIsCode parity; remove static-global name; set StaticsClass; omit or reorder the zero-mask UFunction row without matching ordinal/hash |
| Class.UClass statics | generated reflection-only UClass with ordered reflected module globals including a zero-ReflectionFlags row | add property/OrderedMethod/VFT/behavior; add Base/Shadow; remove Code; allow Config/static name; add forbidden reflection flag; omit/reorder without matching ordinal/hash or add wrong-owner UFunction member; empty reflected list |
| Struct.None | value/final, local OrderedMethods, empty VFT, local property/construct/copyconstruct | remove Final/Value; add VFT/Factory; add Base; add UClass reflection |
| Struct.UStruct | value/final, UASStruct boundary, IsStruct | boundary/env ABI mismatch; clear IsStruct; add other class flag; add replicated property |
| Interface.None | abstract/reference, independent exact methods/VFT, ordered direct parent interfaces | remove Abstract/Reference; conflate methods/VFT; add Final/constructor/property; any reflection other than None |
| Enum.None/UEnum | final/value, ordered signed-int32 values | duplicate name, ordinal gap, out-of-range capture, metadata/hash mismatch, any member slot |
| Delegate.UDelegate | generated/final/value, `_Inner`, generated local OrderedMethods/construct/copy under amended common owner contract, empty VFT | add ReferenceType; clear Generated/Final/Value; Reflection None; non-generated member; VFT/Factory; signature owner mismatch; run against unamended common owner validator |
| Typedef.None | zero flags, primitive alias | any flag; object/handle/ref/Auto/Void alias; any relation/member; any reflection other than None |
| Funcdef.None | reference and optional Shared, signature, multicast false | missing Reference; add value/ctor; multicast true; any member; any reflection other than None |

Although there are eleven reflection-form fixtures, they exhaust the seven
TypeKinds rather than treating “ordinary/statics/reflected/plain” as new kinds.

### 12.3 Relation Cartesian rows

Generate one row for every:

```text
11 legal reflection forms
x 5 RelationKind values
x {absent, one, two}
x {ScriptType, EnvironmentSymbol, wrong ReferenceKind}
```

Assert the section 6 table exactly. Add focused rows for self-reference,
duplicate identical interface, conflicting singleton, noncanonical
relation-kind section order, missing/extra ImplementedInterface
SemanticOrdinal,
first/middle/last interface ordinal gap/duplicate, missing ExpectedAbi, Base
target wrong TypeKind, UClass Base code-root mismatch, Shadow/Code unequal key,
and statics Shadow presence. Add two otherwise-equal fixtures whose direct
interface targets are reversed: both are valid only with matching `0..N-1`
ordinals, produce different TypeLayoutHash values, and restore the respective
order. Add diamond closure fixtures proving direct-only storage, base-first
recursive traversal, and first-visit deduplication. For each graph row, pair a
simultaneous current-resolver mismatch and prove the graph error wins.

### 12.4 Property and layout rows

Required RED mutations:

1. property array position differs from LayoutOrdinal;
2. first/middle/last ordinal gap and duplicate;
3. inherited property inserted in derived local list;
4. Property key owner/name/type/access/flags/metadata mismatch;
5. offset below BasePropertyBoundary;
6. offset not aligned;
7. offset overlaps previous property;
8. offset is aligned but differs from exact AlignUp cursor;
9. property end or terminal AlignUp overflows u32/int32 or SemanticSize and
   returns existing `Overflow`;
10. SemanticAlignment zero, non-power-of-two, below property/base/shadow
    alignment, below exact initial `8`, or unequal to the exact maximum; UStruct
    header has no alignment contribution to compare;
11. BasePropertyBoundary above size or inconsistent with Base/code/UStruct;
12. terminal SemanticSize differs from
    `AlignUp(final cursor, SemanticAlignment)`, including a fixture where cursor
    itself is valid but unaligned and the stored size omits mandatory tail pad;
13. individual property fingerprint mismatch;
14. TypeLayoutHash mismatch after otherwise self-consistent mutation;
15. property present on each forbidden TypeKind/form;
16. every implication/forbidden owner row from section 7.2;
17. resolved property type ABI/layout mismatch;
18. same terminal size with two different stored per-property offsets, proving
    offset participates in fingerprint/hash;
19. empty Class, Struct, Interface, and Delegate fixtures proving alignment `8`
    and the applicable aligned zero/base boundary result without live-engine
    inference.
20. every StorageKind x CanonicalDataType/qualifier legal and illegal row;
21. zero/non-power-of-two/above-int32 storage size/alignment, and independent
    StorageLayoutHash mismatch;
22. BaseType, CodeRoot, and StructHeader LayoutInput positive rows plus every
    missing/extra/wrong-target/wrong-role/hash mutation; include a present-zero
    Base boundary that remains distinct from an absent Base input;
23. ordinary UClass roots consume present CodeRoot boundary/shadow alignment,
    while a script-derived ordinary UClass requires absent CodeRoot boundary,
    present CodeRoot shadow alignment, and present Base boundary/alignment;
24. reflected UStruct consumes ScriptValueOffset as a present boundary-only
    input with absent AlignmentContribution;
25. linked same-module Base/inline-value layout disagreement is
    GraphAbiMismatch even when current resolution also fails;
26. cross-module Base, EnvironmentType property, code root, and struct header
    whose persisted witness is self-consistent but current equal/missing/
    different, proving current-only eligibility classification; and
27. a fixture resolver call-order/at-most-once matrix that creates no AS engine
    or UObject, including one raw CodeRoot result reused by root and script-
    derived consumers with different stored boundary-presence masks;
28. a cold exact-hit fixture whose current resolvers deliberately contain no
    selected-module Script* entries, proving same-module dependencies, Base,
    InlineValue properties, primitives, and ObjectHandles succeed with zero
    local `CurrentSymbols`/`CurrentLayouts` calls;
29. a selected-module declaration requiring TypeSchema but missing its child,
    proving immutable `MissingCoverage`/`MissingGraphTarget` rather than fallback
    to an external current lookup;
30. an EnvironmentType template nested over a selected-module InlineValue
    ScriptType, proving its pre-materialization recipe reads the prospective
    view and makes only the one outer eligible layout call; and
31. ordered external/environment controls proving skipped local coordinates do
    not enter memos while each eligible exact coordinate is called at most once;
    and
32. the exact engine-free V1 build-layout table for every Primitive and
    ObjectHandle route, including current AS bool/pointer/int64/double ABI,
    mismatch before eligible layout calls, and canonical-input coverage required
    from the first production CompatibilityKey assembler.

### 12.5 Independent public-method and VFT rows

Required RED mutations and positive controls:

1. first/middle/last OrderedMethods ordinal gap, duplicate, and out-of-order;
2. first/middle/last VirtualFunctionTable ordinal gap, duplicate, and
   out-of-order, independently of OrderedMethods;
3. all four raw MethodSlotKind values in both array roles on every TypeKind/form,
   proving only `{LocalMethod,Inherited}` are legal MethodEntry values and only
   `{VirtualDeclaration,VirtualOverride,Inherited}` are legal VFT values;
4. an exact derived fixture whose base has two methods and whose local prefix
   contains a new method plus an override: OrderedMethods is local registration
   order followed by the one non-overridden base row, while VFT is cloned base
   order with replacement followed by the new method;
5. variants that sort either array by kind/key, copy VFT order into
   OrderedMethods, or copy method order into VFT; each must fail exact
   reconstruction despite containing the same FunctionKeys;
6. an inherited method appended despite a matching local override, an
   unoverridden base method omitted, or a base suffix appended in any order
   other than resolved base OrderedMethods order;
7. LocalMethod with non-self owner, Inherited MethodEntry with self owner or
   changed FunctionKey/ABI, and forbidden VirtualDeclaration/Override in the
   method array;
8. VirtualDeclaration with non-self owner, VirtualOverride with self
   DeclaringOwner or non-self ImplementingOwner, Inherited VFT with changed
   installed FunctionKey, and forbidden LocalMethod in the VFT;
9. ancestor VFT slot absent/different ordinal and declaration ABI mismatch
   among row, implementation, and ancestor;
10. constructor/destructor/factory/signature used in either method sequence,
    plus legal Method/InitDefaults positive rows;
11. repeated FunctionKey inside one Method/VFT array as `DuplicateKey` even when
    owner/ABI bytes differ; the same opAssign key in OrderedMethods+VFT+Copy and
    the same reflected method in OrderedMethods+VFT+OrderedUFunctionMembers as
    positive rows, plus duplicates within each individual sequence as negative
    rows;
12. StaticsClass with empty VM arrays plus ordered reflected globals as a
    positive row, and any statics VM method/VFT member as negative;
13. byte goldens from the new-method+override+inherited fixture proving exact
    cold-capture and warm-reconstruction equality separately for every
    `GetMethodByIndex(i)` result and every `virtualFunctionTable[i]` result.

### 12.6 Behavior 17-kind represented-coordinate rows

Absence carries no BehaviorKind, target, owner or function-entity coordinate.
Test the empty Behavior array once per actual legal type/reflection form,
including StaticsClass. Do not multiply an empty DTO by hypothetical values.

For nonempty rows generate only represented combinations:

```text
17 BehaviorKind values
x 7 TypeKind values
x {one, two}
x {ScriptFunction, EnvironmentSymbol}
x {owner absent, self, other local type, other module}
x all relevant function entity kinds
```

This is one logical matrix with two mandatory validation stages; it is not one
local-decoder loop and it SHALL NOT create a second declaration authority in
TypeSchema:

1. the TypeSchema local-decode RED partitions the represented
   `{BehaviorKind, TypeKind, cardinality, ReferenceKind, owner presence/value}`
   product and decides only wire shape, local grouping/ordinal, type-form,
   owner-presence/nonzero, flag, count, and local alias rules. It must use
   explicit literal expectations, not a dynamic expected-validity predicate; and
2. the ModuleSnapshot graph RED crosses every locally admitted row with all
   relevant ModuleInterface function entity kinds, exact owner, target
   existence, and ExpectedAbi outcomes. Missing target, wrong entity, wrong
   owner, and ABI drift are graph failures and SHALL NOT be guessed or rejected
   by the local TypeSchema decoder.

The two test families together must cover every represented cell. Self and
nonself nonzero Script owners are local positives pending graph resolution. A
generic graph smoke test cannot replace the entity-kind cross product, and a
local test cannot use
function names, declaration spelling, metadata, or a test-only lookup table to
pretend that it resolved ModuleInterface authority.

The expected validity predicate is exactly sections 9.1 and 9.2. Add focused
rows for:

- per-kind ordinal gap/duplicate and BehaviorKind group disorder;
- local Class constructor/factory count/ordinal mismatch, plus graph-only
  parameter/default/return mismatch;
- Struct/Delegate Factory presence;
- graph-resolved zero, one, and two zero-parameter constructors;
- local HasDefaultConstructor necessary conditions, graph-complete default-
  constructor bidirectionality, and local HasDestructor both directions;
- script-owned CopyConstruct not exactly aliased to a Construct row;
- script-owned CopyFactory not exactly aliased to a Factory row;
- EnvironmentSymbol CopyConstruct/CopyFactory positive rows that have no
  script FunctionKey alias, plus negative rows that try to satisfy or compare
  them through a Construct/Factory ScriptFunction key;
- Copy not resolving to a compatible Method/opAssign declaration;
- environment target with owner present, script target with owner absent;
- missing ABI, wrong ReferenceKind, missing target, wrong entity, and ABI drift;
- explicit goldens proving `Copy=15`, `CopyConstruct=16`, `CopyFactory=17` and
  proving no function derives those values from `asEBehaviours`.

### 12.7 Reflection/payload/string rows

For each legal form, iterate all five ReflectionKind values and assert the
closed allowlist. For ordinary UClass test ConfigName absent/present nonempty/
present empty and StaticClassGlobalName absent/present nonempty/present empty.
For statics and every other form, test each string absent and present. Add
Abstract/SuperIsCode/Statics parity violations and all payload union wrong-tag
presence combinations.

For OrderedUFunctionMembers add:

- an ordinary UClass with two otherwise-equivalent zero-ReflectionFlags AS
  methods where exactly one explicit member row is reflected, proving no mask
  inference;
- exact zero, one, and many ordinary-member sequences, with first/middle/last
  ordinal gap/duplicate, row reorder, omission, and extra-member mutations;
- wrong ReferenceKind, zero/missing ABI, missing target, nonlocal Method,
  GlobalFunction, Constructor, and wrong-owner mutations;
- a StaticsClass with two Module-owned GlobalFunctions in semantic order,
  including `UFUNCTION(NotBlueprintCallable)` with zero ReflectionFlags, plus
  empty-list, Type-owned Method, reordered, omitted, and extra-global failures;
- every non-UClass reflection form with one member as `InvalidPresence`;
- byte/hash goldens proving only explicit membership/order changes
  TypeLayoutHash, while changing a declaration mask from zero to a nonzero
  known mask changes declaration ABI independently and is checked by graph ABI.

### 12.8 Precedence rows

At least these paired failures are required:

| Earlier mutation | Later mutation | Expected winner |
|---|---|---|
| unknown flag bit | missing required flag | `UnknownFlags` |
| invalid UTF-8 name | invalid payload presence | `InvalidUtf8` |
| trailing byte | TypeLayoutHash mismatch | `TrailingData/PayloadDecode` |
| trailing byte | EnumAuthorityHash mismatch | `TrailingData/PayloadDecode` |
| noncanonical Metadata | invalid Enum KindPayload | Metadata `NonCanonicalOrder` at its captured enclosing-field offset |
| zero relation key | missing graph target | `ZeroStableKey` |
| noncanonical relation order | TypeLayoutHash mismatch | `NonCanonicalOrder` |
| property ordinal gap | property fingerprint mismatch | `OrdinalGap` |
| LayoutInputHash mismatch | PropertyLayoutFingerprint mismatch | LayoutInput `DerivedHashMismatch` at its captured enclosing-field offset |
| PropertyLayoutFingerprint mismatch | noncanonical Dependencies | Property `DerivedHashMismatch` at its captured enclosing-field offset |
| self-consistently rehashed wrong property offset | noncanonical Dependencies | Dependencies `NonCanonicalOrder` at its captured enclosing-field offset; field-local pass precedes layout replay |
| OrderedMethods ordinal gap | missing method declaration | `OrdinalGap` |
| VFT ordinal gap | ancestor VFT ABI mismatch | `OrdinalGap` |
| Behavior Script owner present-zero | later ordinal gap | `ZeroStableKey` |
| Behavior Script owner absent | later ordinal gap | `OrdinalGap` |
| Behavior Environment owner present-zero/nonzero | later ordinal gap | `OrdinalGap` |
| otherwise canonical Behavior owner optional invalid | missing behavior graph target | `InvalidPresence` |
| malformed Dependencies | reflection-form contradiction | the Dependencies field-local error |
| reflection wrong form | TypeLayoutHash mismatch | `InvalidPresence` |
| UFunction-member ordinal gap | missing reflected target | `OrdinalGap` |
| EnumAuthorityHash mismatch | TypeLayoutHash mismatch | Enum KindPayload `DerivedHashMismatch` at its captured enclosing-field offset |
| EnumAuthorityHash mismatch | current enum ABI mismatch | `DerivedHashMismatch` locally |
| LayoutInputHash mismatch | current layout missing | `DerivedHashMismatch` locally |
| missing/wrong declaration owner | graph ABI mismatch | common `CrossModuleOwner`/`WrongReferenceKind`/`MissingOwner` precedence |
| linked stored layout/ABI mismatch | current resolver missing/different | `GraphAbiMismatch` |
| valid single external layout witness | current layout missing/different | `CurrentSymbolMissing`/`CurrentAbiMismatch` only after stored graph success |
| complete valid stored graph | current ABI/content/missing mutation | existing current-resolver error only now |

### 12.9 Shared-contract amendment gate rows

Before the matrix can be approved for RED:

1. Task 2B-1 owner Cartesian tests must accept every generated Delegate row in
   section 3.5 and still reject the same entity/Delegate-owner pairs without
   the required Generated traits.
2. Existing Class/Struct/Interface/non-Delegate owner goldens must remain byte-
   and result-identical after that common-contract amendment.
3. Exact remaining-wire goldens must place TypeRelation SemanticOrdinal between
   RelationKind and Target, OrderedMethods immediately before
   VirtualFunctionTable, and OrderedUFunctionMembers after
   StaticClassGlobalName inside ReflectionSchema.
4. One-byte truncation and invalid optional-tag mutations are required at every
   new field boundary; physical decode errors retain the exact failing byte,
   while completed-field semantic failures retain the enclosing-field offset.
5. Comparator/hash goldens must independently perturb direct-interface ordinal,
   MethodOrdinal, VftOrdinal, ReflectionOrdinal, and zero-mask UFunction
   membership, proving that no new authority is accidentally omitted.

### 12.10 Allocator-authoritative TypeSchema rows

This is the exhaustive V1 allocation-family inventory. Exact capacity means the
actual UE allocator capacity/`GetAllocatedSize`, never logical count times
element size. Every allocation is budgeted before reserve/grow using the same
allocator authority. An implementation that eliminates a listed validation
container must prove zero allocations for that family; it may not silently
replace it with an unbudgeted container. The complete lifetime and test rules
are co-normative in `type-layout-authority-v1.md` section 11.

| ID | Allocation family | Lifetime |
|---|---|---|
| TS-SCR-01 | top-level namespace/name/declaration strings, Metadata array/entry strings, and their parallel captured-offset capacity | decoded token retained |
| TS-SCR-02 | Relations array, nested optional/reference storage, and parallel relation offsets | decoded token retained |
| TS-SCR-03 | LayoutInputs array and parallel layout-input offsets | decoded token retained |
| TS-SCR-04 | OrderedProperties top-level array and parallel property-row offsets | decoded token retained |
| TS-SCR-05 | property names, recursive CanonicalDataType subtype arrays, property Metadata/strings, and their nested captured offsets | decoded token retained |
| TS-SCR-06 | OrderedMethods array and parallel method offsets | decoded token retained |
| TS-SCR-07 | VirtualFunctionTable array and parallel VFT offsets | decoded token retained |
| TS-SCR-08 | OrderedBehaviorSlots array, owner optionals, and parallel behavior offsets | decoded token retained |
| TS-SCR-09 | enum enumerators/names/Metadata, inline Delegate/Funcdef/Typedef kind-payload ownership and parallel kind-payload offsets; legal Typedef primitive aliases have zero subtypes, while a physically encoded nonzero subtype array is hostile-input `InvalidFixtureOnly` coverage; Delegate/Funcdef callable fields are inline and have no signature-string allocation | decoded token retained until publication or semantic rejection |
| TS-SCR-10 | Reflection strings, OrderedUFunctionMembers, and parallel reflection/member offsets | decoded token retained |
| TS-SCR-11 | Dependencies array and parallel dependency offsets | decoded token retained |
| TS-SCR-12 | actual local canonical/duplicate/conflict indexes for nested sets | local-decode temporary RAII scratch |
| TS-SCR-13 | property ordinal/layout/hash replay scratch; zero-allocation streaming is preferred | local-decode temporary or proven zero |
| TS-SCR-14 | method/VFT/behavior/UFunction ordinal/duplicate scratch | local-decode temporary or proven zero |
| TS-SCR-15 | reachable TypeSchema/type-key index and Base/value-layout DAG state/work queue | graph-call temporary RAII scratch |
| TS-SCR-16 | interface-closure visited set and work queue | graph-call temporary RAII scratch |
| TS-SCR-17 | property declaration and exact-coverage indexes | graph-call temporary RAII scratch |
| TS-SCR-18 | method/VFT/ancestor-slot/behavior indexes | graph-call temporary RAII scratch |
| TS-SCR-19 | UFunction and already-locally-exact Dependency-target graph-resolution indexes | graph-call temporary RAII scratch |
| TS-SCR-20 | eligible external/environment `{InputKind,ReferenceKind,StableKey}` lookup/memo, distinct eligible CanonicalDataType current-layout memo, masked consumer comparison and current result indexes; prospective local view aliases TS-SCR-15 and allocates zero | graph/current temporary RAII scratch |
| TS-SCR-21 | candidate/published TypeKey views and their ReachableRecords handle capacity | candidate scratch promoted to retained at atomic step 11 |
| TS-SCR-22 | maximum simultaneous decoded token + graph + layout memo + candidate output + opaque summaries | mixed retained/temporary shared Budget |

For every TS-SCR-01..22 family, parameterized RED covers empty, one, allocator
slack boundary, and many values; exact capacity succeeds; one byte short fails
before allocation/growth with an unchanged allocation counter and sentinel
output. All stated simultaneously-live capacities are summed. Every success,
early physical-decode failure, local semantic/hash failure, graph failure,
current miss, and late pre-publication failure returns temporary resident bytes
to the entry value without refunding monotonic decoded/stored/decompressed/
reference counters. Retained/candidate bytes are charged exactly once and
promotion reclassifies rather than consumes them again.

TS-SCR-20 additionally parameterizes every frozen skip/call route, a cold exact
hit with no selected-module resolver entries, and an environment template nested
over a local prospective value type. It proves skipped coordinates allocate no
memo entry and make zero calls, while eligible external/environment coordinates
retain canonical order and at-most-once counters.

TS-SCR-21 names the same physical sites as MS-SCR-21. The matrices do not
authorize duplicate reservations, duplicate retained tables, or double charge.
A generic tiny cumulative-budget RED cannot replace this allocation-family
matrix. Any new container/site requires a new row and exact-limit test.
The private captured-offset table is not a twenty-third family: each of its
parallel arrays belongs to the corresponding TS-SCR-01..11 DTO family above
and is measured concurrently with that DTO capacity. A flat token/header offset
block with no per-element allocation is charged once in TS-SCR-01.

The public TypeSchema captured-field enum is append-only through `0..40`, and its
exhaustive P/S/T consumption table is normative in
`record-wire-v1-remaining.md`. The original `0..38` values are unchanged;
`ReflectionKind=39` and `ClassReflectionFlags=40` provide exact intrinsic
Reflection diagnostics. In
particular, PropertyMetadata consumes `{PropertyOrdinal,MetadataOrdinal,U}`,
BehaviorDeclaringOwner consumes `{BehaviorOrdinal,U,U}` and is unset when the
optional is absent, and EnumEnumeratorMetadata consumes
`{EnumeratorOrdinal,MetadataOrdinal,U}`. RED must exercise every row's valid,
surplus-index, out-of-range, absent and inapplicable behavior plus zero-offset
presence and allocation/Budget invariance; numeric enum assertions alone are
not coverage.

The family matrix is expanded by the independent allocation-site templates in
`type-layout-authority-v1.md` section 11.1. Every real allocator site, including
nested string/subtype/metadata and parallel offset storage, is a separate RED
case. A production probe may expose chronological observed events, but it may
not choose the target site or return the expected Stage, ByteOffset, or limit.
One probe-selected target per family/variant is not exhaustive evidence.

## 13. Merge-ready normative replacement summary

The authoritative wire document can adopt the following compact rules without
retaining alternatives:

1. Correct Delegate from `ReferenceType` to required
   `Final|Generated|ValueType`; require UDelegate.
2. Append BehaviorKind `Copy=15`, `CopyConstruct=16`, `CopyFactory=17`.
3. Add `SemanticByteOffset:u32` to PropertySchema and its fingerprint.
4. Replace the conflated MethodSlot array with independently ordinaled exact
   `OrderedMethods` and `VirtualFunctionTable` arrays.
5. Add ImplementedInterface-only `TypeRelation.SemanticOrdinal`; store ordered
   direct interfaces and derive base-first closure without persisting it.
6. Append `ReflectionSchema.OrderedUFunctionMembers`, including explicit
   zero-ReflectionFlags ordinary methods and ordered StaticsClass module globals.
7. Replace BehaviorSlot FunctionKey/ABI with `Target:StableReference` and an
   owner optional whose presence is selected by target reference kind.
8. Amend the common Task 2B-1 owner contract for generated Delegate members as
   section 3.5, then rerun and independently approve the affected regression
   matrix before TypeSchema RED.
9. Adopt the literal TypeKind flag/payload matrix in section 4.
10. Adopt the closed reflection/config/static/UFunction matrix in section 5.
11. Adopt the ordered-direct relation target/cardinality/code-root matrix in
   section 6;
   Compose is zero-cardinality/NotCacheable in V1.
12. Store only local properties; remove the false PersistentInstance-to-
    InstancedReference implication; execute initial alignment `8`, exact
    per-property offsets, and mandatory terminal AlignUp from section 7.
13. Adopt the independent method/VFT owner/ABI tables in section 8 and the
    17-kind behavior matrix in section 9, including the split script-alias versus
    EnvironmentSymbol copy-singleton rule.
14. Use section 11's local then graph precedence and section 12's generated
    exhaustive RED rows before any TypeSchema golden is frozen.

There is no legacy compatibility branch. A semantic that cannot satisfy these
matrices makes the complete module snapshot NotCacheable; it is never omitted,
defaulted, or regenerated from source text on a purported warm hit. This
summary remains RED-blocked until the independent re-review passes; the shared-
authority merge gate in section 3.9 is closed.
