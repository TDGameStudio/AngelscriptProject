## ADDED Requirements

### Requirement: Cache V2 is logically segmented and physically packed

The Runtime SHALL represent six reusable semantic record kinds—source indexes, module interfaces, type schemas, module state, function bodies, and debug sidecars—as independent versioned content-addressed records. A generation manifest SHALL reference exactly one SourceIndex record. A content-addressed ModuleSnapshot assembly record SHALL bind one complete module activation from ModuleInterface, TypeSchema, ModuleState and FunctionBody records; each FunctionBody is the sole authority for its optional DebugSidecar link. The Runtime MUST aggregate multiple records into bounded immutable pack files and MUST NOT require one file per function, type, global, or module.

V1 manifest and pack bytes SHALL follow `manifest-pack-wire-v1.md`: manifest
magic/schema `UEASCV2M`/1; pack magic/schema `UEASCV2P`/1; 33-byte RecordIds,
65-byte module roots, 122-byte record locations, a 32-byte pack header, and
96-byte pack index entries with no native padding or trailing bytes. Packs
SHALL store canonical semantic payload bytes rather than nested record
envelopes. RawChecksum SHALL hash exactly the uncompressed payload; PackId and
GenerationId SHALL hash every byte of their complete final files and SHALL NOT
be serialized inside the file whose identity they define.

#### Scenario: One function body is updated

- **WHEN** a changed FunctionBody is published while other module/type/state/function records remain valid
- **THEN** the new generation references the existing unchanged records and packs
- **AND** only new content requires new pack bytes

#### Scenario: Store contents are inspected

- **WHEN** a project contains thousands of cached functions
- **THEN** the physical store consists of generation manifests and aggregated packs
- **AND** it does not contain one independent filesystem file for every function

#### Scenario: Compression policy changes physical bytes

- **WHEN** identical uncompressed records are packed with different valid codec output or physical layout
- **THEN** their semantic RecordIds remain identical
- **AND** the complete byte-exact pack files receive different PackIds
- **AND** an immutable pack filename is never reused for different bytes

#### Scenario: Zlib bytes are noncanonical

- **WHEN** a Zlib blob decompresses to the expected payload but differs from the fixed V1 `NAME_Zlib`/`COMPRESS_BiasMemory`/window-15 recompression
- **THEN** the pack is rejected as a codec/integrity failure
- **AND** the reader does not accept an alternate or trailing compressed stream under the same compatibility namespace

### Requirement: Exact restore records contain reconstructible semantic descriptors

Every record payload SHALL carry an explicit payload-schema version.
TypeSchema, ModuleState, FunctionBody, DebugSidecar, and ModuleSnapshot SHALL
each own an independent payload-version axis beginning at V1; equal initial
values MUST NOT couple their future upgrades. The Runtime MUST persist canonical
pointer-free data-type, declaration, property, method/behavior slot, import,
global/storage, metadata, reflection, and typed dependency descriptors
sufficient to rebuild an exact matching module without preprocessing or
parsing. Hash summaries MAY accelerate comparison but MUST NOT replace the
descriptor bytes required for reconstruction. Only versioned VM execution,
initializer, and debug payloads MAY remain opaque to the common archive, and
those payloads MUST be validated by their private codec before attachment.

#### Scenario: Exact SourceIndex and profile match

- **WHEN** a matching generation is selected without preprocessing or parsing current source
- **THEN** ModuleInterface, TypeSchema, and ModuleState provide every declaration/type/global/reflection descriptor needed to assemble the module
- **AND** no raw C++ struct layout, native pointer, UObject, FName index, numeric type/function ID, or host absolute path is required

#### Scenario: A record contains only declaration hashes

- **WHEN** a purported ModuleInterface or TypeSchema omits its reconstructible canonical declaration/type fields
- **THEN** that record is rejected as malformed rather than used for an exact no-parse restore

#### Scenario: One remaining record schema advances

- **WHEN** a reader receives a supported FunctionBody V1 alongside an unsupported TypeSchema payload version
- **THEN** only the TypeSchema decoder reports `UnsupportedPayloadSchema` with TypeSchema kind and payload-decode stage
- **AND** no shared version switch reinterprets either record through the other schema

### Requirement: The maintained AngelScript fork is an authorized implementation surface

All code under `Plugins/Angelscript` SHALL be considered part of the authorized
Cache V2 implementation surface. When complete artifact capture, validation,
restoration, stable identity, dependency tracking, or incremental invalidation
cannot be implemented coherently through existing plugin-facing seams, the
implementation MAY extend the maintained AngelScript fork under
`Source/AngelscriptRuntime/ThirdParty/angelscript`, including its builder,
compiler, bytecode, module/function representation, VM, and restore internals.
The implementation MUST NOT duplicate incomplete compiler/VM behavior or accept
partial runtime state solely to avoid modifying the maintained fork. Existing
AngelScript language syntax and unrelated script behavior SHALL remain unchanged
unless a later explicit requirement says otherwise. Once a Cache V2 requirement
and focused implementation evidence establish that a lower-level change is
needed, no separate scope exception or renewed authorization SHALL be required
before modifying any code under `Plugins/Angelscript`; the rationale,
compatibility impact, focused tests, and verification evidence SHALL instead be
recorded progressively in this OpenSpec.

#### Scenario: Complete function restoration needs a lower-level hook

- **WHEN** an outer Runtime adapter cannot capture or restore every VM-private field needed for an exact FunctionBody hit
- **THEN** the implementation extends the smallest coherent maintained-fork builder/compiler/VM seam
- **AND** validates and reconstructs the complete runtime artifact before publishing it
- **AND** does not fall back to raw-bytecode attachment, obsolete numeric FunctionId pairing, or a partial adapter imitation merely to avoid changing fork code

#### Scenario: A lower-level change is unnecessary

- **WHEN** an existing maintained interface already supports the required behavior completely and correctly
- **THEN** the implementation may use that interface without changing fork internals
- **AND** the authorization to modify all plugin code does not require unrelated source churn

### Requirement: ModuleInterface declares exact schema and body coverage

Every persistent ModuleInterface declaration SHALL carry explicit
Required/Forbidden TypeSchema and FunctionBody coverage values. V1 SHALL NOT
infer coverage from a function name, flags, record presence, or declaration
kind at graph-validation time, and SHALL NOT encode an Optional state. A
producer that cannot capture a required body SHALL mark the complete snapshot
NotCacheable rather than publish partial coverage. ModuleSnapshot validation
SHALL require exact equality between Required entity sets and keyed child links
and SHALL reject a child record for a Forbidden entity.

#### Scenario: A body is linked for a forbidden declaration

- **WHEN** a ModuleSnapshot links a FunctionBody for an abstract, delegate-signature, or ModuleState-owned initializer declaration marked BodyCoverage Forbidden
- **THEN** graph validation rejects the complete snapshot as inconsistent
- **AND** no function body is partially attached

#### Scenario: A required body cannot be captured

- **WHEN** a persistent executable function requires FunctionBody coverage but the producer cannot represent its semantics or VM payload
- **THEN** the complete snapshot is NotCacheable
- **AND** the writer does not weaken coverage to Optional or Forbidden

### Requirement: ModuleInterface local owners resolve through an exact matrix

Every Type and Global declaration SHALL be Module-owned by the enclosing
ModuleKey. Every ordinary Property SHALL resolve only to a local Class or
Struct; ordinary Method SHALL resolve only to local Class, Struct, or Interface;
other Type-owned callables SHALL follow their exact V1 TypeKind row. A Delegate
MAY additionally own only the Generated-trait-gated Property/Method/Constructor/
Destructor/GeneratedDefaultConstructor/InitDefaults rows in the normative
common matrix; Factory and every non-generated Delegate variant remain
forbidden. GlobalInitializer SHALL
resolve to a local Global declaration;
and Module-owned callables SHALL use the enclosing ModuleKey. V1 SHALL freeze
the owner-kind matrix for GlobalFunction, Method, Constructor, Destructor,
Factory, DelegateSignature, ModuleInitializer, GlobalInitializer,
GeneratedDefaultConstructor, and InitDefaults. DelegateSignature SHALL be
owned only by a local Delegate or Funcdef Type. Property-owned callables are
not representable in V1 ModuleInterface.

After local shape/hash/order checks, enclosing/Module-owner mismatch SHALL be
`CrossModuleOwner`; incompatible owner kind or a key found under the wrong
local declaration kind SHALL be `WrongReferenceKind`; and an owner absent from
all local indexes SHALL be `MissingOwner`. No local owner MAY silently resolve
to another module.

For Global/Property identity, CanonicalTypeSpelling and DeclaredType SHALL both
be present, valid, and included in key/signature/interface hashes. The 2B-1
pure decoder MUST NOT claim semantic spelling equality because script/
environment types carry only stable key/ABI and no canonical name. The producer
SHALL derive both from one compiler type; a later TypeSchema/current resolver
SHALL compare equality when it owns canonical spelling authority. A stricter
pure-local rule requires a versioned schema addition.

