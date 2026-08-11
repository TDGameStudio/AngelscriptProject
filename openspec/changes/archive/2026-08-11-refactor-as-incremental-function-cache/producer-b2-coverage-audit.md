# TypeSchema normal-producer B2 coverage audit

Date: 2026-08-09 (Asia/Shanghai)

This is a non-normative implementation attachment for B2. Frozen semantics remain
owned by `type-layout-authority-v1.md`, `type-schema-matrix-v1.md` and
`record-wire-v1-remaining.md`.

Audited candidate:
`Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`

Start/end SHA-256:
`183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`.
The independent audit was read-only and changed no file.

## 1. Evidence boundary

B2 counts a scenario only when the behavior under test enters through:

```cpp
FAngelscriptCacheTypeSchemaArchive::SerializeTypeSchema(
    const FAngelscriptCachedTypeSchema&,
    TArray<uint8>&);
```

The following are not normal-producer B2 evidence:

- `SerializeTypeSchemaPhysicalForTests` as the behavior oracle;
- `DecodePhysicalOnlyFixture` or another `TryDecode` path;
- raw-byte patching, captured byte offsets or the independent wire scanner;
- trailing-data, one-byte truncation or invalid physical tag cases;
- ModuleSnapshot graph validation;
- current symbol/layout resolvers or resolved entity/owner/ABI checks; and
- a missing header, unresolved symbol, crash, check or stale binary.

The guarded physical writer may remain an observation tool for a before/after
snapshot proving that a const input DTO was not mutated. It cannot decide whether
that DTO is semantically legal or what error the normal producer should return.

At the audited SHA the file contains roughly 48 normal `SerializeTypeSchema`
calls, 18 physical-writer calls and 84 `DecodePhysicalOnlyFixture` calls. Many
normal calls only prepare valid payloads for other tests. Consequently broad
TypeSchema coverage is not equivalent to exhaustive normal-producer coverage.

## 2. B1 coverage that is accepted

`NormalProducerRejectsCanonicalLocalSemanticViolationsAtomically` has 33 direct
normal-producer failures through
`ExpectExactProducerFailureAndInputUnchanged`; the kind-payload test has two more
inactive-arm producer failures.

The 33 representative rows cover:

1. duplicate and conflicting LayoutInput singleton keys;
2. direct-interface ordinal gap;
3. Struct with a forbidden Base relation;
4. terminal layout size replay;
5. non-power-of-two layout alignment;
6. a boundary without an authority;
7. property byte-offset replay;
8. unknown property storage and member-access enums;
9. property flag implication and forbidden NetGroup;
10. property, method, VFT, behavior, reflected-member and enum ordinal gaps;
11. method/VFT role and owner errors;
12. behavior owner/presence and forbidden TemplateCallback;
13. the IC-144 unknown TypeSemanticFlags high bit;
14. missing Class ReferenceType and `Abstract|Final`;
15. present-empty ConfigName and empty StaticsClass member list;
16. wrong reflected-UFunction reference kind;
17. duplicate enum name; and
18. missing and extra derived dependencies.

The unified failed-producer tuple is:

```text
Error      = explicit per-case value
Class      = Classify(Error)
RecordKind = TypeSchema
Stage      = None
ByteOffset = 0
OutPayload = empty
Input DTO  = physically unchanged before/after
```

This is sufficient for B1 representative spanning. It is not the “every
canonical-local obligation” closure required by B2.

## 3. Existing exhaustive tests that do not close B2

The candidate already has detailed decoder/physical matrices for:

- all raw enums/booleans/optional tags and unknown bits;
- TypeSemanticFlags and ClassReflectionFlags;
- relations and direct-interface ordering;
- LayoutInput role/presence/target rules;
- property storage, datatype, qualifiers, flags, replication and replay;
- method/VFT roles and owners;
- all 17 behavior kinds;
- enum/typedef/funcdef cases;
- physical/local/hash precedence and captured coordinates; and
- allocation Budget/fault/probe chronology.

Those prove decoder error stage/offset/precedence. They do not prove that an
invalid source DTO fails before the normal producer emits bytes with the inactive
producer coordinate.

## 4. Missing normal-producer obligation groups

### 4.1 Header, identity, strings and metadata

Add exact producer cases for:

