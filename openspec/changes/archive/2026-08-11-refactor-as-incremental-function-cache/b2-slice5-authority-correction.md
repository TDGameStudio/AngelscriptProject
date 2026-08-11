# B2 Slice 5 authority correction proposal

Date: 2026-08-09 (Asia/Shanghai)

Status: **PROPOSED / HOLD — not yet normative and not a source-edit packet**

## 1. Purpose and immutable boundary

This attachment resolves contradictions found while materializing the B2 Slice 5
normal-producer packet for independent Method/VFT sequences and Behavior groups.
It does not itself amend the frozen normative authorities, authorize source edits,
close B2, claim focused RED or permit B3 Runtime work.

The source frontier remains:

```text
Plugins/Angelscript/Source/AngelscriptTest/Cache/
  AngelscriptCacheTypeSchemaTests.cpp
SHA-256  9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32
blob     0e0c8dcbc06a7b41ac56e679900cd6f4200afcc0
bytes    614741
LF       14005
CR       0
methods  61
final LF yes
```

The production producer remains read-only SHA-256
`DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`.

Frozen inputs under review are `type-layout-authority-v1.md`,
`type-schema-matrix-v1.md`, `record-wire-v1-remaining.md` and the non-normative
`producer-b2-coverage-audit.md`. The exact ready packet must be rematerialized
only after this correction receives an independent 0 Critical / 0 Important
disposition and the corresponding normative text is amended and rereviewed.

## 2. Evidence that forced the hold

`FAngelscriptCachedBehaviorSlot` persists only:

```text
BehaviorKind
SlotOrdinal
Target {ReferenceKind, StableKey, ExpectedAbi}
optional DeclaringOwner TypeKey
```

It has no parameter count, canonical parameter types, in/out modes, default
arguments, return shape or explicit default-constructor marker. Therefore a pure
TypeSchema producer/decoder cannot distinguish one zero-parameter constructor
from one one-parameter constructor, nor determine which Class Factory declaration
corresponds to a zero-parameter Construct.

The existing Behavior Cartesian also executes 952 `Cardinality==0` combinations.
Those combinations add no BehaviorSlot, yet a dynamic predicate consults the
unencoded Kind and target-kind loop variables and assigns byte-identical empty
DTOs different expectations. Its four owner cases are additional identical
repetitions whose expectation is owner-independent at zero cardinality. Absence
carries none of those coordinates.

Independent read-only audit additionally found unresolved exact-error and
validation-order branches for statics arrays, duplicate FunctionKeys, complete-row
reorder, zero owner keys and Behavior owner equality. Source authoring against any
one branch would prematurely make the test file a second semantic authority.

## 3. Proposed unique local-versus-graph split

### 3.1 Method and VFT local ownership

The TypeSchema local producer/decoder owns only facts available in the DTO:

- form-independent row, scalar, ordinal and duplicate validation for each array;
- array presence/cardinality only later in `ReflectionFormClosure` when the rule
  depends on the not-yet-available Reflection discriminator;
- raw `MethodSlotKind` domain;
- role allowlists: Method `{LocalMethod, Inherited}` and VFT
  `{VirtualDeclaration, VirtualOverride, Inherited}`;
- exact independent ordinal domains and stored row order;
- nonzero FunctionKey, DeclaringOwner, ImplementingOwner and declaration ABI;
- local self/nonself shape required by the selected Method/VFT role; and
- duplicate FunctionKey coordinates inside one array.

ModuleSnapshot graph exclusively owns declaration existence/entity, actual owner
and module, nonzero ABI equality, strict ancestor/interface membership, inherited
suffix reconstruction, override elimination, exact VFT ancestor slot and
implementation ownership. A locally admissible unresolved row must serialize
without a current resolver.

### 3.2 Behavior local ownership

The TypeSchema local producer/decoder owns:

- raw BehaviorKind domain `1..17` and DTO rejection of known-but-forbidden
  `TemplateCallback`;
- actual nonempty row TypeKind/form/cardinality allowlists;
- grouping by ascending BehaviorKind and exact per-group ordinal/order rules;
- target StableReference physical/local shape, nonzero key and nonzero ABI;
- ScriptFunction owner present/nonzero versus EnvironmentSymbol owner absent;
- Class Construct/Factory **count equality only**;
- `HasDestructor` equality with zero/one Destruct row;
- exact script CopyConstruct tuple alias to one Construct row;
- exact script CopyFactory tuple alias to one Factory row; and
- EnvironmentSymbol CopyConstruct/CopyFactory independence from script aliases.