ImportKey SHALL likewise have one public fail-closed identity-only builder over
ModuleKey, namespace/name/signature, TargetModuleKey, and target
StableFunctionKey. Target ExpectedAbi/ReferenceKind and Slots SHALL not enter
that builder or control identity-input success; full Import preparation SHALL
validate them separately before publication.

#### Scenario: Delegate signature has a class owner

- **WHEN** a DelegateSignature declaration resolves its Type owner to a Class rather than Delegate or Funcdef
- **THEN** ModuleInterface validation reports `WrongReferenceKind`
- **AND** no later TypeSchema is allowed to reinterpret the owner

#### Scenario: Non-generated method or property has a forbidden TypeKind owner

- **WHEN** a Method is owned by Enum/Typedef/Funcdef, a Property is owned by Interface/Enum/Typedef/Funcdef, or either is Delegate-owned without its exact Generated traits
- **THEN** ModuleInterface validation reports `WrongReferenceKind`
- **AND** no TypeSchema is emitted for that invalid member graph

#### Scenario: Generated Delegate members have explicit common owners

- **WHEN** a generated Delegate owns its generated inner Property, Method, Constructor, Destructor, GeneratedDefaultConstructor, or InitDefaults declaration
- **THEN** ModuleInterface accepts the exact trait-gated owner row and preserves that stable declaration/body authority
- **AND** it does not infer the member later from DelegateSignature text

#### Scenario: Global initializer owner is missing

- **WHEN** a GlobalInitializer names no local Global declaration
- **THEN** ModuleInterface validation reports `MissingOwner`
- **AND** the initializer cannot be published in ModuleState

#### Scenario: Pure decoder sees opaque type spelling

- **WHEN** a valid ScriptType DeclaredType has nonzero StableKey/ExpectedAbi and a present CanonicalTypeSpelling
- **THEN** 2B-1 validates their shape and hashes without parsing text or guessing a name from the key
- **AND** producer and resolved-authority equality remain mandatory downstream

#### Scenario: Import route ABI changes without identity change

- **WHEN** two Import identity inputs are equal but full Import records carry different Target ExpectedAbi or slot data
- **THEN** `TryBuildImportKey` returns the same full key for both identity inputs
- **AND** full Import validation independently accepts or rejects route ABI/reference/slot shape

### Requirement: Record links are keyed and graph ownership is validated

A ModuleSnapshot SHALL link one ModuleInterface and one ModuleState by ModuleKey, TypeSchema records by `{TypeKey, RecordId}`, and FunctionBody records by `{FunctionKey, RecordId}`. A generation manifest SHALL link ModuleSnapshots by `{ModuleKey, RecordId}` and SHALL index exactly the transitive record set reachable from its one SourceIndex and those ModuleSnapshots, including FunctionBody-owned DebugSidecars. Historical records MAY remain in immutable packs but MUST NOT appear as unreachable extras in a new manifest.

#### Scenario: Two records claim one entity key

- **WHEN** one ModuleSnapshot links two different TypeSchema or FunctionBody records under the same stable entity key
- **THEN** graph validation rejects the snapshot as a conflicting key
- **AND** neither record is partially attached

#### Scenario: A keyed record belongs to another module

- **WHEN** a TypeSchema, ModuleState, FunctionBody, or ModuleSnapshot link resolves to a record whose embedded owner key differs from the link or owning module
- **THEN** graph validation reports a typed cross-owner failure
- **AND** the complete owning ModuleSnapshot is a miss

#### Scenario: Manifest contains an unreachable extra record

- **WHEN** a generation record index contains content not reachable from its SourceIndex, keyed ModuleSnapshots, and FunctionBody sidecars
- **THEN** the manifest is rejected as noncanonical
- **AND** old pack content remains independently retainable by older generations

### Requirement: SourceIndex internal references and eligibility reasons are exact

Before publication, SourceIndex SHALL resolve Mount.ProviderKey to Provider;
File.MountKey to Mount with equal SourceKind/ProviderKey; Hook affected scope,
Input owner scope, and IneligibleScope by typed ScopeKind to Mount/Provider/
Hook/File or the ModuleKey set derived only from Files; Input target by its tag;
and Edge From/To by EdgeKind to SourceFile or the generated-key set derived
from present File.GeneratedSourceKey values. V1 MUST publish no dangling source
reference and MUST NOT introduce a second module authority table.

The six Mount/Provider/Hook/File/Input/Edge stable-key algorithms SHALL each
have one public fail-closed typed Runtime builder that accepts only the
identity inputs in its canonical hash stream, delegates to the shared artifact
canonical writer, returns a full typed hash, and leaves zero output on failure.
Encoders, producers and tests MUST NOT copy those domain/hash algorithms.
Every present GeneratedSourceKey SHALL have exactly one File authority; two
distinct Files claiming one key SHALL be `ConflictingKey` before target/edge
resolution.

After scalar/presence/hash/order/duplicate validation, a target absent from its
tag-selected index but present in another typed source authority SHALL be
`WrongReferenceKind`; a target absent from every authority SHALL be
`MissingGraphTarget`; and a resolved File/Mount SourceKind or ProviderKey
disagreement SHALL be `ConflictingKey`.

For each Provider and Hook, StableIdentity, VersionFingerprint,
ConfigurationFingerprint and ContentFingerprint capability presence SHALL be
bidirectional with the exact same-scope/key missing reason fixed by V1. An
unset capability requires its matching reason; a set capability forbids that
reason. Other semantically valid independent reasons MAY coexist but MUST NOT
satisfy another missing capability. Within each
`{FromSourceFileKey, EdgeKind}` group, SourceEdge SemanticOrdinal SHALL be all
absent or all present as a unique contiguous `0..N-1` set; mixed presence is
`InvalidPresence`.

The Runtime SHALL expose a pure exact-fast-path eligibility query taking one
validated SourceIndex and ModuleKey. It SHALL derive that module's Files,
Mounts, Providers, and fixed-point affected-Hook closure, then return a boolean
and the exact canonical matching IneligibleScope rows/reasons. A ModuleKey with
no File SHALL return `MissingGraphTarget` with cleared output. No global
eligibility boolean SHALL be persisted or inferred, and an unrelated closure
MUST remain eligible.

HookKey SHALL continue to hash its AffectedScopeStableKey. A Hook scoped to
another Hook therefore references an already-built HookKey; a valid producer
SHALL construct Hooks outward from a non-Hook scope. A self-cycle or multi-Hook
cycle satisfying every derived key would require a BLAKE3-256 fixed point and
is not a valid V1 producer graph. A manually forged cycle MUST fail existing
`DerivedHashMismatch` during derived-key validation before eligibility is
queried. V1 MUST NOT add a cycle-specific error or iterative HookKey-hash
solver. The eligibility fixed point is only transitive set closure over the
already validated authority chain.

#### Scenario: Source reference uses the wrong typed authority

- **WHEN** an Include edge target hash is absent from SourceFiles but equal to a ProviderKey
- **THEN** SourceIndex validation reports `WrongReferenceKind`
- **AND** it does not treat the provider as an include file or publish the index

#### Scenario: Public source-key builder rejects identity input

- **WHEN** any typed source-key builder receives an invalid enum/tag/optional, UTF-8/path, or referenced-key identity input
- **THEN** it returns the typed failure with zero output
- **AND** no encoder-private or producer-local hash path supplies an alternate key

#### Scenario: Two files claim one generated source key

- **WHEN** distinct SourceFiles contain the same present GeneratedSourceKey
- **THEN** SourceIndex validation returns `ConflictingKey`
- **AND** a GeneratedSource input/edge cannot resolve an ambiguous authority

#### Scenario: Source reference is dangling

- **WHEN** a hook scope, input owner/target, mount provider, file mount, or edge endpoint exists in no expected or alternate source authority
- **THEN** SourceIndex validation reports `MissingGraphTarget`
- **AND** the source snapshot cannot become an exact-fast-path authority

#### Scenario: Capability and missing reason contradict

- **WHEN** a provider advertises a stable version fingerprint but its own Provider scope also carries MissingVersionFingerprint
- **THEN** SourceIndex validation reports `InvalidPresence`
- **AND** unrelated valid ineligibility reasons remain independently representable

#### Scenario: Source edge ordinal presence is mixed

- **WHEN** two edges in one `{FromSourceFileKey, EdgeKind}` group have one present and one absent SemanticOrdinal
- **THEN** SourceIndex validation reports `InvalidPresence`
- **AND** it does not infer order from canonical edge-array position

#### Scenario: Two modules have different eligibility closures

- **WHEN** one validated SourceIndex contains two modules and a provider/hook reason is reachable only from the first module's file/mount/provider/hook closure
- **THEN** the pure query returns that canonical matching reason and false only for the first module
- **AND** the second module returns an empty reason set and true

#### Scenario: A detached Hook chain is unrelated

- **WHEN** a validated SourceIndex contains a base-to-dependent Hook chain for one module and a detached Hook chain that no target file/mount/provider/module reaches
- **THEN** eligibility transitively includes only the reachable chain
- **AND** detached Hooks do not contaminate that module or an unrelated module

#### Scenario: A forged Hook cycle is presented

