# Cache V2 Semantic Record Schema

## Status and authority

This document is the implementation-facing semantic schema for Cache V2. It
refines `design.md`, `implementation-plan.md`, and the
`as-incremental-script-cache` delta spec. If an abbreviated interface sketch
conflicts with this document, the explicit pointer-free values and invariants
here take precedence until the artifacts are revised together.

`record-wire-v1.md` is the narrower byte-level authority for Task 2B-1 common
values, `SourceIndex`, `ModuleInterface`, wire enums, field order, derived
hashes, validation mapping, and canonical collections. This document remains
the ownership and graph authority across all seven record kinds.

`record-wire-v1-remaining.md` is the corresponding byte-level and validation
authority for Task 2B-2 `TypeSchema`, `ModuleState`, `FunctionBody`,
`DebugSidecar`, `ModuleSnapshot`, opaque-codec summaries, current-symbol
resolution, and the per-module graph. It reuses the 2B-1 primitives without
changing their bytes. Where the minimum-field summaries below abbreviate an
enum, field order, hash stream, presence rule, error, or validation phase, the
two record-wire documents are normative.

`manifest-pack-wire-v1.md` is the byte-level/physical-identity authority for
Task 2B-3 manifests and in-memory aggregate packs. `store-publication-v1.md`
separately owns Task Group 3 filesystem/pointer/publication behavior and store
errors. Neither document changes a semantic record payload; the store document
does not add archive validation errors.

This schema is intentionally independent from live `asCScriptEngine`, UObject,
filesystem, and StaticJIT provider state. Task 2 proves these values, archives,
record graphs, manifests, and in-memory pack bytes without constructing a live
AngelScript engine; repository task group 3 owns the disk store. Later source/
compiler work captures and attaches records through a VM-private codec and the
per-engine mutation transaction.

## Legacy data is an inventory, not a wire model

`StaticJIT/PrecompiledData.h/.cpp` demonstrates the categories that a complete
restore must recreate: modules, declarations, classes, properties, enums,
globals, imports, function bodies, stack/local state, debug mapping, and
relocations. Its representation is forbidden for Cache V2 because it persists
pointer-, FunctionId-, type-id-, and property-offset-shaped integers, raw
`asDWORD` bytecode, random `DataGuid`, coarse `BuildIdentifier`, map iteration,
and `FArchive <<` layout.

The legacy function snapshot is also incomplete relative to the maintained
fork. It saves bytecode, variable space, object-variable tables,
`objVariableInfo`, heap count, stack need, `declaredAt`, and line numbers, but
the current `ScriptFunctionData` additionally carries `tryCatchInfo`,
`temporaryVariables`, complete local `variables`, and `sectionIdxs`.
`dontCleanUpOnException` is function execution state. The future codec MUST be
defined from the maintained fork's actual compiler/VM state and opcode table,
not by copying `FAngelscriptPrecompiledFunction`.

Legacy field ownership maps as follows:

| Legacy category | Cache V2 owner |
|---|---|
| module name/imports/declarations/slots | `ModuleInterface` |
| source-relative file/module code hash | complete `SourceIndex` and entity digests |
| class/property/inheritance/behavior/reflection | `TypeSchema` |
| enum declaration/value shape | `TypeSchema`; derived hard-value fingerprint in `ModuleState` |
| globals/constants/storage/init/post-init | atomic `ModuleState` |
| ordinary/method/constructor/destructor/factory/`__InitDefaults` execution | `FunctionBody` |
| line/section/local-name/editor data | `DebugSidecar` |
| type/function/global/property/name/string reference maps | typed stable references and owning payload bytes |
| numeric IDs, pointer maps, `DataGuid`, loaded-data views | never persisted |

## Three-layer ownership boundary

### Common Cache archive

`Cache/AngelscriptCacheTypes.*` and `Cache/AngelscriptCacheArchive.*` own:

- fixed-width pointer-free value types;
- canonical UTF-8, little-endian scalar, array, and optional encoding;
- explicit record payload schemas and per-record versions;
- stable entity/reference keys and expected fingerprints;
- set ordering, semantic sequence ordinals, duplicate/conflict validation;
- record/manifest/pack identity and cross-record graph validation;
- per-value, per-record, and cumulative read budgets; and
- typed malformed, integrity, graph, and eligibility results.

Type declarations, properties, globals, imports, metadata, slots, dependency
targets, and keyed record links are explicit common values. They MUST NOT be
hidden in a raw schema/state memory blob merely because live attachment is
engine-private.