- unsupported payload schema;
- zero ModuleKey and TypeKey;
- invalid/out-of-range TypeKind;
- empty required canonical name/declaration;
- embedded NUL and invalid/unpaired Unicode scalar;
- duplicate metadata key/value and same key with conflicting value; and
- successful canonicalization of unique unordered top-level, property and enum
  metadata without mutating the caller DTO.

Producer set-like inputs are allowed to arrive unordered and must serialize to
canonical bytes. `NonCanonicalOrder` applies only to sequence-semantic fields.

### 4.2 TypeSemanticFlags closed predicates

For each of the seven TypeKinds, add explicit witnesses for every independent
required, allowed and forbidden known bit, plus:

- an unknown bit;
- `ValueType|ReferenceType` conflict;
- legal/illegal `Shared` forms;
- `Abstract|Final`; and
- locally visible `HasDefaultConstructor=true` necessary group presence plus
  complete `HasDestructor` bidirectionality for Class, Struct and Delegate.

`HasDefaultConstructor=false` with opaque Construct rows is a local success: the
DTO has no parameter/default signature. Unique zero-parameter constructor and
corresponding Class Factory truth belongs to ModuleSnapshot graph. The three
approved Slice-1 reverse producer rows and the retained decoder reverse test must
be repaired before Slice 5 becomes authority.

B2 need not duplicate the decoder's brute-force `0..0xff` oracle. It must provide
one explicit normal-producer case for every distinct frozen rule and must not use
`IsExpectedTypeSemanticFlagMaskValid` to calculate expectations.

### 4.3 KindPayload, callable, enum and typedef

Cover the complete seven-kind selected/inactive-arm presence matrix, including
missing selected arms and every illegal extra arm. Add:

- callable zero signature key and missing signature ABI;
- `Funcdef.bMulticast=true` with exact
  `InvalidQualifierCombination` (IC-146); current producer returns
  `InvalidBoolean`;
- Typedef restricted to an unqualified primitive, rejecting Void, Auto, object,
  handle, reference and nonempty subtype arrays;
- enum duplicate ordinal, empty name, metadata duplicate/conflict, numeric alias,
  signed `MIN_int32`/`MAX_int32`, and stale EnumAuthorityHash; and
- successful canonicalization of unordered unique enum metadata.

An out-of-range signed enum value cannot be represented by the `int32` DTO and
must not be invented as a producer test.

### 4.4 Relations

Add explicit normal-producer rows for:

- unknown RelationKind;
- missing/extra semantic ordinal, gap, duplicate and sequence reorder;
- duplicate identical target and same singleton kind with a different target;
- self-reference;
- zero key, missing ExpectedAbi and locally wrong ReferenceKind;
- every legal form × relation kind local presence/cardinality rule; and
- every forbidden form, including the always-forbidden Compose relation.

Resolved target TypeKind/entity, module owner, code-root equality, resolved ABI and
interface closure remain ModuleGraph obligations.

### 4.5 LayoutInputs and relation pairing

Cover:

- unknown InputKind;
- wrong target kind, zero key and missing ExpectedAbi;
- missing, extra and wrong-role input;
- exact optional masks for BaseType, root/derived CodeRoot and StructHeader;
- present-zero boundary as distinct from absence;
- zero/non-power-of-two alignment;
- boundary/alignment above `INT32_MAX`;
- pairing with the locally authoritative relation/input role; two individually
  valid target tuples that disagree return literal `InvalidQualifierCombination`;
- stale LayoutInputHash; and
- successful canonicalization of unique unordered inputs.

Expected errors include `UnknownEnumValue`, `InvalidPresence`, `WrongReferenceKind`,
`ZeroStableKey`, `MissingExpectedAbi`, `InvalidQualifierCombination`, `Overflow`
and `DerivedHashMismatch` as frozen per row.

### 4.6 Layout scalar and immutable replay

Add positive normalized layouts for StaticsClass, Interface, Enum, Typedef,
Funcdef and empty Class/Struct/Delegate. Add failures for:

- zero or below-minimum alignment;
- alignment below a property/base/code-root contribution or not equal to the
  exact maximum;
- boundary above size;
- offset below boundary, unaligned, overlapping or aligned-but-not-exact cursor;
- missing terminal tail padding;
- property end/AlignUp/u32/int32 overflow; and
- different property offsets that preserve the same terminal size.

### 4.7 Properties

Cover every owner-form presence rule and independent obligation for:

- ordinal gap/duplicate/reorder and empty name;
- CanonicalDataType validity;
- StorageKind × datatype/qualifier allowlist;
- zero/invalid/overflowing size and alignment;
- InlineValue/ObjectHandle qualifier mismatches;
- Auto/Void/Reference/unresolved/Funcdef rejection;
- all property flag implications and owner allowlists;
- replication, RepNotify/ReplicatedUsing, SkipReplication and condition rules;
- duplicate/conflicting property metadata; and
- legal StorageLayoutHash/PropertyLayoutFingerprint regeneration plus unequal
  fingerprints for self-consistent layouts that share a terminal size.

Stale property hashes are not repeated here. Section 4.12 is the whole-B2
exactly-once stored-hash inventory: Slice 2 owns EnumAuthorityHash, Slice 3 owns
LayoutInputHash, and Slice 6 owns StorageLayoutHash,
PropertyLayoutFingerprint and final TypeLayoutHash.

Type-sensitive live UE property capability remains eligibility/current-environment
work and must not be guessed from names in the producer validator.

### 4.8 OrderedMethods and VFT

Treat the two sequences independently. Add rows for:

- per-form presence;
- zero function key and missing ABI;
- ordinal gap/duplicate/reorder;
- duplicate FunctionKey inside each sequence, always `DuplicateKey` even when the
  second valid-ordinal row changes owner or ABI;
- exact allowed MethodEntry and VFT slot kinds;
- forbidden member/VFT forms; and
- required nonzero owner keys and locally knowable self/nonself role predicates.

The same FunctionKey appearing in different roles may be a legal positive. Exact
declaration entity, inherited suffix, ancestor slot and signature compatibility
remain graph obligations.

### 4.9 Behaviors

Cover all 17 local BehaviorKinds with:

- one empty-array baseline per actual legal TypeKind/reflection form, including
  StaticsClass, with no hypothetical Kind/target/owner coordinate;
- nonempty TypeKind/form presence/cardinality using only represented rows;
- group order, ordinal gap and duplicate;
- singleton duplication;
- target reference kind/key/ABI;
- Script owner present/nonzero and Environment owner absent; self and nonself
  nonzero Script owners are local positives pending graph validation;
- Class Construct/Factory count and script Copy alias rules;
- Struct/Delegate Factory rejection;
- local `HasDefaultConstructor=true` necessary group conditions and complete local
  `HasDestructor` bidirectionality;
- script CopyConstruct/CopyFactory alias requirements; and
- environment CopyConstruct/CopyFactory independent positives.

Include explicit positive rows for Copy=15, CopyConstruct=16 and CopyFactory=17.
Entity kind, actual owner/module, parameters/defaults, zero/one/two zero-parameter
constructor cases, compatible opAssign and resolved declaration ABI stay in
ModuleGraph. Do not use the old `17 x 7 x {empty,...}` dynamic Cartesian:
cardinality-zero generated 952 calls whose byte-identical empty DTOs were assigned
different expectations from unencoded loop variables. Every producer expectation
must be a literal represented-coordinate partition.

Behavior first-error rows freeze the shared phase order: active target key/ABI and
present Script owner value; ordinal duplicate/gap/order; allowed target arm and
optional tag; then form/count/alias/flag closure. Script present-zero wins
`ZeroStableKey` before an ordinal fault. Script absent and Environment present
(zero or nonzero) lose to ordinal faults and then return `InvalidPresence`; the
inactive Environment owner value is never interpreted.

### 4.10 Reflection

Add normal-producer rows for:

- TypeKind/form × ReflectionKind allowlist and unknown kind;
- unknown and known-but-forbidden ClassReflectionFlags;
- ordinary Abstract and SuperIsCode parity;
- StaticsClass bidirectionality;
- absent/nonempty/empty optional ConfigName and StaticClassGlobalName;
- optional strings or reflected members on a non-UClass form;
- reflected-member ordinal gap/duplicate/reorder, duplicate target, zero key,
  missing ABI and wrong reference kind; and
- ordinary `0..N`, statics `1..N` and zero-flag member positives.

Resolved target entity/owner remains graph validation.

### 4.11 Dependencies

Add normal-producer evidence for:

- successful canonicalization of unique unordered dependencies;
- duplicate coordinate and same coordinate with conflicting ABI/content;
- unknown dependency kind;
- invalid stable references and forbidden ExpectedContent presence;
- the five allowed derived kinds: Inheritance, ValueLayout, Declaration,
  Signature and EnvironmentAbi;