- **WHEN** hand-authored SourceIndex rows attempt a Hook self-cycle or multi-node cycle
- **THEN** HookKey recomputation reports `DerivedHashMismatch` before eligibility
- **AND** no cycle-specific error or HookKey fixed-point computation is used

#### Scenario: Eligibility query names an absent module

- **WHEN** the pure query receives a ModuleKey not derived from any SourceFile
- **THEN** it returns `MissingGraphTarget` and clears output
- **AND** it does not manufacture a module-wide global miss

### Requirement: TypeSchema has one explicit reconstructible authority model

V1 TypeSchema SHALL encode Class, Struct, Interface, Enum, Delegate, Typedef,
and Funcdef with stable nonzero kind values `1..7`; explicit canonical
relations with ordered direct implemented interfaces, semantic layout including
hash-bound per-property storage kind/size/alignment, BaseType/UClass CodeRoot/
UStruct StructHeader numeric LayoutInputs, exact property offsets and terminal
alignment, property flags/access/
replication, distinct ordered public-method and VFT sequences, grouped behavior
slots, type-kind payload, reflection kind/flags/optional names plus explicit
ordered UFunction membership, metadata, and dependencies. ModuleInterface SHALL remain the
sole stable TypeKey identity authority, and graph validation SHALL require the
TypeSchema module/kind/namespace/name/declaration coordinate to equal it rather
than derive a second key. Super/interface/compose/metadata fields MUST have one
authority, constructor/factory order MUST exist only as behavior-slot groups,
and executable defaults MUST exist only as an InitDefaults FunctionBody.

Local TypeSchema validation SHALL replay the maintained `LayoutClass` cursor
from persisted pointer-free evidence before any current resolver is called. A
present boundary contribution MAY be zero and remains distinct from an absent
optional; property storage size and every alignment contribution MUST be
nonzero, alignments MUST be powers of two, and all maintained object arithmetic
MUST fit nonnegative `int32`. `UASStruct::ScriptValueOffset` contributes only a
boundary. An ordinary UClass SHALL retain its code-root/shadow alignment with or
without a Script Base; when Base exists, Base supplies the cursor boundary and
the CodeRoot boundary is absent. Same-module linked Base/inline-value layouts
SHALL be compared as immutable graph authorities. Selected-module Script*
dependencies and layouts, primitive storage, and ObjectHandle slots SHALL make
zero current resolver calls; a missing required local child SHALL fail immutable
coverage. A legal external/environment single witness SHALL be compared only
after graph success through a distinct required per-engine current-layout
resolver with no process-global fallback. The resolver SHALL be callable before
the selected module has live script types and SHALL receive an allocation-free
read-only prospective view over validated local TypeSchemas for environment
recipes nested over local value subtypes. A layout-input resolver result SHALL
describe raw current coordinates by role; the validator SHALL apply the already-
validated stored consumption mask before comparison. Thus one CodeRoot result
can serve both a root UClass that consumes boundary+alignment and a script-
derived UClass that consumes alignment only.

Primitive and ObjectHandle comparison SHALL use the engine-free V1 maintained-
build table in `type-layout-authority-v1.md`, including AS bool/pointer/int64/
double ABI. The first production CompatibilityKey assembler SHALL include every
listed table coordinate so another build cannot select the same profile and then
reinterpret those fixed slots.

Typedef TypeSchema SHALL preserve the live descriptor `{primitive alias size,
alignment 4}`, while a typedef property SHALL encode the primitive datatype to
which `aliasForType` was expanded. Funcdef SHALL preserve live descriptor
`{size 0, alignment 4}` but SHALL be NotCacheable as V1 property storage.

Enum values SHALL be signed `int32` little-endian with contiguous declaration
ordinals and unique names; distinct names MAY alias one numeric value, and
enumerator metadata SHALL enter the enum-authority hash. Reflection presence,
known masks and contradictions SHALL follow the remaining-wire V1 matrix.
Ordinary UClass reflection SHALL permit optional nonempty ConfigName (absence
inherits superclass config) and require StaticClassGlobalName. A synthetic
StaticsClass UClass and every non-UClass form SHALL forbid both; the
StaticsClass flag SHALL be a bidirectional synthetic-class discriminator.
UFunction membership and ClassGenerator order SHALL come only from explicit
reflected-member rows; a declaration whose ReflectionFlags mask is zero MAY be
present, and no nonzero flag mask SHALL imply membership by itself.

#### Scenario: Constructor order is duplicated outside behavior slots

- **WHEN** a producer attempts to persist an independent constructor/factory array in addition to grouped behavior slots
- **THEN** the V1 DTO/wire cannot encode that second authority
- **AND** graph restore uses only contiguous behavior-slot ordinals

#### Scenario: Enum aliases retain one authority

- **WHEN** two unique enumerator names share one signed-int32 value and have canonical metadata
- **THEN** TypeSchema preserves both declaration ordinals and accepts the numeric alias
- **AND** changing either name, value, ordinal, or metadata changes EnumAuthorityHash

#### Scenario: Reflection optional names contradict the class form

- **WHEN** a synthetic StaticsClass carries ConfigName or StaticClassGlobalName, or an ordinary UClass omits StaticClassGlobalName
- **THEN** local/graph validation rejects the TypeSchema before ClassGenerator mutation

#### Scenario: Public method order differs from VFT order

- **WHEN** a derived class has a new local method, an override, and one inherited non-overridden method
- **THEN** TypeSchema preserves exact `asCObjectType::methods` order and exact virtual-function-table order in two independent sequences
- **AND** warm reconstruction MUST NOT derive either by reordering the other

#### Scenario: Direct interfaces are reordered

- **WHEN** an otherwise identical class changes only the order of its directly implemented interfaces
- **THEN** their semantic ordinals and TypeLayoutHash change
- **AND** base-first transitive closure is deterministically derived with first-visit diamond deduplication rather than serialized as direct rows

#### Scenario: A reflected layout input is replayed

- **WHEN** an ordinary UClass with a Script Base carries Base boundary/alignment and CodeRoot shadow alignment, or a reflected UStruct carries its ScriptValueOffset header boundary
- **THEN** local validation reproduces every exact property offset, aggregate alignment, and terminal size without a live resolver
- **AND** the derived UClass forbids a CodeRoot boundary while the UStruct forbids a header alignment contribution

#### Scenario: Stored and current layout failures compete

- **WHEN** a linked same-module Base or inline-value TypeSchema disagrees with its consuming witness and the current-layout resolver would also be missing or unequal
- **THEN** `GraphAbiMismatch` wins before any current-layout call
- **AND** a self-consistent cross-module or environment single witness instead reaches current eligibility and returns `CurrentSymbolMissing` or `CurrentAbiMismatch` there

#### Scenario: Cold exact restore has no selected-module live types

- **WHEN** a self-consistent exact-hit snapshot contains same-module Script* dependencies, a Script Base, inline-value local properties, primitive properties, ObjectHandles, and an environment template nested over a local value type while neither current resolver contains selected-module live entries
- **THEN** graph/profile-closed coordinates restore with zero selected-module `CurrentSymbols` and `CurrentLayouts` calls
- **AND** the one eligible outer environment recipe reads the immutable prospective local TypeSchema view before materialization
- **AND** a missing required local TypeSchema fails immutable coverage rather than falling through to external current lookup

#### Scenario: TypeSchema semantic failures have one deterministic order

- **WHEN** two otherwise independently valid mutations compete across LayoutInputHash, a property StorageLayoutHash or PropertyLayoutFingerprint, EnumAuthorityHash, Dependencies, layout replay, and TypeLayoutHash
- **THEN** complete physical exhaustion occurs first, field-local validation follows exact top-level wire order, cross-field pairing/coverage/layout replay follows only after all field-local checks, and TypeLayoutHash is last
- **AND** the exact winner, validation stage, record kind, and captured enclosing-field ByteOffset are identical across serial and parallel preparation

#### Scenario: A payload has trailing bytes and a bad derived hash

- **WHEN** a physically decoded TypeSchema contains an extra trailing byte and also has a mismatching TypeLayoutHash or EnumAuthorityHash
- **THEN** `TrailingData/PayloadDecode` wins at the first extra byte
- **AND** derived-hash validation begins only after complete payload exhaustion

#### Scenario: Zero-flag function remains reflected

- **WHEN** an ordinary UClass method or StaticsClass module GlobalFunction has zero ReflectionFlags but appears in OrderedUFunctionMembers
- **THEN** ClassGenerator restores a UFunction at the stored reflection ordinal
- **AND** an otherwise equal declaration absent from that list remains an ordinary non-reflected AS function

### Requirement: Function invocation kind maps to one shared identity declaration

FunctionBody graph validation SHALL use the V1 invocation-to-ModuleInterface
EntityKind, owner, and Generated-trait matrix. V1 MUST NOT add or renumber a
Task 1 `GeneratedDefaultDestructor` EntityKind: that invocation SHALL use the
existing `EntityKind::Destructor=35`, a Type owner, and required Generated
trait. Public single functions and lambdas SHALL be cacheable only when their
stable declaration, owner, generated trait and canonical identity trait are
represented; otherwise the capture result is NotCacheable.

#### Scenario: Generated default destructor is restored