### VM-private function/state/debug codec

`AngelscriptFunctionArtifactCodec` owns the versioned canonical execution,
initializer, and debug payloads. It alone may interpret:

- opcode boundaries, instruction ordinals, jumps, and pointer-width-dependent
  word layout;
- function/type/global/property/import/name/string operands and stable
  relocation entries;
- `scriptData`, stack/variable space, object variables, heap partition,
  object-variable scopes, try/catch and cleanup metadata;
- complete local variable type/offset/on-heap state needed by context
  serialization;
- line cues, source-section transitions, local/temporary debug information;
  and
- recomputation of derived current-VM offsets, IDs, refcounts, sizes, and
  parameter/return cleanup state.

Its canonical payload never contains a native address or process-local numeric
ID disguised as an integer. A relocation identifies at least instruction
ordinal, operand slot, reference kind, full stable key, and expected
fingerprint. Name/string bytes live in a canonical pool owned by that payload.

### Serialized engine attachment

The per-engine mutation transaction consumes fully validated pointer-free
records, resolves stable references against the current module transaction and
environment catalog, constructs declarations/types/globals/functions, runs
ClassGenerator/reflection validation, and atomically activates the complete
module. Workers never call AngelScript engine APIs. No function or partial
module is exposed while VM decoding or cross-record validation is incomplete.

## Common values

### Independent version axes

The physical record envelope schema, each semantic record payload schema, and
the VM execution/debug codec schema are distinct fixed-width versions.
`CompatibilityKey` includes the compiler/bytecode/codec ABI, but every payload
also starts with its explicit `PayloadSchemaVersion` so an unsupported record
fails with the precise stage and kind.

### Canonical data type

Every declaration/property/global/local/import/delegate/funcdef uses a
pointer-free canonical type descriptor containing:

- stable wire kind: primitive, script type, environment type, or auto;
- stable semantic primitive token when primitive;
- typed stable reference when script/environment object type;
- explicit qualifier flags for reference, object const, object handle, const
  handle, auto, and if-handle-then-const; and
- ordered template/subtype descriptors when not already part of the referenced
  stable symbol.

Raw maintained-fork `eTokenType`, type ID, `asCTypeInfo*`, or UObject values are
not wire fields. The decoder rejects unknown bits, impossible combinations,
zero entity keys, and missing type ABI before attachment.

### Canonical declaration

The no-parse path needs more than hashes. A declaration descriptor contains:

- declaration kind, existing Task 1 entity kind, and stable key;
- stable owner kind/key and owning `ModuleKey`;
- canonical namespace, name, and declaration bytes;
- sorted unique canonical identity traits, Global/Property canonical type
  spelling, and tagged canonical return/property/global descriptors as
  applicable;
- ordered parameter types, in/out modifiers, and default expressions;
- fixed call/trait/reflection flags;
- explicit Required/Forbidden TypeSchema and FunctionBody coverage; V1 has no
  inferred or Optional coverage state;
- canonically sorted metadata key/value pairs; and
- zero or more explicit slot category/ordinal pairs when ordering is semantic.

`SignatureHash` and `TraitsHash` are recomputed validation accelerators, not
substitutes for the reconstructible declaration. V1 declarations are a strict
tagged union: Type, Function, Global, or Property. Import exists only in the
ModuleInterface import table. Delegate, Typedef, and Funcdef are Type
declarations with shared entity kinds `Delegate=5`, `Typedef=6`, and
`Funcdef=7`; delegate/funcdef signatures are separate Function declarations
with `EntityKind::DelegateSignature` owned by the TypeKey. Every stable
declaration key is recomputed through the existing Task 1 identity builder.

Every local owner resolves through the exact V1 matrix in
`record-wire-v1.md`: Type/Global are Module-owned, Property and the applicable
callables resolve local Type declarations, GlobalInitializer resolves a local
Global, ordinary Method accepts Class/Struct/Interface, ordinary Property
accepts Class/Struct, and DelegateSignature accepts only Delegate/Funcdef. A
Delegate additionally owns only the generated Property/Method/Constructor/
Destructor/GeneratedDefaultConstructor/InitDefaults rows explicitly allowed by
the common trait-gated matrix; Factory remains forbidden. The fixed
CrossModuleOwner/WrongReferenceKind/MissingOwner precedence rejects unresolved
or wrong-kind owners before a ModuleSnapshot can refer to the interface.