ModuleSnapshot graph exclusively owns target existence/entity, actual declaration
owner/module, ABI equality, generated traits, Construct/Factory parameter/default/
return compatibility, zero-parameter identification, full
`HasDefaultConstructor` truth, and Copy-to-opAssign compatibility.

### 3.3 Behavior owner decision

For a normal script behavior, local validation requires only a present, nonzero
`DeclaringOwner`. It does **not** require `DeclaringOwner == Schema.TypeKey`.
Exact declaration ownership is graph-owned. Consequently both self and nonself
nonzero script-owner coordinates are local successes pending graph validation.

Owner equality is local only where the DTO itself defines an exact alias tuple:
a script CopyConstruct must repeat its selected Construct target key, ABI and owner;
a script CopyFactory must repeat its selected Factory tuple.

This replaces the non-normative producer-audit phrase “local owner equality” with
“owner presence/nonzero locally; exact owner at graph; alias-owner equality only.”

## 4. Proposed `HasDefaultConstructor` correction (IC-172)

The local layer may enforce only necessary conditions visible without resolving a
function declaration:

- `HasDefaultConstructor=true` requires at least one Construct row;
- on Class, `HasDefaultConstructor=true` also requires at least one Factory row and
  the already-local Construct/Factory counts must match;
- `HasDefaultConstructor=false` with zero, one or many Construct rows is locally
  admissible because every row may be parameterized; and
- the local layer must not label a fixture “zero-parameter” by key, name, ordinal or
  test-only lookup.

These necessary-condition contradictions are cross-field flag/Behavior failures:

- `HasDefaultConstructor=true` with no Construct returns
  `InvalidQualifierCombination`, captured at `TypeSemanticFlags`;
- on Class, a mismatched Construct/Factory count is first the Behavior count error
  `InvalidPresence`, captured at the first unmatched physical `BehaviorSlot` row:
  when Construct count is greater, the row whose Construct `SlotOrdinal` equals
  the Factory count; when Factory count is greater, the row whose Factory
  `SlotOrdinal` equals the Construct count; after counts are valid, a remaining
  flag-set/no-eligible-group contradiction is
  `InvalidQualifierCombination` at `TypeSemanticFlags`;
- `HasDestructor=true` with no Destruct returns
  `InvalidQualifierCombination` at `TypeSemanticFlags`; and
- `HasDestructor=false` with one otherwise valid Destruct row returns
  `InvalidQualifierCombination` at the physical `BehaviorSlot` row carrying
  Destruct ordinal zero.

All field-local checks through Dependencies, then form/cardinality closure, run
before this flag/Behavior closure. A malformed row, a singleton-cardinality fault,
or a later field-local Dependency error therefore wins. The normal producer keeps
its normalized `Stage=None, ByteOffset=0` result; the captured coordinates above
are decoder authority.

The graph computes the complete bidirectional rule after resolving declarations:

```text
HasDefaultConstructor
  iff exactly one Construct declaration has zero parameters;
Class additionally requires its corresponding zero-parameter Factory declaration.
```

Required existing-test repair before new Slice 5 methods become authority:

1. In approved Slice-1
   `NormalProducerRejectsHeaderStringsAndTypeFlagRulesAtomically`, retain the three
   flag-set/no-Construct necessary-condition failures and all HasDestructor rows,
   but replace the three Class/Struct/Delegate
   Construct-present/HasDefault-cleared failures with normal-producer local-success
   controls. Their contexts must state that graph owns zero-parameter parity.
2. In `DefaultConstructorFlagAndConstructFactoryRowsAreBidirectional`, remove the
   local assertion that one opaque Construct (plus Class Factory) implies the flag.
   Retain locally visible necessary-condition and count tests; move exact reverse
   parity to the ModuleSnapshot graph RED with real declaration signatures.
3. Freshly compile and independently rereview the complete exact test TU because
   this repairs previously approved Slice-1 producer authority.

## 5. Proposed empty Behavior correction (IC-173)

An empty Behavior group has no BehaviorKind, target or owner coordinate. Test it
once per actual type/form baseline, including the statics form after the statics
ordering correction below. Do not multiply absence by hypothetical values.

All Kind/target/owner/cardinality/alias producer calls must contain one or more
concrete BehaviorSlot rows. The new normal-producer method must use explicit
represented-coordinate partitions with literal expected errors; it must not call
or reproduce `IsAllowedCardinality`, `IsEnvironmentTargetAllowed` or another
dynamic expected-validity predicate.