- one positive and one missing case per source family;
- de-duplication/merge across relations, recursive datatypes, methods, VFT,
  reflected functions, behaviors, callable and StructHeader; and
- unsupported extra dependency kinds.

These are normal-producer/local obligations. After field-local Dependency
shape/order/duplicate checks, derive the exact set from the TypeSchema DTO:
missing returns literal `MissingCoverage`, extra returns literal
`UnexpectedRecord`. ModuleGraph tests separately resolve every locally exact
target's existence/entity/owner/module/ABI and record/declaration coverage; they
must not duplicate the DTO-derived set-equality oracle.

### 4.12 Five stored hashes and resolver independence

Normal producer integration must separately reject stale exactly once across B2:

1. LayoutInputHash;
2. StorageLayoutHash;
3. PropertyLayoutFingerprint;
4. EnumAuthorityHash; and
5. TypeLayoutHash.

Ownership is frozen as: approved Slice 3 owns item 1; Slice 6 owns items 2, 3
and 5; approved Slice 2 owns item 4. Slice 6 cites the prior exact-SHA witnesses
instead of duplicating them. Slice 4 may recompute legal property hashes and
compare two legal fingerprints for inequality, but does not submit a stale stored
hash.

Also embed the IC-139 literal LayoutInputHash and EnumAuthorityHash in complete
legal schemas that serialize successfully. Producer errors have no field offset,
so B2 must not add a test-only coordinate API to observe internal hash ordering.

Freeze the exact `SerializeTypeSchema` function signature at compile time and prove
legal unresolved local coordinates serialize without any current resolver:

- external ScriptType Base;
- CodeRoot and StructHeader EnvironmentSymbol;
- external ScriptType InlineValue;
- nested EnvironmentType;
- ScriptType ObjectHandle; and
- locally unresolved Method/Behavior/reflected-function target.

## 5. Scenario-oriented test shape

Keep one CQTest class and one owned test file. Add these eleven methods:

| Method | Scope |
|---|---|
| `NormalProducerCanonicalizesEverySetLikeFieldWithoutMutatingInput` | top/property/enum metadata, relation/input/dependency set ordering, duplicate/conflict |
| `NormalProducerRejectsHeaderStringsAndTypeFlagRulesAtomically` | version, identity, strings, TypeKind and per-kind flags |
| `NormalProducerRejectsKindPayloadEnumCallableAndTypedefRulesAtomically` | union presence, enum, callable, typedef and IC-146 |
| `NormalProducerRejectsRelationRulesAtomically` | relation sections, ordinals, targets, local cardinality |
| `NormalProducerRejectsLayoutInputRolesAndPairingAtomically` | role/form presence, targets, optionals, range, pairing and hash |
| `NormalProducerRejectsPropertyStorageFlagsAndLayoutReplayAtomically` | owner presence, storage/type/qualifier, flags, ordinals, cursor/tail/overflow and legal hash regeneration/inequality |
| `NormalProducerRejectsMethodAndVftSequencesIndependently` | form-independent roles/kinds, ordinals, active keys/owners/ABI, exact duplicate-key/reorder literals; graph reconstruction excluded |
| `NormalProducerRejectsBehaviorGroupsOwnersFlagsAndAliasesAtomically` | represented nonempty coordinates for 17 local kinds, one empty baseline per real form, owner-tag phases, target shape, local cardinality/count/aliases and locally visible flags |
| `NormalProducerRejectsReflectionFormsNamesAndMembersAtomically` | closed forms, flags/parity, optional names and member sequence |
| `NormalProducerRejectsDependencyCoverageAndConflictsAtomically` | canonical dependency set, five derived kinds, merge, missing/extra/conflict |
| `NormalProducerUsesFrozenHashesAndNeverAcceptsResolvers` | IC-139 literals, remaining stale property/type hashes, prior hash-witness citations, signature and legal unresolved coordinates |

Each failure expectation is explicit in the scenario row. Do not calculate it
with a second `IsExpectedProducerSchemaValid` or reuse the decoder's dynamic
`IsExpected*` predicates. Within a method, accumulate all helper results into one
final fatal assertion so the RED run reports every row rather than stopping at the
first mismatch.

## 6. Helpers and ownership

