# Cache V2 ModuleState V1 Exhaustive Matrix

Status: normative Task 2B-2 OpenSpec authority, incorporated by reference from
`record-wire-v1-remaining.md`. This matrix is promoted for independent review;
promotion alone does not authorize RED or complete a task. Task 2B-2 RED begins
only after this matrix and `type-schema-matrix-v1.md` receive an explicit
independent approval recorded in `verification.md`.

Scope: only the Cache V2 `ModuleState` record, its local validation, and the
ModuleState-specific part of `ValidateModuleSnapshotGraph`. TypeSchema,
FunctionBody, DebugSidecar, ModuleSnapshot, live capture/attach, disk storage,
legacy migration, StaticJIT, PIE, packaging, and Shipping startup remain outside
this matrix except where ModuleState needs an explicit cross-record contract.

## 1. Outcome

The V1 model is an atomic, profile-keyed module state input record:

1. `OrderedGlobals` is the complete storage schema for every local
   `GlobalVariable` declaration, in one explicit storage sequence. Storage
   order is not execution order.
2. Each global has exactly one of `Default`, `PureConstant`, or `VmInitializer`.
3. `PureConstant` stores one exact-width scalar `GlobalConstant` hard value;
   `VmInitializer` stores one ModuleState-owned opaque initializer unit;
   `Default` stores neither.
4. Enum declarations remain authoritative in TypeSchema. ModuleState stores one
   derived `EnumAuthority` hash per local enum, without duplicating enumerators.
5. Global/module initializer bytes are embedded in ModuleState and identified by
   stable function keys. They never receive FunctionBody records or persisted
   numeric FunctionIds. Initializer units are a canonical payload set, not an
   execution sequence.
6. `OrderedInitializationActions` is the single dependency-solved execution
   sequence. It interleaves type-driven `DefaultConstructGlobal` actions with
   `ExecuteInitializer` actions for global and module initializer units, exactly
   preserving the compiler/runtime order that may place a primitive VM
   initializer before a complex default constructor.
7. All storage is zeroed/allocated and pure-constant bits are installed before
   the action sequence. A transient cleanup stack, derived in action-attempt
   order, gives failure and release the same exact reverse behavior. No
   initialized bit or cleanup stack is persisted.
8. The only common-code opaque field is each initializer's execution payload.
   Local decode recomputes its outer hash but never invokes a VM codec. Graph
   step 1 invokes the injected validator exactly once for each reachable unit.

This preserves module-atomic class/global state while still allowing function
bodies to invalidate independently. It also replaces the current coarse legacy
archive's ambiguous booleans, host-width constant bucket, name-only post-init
lookup, and process-local function identity.

## 2. Evidence, decisions, and closed questions

The labels used below have exact meanings:

- **Evidence**: already fixed by authoritative OpenSpec or observed in current
  source. Source behavior is evidence, not a requirement to retain legacy wire.
- **Design choice**: the one normative V1 rule selected where the earlier
  summary prose did not supply an exhaustive row/comparator/priority.
- **Closed question**: an earlier normative gap whose one executable resolution
  is frozen by this matrix; it is not a menu of alternatives.

### 2.1 Authoritative OpenSpec evidence

- **Evidence** — `record-schema.md:369-395` assigns globals, constants,
  initializer programs/order, post-init, dependencies, and cleanup to one
  ModuleState. It forbids mutable runtime values, UObject pointers, an opaque
  lifetime field, and a persisted initialized bit.
- **Evidence** — `record-wire-v1-remaining.md:295-330` fixes the initialization,
  cleanup, hard-value, initializer, and scalar enum numbers and replaces the old
  three booleans with one initialization tag.
- **Evidence** — `record-wire-v1-remaining.md:401-434` fixes the four hash domains
  and the inputs that StateInputHash must cover.
- **Evidence** — `record-wire-v1-remaining.md:658-712` fixes the complete wire
  field order. No lifetime blob, initialized bit, direct RecordId, numeric ID,
  raw address, or source string may be added to ModuleState V1.
- **Evidence** — `record-wire-v1-remaining.md:717-739` fixes exact scalar widths,
  enum int32 encoding, preservation of floating bit patterns, and hard-value
  owner/value presence.
- **Evidence** — `record-wire-v1-remaining.md:741-786` fixes semantic sequences,
  exact initialization coverage, zero-or-one module initializer, same-module
  initializer/post-init declarations, one enum authority per local enum,
  lifecycle ordering, and profile handling.
- **Evidence** — `record-wire-v1-remaining.md:917-1034` fixes the opaque request,
  deterministic fixture seam, relocation subset rule, and owned canonical bytes.
- **Evidence** — `record-wire-v1-remaining.md:1119-1187` fixes the eleven graph
  stages. Reachable opaque validation precedes ModuleState ownership/coverage;
  enum authority follows global coverage; current eligibility is last.
- **Evidence** — `record-wire-v1-remaining.md:1207-1266` fixes errors `44..64`,
  their classes, and global error precedence.

### 2.2 Current implementation evidence, not wire authority

- **Evidence** — legacy `FAngelscriptPrecompiledGlobalVariable` persists
  `bIsPureConstant`, `bIsDefaultInit`, `bHasInitFunction`, and a single `uint64`
  constant bucket (`StaticJIT/PrecompiledData.h:364-397`). Its branch encoding
  does not itself prove all three booleans are mutually consistent.
- **Evidence** — legacy capture reads `asCGlobalProperty::storage` into `uint64`
  and embeds a complete precompiled init function
  (`StaticJIT/PrecompiledData.cpp:1327-1357`). Restore recreates a process-local
  function id and attaches the function directly to the property
  (`PrecompiledData.cpp:1360-1402`).
- **Evidence** — legacy module capture iterates a symbol map for globals and
  stores post-init names as strings (`PrecompiledData.cpp:1431-1488`); restore
  allocates every global before functions are finalized
  (`PrecompiledData.cpp:1590-1651`). These are useful lifecycle clues but are not
  canonical-order or stable-reference contracts.
- **Evidence** — unnamed global initializer functions currently receive random
  ids, while named functions derive collision-adjusted 32-bit ids from current
  module/type/declaration data (`PrecompiledData.cpp:2765-2802`). Cache V2 must
  not preserve either route.
- **Evidence** — the compiler marks only read-only primitive compile-time values
  as pure constants and stores their evaluated bits in `asQWORD`
  (`ThirdParty/angelscript/source/as_compiler.cpp:1962-2035`). A non-primitive
  value without an initializer is marked for default construction.
- **Evidence** — global compilation is retried to establish dependency order,
  processes primitives before complex values, and swaps `scriptGlobalsList`
  into the resulting init order (`as_builder.cpp:2614-2800`). A generated init
  function is retained only when its bytecode is more than the trivial
  suspend/return pair (`as_builder.cpp:2725-2753`).
- **Evidence** — the VM clears every nonconstant global before any initializer,
  then walks the global list and either default-constructs or executes the
  property init function (`as_module.cpp:361-448`). Even a failed initializer
  sets the transient module initialized flag so partial state is released
  (`as_module.cpp:456-465`).
- **Evidence** — current cleanup releases ref objects, destructs/frees owned
  objects, and releases funcdefs (`as_module.cpp:469-513`), but `CallExit()`
  currently visits globals forward (`as_module.cpp:516-527`). Cache V2's
  authoritative reverse cleanup rule is therefore an intentional behavior
  correction, not a serialization of the current loop.
- **Evidence** — current post-init stores names, scans global functions by short
  name, prefers a property getter, and silently continues when missing
  (`ClassGenerator/AngelscriptClassGenerator_Finalize.cpp:802-841`). Cache V2
  instead requires a stable ScriptFunction reference and exact ABI.
- **Evidence** — the already implemented common DTO has exact primitive tokens,
  type qualifiers, stable-reference ABI rules, and the semantic dependency
  comparator (`Cache/AngelscriptCacheSemanticRecords.h:5-183` and
  `.cpp:560-750,1119-1183`). ModuleState must reuse these definitions without
  renumbering or reinterpretation.
- **Evidence** — ModuleInterface already treats `GlobalInitializer` as a
  Function owned by a Global and `ModuleInitializer` as a Function owned by the
  Module; both have forbidden FunctionBody coverage
  (`AngelscriptCacheSemanticRecords.cpp:3270-3303,3720-3811`).

### 2.3 Normative gaps closed by this matrix