The existing decoder Cartesian must drop all 952 ghost-empty combinations. Its
nonempty Cartesian may remain only after the exact local/graph split and literals
in this correction are applied.

## 6. Proposed reflected-form validation order

StaticsClass and the other reflected forms are discriminated by Reflection fields
that occur after Relations, LayoutInputs, Layout, Properties, Methods, VFT and
Behaviors. Preserve the no-look-ahead rule: each earlier field performs only its
form-independent row/scalar validation and defers any allowlist/cardinality rule
that needs `ReflectionKind` or `StaticsClass`. It must not assume an ordinary Class.

After **all** top-level field-local checks through Dependencies succeed, run one
`ReflectionFormClosure` cross-field pass. A malformed Reflection or Dependency
therefore wins before the closure. The closure derives exactly one legal form from
TypeKind plus the already validated Reflection discriminator, then applies the
frozen form tables to prior fields in their wire order.

For `Class + UClass + StaticsClass`, the complete closure checklist is:

1. `TypeSemanticFlags` contains `Generated|ReferenceType`, permits optional `Final`,
   and forbids `Abstract|Shared|HasDefaultConstructor|HasDestructor|ValueType`;
2. Relations contain no Base, ShadowSuper, ImplementedInterface or Compose and
   exactly one structurally valid EnvironmentSymbol CodeSuper;
3. LayoutInputs contain no role contribution and Layout is exactly
   `{size=0, alignment=1, boundary=0}`;
4. OrderedProperties, OrderedMethods, VirtualFunctionTable and
   OrderedBehaviorSlots are all empty;
5. Reflection has the already field-locally validated
   `UClass|SuperIsCodeClass|StaticsClass` closed flag form, permits only optional
   Placeable, forbids ConfigName and StaticClassGlobalName, and contains at least
   one ordered reflected member; and
6. each reflected member remains locally a valid ScriptFunction stable reference;
   its Module-owned GlobalFunction entity/owner/ABI is graph-owned.

The closure returns the frozen form-specific literal (`InvalidPresence` for
forbidden/missing fields, `InvalidQualifierCombination` for statics flag/layout
parity) at the first offending logical group in the top-level wire order:
`TypeSemanticFlags -> Relations -> LayoutInputs -> Layout -> Properties -> Methods
-> VFT -> Behaviors -> Reflection`. Intrinsic row-local errors already won before
this point. “Logical group” does not invent a public container coordinate. The
decoder must use the following exact, existing coordinate contract; all unused
indices are `MAX_uint32`:

| Closure failure | Captured coordinate |
|---|---|
| form-dependent semantic-flag requirement/forbidden bit | `TypeSemanticFlags` |
| a present forbidden Relation row | `Relation` at its physical array index |
| too many rows of a required singleton Relation kind | the second matching `Relation` row's physical array index |
| a required form-specific Relation row is absent | `Reflection` |
| a present forbidden LayoutInput row | `LayoutInput` at its physical array index |
| too many rows of a required singleton LayoutInput kind | the second matching `LayoutInput` row's physical array index |
| a required form-specific LayoutInput row is absent | `Reflection` |
| a form-specific size/alignment/boundary mismatch | `LayoutExpectation` |
| a forbidden property, Method, VFT or Behavior row | respectively `OrderedProperty`, `OrderedMethod`, `VirtualFunctionSlot` or `BehaviorSlot` at the first offending physical array index |
| a forbidden reflected-member row | `ReflectedFunctionMember` at its first offending physical array index |
| a required statics reflected-member row is absent | `Reflection` |
| illegal `(TypeKind, ReflectionKind)`, reflection flags, ConfigName or StaticClassGlobalName presence/value | `Reflection` |

For multiple closure contradictions, select the earliest logical group above;
within an indexed group select the lowest physical array index that proves the
fault. Missing-required rows have no row offset, so the already captured
`Reflection` discriminator is the unique fallback for every requirement selected
by `(TypeKind, ReflectionKind)`. This applies to ordinary UClass required
ShadowSuper/CodeSuper and CodeRoot, UStruct required StructHeader, the statics
CodeSuper/member requirements, and every other legal non-statics form—not only to
the statics checklist. It does not move TypeKind-only intrinsic flag/payload rules
out of their existing field-local phase.