- **WHEN** a FunctionBody declares InvocationKind GeneratedDefaultDestructor
- **THEN** its ModuleInterface declaration is `EntityKind::Destructor=35` with Type owner and Generated trait
- **AND** a new shared entity discriminator is neither required nor accepted

#### Scenario: Invocation and declaration disagree

- **WHEN** an ordinary Destructor declaration without Generated trait is linked to a GeneratedDefaultDestructor FunctionBody
- **THEN** graph validation returns `InvocationKindMismatch`
- **AND** no body is attached

### Requirement: ModuleState exclusively owns V1 global initializer execution

The Runtime SHALL encode ModuleState with the selected ArtifactProfileKey,
ordered explicit global storage descriptors, mutually exclusive Default/
PureConstant/VmInitializer tags, canonical hard values, a canonical set of
stable-keyed versioned initializer VM payloads, one dependency-solved
OrderedInitializationActions sequence that interleaves DefaultConstructGlobal
and ExecuteInitializer, ordered same-module post-init references, typed
dependencies, and per-global cleanup policy. V1 MUST NOT publish or
activate an initializer as an independent FunctionBody record and MUST NOT
persist an opaque ModuleLifetime field or initialized-state bit. TypeSchema
SHALL be authoritative for enum enumerator declaration/name/value/metadata/
reflection shape; ModuleState SHALL carry exactly one derived enum-authority
fingerprint for every local enum and MUST validate it against TypeSchema.
Primitive and resolved ScriptType cleanup SHALL close inside the immutable
graph. EnvironmentType cleanup SHALL remain one of the locally allowed
candidates until current eligibility step 10 first reads the resolver's explicit
`CurrentValueStorageKind`; missing, invalid, or unequal mapping SHALL be
`CurrentAbiMismatch`/Ineligible and MUST NOT be reported early as
`GlobalCoverageMismatch`.

Canonical PureConstant values SHALL use the fixed width selected by the
declared type: bool, signed/unsigned 8/16/32/64-bit integer, exact IEEE
binary32/binary64 bits, or enum signed-int32. Compiler-evaluated NaN payloads
and signed zero SHALL be preserved. Strings, objects, handles, UObjects and
mutable runtime values MUST NOT be encoded as PureConstant.

#### Scenario: One global initializer changes

- **WHEN** an initializer body, dependency, constant, or dependency-solved order changes
- **THEN** the complete owning ModuleState is a miss
- **AND** no old initializer FunctionBody is independently reused or activated

#### Scenario: Enum hard-value state disagrees with its schema

- **WHEN** ModuleState's derived enum hard-value fingerprint does not match the linked TypeSchema authority
- **THEN** the ModuleSnapshot is rejected before global allocation or engine mutation

#### Scenario: Global lifecycle activates successfully

- **WHEN** a complete ModuleState passes graph and current-profile validation
- **THEN** the loader allocates/zeros all globals, installs pure constants, executes the exact interleaved initialization-action sequence, runs ordered same-module post-init functions, and only then publishes active state
- **AND** before each global-owning action attempt it pushes that non-None global once and failure or normal release pops exact reverse action-attempt order without reading an initialized bit from cache

#### Scenario: Initializer coverage is ambiguous

- **WHEN** declaration/unit/ExecuteInitializer target sets differ, a VmInitializer global has zero or two owning units/actions, a Module initializer carries OwnerGlobal, a Default DestroyValue global lacks its DefaultConstructGlobal action, or more than one Module initializer exists
- **THEN** graph validation reports an initializer-ownership/coverage failure
- **AND** the complete ModuleState remains inactive

#### Scenario: A NaN pure constant is cached

- **WHEN** the compiler evaluates a valid float/double NaN constant
- **THEN** ModuleState preserves the exact IEEE bit pattern used by compilation
- **AND** it does not normalize the NaN or serialize a host numeric container

### Requirement: Opaque VM payloads publish validated common summaries

The common cache graph SHALL treat function execution, initializer execution,
and debug payload bytes as opaque and SHALL validate them through an injectable
`IAngelscriptCacheOpaquePayloadValidator`. A successful codec result SHALL
publish only the domain-correct validated payload hash, ordered relocations,
exact debug source set, and owned CanonicalName/StringLiteral UTF-8 bytes.
The validator SHALL receive a narrow charge sink backed by the module graph's one
private decoded-candidate transaction and extend it before every allocation
retained by that summary; codec-local
scratch SHALL use the caller's ordinary read Budget. The codec SHALL NOT promote
or otherwise control the private transaction. The graph SHALL promote its complete candidate once
only after all graph and current-environment checks succeed, so a late failure
leaves no retained summary charge or partial output.
Task 2B-2 SHALL use a deterministic fixture codec through the same seam; the
real VM codec MAY replace it later without changing common record/graph
interfaces.

Every relocation SHALL be a subset match against the owning complete semantic
dependency set on dependency kind, reference kind, full StableKey, ExpectedAbi,
and ExpectedContentOrValue presence/hash. CanonicalName/StringLiteral SHALL use
zero ExpectedAbi, bypass current-symbol resolution, and have codec-owned bytes
whose domain hash equals their StableKey. For each initializer summary those
owned rows SHALL be the exact set selected by its CanonicalName/StringLiteral
relocations: missing and extra rows both reject. Reachable initializer codecs
SHALL be called exactly once in ExecuteInitializer action order and fail fast;
caller token/map insertion order MUST NOT change the first error or call prefix.
Common graph code MUST NOT parse VM instructions or debug byte layout itself.

#### Scenario: Relocation differs only by content coordinate

- **WHEN** an opaque codec returns a relocation with the same key and ABI as a semantic dependency but a different ExpectedContentOrValue presence or hash
- **THEN** graph validation reports `RelocationDependencyMismatch`
- **AND** the payload is not attached

#### Scenario: A semantic dependency has no relocation

- **WHEN** an overload/layout/compile-option dependency affects compilation but leaves no final VM operand
- **THEN** the FunctionBody remains valid with that extra semantic dependency
- **AND** relocation validation uses subset rather than equality

#### Scenario: Common graph receives malformed VM bytes

- **WHEN** the injected codec rejects the opaque payload or exceeds the shared budget
- **THEN** common graph validation propagates the typed codec/budget result and empty output
- **AND** common cache code does not attempt a fallback bytecode parse

### Requirement: Declaration ABI and embedded content dependencies are distinct

Stable references to script modules, types, functions, globals, properties, imports, and environment symbols SHALL carry nonzero declaration/layout/storage/route ABI expectations. `ScriptFunction.ExpectedAbi` SHALL describe declaration/signature/traits/call ABI rather than ordinary callee implementation content. If compilation embeds or folds a callee's content, a constant value, or another hard value, the record MUST carry a separate typed content/value dependency. CanonicalName and StringLiteral references SHALL carry zero ABI and SHALL be validated against canonical bytes owned by the same explicit VM/state/debug payload.

#### Scenario: Callee body changes without ABI change

- **WHEN** a caller routes through the same stable function declaration and only the callee implementation content changes
- **THEN** the caller remains eligible for a FunctionBody hit
- **AND** the callee content change does not masquerade as a declaration ABI mismatch

#### Scenario: A constant is folded into a function

- **WHEN** compilation embeds a global or enum hard value in function execution
- **THEN** the FunctionBody records a separate typed hard-value/content fingerprint
- **AND** changing that value invalidates the dependent body even when storage/declaration ABI is unchanged

#### Scenario: Name or string relocation is restored

- **WHEN** a FunctionBody or ModuleState contains a CanonicalName or StringLiteral relocation
- **THEN** the owning payload contains the canonical encoding and bytes whose domain hash equals the stable key
- **AND** no process FName index, address, or external string-table offset is read from cache

### Requirement: Debug sidecar absence has a canonical content coordinate

Each FunctionBody SHALL be the sole authority for its optional DebugSidecar
link. A present sidecar MUST carry the same FunctionKey and full ArtifactProfileKey,
and its payload-only `function-debug` hash MUST equal both stored DebugHash and
the FunctionBody identity's debug coordinate. An absent sidecar SHALL be an
unset optional plus the shared artifact-identity
`H("function-debug-absent", full ArtifactProfileKey)` coordinate, never a zero
RecordId/hash or `function-debug` hash of empty bytes. The shared API and full
Editor/Shipping golden vectors SHALL be consumed by both Cache and the sibling
StaticJIT contract.

Each debug source SHALL use typed SourceFileKey and LogicalSectionKey. The
logical key SHALL hash the typed source key plus exact strict-UTF-8 logical
section bytes under `cache-debug-logical-section`, with no normalization.
Numeric script section indices MUST NOT appear in the DTO/wire. Explicit source
rows SHALL equal the opaque codec's validated source summary exactly.

#### Scenario: Shipping profile omits debug payload

- **WHEN** a valid Shipping FunctionBody has no DebugSidecar
- **THEN** its execution content remains independently verifiable
- **AND** its debug coordinate equals the canonical profile-specific absent digest

#### Scenario: Sidecar function key differs

- **WHEN** a FunctionBody links a valid DebugSidecar record belonging to another FunctionKey
- **THEN** graph validation reports a typed debug-link mismatch
- **AND** the sidecar is not attached

