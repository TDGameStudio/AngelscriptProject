# Cache V2 Task 2B-1 Record Wire V1

## Status and authority

This document is the normative byte-level contract for Task 2B-1 canonical
values, `SourceIndex`, and `ModuleInterface`. It closes the implementation
choices that must be fixed before byte-golden RED tests are written. For these
types it overrides abbreviated C++ sketches in `implementation-plan.md`;
`record-schema.md` remains authoritative for ownership across all seven record
kinds.

V1 is pointer-free and value-only. It does not construct an AngelScript engine,
discover live source, modify `IAngelscriptSourceProvider`, attach declarations,
or access a filesystem store. Producers added later must populate exactly these
values rather than introducing another cache representation.

## Canonical scalar encoding

All integers are unsigned little-endian fixed-width values. No native enum,
`FArchive <<`, C++ object layout, padding, `FName` index, pointer, numeric type
ID, or numeric FunctionId is a wire value.

| Value | V1 encoding |
|---|---|
| enum or tag | `u8`; unknown values reject |
| flags | `u32`; unknown bits reject |
| declaration trait, reflection, parameter trait, qualifier, capability, or filter flags | `u32`; unknown bits reject |
| payload schema, ordinal, array count | `u32` |
| byte size and budget accounting | `u64` |
| boolean | one `u8`, exactly `0` or `1` |
| optional | one `u8`: `0` absent, `1` present, followed by the value only when present |
| hash or stable key | exactly 32 bytes in `FAngelscriptHash256` byte order |
| string | `u32` UTF-8 byte count followed by exact bytes |
| byte payload | `u64` byte count followed by exact bytes |
| array | `u32` element count followed by elements |

Every semantic record begins with `PayloadSchemaVersion:u32`; V1 requires
value `1`. Strings use strict UTF-8, prohibit embedded NUL, and preserve exact
decoded bytes. V1 performs no NFC, NFD, locale, or other Unicode
normalization. Before allocation a reader checks scalar availability, checked
`count * minimum element bytes`, field/record/session budgets, and nesting.
Trailing payload bytes reject the record.

The same caller-owned `FAngelscriptCacheReadBudget` also owns semantic-
validation and eligibility-query scratch memory. Persistent counters for stored,
decompressed, decoded, retained decoded values, and references remain monotonic.
Temporary scratch uses a live-resident RAII reservation: checked byte size is
reserved before `Reserve`, `SetNum*`, sorting-index construction, queue growth,
or any equivalent allocation, and the reservation is released on every success
or failure exit. A failed reservation changes no budget counter and performs no
allocation. At all times, retained decoded bytes plus active scratch bytes must
not exceed `MaxResidentDecodedBytes`; releasing scratch never refunds a
persistent consumed counter.

The existing record envelope and its fixed 56-byte header remain unchanged. A semantic payload is
encoded first, including all stored derived hashes, and the existing envelope
then computes the RecordId over that complete canonical payload.

## Stable V1 enums and flags

Zero is invalid unless this document explicitly names a valid zero value.

```text
EAngelscriptCacheCodec : u8
  None=0, Zlib=1

EAngelscriptCacheRecordKind : u8
  Invalid=0
  SourceIndex=1, ModuleInterface=2, TypeSchema=3, ModuleState=4,
  FunctionBody=5, DebugSidecar=6, ModuleSnapshot=7

EAngelscriptCacheReferenceKind : u8
  Invalid=0
  ScriptModule=1, ScriptType=2, ScriptFunction=3, ScriptGlobal=4,
  ScriptProperty=5, ScriptImport=6, EnvironmentSymbol=7,
  CanonicalName=8, StringLiteral=9

EAngelscriptCachedDataTypeKind : u8
  Invalid=0, Primitive=1, ScriptType=2, EnvironmentType=3, Auto=4

EAngelscriptCachedPrimitiveType : u8
  Invalid=0, Void=1, Bool=2,
  Int8=3, Int16=4, Int32=5, Int64=6,
  UInt8=7, UInt16=8, UInt32=9, UInt64=10,
  Float32=11, Float64=12

EAngelscriptCacheDeclarationKind : u8
  Invalid=0, Type=1, Function=2, Global=3, Property=4

EAngelscriptCacheSchemaCoverage : u8
  Invalid=0, Forbidden=1, Required=2

EAngelscriptCacheBodyCoverage : u8
  Invalid=0, Forbidden=1, Required=2

EAngelscriptCacheDeclarationSlotKind : u8
  Invalid=0, Declaration=1, Function=2, VirtualFunction=3, Import=4

EAngelscriptCachedParameterPassing : u8
  Invalid=0, Value=1, InReference=2, OutReference=3,
  InOutReference=4

EAngelscriptCacheSemanticDependencyKind : u8
  Invalid=0, Import=1, Declaration=2, Signature=3, Inheritance=4,
  ValueLayout=5, PropertyLayout=6, GlobalStorage=7, HardValue=8,
  Initializer=9, CompileOption=10, EnvironmentAbi=11

EAngelscriptCachePreprocessorInputKind : u8
  Invalid=0, IncludeFile=1, Define=2, ConditionalSymbol=3,
  GeneratedSource=4

EAngelscriptCachedSourceKind : u8
  Invalid=0, Game=1, Plugin=2, Memory=3

EAngelscriptCachedSourceProviderKind : u8
  Invalid=0, BuiltInDisk=1, Memory=2, Generated=3, External=4

EAngelscriptCachedPreprocessHookPhase : u8
  Invalid=0, ProcessChunks=1, PostProcessCode=2, External=3

EAngelscriptCachedSourceEdgeKind : u8
  Invalid=0, Include=1, GeneratedSource=2

EAngelscriptCachedFastPathScopeKind : u8
  Invalid=0, Mount=1, Provider=2, Hook=3, SourceFile=4, Module=5

EAngelscriptCachedFastPathIneligibleReason : u8
  Invalid=0, MissingStableIdentity=1, MissingVersionFingerprint=2,
  MissingConfigurationFingerprint=3, UnstableGeneratedSource=4,
  UnknownHookBehavior=5

EAngelscriptCachePreprocessorInputTargetKind : u8
  None=0, SourceFile=1, Provider=2, Hook=3, Module=4,
  GeneratedSource=5
```

`Generated` and `External` are provider kinds, never source kinds. The current
runtime `EAngelscriptSourceKind` is not serialized directly. AngelScript `int`
and `uint` canonicalize to `Int32` and `UInt32`. V1 has no `Wildcard` primitive;
encountering a declaration that cannot be represented is an eligibility/build
failure, not permission to persist a maintained-fork token number.

The existing identity values remain fixed and are not renumbered:

```text
EAngelscriptFunctionOwnerKind : u8
  Invalid=0, Module=1, Type=2, Global=3, Property=4

EAngelscriptArtifactEntityKind : u8
  Class=1, Struct=2, Interface=3, Enum=4, Delegate=5,
  Typedef=6, Funcdef=7,
  GlobalVariable=16, Property=17,
  GlobalFunction=32, Method=33, Constructor=34, Destructor=35,
  Factory=36, DelegateSignature=37, ModuleInitializer=38,
  GlobalInitializer=39, GeneratedDefaultConstructor=40, InitDefaults=41
```

Type qualifier flags are:

```text
Reference=0x00000001
ObjectConst=0x00000002
ObjectHandle=0x00000004
ConstHandle=0x00000008
Auto=0x00000010
IfHandleThenConst=0x00000020
KnownMask=0x0000003f
```

`DataTypeKind::Auto` and the `Auto` qualifier are both retained and must agree:
an Auto value has both; every non-Auto value has neither. `ConstHandle`
requires `ObjectHandle`; handle-only flags are forbidden on primitives; an
unknown or impossible combination is malformed.

Discovery filter flags are:

```text
SkipDevelopment=0x00000001
SkipEditor=0x00000002
KnownMask=0x00000003
```

Provider and hook fingerprint capability flags are:

```text
StableIdentity=0x00000001
VersionFingerprint=0x00000002
ConfigurationFingerprint=0x00000004
ContentFingerprint=0x00000008
KnownMask=0x0000000f
```

`StableIdentity` set requires the fixed IdentityFingerprint to be nonzero; when
unset that field is zero. Every other set capability requires its corresponding
optional fingerprint to be present and nonzero; an unset capability requires
the optional to be absent. Missing capabilities are represented by
`IneligibleScopes`, not by inventing a process address or 64-bit timestamp/hash
identity.

Capability and its corresponding same-scope missing reason are bidirectional.
For each Provider, the exact mapping is:

| Capability | Required/forbidden `{Provider, ProviderKey}` reason |
|---|---|
| StableIdentity | MissingStableIdentity |
| VersionFingerprint | MissingVersionFingerprint |
| ConfigurationFingerprint | MissingConfigurationFingerprint |
| ContentFingerprint | UnstableGeneratedSource |

For each Hook, the exact mapping is:

| Capability | Required/forbidden `{Hook, HookKey}` reason |
|---|---|
| StableIdentity | MissingStableIdentity |
| VersionFingerprint | MissingVersionFingerprint |
| ConfigurationFingerprint | MissingConfigurationFingerprint |
| ContentFingerprint | UnknownHookBehavior |

An unset capability requires exactly one matching scope/key/reason entry; a set
capability forbids that matching missing reason. Exact duplicate ineligible
rows are already `DuplicateKey`. Other independent reasons remain permitted
only when their own scope semantics apply; they do not satisfy a different
missing capability. Any missing, wrong-scope, wrong-key, or contradictory
capability/reason pair returns `InvalidPresence`.

Declaration trait flags are:

```text
Static=0x00000001
Const=0x00000002
Private=0x00000004
Protected=0x00000008
ThreadSafe=0x00000010
Abstract=0x00000020
Final=0x00000040
Override=0x00000080
Generated=0x00000100
KnownMask=0x000001ff
```

Reflection flags are:

```text
BlueprintCallable=0x00000001
BlueprintOverride=0x00000002
BlueprintEvent=0x00000004
BlueprintPure=0x00000008
NetMulticast=0x00000010
NetClient=0x00000020
NetServer=0x00000040
NetValidate=0x00000080
Unreliable=0x00000100
BlueprintAuthorityOnly=0x00000200
Exec=0x00000400
CanOverrideEvent=0x00000800
BlueprintReadable=0x00001000
BlueprintWritable=0x00002000
KnownMask=0x00003fff
```

Parameter trait flags are:

```text
BlueprintByValue=0x00000001
BlueprintOutRef=0x00000002
BlueprintInRef=0x00000004
KnownMask=0x00000007
```

V1 has no additional call-mask field. Signature call semantics are derived
from DeclarationKind/EntityKind/owner, canonical data types and parameter
passing, declaration trait/reflection flags, and parameter trait flags. A
producer feature that cannot be represented by these masks is NotCacheable and
requires a future schema/flag definition; it is never silently dropped. V1
readers reject every unknown bit. Type/property/reflection details outside
these declaration-level masks belong to Task 2B-2 TypeSchema.

## Typed source keys

The following C++ wrappers all contain one full nonzero `FAngelscriptHash256`
but remain distinct types to prevent accidental cross-kind comparison:

```text
FAngelscriptCachedSourceMountKey
FAngelscriptCachedSourceProviderKey
FAngelscriptCachedPreprocessHookKey
FAngelscriptCachedSourceFileKey
FAngelscriptCachedPreprocessorInputKey
FAngelscriptCachedSourceEdgeKey
```

Every source sub-key is produced with the existing
`FAngelscriptArtifactCanonicalWriter`. Consequently its input stream is exactly
ASCII `UEAS-ARTIFACT`, one NUL, little-endian
`IdentitySchemaVersion=1`, the writer's length-prefixed domain, followed by the
fields below; `FinalizeHash()` supplies BLAKE3-256.

```text
MountKey = H("cache-source-mount",
  SourceKind, LogicalMount, ProviderKey)

ProviderKey = H("cache-source-provider",
  ProviderKind, CanonicalImplementationIdentity, IdentityFingerprint)

HookKey = H("cache-preprocess-hook",
  HookPhase, CanonicalImplementationIdentity, AffectedScopeKind,
  AffectedScopeStableKey)

SourceFileKey = H("cache-source-file",
  SourceKind, MountKey, ProviderKey, RelativeLogicalPath,
  OptionalGeneratedSourceKey)

InputKey = H("cache-preprocessor-input",
  OwnerScopeKey, InputKind, CanonicalName, OptionalTargetStableKey)

EdgeKey = H("cache-source-edge",
  EdgeKind, FromSourceKey, ToSourceOrGeneratedKey,
  CanonicalIncludeOrGeneratorIdentity)
```

The optional values use the canonical `u8` optional tag. Version,
configuration, observed content, raw source content, and timestamps never
enter these stable keys; their explicit fingerprints enter `SourceSnapshot`.

When `AffectedScopeKind=Hook`, `AffectedScopeStableKey` is the already-built
key of the affected Hook. HookKey therefore remains a direct derived-key
formula; it is not obtained by iterating a graph hash to a fixed point. A
self-reference or multi-Hook cycle that also satisfies every stored HookKey
would require constructing a BLAKE3-256 fixed point. Such a value is not a
valid producer input for V1. The producer builds Hook keys from non-Hook scopes
outward through an acyclic authority chain. The decoder recomputes every
HookKey from its stored identity fields before graph resolution, so a manually
forged cyclic row set fails `DerivedHashMismatch` before eligibility is
queried. V1 adds no cycle-specific error and no graph-hashing algorithm.