Rules that depend on an existing Base/Relation rather than on reflection form stay
in the later frozen relation-to-LayoutInput pairing closure. A missing matching
BaseType input is reported at the existing `Relation` row that requires it; an
extra present LayoutInput is reported at its `LayoutInput` row. They do not use
the `Reflection` fallback.

The normal producer still normalizes to `Stage=None/ByteOffset=0`.

## 7. Proposed exact error and precedence rules

### 7.1 Raw enums and keys

- raw Method/VFT kinds `0`, `5`, `255`: `UnknownEnumValue`;
- raw Behavior kinds `0`, `18`, `255`: `UnknownEnumValue`;
- zero Method/VFT FunctionKey or owner key: `ZeroStableKey`;
- zero Method/VFT ExpectedDeclarationAbi: `MissingExpectedAbi`;
- zero Behavior Target.StableKey: `ZeroStableKey`;
- zero Behavior Target.ExpectedAbi: `MissingExpectedAbi`;
- ScriptFunction owner absent: `InvalidPresence`;
- ScriptFunction owner present-zero: `ZeroStableKey`;
- EnvironmentSymbol owner absent: locally admissible;
- EnvironmentSymbol owner present with any value, including zero:
  `InvalidPresence` without interpreting the inactive value; and
- required/active key and reference validity precedes role/alias predicates.

### 7.2 Ordinal set versus stored order

Producer and decoder use one phased algorithm:

1. Decoder PayloadDecode, and a producer DTO-domain preflight over the same raw
   enum fields in wire order, rejects any raw Method/VFT/Behavior kind outside its
   closed domain as `UnknownEnumValue` before canonical-local validation.
2. For each array, validate each stored row's required/active scalar/reference
   fields in stored-row and wire-subfield order. Method/VFT validates FunctionKey,
   required owner keys and ABI. Behavior validates Target key and ABI; only when
   Target is ScriptFunction **and** DeclaringOwner is present does this phase
   validate that active owner value as nonzero. This phase never rejects a missing
   ScriptFunction owner, never rejects a present EnvironmentSymbol owner, and
   never interprets an EnvironmentSymbol owner value. Thus an active present-zero
   ScriptFunction owner wins before an array-wide ordinal contradiction first
   established by a later row.
3. Scan the array's ordinal domain: duplicate values return `DuplicateOrdinal`;
   otherwise a set not exactly `0..N-1` returns `OrdinalGap`; otherwise an exact
   set stored out of ordinal position returns `NonCanonicalOrder`. After every
   BehaviorKind subgroup passes, a non-ascending BehaviorKind group sequence also
   returns `NonCanonicalOrder`.
4. Validate per-row Method/VFT role and local self/nonself owner shape in stored
   order. For Behavior first validate the allowed ScriptFunction/
   EnvironmentSymbol target arm, then validate the optional-owner tag only:
   ScriptFunction absent is `InvalidPresence`; EnvironmentSymbol present is
   `InvalidPresence` regardless of whether the inactive stored value is zero or
   nonzero. ScriptFunction present-nonzero and EnvironmentSymbol absent pass this
   phase.
5. Scan Method/VFT duplicate FunctionKeys; then run local TypeKind/reflection-form
   presence/cardinality and Class Construct/Factory count rules in
   `ReflectionFormClosure`; then run copy aliases and flag/Behavior cross-field
   closure in their frozen order.

Paired winners are therefore explicit: raw unknown enum beats all local faults;
row-zero zero key/missing ABI beats a later duplicate/gap; ordinal duplicate beats
gap/order; gap beats order; order beats role/duplicate-key/alias; a role/owner fault
in an earlier stored row beats a later duplicate-key/alias; field-local Dependencies
beat every form/alias/flag cross-field closure.

For the optional Behavior owner specifically: ScriptFunction present-zero beats a
later ordinal fault because it is an active-value fault from phase 2; a missing
ScriptFunction owner loses to duplicate/gap/order because its tag is phase 4; and
an EnvironmentSymbol owner present with either zero or nonzero value also loses to
duplicate/gap/order and then returns `InvalidPresence` without value inspection.

A complete-row swap of an exact ordinal set is therefore `NonCanonicalOrder`.
“First/middle/last” fixtures must be byte-distinct and must not accidentally turn a
gap case into a duplicate case.

### 7.3 Duplicate Method/VFT FunctionKeys

Within one Method array or one VFT array, a second row carrying the same
FunctionKey at a distinct valid ordinal is always `DuplicateKey`. Owner or ABI
differences do not create a second local coordinate and do not change the literal;
their equality with the real declaration is graph-owned.