#### Scenario: Empty debug is used as absence

- **WHEN** a body has no sidecar but carries the `function-debug` hash of an empty payload rather than the profile-specific absence hash
- **THEN** graph validation reports a debug-link mismatch
- **AND** it does not reinterpret the empty payload coordinate as absence

#### Scenario: Logical section bytes are normalized

- **WHEN** stored LogicalSectionKey was computed from bytes other than the exact stored strict-UTF-8 logical section or a numeric section index is supplied
- **THEN** local debug validation rejects the source reference
- **AND** no process-local section mapping is trusted

### Requirement: Validation is versioned, cumulative, and distinguishes corruption from ineligibility

The loader MUST validate the physical archive schema, each semantic record
payload schema, and each VM execution/initializer/debug codec version
independently. Read limits SHALL cover per-field and per-record counts/bytes
plus read-session cumulative stored, decompressed, and resident decoded bytes.
One caller-owned `FAngelscriptCacheReadBudget` SHALL be passed through every
child decode, graph index/resident DTO allocation and opaque-codec payload/
summary; no child MAY reset it. TypeSchema SHALL additionally cover every
actual decoded, local-scratch, graph-index, current-layout-memo, and candidate-
output allocation family through the exhaustive `TS-SCR-01..22` matrix: exact
allocator capacity succeeds, one byte short fails before allocation, temporary
reservations release on every exit, monotonic counters do not refund, and shared
candidate-output sites are charged/promoted exactly once. A generic cumulative-
budget test SHALL NOT replace those rows. Validation SHALL distinguish malformed format,
arithmetic/budget, codec/integrity, canonical semantic, graph/ownership, and
normal eligibility mismatch through one exhaustive classification authority.
Errors `0..43` SHALL retain their values, Task 2B-2 SHALL append only the
frozen `44..64` errors, and Task 2B-3 SHALL append only manifest/pack format and
integrity errors `65..71`. Task 2B-3 SHALL append validation stages only as
`PackDecode=7`, `ManifestDecode=8`, and `ManifestGraph=9`. Results SHALL carry
record kind, validation stage and first failing byte/field offset. Filesystem,
path, lock, I/O, atomic-publication, cancellation and commit outcomes MUST use
the separate store-result error space and MUST NOT consume archive error
numbers; a content failure MAY nest its archive validation result.

Validation precedence SHALL be local decode/integrity, then immutable graph
self-consistency, then current source/profile/symbol eligibility. Internal
record ABI/profile/source contradictions MUST be GraphOrOwnership. Only a
self-consistent stored graph compared with current source/profile/ABI/content/
symbol existence MAY return a typed Ineligible miss.

#### Scenario: Many individually valid records exceed the session budget

- **WHEN** every record is below its individual limit but their cumulative selected raw/decompressed/resident bytes exceed the read-session limit
- **THEN** loading stops with `BudgetExceeded` before further allocation or engine mutation

#### Scenario: A manifest references too many distinct packs

- **WHEN** a manifest contains more than the configured `MaxGenerationPacks` distinct nonzero PackIds
- **THEN** writer or decoder returns `BudgetExceeded`
- **AND** the decoder performs no pack lookup, open, or handle allocation

#### Scenario: Record payload version is unsupported

- **WHEN** an envelope is valid but the selected record kind's payload schema or VM codec version is unsupported
- **THEN** the loader reports the precise unsupported stage and kind
- **AND** it does not reinterpret the payload through a raw struct or another record schema

#### Scenario: Current environment ABI differs

- **WHEN** record bytes and graph are valid but one referenced current environment symbol has another ABI fingerprint
- **THEN** the affected record/snapshot is an ABI eligibility miss
- **AND** diagnostics do not label the immutable pack corrupt

#### Scenario: Immutable ABI disagrees before current resolution

- **WHEN** FunctionBody ExpectedDeclarationAbi differs from its linked ModuleInterface declaration ABI even though the current resolver would also differ
- **THEN** validation reports `GraphAbiMismatch` before invoking current eligibility resolution
- **AND** the contradiction is not relabeled as `CurrentAbiMismatch`

#### Scenario: Current symbol is missing or content differs

- **WHEN** a self-consistent graph resolves no current target or resolves unequal required current content
- **THEN** validation returns distinct `CurrentSymbolMissing` or `CurrentContentMismatch` Ineligible results
- **AND** it does not label the record malformed

### Requirement: Task 2B-2 validates one module graph without manifest reachability

The Runtime SHALL expose per-module `ValidateModuleSnapshotGraph` that follows
one requested ModuleSnapshot's redundantly keyed ModuleInterface/ModuleState,
TypeSchema, FunctionBody and body-owned DebugSidecar links. It SHALL validate
exact schema/body/global/enum/initializer-unit/initialization-action/post-init
coverage, TypeSchema direct-interface/method/VFT/reflected-member order,
persisted layout replay and linked-layout equality, ownership, invocation,
profile/source/ABI, current numeric layout, relocation and debug invariants in
the normative 11-step order and publish an immutable module graph only after
total success. Task 2B-2
MUST NOT require a generation manifest or reject unrelated records in the
caller's record pool. Exact manifest reachability and unreachable-extra checks
SHALL remain Task 2B-3.

Remaining records SHALL be supplied as factory-created thread-safe shared const
handles whose token/control/DTO allocation is charged once at decode. The
sole owning handle type SHALL be
`TSharedRef<const FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>`.
The declared-RecordId factory SHALL publish it through an atomic
`TOptional<FAngelscriptDecodedCacheRecordHandle>` output slot, clear that slot
on every failure, and expose no nullable `TSharedPtr`, per-record owning token,
public record-specific decoder, or DTO-to-token constructor. SourceIndex and
ModuleInterface SHALL migrate from their Task 2B-1 transitional public decode
forms into this factory rather than being wrapped, copied, or charged twice.
Exact-fast-path eligibility SHALL consume only the common token's const
SourceIndex view and reject another RecordKind. The
published graph SHALL retain only reachable handles and graph-owned opaque
summaries, and SHALL expose compact ordinal-based RecordId/type/global/function/
initializer/opaque-owner tables rather than borrowed DTO views or validation
maps. Candidate output capacity SHALL be charged before allocation as monotonic
total-decoded bytes plus active resident scratch and SHALL be atomically
promoted to retained resident accounting at publication without double charge.
Late failure SHALL release candidate scratch and leave output empty; input-array
destruction SHALL not invalidate success, and unrelated handles SHALL not be
retained.

#### Scenario: Output token owns the input payload view

- **WHEN** the canonical-payload input view aliases bytes owned by the token currently held in the factory's output optional
- **THEN** the factory keeps a local reference-count-only lifetime guard before clearing the output
- **AND** it consumes the complete input without use-after-free
- **AND** the guard allocates, copies and charges no payload, DTO or control-block bytes
- **AND** normal atomic success or failure output rules still apply

#### Scenario: Record pool includes another module

- **WHEN** the caller validates one ModuleSnapshot from an in-memory pool that also contains valid unrelated records
- **THEN** Task 2B-2 follows and validates only that snapshot's child graph
- **AND** it leaves unrelated-record reachability decisions to Task 2B-3

#### Scenario: One required child fails

- **WHEN** any linked required child fails local, graph, codec, or current eligibility validation
- **THEN** the complete per-module output remains empty
- **AND** no partial type/state/function/debug graph is published

### Requirement: Module activation is atomic

The Runtime MUST assemble each active module from one validated ModuleInterface, its ordered TypeSchema records, one ModuleState, ordered FunctionBody records, each body's optional DebugSidecar, and dependency metadata. It MUST complete imports, globals, dependency checks, module swap, and ClassGenerator/reflection validation before publishing that ModuleSnapshot as active.

#### Scenario: One referenced record is invalid

- **WHEN** any required TypeSchema, ModuleState, FunctionBody, dependency, or stable reference fails validation
- **THEN** no partial form of that ModuleSnapshot mutates the active engine
- **AND** the planner compiles a safe miss closure or fails the transaction

#### Scenario: Snapshot link kind is wrong

- **WHEN** a keyed TypeSchema, ModuleState, FunctionBody, DebugSidecar, or ModuleSnapshot link resolves to another record kind
- **THEN** graph validation reports `WrongRecordKind` before attachment
- **AND** no partial declaration, type, global, function, or debug state mutates the engine

#### Scenario: Complete module restore succeeds

- **WHEN** every referenced record resolves against current declarations/environment and ClassGenerator validation succeeds
- **THEN** the complete module transaction becomes active atomically

### Requirement: Exact source snapshots bypass preprocess parse and compile

The cache service SHALL discover and content-hash directly observable source/action inputs for configured `Game`, `Plugin`, and `Memory` kinds, including stable mount/provider/hook/source-file coordinates; relocation-stable mount/root configuration fingerprints; source-provider stable identity/version/configuration; development/editor filters; loose, memory and generated raw bytes; validated typed relative logical paths; explicit define/preprocessor/compile options and hook fingerprints; source-to-module mapping; additions; and deletions. Host absolute paths MUST NOT be persisted.