### Public typed source-key builders

The six algorithms above have one public fail-closed Runtime implementation;
record encoders, Task 4 producers and tests MUST call it rather than duplicate
domain strings or canonical streams. The API surface is:

```cpp
FAngelscriptCacheValidationResult TryBuildSourceMountKey(
	const FAngelscriptSourceMountIdentityInput& Input,
	FAngelscriptCachedSourceMountKey& OutKey);
FAngelscriptCacheValidationResult TryBuildSourceProviderKey(
	const FAngelscriptSourceProviderIdentityInput& Input,
	FAngelscriptCachedSourceProviderKey& OutKey);
FAngelscriptCacheValidationResult TryBuildPreprocessHookKey(
	const FAngelscriptPreprocessHookIdentityInput& Input,
	FAngelscriptCachedPreprocessHookKey& OutKey);
FAngelscriptCacheValidationResult TryBuildSourceFileKey(
	const FAngelscriptSourceFileIdentityInput& Input,
	FAngelscriptCachedSourceFileKey& OutKey);
FAngelscriptCacheValidationResult TryBuildPreprocessorInputKey(
	const FAngelscriptPreprocessorInputIdentityInput& Input,
	FAngelscriptCachedPreprocessorInputKey& OutKey);
FAngelscriptCacheValidationResult TryBuildSourceEdgeKey(
	const FAngelscriptSourceEdgeIdentityInput& Input,
	FAngelscriptCachedSourceEdgeKey& OutKey);
```

Each input contains exactly the fields shown in its hash formula and no stored
derived key, version/configuration/content fingerprint, source bytes, time,
address, or diagnostic field. The builder validates enum/tag/optional/strict-
UTF-8/logical-path/nonzero referenced-key rules applicable to those identity
fields, writes through `FAngelscriptArtifactCanonicalWriter`, and resets OutKey
to zero before any work. Failure returns the typed error and leaves zero;
success returns one nonzero typed full hash. There is no unchecked public hash
helper or encoder-private alternative.

Task 2B-1 RED freezes one independent full-hash vector for each public builder,
plus invalid enum, optional, UTF-8/path and referenced-key cases with zero
output. Encoder derived-key recomputation must match the same public result.

## Common value wire order

### Canonical data type

Fields are written in this exact order:

```text
Kind:u8
Primitive:u8
TypeReference:optional<StableReference>
QualifierFlags:u32
OrderedSubTypes:array<CanonicalDataType>
```

Presence rules are:

- `Primitive`: non-Invalid Primitive, absent TypeReference;
- `ScriptType`: Invalid Primitive, present `ScriptType` reference;
- `EnvironmentType`: Invalid Primitive, present `EnvironmentSymbol` reference;
- `Auto`: Invalid Primitive, absent TypeReference, Auto qualifier set;
- subtype order is semantic and is never sorted.

Every recursive value consumes nesting and element budgets before allocation.

### Stable reference

```text
ReferenceKind:u8
StableKey:hash256
ExpectedAbi:hash256
```

Script module/type/function/global/property/import and environment references
require nonzero StableKey and ExpectedAbi. CanonicalName and StringLiteral
require nonzero StableKey, zero ExpectedAbi, and matching canonical bytes in
their owning payload. Null is represented only by an enclosing optional.

### Typed semantic dependency

```text
DependencyKind:u8
Target:StableReference
ExpectedContentOrValue:optional<hash256>
```

The active development-schema presence matrix (V1 base plus the append-only
V4.4 FunctionContent kind) is:

| Dependency kind | ExpectedContentOrValue |
|---|---|
| Import, Declaration, Signature, Inheritance, EnvironmentAbi | absent |
| ValueLayout, PropertyLayout, GlobalStorage, HardValue, CompileOption, Initializer, FunctionContent | present and nonzero |

ValueLayout content is the target TypeLayoutHash; PropertyLayout content is the
target PropertyLayoutFingerprint. In both cases Target.ExpectedAbi remains the
target declaration SignatureHash. FunctionContent is the append-only V4.4 kind
and carries the target FunctionBody execution hash. An order-only initializer
dependency requires a future kind/schema; the optional field is always the
exact semantic projection named by DependencyKind.

Property storage selects the dependency kind rather than the DataType tag alone:
InlineValue ScriptType/EnvironmentType derives ValueLayout, ObjectHandle
ScriptType derives Declaration, and ObjectHandle EnvironmentType derives
EnvironmentAbi. The handle target never contributes TypeLayoutHash because the
slot size/alignment is owned by the selected Compatibility/Profile constants.

### Metadata, option, parameter, and slot

```text
MetadataEntry:
  CanonicalKey:string
  CanonicalValue:string

CanonicalOption:
  CanonicalKey:string
  ValueFingerprint:hash256

Parameter:
  Ordinal:u32
  CanonicalName:string
  Type:CanonicalDataType
  Passing:u8
  CanonicalDefaultExpression:optional<string>
  TraitFlags:u32

DeclarationSlot:
  SlotKind:u8
  Ordinal:u32
```

Default-expression presence and exact canonical bytes are caller-visible
declaration semantics. They enter SignatureHash and InterfaceAbi. If the
compiler later embeds a resolved value, Task 4 additionally records a
HardValue dependency; the declaration hash does not replace that dependency.

## SourceIndex V1 wire order

The record fields are:

```text
PayloadSchemaVersion:u32 = 1
SourceSnapshot:hash256
DiscoveryPolicy:SourceDiscoveryPolicy
Mounts:array<SourceMount>
Providers:array<SourceProvider>
PreprocessHooks:array<PreprocessHook>
Files:array<SourceFile>
PreprocessorInputs:array<PreprocessorInput>
Edges:array<SourceEdge>
IneligibleScopes:array<FastPathIneligibleScope>
```

There is no global `bExactFastPathEligible` and no separate
source-to-module mapping. `SourceFile.ModuleKey` is the sole wire authority;
the mapping is derived from canonical Files.

Subrecords use this exact field order:

```text
SourceDiscoveryPolicy:
  PolicyVersion:u32
  FilterFlags:u32
  Options:array<CanonicalOption>

SourceMount:
  MountKey:SourceMountKey
  SourceKind:u8
  LogicalMount:string
  ProviderKey:SourceProviderKey
  RootConfigurationFingerprint:hash256
  Options:array<CanonicalOption>

SourceProvider:
  ProviderKey:SourceProviderKey
  ProviderKind:u8
  CanonicalImplementationIdentity:string
  IdentityFingerprint:hash256
  VersionFingerprint:optional<hash256>
  ConfigurationFingerprint:optional<hash256>
  ContentFingerprint:optional<hash256>
  CapabilityFlags:u32

PreprocessHook:
  HookKey:PreprocessHookKey
  Phase:u8
  CanonicalImplementationIdentity:string
  AffectedScopeKind:u8
  AffectedScopeStableKey:hash256
  IdentityFingerprint:hash256
  VersionFingerprint:optional<hash256>
  ConfigurationFingerprint:optional<hash256>
  ContentFingerprint:optional<hash256>
  CapabilityFlags:u32

SourceFile:
  SourceFileKey:SourceFileKey
  SourceKind:u8
  MountKey:SourceMountKey
  ProviderKey:SourceProviderKey
  RelativeLogicalPath:string
  RawContentHash:hash256
  GeneratedSourceKey:optional<hash256>
  GeneratedConfigurationFingerprint:optional<hash256>
  ModuleKey:StableModuleKey

PreprocessorInput:
  InputKey:PreprocessorInputKey
  OwnerScopeKind:u8
  OwnerScopeStableKey:hash256
  InputKind:u8
  CanonicalName:string
  TargetKind:u8
  TargetStableKey:optional<hash256>
  EffectiveValueOrContentHash:hash256

SourceEdge:
  EdgeKey:SourceEdgeKey
  EdgeKind:u8
  FromSourceFileKey:SourceFileKey
  ToSourceOrGeneratedKey:hash256
  CanonicalIncludeOrGeneratorIdentity:string
  SemanticOrdinal:optional<u32>

FastPathIneligibleScope:
  ScopeKind:u8
  ScopeStableKey:hash256
  Reason:u8
  CanonicalDiagnosticIdentity:string
  ObservedFingerprint:optional<hash256>
```

`TargetKind=None` requires absent TargetStableKey; every other TargetKind
requires a present nonzero key of that tagged kind. `GeneratedSourceKey` and
`GeneratedConfigurationFingerprint` are both present only for generated input;
raw generated content still uses `RawContentHash`. Game, Plugin, and Memory
remain the only SourceKind values regardless of provider kind.

Host absolute roots never appear. `RelativeLogicalPath` passes the typed
logical-path validator: reject empty, drive, UNC, slash-rooted, embedded-NUL,
or escaping `..`; normalize separators and removable `.` segments before
encoding.

Source records accept raw-byte BLAKE3-256 and explicit full fingerprints. Task
2B-1 does not change the current provider. A later producer must gain raw-byte
and fingerprint capabilities; `FAngelscriptSourceState`'s 64-bit state hash is
never promoted to `RawContentHash` or any stable identity.

### SourceIndex canonical order and duplicate keys

| Collection | Wire order | Duplicate/conflict authority |
|---|---|---|
| policy or mount Options | key UTF-8, then full value fingerprint | CanonicalKey |
| Mounts | SourceKind, LogicalMount UTF-8, ProviderKey, MountKey | MountKey; the same logical coordinate with a different key conflicts |
| Providers | ProviderKind, implementation identity UTF-8, ProviderKey | ProviderKey |
| Hooks | Phase, implementation identity UTF-8, HookKey | HookKey |
| Files | SourceKind, MountKey, ProviderKey, relative path UTF-8, SourceFileKey | SourceFileKey; a folded path collision is separate |
| Inputs | OwnerScopeKey, InputKind, name UTF-8, target key, InputKey | InputKey |
| Edges | EdgeKind, from key, to key, EdgeKey | EdgeKey |
| IneligibleScopes | ScopeKind, scope key, Reason | `{ScopeKind, ScopeKey, Reason}`; one scope may carry several distinct reasons |

Set-like arrays are sorted by their row before writing. A reader rejects
unique but unsorted bytes. Exact duplicates return `DuplicateKey`; the same
authority key with different owner/content/ABI returns `ConflictingKey`.
SemanticOrdinal, when present, is validated as a unique contiguous `0..N-1`
set within the same `{FromSourceFileKey, EdgeKind}` group. Presence is
all-or-none per group: every edge in one
group either has no SemanticOrdinal, or every edge has one and the values form
the complete contiguous sequence. Mixed present/absent ordinals return
`InvalidPresence`. The edge array remains sorted by stable row rather than
ordinal, so group sequence validation uses the explicit values and not global
array position.

Path collision checking decodes the exact UTF-8 path to `TCHAR`, walks Unicode
scalar values with `FTextChar::GetCodepoint`, applies `FTextChar::ToLower` once
per decoded code point, and compares the resulting code-point sequence. This
one-code-point invariant lowercase mapping is only a collision detector: it
does not perform multi-code-point full case folding and never changes stored
path bytes or identity inputs. CompatibilityKey isolates the engine Unicode/
lowercase implementation. V1 goldens must cover ASCII case collision, a
non-ASCII BMP policy vector, and a supplementary-plane/code-point traversal
vector so UTF-16 surrogate halves are never folded independently.

### SourceIndex typed reference graph

A locally canonical SourceIndex is not publishable until every internal typed
reference resolves. Build typed indexes for MountKey, ProviderKey, HookKey,
SourceFileKey, the set of present `SourceFile.GeneratedSourceKey` values, and
the set of ModuleKey values derived exclusively from `SourceFile.ModuleKey`.
There is no second module table.

Every present GeneratedSourceKey has exactly one SourceFile authority in one
SourceIndex. Repeating the same SourceFile is already `DuplicateKey` by
SourceFileKey; two distinct Files that claim the same GeneratedSourceKey return
`ConflictingKey` before target/edge resolution. GeneratedSource target lookup
therefore always resolves one producing File rather than an ambiguous set.

The exact resolution matrix is:

| Reference | Required authority and consistency |
|---|---|
| `Mount.ProviderKey` | one Provider with that ProviderKey |
| `File.MountKey` | one Mount; File.SourceKind and File.ProviderKey equal the resolved Mount's SourceKind and ProviderKey |
| `Hook.{AffectedScopeKind,AffectedScopeStableKey}` | Mount/Provider/Hook/File/derived Module set selected by ScopeKind |
| `Input.{OwnerScopeKind,OwnerScopeStableKey}` | Mount/Provider/Hook/File/derived Module set selected by ScopeKind |
| `IneligibleScope.{ScopeKind,ScopeStableKey}` | Mount/Provider/Hook/File/derived Module set selected by ScopeKind |
| `Input.TargetKind=SourceFile` | SourceFile index |
| `Input.TargetKind=Provider` | Provider index |
| `Input.TargetKind=Hook` | Hook index |
| `Input.TargetKind=Module` | ModuleKey set derived from Files |
| `Input.TargetKind=GeneratedSource` | set of present File.GeneratedSourceKey values |
| `Edge.FromSourceFileKey` | SourceFile index |
| `EdgeKind=Include: ToSourceOrGeneratedKey` | SourceFile index |
| `EdgeKind=GeneratedSource: ToSourceOrGeneratedKey` | generated-source-key set |

`Input.TargetKind=None` retains its already-defined absent-key rule and performs
no lookup. ScopeKind never selects a GeneratedSource; generated keys are valid
only through the explicit input target or edge kind above.