The same FunctionKey across Method, VFT, reflected-member and Copy roles remains
legal and consumes one canonical Declaration dependency.

### 7.4 Behavior target and form errors

- a valid stable-reference kind other than ScriptFunction/EnvironmentSymbol:
  `WrongReferenceKind`;
- EnvironmentSymbol on script-only Construct/ListConstruct/Factory/ListFactory:
  `InvalidPresence` after stable-reference shape succeeds;
- ScriptFunction owner absent or EnvironmentSymbol owner present:
  `InvalidPresence`;
- known TemplateCallback in an explicit archive DTO: `InvalidPresence`;
- forbidden TypeKind/cardinality and Class Construct/Factory count mismatch:
  `InvalidPresence`;
- script CopyConstruct/CopyFactory key/ABI/owner/no-peer mismatch:
  `InvalidQualifierCombination`;
- singleton two rows at ordinals `0,0`: `DuplicateOrdinal` before cardinality; and
- singleton two rows at ordinals `0,1`: `InvalidPresence`.

`TemplateCallback` remains `NotCacheable` at live capture/planning. The above
`InvalidPresence` applies only when an explicit invalid DTO reaches
`SerializeTypeSchema` or the decoder, matching the Compose archive boundary.

## 8. Proposed Class/copy controls

Class Construct/Factory local positives are count pairs `0/0`, `1/1`, `2/2`.
Local negatives are `1/0`, `0/1`, `2/1`, `1/2`, all `InvalidPresence`.
Parameter/default/return agreement is graph-only.

Environment CopyConstruct/CopyFactory controls are:

- environment copy without a script peer: success;
- environment copy plus an unrelated script peer: success; and
- the same StableKey bytes in a ScriptFunction peer do not create an alias because
  ReferenceKind is part of the coordinate.

Only a ScriptFunction copy row without an exact script peer tuple is
`InvalidQualifierCombination`.

Delegate “generated local method” locally means local rather than inherited. The
declaration's Generated trait is graph-owned.

## 9. Slice ownership and first-error discipline

Slice 5 must construct a complete canonical dependency set so each fixture is
single-fault, but Slice 6 exclusively owns dependency missing/extra/conflict/merge
coverage, stale StorageLayoutHash, PropertyLayoutFingerprint and TypeLayoutHash,
and resolver-independence integration. ModuleGraph owns every resolved declaration,
owner/entity/ABI/reconstruction fact listed above.

For every Method/VFT/Behavior mutation—including raw enum, zero key, missing ABI,
wrong reference kind and active present-zero owner—close/sort the dependency rows
as far as the same mutated coordinate permits, then call
`FinalizeValidFixtureHashes` after the mutation. The hashing helper writes these
raw DTO values and supplies the single non-stale final hash; it is not a legality
oracle. Do not use the physical malformed-ordinal rehash helper. A dependency row
that necessarily repeats the same invalid target coordinate is the same root fault,
not permission to leave a second stale TypeLayoutHash. Slice 5 adds no stale-hash
witness; Slice 6 retains exclusive stale-final-hash ownership.

The local top-level order remains:

```text
header/flags -> Metadata -> Relations -> LayoutInputs -> Layout -> Properties
-> Methods -> VFT -> Behaviors -> KindPayload -> Reflection local
-> Dependencies local -> ReflectionFormClosure -> Behavior alias closure
-> flag/Behavior closure -> existing pairing/dependency/layout cross-field rules
-> TypeLayoutHash last
```

## 10. Required correction and review sequence

1. Independently review this proposal against all three normative authorities,
   actual DTOs, current producer, approved Slices 1–4 and ModuleGraph routing.
2. Resolve every Critical/Important finding; the required release is
   0 Critical / 0 Important with every Minor explicit.
3. Amend the normative matrix/wire/local-order text and the non-normative producer
   audit in one exact authority patch; record IC-172/173 and any new issue.
4. Independently rereview that exact authority patch.
5. Materialize a new Slice-5 ready packet from the still-exact source frontier. It
   must freeze immutable hashes, exact existing-test repairs, literal call tables,
   dependency/finalizer rules, one complete-TU wrapper label and an exact-source
   review gate.
6. Only after that ready packet is approved may the owned test TU change.

Until step 6, no Runtime/test source, build file, registration, decoder, graph or
Git state may change. IC-145 still forbids linked focused Automation, B2 completion
and B3 authorization even after source/compile Slice 5 authority exists.