| ID | Closed question | Normative executable resolution |
|---|---|---|
| OQ-MS-01 | HardValue is called a canonical set but its exact authority/comparator is omitted. | Authority is `{numeric HardValueKind, numeric Owner.ReferenceKind, Owner.StableKey}`. Sort by exactly that tuple. ExpectedAbi, Type, value presence/bytes, and stored hash are content: equal authority/equal content is `DuplicateKey`; equal authority/different content is `ConflictingKey`. |
| OQ-MS-02 | Script type spelling alone does not select cleanup ownership. | Graph validation resolves the TypeSchema: Class/Interface/Funcdef use `ReleaseHandle`; Struct/Delegate use `DestroyValue`; Enum and primitive-only Typedef use `None`. An explicit handle is legal only for a resolved reference semantic type and still uses `ReleaseHandle`. Reference-qualified globals remain NotCacheable. |
| OQ-MS-03 | An opaque environment ABI hash does not expose cleanup ownership. | The current-symbol result carries an explicit `ValueStorageKind={Trivial,OwningValue,ReferenceCounted}` when resolving an EnvironmentType. Global cleanup must map exactly to `{None,DestroyValue,ReleaseHandle}`. Missing or unequal storage category is fail-closed before attach; graph code never infers it from hash equality. |
| OQ-MS-04 | Storage order and the initializer-unit table cannot express the compiler's interleaved dependency-solved execution order. | Add one `OrderedInitializationActions` sequence. Each action is either `DefaultConstructGlobal` targeting ScriptGlobal or `ExecuteInitializer` targeting ScriptFunction. Action dependencies own the ordering edges; a local `Initializer` edge must target an earlier action and carry its exact action content coordinate. |
| OQ-MS-05 | Exact initializer declaration/byte/action coverage is implied but not stated as set equality. | InitializerUnit keys, ExecuteInitializer action target keys, and ModuleInterface initializer declaration keys are exact-equal sets. Every VmInitializer global contributes exactly one GlobalInitializer declaration/unit/action; every other global contributes none; a ModuleInitializer declaration exists iff its single unit/action exists. No unused unit, action, or declaration is allowed. |
| OQ-MS-06 | Post-init is an ordered sequence but duplicate target behavior is omitted. | A ScriptFunction StableKey may occur at most once. Equal key/equal ExpectedAbi is `DuplicateKey`; equal key/different ExpectedAbi is `ConflictingKey`. Ordinal remains semantic and is not a sorting key. |
| OQ-MS-07 | Reverse “storage/initialization order” is not one concrete runtime algorithm. | Restore maintains a transient cleanup stack. Immediately before a global-owning initialization action begins, push its non-`None` global once. Pop in exact reverse action-attempt order on failure or release. Pure constants and `None` globals never enter the stack. The stack is not persisted. |
| OQ-MS-08 | Empty opaque payload and codec version zero are not assigned a local semantic error. | Both are structurally decodable. Local hashing covers their exact values. Only the injected codec decides support/format in graph step 1, yielding `UnsupportedCodecVersion` or `OpaquePayloadMalformed`; local decode never hardcodes VM versions or fixture magic. |
| OQ-MS-09 | Initializer summaries expose debug-source rows although ModuleState has no debug-source authority. | `InitializerExecution` must return `ExactDebugSources=[]`. A nonempty result is `OpaquePayloadMalformed`. Relocations and CanonicalName/StringLiteral owned bytes remain permitted and are validated normally. |
| OQ-MS-10 | Local validation order among physical decode, trailing bytes, ordinals, authorities, hashes, and RecordId is unstated. | Complete physical decode first, including raw enum/tag/UTF-8/count checks; then require end-of-payload; then run local semantic checks in wire-field order, canonical authority checks, per-row derived hashes, and StateInputHash; finally the token factory recomputes RecordId. This order is unconditional. |
| OQ-MS-11 | The remaining wire names initializer declaration kinds but omits their exact callable shape/traits. | Both initializer declarations are compiler-generated zero-parameter `void()` Functions with exactly the common `Generated` trait, zero reflection/identity flags, no metadata/slots, and BodyCoverage Forbidden. GlobalInitializer is Global-owned; ModuleInitializer is Module-owned. No name heuristic supplies any fact. |
| OQ-MS-12 | “same-module declared ScriptFunction” does not say whether a post-init target may be non-executable, a method/initializer, or take parameters. | A post-init target is a module-owned, non-abstract GlobalFunction with zero parameters and BodyCoverage Required. Its return may be non-void and is discarded. Methods, initializers, delegates, imports, properties, parameterized functions, abstract declarations, and BodyCoverage Forbidden are rejected. |

OQ-MS-01..12 are closed by the exact rows below. Their historical identifiers
remain stable for traceability. Task 2B-2 RED remains blocked only on the fresh
independent approval required by `record-wire-v1-remaining.md`.

### 2.4 Requested-point provenance/closure map

| Requested point | Evidence used | Design choice / open-question closure |
|---|---|---|
| global declaration + init kind | authoritative exact coverage; current compiler pure/default/nontrivial-init behavior | section 4 classifier; OQ-MS-05 exact declaration/unit set equality |
| CanonicalValue primitive widths/bits | authoritative scalar table; existing canonical primitive enum | section 5 exhaustive token mapping; no open width choice remains |
| cleanup ownership | authoritative policy prose; current VM release/destruct routes | section 6 classifier; OQ-MS-02/03 enum and environment authority; OQ-MS-07 reverse transient stack |
| HardValue comparator/authority | authoritative hard-value shapes/hashes, but no comparator | section 7; OQ-MS-01 supplies the one authority and conflict comparator |
| initializer owner/kind/dependency/ordinal | authoritative wire/tag/coverage and common dependency comparator | section 8; OQ-MS-04 topological edge rule, OQ-MS-10 local validation order, OQ-MS-11 callable shape |
| module initializer presence/cardinality | authoritative zero-or-one prose | section 9 exact declaration/unit cardinality; OQ-MS-05 closes equality |
| post-init presence/cardinality | authoritative semantic sequence + same-module reference; current getter execution | section 9 zero-or-more unique sequence; OQ-MS-06 duplicate rule and OQ-MS-12 callable shape |
| StateInputHash | authoritative domain/input list and canonical writer | section 10 freezes the full ordered stream and self-exclusion |
| opaque request | authoritative public request/summary and graph step 1 | section 11; OQ-MS-08 zero/empty handling and OQ-MS-09 empty debug sources |
| error priority | authoritative stage/error/global precedence | section 12 adds deterministic ModuleState-local order through OQ-MS-10 |
| exhaustive RED rows | authoritative executable-evidence requirements | section 13 enumerates all semantic partitions and expected first failures |

## 3. Frozen V1 shape and collection semantics

### 3.1 Wire enums

**Evidence** — retain these exact numeric values:

```text
GlobalInitializationKind: Invalid=0, Default=1, PureConstant=2, VmInitializer=3
GlobalCleanupPolicy:      Invalid=0, None=1, DestroyValue=2, ReleaseHandle=3
HardValueKind:            Invalid=0, GlobalConstant=1, EnumAuthority=2
InitializerKind:          Invalid=0, Global=1, Module=2
InitializationActionKind: Invalid=0, DefaultConstructGlobal=1,
                          ExecuteInitializer=2
CanonicalValueKind:       Invalid=0, Bool=1, SignedInteger=2,
                          UnsignedInteger=3, Float32=4, Float64=5,
                          EnumInt32=6
OpaquePayloadKind:        Invalid=0, FunctionExecution=1,
                          InitializerExecution=2, Debug=3
```

Zero and every unlisted byte are `UnknownEnumValue` at `PayloadDecode`.

### 3.2 Exact DTO/wire field order

**Evidence** — the record and nested rows are exactly:

```text
ModuleState:
  PayloadSchemaVersion:u32
  ModuleKey:hash256
  Profile:hash256
  StateInputHash:hash256
  OrderedGlobals:array<GlobalSchema>
  HardValues:array<HardValue>
  Initializers:array<InitializerUnit>
  OrderedInitializationActions:array<InitializationAction>
  OrderedPostInitFunctions:array<PostInitFunction>
  Dependencies:array<SemanticDependency>

GlobalSchema:
  StorageOrdinal:u32
  GlobalKey:hash256
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
  FixedWidthValueBytes:bytes

InitializerUnit:
  InitializerKind:u8
  InitializerKey:hash256
  OwnerGlobal:optional<hash256>
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

**Design choice** — use owning, pointer-free DTOs only. No raw AS/UE type,
function, global, address, storage byte buffer, `FName`, `UObject*`, FunctionId,
TypeId, RecordId, lifetime blob, source path, initialized flag, or decoder view
is representable in these structs.

### 3.3 Collection categories

| Field | Category | Writer | Reader |
|---|---|---|---|
| OrderedGlobals | semantic sequence | preserves caller order; requires position ordinal | rejects position mismatch; never sorts |
| HardValues | canonical unique set | validates duplicate/conflict, sorts by OQ-MS-01 comparator | rejects duplicate/conflict and noncanonical order |
| Initializers | canonical unique set by complete InitializerKey | rejects duplicate/conflict then sorts by key | rejects duplicate/conflict and noncanonical order |
| OrderedInitializationActions | semantic sequence | preserves dependency-solved execution order; requires position ordinal | rejects position mismatch; never sorts |
| InitializationAction.Dependencies | common canonical unique set | reuses exact common dependency comparator | reuses exact common duplicate/conflict/order rules |
| OrderedPostInitFunctions | semantic sequence | preserves caller order; requires position ordinal | rejects position mismatch; never sorts |
| ModuleState.Dependencies | common canonical unique set | reuses exact common dependency comparator | reuses exact common duplicate/conflict/order rules |

**Design choice** — sequence identity is the array position plus stored ordinal;
the stable entity key is still unique within each sequence. For globals and
initialization actions, equal target authority with equal non-ordinal content
is `DuplicateKey`; differing content is `ConflictingKey`. Initializer units are
a canonical set whose sole authority is InitializerKey. Physical decode and
trailing-data validation precede every semantic ordinal/authority check under
OQ-MS-10. For post-init, OQ-MS-06 applies.

## 4. Global declaration and initialization matrix

### 4.1 Exact ModuleInterface-to-GlobalSchema match

**Evidence** — graph step 5 compares ModuleState globals with the complete local
global declaration set.

**Design choice** — build a full-key index over ModuleInterface declarations.
For every declaration with
`DeclarationKind=Global, EntityKind=GlobalVariable`, require exactly one
GlobalSchema and require:

| GlobalSchema field | Required authority/equality |
|---|---|
| GlobalKey | declaration `StableKey` |
| CanonicalNamespace | byte-equal declaration namespace |
| CanonicalName | byte-equal declaration name |
| Type | deep-equal declaration `DeclaredType` |
| GlobalTraitFlags | exactly declaration `TraitFlags`; not a subset |
| StorageOrdinal | position in ModuleState storage sequence; no authority in ModuleInterface |
| InitializationKind | capture classification below; exact coverage checks below |
| CleanupPolicy | canonical ownership classifier below |
| StorageLayoutFingerprint | exact local recomputation |

No non-global declaration may appear. No global declaration may be omitted. A
different key with the same name is not accepted as a rename or fallback.

Graph mismatch is `GlobalCoverageMismatch`, except a zero key/invalid common
type/unknown flag already fails local validation with its earlier common error.

### 4.2 Producer classification algorithm

**Design choice** — classify each compiler global exactly once, in this order:

1. Canonicalize the declared type and determine cleanup ownership. If type,
   ownership, initializer identity, or dependency closure is not representable,
   the complete module snapshot is NotCacheable; emit no partial record.
2. If the compiler proves a read-only scalar compile-time value and the scalar
   is representable by section 5, require the common `Const` declaration trait
   and emit `PureConstant`.
3. Otherwise, if the compiler emits nontrivial global initializer execution,
   emit `VmInitializer` and one stable GlobalInitializer declaration/unit.
4. Otherwise emit `Default`. This includes zero/null initialization and
   type-driven default construction. An explicit initializer optimized to no
   execution is `Default`, not an empty VmInitializer.

The producer does not infer a module initializer from the list of global
initializers. It emits a `Module` unit only when the compiler exposes a distinct
stable module-level initializer declaration.

### 4.3 Capture eligibility by semantic type

| Declared global category | Default | PureConstant | VmInitializer | Required cleanup |
|---|---:|---:|---:|---|
| non-void primitive, non-reference | yes | yes, only compiler-proved + Const | yes | None |
| local enum ScriptType, non-reference/non-handle | yes | yes, only compiler-proved + Const | yes | None |
| resolved ScriptType Class/Interface/Funcdef reference semantic, explicit or implicit handle | yes (null) | no | yes | ReleaseHandle |
| resolved ScriptType Struct/Delegate value | yes | no | yes | DestroyValue |
| EnvironmentType with explicit resolver storage category | yes | no | yes | exact None/DestroyValue/ReleaseHandle mapping in section 6 |
| Auto | no | no | no | NotCacheable |
| Void | no | no | no | NotCacheable |
| any reference-qualified global | no | no | no | NotCacheable |
| ScriptType handle applied to Struct/Delegate/Enum/Typedef | no | no | no | NotCacheable |
| pointer/UObject/raw host or ownership-undetermined type | no | no | no | NotCacheable |

“Mutable global” here means its live value must not be captured. Mutable
Default/VmInitializer declarations remain cacheable when their schema and
initializer inputs are complete; they simply cannot be `PureConstant` and never
persist a post-startup value.

### 4.4 Exact init/hard-value/initializer coverage

For a GlobalKey `G`, define C(G) as GlobalConstant HardValue count, U(G) as
Global InitializerUnit owner count, E(G) as matching ExecuteInitializer action
count, and D(G) as DefaultConstructGlobal action count.

| InitializationKind / cleanup | C(G) | U(G) | E(G) | D(G) | Additional rule |
|---|---:|---:|---:|---:|---|
| Default / DestroyValue | 0 | 0 | 0 | 1 | no initializer declaration; action performs type default construction |
| Default / None or ReleaseHandle | 0 | 0 | 0 | 0 | zero/null storage is the complete default |
| PureConstant / None | 1 | 0 | 0 | 0 | global has Const trait; scalar type/value exact |
| VmInitializer / any legal cleanup | 0 | 1 | 1 | 0 | exactly one matching GlobalInitializer declaration/unit/action |

**Evidence** — this is the exact coverage described by
`record-wire-v1-remaining.md:756-767`.

**Design choice** — every other tuple is a local coverage error when the unit/
action contradiction is record-internal, otherwise `GlobalCoverageMismatch` at
graph step 5. Duplicate/conflicting HardValue, Initializer, or action targets
that can be proven within the record fail earlier locally.

### 4.5 Global storage layout fingerprint

**Evidence** — recompute exactly:

```text
H("cache-global-storage-layout-v1",
  ModuleKey,
  GlobalKey,
  StorageOrdinal,
  CanonicalNamespace,
  CanonicalName,
  CanonicalDataType,
  GlobalTraitFlags,
  InitializationKind,
  CleanupPolicy)