For Global/Property, the pure 2B-1 reader validates CanonicalTypeSpelling and
DeclaredType presence, shape, and hash participation but cannot prove their
semantic equality because stable type refs contain no canonical name. The
producer derives both from one compiler type; TypeSchema/current resolution
compares equality when the canonical type authority is available. The decoder
does not parse spelling or guess text from a key.

Coverage is graph authority stored in ModuleInterface. Type declarations
require TypeSchema; other declaration kinds forbid it. Ordinary
persistent executable functions require FunctionBody, while type/global/
property, abstract, delegate-signature, and ModuleState-owned initializer
declarations forbid FunctionBody. A producer unable to capture a required body
marks the complete snapshot NotCacheable rather than writing partial/optional
coverage. ModuleSnapshot validation compares Required sets to keyed links
exactly and rejects records for Forbidden entities.

### Stable reference and typed semantic dependency

A stable reference is:

```text
ReferenceKind + full StableKey + full ExpectedAbi
```

`StableKey` is nonzero for every reference kind. Null/absence is an explicit
optional or codec null operand. A typed semantic dependency adds a dependency
kind to a stable target reference and, when compilation truly embeds content
or a hard value, a separate nonzero expected content/value fingerprint. This
keeps declaration ABI distinct from implementation/value dependencies.

Expected ABI rules are:

| Reference kind | Expected ABI |
|---|---|
| `ScriptModule` | nonzero linked ModuleInterface ABI |
| `ScriptType` | nonzero declaration `SignatureHash`; layout is a separate ValueLayout content coordinate |
| `ScriptFunction` | nonzero declaration/signature/traits/call ABI, not ordinary callee body content |
| `ScriptGlobal` | nonzero type/storage ABI; folded constants add a separate hard-value dependency |
| `ScriptProperty` | nonzero property declaration `SignatureHash`; offset/layout is a separate PropertyLayout content coordinate |
| `ScriptImport` | nonzero import signature and target route ABI |
| `EnvironmentSymbol` | nonzero current catalog ABI fingerprint |
| `CanonicalName` | zero only; owning payload contains matching canonical UTF-8 bytes |
| `StringLiteral` | zero only; owning payload contains matching encoding and bytes |

The same `(Kind, StableKey)` with different expectations is a conflict. An ABI
mismatch is an ineligible cache miss before attachment; a missing/forbidden ABI
value is malformed record data.

The active development schema fixes `ExpectedContentOrValue` presence: Import,
Declaration, Signature, Inheritance, and EnvironmentAbi require absence;
ValueLayout, PropertyLayout, GlobalStorage, HardValue, CompileOption,
Initializer, and the V4.4 append-only FunctionContent kind require a present
nonzero fingerprint. ValueLayout carries the exact target `TypeLayoutHash` and
PropertyLayout carries the exact target `PropertyLayoutFingerprint`, while
their stable target keeps the declaration `SignatureHash` in `ExpectedAbi`.
FunctionContent targets ScriptFunction and carries its exact execution-content
hash rather than overloading HardValue/Initializer/CompileOption. GlobalStorage
carries the exact storage-layout fingerprint;
that content coordinate invalidates ModuleState but is not itself folded into
ModuleInterface ABI. A future order-only initializer dependency needs a new
kind/schema rather than another interpretation of the optional field.

## Record schemas

### SourceIndex

Minimum fields:

- payload schema version and recomputable `SourceSnapshot`;
- source filter/discovery/preprocessor policy;
- keyed per-scope exact-fast-path ineligibility and reasons, with no global
  eligibility boolean;
- mount descriptors: source kind, stable mount key, logical mount, provider
  key, relocation-stable root/config fingerprint, and options;
- provider descriptors: stable key, implementation kind, identity/version/
  config fingerprints, and fingerprint capability;
- preprocess-hook descriptors: stable key, version/config fingerprint,
  affected scope, and fingerprint capability;
- source files: stable source-file key, source kind, mount/provider keys,
  validated relative logical path, raw byte hash, generated-source identity,
  and owning ModuleKey;
- per-file preprocessor inputs with kind, canonical name, target source/
  provider key, and effective value/content hash;
- explicit stable-keyed include/generated-source edges.