Include/generated-source edges, effective conditional consumption and other results that require the authoritative preprocessor SHALL be captured after a successful preprocess as bounded, disposable candidate dependency state. Before the exact lookup decision, the loader SHALL validate a selected candidate's current raw/provider/option fingerprints without rerunning the preprocessor merely to reconstruct that candidate graph. A missing, corrupt, unhashable or mismatching candidate SHALL be a normal miss and trigger authoritative preprocessing. A provider or hook without a stable fingerprint MUST record only its affected scope as ineligible without disabling unrelated scopes. When direct inputs, the selected candidate, profile, environment dependencies and ModuleSnapshots match exactly, the service SHALL restore eligible modules without invoking the preprocessor, parser or function compiler.

#### Scenario: Second unchanged launch

- **WHEN** source bytes, source inventory, settings, compatible environment symbols, and cache schema are unchanged after a successful launch
- **THEN** eligible modules restore from matching ModuleSnapshots
- **AND** preprocess, parse, and function-compiler invocation counters are zero
- **AND** no replacement generation is written solely for that launch

#### Scenario: A new source file appears

- **WHEN** a loose `.as` file is added under a configured source root
- **THEN** the complete SourceIndex no longer matches
- **AND** the affected source/module closure enters preprocess and planning

#### Scenario: A persisted include candidate still matches

- **WHEN** direct source/action inputs select the current candidate and every persisted include/generated/preprocess dependency fingerprint still matches
- **THEN** the loader may select the exact ModuleSnapshot without rerunning the preprocessor to rediscover those edges
- **AND** candidate loss or mismatch causes authoritative preprocessing rather than stale activation

### Requirement: Changed modules retain unchanged function bodies

When a SourceIndex or module input changes, the Runtime SHALL preprocess/parse only the affected closure through the existing authoritative frontend and establish current ModuleInterface, TypeSchema, declaration and environment authority before function reuse. It SHALL then compare `FunctionSourceDigest`, resolve the matching artifact's persisted actual dependency set into `FunctionInputDigest` before each invocation's compiler decision, attach validated hits, and invoke the compiler only for misses. The builder hook MUST explicitly categorize ordinary functions, methods, constructors, destructors, factories, generated default constructors, `__InitDefaults`, public single-function compilation, and generated lambdas. Invocations without stable persistent module coordinates MUST return `NotCacheable`, compile normally, and MUST NOT be captured.

The Runtime SHALL support a forced-clean mode that bypasses function lookup and compiles normally while emitting the same canonical artifact model. It is the fallback for unavailable/unsupported cache state and the equivalence oracle for cached mode; it MUST NOT create another identity, serializer, module graph or source-classification path.

#### Scenario: One body changes without structural change

- **WHEN** one function body changes and all other declarations, type schemas, module state, options, and actual dependencies remain equal
- **THEN** exactly that FunctionBody is a compile miss
- **AND** the other FunctionBodies remain hits at their existing content coordinates

#### Scenario: Formatting changes only

- **WHEN** comments or whitespace change source/debug mapping without changing execution inputs
- **THEN** the affected module may be reparsed and DebugSidecar updated
- **AND** execution FunctionBodies remain eligible hits

#### Scenario: Cached mode is compared with a clean compile

- **WHEN** one fixture is compiled once with function lookup forced off and once with eligible FunctionBody restores
- **THEN** their canonical ModuleInterface, TypeSchema, ModuleState, function content and observable VM behavior match
- **AND** any unsupported or unequal cached artifact safely takes the normal compiler path rather than weakening validation

### Requirement: Type schemas invalidate structural dependency closure

Class, struct, interface, enum, delegate, inheritance, property, method declaration, trait, metadata, reflection, and layout information SHALL be persisted in TypeSchema records. A TypeSchema change MUST invalidate the owning ModuleSnapshot and every dependent module/entity selected by existing structural dependency semantics.

#### Scenario: Property is added to a script class

- **WHEN** a script class gains a reflected or runtime property
- **THEN** its TypeSchema and owning module assembly change
- **AND** structural dependents enter the required invalidation closure
- **AND** unrelated modules remain eligible hits

#### Scenario: Method body changes but class shape does not

- **WHEN** a method implementation changes without changing its declaration or class layout
- **THEN** the TypeSchema remains reusable
- **AND** invalidation is limited to the affected FunctionBody and actual dependencies

### Requirement: Globals and initializer order are one module-state cache unit

The Runtime SHALL persist globals, constants, enum values, global storage
layout, canonical initializer bytecode units, one interleaved dependency-solved
default-construction/initializer action order with action-owned dependencies,
post-init functions, and hard-value dependency metadata as one ModuleState
record per module. V1 MUST NOT independently activate a subset of global
initializer artifacts.

#### Scenario: Global initializer changes

- **WHEN** one global value or initializer changes
- **THEN** the owning ModuleState is a miss
- **AND** the module's complete global dependency-solving pass is rebuilt
- **AND** hard-value dependent modules enter the required closure

#### Scenario: Function body changes without global dependency change

- **WHEN** an ordinary function body changes and ModuleState inputs remain equal
- **THEN** ModuleState remains a cache hit

### Requirement: Invalidation uses typed semantic dependencies

The planner MUST distinguish source/include/preprocessor, declaration/signature, type/property layout, global/hard-value, import, compile option, debug mapping, and environment-symbol ABI dependencies. These classifications SHALL be derived from the authoritative SourceIndex candidate, frontend semantic records and compiler-captured actual dependencies, not a parallel text-diff/preprocessor heuristic. It SHALL produce deterministic hit/miss reasons and the minimum complete closure that preserves correctness; inability to prove a narrower closure is a conservative miss.

#### Scenario: Function signature changes

- **WHEN** a function's signature, owner, qualifiers, or traits change
- **THEN** its logical key and ModuleInterface change
- **AND** callers/importers referring to the old declaration enter the miss closure

#### Scenario: Unrelated binding changes

- **WHEN** a bound symbol not named by any record in a module changes
- **THEN** that module remains eligible for cache hits

#### Scenario: Include changes

- **WHEN** a shared include or preprocessor input changes
- **THEN** SourceIndex identifies the affected source/module closure
- **AND** entity-level comparison is applied after preprocessing rather than blindly invalidating every module

### Requirement: Cache V2 is a Saved-only immutable generation store

The default cache base SHALL be exactly
`<ProjectSavedDir>/Angelscript/CacheV2`. An explicit `-as-cache-root` SHALL
replace that complete base rather than add another CacheV2 suffix. The service
SHALL append canonical lower-case full-256-bit CompatibilityKey/ContextKey
components and SHALL keep every known final/temp path within the canonical
root. Each namespace MUST contain immutable content-addressed packs, immutable
generation manifests, and atomic Current/Previous/PendingColdStart pointers;
it MUST NOT require a packaged Cache V2 baseline. Pointer schema SHALL be a
CompatibilityKey input.

#### Scenario: First launch has no cache namespace

- **WHEN** a valid loose source tree starts without a matching Cache V2 namespace
- **THEN** source compiles normally
- **AND** a successful transaction publishes the first Saved generation
- **AND** the process continues rather than exiting for cache generation

#### Scenario: Compatibility or context differs

- **WHEN** compiler/bytecode ABI, platform, target, configuration, preprocessor settings, or source mounts select another compatibility/context key
- **THEN** the service uses a distinct namespace
- **AND** it neither consumes nor deletes incompatible namespaces

#### Scenario: A pointer slot is decoded

- **WHEN** Current, Previous, or PendingColdStart is present
- **THEN** it is exactly an 80-byte `UEASCV2C` schema-1 file whose embedded kind matches its filename and whose nonzero GenerationId is protected by the frozen checksum
- **AND** a missing slot is valid absence while malformed pointer bytes are a store/pointer failure rather than an archive error

### Requirement: Generation publication is atomic and recoverable

The writer MUST publish new immutable pack data and a validated generation manifest before atomically replacing Current. Every temp SHALL use the frozen same-directory writer-token name and SHALL be fully written, flushed, closed, reopened and validated. Immutable finals SHALL use no-replace rename, directory sync and final reopen validation. Pointer replacement/removal MUST use a supported platform old-or-new atomic seam; a generic delete-then-move MUST NOT satisfy V1. It MUST retain a valid Previous generation and readers MUST pin one manifest handle and every distinct referenced pack handle for an entire immutable read session.

#### Scenario: Process stops during pack or manifest write

- **WHEN** cancellation, crash, or shutdown occurs before Current is replaced
- **THEN** the previous Current remains selected on the next launch
- **AND** incomplete temporary files are never accepted as records

#### Scenario: Two processes publish concurrently

- **WHEN** two engines target the same store
- **THEN** writers serialize through a store-path system-wide lock
- **AND** the later writer rereads/rebases Current before publication
- **AND** readers never observe a half-published generation

#### Scenario: Cancellation arrives after Current replacement

- **WHEN** the platform has successfully atomically replaced Current and cancellation or directory synchronization failure is observed afterward
- **THEN** the outcome records CurrentCommitted and does not roll back the pointer
- **AND** immutable packs or manifests are not deleted as cancellation rollback

#### Scenario: A pinned reader overlaps publication or compaction