```

The stored fingerprint is never an input to itself. Any unequal stored value is
`DerivedHashMismatch`/`LocalSemantic` at the fingerprint field. This hash is a
semantic storage coordinate, not a byte offset, `sizeof`, host alignment, or
address.

## 5. CanonicalValue exact width and bit rules

### 5.1 Primitive mapping

**Evidence** — the declared canonical type, not `ValueKind` alone, selects the
only legal kind and byte count:

| Canonical declared type | Required ValueKind | Bytes | Accepted bit patterns |
|---|---|---:|---|
| Primitive Bool | Bool | 1 | exactly `00` or `01` |
| Primitive Int8 | SignedInteger | 1 | every 8-bit two's-complement pattern |
| Primitive Int16 | SignedInteger | 2 | every 16-bit pattern, little-endian |
| Primitive Int32 | SignedInteger | 4 | every 32-bit pattern, little-endian |
| Primitive Int64 | SignedInteger | 8 | every 64-bit pattern, little-endian |
| Primitive UInt8 | UnsignedInteger | 1 | every 8-bit pattern |
| Primitive UInt16 | UnsignedInteger | 2 | every 16-bit pattern, little-endian |
| Primitive UInt32 | UnsignedInteger | 4 | every 32-bit pattern, little-endian |
| Primitive UInt64 | UnsignedInteger | 8 | every 64-bit pattern, little-endian |
| Primitive Float32 | Float32 | 4 | every IEEE-754 binary32 bit pattern |
| Primitive Float64 | Float64 | 8 | every IEEE-754 binary64 bit pattern |
| local enum ScriptType | EnumInt32 | 4 | every signed-int32 pattern, little-endian |

Float positive/negative zero, infinities, subnormals, signaling/quiet NaNs, and
NaN payload bits are copied exactly. The producer must not parse, round,
canonicalize, endian-swap twice, quiet a NaN, or turn `-0` into `+0`.

### 5.2 Presence and type constraints

**Design choice** — a CanonicalValue is valid only when all are true:

1. it is the present value of `HardValueKind::GlobalConstant`;
2. the owning GlobalSchema is `PureConstant` and carries the common `Const`
   declaration trait;
3. the declared type matches exactly one row above;
4. primitive types have `QualifierFlags=None`, no TypeReference, and no
   subtypes; the enum has a ScriptType reference, no handle/reference flags, and
   no subtypes;
5. byte count and Bool contents are exact.

Primitive Void, Auto, objects, handles, references, environment values,
variable-width strings, arrays/containers, UObjects, raw pointers, host-width
integers, and mutable values cannot appear. A producer encountering one returns
NotCacheable. A forged wire value is `InvalidPresence` locally when decidable;
an apparent ScriptType that resolves to a non-enum fails
`GlobalCoverageMismatch` in graph step 5.

The `bytes` field carries the inherited canonical `u64` byte count on the wire.
“Fixed-width” constrains the decoded count to the row's exact width; it does not
remove or narrow the common byte-array count prefix.

## 6. Cleanup ownership and lifecycle

### 6.1 Local cleanup-policy classifier

Let `Qref` be the Reference qualifier and `Qhandle` the ObjectHandle qualifier.
After common `CanonicalDataType` validation, local validation applies only the
rules it can know without another record:

| Type shape | Locally allowed policy | Required graph/current authority |
|---|---|---|
| Auto, Primitive Void, or any Qref | none; record shape invalid | producer NotCacheable; forged record `InvalidPresence` |
| non-void Primitive, no Qref/Qhandle | None only | no refinement |
| ScriptType, no Qref | one of None/DestroyValue/ReleaseHandle | resolved TypeSchema table below selects exactly one; Qhandle requires a reference-semantic kind |
| EnvironmentType, no Qref | one of None/DestroyValue/ReleaseHandle | explicit current `ValueStorageKind` table below selects exactly one; Qhandle requires ReferenceCounted |

Resolved ScriptType cleanup is exhaustive:

| Resolved TypeKind | Qhandle allowed | Required cleanup |
|---|---:|---|
| Class | optional/implicit reference semantic | ReleaseHandle |
| Interface | optional/implicit reference semantic | ReleaseHandle |
| Funcdef | optional/implicit reference semantic | ReleaseHandle |
| Struct | forbidden | DestroyValue |
| Delegate | forbidden | DestroyValue |
| Enum | forbidden | None |
| primitive-only Typedef | forbidden | None |

The current environment resolver exposes this independent, typed coordinate:

```text
EAngelscriptCacheValueStorageKind : u8 (not serialized in ModuleState)
  Invalid=0, Trivial=1, OwningValue=2, ReferenceCounted=3
```

When resolving an EnvironmentType, `FAngelscriptCacheCurrentSymbol` must carry
one non-Invalid value. Its exact mapping is Trivial→None,
OwningValue→DestroyValue, ReferenceCounted→ReleaseHandle. Qhandle is legal only
for ReferenceCounted. The storage category is compared explicitly before any
attach; equal ABI hashes never imply an ownership route. A missing category or
unequal cleanup is `CurrentAbiMismatch`/Ineligible after immutable graph closure.

All other policy/type combinations are `InvalidPresence` when locally
decidable or `GlobalCoverageMismatch` after TypeSchema resolution. Unknown
policy bytes remain `UnknownEnumValue` at decode. ObjectConst, ConstHandle, and
IfHandleThenConst do not change the top-level cleanup action; common qualifier
validation still applies. Ordered template subtypes do not choose cleanup for
the top-level value, but every subtype must be valid and ABI-covered.

### 6.2 Restore and rollback algorithm

**Design choice** — a later live loader implements this exact policy:

1. Allocate and zero every global storage slot in `StorageOrdinal` order.
   PureConstant storage receives its exact canonical bits during this phase.
   Neither operation is an initialization action.
2. Walk `OrderedInitializationActions` once in ActionOrdinal order. For
   `DefaultConstructGlobal`, resolve the targeted Default global and invoke its
   type-driven default constructor. For `ExecuteInitializer`, resolve the
   targeted Global or Module InitializerUnit and execute its validated payload.
3. Immediately before an action that may establish a non-`None` global value,
   push that GlobalKey once on a transient cleanup stack if not already present.
   A Module initializer never pushes a global. The stack therefore records exact
   attempt order across interleaved default and VM actions.
4. Execute `OrderedPostInitFunctions` only after every initialization action.
5. Publish the module active only after all prior operations succeed.
6. On failure, or on normal module release, pop the transient stack and apply
   each GlobalSchema policy: `DestroyValue` invokes the resolved value destroy/
   free route; `ReleaseHandle` invokes the resolved release route and clears the
   slot. `None` does nothing.

The stack and active flag are runtime transaction state. Neither is serialized.
Cleanup policy and the underlying VM type route must be zero/partial-failure
safe because a constructor/initializer may fail after writing only part of a
slot. A global can enter the stack at most once. StorageOrdinal never substitutes
for ActionOrdinal when choosing execution or reverse cleanup order.

## 7. HardValue authority, comparator, and hashes

### 7.1 Shape matrix

| HardValueKind | Owner.Kind | CanonicalValue | Type | Hash authority |
|---|---|---|---|---|
| GlobalConstant | ScriptGlobal | required | exact owning global type | locally recomputable from stored scalar |
| EnumAuthority | ScriptType | forbidden | exact canonical type for the same enum | graph recomputes from TypeSchema enumerators |

For both kinds, Owner StableKey and ExpectedAbi are nonzero under the common
StableReference rules. In graph validation ExpectedAbi equals the matching
ModuleInterface declaration ABI. The owner must be local to ModuleState's
ModuleKey.

Wrong owner reference kind or value presence is `WrongReferenceKind` or
`InvalidPresence` locally. Missing owner, wrong module, undeclared owner, ABI
disagreement, or type disagreement is a graph error according to section 12.

### 7.2 Canonical set comparator

**Design choice OQ-MS-01** — define:

```text
HardValueAuthority = {
  numeric HardValueKind,
  numeric Owner.ReferenceKind,
  complete Owner.StableKey bytes
}
```

Rows sort ascending by that tuple only. It is an entity authority comparator,
not a content comparator. Before sorting/ordering validation, group all rows by
authority:

- same authority and byte-equal ExpectedAbi, Type, optional presence/value
  kind/value bytes, and HardValueHash => `DuplicateKey`;
- same authority and any differing content => `ConflictingKey`.

ExpectedAbi and content are intentionally excluded from authority so two
claims for one global/enum cannot evade conflict detection by changing ABI or
value. After duplicate/conflict rejection the authority tuple is already a
strict total order; the reader returns `NonCanonicalOrder` for a descending row.

### 7.3 Exact hash rules

**Evidence** — `GlobalConstant` recomputes:

```text
H("cache-hard-value-v1",
  GlobalConstant,
  Owner StableReference,
  CanonicalDataType,
  CanonicalValue fields)
