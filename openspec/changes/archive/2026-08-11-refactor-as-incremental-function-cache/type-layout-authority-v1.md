# Cache V2 Type Layout Authority V1

Status: approved co-normative TypeSchema authority. This file is co-normative
with `type-schema-matrix-v1.md` and `record-wire-v1-remaining.md`; their stable
synchronized snapshot received fresh independent approval for RED on
2026-08-08. The focused maintained-source audit also returned
`APPROVED — 0 Critical / 0 Important / 1 Minor`; its sole Minor is the explicit
downstream production CompatibilityKey assembler spelling/golden work and does
not block Task 2B-2 RED.

## 1. Problem and selected architecture

The TypeSchema reader must reconstruct and validate exact AngelScript object
layout without creating a live AS engine or UObject. The maintained compiler
uses numeric inputs that cannot be recovered from an ABI hash:

- a property's effective storage size and alignment;
- a script base's final size and alignment;
- a UClass code-root property boundary and registered AS shadow alignment; and
- `UASStruct::ScriptValueOffset` for a reflected script struct.

An expected ABI proves equality only when another authority supplies the value
to compare; it cannot be inverted to recover those numeric inputs. Conversely,
calling the live current-symbol catalog before immutable graph validation would
collapse a contradictory stored graph into a normal cache miss.

V1 therefore selects two deliberately separate authorities:

1. **Persisted layout evidence.** Every numeric input needed to replay
   `LayoutClass` is encoded pointer-free inside TypeSchema and participates in
   canonical hashes and RecordId. Local validation can recompute every property
   offset, terminal size, and type layout without a live resolver.
2. **Eligible current layout resolution.** After the complete stored module
   graph is self-consistent, a separate layout resolver compares only layout
   coordinates that are not already closed by the selected module graph or by
   versioned Compatibility/Profile constants. It can consume a read-only
   prospective view of validated local TypeSchemas while evaluating a nested
   environment-type recipe, but it never requires the selected module's live
   script types to exist. Current drift is a normal Ineligible result and never
   supplies an input to an earlier graph check.

The selected design does not add a global layout record and does not make legal
cross-module TypeSchemas children of one ModuleSnapshot. A same-module linked
TypeSchema is an independent stored authority and must agree during graph
validation. A legal external target for which the current module graph contains
no second record has only one persisted authority; its current comparison is
therefore step-10 eligibility, not a fabricated graph contradiction.

This is not a security/authenticity boundary. A party able to replace semantic
payload bytes and recompute all hashes can forge any Cache V2 record. Store and
package trust are handled separately. The purpose here is deterministic
corruption detection, cross-record consistency, and exact current-ABI
invalidation.

## 2. Maintained implementation evidence

The rules below mirror the maintained fork rather than host `sizeof` guesses:

- `asCObjectType` starts with alignment `8` in
  `ThirdParty/angelscript/source/as_objecttype.cpp`.
- `asCObjectType::AddPropertyToClass` raises object alignment from each
  `asCDataType::GetAlignment()`.
- `asCBuilder::LayoutClass` starts at `derivedFrom->size`, otherwise at
  `basePropertyOffset`; it aligns each local property, stores `byteOffset`, adds
  the effective storage size, and tail-aligns the final object size.
- a value object property uses `GetSizeInMemoryBytes`; a non-value object uses
  `GetSizeOnStackDWords()*4`; primitive values use `GetSizeInMemoryBytes`.
- `FAngelscriptEngine` obtains a UClass code-root boundary from
  `CodeSuperClass->GetPropertiesSize()` and the shadow alignment from the
  registered AS shadow type. Applying PreClassData raises the new script
  object's alignment from that shadow before properties or `LayoutClass` run.
  `LayoutClass` later selects Base size when a script Base exists, but its final
  alignment therefore still contains both the earlier code-root contribution
  and the Base contribution.
- a reflected script struct sets `basePropertyOffset` to
  `UASStruct::ScriptValueOffset`. It has no shadow alignment contribution; the
  AS object still starts at the V1 initial alignment and is raised by local
  properties.
- the maintained bytecode reader rebuilds the same layout recursively after
  type/property restoration. It does not persist old numeric offsets as the
  reconstruction authority.
- the common `asITypeInfo` descriptor alignment starts at `4`. RegisterTypedef
  stores only the primitive alias size and leaves that descriptor alignment at
  `4`; `asCFuncdefType` leaves size `0` and alignment `4`. These are observable
  live descriptor coordinates and are not normalized to the primitive alias
  alignment or to `1`.

The legacy `PrecompiledScript.Cache` path is negative evidence only. In
particular, its shadow restore may derive `basePropertyOffset` from the shadow
type size, while the current producer obtains the UClass boundary from
`GetPropertiesSize()`. Cache V2 captures the actual maintained producer inputs
and does not preserve that legacy shortcut.

## 3. Exact append-only enums

These are remaining-wire enums and do not renumber any Task 2B-1 value.

```text
EAngelscriptCachedPropertyStorageKind : u8
  Invalid=0
  InlineValue=1
  ObjectHandle=2

EAngelscriptCachedTypeLayoutInputKind : u8
  Invalid=0
  BaseType=1
  CodeRoot=2
  StructHeader=3
```

Unknown values fail with `UnknownEnumValue/PayloadDecode`. Zero is never a
valid stored value.

`InlineValue` means the exact bytes returned by the maintained in-memory value
layout. It covers primitive, enum, script value type, environment value type,
and a fully instantiated value template. A source-level typedef used in a
property is expanded to its primitive `aliasForType` before this witness is
captured; no property row points at the standalone typedef descriptor.
`ObjectHandle` means the exact
storage used by the maintained non-value object property route. A property with
`Reference`, `Auto`, `Void`, null-handle, unresolved, or otherwise
non-instantiable storage is NotCacheable at capture and malformed if encoded.

## 4. Exact TypeSchema wire additions

Insert `LayoutInputs` immediately after `Relations` and before `Layout`:

```text
PayloadSchemaVersion:u32
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

The new subrecord is:

```text
TypeLayoutInput:
  InputKind:u8
  Target:StableReference
  BoundaryContribution:optional<u32>
  AlignmentContribution:optional<u32>
  LayoutInputHash:hash256