Host absolute roots are current-scan inputs only and never persisted. External
source remains relocation-stable only when its provider supplies stable mount,
identity, version, and configuration fingerprints; otherwise the affected
scope is ineligible for the exact zero-preprocess path. Raw `FString`
virtual/absolute paths are not record fields: validated typed relative logical
paths reject drive, UNC, slash-rooted, NUL, and escaping `..` input. Distinct
paths that collide under case-insensitive comparison reject the SourceIndex.
`SourceFile.ModuleKey` is the sole source-to-module wire authority and the
mapping is derived from canonical Files. Mount/provider/hook/source-file/input/
edge keys use distinct typed wrappers and the exact Task 1 canonical-writer
domains in `record-wire-v1.md`. Only Game, Plugin, and Memory are source kinds;
Generated and External are provider kinds. Raw source and explicit
fingerprints are full BLAKE3-256 values; the current provider's 64-bit state
hash is not a Cache V2 content hash.

Mount/Provider/Hook/File/Input/Edge keys each have one public identity-only,
fail-closed typed builder using the shared artifact writer and zero output on
failure. Encoder, producer and tests call those builders rather than duplicate
hash domains.

Before publication the SourceIndex resolves every typed mount/provider, hook/
input/ineligible scope, input target, include/generated edge and generated key;
the ModuleKey authority set is derived only from Files. Wrong typed authority,
missing target, and resolved File/Mount inconsistency use the fixed
WrongReferenceKind/MissingGraphTarget/ConflictingKey precedence. Provider/Hook
capabilities and their exact same-scope missing reasons are bidirectional.
Within a `{FromSourceFileKey, EdgeKind}` group SemanticOrdinal is all absent or
all present and contiguous.

Eligibility is a pure query of a validated SourceIndex plus target ModuleKey.
It derives files/mounts/providers and the transitive fixed-point matching-hook
closure, then returns the boolean and exact canonical matching IneligibleScope
rows. This is set closure, not HookKey hash iteration. HookKey includes
AffectedScopeStableKey; producers construct an acyclic chain outward from a
non-Hook scope, while a forged self/multi-node cycle fails existing
DerivedHashMismatch during key recomputation before eligibility. No cycle-
specific error or HookKey solver is introduced.
Missing module clears output and returns MissingGraphTarget. No global boolean
is persisted, and neither a detached Hook chain nor one bad closure disables an
unrelated module in the same SourceIndex.

### ModuleInterface

Minimum fields:

- payload schema version, ModuleKey, canonical module name, and interface ABI;
- a sorted unique table of actually used nonempty namespaces; declarations use
  an empty namespace for the global namespace;
- complete canonical declaration descriptors;
- explicit declaration/function/virtual/import slot ordering;
- imported-module/function descriptors with stable import key, target
  ModuleKey/declaration, canonical signature, expected ABI, and ordinal; and
- typed semantic dependencies whose targets may be module, type, function,
  global, property, import, or environment symbol.

Include/preprocessor source edges remain SourceIndex data. Reflection metadata
for global/static functions is interface/type structural data, not body data.
ImportKey has one public identity-only fail-closed builder over module/
namespace/name/signature/target-module/target-function key. Target
ReferenceKind/ExpectedAbi and Slots are non-key full-record fields validated
separately and cannot alter identity-builder success.

Declaration sets are ordered independently from semantic slots. Each SlotKind
forms one ModuleInterface-wide unique contiguous `0..N-1` sequence, and one
declaration may participate in multiple slot kinds. V1 SignatureHash includes
canonical type spelling, ordered parameters, the frozen declaration/
reflection/parameter flags, and default-expression presence/bytes. There is no
separate undefined call mask. TraitsHash conservatively includes all canonical
identity traits, declaration/reflection flags, and metadata. InterfaceAbi contains namespaces,
declaration key/signature/traits/slots, import route ExpectedAbi, and only
ABI-bearing dependencies; it excludes itself and ExpectedContentOrValue.
Default expressions are caller-visible interface semantics, while a compiler-
embedded resolved value still creates a separate Task 4 HardValue dependency.

### TypeSchema

Minimum fields:

- payload schema version, owning ModuleKey, TypeKey, kind, canonical namespace,
  name, and declaration;
- fixed traits/flags and canonical metadata;
- typed base, shadow/code-super, ordered direct implemented-interface, and
  compose refs; direct interface ordinals are semantic and their transitive
  closure is derived base-first with first-visit diamond deduplication;
- layout hash and expected semantic size/alignment/base-property boundary,
  including the V1 object initial alignment `8`, common non-object TypeInfo
  alignment `4`, exact property byte offsets, checked terminal tail alignment,
  and explicit Base/code-root/struct-header LayoutInputs;