Validation precedence after all scalar/presence/key/hash/order/duplicate/case
checks is fixed:

1. build the typed indexes and derived sets;
2. visit reference-bearing enclosing fields in the exact graph-phase wire
   order `Mounts`, `PreprocessHooks`, `Files`, `PreprocessorInputs`, `Edges`,
   `IneligibleScopes`; Providers contain no graph reference in this phase;
3. for each tagged reference, a key present in its required authority passes;
4. if absent there but the same full hash is present in any other typed source
   authority index/set, return `WrongReferenceKind`;
5. if absent from every source authority, return `MissingGraphTarget`; and
6. after every reference resolves, return `ConflictingKey` when two resolved
   authorities disagree, including File versus Mount SourceKind/ProviderKey.

Unknown tags remain the earlier `UnknownEnumValue`; malformed optional shape
remains the earlier `InvalidPresence`. The first failing field in canonical
wire order wins within each phase. V1 permits no dangling mount/provider/scope/
target/edge/generated/module source reference.

The validated Hook-to-Hook authority graph is consequently acyclic: base
Hooks are scoped to Module/File/Mount/Provider and later Hooks may scope to an
already-keyed Hook. Graph resolution does not attempt to repair, topologically
re-key, or solve cycles. Any hand-authored cycle has already failed the
derived-key phase above.

### SourceSnapshot

`SourceSnapshot` is recomputed with
`FAngelscriptArtifactCanonicalWriter("cache-source-snapshot-v1")` over, in
wire order:

```text
PayloadSchemaVersion
DiscoveryPolicy
canonical Mounts
canonical Providers including version/config/content/capability
canonical Hooks including version/config/content/capability
canonical Files including raw/generated fingerprints and ModuleKey
canonical PreprocessorInputs including effective hashes
canonical Edges
canonical IneligibleScopes
```

It excludes the stored SourceSnapshot field itself. A mismatch inside the
record is `DerivedHashMismatch/CanonicalSemantic`; comparison of a valid old
SourceSnapshot with current source is `SourceSnapshotMismatch/Ineligible`.

### Per-scope exact eligibility

`IneligibleScopes` is the sole authority; there is no stored or derived global
eligibility boolean. Task 2B-1 exposes this pure query over a locally validated
SourceIndex:

```cpp
struct FAngelscriptCacheExactFastPathEligibility
{
	bool bExactFastPathEligible;
	TArray<FAngelscriptCachedFastPathIneligibleScope> MatchingScopes;
};

FAngelscriptCacheValidationResult QueryExactFastPathEligibility(
	const FAngelscriptDecodedCacheRecord& SourceIndexRecord,
	const FAngelscriptStableModuleKey& ModuleKey,
	const FAngelscriptCacheReadLimits& Limits,
	FAngelscriptCacheReadBudget& Budget,
	FAngelscriptCacheExactFastPathEligibility& OutEligibility);
```

Task 2B-1 originally introduced a factory-only immutable
`FAngelscriptValidatedSourceIndex` before the common all-record factory
was frozen. Task 2B-2 removes that transitional public owning token: the
SourceIndex decoder reads into one private mutable candidate, captures
enclosing-field offsets, completes local/hash/order/duplicate/typed-graph
validation and all budgeted index construction, then publishes exactly one
`FAngelscriptDecodedCacheRecordHandle` through the common declared-RecordId
factory in `record-wire-v1-remaining.md`. The query accepts a non-owning const
view of that common record, first requires `RecordKind=SourceIndex`, and neither
copies nor re-runs SourceIndex preparation. Its closure queues and temporary
indexes use `Limits` and the same caller-owned `Budget` under the live-resident
scratch reservation contract above. There is no compatibility wrapper,
DTO-to-token constructor, second retained token, or second budget charge.

The function clears output on entry. If no SourceFile declares ModuleKey, it
returns `MissingGraphTarget` with empty output. Otherwise it computes this
closure:

1. select every File with the target ModuleKey;
2. add those files' resolved Mounts and Providers plus the ModuleKey itself;
3. select every Hook whose `{AffectedScopeKind, AffectedScopeStableKey}` is in
   the current Module/File/Mount/Provider/Hook closure, add its HookKey, and
   repeat until no new Hook is added; and
4. select every IneligibleScope whose typed scope/key is in the completed
   closure.

`MatchingScopes` is the exact selected row set in the same canonical comparator
order as SourceIndex.IneligibleScopes; filtering a canonical input must not
reorder it. It retains each matching reason, diagnostic identity and observed
fingerprint. `bExactFastPathEligible` is true iff MatchingScopes is empty.
Provider/hook missing-capability rows participate through the same closure;
other valid reasons are reported rather than collapsed.

A Hook scoped to another Hook affects a module only if the referenced Hook is
already in that module's affected-hook closure, hence the explicit fixed-point
rule. A Provider, Hook, Mount, File, or Module outside the closure cannot make
the target ineligible. Two modules in one validated SourceIndex may therefore
produce different results, and an ineligible scope in one closure leaves the
other exact-hit eligible.

This eligibility fixed point is transitive set closure over an already valid
acyclic authority graph; it is not a HookKey hash fixed point. Required tests
use a base-to-dependent Hook chain, a detached Hook chain plus an unrelated
module, and a manually forged self/multi-node cycle. The valid chain must close
transitively, detached/unrelated Hooks must not contaminate the target, and the
forged cycle must return `DerivedHashMismatch` during SourceIndex validation so
the query is never invoked for it.

## ModuleInterface V1 wire order

The record fields are:

```text
PayloadSchemaVersion:u32 = 1
ModuleKey:StableModuleKey
CanonicalModuleName:string
InterfaceAbi:hash256
CanonicalNamespaces:array<string>
Declarations:array<Declaration>
Imports:array<ImportDeclaration>
Dependencies:array<SemanticDependency>
```

CanonicalNamespaces contains only actually used nonempty namespaces. The
global namespace is the empty CanonicalNamespace in a declaration. Empty or
duplicate namespace-table entries are malformed.

### Complete declaration tagged union

Declaration fields are written in this exact order:

```text
DeclarationKind:u8
EntityKind:u8
SchemaCoverage:u8
BodyCoverage:u8
StableKey:hash256
OwnerKind:u8
OwnerKey:hash256
ModuleKey:StableModuleKey
CanonicalNamespace:string
CanonicalName:string
CanonicalDeclaration:string
CanonicalIdentityTraits:array<string>
CanonicalTypeSpelling:optional<string>
DeclaredType:optional<CanonicalDataType>
OrderedParameters:array<Parameter>
TraitFlags:u32
ReflectionFlags:u32
Metadata:array<MetadataEntry>
Slots:array<DeclarationSlot>
SignatureHash:hash256
TraitsHash:hash256
```