```

`LayoutInputs` is a canonical set ordered by numeric `InputKind`. Every legal
kind is a singleton. Duplicate equal rows are `DuplicateKey`; the same kind
with another coordinate is `ConflictingKey`; noncanonical order is
`NonCanonicalOrder`.

Replace PropertySchema with this exact order:

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

Every property storage size and every present alignment is nonzero; every
present alignment is a power of two. A present boundary contribution may be
zero, because an empty script Base can have semantic size zero. Optional absence
means the maintained producer does not consume that coordinate for this role;
zero never substitutes for the optional presence tag.
Object-like sizes, boundaries, offsets, and checked ends must be representable
by nonnegative maintained `int32`; a wire `u32` above `INT32_MAX` is `Overflow`,
not truncation.

## 5. Exact hash streams

All streams use `FAngelscriptArtifactCanonicalWriter`, encode nested values in
wire order, and exclude their own stored result.

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

Changing one storage kind, size, alignment, layout-input role, target ABI,
boundary, or alignment contribution changes its immediate hash, TypeLayoutHash,
semantic payload, and RecordId. The current resolver never supplies bytes to a
stored hash calculation.

## 6. Layout-input presence and semantics

The exact matrix is:

| Type form | BaseType | CodeRoot | StructHeader |
|---|---|---|---|
| Class + None, no Base | forbidden | forbidden | forbidden |
| Class + None, Base present | exactly one, target exactly Base relation | forbidden | forbidden |
| ordinary Class + UClass, no Base | forbidden | exactly one, target exactly both ShadowSuper and CodeSuper; boundary+alignment present | forbidden |
| ordinary Class + UClass, Base present | exactly one, target exactly Base relation; boundary+alignment present | exactly one, target exactly both ShadowSuper and CodeSuper; boundary absent, alignment present | forbidden |
| statics Class + UClass | forbidden | forbidden | forbidden |
| Struct + None | forbidden | forbidden | forbidden |
| Struct + UStruct | forbidden | forbidden | exactly one runtime-layout EnvironmentSymbol; boundary present, alignment absent |
| Interface, Enum, Delegate, Typedef, Funcdef | forbidden | forbidden | forbidden |

Role semantics are:

- `BaseType`: present `BoundaryContribution` is the base TypeSchema
  `SemanticSize` and present `AlignmentContribution` is its
  `SemanticAlignment`.
- `CodeRoot`: when present, `BoundaryContribution` is the current code superclass
  `GetPropertiesSize()` captured by the producer; `AlignmentContribution` is
  the registered AS shadow type alignment. The same environment target and ABI
  must appear in both ShadowSuper and CodeSuper relations. This witness is
  present for every ordinary UClass. With a script Base, BoundaryContribution
  is absent because the maintained cursor selects Base size; the present
  AlignmentContribution still participates because PreClassData applies the
  shadow alignment before `LayoutClass` takes the later `derivedFrom` branch.
- `StructHeader`: present `BoundaryContribution` is
  `UASStruct::ScriptValueOffset`; AlignmentContribution is absent because the
  maintained builder uses the header only as `basePropertyOffset` and installs
  no shadow alignment. Its target is the environment catalog's reserved runtime-layout
  coordinate `UnrealAngelscript/UASStruct.ScriptValueHeader/V1`, whose ABI
  covers the header fields, pointer width, `ScriptValueOffset`, and the
  compatibility-selected struct-value convention.

Every row has exactly one matching semantic dependency with the identical
target: `BaseType` uses the Base relation's existing `Inheritance` row;
`CodeRoot` uses the existing code-root `EnvironmentAbi` row;
`StructHeader` uses `EnvironmentAbi`. LayoutInputs do not create a second target
identity or a second ABI. Exact dependency coverage rejects a missing or extra
row.

Local pairing and error mapping are exact:

- a missing, extra or wrong LayoutInput role, or a role with the wrong optional-
  field presence mask, is `InvalidPresence`;
- an unknown InputKind, zero target key, missing ABI or locally wrong
  ReferenceKind uses its existing common local error;
- after both Relations and LayoutInputs pass their own field-local checks,
  `BaseType.Target` must equal the Base relation target and `CodeRoot.Target`
  must equal both ShadowSuper and CodeSuper targets over the complete stored
  `{ReferenceKind, StableKey, ExpectedAbi}` tuple; two individually well-formed
  stored references that disagree return `InvalidQualifierCombination` at the
  offending LayoutInput enclosing-field offset; and
- dependency presence/equality remains the following cross-field phase and uses
  `MissingCoverage`, `UnexpectedRecord` or the common dependency conflict error,
  never the pairing error above.

This exact stored-coordinate equality is local and allocation-free. It does not
resolve the target. ModuleGraph still owns target existence, entity/reflection
category, module/type ownership, the linked declaration ABI and the semantic
proof that the common stored environment coordinate is the actual code-root
class. Thus local equality of the three stored CodeRoot/ShadowSuper/CodeSuper
references does not move resolved same-code-root validation into the local pass.

## 7. Exact immutable layout replay

Local decode first validates and owns all layout evidence. It then performs the
following checked replay without a resolver:

1. Start every VM object type at schema constant
   `V1ObjectInitialAlignment=8`.
2. Select `BasePropertyBoundary`:
   - BaseType BoundaryContribution when BaseType is present;
   - otherwise CodeRoot BoundaryContribution for ordinary UClass;
   - otherwise StructHeader BoundaryContribution for reflected UStruct;
   - otherwise zero.
3. Compute `SemanticAlignment` as the exact maximum of `8`, every local
   property's `SemanticStorageAlignment`, present BaseType
   AlignmentContribution, and present CodeRoot AlignmentContribution.
   StructHeader has no alignment coordinate.
4. Start the cursor at BasePropertyBoundary.
5. For every local property in LayoutOrdinal order, checked-AlignUp the cursor
   to SemanticStorageAlignment, require exact SemanticByteOffset, and checked-add
   SemanticStorageSize.
6. Checked-AlignUp the final cursor to SemanticAlignment and require exact
   SemanticSize, including mandatory terminal tail padding.

Special normalized forms remain:

- statics UClass `{size=0, alignment=1, boundary=0}`;
- Interface `{size=0, alignment=8, boundary=0}`;
- Enum `{size=1, alignment=1, boundary=0}`;
- Typedef has the primitive alias byte size, descriptor alignment
  `V1TypeInfoInitialAlignment=4`, and boundary zero. In particular a typedef of
  int8 has `{size=1, alignment=4}`, not primitive int8 alignment `1`.
  When a typedef is used in a property, the maintained builder expands
  `aliasForType` into the primitive `asCDataType`; the property's
  CanonicalDataType/storage evidence is therefore that primitive layout, not a
  ScriptType reference to the typedef descriptor.
- Funcdef has live descriptor layout `{size=0, alignment=4, boundary=0}`.
  Funcdef remains usable as a signature/reference coordinate, but a Funcdef
  property is NotCacheable in V1 because maintained property layout would have
  zero semantic storage size and the old cache used a conflicting pointer-size
  special case.

Delegate is a generated value object with boundary zero and normal property
replay. Empty non-normalized Class/Struct/Delegate objects still use alignment
`8` and terminal checked alignment.

### 7.1 Versioned build-layout constants

Primitive and ObjectHandle step-10 comparison uses one engine-free immutable
`FAngelscriptCacheV1BuildLayoutConstants` returned by the maintained Runtime
build; it does not query an AS engine, type database, environment catalog, or
`CurrentLayouts`. The exact V1 table mirrors `asCDataType`:

| Storage route | SemanticStorageSize | SemanticStorageAlignment |
|---|---:|---:|
| Bool | `AS_SIZEOF_BOOL` (`1` or `4`) | `1` |
| Int8, UInt8 | `1` | `1` |
| Int16, UInt16 | `2` | `2` |
| Int32, UInt32, Float32 | `4` | `4` |
| Int64, UInt64 | `8` | `alignof(asINT64)` |
| Float64 | `8` | `alignof(double)` |
| ObjectHandle | `4 * AS_PTR_SIZE` (current pointer byte width) | `8` |

Void and Auto have no property-storage row. Reference is NotCacheable. A local
Enum/Script value layout comes from its TypeSchema rather than this primitive
table. The factory also exposes `V1ObjectInitialAlignment=8` and
`V1TypeInfoInitialAlignment=4` used above.

The first authoritative production CompatibilityKey assembler MUST add exact
canonical inputs for cache layout schema version, `AS_SIZEOF_BOOL`, pointer byte
width, `alignof(asINT64)`, `alignof(double)`, ObjectHandle alignment `8`, object
initial alignment `8`, and type-info initial alignment `4`. Until that assembler
exists this is an explicit downstream contract, not evidence that the current
Task-1 descriptor strings already include those values. After selected Profile
equality succeeds in graph step 10, every primitive/ObjectHandle property is
compared with this table before eligible resolver calls. Inequality is
`CurrentAbiMismatch/Ineligible`; it cannot fall back to a live query.

The decoder does not infer property storage from C++ `sizeof`, parse canonical
type spelling, consult a global type database, or silently repair a producer
coordinate. Invalid power-of-two/range/presence/role combinations use
`InvalidQualifierCombination` or `InvalidPresence`; checked arithmetic uses
`Overflow`; stored hash mismatch uses `DerivedHashMismatch`.

A TypeSchema producer that is asked to serialize an inactive or missing selected
kind arm rejects before emitting payload bytes with the exact normalized tuple
`InvalidPresence / CanonicalSemantic / TypeSchema / None / 0` and leaves the
output byte array empty. `Stage=None` and offset zero identify the producer-side
boundary; decoder-side mutations continue to use their actual decode/local stage
and independently scanned payload coordinate.

## 8. Immutable graph cross-checks

After every TypeSchema token has completed wire/local/hash validation, graph
validation performs these additional checks before current resolution. Local
validation has already proved relation/LayoutInput pairing, property StorageKind
versus canonical qualifier compatibility, and the exact DTO-derived Dependency
set; none is re-derived here:

1. Resolve every locally paired LayoutInput relation/dependency target to the
   required graph entity/category/actual owner/module/ABI.
2. Resolve each inline-value property's already locally exact ValueLayout
   Dependency target; when it names a linked same-module TypeSchema, compare the
   independent stored layout authority as specified below. An ObjectHandle instead
   requires only ScriptType Declaration or EnvironmentType EnvironmentAbi target
   authority because its storage comes from the selected profile constant.
3. If BaseType targets a TypeSchema reachable in this module graph, its
   BoundaryContribution/AlignmentContribution equal the target Layout's
   SemanticSize/SemanticAlignment.
4. If an InlineValue ScriptType property directly targets a reachable
   TypeSchema, its storage size/alignment equal the target layout. ObjectHandle
   storage deliberately does not require the target object instance size.
5. Same-module by-value layout edges and Base edges are traversed as a DAG.
   A cycle, unresolved required target, or disagreement between two stored
   authorities is `GraphAbiMismatch/ModuleGraph` before any current call.

A legal cross-module target need not be a child record. In that case the
persisted LayoutInput or Property storage coordinate is the only stored numeric
authority. Its self-hash and all consuming offsets are still locally checked,
and its target/dependency identity is still graph checked. Equality with the
external/current target is deferred to step 10 by design. The validator must not
search unrelated caller records and must not convert an external dependency into
an ownership error merely to obtain a second layout copy.

## 9. Current layout resolver

Current layout comparison is a separate interface from current symbol ABI/
content resolution:

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

The prospective view is a non-owning façade over the already graph-validated
TypeKey index. It exposes only the selected ModuleKey's immutable TypeKind,
SemanticSize, and SemanticAlignment; it cannot return an unvalidated DTO,
external type, current symbol, pointer, UObject, or live AS type. A same-module
type reference missing from that index has already failed immutable graph
coverage and never reaches this interface.

The production current-layout implementation is per-engine and is backed by a
sealed environment-layout recipe catalog plus already selected imported-module
layout authorities. It is callable before the selected module is materialized.
For an EnvironmentType whose ordered subtype tree contains a same-module
ScriptType, the recipe obtains that subtype's numeric layout only through
`LocalLayouts`; it MUST NOT look up the selected module in a live AS engine.
Neither resolver consults the process-global fallback type database. The pure
Task 2B-2 fixture resolver is a deterministic value map/recipe set and creates
no live AS engine or UObject.

Lookup identity excludes every stored ExpectedAbi, stored size/alignment/hash,
stored optional-presence bit, and owner-provided display string.
`ResolveDataTypeLayout` locates an eligible cross-module or fully instantiated
environment canonical type structure from kind, stable keys, qualifiers, and
ordered subtypes; primitive and graph-closed local routes never call it;
`ResolveTypeLayoutInput` locates only by role, reference kind, and full stable
key. Its optionals describe raw coordinates available from the current catalog,
not which coordinates this consuming TypeSchema uses:

| Current resolver role | Raw BoundaryContribution | Raw AlignmentContribution |
|---|---|---|
| BaseType | present, may be zero | present nonzero power of two |
| CodeRoot | present, may be zero | present nonzero power of two |
| StructHeader | present | absent |

This distinction is required because the same CodeRoot key can be consumed by
both a root UClass (stored boundary+alignment present) and a script-derived
UClass (stored boundary absent, alignment present). The validator first proves
the stored presence matrix locally, then applies that stored consumption mask
to the raw current result: every stored-present coordinate takes the returned
current value; every stored-absent coordinate remains absent even if the raw
catalog also knows it. The validator, not the provider, recomputes current
StorageLayoutHash/LayoutInputHash from that masked value and the stored identity
coordinate. It never treats an unconsumed raw coordinate as a presence mismatch.

`FAngelscriptCacheModuleGraphValidationContext` adds one required non-null:

```cpp
const IAngelscriptCacheCurrentLayoutResolver* CurrentLayouts;
```

Null context fails with the existing `ContextMismatch` before codec or resolver
calls. No default/global resolver is inferred.

### 9.1 Frozen graph-closed/current-eligible split

The validator decides eligibility from validated stable ownership and datatype
shape, never from resolver success or a display name. A target declared by the
selected ModuleInterface is same-module. If that declaration requires a
TypeSchema but its child record is absent, immutable coverage fails; it MUST NOT
fall through and be treated as an external current lookup.

Current-symbol resolution uses the same split. Selected-module ScriptModule,
ScriptType, ScriptFunction, ScriptGlobal, ScriptProperty, and ScriptImport
coordinates whose declaration/content authority is represented by the
validated graph are graph-closed and produce **zero** `CurrentSymbols` calls.
An import's external target remains a separate external dependency and is still
eligible. External Script* references and every EnvironmentSymbol dependency
are eligible. CanonicalName and StringLiteral remain codec-owned and are never
eligible.

TypeLayoutInput selection is exact:

| Stored input | Authority at step 10 | `CurrentLayouts` call |
|---|---|---|
| BaseType targeting a selected-module TypeSchema | already checked TypeSchema DAG | no |
| BaseType targeting another module | selected imported-module/current authority | `ResolveTypeLayoutInput` |
| CodeRoot | sealed engine environment authority | `ResolveTypeLayoutInput` |
| StructHeader | sealed engine environment authority | `ResolveTypeLayoutInput` |

Property storage selection is exact:

| CanonicalDataType / storage form | Authority at step 10 | `ResolveDataTypeLayout` call |
|---|---|---|
| Primitive InlineValue, including a property-expanded typedef | versioned Compatibility/Profile primitive table | no |
| selected-module ScriptType InlineValue | graph-validated target TypeSchema | no |
| external ScriptType InlineValue | selected imported-module/current authority | yes |
| EnvironmentType InlineValue, including nested templates | sealed environment recipe plus `LocalLayouts` | yes |
| ScriptType or EnvironmentType ObjectHandle | versioned Compatibility/Profile handle-slot table; target ABI remains a symbol/graph concern | no |

Auto, Void, Reference, unresolved, or another non-instantiable form has already
failed local semantics. An ObjectHandle never queries target instance size; its
slot size/alignment is compared with the selected profile constant, while the
target's declaration/environment ABI is independently checked by the graph or
eligible `CurrentSymbols` dependency.

### 9.2 Exact call order and memoization

In graph step 10, after selected source/profile and the eligible current-symbol
ABI/content walk succeed, the validator builds one allocation-free
`LocalLayouts` façade and then:

1. visit TypeSchemas in ModuleSnapshot link order and compare each Primitive or
   ObjectHandle property with the V1 build-layout table in LayoutOrdinal order;
2. skip graph-closed inputs, then visit each distinct eligible
   `{InputKind,ReferenceKind,StableKey}` TypeLayoutInput in first numeric-kind/
   link order, call once, validate its raw role shape, and reuse that result for
   every consumer-specific stored presence mask;
3. visit properties in LayoutOrdinal order, skip already compared profile-
   constant and graph-
   closed routes, and resolve once per distinct eligible exact
   CanonicalDataType/storage coordinate at its first occurrence; and
4. compare storage kind/size/alignment and, for TypeLayoutInput, only the
   consumer-masked contributions plus the validator-recomputed layout hash.

Skipped coordinates do not enter current-result memos and do not increment
resolver call counters. `LocalLayouts` lookups made by an environment recipe are
not current lookups. Eligible external/environment calls remain ordered and
at-most-once even when multiple TypeSchemas or nested templates reuse them.

A missing resolver result is `CurrentSymbolMissing/Ineligible`. An invalid raw
role shape, a missing raw coordinate required by a stored-present mask, or an
unequal kind/size/alignment/masked hash is
`CurrentAbiMismatch/Ineligible`. No current layout error may win over a stored
local/hash/ownership/coverage/layout contradiction.

## 10. Physical decode and error precedence

Physical payload completeness is checked before every semantic or derived-hash
rule. The exact local order is:

1. decode every field recursively with scalar/enum/optional/UTF-8/array/
   arithmetic/budget checks;
2. require `Reader.IsAtEnd()` and return `TrailingData/PayloadDecode` at the
   first extra byte;
3. run one field-local semantic pass in exact top-level wire order:
   header/identity/strings/flags, Metadata, Relations, LayoutInputs, Layout
   scalars, OrderedProperties, OrderedMethods, VirtualFunctionTable,
   OrderedBehaviorSlots, KindPayload, Reflection, then Dependencies. Within an
   array, validate rows in stored order and subfields in row wire order. At the
   containing field, recompute each LayoutInputHash; for each property recompute
   StorageLayoutHash then PropertyLayoutFingerprint; and at Enum KindPayload
   recompute EnumAuthorityHash. Layout.TypeLayoutHash is deliberately deferred.
   Earlier fields apply only intrinsic and TypeKind-local rules; any presence,
   cardinality, allowlist or scalar parity selected by the later Reflection
   discriminator is deferred and no earlier field may look ahead;
4. after every field-local check succeeds, run cross-field rules in this fixed
   order: `ReflectionFormClosure` including Class Construct/Factory count; script
   CopyConstruct/CopyFactory alias tuples;
   flag/Behavior coupling; relation-to-LayoutInput exact pairing; locally
   derivable Dependency set equality (`MissingCoverage` for a missing derived row,
   `UnexpectedRecord` for an extra row); then complete property-offset/aggregate-
   alignment/terminal-size replay. `ReflectionFormClosure` derives the one legal
   TypeKind+Reflection form only after Reflection and Dependencies field-local
   success and applies form-dependent prior-field rules in wire order. A later-
   field local error therefore wins over an earlier-field cross-field
   contradiction;
5. recompute TypeLayoutHash last, after every value it covers and every other
   local derived hash is valid; and
6. publish the immutable DTO only after all checks succeed.

The unique derived-hash order is therefore: LayoutInputHash rows; for each
property, StorageLayoutHash then PropertyLayoutFingerprint; EnumAuthorityHash;
TypeLayoutHash last. The physical position of TypeLayoutHash inside `Layout`
does not move it earlier. “Wire order” refers to the field-local pass and never
authorizes reading a later top-level field during an earlier field's semantic
check.

Method/VFT/Behavior canonical validation is phased exactly as frozen in
`type-schema-matrix-v1.md`: raw enum domain; stored-row active keys/ABIs; ordinal
duplicate/gap/order; local role and optional-tag shape; duplicate FunctionKey;
then cross-field closure. For Behavior, a present ScriptFunction owner value is
active and checked nonzero before ordinals; a missing ScriptFunction owner and
any present EnvironmentSymbol owner are tag-shape failures checked after
ordinals. An inactive EnvironmentSymbol owner value is never interpreted.

Closure diagnostics use only the public captured fields frozen in
`record-wire-v1-remaining.md`. Present forbidden rows use their lowest proving
physical array index. A form-selected missing row has no offset and therefore
uses top-level `Reflection`; layout scalar parity uses `LayoutExpectation`, and
form-dependent semantic flags use `TypeSemanticFlags`. Base-driven missing
BaseType LayoutInput uses the requiring `Relation` row instead. Duplicate or
conflicting singleton Relation/LayoutInput authority is already rejected at the
second physical row during the field-local pass and never reaches closure.
Locally derivable Dependency set equality is likewise not graph work: a missing
row uses the decoder's physical Dependencies-array/enclosing-field error offset
because no public row coordinate exists, while an extra row uses its indexed
`Dependency` coordinate. Graph validation only resolves each locally exact
target's existence/entity/owner/module/ABI and owns separate record/declaration
coverage.

Required paired winners are:

| Earlier mutation | Later mutation | Winner |
|---|---|---|
| trailing byte | TypeLayoutHash mismatch | `TrailingData/PayloadDecode` |
| trailing byte | EnumAuthorityHash mismatch | `TrailingData/PayloadDecode` |
| Metadata noncanonical | invalid Enum KindPayload semantics | the Metadata `NonCanonicalOrder/LocalSemantic` at its captured enclosing-field offset |
| LayoutInputHash mismatch | PropertyLayoutFingerprint mismatch | the LayoutInput `DerivedHashMismatch/LocalSemantic` at its captured enclosing-field offset |
| PropertyLayoutFingerprint mismatch | Dependencies noncanonical | the Property `DerivedHashMismatch/LocalSemantic` at its captured enclosing-field offset |
| self-consistently rehashed wrong property offset | Dependencies noncanonical | the Dependencies `NonCanonicalOrder/LocalSemantic`; all field-local checks precede layout replay |
| Dependencies noncanonical | missing form-required CodeSuper/CodeRoot/StructHeader/member | the Dependencies field-local error; closure has not run |
| Behavior Script owner present-zero | later ordinal gap | `ZeroStableKey` at the present owner value |
| Behavior Script owner absent | later ordinal gap | `OrdinalGap`; optional-tag shape is later |
| Behavior Environment owner present-zero/nonzero | later ordinal gap | `OrdinalGap`; the inactive owner value is not read |
| EnumAuthorityHash mismatch | TypeLayoutHash mismatch | the Enum KindPayload `DerivedHashMismatch/LocalSemantic` at its captured enclosing-field offset |
| no trailing byte | TypeLayoutHash mismatch | `DerivedHashMismatch/LocalSemantic` |
| no trailing byte | EnumAuthorityHash mismatch | `DerivedHashMismatch/LocalSemantic` |
| LayoutInputHash mismatch | missing current layout | `DerivedHashMismatch/LocalSemantic` |
| stored linked layout mismatch | current layout missing/different | `GraphAbiMismatch/ModuleGraph` |
| valid single external witness | current layout missing | `CurrentSymbolMissing/Ineligible` |
| valid single external witness | current layout differs | `CurrentAbiMismatch/Ineligible` |

## 11. Allocator-authoritative TypeSchema budget inventory

Every allocation is charged before reserve/grow by the actual UE allocator
capacity authority, not `Num*sizeof(T)`. `TArray` uses its exact
`ElementAllocatorType::CalculateSlackReserve` branch and later proves
`GetAllocatedSize`; FString and owned bytes use their actual allocator capacity.
Checked byte addition happens before allocation. A failed reservation is
side-effect-free. Temporary resident reservations release on every exit;
monotonic decoded/stored/decompressed/reference counters never refund.

The `decoded token retained` labels below describe the storage's final semantic
lifetime, not its pre-publication Budget acquisition class. Controller, canonical
payload, DTO strings/arrays and captured offsets first extend one private aggregate
decoded-candidate **Temporary** transaction. Each event therefore has
`TemporaryCharge=ExactCapacity` and `ResidentCharge=0` until publication. Failure
releases the aggregate Temporary bytes while TotalDecoded remains monotonic; success
performs one final promotion checkpoint that moves the aggregate to Resident before
publishing the handle, without a second Total or live charge.

The following table is exhaustive for V1. Adding or retaining another
container/site requires another row and parameterized test before approval.

| ID | Allocation family | Lifetime | Required proof |
|---|---|---|---|
| TS-SCR-01 | one shared token/controller allocation, the token-owned canonical-payload byte array, the flat token/header captured-offset block, top-level namespace/name/declaration strings, Metadata array/both strings, and parallel metadata-offset capacity | decoded token retained | controller and every byte/string/array/offset block use exact allocator capacity; payload ownership is non-aliasing and charged once; nested and combined Total/Resident one-byte-short |
| TS-SCR-02 | Relations array, nested optional/reference storage, and parallel relation offsets | decoded token retained | zero/one/many, every relation kind, exact combined capacity |
| TS-SCR-03 | LayoutInputs array and parallel layout-input offsets | decoded token retained | all three roles independently and together; exact combined capacity |
| TS-SCR-04 | OrderedProperties top-level array and parallel property-row offsets | decoded token retained | zero/one/many exact capacity before element construction |
| TS-SCR-05 | each property name, recursive CanonicalDataType subtype arrays, property Metadata/strings, and nested captured offsets | decoded token retained | depth/width, first/middle/last nested growth, exact concurrent capacity |
| TS-SCR-06 | OrderedMethods array and parallel method offsets | decoded token retained | zero/one/many exact combined capacity |
| TS-SCR-07 | VirtualFunctionTable array and parallel VFT offsets | decoded token retained | independent of methods and combined-live exact capacity |
| TS-SCR-08 | OrderedBehaviorSlots array, owner optionals, and parallel behavior offsets | decoded token retained | every behavior group/cardinality, exact combined capacity |
| TS-SCR-09 | Enum enumerator array plus name/Metadata strings, selected-arm inline ownership and parallel kind-payload offsets; a physically encoded nonzero Typedef CanonicalDataType subtype array is an `InvalidFixtureOnly` hostile-input site because a legal V1 Typedef aliases only an unqualified primitive | decoded token retained until semantic rejection | each legal union arm independently; the invalid Typedef subtype site proves pre-allocation Budget, exact physical capacity and candidate cleanup but never success-path exhaustion; Delegate/Funcdef callable key+ABI+bool are inline and allocate no DTO string/container; wrong arm allocates nothing beyond decoded prefix |
| TS-SCR-10 | Reflection ConfigName/StaticClassGlobalName strings, OrderedUFunctionMembers, and parallel reflection/member offsets | decoded token retained | absent/present/empty/many and combined-live exact capacity |
| TS-SCR-11 | Dependencies array and parallel dependency offsets | decoded token retained | exact combined capacity for TypeSchema-derived `Inheritance`, `ValueLayout`, `Declaration`, `Signature` and `EnvironmentAbi` rows; other common dependency kinds are invalid extras for this record and cannot close Required success coverage |
| TS-SCR-12 | local canonical/duplicate/conflict indexes retained by the implementation for metadata, relations, layout inputs, dependencies, or nested sets | local-decode temporary RAII scratch; streaming/adjacent implementations prove zero allocation for omitted families | each actual index independently and every concurrently live combination |
| TS-SCR-13 | local property ordinal/layout/hash replay scratch | local-decode temporary; normative streaming implementation should allocate zero | adversarial many-property fixture proves zero validation allocation or exact capacity if implementation retains a table |
| TS-SCR-14 | local method/VFT/behavior/UFunction ordinal and duplicate scratch | local-decode temporary; zero-allocation positional checks preferred | each actual retained index plus zero-allocation proof for omitted ones |
| TS-SCR-15 | reachable TypeSchema/type-key index and same-module value-layout/Base DAG state/work queue | graph-call temporary RAII scratch | deep base chain, wide value graph, duplicate edge, cycle, exact combined capacity |
| TS-SCR-16 | direct-interface closure visited set and work queue | graph-call temporary RAII scratch | deep/wide/diamond/cycle and exact simultaneous capacity |
| TS-SCR-17 | property declaration and exact coverage indexes | graph-call temporary RAII scratch | missing/extra/owner/type/layout cases, exact capacity |
| TS-SCR-18 | OrderedMethods, VFT, ancestor-slot, and behavior target indexes | graph-call temporary RAII scratch | each independent sequence and combined-live capacity |
| TS-SCR-19 | reflected-UFunction and already-locally-exact Dependency-target graph-resolution indexes | graph-call temporary RAII scratch | ordinary/statics/zero-mask plus missing target/wrong entity/owner/ABI and combined capacity; no DTO set re-derivation |
| TS-SCR-20 | eligible external/environment layout-input lookup, distinct eligible CanonicalDataType current-layout memo, and current result indexes; `LocalLayouts` is a zero-allocation non-owning façade over the TS-SCR-15 validated TypeKey index | graph/current-step temporary RAII scratch | cold exact hit with no selected-module resolver entries/calls, duplicate eligible property types, environment templates nested over local prospective values, cross-module Base, code root, struct header, every skip route, exact capacity and ordered at-most-once call counters |
| TS-SCR-21 | candidate/published sorted TypeKey-to-TypeSchema ordinal views plus their portion of ReachableRecords/shared handles | candidate scratch plus monotonic decoded charge, promoted to retained only at atomic step 11 | each output array and all outputs concurrently, input destruction, unrelated handle non-retention |
| TS-SCR-22 | maximum simultaneous decoded token + graph indexes + layout memo + candidate output + already-produced opaque summaries | mixed retained and temporary | one shared Budget exact aggregate succeeds; one byte short fails before the next allocation; no reset/retry/new Budget |

### 11.1 TS-SCR-01..14 allocation-site oracle

A family total is not a sufficient one-byte-short oracle. RED owns an
independent, append-only table of allocation **site templates**. A site case is:

```text
{Family, FixtureVariant, SiteKind, PrimaryIndex, SecondaryIndex,
 TertiaryIndex, ExpectedStage}