- **WHEN** a reader has pinned the selected manifest and every referenced pack before the namespace lock is released
- **THEN** later pointer movement cannot change the bytes used by that session
- **AND** compaction either unlinks with handle-safe semantics or defers deletion without substituting path-opened data

### Requirement: Cache preparation is bounded parallel and deterministic

The service SHALL use bounded worker tasks for source scanning/hashing, manifest/pack I/O and validation, decompression, pure hit planning, digest preparation, compression, and pack construction. Current-engine declaration creation, reference attachment, globals, module swap, ClassGenerator, and active generation selection MUST remain serialized on the owning lifecycle.

#### Scenario: Serial and parallel output are compared

- **WHEN** identical generation input is prepared in forced-serial and normal bounded-parallel modes
- **THEN** record ordering, hashes, manifest bytes, pack indexes, pack bytes, and generation ID are identical

#### Scenario: Worker completion order changes

- **WHEN** workers complete in different or randomized orders
- **THEN** output order still derives from canonical full keys
- **AND** no worker mutates the active engine

#### Scenario: Multiple engines read one store

- **WHEN** two engines open immutable cache data concurrently
- **THEN** they may share file bytes
- **AND** their FunctionId routing, module state, cancellation, diagnostics, and reload state remain engine-owned and isolated

### Requirement: AngelScript engine mutation is serialized per engine

Each `FAngelscriptEngine` MUST own an explicit mutation transaction gate distinct from the diagnostic compilation lock. The gate SHALL cover startup restore/attachment, builder hook lifetime, declaration/layout/global mutation, module swap/ClassGenerator handoff, stable route rebuild, runtime reload, Current/Pending selection, StaticJIT route refresh, and shutdown/cancellation. It MUST support the initialization owner thread and later game-thread safe-point ownership with defined reentrancy and lock order. Workers SHALL consume immutable DTOs and MUST NOT call AngelScript engine APIs or reread mutable descriptors.

#### Scenario: Reload races shutdown

- **WHEN** runtime reload or provider refresh is queued while shutdown begins
- **THEN** one engine mutation owner deterministically completes or cancels the operation before engine destruction
- **AND** no worker dereferences released engine/module/function state

#### Scenario: Two engines mutate concurrently

- **WHEN** two independent engines compile or reload at the same time
- **THEN** each engine serializes its own mutations
- **AND** neither engine's gate blocks the other except while publishing to the same store writer lock

### Requirement: Loose source is authoritative over stale cache

A cache generation SHALL be eligible only when its SourceIndex exactly matches the discovered source snapshot or after the changed source has successfully compiled into a new transaction. If changed current source fails fresh-start compilation, the system MUST NOT activate a different-source previous generation as fallback.

#### Scenario: Fresh packaged startup has invalid changed source

- **WHEN** loose source differs from Current and fails parsing, compilation, or ClassGenerator validation
- **THEN** no new generation is published
- **AND** stale cached script behavior is not activated
- **AND** packaged initialization exits with a failure result

#### Scenario: Editor fresh startup has invalid changed source

- **WHEN** Editor source differs from Current and initial script compilation fails
- **THEN** Editor exposes an explicit AngelScript initialization failure state
- **AND** it does not activate the stale different-source scripts

#### Scenario: Hot reload fails after a valid module is active

- **WHEN** an Editor or enabled runtime reload attempt fails
- **THEN** the currently active last-good module remains active
- **AND** Current is not advanced to the failed source generation

### Requirement: Editor and PIE continuously maintain Cache V2

Every successful Editor initial compile, soft reload, or full structural reload SHALL freeze pointer-free immutable artifacts inside the mutation gate after final compile result, active module swap, ClassGenerator/reflection and reinstancing succeed but before temporary compiled objects are released. The service MUST publish Current only from that DTO. A `PartiallyHandled` PIE result MUST keep active-Current and cold-start-candidate DTOs semantically separate; diagnostic `CompileEnd` callbacks MUST NOT recapture mutable VM objects.

#### Scenario: Editor body hot reload succeeds

- **WHEN** a code-only script edit successfully soft reloads
- **THEN** the new FunctionBody and updated ModuleSnapshot are prepared asynchronously
- **AND** a valid generation becomes Current without waiting for Editor shutdown

#### Scenario: Structural reload succeeds outside PIE

- **WHEN** a class/property/signature change completes full reload and reinstancing outside PIE
- **THEN** Current advances only after ClassGenerator and reflected type replacement succeed

#### Scenario: Structural source is compiled during PIE

- **WHEN** a structural edit is valid for a fresh engine but cannot safely replace active PIE instances
- **THEN** active Current remains aligned with the live PIE modules
- **AND** the compiled artifacts may be published only as PendingColdStart
- **AND** PendingColdStart is promoted only by a later successful cold/full transaction

### Requirement: Shutdown performs a bounded flush without late compilation

`FAngelscriptEngine::Shutdown()` MUST ask its Cache service to flush completed/prepared work before releasing AngelScript engine data. It SHALL wait no longer than the configured timeout and MUST NOT discover, preprocess, or compile unprocessed source during shutdown.

#### Scenario: Pending write completes before timeout

- **WHEN** Editor or game shutdown begins with a prepared valid generation
- **THEN** the generation is committed before engine data is released

#### Scenario: Flush exceeds timeout

- **WHEN** cache preparation/write does not finish within the default 5-second shutdown timeout
- **THEN** known work and temporary files are cancelled/cleaned
- **AND** the previous committed generation remains valid
- **AND** shutdown continues without compiling source

### Requirement: Packaged runtime reload is configurable and code-only

The plugin SHALL provide `Disabled`, `Manual`, and `Automatic` runtime reload modes, with `Disabled` as the default. Manual and automatic requests MUST run through one game-thread safe-point pipeline. A packaged live reload SHALL activate only code-only soft changes and SHALL return `RequiresRestart` for structural changes.

#### Scenario: Runtime reload is disabled

- **WHEN** Blueprint, C++, or console requests a reload under the default Disabled mode
- **THEN** the request returns `Disabled`
- **AND** no source scan or active module change occurs

#### Scenario: Code-only runtime reload succeeds

- **WHEN** Manual or Automatic mode discovers a valid body-only change
- **THEN** the change is applied through the existing soft-reload transaction
- **AND** the result is `AppliedCodeOnly`
- **AND** successful cache records are published

#### Scenario: Runtime structural change is discovered

- **WHEN** a signature, property, inheritance, class/global layout, interface, delegate, enum, or structural dependency changes while a packaged process is live
- **THEN** the result is `RequiresRestart`
- **AND** old modules remain active
- **AND** the attempted structural generation is not published as Current

#### Scenario: Automatic mode is enabled in a packaged target

- **WHEN** Automatic mode is configured
- **THEN** Runtime periodically content-hashes loose source using the configured interval
- **AND** it does not depend on the Editor DirectoryWatcher module

### Requirement: Runtime reload and cache controls are exposed through stable APIs

The Runtime SHALL expose reload mode, request status, reload outcome, and result types to C++ and Blueprint; `UAngelscriptSubsystem` SHALL expose `RequestRuntimeReload()` and a completion delegate. It SHALL also expose `as.ReloadScripts`, `as.Cache.Status`, `as.Cache.Flush`, `as.Cache.Verify`, `as.Cache.Compact`, `as.Cache.ForceClean`, `as.Cache.Explain`, and `as.Cache.Trace` console commands.

#### Scenario: Blueprint queues a manual reload

- **WHEN** Blueprint calls `RequestRuntimeReload()` while Manual mode is idle
- **THEN** it receives `Queued`
- **AND** the completion delegate later reports `NoChanges`, `AppliedCodeOnly`, `RequiresRestart`, `CompileFailed`, or `Cancelled` with module and cache diagnostics

#### Scenario: Flush command is used by package smoke

- **WHEN** `as.Cache.Flush` is executed after startup compilation
- **THEN** it waits for valid prepared cache work to commit or reports a typed failure
- **AND** shutdown can follow without losing an already completed generation

### Requirement: Cache settings have safe deterministic defaults

`UAngelscriptCacheSettings` MUST be an Engine default-config object with incremental cache enabled, runtime reload Disabled, automatic scan interval 1.0 second, and shutdown flush timeout 5.0 seconds unless explicitly configured otherwise.

#### Scenario: Project provides no cache settings

- **WHEN** Editor, Development, or Shipping starts without project overrides
- **THEN** Cache V2 reads/writes are enabled
- **AND** packaged runtime live reload remains disabled
- **AND** shutdown uses the 5-second bounded flush

### Requirement: Cache data is validated before allocation and engine mutation

The loader MUST validate magic, schema, profile/context, integer arithmetic, counts, offsets, stored/raw lengths, codecs, checksums, canonical order, duplicate/conflicting keys, dependency kinds/targets, logical root containment, and configured memory budgets before resolving records into active engine objects. It SHALL enforce `MaxGenerationPacks` before pack access, validate whole-file PackId/GenerationId and exact manifest-to-pack index locations, and canonical-recompress V1 Zlib. It MUST NOT deserialize native pointers, UObjects, function addresses, vtables, FName indices, or numeric FunctionIds.