- ordered local properties with PropertyKey, canonical type, access,
  replication/serialization/reflection flags, metadata, layout ordinal, and
  expected property layout fingerprint, plus hash-bound StorageKind/semantic
  storage size/alignment consumed by immutable layout replay;
- an exact public `asCObjectType::methods` sequence and a distinct exact
  virtual-function-table sequence, each with its own ordinal domain, stable
  declarations, and explicit declaring/implementing owner rules;
- named behavior slots, including constructor/factory order as grouped
  contiguous behavior-slot sequences; no duplicate constructor/factory arrays;
- kind-specific enum, delegate, typedef, or funcdef values;
- ClassGenerator/reflection descriptors required for exact restore, including
  explicit ordered UFunction membership for ordinary classes and StaticsClass
  globals even when the target declaration's ReflectionFlags are zero; and
- sorted type/property/function/environment dependencies.

TypeSchema is explicit common schema, not an opaque byte blob. Live creation of
AS/UE type objects is still engine-private. ModuleInterface is the sole type
identity authority; TypeSchema graph validation checks the same module/kind/
namespace/name/declaration coordinate rather than inventing a second key
algorithm. TypeSchema is authoritative for signed-int32 enum enumerator order,
name, value, metadata and reflection shape. ModuleState stores only the derived
hard-value fingerprint and validates it against that authority. Super,
interface, compose and metadata data have one common-field authority rather
than duplicated reflection copies. Executable defaults belong to an
`InitDefaults` FunctionBody, never a reflection blob/string.
Numeric layout authority is split exactly as
`type-layout-authority-v1.md`: persisted pointer-free evidence first, separate
eligible current layout comparison last. A linked same-module Base/inline-value
TypeSchema is a second stored authority and disagreement is GraphAbiMismatch;
same-module Script* dependencies and numeric layout coordinates are graph-closed
and make zero current-resolver calls on a cold exact hit. Primitive and
ObjectHandle storage use versioned Compatibility/Profile constants. An
ObjectHandle property derives Declaration for ScriptType or EnvironmentAbi for
EnvironmentType; it never derives ValueLayout from the target instance type. A legal
cross-module/environment target need not be a child record; its single stored
witness remains locally/hash/consumer validated and is compared through the
required per-engine `IAngelscriptCacheCurrentLayoutResolver` only after the
immutable graph succeeds. The resolver can run before selected-module live
types exist and receives a non-owning prospective view over validated local
TypeSchemas when an environment recipe contains a local value subtype. It has
no process-global fallback and never supplies values to stored hash calculation.
It memoizes only eligible raw layout-input role coordinates by stable identity;
each TypeSchema applies its locally validated stored consumption mask before
current comparison/hash recomputation, so a derived UClass ignores the raw
CodeRoot boundary while still comparing shadow alignment. TypeSchema local
validation exhausts physical payload first, then checks field-local semantics in
top-level wire order, then cross-field layout replay; LayoutInputHash, property
StorageLayoutHash/PropertyLayoutFingerprint, EnumAuthorityHash, and final
TypeLayoutHash have one fixed dependency order. Typedef preserves live descriptor
`{primitive alias size, alignment 4}`; Funcdef preserves `{size 0, alignment 4}`
and is NotCacheable as property storage in V1.
Ordinary UClass reflection has optional ConfigName and required
StaticClassGlobalName; synthetic StaticsClass UClass and every non-UClass form
forbid both, with StaticsClass enforced bidirectionally as specified by the
remaining-wire presence matrix.

### ModuleState

Minimum fields:

- independent payload schema version, owning ModuleKey, ArtifactProfileKey,
  and recomputable state-input hash;
- ordered global storage descriptors with GlobalKey, namespace/name,
  canonical type, traits, storage ordinal, and layout fingerprint;
- explicit default/pure-constant/initializer kind per global;
- canonical constant/hard-value entries;
- a canonical set of versioned VM-private InitializerUnit payloads keyed by
  stable global or module initializer key; units carry no execution ordinal or
  dependency set;
- one `OrderedInitializationActions` semantic sequence as the sole dependency-
  solved execution authority, interleaving `DefaultConstructGlobal` and
  `ExecuteInitializer`; action-owned dependencies express every ordering edge;
- ordered post-init function refs;
- typed hard-value/global/type/environment dependencies; and
- explicit per-global cleanup policy validated by canonical type.