```

`SiteKind` names a semantic wire/captured coordinate from the table below; it
is not an allocation-probe enum generated by production. Indices select the
concrete first/middle/last/nested occurrence. The independent all-fields wire
inventory maps that coordinate to the expected ByteOffset. The Runtime probe
is deliberately semantic-blind: it may report only a generic chronological
allocation/reservation event stream and raw counter values. It MUST NOT return
or echo `FixtureVariant`, `SiteKind`, P/S/T indices, expected Stage,
ByteOffset, site choice, lifetime disposition, exact limit, or one-byte-short
limit. The test already owns the fixture and must derive all of those values
without asking production which semantic site it observed.

The probe itself is allocation-free: an explicit synchronous per-call sink writes
only into a caller-provided fixed-capacity event view and records overflow without
growing or logging. The unit-test façade forwards that view into the same private
factory used by the public unobserved call; there is no scoped/TLS/global active
probe or nested ambient state. It observes chronology and raw allocator/Budget
facts only and exposes no production mutation authority.

| Family | Required site templates | Expected stage |
|---|---|---|
| TS-SCR-01 | one shared token/controller block owned by PayloadSchemaVersion; one token-owned canonical-payload byte-array allocation whose requested count is the canonical payload byte count and whose charged size is its actual allocator capacity; flat token/header offset block; CanonicalNamespace; CanonicalName; CanonicalDeclaration; top-level Metadata array; MetadataEntry key string; MetadataEntry value string; parallel metadata-offset array | PayloadDecode |
| TS-SCR-02 | Relations array and parallel relation-offset array | PayloadDecode |
| TS-SCR-03 | LayoutInputs array and parallel layout-input-offset array | PayloadDecode |
| TS-SCR-04 | OrderedProperties array and parallel property-row-offset array | PayloadDecode |
| TS-SCR-05 | each Property canonical-name string; every recursive CanonicalDataType OrderedSubTypes array at its pre-order node; each Property Metadata array/key/value string; parallel nested datatype/property-metadata offset arrays | PayloadDecode |
| TS-SCR-06 | OrderedMethods array and parallel method-offset array | PayloadDecode |
| TS-SCR-07 | VirtualFunctionTable array and parallel VFT-offset array | PayloadDecode |
| TS-SCR-08 | OrderedBehaviorSlots array and parallel behavior-offset array; DeclaringOwner optional storage is inline and therefore is not a separate allocator site | PayloadDecode |
| TS-SCR-09 | Enum OrderedEnumerators array, each enumerator name string, Metadata array/key/value strings and parallel offsets; a physically present nonzero Typedef CanonicalDataType subtype array declared `InvalidFixtureOnly`; flat selected-arm offset block. A legal Typedef primitive alias separately proves a zero-event validation checkpoint but does not change this physical site's disposition. Delegate and Funcdef store only inline SignatureFunctionKey, ExpectedSignatureAbi, and bMulticast and therefore have no signature-string/container DTO site | PayloadDecode |
| TS-SCR-10 | Reflection ConfigName string; StaticClassGlobalName string; OrderedUFunctionMembers array; parallel reflection/member-offset array | PayloadDecode |
| TS-SCR-11 | Dependencies array and parallel dependency-offset array; Required expanded success variants use only dependencies exactly derived by TypeSchema (`Inheritance`, `ValueLayout`, `Declaration`, `Signature`, `EnvironmentAbi`), while other enum variants remain semantic invalid-input coverage | PayloadDecode |
| TS-SCR-12 | every actual retained local canonical/duplicate/conflict index site, separately for Metadata, Relations, LayoutInputs, Dependencies, Enum metadata, Property metadata, and any combined-live implementation site; an omitted streaming site has no event | LocalSemantic |
| TS-SCR-13 | each actual property replay scratch container, if any; the preferred streaming implementation instead has no event | LocalSemantic |
| TS-SCR-14 | each actual Method, VFT, Behavior, and UFunction ordinal/duplicate scratch container, if any; a streaming positional check has no event | LocalSemantic |

Every template declares one test-owned disposition: `Required`,
`StreamingZero`, or `InvalidFixtureOnly`. Every `Required` template must expand
in at least one fixture and match exactly one event. `StreamingZero` must be
declared statically and proves zero event/attempt/bytes; a production
`bProvenZeroAllocation` result is not an oracle. `InvalidFixtureOnly` is never
used to prove success-path site exhaustion.

The Typedef subtype allocation template is the canonical V1 example of this
distinction: a legal primitive alias reaches the subtype-count checkpoint with zero
allocation, while a hostile physically encoded nonzero count can allocate before
the later Typedef semantic rejection. The former is checkpoint coverage; the latter
is the single `InvalidFixtureOnly` allocation template that proves Budget and
candidate cleanup. It is never reclassified as Required or StreamingZero merely to
preserve a previous disposition count.

For variable-length sites, RED expands each template at empty, one, the first
slack boundary of that site's **actual element/allocator type**, many, first,
middle, last, and recursive positions as applicable. A family-level boundary
selected from one representative element type is insufficient. A fixture
variant may expand to multiple site cases, including all nonempty baseline
fields and physical union-arm data that remain allocated before a later local
failure. Testing only one probe-selected allocation per `{Family,Variant}` does
not satisfy this table.

For each nonzero site case:

1. derive requested element count, element type/alignment, capacity and bytes
   independently from the fixture and the actual UE allocator authority
   (`CalculateSlackReserve` plus checked element size, or an equivalently
   independent concrete-container oracle); the observed requested capacity is
   comparison data only;
2. construct the complete expected chronological event list and its Total,
   retained Resident, active Temporary, PeakLive and reference/relocation
   prefixes without reading any observed entry counters; decoded-token site events
   extend Temporary and a separate final checkpoint promotes their aggregate once;
3. compare the generic observed event at the same chronological index to the
   test-owned expected site; unordered scanning or production semantic tags do
   not establish chronology;
4. require observed requested/charged bytes to equal the independent value;
5. run distinct Total one-byte-short and Resident one-byte-short cases over the
   exact same expanded site/occurrence/slack case set, each
   derived from the independent prefix plus `ExpectedCharge - 1`, never from a
   production helper or event-entry counter;
6. require `BudgetExceeded` at the static table's Stage and independently
   scanned wire/captured ByteOffset, including the tertiary coordinate where
   applicable;
7. require target and later allocation-attempt/event counters unchanged across
   the rejected reservation, output reset, entry retained state preserved, and
   temporary/live allocator state restored exactly; and
8. for every reference-bearing fixture independently count all nested
   reference/relocation consumes, prove exact-limit success, and prove a
   one-short failure at the first overflowing enclosing-field coordinate.

Zero-allocation variants require a static `StreamingZero` disposition, no
observed site event, and unchanged Budget and allocation counters.
`GetTargetFamilyAllocationStage`,
`GetTargetFamilyAllocationByteOffset`, and
`MakeOneByteShortLimitsBeforeTargetFamilyAllocation`-style production helpers
are forbidden as expected-result oracles. A narrow read-only event stream is
permitted only for generic observed facts checked against the independent
table; semantic site/variant/coordinate echoes are forbidden.

TS-SCR-21 aliases the same physical candidate-output sites documented by
MS-SCR-21. They are charged and promoted exactly once; the two matrices provide
coverage lenses, not permission to double charge. All other shared graph sites
likewise have one physical allocation and one reservation.

The immutable captured-offset table is not an extra allocation family. Its
parallel arrays are charged and tested with the matching TS-SCR-01..11 DTO
family; the flat token/header offset block is part of TS-SCR-01. Omitting an
offset array from the combined exact/one-byte-short proof is a budget failure.

Parameterize every row at empty, one, allocator-slack boundary, and many values.
For each allocation family prove:

- exact allocator-capacity limit succeeds;
- one byte short fails before reserve/grow and leaves the allocation probe
  unchanged;
- pre-existing active reservations and sentinel output remain unchanged on
  failed acquisition;
- success, early decode failure, semantic/hash failure, graph failure, current
  miss, and late pre-publication failure restore temporary resident bytes to the
  entry value; and
- persistent/retained counters and bytes remain charged exactly once.

A generic tiny cumulative-budget failure is not a substitute for these rows.

## 12. Required RED fixtures

In addition to the existing TypeSchema matrix, Task 2B-2 RED must add:

1. byte goldens and one-byte truncation/invalid-enum cases at every new field;
2. all Property StorageKind x CanonicalDataType/qualifier legal and illegal
   combinations;
3. storage size/alignment zero, non-power-of-two, above-int32, hash mismatch,
   and otherwise self-consistent wrong-coordinate cases; include a present-zero
   Base boundary that remains distinct from an absent Base input;
4. BaseType, CodeRoot, and StructHeader positive fixtures and every
   missing/extra/wrong-target/wrong-role/hash mutation;
5. derived AS class whose Base TypeSchema is linked and a cross-module Base
   whose TypeSchema is deliberately absent from the root;
6. ordinary UClass with and without script Base, proving CodeRoot boundary is
   selected only in the no-Base root while shadow alignment contributes in both
   because it is installed from PreClassData before LayoutClass;
7. reflected UStruct proving ScriptValueOffset boundary and absent header
   alignment contribution without live inference;
8. EnvironmentType property, nested instantiated environment value type,
   ScriptType inline value, and ScriptType object handle;
   include a typedef-int8 property proving canonical primitive `{size=1,
   alignment=1}` while its independent Typedef TypeSchema remains
   `{size=1,alignment=4}`;
9. same-module linked layout disagreement paired with current resolver failure,
   proving `GraphAbiMismatch` wins;
10. a cold exact-hit graph whose fixture resolvers contain no selected-module
    Script* entries: same-module Base, InlineValue ScriptType, ObjectHandle, and
    local Script* dependencies still succeed with zero `CurrentSymbols` and
    zero `CurrentLayouts` calls for those coordinates;
11. cross-module/environment single-witness current equal/missing/different
    controls, proving only eligible current failures occur after stored graph
    success;
12. an EnvironmentType template nested over a selected-module InlineValue
    ScriptType, proving the recipe uses `LocalLayouts` before any local live type
    exists and does not turn that subtype into a current-layout call;
13. pure fixture resolver call-order and at-most-once tests with no AS engine or
    UObject, including one CodeRoot result reused by root and script-derived
    consumers whose stored boundary-presence masks differ;
14. every precedence pair in section 10 with exact Error, Stage, RecordKind and
    captured ByteOffset, including LayoutInputHash versus property fingerprint,
    property versus Dependencies, and EnumAuthorityHash versus TypeLayoutHash;
    and
15. the complete parameterized TS-SCR-01..22 allocator matrix.

## 13. Integration gates

Before TypeSchema receives final approval:

1. merge these exact enums/fields/hash streams into
   `record-wire-v1-remaining.md`;
2. merge the authority/error/budget summary into `type-schema-matrix-v1.md`,
   `record-schema.md`, `design.md`, implementation plan, tasks, traceability, and
   the incremental-cache delta spec;
3. make the normative 11-step graph explicitly perform linked stored-layout
   checks in step 4/9 and current layout comparison only in step 10;
4. make all local record readers check trailing-data immediately after complete
   physical decode and before semantics/hashes;
5. freeze the environment catalog's runtime StructHeader coordinate and current
   layout lookup boundary without implementing a process-global fallback;
6. run strict OpenSpec validation, diff checks, and a fresh independent read-only
   TypeSchema approval; and
7. start Task 2B-2 RED only after the result is 0 Critical / 0 Important.