CanonicalIdentityTraits are sorted by exact UTF-8 bytes and contain no
duplicate. They are supplied to the existing identity builder when StableKey
is recomputed. Presence is:

| DeclarationKind | EntityKind and owner | CanonicalTypeSpelling | DeclaredType / parameters |
|---|---|---|---|
| Type | Class, Struct, Interface, Enum, Delegate, Typedef, or Funcdef; module-owned | absent | absent / empty |
| Function | a Task-1 callable kind; owner follows callable semantics | absent | present return type / ordered parameters |
| Global | GlobalVariable; module-owned | present | present value type / empty |
| Property | Property; type-owned | present | present value type / empty |

### Declaration owner graph and callable matrix

ModuleInterface resolves every local declaration owner before publication. Type
and Global declarations are Module-owned with `OwnerKey=ModuleKey`; Property is
Type-owned and normally resolves only to a local Class or Struct declaration.
A Delegate may own a generated storage Property only when both the Delegate
Type declaration and Property declaration carry the exact common `Generated`
trait bit. Interface, Enum, Typedef, Funcdef, a non-generated Delegate, and a
Delegate paired with a non-generated Property cannot own storage Property
declarations in V1.
Function declarations use this exact V1 matrix:

| EntityKind | Required OwnerKind | Required local owner authority |
|---|---|---|
| GlobalFunction | Module | ModuleInterface.ModuleKey |
| Method | Type | local Class, Struct, or Interface; also local Delegate iff both owner and Method carry `Generated` |
| Constructor | Type | local Class or Struct; also local Delegate iff both owner and Constructor carry `Generated` |
| Destructor | Type | local Class or Struct; also local Delegate iff both owner and Destructor carry `Generated` |
| Factory | Type | local Class or Struct declaration |
| DelegateSignature | Type | local Delegate or Funcdef declaration only |
| ModuleInitializer | Module | ModuleInterface.ModuleKey |
| GlobalInitializer | Global | local Global declaration |
| GeneratedDefaultConstructor | Type | local Class or Struct; also local Delegate iff the declaration carries `Generated` |
| InitDefaults | Type | local Class or Struct; also local Delegate iff the declaration carries `Generated` |

The Delegate rows above are the complete additive exception. `Factory` remains
forbidden because Delegate is a value type. `DelegateSignature` remains the
single non-executable signature declaration. Generated Delegate Property,
Method, Constructor, Destructor, GeneratedDefaultConstructor, and InitDefaults
declarations are ordinary stable declaration/body authorities rather than
members implicitly reconstructed from the signature.

`FunctionOwnerKind::Property` has no ModuleInterface callable use in V1. A
future stable lambda/property-owned callable requires an explicit schema/matrix
extension rather than being accepted through the Task 1 enum alone.

Owner validation runs after declaration tagged-union, scalar/hash, canonical
order, duplicate/conflict, and ModuleInterface.ModuleKey validation, with this
fixed precedence:

1. a Declaration.ModuleKey unequal to ModuleInterface.ModuleKey, or a
   Module-owned OwnerKey unequal to it, is `CrossModuleOwner`;
2. an OwnerKind forbidden by the declaration/entity matrix is
   `WrongReferenceKind`;
3. a zero required OwnerKey is `MissingOwner`;
4. for Type/Global ownership, a key absent from the expected local declaration
   index but present under another declaration kind is `WrongReferenceKind`;
5. a key absent from every local declaration index is `MissingOwner`; and
6. a resolved Type owner of the wrong Type entity kind, including a
   DelegateSignature owned by Class/Struct/Interface/Enum/Typedef, is
   `WrongReferenceKind`.

Because every resolved local owner declaration has already passed the same
ModuleKey check, no local Type-owned Function/Property or GlobalInitializer can
silently name an external owner. Imports remain the sole cross-module function
route authority and follow their separate target contract.

Coverage is explicit graph authority rather than a value inferred later from
names, flags, or array presence:

- Type requires `SchemaCoverage::Required`; Function, Global, and
  Property require `SchemaCoverage::Forbidden`.
- Type, Global, and Property require `BodyCoverage::Forbidden`.
- A Function with `Abstract` trait, `DelegateSignature`, `ModuleInitializer`, or
  `GlobalInitializer` requires `BodyCoverage::Forbidden`. Initializer execution
  belongs to ModuleState and a delegate/abstract declaration has no body.
- Every other persistent script Function in a ModuleInterface requires
  `BodyCoverage::Required`. A producer feature that cannot safely emit a
  required body is NotCacheable for the complete snapshot; V1 does not encode
  an ambiguous Optional state.

The later ModuleSnapshot validator performs exact equality between declarations
marked Required and keyed TypeSchema/FunctionBody links. A Forbidden entity is
malformed if such a record is linked.

A delegate, typedef, or funcdef is a Type declaration with its corresponding
EntityKind and stable TypeKey. Delegate and funcdef signatures are separate
`Function + EntityKind::DelegateSignature` declarations owned by that TypeKey;
the later TypeSchema kind payload links the signature. Import never appears as
a declaration and has its own array. `Typedef=6` and `Funcdef=7` extend the
shared Task-1 entity-kind contract without renumbering existing values.

`CanonicalTypeSpelling` is the exact string supplied to the existing
Global/Property identity descriptor. `DeclaredType` is the reconstructible
semantic type. Task 2B-1 local decode validates only their required presence,
strict-UTF-8/nonempty spelling shape, canonical data-type shape and inclusion
in StableKey/SignatureHash/InterfaceAbi inputs. It cannot prove semantic text
equality: ScriptType/EnvironmentType carries only StableKey/ExpectedAbi and the
pure reader has no type-name resolver.

The producer MUST derive both fields from the same compiler type and marks the
snapshot NotCacheable if it cannot do so. Task 2B-2/current-symbol or TypeSchema
graph validation compares the spelling when its resolved type authority exposes
the canonical spelling. A local decoder MUST NOT parse spelling, guess a name
from a key, or claim equality without that authority. Making equality a future
pure-local invariant requires an explicit reconstructible schema addition and
version bump. Empty optionals never use a default-constructed data type as a
sentinel.

Slots are semantic sequences embedded in otherwise set-sorted declarations.
For each SlotKind, all slots across the complete ModuleInterface form one
unique contiguous `0..N-1` sequence. Declaration array order never defines
slot order. A declaration may carry more than one distinct SlotKind; duplicate
kind/ordinal entries reject.

### Import declaration

```text
ImportKey:hash256
CanonicalNamespace:string
CanonicalName:string
CanonicalSignature:string
TargetModuleKey:StableModuleKey
TargetDeclaration:StableReference
Slots:array<DeclarationSlot>
```