Safe reusable fixture builders include `MakeHash`, `MakeReference`,
`MakePrimitive`, `MakeScriptType`, `MakeDependency`,
`FinalizeValidFixtureHashes`, `MakeCompleteDelegateSchema`, `MakeEnumSchema`,
`MakeMinimalSchema`, the three reflection-form builders, the property-owner/three-
property fixtures and the recursive-property fixture.

Rules for `FinalizeValidFixtureHashes`:

- start from a legal baseline;
- use it to make a non-hash violation self-consistent so the intended local rule is
  the first fault;
- for every representable Slice-5 Method/VFT/Behavior non-hash mutation—including
  raw enum, zero key, missing ABI, wrong target kind and present-zero active Script
  owner—close/sort dependencies as far as the same mutated coordinate permits and
  recompute the final TypeLayoutHash after the mutation;
- never call it after deliberately corrupting the hash under test; and
- never treat helper success as semantic legality evidence.

The finalizer writes raw DTO bytes and hashes; it is not a legality oracle. Do not
use the physical malformed-ordinal rehash helper. Slice 5 owns no stale final-hash
row; the remaining stale TypeLayoutHash witness stays exactly-once in Slice 6.

Reuse `ExpectExactProducerFailureAndInputUnchanged` for negative rows. Its physical
writer calls are before/after const-input snapshots only; the actual result comes
from normal `SerializeTypeSchema`. Add one narrow normal-producer success helper
for canonicalization/positive rows that:

- snapshots input before/after without deciding semantics;
- seeds output, calls normal `SerializeTypeSchema`, and requires exact Success plus
  nonempty bytes;
- optionally compares bytes to an explicitly constructed canonical equivalent;
  and
- proves caller input is unchanged.

Do not create or extend:

- an `IsExpectedProducer*` semantic predicate;
- a second TypeSchema serializer/decoder;
- a test-local expected hash implementation;
- producer field-offset/trace APIs;
- current resolver parameters on the producer; or
- AS engine, UObject, World or disk fixtures for this pure archive layer.

## 7. B2 packet and IC-145 disposition

Allowed source edit:

```text
Plugins/Angelscript/Source/AngelscriptTest/Cache/
  AngelscriptCacheTypeSchemaTests.cpp
```

Runtime Cache, physical writer, decoder/factory, graph, ArtifactIdentity and frozen
authority files are read-only in B2.

Implement in six small authoring slices:

1. helper plus canonicalization/header/flag methods;
2. kind payload/enum/callable/typedef;
3. relations and LayoutInputs;
4. properties and layout replay;
5. methods/VFT and behaviors; and
6. reflection, dependencies, hashes and resolver independence.

After each slice, fresh-compile the complete test TU through `Tools\RunBuild.ps1`
with an exact `-SingleFile` argument. After the sixth slice, freeze SHA/shape,
scan the source diff and obtain an independent exact-SHA review. This produces a
compiled/reviewed B2 candidate, not executed RED.

The audit initially proposed a full module build and focused RED immediately after
authoring. Root-cause evidence IC-145 shows that would fail before Automation on
the C2-owned missing Manifest header and B5–B7-owned unresolved TypeSchema bridge.
Therefore:

- do not run or claim focused B2 RED through that known infrastructure failure;
- do not start B3 production changes before a truthful focused RED is observed;
- progress B4/B5–B7 and real C2 in their existing lanes;
- as soon as both link prerequisites close, run
  `Angelscript.TestModule.Cache.Archive.TypeSchema.NormalProducer` through
  `Tools\RunTests.ps1`;
- require every new method to be discovered and executed, and require failures to
  be returned-result mismatches rather than crash/check/timeout; and
- only then may B2 close and B3 modify the production validator.

## 8. Current disposition

```text
B1 representative producer span:
APPROVED
- 33 normal-producer semantic failures
- 2 inactive-arm producer failures
- exact inactive result tuple
- atomic output clearing
- representative input immutability

B2 every canonical-local producer obligation:
OPEN
- most exhaustive matrices currently drive physical decode only
- set canonicalization is incomplete on the normal producer
- every local matrix is not yet represented by explicit producer rows
- the remaining property/type stored hashes are not yet rejected through normal serialization
- IC-139 literals are not both integrated through complete producer success
- resolver independence is not explicitly frozen at the producer signature
- IC-146 exposes one concrete wrong producer error
```

B3's architectural target is not another producer-only semantic table. The sole
production canonical-local validator established by the TypeSchema decoder work
must be reusable by producer and decoder, with caller-specific error coordinates.