```

An unequal stored value is `DerivedHashMismatch` locally at HardValueHash.

**Evidence** — `EnumAuthority` recomputes in graph step 6:

```text
EnumAuthorityInput =
  TypeKey,
  for each TypeSchema enumerator in DeclarationOrdinal order:
    DeclarationOrdinal, CanonicalName, SignedInt32Value, canonical Metadata

HardValueHash = H("cache-hard-value-v1",
  EnumAuthority,
  Owner StableReference,
  enum CanonicalDataType,
  EnumAuthorityInput)
```

ModuleState does not repeat the enumerator array. There is exactly one such row
for every local Enum TypeSchema and no row for any other type. Every missing,
extra, duplicate, mismatched-owner/type/ABI, or unequal enum authority is
`EnumAuthorityMismatch` in graph step 6 unless a local duplicate/conflict error
already won.

## 8. Initializer units, initialization actions, dependencies, and cardinality

### 8.1 InitializerUnit tagged-owner matrix and canonical set

| InitializerKind | OwnerGlobal optional | InitializerKey | Local result |
|---|---|---|---|
| Global | present and nonzero | nonzero | `shape valid` |
| Global | absent or zero | any | `InvalidPresence` or `ZeroStableKey` |
| Module | absent | nonzero | `shape valid` |
| Module | present | any | `InvalidPresence` |
| Invalid/unknown | any | any | `UnknownEnumValue` |

`Initializers` is a canonical unique set ordered only by complete
InitializerKey. Same key and equal kind/owner/codec/hash/payload is
`DuplicateKey`; same key with any differing content is `ConflictingKey`.
No dependency or ordinal is stored on the unit: it owns canonical execution
bytes, while its single ExecuteInitializer action owns semantic dependencies
and execution position.

### 8.2 Exact ModuleInterface declaration match

| Unit kind | Required declaration |
|---|---|
| Global | DeclarationKind Function; EntityKind GlobalInitializer; OwnerKind Global; OwnerKey equals OwnerGlobal; ModuleKey equals state ModuleKey; BodyCoverage Forbidden; zero parameters; return canonical Void; TraitFlags exactly Generated; ReflectionFlags/identity flags/metadata/slots empty |
| Module | DeclarationKind Function; EntityKind ModuleInitializer; OwnerKind Module; OwnerKey equals state ModuleKey; ModuleKey equals state ModuleKey; BodyCoverage Forbidden; zero parameters; return canonical Void; TraitFlags exactly Generated; ReflectionFlags/identity flags/metadata/slots empty |

Declaration, unit, and ExecuteInitializer action target-key sets are exact-equal.
Every VmInitializer global contributes exactly one GlobalInitializer
declaration/unit/action. A Global initializer's OwnerGlobal is that global.
Every other global contributes none. There are zero or one Module units and
therefore zero or one matching ModuleInitializer declaration/action. A unit
without a declaration is `UndeclaredEntity`; a declaration without a unit is
`MissingCoverage`; wrong kind/owner/cardinality is
`InitializerOwnershipMismatch`.

No initializer key may appear in ModuleSnapshot FunctionBody links. Such a link
is `UnexpectedRecord` before normal FunctionBody coverage succeeds.

### 8.3 Initializer execution hash

Local validation recomputes:

```text
H("cache-initializer-execution-v1",
  ModuleState.ModuleKey,
  ModuleState.Profile,
  InitializerKey,
  VmInitializerCodecVersion,
  CanonicalExecutionPayload)
```

It requires equality with InitializerExecutionHash and otherwise returns
`DerivedHashMismatch`/LocalSemantic at that hash field. It does not inspect VM
instructions or call the opaque validator.

### 8.4 InitializationAction shape and exact coverage

`ActionOrdinal` equals array position `0..N-1`. A smaller value at the first
offending position is `DuplicateOrdinal`; a larger value is `OrdinalGap`.
The writer never sorts this sequence.

| ActionKind | Target kind | Required target and coverage |
|---|---|---|
| DefaultConstructGlobal | ScriptGlobal | target is one Default global with CleanupPolicy DestroyValue; exactly one such action exists for every Default DestroyValue global and for no other global |
| ExecuteInitializer | ScriptFunction | target is one InitializerUnit key; every unit is targeted exactly once; Global unit owner is its VmInitializer global, Module unit has no global |

Target ExpectedAbi is required and must equal the matching ModuleInterface
declaration ABI. Equal action target authority with equal kind/dependencies is
`DuplicateKey`; equal authority with differing content is `ConflictingKey`.
Wrong reference kind is local `WrongReferenceKind`; missing unit/global,
wrong initialization kind, wrong cleanup, or coverage mismatch is
`InitializerOwnershipMismatch`.

The action content coordinate used by local ordering dependencies is:

```text
DefaultConstructGlobal -> target GlobalSchema.StorageLayoutFingerprint
ExecuteInitializer     -> target InitializerUnit.InitializerExecutionHash
```

### 8.5 Dependency kind, target, scope, and ordering matrix

Every action dependency reuses the common full comparator and duplicate
authority:

```text
full comparator = {
  numeric DependencyKind,
  numeric Target.ReferenceKind,
  Target.StableKey,
  Target.ExpectedAbi,
  ExpectedContentOrValue presence,
  ExpectedContentOrValue hash when present
}

duplicate authority = {
  DependencyKind,
  Target.ReferenceKind,
  Target.StableKey
}
```

The allowlist is bidirectional:

| DependencyKind | Allowed target | Content | Scope/rule |
|---|---|---|---|
| Initializer | ScriptGlobal or ScriptFunction | required | when target is another local action, it must name that action target, equal its action content coordinate, and have a strictly smaller ActionOrdinal; self/forward/missing/cycle is InitializerOwnershipMismatch |
| Declaration | ScriptFunction | absent | exact callable/default-behavior declaration consumed by this action; an initializer declaration target must instead use Initializer |
| ValueLayout | ScriptType or EnvironmentSymbol | required | target declaration/environment ABI remains in ExpectedAbi; content is the exact recursively used TypeLayoutHash/environment layout fingerprint |
| GlobalStorage | ScriptGlobal | required | exact referenced global storage fingerprint |
| HardValue | ScriptGlobal or ScriptType | required | exact GlobalConstant or EnumAuthority hash observed by the action |
| CompileOption | EnvironmentSymbol | required | exact option/value coordinate captured for the action |
| EnvironmentAbi | EnvironmentSymbol | absent | exact external ABI consumed by the action |

CanonicalName and StringLiteral are reference kinds, not dependency kinds.
They are legal only through a relocation's otherwise valid dependency kind and
require the exact owned bytes supplied by the opaque summary.

Import, Signature, Inheritance, and PropertyLayout are allowed only when the
initializer/default-construction producer supplies a concrete dependency with
the common target-kind/content rule and the target is semantically reachable
from this action's declaration/type closure. Any unrelated target or a
dependency kind that contradicts a local initializer/global/type authority is
`UnexpectedRecord`.

For every local action-to-action dependency, `Initializer` is mandatory; a
Declaration or other-kind edge to the same action authority is invalid. Every
Initializer edge to a local key must resolve to an action. External Initializer
edges may target another module and impose no local ordinal, but still require
ScriptGlobal/ScriptFunction, ABI, and content. These bidirectional rules prevent
a forged Declaration edge from bypassing the topological/content check.

The compiler retry order is capture evidence. The explicit action sequence plus
its local Initializer edges is the cache authority. Independent actions need no
synthetic edge; their captured relative order is still semantic and preserved.


## 9. Module initializer and post-init presence/cardinality

### 9.1 Module initializer

**Evidence** — a module has zero or one `InitializerKind::Module` unit.

**Design choice** — cardinality is exact against ModuleInterface:

| ModuleInitializer declarations | Module units | Execute actions | Result |
|---:|---:|---:|---|
| 0 | 0 | 0 | valid |
| 1 | 1, same key | 1, same key | valid |
| any other tuple | any | any | exact UndeclaredEntity/MissingCoverage/InitializerOwnershipMismatch mapping from section 8 |

A Module ExecuteInitializer action may occur anywhere in
`OrderedInitializationActions` that satisfies its explicit dependency edges.
V1 does not silently force it first or last.

### 9.2 Post-init functions

**Evidence** — `PostInitOrdinal` is `0..N-1`; every target is a same-module
declared ScriptFunction with exact ExpectedAbi.

**Design choice OQ-MS-12** — local rules are:

- Function.Kind must be ScriptFunction; otherwise `WrongReferenceKind`;
- StableKey and ExpectedAbi use common nonzero rules;
- ordinal equals position;
- StableKey occurs once under OQ-MS-06.

Graph rules are:

- key resolves in the same ModuleInterface;
- declaration is an ordinary module-owned, non-abstract `GlobalFunction`, not
  a method, initializer, delegate signature, import, or property;
- declaration has zero parameters (the return value may be non-void and is
  discarded, matching generated property getter use);
- BodyCoverage is exactly Required, so the snapshot must contain its executable
  FunctionBody; no alternate executable provider is inferred;
- ExpectedAbi equals declaration ABI;
- normal snapshot FunctionBody coverage and invocation-kind validation apply.

Unknown key is `UndeclaredEntity`; wrong declaration category is
`WrongReferenceKind`; ABI disagreement is `GraphAbiMismatch`. No declaration is
implicitly post-init merely because of its name, property flag, or `Get` prefix.

The lifecycle allows zero post-init rows. Count is bounded by normal array and
session limits; there is no separate “present” boolean.

## 10. StateInputHash exact stream

### 10.1 Domain and field order

**Evidence** — use `FAngelscriptArtifactCanonicalWriter` with domain
`cache-module-state-input-v1`. It writes the following stream after set
canonicalization and sequence validation:

```text
PayloadSchemaVersion
ModuleKey
Profile