The sole all-record factory dispatches all seven record kinds and returns one
thread-safe shared const token handle;
the token/control/DTO allocation is budgeted once at decode. Per-module graph
validation accepts a view of those handles and retains only handles reachable
from the requested ModuleSnapshot. The published graph owns compact ordinal-
based RecordId/type/global/function/initializer/opaque-owner tables and opaque
summaries; graph-validation maps are temporary and never escape. Candidate
output capacity is live scratch until atomic step-11 promotion transfers the
same bytes to retained resident accounting without double charge. Thus caller
input destruction is safe, unrelated tokens are not retained, and no DTO is
deep-copied merely to publish a graph.

ModuleState never stores mutable gameplay/editor global values, UObject
pointers, an opaque ModuleLifetime field, or a persisted initialized bit. In
V1 global/module initializer execution units are embedded in the atomic
ModuleState record; they are not independently linked FunctionBody records.
Their stable keys remain useful inside ModuleState and diagnostics. All global
storage is allocated/zeroed and pure constants are installed before the exact
initialization-action sequence runs; ordered post-init functions run only after
all actions succeed. Immediately before a global-owning action attempt, its
non-None global is pushed once on a transient cleanup stack. Failure and normal
release pop exact reverse action-attempt order through the explicit per-global
policy; neither that stack nor an initialized bit is persisted. Declaration,
unit, and ExecuteInitializer target sets are exact-equal. There is exactly one
enum-authority expectation for every local enum, one unit/action for every
VmInitializer global, exact DefaultConstructGlobal coverage for Default
DestroyValue globals, and zero or one module initializer unit/action.

### FunctionBody

Minimum fields:

- payload schema version and `FAngelscriptFunctionArtifactIdentity`;
- owning ModuleKey and expected declaration ABI;
- `FunctionSourceDigest`, `FunctionInputDigest`, and invocation kind;
- execution codec version and bounded canonical execution payload;
- sorted complete actual semantic dependencies;
- optional DebugSidecar RecordId; and
- fields required to recompute/validate execution/debug content hashes.

Relocation references are a validated subset of complete actual dependencies;
overload/layout/constant/option dependencies may survive even when no final
opcode operand refers to them. The common reader does not attach raw bytecode;
the injected opaque-payload validator validates every instruction, position,
stack/local table, literal, and relocation against the selected profile, then
publishes only a validated payload hash, ordered relocation coordinates, exact
debug sources and owned CanonicalName/StringLiteral bytes. The common graph
matches relocations to actual dependencies on dependency kind, reference kind,
full key, ExpectedAbi and content presence/hash; it never parses VM bytes.
Invocation kind is checked against the ModuleInterface declaration using the
remaining-wire matrix. Generated default destructor intentionally maps to the
existing `EntityKind::Destructor=35` plus required Generated trait; V1 does not
add a second Task 1 entity value.

### DebugSidecar

Minimum fields:

- independent payload schema version, owning FunctionKey, ArtifactProfileKey,
  and DebugHash;
- debug codec version and bounded canonical debug payload; and
- stable source-file/logical-section references required to validate the map
  against SourceIndex/profile.

The codec owns program-position/line cues, section changes, declared location,
parameter/local names/scopes, temporary-variable debug data, and editor-only
metadata. Numeric script section indices are not persisted.

If a sidecar is present, its FunctionKey, ProfileKey and recomputed DebugHash
must match the FunctionBody identity. If absent, the identity's debug
coordinate is the shared artifact-identity
`H("function-debug-absent", full ProfileKey)` value. Absence is an unset
optional, never a zero RecordId/hash sentinel or an empty-debug payload hash.
Debug source references use typed SourceFileKey and LogicalSectionKey values;
the latter hashes exact strict-UTF-8 section bytes without normalization.

### ModuleSnapshot

Minimum fields:

- payload schema version and owning ModuleKey;
- required `{ModuleKey, ModuleInterface RecordId}`;
- sorted `{TypeKey, TypeSchema RecordId}` links;
- required `{ModuleKey, ModuleState RecordId}`, including empty state; and
- sorted `{FunctionKey, FunctionBody RecordId}` links.

Bare RecordId arrays are forbidden because record content hashes cannot define
entity order or detect two records claiming one entity without decoding
ambiguous candidates. Cross-record validation requires every linked entity to
be declared and owned by the same module, exactly one TypeSchema for every
concrete local type, exactly one FunctionBody for every cacheable declaration
with execution, no body for abstract/import/system declarations, ModuleState
coverage of globals, and no direct DebugSidecar link.