TargetDeclaration is a `ScriptFunction` reference with nonzero ExpectedAbi.
Every Import contains exactly one `Import` slot; Import slot ordinals join the
same ModuleInterface-wide per-kind contiguous validation. `ImportKey` is
recomputed with `FAngelscriptArtifactCanonicalWriter("cache-script-import")`
over ModuleKey, namespace, name, canonical signature, TargetModuleKey, and
TargetDeclaration StableKey. Route ABI remains in TargetDeclaration.ExpectedAbi
and is not duplicated as another field.

ImportKey follows the same single-public-builder principle as source keys:

```cpp
FAngelscriptCacheValidationResult TryBuildImportKey(
	const FAngelscriptImportIdentityInput& Input,
	FAngelscriptStableImportKey& OutKey);
```

The identity input contains exactly ModuleKey, canonical namespace/name/
signature, TargetModuleKey, and target StableFunctionKey. It does not contain
TargetDeclaration.ExpectedAbi, ReferenceKind, Slots, metadata, or the stored
ImportKey. The builder resets output to zero, validates only these identity
inputs, reuses `FAngelscriptArtifactCanonicalWriter`, and returns one nonzero
full key or a typed failure. Changing route ExpectedAbi or Slots cannot change
the builder result or make otherwise-valid identity input fail.

Full Import preparation separately requires ScriptFunction ReferenceKind,
nonzero ExpectedAbi, exactly one Import slot and interface-wide slot ordinals,
then recomputes ImportKey through this public builder. Task 2B-1 RED freezes the
builder full hash, zero-output failures, equal keys across ABI/slot variants,
and independent full-record ABI/slot rejection.

### ModuleInterface canonical order

| Collection | Wire order |
|---|---|
| CanonicalNamespaces | exact UTF-8 bytes |
| Declarations | DeclarationKind, EntityKind, StableKey |
| CanonicalIdentityTraits | exact UTF-8 bytes |
| Metadata | key UTF-8, then value UTF-8 |
| Dependencies | DependencyKind, Target.ReferenceKind, Target.StableKey, ExpectedAbi, content presence, content hash |
| OrderedParameters | stored position and explicit Ordinal, both `0..N-1` |
| Slots | SlotKind, then Ordinal; ordinals validated ModuleInterface-wide |
| Imports | ImportKey; import slot order remains in Slots |

Metadata with the same key/value is `DuplicateKey`; the same key with a
different value is `ConflictingKey`. V1 does not define last-wins or implicit
multi-valued metadata.

### Stable entity and derived hash recomputation

Declaration StableKey is never accepted merely because it is nonzero. Convert
the validated tagged union to the existing Task-1 descriptor and call
`BuildTypeKey`, `BuildFunctionKey`, `BuildGlobalKey`, or `BuildPropertyKey`.
CanonicalIdentityTraits are validated sorted/unique before calling the builder.

Derived hashes use the existing artifact writer and exclude their own stored
field:

```text
SignatureHash = H("cache-declaration-signature-v1",
  DeclarationKind, EntityKind, SchemaCoverage, BodyCoverage,
  OwnerKind, OwnerKey, ModuleKey,
  CanonicalNamespace, CanonicalName, CanonicalDeclaration,
  CanonicalTypeSpelling presence and bytes,
  DeclaredType presence and value,
  ordered parameters including ordinal, name, type, passing,
    default-expression presence and canonical bytes, parameter traits,
  Declaration TraitFlags, ReflectionFlags)

TraitsHash = H("cache-declaration-traits-v1",
  all CanonicalIdentityTraits,
  TraitFlags, ReflectionFlags,
  all canonical Metadata)

InterfaceAbi = H("cache-module-interface-abi-v1",
  PayloadSchemaVersion, ModuleKey, CanonicalModuleName,
  CanonicalNamespaces,
  for each canonical declaration:
    DeclarationKind, EntityKind, SchemaCoverage, BodyCoverage,
    StableKey, SignatureHash, TraitsHash, Slots,
  for each canonical import:
    ImportKey, canonical signature, TargetModuleKey,
    target ReferenceKind, StableKey, ExpectedAbi, Slots,
  ABI-bearing Dependencies without ExpectedContentOrValue)
```

ABI-bearing dependency kinds are Import, Declaration, Signature, Inheritance,
ValueLayout, PropertyLayout, GlobalStorage, and EnvironmentAbi. HardValue,
CompileOption, and Initializer are excluded from InterfaceAbi; the complete
ModuleInterface payload and RecordId still include every dependency and its
stored ExpectedContentOrValue. For GlobalStorage, InterfaceAbi includes the kind
and stable target reference but deliberately excludes its storage-layout content
fingerprint; that fingerprint belongs to ModuleState invalidation.

Default-expression presence and canonical bytes enter SignatureHash and
InterfaceAbi. A later compiler capture still records a separate HardValue
dependency whenever resolved default content is embedded into a caller.

The payload stores SignatureHash, TraitsHash, and InterfaceAbi; the decoder
recomputes all three and rejects any mismatch before publishing the value.
The envelope RecordId covers the stored derived hashes as ordinary payload
bytes.

## Validation result V1

The existing envelope error numeric values `0..11` remain compatible:

```text
None=0, BadMagic=1, UnsupportedSchema=2, UnknownRecordKind=3,
NonZeroReserved=4, Overflow=5, BudgetExceeded=6, OutOfBounds=7,
ChecksumMismatch=8, TrailingData=9, InvalidArrayView=10,
AliasedInputOutput=11
```

Semantic/archive extensions are:

```text
UnsupportedPayloadSchema=12, UnknownEnumValue=13, UnknownFlags=14,
InvalidBoolean=15, InvalidOptionalTag=16, InvalidUtf8=17,
EmbeddedNul=18, InvalidLogicalPath=19, ImpossibleCount=20,
NestingDepthExceeded=21, RecordIdMismatch=22,
NonCanonicalOrder=23, DuplicateKey=24, ConflictingKey=25,
CaseCollision=26, ZeroStableKey=27, MissingExpectedAbi=28,
ForbiddenExpectedAbi=29, InvalidPresence=30,
InvalidQualifierCombination=31, OrdinalGap=32, DuplicateOrdinal=33,
DerivedHashMismatch=34, MissingOwner=35, CrossModuleOwner=36,
MissingGraphTarget=37, WrongReferenceKind=38,
CompatibilityMismatch=39, ContextMismatch=40, ProfileMismatch=41,
SourceSnapshotMismatch=42, CurrentAbiMismatch=43
```

ValidationClass values are:

```text
Success=0, Malformed=1, ArithmeticOrBudget=2, CodecOrIntegrity=3,
CanonicalSemantic=4, GraphOrOwnership=5, Ineligible=6
```

One exhaustive `Classify(EAngelscriptCacheValidationError)` function is the
only class authority:

| Class | Errors |
|---|---|
| Success | None |
| Malformed | BadMagic, UnsupportedSchema, UnsupportedPayloadSchema, UnknownRecordKind, UnknownEnumValue, UnknownFlags, InvalidBoolean, InvalidOptionalTag, NonZeroReserved, InvalidUtf8, EmbeddedNul, InvalidLogicalPath, TrailingData, InvalidArrayView, AliasedInputOutput |
| ArithmeticOrBudget | Overflow, BudgetExceeded, OutOfBounds, ImpossibleCount, NestingDepthExceeded |
| CodecOrIntegrity | ChecksumMismatch, RecordIdMismatch |
| CanonicalSemantic | NonCanonicalOrder, DuplicateKey, ConflictingKey, CaseCollision, ZeroStableKey, MissingExpectedAbi, ForbiddenExpectedAbi, InvalidPresence, InvalidQualifierCombination, OrdinalGap, DuplicateOrdinal, DerivedHashMismatch |
| GraphOrOwnership | MissingOwner, CrossModuleOwner, MissingGraphTarget, WrongReferenceKind |
| Ineligible | CompatibilityMismatch, ContextMismatch, ProfileMismatch, SourceSnapshotMismatch, CurrentAbiMismatch |

`FAngelscriptCacheValidationResult` carries Error, the classified Class,
RecordKind, and ByteOffset. Construction must guarantee
`Class == Classify(Error)`; call sites never choose a class. RecordKind is zero
when no record kind has been established. ByteOffset identifies the first
failing byte or the enclosing field start for semantic validation.
Once a public SourceIndex or ModuleInterface producer encoder or the common
decoded-record factory dispatch is entered, its record kind is established for
every later failure. Decode semantic failures report that kind plus the
captured enclosing-field start; encode semantic failures report that kind plus
`ByteOffset=0` because no canonical output field has been published yet. A
nested helper result with zero kind must be wrapped at the record boundary
rather than leaked publicly. There are no final V1 public record-specific
decode entry points.

Missing provider/hook fingerprint capability does not itself corrupt a valid
SourceIndex; the corresponding IneligibleScope is normal data. Malformed
capability/presence combinations reject locally. Cross-record/current-engine
existence and ABI checks remain later phases.

## Writer, reader, and test obligations

The public encoder accepts semantic values in arbitrary insertion order,
canonicalizes a copy, validates it, and leaves input untouched. The public
all-record factory accepts SourceIndex only in canonical wire order,
consumes the shared read-session budget, recomputes the declared RecordId, and
publishes only the common immutable record handle; it clears the optional
output on every failure. The record-specific SourceIndex decoder is private. A
low-level unchecked writer may exist only as a test fixture surface under
`WITH_ANGELSCRIPT_UNITTESTS`.

Task 2B-1 byte goldens must freeze:

- every enum and flag value;
- scalar, optional, UTF-8, data type, reference, dependency, metadata,
  parameter, slot, declaration, and import bytes;
- one complete SourceIndex payload, SourceSnapshot, RecordId, and envelope;
- one complete ModuleInterface payload, declaration StableKeys,
  SignatureHash, TraitsHash, InterfaceAbi, RecordId, and envelope;
- six public source-key builder full hashes plus zero-output invalid identity
  inputs, with encoder recomputation equal to those public results;
- forward, reverse, and map/random insertion producing identical bytes;
- manually unsorted wire producing `NonCanonicalOrder`;
- duplicate/conflict/ordinal/presence/ABI/hash/path/case failures;
- SourceEdge SemanticOrdinal all-absent, all-present contiguous, mixed-presence
  `InvalidPresence`, gap, and duplicate cases;
- every Provider/Hook capability-to-same-scope-reason pair in both directions:
  unset+missing entry, unset+present entry, set+forbidden missing reason, wrong
  scope/key/reason, and unrelated independently valid reason;
- every SourceIndex typed-reference matrix row with valid target,
  `WrongReferenceKind`, `MissingGraphTarget`, and resolved-authority
  `ConflictingKey` precedence, including generated-key and derived-ModuleKey
  sets, distinct Files claiming one GeneratedSourceKey as `ConflictingKey`, and
  proof that no dangling or ambiguous source reference publishes;
- graph-phase combination failures proving the exact field order
  `Mounts -> Hooks -> Files -> Inputs -> Edges -> IneligibleScopes`, including
  Hook before File, Input before IneligibleScope, and Edge before
  IneligibleScope, followed only then by resolved-authority `ConflictingKey`;
- every ModuleInterface declaration/callable owner-matrix row, Type-owned
  Function/Property and GlobalInitializer local resolution, ordinary Method
  Class/Struct/Interface and Property Class/Struct restrictions, the complete
  Generated-trait-gated Delegate Property/Method/Constructor/Destructor/
  GeneratedDefaultConstructor/InitDefaults Cartesian exception, forbidden
  Delegate Factory/non-generated variants, DelegateSignature Delegate/Funcdef
  restriction, all other forbidden TypeKind owners, plus exact
  CrossModuleOwner/WrongReferenceKind/MissingOwner precedence;
- Global/Property CanonicalTypeSpelling and DeclaredType local presence/shape/
  hash mutation tests without a false pure semantic-equality claim; producer
  same-compiler-type and later resolved-authority equality remain explicit
  downstream obligations;
- public identity-only `TryBuildImportKey` full hash/zero-output failures,
  unchanged key across ExpectedAbi/Slot variants, and separate full Import
  ReferenceKind/ABI/slot rejection;
- pure eligibility-query fixtures with two modules, canonical matching-row
  output, missing-module `MissingGraphTarget` plus empty output, direct module/
  file/mount/provider/hook reasons, a base-to-dependent transitive Hook chain,
  a detached Hook chain, and proof that either detached Hooks or one bad scope
  do not contaminate an unrelated module; tests obtain the factory-only token
  through decode, prove raw DTOs cannot call the query, and instrument that
  decode move-publication/query perform no whole-SourceIndex deep copy;
- manually forged Hook self-cycle and multi-node cycle rows rejected as
  `DerivedHashMismatch` before eligibility, with no cycle-specific error or
  iterative HookKey-hash solver;
- ASCII case collision, a non-ASCII BMP simple-fold policy vector, and a true
  supplementary-plane traversal vector proving UTF-16 surrogate halves are
  never folded independently;
- strict invalid UTF-8 and embedded NUL;
- serializer semantic failures with established SourceIndex/ModuleInterface
  `RecordKind` and `ByteOffset=0`, plus decoder semantic failures with exact
  enclosing-field offsets;
- two competing full-256 authority duplicate groups proving the smallest
  second wire occurrence determines `DuplicateKey` versus `ConflictingKey`;
- per-field, record, nesting, element, cumulative session, retained-resident,
  and temporary scratch budgets before allocation, including exact-limit
  success, one-byte-short failure with unchanged counters/no allocation, and
  RAII scratch release on both success and every early failure path.

No 2B-1 test may construct a live AS engine, access disk, depend on provider
addresses, or substitute a 64-bit source-state hash for a full fingerprint.