OrderedGlobals.count
for each GlobalSchema in semantic order:
  StorageOrdinal
  GlobalKey
  CanonicalNamespace
  CanonicalName
  CanonicalDataType field-by-field
  GlobalTraitFlags
  InitializationKind
  CleanupPolicy
  StorageLayoutFingerprint

HardValues.count
for each HardValue in OQ-MS-01 canonical order:
  HardValueKind
  Owner StableReference field-by-field
  CanonicalDataType field-by-field
  CanonicalValue presence tag
  if present: ValueKind, FixedWidthValueBytes.count, exact bytes
  HardValueHash

Initializers.count
for each InitializerUnit in canonical InitializerKey order:
  InitializerKind
  InitializerKey
  OwnerGlobal presence tag and key when present
  VmInitializerCodecVersion
  InitializerExecutionHash
  CanonicalExecutionPayload.count and exact bytes

OrderedInitializationActions.count
for each InitializationAction in semantic order:
  ActionOrdinal
  ActionKind
  Target StableReference field-by-field
  Dependencies.count and every canonical dependency field

OrderedPostInitFunctions.count
for each row in semantic order:
  PostInitOrdinal
  Function StableReference field-by-field

Dependencies.count
every canonical ModuleState dependency field
```

The stream excludes StateInputHash itself. It intentionally includes stored
derived storage/hard-value/initializer hashes as well as their semantic inputs.
For EnumAuthority the stored HardValueHash participates locally; graph step 6
separately proves it against TypeSchema.

Any field mutation listed above changes StateInputHash. A mismatch is
`DerivedHashMismatch`/`LocalSemantic` at the StateInputHash field, after earlier
row validation/hash failures. Profile is an input; a profile change is not
silently hidden by identical payload bytes.

### 10.2 ModuleState top-level dependencies

ModuleState.Dependencies is the exact canonical set of state-level inputs not
owned solely by one InitializationAction. Required derived coverage is:

| DependencyKind | Exact target/content coverage |
|---|---|
| Declaration | one ScriptModule row for the owning ModuleInterface ABI; one ScriptFunction row for every InitializerUnit declaration and every post-init declaration; absent content |
| GlobalStorage | one ScriptGlobal row for every OrderedGlobal, with ExpectedContentOrValue equal StorageLayoutFingerprint |
| ValueLayout | one row for every distinct ScriptType/EnvironmentSymbol recursively present in a GlobalSchema CanonicalDataType; content equals the exact TypeLayoutHash/environment layout fingerprint consumed by the cached global layout |
| HardValue | one row for every HardValue authority, targeting the same ScriptGlobal/ScriptType and carrying HardValueHash |
| CompileOption | every exact state-wide compile option/value consumed outside an individual action; EnvironmentSymbol target and required content |
| EnvironmentAbi | every environment ABI/storage-category input used by a global type/cleanup route outside an individual action; EnvironmentSymbol target and absent content |

Initializer, Import, Signature, Inheritance, PropertyLayout, and action-private
Declaration/ValueLayout/GlobalStorage/HardValue rows belong to the relevant
InitializationAction.Dependencies and are forbidden as unrelated top-level
duplicates. A coordinate needed by both scopes appears once in each owner; this
is intentional because their hash owners differ. Missing a required derived row
is `MissingCoverage`; an extra row not justified by the table or an exact
state-wide producer input is `UnexpectedRecord`; wrong kind/target/content is
the earlier common reference error or `GraphAbiMismatch` as applicable.

CanonicalName/StringLiteral targets are forbidden in the top-level set because
ModuleState has no top-level opaque owned-byte authority. They may appear in an
InitializationAction dependency only when the linked initializer codec summary
provides the exact owned UTF-8 row required by the common opaque contract.

## 11. Opaque initializer request and summary

### 11.1 Exact request

For each reachable ExecuteInitializer action, graph step 1 resolves its unique
InitializerUnit and constructs exactly:

```text
Kind             = InitializerExecution
CodecVersion     = unit.VmInitializerCodecVersion
ModuleKey        = state.ModuleKey
OwnerKey         = unit.InitializerKey
Profile          = state.Profile
CanonicalPayload = exact unit.CanonicalExecutionPayload view
```

and calls:

```text
Validate(Request, same Limits, same caller-owned Budget, OutSummary)
```

Calls occur in ascending ActionOrdinal, exactly once per ExecuteInitializer
action/unit, and are fail-fast: after the first failing call every later action
receives zero calls. Later steps consume the graph-owned immutable summaries and
never call again. An unrelated state/initializer in the supplied token pool
receives zero calls. Output summary resets before each call and publishes only
on complete success. Two-malformed-unit fixtures freeze both first error and
the exact prefix call count independently of caller pool/map insertion order.

### 11.2 Summary validation

Require:

1. `ValidatedPayloadHash == InitializerExecutionHash`; mismatch is
   `OpaquePayloadHashMismatch`.
2. relocations are a semantic sequence ordered by
   `{InstructionOrdinal, OperandSlot}`, with duplicate coordinates rejected;
3. each relocation has one exact matching owning action dependency on dependency kind,
   reference kind, StableKey, ExpectedAbi, content presence, and content hash;
   relocation is a subset, not equality;
4. CanonicalName/StringLiteral relocations have zero ABI and exactly one owned
   strict-UTF-8 byte row whose domain hash equals StableKey;
5. owned bytes use comparator `{numeric ReferenceKind, StableKey}` and the
   common duplicate/conflict rules; the owned-byte authority set is exactly
   equal to the unique CanonicalName/StringLiteral relocation authority set, so
   missing and extra unreferenced rows both fail;
6. `ExactDebugSources` is empty under OQ-MS-09.

Unsupported version, malformed payload/summary, hash mismatch, and relocation
dependency mismatch return errors `44`, `45`, `46`, and `47` respectively at
`OpaqueCodec`, with RecordKind ModuleState and the enclosing payload byte-array
offset.

Empty payload and version zero reach the validator under OQ-MS-08; common code
does not pre-label them.

## 12. Error ownership and deterministic priority

### 12.1 Local ModuleState validation order

**Design choice OQ-MS-10** — after envelope success, the ModuleState decoder
uses this observable order:

1. read PayloadSchemaVersion; unequal `1` => `UnsupportedPayloadSchema`,
   `PayloadDecode`, offset 0;
2. physically decode every remaining field and nested array in exact wire
   order, charging the same budget before allocations. Invalid width/tag/enum/
   UTF-8/count/out-of-bounds fails immediately at `PayloadDecode`; integer flag
   masks are physically read here but their unknown bits are checked later as
   `UnknownFlags / LocalSemantic`. No ordinal, presence, authority, graph, or
   derived-hash predicate runs yet;
3. require end-of-payload. A trailing byte is `TrailingData` and wins over every
   otherwise earlier local semantic/hash contradiction;
4. require nonzero ModuleKey/Profile and validate every nested common stable
   value in captured wire-field order;
5. validate the semantic collections in top-level wire order: globals ordinal
   and key authority; HardValue authority/conflict/order; Initializer key
   authority/order; initialization action ordinal/target/dependencies;
   post-init ordinal/key; then top-level dependency authority/order;
6. validate locally decidable tagged presence, initialization/action coverage,
   cleanup candidates, value width/kind, and reference-kind rules;
7. recompute every GlobalStorageLayoutFingerprint in global order;
8. recompute every GlobalConstant HardValueHash in canonical order;
9. recompute every InitializerExecutionHash in canonical InitializerKey order;
10. recompute StateInputHash;
11. only after complete local success does the immutable-token factory
    recompute and compare the declared RecordId.

This ordering is unconditional and combination-RED observable. Physical decode
and trailing data beat local semantics; local semantics beat derived hashes;
nested/row hashes beat StateInputHash; all local results beat RecordIdMismatch.
Every failure clears the decoded DTO/token.

### 12.2 Graph priority for ModuleState

**Evidence** — the relevant first-failure order is:

1. step 1 resolves reachable records and invokes every reachable initializer
   codec exactly once in Execute action order, fail-fast; codec/integrity errors
   win over later owner/coverage contradictions;
2. step 2 proves snapshot/state redundant ModuleKey ownership;
3. step 3 indexes ModuleInterface globals/initializers/functions;
4. step 5 validates exact globals, locally allowed cleanup candidates, the
   unique cleanup selected by resolved ScriptType, GlobalConstant, initializer
   unit/action owner/declaration/cardinality/dependency/relocation, post-init,
   and absence of initializer FunctionBodies. It does not call the current
   resolver and does not select EnvironmentType storage category;
5. step 6 validates enum authority;
6. step 9 validates immutable profile/dependency/ABI self-consistency;
7. step 10 compares selected source, selected profile, then current symbols;
   only here does an EnvironmentType consume CurrentValueStorageKind and require
   its exact cleanup mapping;
8. step 11 atomically publishes.

Suggested exact error assignment:

| Contradiction | Error / class |
|---|---|
| state link missing/wrong kind | MissingRecord or WrongRecordKind / GraphOrOwnership |
| state.ModuleKey differs snapshot/interface | CrossModuleOwner / GraphOrOwnership |
| global declaration set/field/init-hard-init tuple/local or resolved ScriptType cleanup authority mismatch | GlobalCoverageMismatch / GraphOrOwnership |
| EnvironmentType CurrentValueStorageKind missing/invalid or unequal to stored cleanup | CurrentAbiMismatch / Ineligible at step 10 |
| initializer key absent from declarations | UndeclaredEntity / GraphOrOwnership |
| wrong initializer declaration kind/owner/cardinality/order | InitializerOwnershipMismatch / GraphOrOwnership |
| initializer has independent FunctionBody | UnexpectedRecord / GraphOrOwnership |
| initializer/post-init declaration ABI contradiction | GraphAbiMismatch / GraphOrOwnership |
| post-init wrong reference/declaration kind | WrongReferenceKind / GraphOrOwnership |
| local enum authority missing/extra/unequal | EnumAuthorityMismatch / GraphOrOwnership |
| initializer relocation not exact dependency subset | RelocationDependencyMismatch / GraphOrOwnership |
| immutable child profiles disagree | ProfileGraphMismatch / GraphOrOwnership |
| selected current profile differs after graph closure | ProfileMismatch / Ineligible |
| current target missing/ABI/content changed | CurrentSymbolMissing, CurrentAbiMismatch, or CurrentContentMismatch / Ineligible |

An internally contradictory stored graph never becomes a normal cache miss.

## 13. Exhaustive RED matrix

These are parameterized RED families, not illustrative samples. “For every”
means the test implementation enumerates the complete stated Cartesian set.
Every failure asserts Error, Class, RecordKind, Stage, first field offset,
cleared output, and unchanged monotonic budget semantics. All tests are pure,
in-memory, engine-free, and disk-free.

### 13.1 Enum, schema, identity, and wire rows

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-001 | PayloadSchemaVersion `{0,2,MAX_u32}` | UnsupportedPayloadSchema / PayloadDecode at version |
| MS-RED-002 | zero ModuleKey; otherwise valid record | ZeroStableKey / LocalSemantic at ModuleKey |
| MS-RED-003 | zero Profile; otherwise valid record | ZeroStableKey / LocalSemantic at Profile |
| MS-RED-004 | each state enum field uses `0` and first byte above its maximum | UnknownEnumValue / PayloadDecode at enum |
| MS-RED-005 | invalid optional tag `{2,255}` for CanonicalValue and OwnerGlobal | InvalidOptionalTag / PayloadDecode at tag |
| MS-RED-006 | unknown GlobalTraitFlags bit | UnknownFlags / LocalSemantic at GlobalTraitFlags |
| MS-RED-006A | unknown GlobalTraitFlags bit paired independently with trailing data, StateInputHash mismatch, and RecordId mismatch | trailing data wins the first pair; UnknownFlags / LocalSemantic wins the hash and RecordId pairs |
| MS-RED-007 | invalid UTF-8 and embedded NUL independently in global namespace/name | InvalidUtf8 or EmbeddedNul at exact string |
| MS-RED-008 | empty global name | InvalidPresence / LocalSemantic at GlobalSchema |
| MS-RED-009 | impossible array/byte count, payload out-of-bounds, nesting overflow | ImpossibleCount, OutOfBounds, or NestingDepthExceeded before allocation |
| MS-RED-010 | valid payload plus one trailing byte | TrailingData / PayloadDecode at end |
| MS-RED-011 | trailing byte paired independently with earlier ordinal/presence/hash/StateInputHash contradiction | TrailingData wins in every pair |
| MS-RED-012 | valid physical payload plus local semantic error plus declared RecordId mismatch | local semantic error wins; with semantics fixed RecordIdMismatch wins |

### 13.2 Global sequence, identity, and layout rows

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-020 | for every index, ordinal `< index` | DuplicateOrdinal at GlobalSchema sequence field |
| MS-RED-021 | for every index, ordinal `> index` | OrdinalGap at GlobalSchema sequence field |
| MS-RED-022 | same GlobalKey and otherwise equal non-ordinal content at distinct valid ordinals | DuplicateKey after ordinal validation |
| MS-RED-023 | same GlobalKey with each other field independently changed | ConflictingKey after ordinal validation |
| MS-RED-024 | zero GlobalKey | ZeroStableKey |
| MS-RED-025 | mutate each fingerprint input independently but retain old fingerprint | DerivedHashMismatch at StorageLayoutFingerprint |
| MS-RED-026 | mutate only stored fingerprint | DerivedHashMismatch at StorageLayoutFingerprint |
| MS-RED-027 | graph omits each interface global in turn | GlobalCoverageMismatch / ModuleGraph |
| MS-RED-028 | graph adds undeclared state global | GlobalCoverageMismatch / ModuleGraph |
| MS-RED-029 | for a matched key, independently change namespace, name, deep type, or one trait bit | GlobalCoverageMismatch / ModuleGraph |
| MS-RED-030 | two ModuleState globals claim one declaration authority under different keys/names | GlobalCoverageMismatch / ModuleGraph |

### 13.3 Exhaustive initialization/coverage rows

Build `C,U,E,D in {0,1,2}` for each initialization kind, where C is owned
GlobalConstant count, U is owned InitializerUnit count, E is matching
ExecuteInitializer action count, and D is matching DefaultConstructGlobal
action count. Accept only `(Default,0,0,0,Drequired)`,
`(PureConstant,1,0,0,0)`, and `(VmInitializer,0,1,1,0)`, where Drequired is one
iff cleanup is DestroyValue and otherwise zero. Every other tuple is RED.

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-040 | every invalid `(kind,C,U,E,D)` tuple after local duplicate-free construction | InvalidPresence locally when internal unit/action coverage is decidable, otherwise GlobalCoverageMismatch / ModuleGraph |
| MS-RED-041 | PureConstant without Const declaration trait | GlobalCoverageMismatch |
| MS-RED-042 | Default with a GlobalInitializer declaration/unit/action | exact local coverage error before graph declaration error when unit/action is present; otherwise MissingCoverage |
| MS-RED-043 | VmInitializer with unit/action but no declaration | UndeclaredEntity |
| MS-RED-044 | Global initializer targets a different valid global | InitializerOwnershipMismatch |
| MS-RED-045 | Global initializer targets Default or PureConstant global | GlobalCoverageMismatch |
| MS-RED-046 | initializer declaration owner/global entity disagrees with unit or Execute action | InitializerOwnershipMismatch |
| MS-RED-047 | initializer key linked as FunctionBody | UnexpectedRecord |

### 13.4 Exhaustive cleanup-policy rows

For every row below, enumerate cleanup byte `{1=None,2=DestroyValue,
3=ReleaseHandle}`. The one accepted policy is GREEN; each other valid byte is
RED `InvalidPresence` locally when the category is locally decidable.

| RED family | Type category | Accepted policy / forged result |
|---|---|---|
| MS-RED-050 | every non-void primitive token Bool..Float64, no reference | None; Destroy/Release invalid locally |
| MS-RED-051 | same eleven non-void primitive tokens with Reference | no accepted wire row; producer NotCacheable, forged row InvalidPresence |
| MS-RED-052 | Primitive Void with every qualifier/policy | no accepted row; InvalidPresence |
| MS-RED-053 | Auto with every policy | no accepted row; InvalidPresence |
| MS-RED-054 | ScriptType/EnvironmentType ObjectHandle, including const-handle variants | locally one of three; graph/current accepts ReleaseHandle only for resolved reference/ReferenceCounted and rejects a handle on value/trivial kinds |
| MS-RED-055 | EnvironmentType crossed with ValueStorageKind Trivial/OwningValue/ReferenceCounted | exact None/DestroyValue/ReleaseHandle mapping; missing/Invalid category and every mismatch fail closed before attach |
| MS-RED-056 | non-handle ScriptType resolved to Enum | only None; Destroy fails GlobalCoverageMismatch, Release invalid locally |
| MS-RED-057 | ScriptType resolved to Struct/Delegate | only DestroyValue; None/Release fail GlobalCoverageMismatch |
| MS-RED-058 | ScriptType resolved to Class/Interface/Funcdef | only ReleaseHandle, including implicit reference semantic; None/Destroy fail GlobalCoverageMismatch |
| MS-RED-058A | primitive-only Typedef | only None; every other policy fails graph equality |
| MS-RED-058B | unresolved ScriptType or non-primitive Typedef | producer NotCacheable; forged row GlobalCoverageMismatch |
| MS-RED-059 | any Script/Environment type with Reference, with/without Handle | no accepted row; InvalidPresence |

For every cacheable type category, cross its accepted cleanup with all three
initialization kinds and apply section 4.3: PureConstant is GREEN only for
primitive/enum + None; all object/handle PureConstant combinations are RED.

### 13.5 Exhaustive CanonicalValue rows

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-060 | for each of 11 non-void primitive tokens, every one of six ValueKinds except its required kind | InvalidPresence |
| MS-RED-061 | for Int/UInt widths 1/2/4/8, byte count one smaller and one larger | InvalidPresence |
| MS-RED-061A | freeze byte-array count prefix at exact inherited 64-bit little-endian width; mutate high count word | correct u64 golden or ImpossibleCount/OutOfBounds before allocation; never a u32 decode |
| MS-RED-062 | Bool bytes `{02,7f,ff}` and counts `{0,2}` | InvalidPresence |
| MS-RED-063 | Float32 counts `{0,1,3,5,8}`; Float64 counts `{0,1,4,7,9}` | InvalidPresence |
| MS-RED-064 | Float32/64 `+0,-0,+inf,-inf,subnormal,qNaN,sNaN` payload mutation while retaining old hard hash | DerivedHashMismatch; separate GREEN proves exact preservation |
| MS-RED-065 | EnumInt32 count not 4 | InvalidPresence |
| MS-RED-066 | EnumInt32 declared as primitive, environment, or non-enum ScriptType | InvalidPresence when local; otherwise GlobalCoverageMismatch in graph |
| MS-RED-067 | Primitive Void, Auto, object, handle, reference, subtype/container with each ValueKind | InvalidPresence |
| MS-RED-068 | CanonicalValue on EnumAuthority | InvalidPresence |
| MS-RED-069 | absent CanonicalValue on GlobalConstant | InvalidPresence |
| MS-RED-070 | CanonicalValue owner global is mutable/Default/VmInitializer | GlobalCoverageMismatch |

Every signed/unsigned width also gets GREEN boundary vectors `00`, all ones,
sign bit only, min, max; these prove no host numeric conversion is involved.

### 13.6 HardValue comparator, authority, and hash rows

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-080 | reverse two distinct HardValue authorities in raw payload | NonCanonicalOrder |
| MS-RED-081 | equal authority/equal content twice | DuplicateKey |
| MS-RED-082 | equal authority with each of ExpectedAbi, Type, optional/value, hash independently changed | ConflictingKey |
| MS-RED-083 | GlobalConstant owner kind each value except ScriptGlobal | WrongReferenceKind |
| MS-RED-084 | EnumAuthority owner kind each value except ScriptType | WrongReferenceKind |
| MS-RED-085 | zero owner key/required ABI | ZeroStableKey or MissingExpectedAbi |
| MS-RED-086 | mutate GlobalConstant kind/owner/type/value but retain old hash | DerivedHashMismatch locally |
| MS-RED-087 | GlobalConstant owner key or deep Type differs matching global declaration | GlobalCoverageMismatch |
| MS-RED-087A | GlobalConstant Owner.ExpectedAbi differs matching global declaration ABI | GraphAbiMismatch |
| MS-RED-088 | for each local enum omit authority | EnumAuthorityMismatch |
| MS-RED-089 | add authority for non-enum/external/undeclared type | EnumAuthorityMismatch |
| MS-RED-090 | mutate enum name/value/ordinal/metadata in TypeSchema while retaining authority | EnumAuthorityMismatch |
| MS-RED-091 | two enum authorities for one local enum that evade local authority only via forged different key | EnumAuthorityMismatch |

### 13.7 Initializer unit/action, dependency, and opaque rows

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-100 | action ordinal `< index` / `> index` | DuplicateOrdinal / OrdinalGap |
| MS-RED-101 | Global unit owner absent; Module unit owner present | InvalidPresence |
| MS-RED-102 | zero InitializerKey, zero present OwnerGlobal, or zero action target | ZeroStableKey |
| MS-RED-103 | repeated InitializerKey equal/different content; reverse canonical unit order | DuplicateKey / ConflictingKey / NonCanonicalOrder |
| MS-RED-103A | repeated action target equal/different kind or dependencies | DuplicateKey / ConflictingKey |
| MS-RED-104 | mutate ModuleKey, Profile, key, codec, or payload but keep execution hash | DerivedHashMismatch locally |
| MS-RED-105 | empty payload with fixture codec | OpaquePayloadMalformed, not local InvalidPresence |
| MS-RED-106 | codec versions `{0,unsupported-high}` | UnsupportedCodecVersion from injected validator |
| MS-RED-107 | codec returns wrong validated hash | OpaquePayloadHashMismatch |
| MS-RED-108 | codec returns nonempty ExactDebugSources | OpaquePayloadMalformed |
| MS-RED-109 | relocation missing exact action dependency or differing kind/ref/key/ABI/presence/content | RelocationDependencyMismatch for every coordinate mutation |
| MS-RED-110 | duplicate relocation coordinate or noncanonical coordinate order | OpaquePayloadMalformed |
| MS-RED-111 | CanonicalName/StringLiteral owned bytes missing/extra/duplicate/conflicting, nonzero ABI, wrong domain key, or an owned row with no relocation | OpaquePayloadMalformed at fixed opaque precedence |
| MS-RED-111A | CanonicalName/StringLiteral relocation has no exact dependency-coordinate match | RelocationDependencyMismatch |
| MS-RED-112 | local Initializer dependency targets same/later action ordinal | InitializerOwnershipMismatch |
| MS-RED-112A | local action authority targeted through Declaration/another kind instead of Initializer; Initializer targets ordinary non-action function/global | InitializerOwnershipMismatch or UnexpectedRecord |
| MS-RED-113 | local Initializer dependency content differs target action content coordinate | InitializerOwnershipMismatch |
| MS-RED-114 | action dependency duplicate authority equal/different, reverse canonical rows, wrong target kind, missing required derived row, or unrelated extra row | DuplicateKey / ConflictingKey / NonCanonicalOrder / MissingCoverage / UnexpectedRecord |
| MS-RED-115 | two distinct Module initializer units/declarations/actions | InitializerOwnershipMismatch |
| MS-RED-116 | every declaration/unit/Execute-action cardinality tuple other than 0/0/0 and same-key 1/1/1 | exact UndeclaredEntity / MissingCoverage / InitializerOwnershipMismatch |
| MS-RED-117 | malformed reachable initializer plus wrong owner | opaque error wins before InitializerOwnershipMismatch |
| MS-RED-118 | unrelated malformed state/token not reachable from requested snapshot | zero codec calls; no failure from unrelated token |
| MS-RED-119 | two malformed reachable initializers in reversed caller-pool insertion orders | first Execute action's opaque error always wins; first called once, every later action zero calls |
| MS-RED-119A | compiler order `VmInitializer(primitive) -> DefaultConstructGlobal(value)` versus reversed action order | only captured dependency-solved order is GREEN; reverse changes StateInputHash and fails the fixed golden |
| MS-RED-119B | Default DestroyValue global missing/duplicate DefaultConstruct action; None/Release global with such action | local coverage mismatch |
| MS-RED-119C | execute action missing unit, unit missing execute action, Global unit targets wrong VmInitializer global | local coverage/InitializerOwnershipMismatch |


### 13.8 Post-init rows

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-120 | post-init ordinal `< index` / `> index` | DuplicateOrdinal / OrdinalGap |
| MS-RED-121 | reference kind every value except ScriptFunction | WrongReferenceKind |
| MS-RED-122 | zero key/ABI | ZeroStableKey / MissingExpectedAbi |
| MS-RED-123 | same key/equal ABI; same key/different ABI | DuplicateKey / ConflictingKey |
| MS-RED-124 | key not declared in same module | UndeclaredEntity |
| MS-RED-125 | key resolves to method/initializer/delegate/import/property, abstract global, or BodyCoverage Forbidden global | WrongReferenceKind or MissingCoverage using the frozen graph order |
| MS-RED-126 | key resolves to global function with parameters | WrongReferenceKind |
| MS-RED-127 | ExpectedAbi differs declaration | GraphAbiMismatch |
| MS-RED-128 | matching required FunctionBody absent/extra | normal FunctionBody MissingCoverage/UnexpectedRecord in graph step 7 |
| MS-RED-129 | initializer declaration independently mutates parameter, return, TraitFlags, ReflectionFlags, identity flags, metadata, slot, or BodyCoverage | InitializerOwnershipMismatch before current eligibility |

### 13.9 StateInputHash, budgets, graph/current precedence rows

The following table is the exhaustive V1 allocation-family inventory for local
ModuleState decode and its portion of per-module graph validation. Every
concrete allocation site MUST map to exactly one row. A later implementation
that adds a container/site also adds a row and parameterized exact-limit test;
the generic cumulative-budget RED is not a substitute.

| Allocation family ID | Simultaneously live container/index family | Lifetime and budget ownership | Required parameterized RED |
|---|---|---|---|
| MS-SCR-01 | decoded GlobalSchema strings/types/metadata, OrderedGlobals storage, flat token/header offsets, and parallel global/nested captured-offset capacity | decoded token retained/persistent | exact allocator-capacity bytes before grow; one-byte-short/no allocation |
| MS-SCR-02 | HardValue/CanonicalValue bytes, InitializerUnit payload bytes, action/post-init/dependency DTO arrays, and their parallel captured-offset capacity | decoded token retained/persistent | each nested array/byte/offset family exact limit and one-byte-short |
| MS-SCR-03 | local GlobalKey uniqueness index | local-decode temporary RAII scratch | empty/one/many exact limit, one-byte-short, release on every exit |
| MS-SCR-04 | HardValue authority groups and duplicate/conflict index | local-decode temporary RAII scratch | each authority group and competing group exact capacity |
| MS-SCR-05 | InitializerKey uniqueness index | local-decode temporary RAII scratch | empty/one/many exact capacity |
| MS-SCR-06 | action-target/ordinal authority plus local action-edge lookup | local-decode temporary RAII scratch | Default/Execute mix, duplicate target, forward/cycle cases |
| MS-SCR-07 | per-action dependency authority/index | local-decode temporary RAII scratch, one live action at a time unless implementation retains more | first/middle/last and maximum-dependency action |
| MS-SCR-08 | PostInit target uniqueness index | local-decode temporary RAII scratch | empty/one/many exact capacity |
| MS-SCR-09 | top-level ModuleState dependency authority/index | local-decode temporary RAII scratch | all dependency kinds, exact capacity |
| MS-SCR-10 | full RecordId/hash-to-token lookup index for the caller pool | graph-call temporary RAII scratch | one requested plus unrelated records, exact capacity |
| MS-SCR-11 | reachability visited set and work queue/stack | graph-call temporary RAII scratch; both capacities count concurrently | deep chain, wide fan-out, duplicate edge; exact combined capacity |
| MS-SCR-12 | ModuleInterface declaration/owner/function/global indexes | graph-call temporary RAII scratch | each index independently exact and combined-live limit |
| MS-SCR-13 | ModuleState global, InitializerUnit, action-target, post-init, and action-edge indexes | graph-call temporary RAII scratch | every index independently exact and combined-live limit |
| MS-SCR-14 | linked TypeSchema/type-kind/enum-authority lookup indexes used by cleanup and enum closure | graph-call temporary RAII scratch | Class/Struct/Delegate/Enum/Typedef mix and exact capacity |
| MS-SCR-15 | FunctionBody/debug-owner indexes consulted for forbidden initializer bodies and post-init coverage | graph-call temporary RAII scratch | missing/extra/shared owner and exact capacity |
| MS-SCR-16 | exact schema/body/global/declaration-unit-action/post-init/enum coverage comparison sets | graph-call temporary RAII scratch; every simultaneously live set is summed | one missing, one extra, and equal maximum-size sets |
| MS-SCR-17 | temporary opaque-summary owner map plus candidate-graph summary DTO array | owner map is graph-call RAII scratch; summary DTO array is candidate scratch until atomic publish, then retained/persistent; combined with all active graph scratch | zero/one/many summaries, duplicate-owner lookup, and publish/failure boundaries |
| MS-SCR-18 | each opaque summary's relocation array, debug-source array, and owned-byte rows | candidate scratch after codec success, live concurrently with summary DTO/output tables; atomically promoted to retained/persistent only at step 11; released as scratch on every pre-publication failure | each family and all-three combined exact capacity |
| MS-SCR-19 | relocation-coordinate matching index | graph-call temporary RAII scratch while summary rows remain resident | empty/one/many/duplicate/mismatch exact capacity |
| MS-SCR-20 | owned-byte authority index | graph-call temporary RAII scratch while owned rows remain resident | missing/extra/duplicate/conflict exact capacity |
| MS-SCR-21 | candidate/output `ReachableRecords` shared-handle array; sorted RecordId, type, global, function, initializer, and opaque-owner published view/index arrays | candidate scratch plus monotonic total-decoded charge before allocation; atomically promoted to retained resident at publish; token/control/DTO bytes are not charged again | each output array independently and all concurrently at exact allocator capacity/one-byte-short; publish success, late failure, input destruction, and unrelated-handle non-retention |

“Exact capacity” means allocator capacity/allocated bytes, not merely logical
element count times `sizeof(T)`. The implementation either reserves the proven
capacity before the first insertion and charges that capacity, or charges each
growth before it occurs. Failed reserve/growth is side-effect-free. Temporary
RAII reservations release on every success/failure path; decoded/candidate
retained bytes remain charged and are included with still-active scratch.
Remaining-record tokens use the sole thread-safe shared immutable handle frozen
by `record-wire-v1-remaining.md`. The token/control/DTO allocation is charged
once by its factory. The candidate graph copies handles only for reachable
records; handle copies allocate nothing. Validation-only MS-SCR-10..16/19/20
indexes are never published. MS-SCR-21 is the exhaustive retained graph surface:
all of its arrays use record/item ordinals rather than borrowed DTO pointers.
Before allocation, candidate bytes consume monotonic total-decoded budget and
active live-resident scratch. `PromoteToRetained()` atomically reclassifies
those same bytes at step 11 without double charging; late failure releases the
scratch portion but never refunds total-decoded consumption.

The private ModuleState captured-offset table is not a new MS-SCR family. Its
parallel arrays belong to MS-SCR-01/02 beside the DTO arrays they describe and
must be present in the same exact-capacity/one-byte-short oracle. The flat
token/header offset block belongs to MS-SCR-01. Omitting those capacities is a
failed exhaustive-budget implementation.

| RED ID | Mutation family | Expected first failure |
|---|---|---|
| MS-RED-130 | independently mutate every stream field in section 10 while retaining StateInputHash and recomputing earlier nested hashes where necessary | DerivedHashMismatch at StateInputHash |
| MS-RED-131 | reverse HardValues or either dependency set and recompute StateInputHash | NonCanonicalOrder before hash acceptance |
| MS-RED-132 | change only StateInputHash | DerivedHashMismatch |
| MS-RED-133 | limits fail before globals/hard values/initializer payload/dependencies allocation | BudgetExceeded; output empty; allocation counter unchanged |
| MS-RED-134 | shared budget fits each record alone but not full graph/opaque summary | BudgetExceeded; no budget reset/retry |
| MS-RED-134A | parameterize every MS-SCR-01..21 family above at exact allocator capacity and one-byte-short, both independently and at every stated simultaneous-lifetime combination | exact limit succeeds; short fails before allocation/growth; allocation counter and prior active reservation remain unchanged on failed reserve |
| MS-RED-134B | every success, early decode error, duplicate/conflict/order error, late hash error, opaque failure, graph failure, and current miss with an active scratch reservation | temporary resident bytes return to the entry value; monotonic persistent counters are never refunded |
| MS-RED-134C | retained decoded tokens plus active graph/codec scratch use one Budget | combined resident limit enforced; no Reset/retry/new Budget may make the graph fit |
| MS-RED-134D | candidate output tables at exact capacity; one-byte-short; successful publish; failure after all MS-SCR-17 summary DTO plus MS-SCR-18 nested capacities and all tables exist; caller input array destroyed; unrelated handle lifetime probe | short fails before candidate allocation; success promotes each byte exactly once and remains readable; late failure leaves OutGraph empty and scratch at entry; reachable records survive input destruction; unrelated reference count/lifetime is unchanged |
| MS-RED-135 | state profile differs body/sidecar profile but initializer codec is valid | ProfileGraphMismatch after opaque validation |
| MS-RED-136 | state profile differs selected current profile, immutable graph self-consistent | ProfileMismatch / CurrentResolver stage; zero symbol calls before source/profile checks finish |
| MS-RED-137 | immutable ABI contradiction plus current resolver miss | GraphAbiMismatch wins; resolver not called for contradictory graph |
| MS-RED-138 | self-consistent dependency current result missing | CurrentSymbolMissing |
| MS-RED-138A | valid immutable EnvironmentType global with missing/Invalid/mismatched CurrentValueStorageKind | no resolver call before step 10; CurrentAbiMismatch / Ineligible there |
| MS-RED-138B | immutable ScriptType/global cleanup contradiction plus a later EnvironmentType current-storage mismatch | GlobalCoverageMismatch wins in step 5; current resolver call count remains zero |
| MS-RED-139 | current ABI differs | CurrentAbiMismatch before content check |
| MS-RED-140 | ABI equal, required current content absent/different | CurrentContentMismatch |
| MS-RED-141 | any failure after a previously valid OutGraph value | OutGraph reset/empty; no partial globals/initializer summaries published |

## 14. Required GREEN/golden complements

The RED matrix is only meaningful with these fixed positive controls:

1. one empty ModuleState full payload, RecordId, and complete envelope golden;
2. one nonempty full golden containing Default/PureConstant/VmInitializer
   globals, primitive and enum constants, GlobalConstant and EnumAuthority,
   global plus module initializer units, an action sequence that interleaves
   DefaultConstructGlobal and ExecuteInitializer, post-init, both dependency
   scopes, and every derived hash;
3. byte-goldens for every scalar width, Bool `00/01`, signed/unsigned boundaries,
   Float32/64 `+0/-0/NaN payload`, and EnumInt32 negative/alias values;
4. forward/reverse insertion equality for HardValues, Initializers, and every
   dependency set, while semantic action/post-init order remains byte-distinct;
5. a dependency-solved action order that differs from StorageOrdinal and places
   a primitive VmInitializer before a complex DefaultConstructGlobal;
6. zero and one module initializer, zero and multiple post-init functions;
7. exact-once reachable initializer codec calls in Execute action order, fail-
   fast two-error call counts, and zero calls for an unrelated state;
8. failure/release cleanup-stack simulation proving exact reverse action-attempt
   order and one cleanup per non-None global without a persisted initialized bit;
9. ScriptType Class/Interface/Funcdef, Struct/Delegate, Enum/Typedef and every
   environment ValueStorageKind cleanup positive row.

## 15. Implementation consequences, after authority approval

This matrix requires the later implementation to:

- add ModuleState enums/DTO/archive in dedicated record files, reusing the
  existing common canonical reader/writer and dependency comparator;
- not place ModuleState code into the legacy StaticJIT archive;
- add only the four fixed hash helpers, with no generic `Ar <<` or raw VM blob
  access outside `CanonicalExecutionPayload`;
- add graph indexes keyed by full 256-bit global/type/function keys so coverage
  and dependencies are O(N+E+R), never nested whole-pool scans;
- preserve existing Task 2B-1 bytes where their inputs remain zero/unchanged;
  the separately reopened common declaration owner/reflected-function additions
  require their own new goldens and approval before this matrix can pass;
- use the deterministic `UEASOPQ1` fixture only in pure tests; live AS codec and
  attachment are later tasks;
- make live capture fail the whole module snapshot as NotCacheable when a global
  ownership/default/initializer dependency cannot be represented; never emit a
  partial state and never fall back to legacy record semantics inside Cache V2.

## 16. Consistency checklist for this matrix

- [x] No old cache field is treated as normative solely because it exists.
- [x] ModuleState field order is frozen here; the compact remaining-wire summary
  must be reconciled to the Initializers + OrderedInitializationActions split.
- [x] No lifetime blob, initialized bit, mutable value, raw pointer/id/offset,
  direct initializer RecordId, or FunctionBody link was introduced.
- [x] Profile exists only on ModuleState/opaque execution coordinates, not on
  ModuleInterface or TypeSchema.
- [x] GlobalConstant is locally recomputable; EnumAuthority has one external
  TypeSchema authority and no duplicated enum table.
- [x] Primitive widths cover every current canonical primitive token and preserve
  float bits exactly.
- [x] Initialization action, cleanup, owner optional, module initializer, and
  executable post-init cardinalities each have one accepted predicate.
- [x] HardValue and dependency comparators separate authority from content so an
  ABI/value mutation cannot create a second valid authority.
- [x] Local decode does not call a VM codec; graph step 1 follows Execute action
  order, calls each reachable unit exactly once, and fails fast deterministically.
- [x] Opaque errors precede ownership/coverage; immutable contradictions precede
  current eligibility.
- [x] One caller-owned budget remains monotonic through record, live-resident
  scratch, codec, and graph with exact-limit/no-allocation/release RED rows.
- [x] Every failure leaves local/summary/graph output empty.
- [x] OQ-MS-01..12 are ratified as the single V1 predicates above; Task 2B-2
  still waits for the explicit independent matrix approval gate.