#### Scenario: Pack range is out of bounds

- **WHEN** a manifest references bytes outside a pack or arithmetic overflows
- **THEN** that generation is rejected before allocating the declared payload or resolving stable references

#### Scenario: Current generation is corrupt

- **WHEN** Current or one of its required packs fails validation
- **THEN** the loader may use a source-snapshot-matching valid Previous or PendingColdStart generation
- **AND** otherwise compiles matching current source
- **AND** it never treats corruption as permission to execute different-source stale behavior

### Requirement: Legacy PrecompiledScript cache has no production path

After Cache V2 becomes active, the plugin MUST NOT read, migrate, dual-write, or silently fall back to `PrecompiledScript.Cache`, random `DataGuid` pairing, old pointer maps, or persisted numeric FunctionIds. `Binds.Cache` SHALL remain independently supported.

#### Scenario: Only a legacy script cache exists

- **WHEN** source is present, Cache V2 is missing, and `PrecompiledScript.Cache` exists
- **THEN** the legacy file is ignored/rejected with a precise diagnostic
- **AND** current source compiles and writes Cache V2

#### Scenario: Legacy file is found in a package

- **WHEN** packaged validation inspects staged files
- **THEN** it fails the package/smoke check as an obsolete script artifact
- **AND** `Binds.Cache` remains accepted

### Requirement: Diagnostics prove incremental behavior with stable identifiers

The service SHALL provide a deterministic diagnostic snapshot and optional JSON report containing compatibility/context/profile, source snapshot, generation before/after, record/module/type/state/function hit and miss counts, typed reasons, preprocess/parse/compiler calls, bytes read/written, validation/fallback/publication result, reload outcome, and stage timings. Persistent ordering and identifiers MUST use full stable keys.

Editor and Development builds SHALL additionally provide a pointer-free C++
diagnostic DTO/API authority with a bounded opt-in decision trace and deterministic
explain queries by transaction, module, function or record. Explain MUST report the
direct typed reason, expected/current coordinates and ordered dependency/recompile
closure from captured immutable diagnostics; it MUST NOT reparse, compile or mutate
the store. The C++ authority SHALL expose read-only shallow/deep persisted
verification plus explicit transactional Flush, Compact and ForceClean requests.
Console/Blueprint entry points delegate to this authority. Diagnostic events MUST
be bounded, schema-versioned and free of persistent pointers/numeric FunctionIds;
Shipping MUST default to disabled or aggregate-only tracing unless explicitly
enabled.

The stable status schema SHALL expose each published module's canonical name,
ModuleSnapshot RecordId and bounded declaration/type/state/function semantic
catalog, including exact TypeSchema/FunctionBody RecordIds and semantic
dependencies. An Engine-aware capture SHALL attach the current pointer-free
function route catalog using full ModuleKey/FunctionKey plus execution, debug and
profile identities and selected VM/Native route. It MUST exclude live function
pointers and numeric FunctionIds. A rejected decision MAY attach the existing
typed validation result and a bounded human detail, but diagnostics MUST NOT
weaken validation or become restore/routing authority.

The status schema SHALL also expose a pointer-free aggregate for the latest
production hybrid compiler-reuse transaction. It MUST identify the selected
candidate GenerationId and report candidate-module, restored-function,
compiled-miss, not-cacheable and rejected-corrupt counts independently of the
bounded decision journal. A Clean Capture skip event MUST retain its existing
bounded typed failure detail so a package report can distinguish unsupported
work from an unexplained fallback compile.

The Engine-native C++ boundary is limited to capturing live state, executing
transactional controls and emitting the stable DTO/JSON contract. The language of
developer-facing report, search, diff and visualization tools is not fixed. Such
tools MAY be implemented in C++ or Python, MUST consume the same stable schema, and
MUST NOT duplicate or override cache-selection and validation authority.
The repository's Python semantic generation diff SHALL be sufficient for this
capability; an equivalent C++ diff implementation or `as.Cache.Diff` command is not
required.

The repository SHALL also provide a read-only standalone Python Cache V2 dump
tool after the production Manifest/Pack format is available. It MUST inspect an
explicit cache root, Manifest, or Pack without launching Unreal or changing store
roots; MUST support deterministic text/JSON and generation/module/record-kind/
stable-key filters; and MUST expose headers, indexes, stable identities, hashes,
sizes, links, and decoded common semantic-record summaries. Generic inspection
MUST report opaque VM/initializer/debug payloads only as kind/codec/hash/size
metadata unless a matching explicit decoder is selected. Invalid or corrupt input
MUST return a structured error and nonzero exit without writing cache data.
The Python tool SHALL also provide semantic generation diff, ordered dependency-
tree explanation and optional correlation with an explicit C++ session report.
For a status schema that supplies module/function record identities, correlation
MUST compare exact ModuleSnapshot/TypeSchema/FunctionBody RecordIds and MUST join
current function routes to persisted FunctionBody records by full FunctionKey,
reporting ModuleKey/ExecutionHash/DebugHash/Profile mismatches by name. Supported
ModuleInterface and TypeSchema payload schemas MUST be consumed completely;
truncated prefixes or trailing bytes MUST NOT be labelled successfully decoded.

#### Scenario: Developer inspects a warm generation offline

- **WHEN** the developer runs the Python dump tool on a valid Cache V2 root and filters one module
- **THEN** deterministic text or JSON lists the selected generation, packs, module root, source/type/state/function records, full stable keys, hashes, sizes, and links
- **AND** Unreal Editor is not launched and no store file is modified

#### Scenario: Dump encounters a corrupt pack range

- **WHEN** a selected Manifest location points outside its Pack
- **THEN** the tool emits a structured range/integrity diagnostic and exits nonzero
- **AND** it does not present a partial record as valid or mutate the cache

#### Scenario: Live Native or VM route differs from the persisted function

- **WHEN** a schema-3 session report is correlated with one selected generation
- **AND** a live route has a different execution, debug, profile or module coordinate
- **THEN** the report identifies the FunctionKey, selected VM/Native route and exact mismatching field
- **AND** it prints the live and persisted values without using a numeric FunctionId

#### Scenario: Packaged warm launch uses hybrid compiler reuse

- **WHEN** exact whole-Generation startup safely misses and normal startup compilation carries one selected Generation into the compiler
- **THEN** schema-4 status identifies that full stable GenerationId
- **AND** it reports at least one restored function plus typed compiled or unsupported work
- **AND** a plain fallback compile with zero restored functions cannot satisfy the warm-cache acceptance oracle

#### Scenario: One body edit is reported

- **WHEN** a fixture changes exactly one function body
- **THEN** the report shows one FunctionBody compile miss
- **AND** unchanged TypeSchema and ModuleState records remain hits
- **AND** no process address is used as a persistent identifier

#### Scenario: Developer explains one live function miss through C++

- **WHEN** a function misses because one environment ABI or dependency content
  coordinate differs
- **THEN** the C++ explain result identifies the transaction, full stable function
  key, direct typed dependency and expected/current digests
- **AND** it lists the deterministic affected closure without reparsing, compiling
  or changing Current/Previous/Pending

#### Scenario: C++ decision tracing reaches its bound

- **WHEN** verbose tracing records more events than its configured capacity
- **THEN** old events are evicted through the documented bounded policy
- **AND** the remaining deterministic DTO contains no AS/UE object pointer or
  persistent numeric FunctionId

#### Scenario: Force-clean diagnostic comparison is requested

- **WHEN** a developer force-compiles one selected module for comparison
- **THEN** the service uses the authoritative transactional clean compiler path
- **AND** compile failure preserves the last-good active graph and reports the
  comparison outcome without directly editing Manifest or Pack bytes

#### Scenario: Exact warm launch is reported

- **WHEN** an unchanged source snapshot restores successfully
- **THEN** the report shows zero preprocess, parse, and compiler calls
- **AND** the generation remains unchanged

### Requirement: Unreachable content is reclaimed outside startup

Normal startup and incremental publication MUST NOT rewrite valid packs solely to remove unreachable records. Physical retention SHALL treat every currently present valid Current, Previous, or PendingColdStart pointer as a root even when a slot is not selection-eligible. Explicit compaction SHALL require authoritative source/profile revalidation and run two crash-safe phases: rewrite/finalize the rooted reachable union and atomically switch rewritten slot pointers without deleting old immutable files; then reacquire the namespace lock, remark current physical roots, and sweep only unmarked strict-name final objects. A pinned-reader deletion failure SHALL be deferred rather than invalidating the committed pointer state.

#### Scenario: Function is renamed or deleted

- **WHEN** a generation no longer references an old FunctionBody
- **THEN** the immutable old pack remains available while retained manifests reference it
- **AND** explicit compaction can later remove it after reachability validation

#### Scenario: Startup sees unreachable packs

- **WHEN** the store contains packs not reachable from retained manifests
- **THEN** startup does not block on compaction

#### Scenario: Publication occurs between compaction phases

- **WHEN** another valid publication changes physical roots after compaction switches its planned pointers but before sweep
- **THEN** Phase B reacquires the namespace lock and recomputes all currently present pointer roots
- **AND** it does not delete any manifest or pack newly rooted by that publication