## Manifest and RecordId link graph

Allowed RecordId links are deliberately narrow:

| Owner | Allowed links |
|---|---|
| SourceIndex | none |
| ModuleInterface | none; stable semantic refs only |
| TypeSchema | none; stable semantic refs only |
| ModuleState | none in V1; initializer units embedded |
| FunctionBody | optional one DebugSidecar |
| DebugSidecar | none |
| ModuleSnapshot | one ModuleInterface, keyed TypeSchemas, one ModuleState, keyed FunctionBodies |
| generation manifest | exactly one SourceIndex and keyed `{ModuleKey, ModuleSnapshot RecordId}` links |

The generation record index is the exact transitive reachable set from its
SourceIndex and ModuleSnapshots, including FunctionBody-owned DebugSidecars.
Historical/unreachable content may remain in immutable packs but is not added
to a new manifest. Every reachable RecordId has exactly one pack location of
the expected kind.

Pack locations validate codec, stored/raw sizes, checked range, pack bounds,
non-overlap/canonical order, raw checksum, semantic RecordId after decode, and
PackId over the complete final physical pack bytes. RecordId remains the hash
of canonical uncompressed semantic payload; compression/layout never changes
it.

The exact V1 files are `UEASCV2M` schema 1 and `UEASCV2P` schema 1. RecordId is
33 bytes; manifest roots/locations are 65/122 bytes; pack header/index entries
are 32/96 bytes. Packs store semantic payload, not record envelopes.
RawChecksum is direct payload BLAKE3. PackId and GenerationId hash their whole
final file and are not embedded in it. Per-record None is always valid;
production Zlib uses the fixed Unreal format/flags/window and byte-equal
canonical recompression. A pack may contain historical extra records, but a
manifest index must equal its exact reachable set.

## Canonical collections

Set/map-like arrays are sorted by stable wire enum, canonical UTF-8 bytes, and
complete 256-bit keys/hashes. This includes mounts, providers, hooks, ineligible
scopes, source files/edges/inputs, declarations, dependencies, metadata,
keyed record links, record indexes, and pack indexes. Writers do not inherit
`TMap`, task completion, registration, or pointer order.

Semantic sequences are not sorted. Function/template parameters,
property/layout order, method/virtual/behavior slots, constructor/factory order
where VM-significant, enum declaration order, global storage, initializer and
post-init order, instruction/relocation order, object/local tables, and debug
position maps preserve explicit contiguous ordinals. Readers reject gaps,
duplicates, out-of-range ordinals, and disagreement between ordinal and stored
position.

Validation distinguishes:

- `DuplicateKey`: identical logical key/ordinal encoded more than once;
- `ConflictingKey`: same key/ordinal with different owner/content/ABI/target;
- `NonCanonicalOrder`: unique set entries in the wrong canonical order; and
- `CaseCollision`: distinct logical paths ambiguous under required
  case-insensitive comparison.

A single snapshot selects at most one record per entity key. Different
historical versions may coexist only as pack content reachable by retained old
generations.

V1 strings use strict UTF-8, reject embedded NUL, preserve exact bytes, and do
no Unicode normalization. Source path collision checking traverses Unicode
scalar values with `FTextChar::GetCodepoint` and applies one
`FTextChar::ToLower` mapping to each code point only for comparison; it performs
no multi-code-point full fold and never changes stored or identity bytes.
CompatibilityKey isolates that engine/Unicode implementation. Namespace tables
reject empty/duplicate entries.

## Budgets, errors, and validation order

Read limits include explicit maximums for envelope/manifest/record stored and
raw bytes, pack bytes/index entries, generation records/module snapshots,
distinct generation PackIds,
array elements/nesting, UTF-8 strings/literals/paths, dependencies/relocations/
debug entries, total selected stored bytes, cumulative decompressed bytes,
cumulative decoded bytes, and cumulative resident decoded bytes. The
cumulative values are consumed by a read-
session budget; resetting a per-record limit for thousands of records is not a
generation memory budget.

`MaxGenerationPacks` defaults to 4,096 distinct PackIds. Writer and decoder
enforce it; the decoder returns BudgetExceeded before any pack lookup/open or
handle allocation.

Every reader follows:

1. prove fixed scalar bytes exist;
2. reject unknown enum/tag/boolean and checked-arithmetic overflow;
3. check field, record, and cumulative budgets;
4. prove `count * minimum element bytes` and ranges fit;
5. only then allocate/decompress;
6. validate UTF-8/path, canonical order, duplicate/conflict and local hashes;
7. publish the pointer-free record only on complete local success; and
8. validate graph/profile/source/ABI before engine mutation.

Typed error families are:

- malformed format: magic, archive/record schema, unknown kind/enum/tag,
  reserved bytes, boolean/optional, UTF-8/path, trailing data;
- arithmetic/budget: overflow, out of bounds, impossible count, budget;
- codec/integrity: unsupported codec, decompression, checksum, RecordId,
  PackId, GenerationId;
- canonical semantic: order, duplicate, conflict, case collision, zero key,
  missing/forbidden ABI;
- graph/ownership: missing dependency/record, wrong dependency/record kind,
  cross-module owner, unexpected record, source snapshot, debug link; and
- eligibility rather than corruption: compatibility, context, profile, source,
  or current ABI mismatch.

Task 2B-3 appends only `PackDecode=7`, `ManifestDecode=8`,
`ManifestGraph=9` and archive format/integrity errors `65..71`. Filesystem,
pointer, path, lock, I/O, cancellation and commit errors remain the separate
store `0..21` result space; only a content-validation store result nests the
archive failure.

Malformed manifest/index/pack identity rejects the generation. An invalid
record required by one ModuleSnapshot makes that complete snapshot a miss and
triggers its safe compile closure; it never enables partial attachment.
Eligibility mismatches are normal misses and never authorize different-source
stale behavior.

`FAngelscriptCacheValidationResult` carries Error, the uniquely classified
ValidationClass, RecordKind, validation Stage, and ByteOffset. One exhaustive
`Classify(Error)` is the only mapping authority and preserves the existing
envelope error values; call sites never select their own class. Errors `0..43`
and their mapping are fixed in `record-wire-v1.md`; the non-renumbering
Task 2B-2 additions `44..64` and their exact classes are fixed in
`record-wire-v1-remaining.md`.

## Task 2 no-live-engine vertical slices

### Task 2A — minimal record envelope

Preserve the existing fixed envelope and golden evidence, then close its
fail-closed public construction and aliasing boundaries. Task 2A completion
does not complete any full semantic-record/store checklist item.

### Task 2B-1 — primitives, SourceIndex, ModuleInterface

Implement canonical reader/writer cursors, data type/declaration/reference and
typed dependency values, SourceIndex, and ModuleInterface. Pure tests freeze
full record goldens and cover insertion order, ABI rules, invalid UTF-8/path,
case collision, semantic ordinals, duplicate/conflict/order, and injected tiny
budgets. The exact wire enums, field order, source-key domains, presence
matrices, derived hashes, per-scope eligibility, validation classes, and
collection comparators come only from `record-wire-v1.md`.

### Task 2B-2 — remaining records and graph validator

Implement explicit TypeSchema and ModuleState descriptors, versioned opaque VM
execution/initializer/debug byte fields, FunctionBody, DebugSidecar, keyed
ModuleSnapshot links, and the per-module `ValidateModuleSnapshotGraph` API.
Follow every exact field/hash/lifecycle/profile/error/budget rule in
`record-wire-v1-remaining.md`. Use its deterministic injectable fixture codec
only; no live AS engine. Test ownership/coverage, wrong kinds, initializer
ownership, debug absence, enum authority, complete-coordinate dependency/
relocation subset invariants, graph-versus-current mismatch precedence and one
caller-owned cumulative budget. Manifest reachability remains Task 2B-3.

### Task 2B-3 — manifest and in-memory pack format

Implement the exact `manifest-pack-wire-v1.md` header/index/location bytes,
keyed generation roots, exact reachable manifest index, allowed pack-only
historical extras, deterministic per-record None/canonical-Zlib pack encode/read
validation, and explicit read-session cumulative budgets over in-memory bytes.
Prove RecordId/RawChecksum/whole-file PackId/whole-file GenerationId
separation, MaxGenerationPacks-before-pack-access, and serial/randomized byte
determinism before live engine capture begins. The repo
`tasks.md` task group 3 exclusively owns filesystem roots, immutable disk read
sessions, Current/Previous/Pending selection, temporary-write publication,
crash recovery, system-wide locking/rebase, cancellation, source-aware
fallback, retention, and compaction.
