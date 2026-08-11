# B2 Slice 5 ready-packet candidate — Method, VFT and Behavior local validation

> Status: **CANDIDATE / HOLD**.
>
> This attachment rematerializes the Slice-5 source-authoring contract from the
> released authority. It authorizes no C++ edit, build, Automation run, B2
> completion or B3 Runtime work until an independent exact-file review returns
> 0 Critical / 0 Important.

## 1. Purpose and scope

Slice 5 adds normal-producer evidence for the local Method, VFT and Behavior
parts of `FAngelscriptCacheTypeSchema`. It also repairs existing source tests
whose expectations were invalidated while the Slice-5 authority was reviewed.

The only future source owner of this packet is:

```text
Plugins/Angelscript/Source/AngelscriptTest/Cache/
  AngelscriptCacheTypeSchemaTests.cpp
```

This packet does **not** authorize changes to Runtime Cache, the physical writer,
decoder/factory, ModuleSnapshot graph, Pack/Manifest/Store, StaticJIT, build files,
test registration or Git state. Existing decoder assertions live in the same TU,
so repairing their test code does not authorize a decoder implementation change.

The two new public CQTest methods remain:

```text
NormalProducerRejectsMethodAndVftSequencesIndependently
NormalProducerRejectsBehaviorGroupsOwnersFlagsAndAliasesAtomically
```

## 2. Immutable authority and source frontier

### 2.1 Released authority

| Artifact | Exact SHA-256 | Shape |
|---|---|---|
| `type-schema-matrix-v1.md` | `206BA8D6D163419A8535DFFA2F16E5B346E244BC9170D9DAF3D9E060951B0B12` | 102,941 bytes / 1,715 LF / 0 CR / final LF |
| `type-layout-authority-v1.md` | `21B84C112EC4B8C2E85FBBF80B155914F689C337F555BC55A83D5C38D398057C` | 56,150 bytes / 944 LF / 0 CR / final LF |
| `record-wire-v1-remaining.md` | `8E290B464AD2F6B885E94DC66E302C07E35EBA9CAA4E9EB0092E7973B8812CD9` | 105,231 bytes / 2,152 LF / 0 CR / final LF |
| `producer-b2-coverage-audit.md` (non-normative) | `8E9E92F5487F47CB5FBBAF5887745B692075A9F55D1FA43C8121702D32838E38` | 22,222 bytes / 491 LF / 0 CR / final LF |

Release chain:

| Artifact | Exact SHA-256 | Disposition |
|---|---|---|
| `b2-slice5-authority-correction.md` | `D48D94CF54288A09E12400AAA830A0063285D9AAE23D7E7F55E9DE9C746C18E1` | released proposal; 0C/0I/1M |
| `reviews/b2-slice5-authority-correction-proposal-final-review.md` | `A453668A763E7FB35990FA61D06FC13F1BAB4C4CAF24AAF0CE003B28E4DB3CD5` | RELEASE |
| `b2-slice5-authority-patch.md` | `0C978C15083B81EDCDF298881238C1CEEA2F4D92FB4A6CDB3D785D0B37E8A144` | exact four-file patch packet |
| `reviews/b2-slice5-authority-patch-final-review.md` | `06A8E9F91B2B6B4F0F18E57B6D551DAD4ED235C971A2DB9DF4A0D96645946D69` | 0C/0I/0M RELEASE |
| `reviews/b2-slice5-authority-form-coordinate-audit.md` | `698FCBA89C8DD3552DE73837C5257B814A8731459CC911C9EA4FE127379EFE7A` | 0C/0I/0M |

Any drift in one of these files invalidates this packet.

### 2.2 Frozen C++ source

| Artifact | Exact identity |
|---|---|
| test TU | SHA-256 `9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32`; Git blob `0e0c8dcbc06a7b41ac56e679900cd6f4200afcc0`; 614,741 bytes; 14,005 LF; 0 CR; final LF; 61 `TEST_METHOD` definitions |
| Runtime producer | SHA-256 `DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4`; 56,909 bytes; 1,702 LF; 0 CR; final LF |
| DTO/header | SHA-256 `CE9BF77DE6C4AD969ADC7E3F8754FBBE78C7ADDAEA15D1F9E9EB818C3426FDD7` |

The historical research note `.superpowers/sdd/b2-slice-5-research.md`, SHA-256
`FE79C93FFD9F924D77FB257DD51A4F4A234189022D732B81EE2D2A9FEDFBBAED`,
is discovery evidence only. Its seven-empty, 41-focused, 1,967-Behavior and
2,088-total figures are superseded by this packet.

## 3. Counting contract

A **producer scenario call** is one invocation of normal
`FAngelscriptCacheTypeSchemaArchive::SerializeTypeSchema` through an exact success
or failure assertion. Fixture construction, dependency normalization,
`FinalizeValidFixtureHashes`, physical before/after snapshot writers and helper
internals do not add scenario calls.

A **decoder scenario call** is one physical TypeSchema decode validation. Decoder
repairs are tracked separately because they prove byte/stage/offset behavior and
cannot substitute for normal-producer coverage.

The candidate adds exactly:

```text
Method/VFT producer       121 =  20 success +  101 failure
Behavior producer        1994 = 118 success + 1876 failure
-------------------------------------------------------
Slice-5 producer total   2115 = 138 success + 1977 failure
```

These are expected validator results, not current runner PASS/FAIL results. At the
frozen source frontier the missing producer validation is expected to accept many
negative fixtures; that future returned-result mismatch is the intended RED.

## 4. Existing source-authority repairs before new methods

All repairs below stay in the one frozen test TU. They are part of the exact
future source slice and occur before the two new methods become authority.

### 4.1 IC-172 — three retained Slice-1 producer rows

In `NormalProducerRejectsHeaderStringsAndTypeFlagRulesAtomically`, replace these
three existing failure assertions with
`ExpectExactNormalProducerSuccessAndInputUnchanged`:

| Stable source anchor | Old expectation | New local expectation |
|---|---|---|
| `Class Construct and Factory require HasDefaultConstructor` at frozen lines 6551–6557 | `InvalidQualifierCombination` | Success; opaque Construct/Factory rows do not prove a zero-parameter constructor |
| `Struct Construct requires HasDefaultConstructor` at frozen lines 6565–6571 | `InvalidQualifierCombination` | Success for the same local/graph split |
| `Delegate Construct requires HasDefaultConstructor` at frozen lines 6579–6585 | `InvalidQualifierCombination` | Success for the same local/graph split |

Keep each existing post-mutation `FinalizeValidFixtureHashes`. Change each context
to say that ModuleSnapshot graph owns unique zero-parameter Construct parity and,
for Class, the corresponding zero-parameter Factory.

Do not alter:

- Class/Struct/Delegate `HasDefaultConstructor=true` with no Construct necessary-
  condition failures at frozen lines 6532–6546; or
- any of the six retained HasDestructor forward/reverse producer failures at
  frozen lines 6535–6549 and 6558–6592.

Call-count delta: zero; three existing calls change from expected failure to
expected success.

### 4.2 IC-172/177 — local default-constructor decoder method

Rename
`DefaultConstructorFlagAndConstructFactoryRowsAreBidirectional` to
`DefaultConstructorNecessaryConditionsAndOpaqueConstructRowsAreLocal`.

Parameterize or split its failure helper: a single hardcoded
`InvalidPresence/BehaviorSlots` expectation cannot express released authority.
Add a decoder-local success helper that asserts both `Result.IsSuccess()` and
`Output.IsSet()`.

Apply these four existing-call changes:

| Frozen source anchor | Exact new result |
|---|---|
| Class flag set, no Construct/Factory, lines 12193–12198 | `InvalidQualifierCombination/LocalSemantic` at captured `TypeSemanticFlags` |
| Class opaque Construct+Factory, flag clear, lines 12199–12208 | finalize, then decoder-local Success |
| Struct flag set, no Construct, lines 12216–12220 | `InvalidQualifierCombination/LocalSemantic` at captured `TypeSemanticFlags` |
| Struct opaque Construct, flag clear, lines 12221–12224 | finalize, then decoder-local Success |

Keep the two following flag-set serialize-success controls. Call-count delta is
zero; two existing failures become successes and two retained failures change
literal/coordinate.

### 4.3 IC-177 — decoder count/destructor error and coordinate repair

In `BehaviorOrdinalsFlagsCardinalityAndCopyAliasesHaveFocusedRows`, parameterize
the failure helper with exact Error, captured field and physical PrimaryIndex.

| Frozen source anchor | Exact new result |
|---|---|
| Class Construct only, lines 12094–12098 | `InvalidPresence/LocalSemantic`, captured `BehaviorSlot`, physical index 0 |
| Class Factory only, lines 12099–12103 | `InvalidPresence/LocalSemantic`, captured `BehaviorSlot`, physical index 0 |
| HasDestructor set/no Destruct, lines 12105–12110 | `InvalidQualifierCombination/LocalSemantic`, captured `TypeSemanticFlags` |
| Destruct present/flag clear, lines 12111–12115 | `InvalidQualifierCombination/LocalSemantic`, captured `BehaviorSlot`, physical index 0 |

The first two calls retain their error and change only from an obsolete array-
container location to the real first unmatched physical row. The last two retain
failure classification and change error/coordinate. Call count and outcome split
are unchanged.

### 4.4 IC-173 — existing decoder Cartesian repair

Rename `AllSeventeenBehaviorKindsHaveTheFullLocalCartesianMatrix` to the exact
identifier
`AllSeventeenBehaviorKindsUseRepresentedNonemptyRowsAndElevenEmptyForms` so its
name no longer claims that absence is a Cartesian coordinate and freezes both
parts of the replacement inventory.

Delete the complete zero-cardinality product:

```text
17 kinds × 7 TypeKinds × 2 targets × 4 owner cases = 952 calls
```

The current dynamic predicate labels those byte-equivalent calls as 784 successes
and 168 failures. Replace all 952 with the eleven literal success baselines in
section 6. Decoder delta:

```text
remove 952 = 784 success + 168 failure
add     11 =  11 success +   0 failure
--------------------------------------
net   -941 = -773 success - 168 failure
```

The nonempty decoder product remains 1,904 calls, but its expected results must be
stored in literal partitions equivalent to sections 8.1 and 8.2. Remove
`IsAllowedCardinality`, `IsEnvironmentTargetAllowed`, dynamic `bExpected` or any
replacement `IsExpected*` legality oracle from expectation selection. A small
runner may expand static literal rows.

Decoder literals must select the exact physical subfield rather than a blanket
row or the nonexistent/obsolete `BehaviorSlots` array-container coordinate:

| Failure family | Exact captured coordinate |
|---|---|
| BehaviorKind/SlotOrdinal/group/cardinality/form failure | `BehaviorSlot`, physical row PrimaryIndex |
| target ReferenceKind/key/ABI failure | `BehaviorTarget`, physical row PrimaryIndex |
| ScriptFunction owner present-zero | `BehaviorDeclaringOwner`, physical row PrimaryIndex |
| ScriptFunction owner absent | `BehaviorSlot`, physical row PrimaryIndex because the optional owner field is unset |
| EnvironmentSymbol owner present-zero or present-nonzero | `BehaviorDeclaringOwner`, physical row PrimaryIndex; validate the presence tag without interpreting the inactive value |

The fixture assembler must preserve dependencies still used by Method,
Reflection, Relation, Layout or KindPayload fields; clearing all Declaration or
EnvironmentAbi rows is forbidden.

### 4.5 Decoder paired-owner additions

Add five decoder scenarios to make the released optional-owner split observable
at an exact byte coordinate:

| Scenario | Exact expected result and captured coordinate |
|---|---|
| canonical Environment owner present-zero | `InvalidPresence/LocalSemantic` at `BehaviorDeclaringOwner`, PrimaryIndex `0`; the inactive value is not interpreted as `ZeroStableKey` |
| Script owner present-zero plus later `0,2` ordinal gap | `ZeroStableKey/LocalSemantic` at the earlier row's `BehaviorDeclaringOwner`, PrimaryIndex `0` |
| Script owner absent plus later `0,2` ordinal gap | `OrdinalGap/LocalSemantic` at the proving `BehaviorSlot`, PrimaryIndex `1` |
| Environment owner present-zero plus later `0,2` ordinal gap | `OrdinalGap/LocalSemantic` at the proving `BehaviorSlot`, PrimaryIndex `1`; the owner subfield is not read |
| Environment owner present-nonzero plus later `0,2` ordinal gap | `OrdinalGap/LocalSemantic` at the proving `BehaviorSlot`, PrimaryIndex `1`; tag validation occurs later |

These decoder calls are deliberate entry-boundary symmetry with producer calls;
they are not deducted from producer inventory.

The complete future TU validation-scenario delta is therefore tracked separately
from the 2,115-call producer gross inventory:

```text
new Slice-5 producer scenarios          +2115
remove decoder ghost-empty scenarios     -952
add decoder real empty-form scenarios      +11
add decoder owner/ordinal scenarios          +5
existing expectation replacements             0 calls
--------------------------------------------------
whole-TU scenario-count delta             +1179
```

Expected-authority classification delta is `-630 success / +1,809 failure`:
new producer `+138/+1,977`, IC-173 `-773/-168`, IC-172 five existing
failure-to-success flips `+5/-5`, and the five new decoder precedence rows
`0/+5`. This net ledger is not a current test result and never replaces the gross
producer count.

## 5. B1 exact exclusions and retained authority

The following nine existing producer rows are cited and never copied:

| Frozen line anchor | Retained B1 coordinate |
|---:|---|
| 9386–9392 | Delegate Method `VirtualDeclaration` -> `InvalidQualifierCombination` |
| 9394–9399 | Method first ordinal gap -> `OrdinalGap` |
| 9401–9407 | Delegate LocalMethod nonself owner -> `InvalidQualifierCombination` |
| 9429–9435 | Class VFT `LocalMethod` -> `InvalidQualifierCombination` |
| 9437–9442 | VFT first ordinal gap -> `OrdinalGap` |
| 9444–9450 | VirtualDeclaration nonself declaring owner -> `InvalidQualifierCombination` |
| 9452–9457 | Behavior Construct first ordinal gap -> `OrdinalGap` |
| 9459–9464 | Delegate Script Construct, owner absent -> `InvalidPresence` |
| 9466–9472 | Delegate TemplateCallback, self owner -> `InvalidPresence` |

The first Method/VFT form-role partition subtracts the first and fourth rows. Its
ordinal and owner partitions cite the other four Method/VFT rows. The Behavior
nonempty product subtracts the final two Behavior presence rows, while its per-
kind gap partition cites the retained Construct gap.

Existing repaired Slice-1 flag rows are citations, not new calls in the Slice-5
Behavior method. Producer and decoder instances of the same DTO shape remain
separate evidence because they enter different public boundaries.

## 6. Eleven legal empty Behavior baselines

The Behavior producer method and the repaired decoder method each own one call per
row below. The Method/VFT producer does not repeat these eleven calls.
Each row clears Behavior slots and `HasDefaultConstructor|HasDestructor`, removes
only Behavior-exclusive dependencies, preserves every dependency still referenced
elsewhere, canonical-sorts dependencies and finalizes hashes.

| # | Legal form | Frozen fixture route |
|---:|---|---|
| 1 | Class + None | `MakeMinimalSchema(Class)` |
| 2 | ordinary Class + UClass | `MakeOrdinaryUClassSchema(false)` |
| 3 | statics Class + UClass | `MakeStaticsUClassSchema()` |
| 4 | Struct + None | `MakeMinimalSchema(Struct)` |
| 5 | Struct + UStruct | `MakeReflectedUStructSchema()` |
| 6 | Interface + None | `MakeMinimalSchema(Interface)` |
| 7 | Enum + None | `MakeReflectionFormSchema(Enum, None)` |
| 8 | Enum + UEnum | `MakeEnumSchema()` |
| 9 | Delegate + UDelegate | `MakeCompleteDelegateSchema()`, with only Behavior-owned state removed |
| 10 | Typedef + None | `MakeMinimalSchema(Typedef)` |
| 11 | Funcdef + None | `MakeMinimalSchema(Funcdef)` |

Exactly eleven calls are expected Success. No empty call carries a hypothetical
BehaviorKind, target, owner, cardinality or entity label.

## 7. Method/VFT producer ledger

### 7.1 Forms and local roles

| Form | Method roles | VFT roles |
|---|---|---|
| Class + None | LocalMethod, Inherited | VirtualDeclaration, VirtualOverride, Inherited |
| ordinary UClass | LocalMethod, Inherited | VirtualDeclaration, VirtualOverride, Inherited |
| statics UClass | empty | empty |
| Struct + None | LocalMethod | empty |
| UStruct | LocalMethod | empty |
| Interface | LocalMethod, Inherited | VirtualDeclaration, VirtualOverride, Inherited |
| Enum + None | empty | empty |
| UEnum | empty | empty |
| Delegate | LocalMethod | empty |
| Typedef | empty | empty |
| Funcdef | empty | empty |

The known kind/form matrix is:

```text
11 forms × 4 known MethodSlotKind values × 2 arrays = 88
- Delegate Method VirtualDeclaration B1 duplicate
- Class VFT LocalMethod B1 duplicate
= 86 calls = 18 success + 68 failure
```

Within an allowed array, a known kind in the wrong role is
`InvalidQualifierCombination`. A form that forbids the array returns
`InvalidPresence`; forbidden container presence wins over a role interpretation.

### 7.2 Exact partitions

| Partition | Calls | Success | Failure |
|---|---:|---:|---:|
| form × known kind × array, after two exact B1 exclusions | 86 | 18 | 68 |
| raw kind `0`, `5`, `255` in Method and VFT | 6 | 0 | 6 |
| per array: middle/last gaps, two duplicate-ordinal shapes, two complete-row reorder shapes; first gap cited from B1 | 12 | 0 | 12 |
| same FunctionKey at distinct valid ordinals inside one Method/VFT array | 2 | 0 | 2 |
| zero FunctionKey and missing ExpectedDeclarationAbi, each array | 4 | 0 | 4 |
| owner shape after B1 exclusions | 10 | 1 | 9 |
| same FunctionKey once in Method and once in VFT | 1 | 1 | 0 |
| **Method/VFT total** | **121** | **20** | **101** |

The owner-shape group is exactly one valid explicit nonself inherited-VFT control,
six remaining nonzero wrong-owner cases and three zero-owner cases. The six wrong
nonzero cases are the full role-field matrix after excluding Delegate LocalMethod
other-owner and Class VirtualDeclaration other-declaring-owner from B1.

Same-array duplicate FunctionKey is always `DuplicateKey` at the later valid-
ordinal row, regardless of owner/ABI differences. Cross-array reuse is locally
valid. Exact entity, actual owner/module, ancestor membership, inherited suffix,
override suppression, VFT ancestor slot and ABI agreement remain graph-owned.

## 8. Behavior producer ledger

### 8.1 Represented nonempty product

The nonempty product is exactly:

```text
17 BehaviorKinds
× 7 TypeKinds
× 2 represented cardinalities {1,2}
× 2 targets {ScriptFunction,EnvironmentSymbol}
× 4 owner shapes {absent,self,other-A,other-B}
= 1904 calls
```

`other-A` and `other-B` are distinct nonzero keys. Labels such as “same module” or
“other module” are diagnostic names only; the local DTO cannot prove module or
declaration ownership and accepts both on the Script arm.

Static literal allowlists, not executable expected-value predicates, encode:

| TypeKind | Script legal kind/cardinality cells | Environment legal kind/cardinality cells |
|---|---:|---:|
| Class | 16: Construct 1/2, Factory 1/2, twelve Class singletons at 1 | 11 Class singleton intersections at 1 |
| Struct | 6: Construct 1/2 plus ListConstruct, Destruct, Copy, CopyConstruct at 1 | Destruct, Copy, CopyConstruct at 1 |
| Delegate | same six as Struct | same three as Struct |
| Interface, Enum, Typedef, Funcdef | none | none |

For a legal Script cell, absent owner fails and the three nonzero forms succeed.
For a legal Environment cell, absent succeeds and all present forms fail. Every
other represented cell is literal `InvalidPresence` after its active reference
shape succeeds.

Mechanical success count:

| TypeKind | Script | Environment | Total |
|---|---:|---:|---:|
| Class | 48 | 11 | 59 |
| Struct | 18 | 3 | 21 |
| Delegate | 18 | 3 | 21 |
| all other TypeKinds | 0 | 0 | 0 |
| **raw product** | **84** | **17** | **101** |

The raw product is `1,904 = 101 success + 1,803 failure`. Exclude the two named B1
failure coordinates (Delegate Script Construct/absent owner and Delegate
TemplateCallback/self owner):

```text
represented nonempty after B1 = 1902 = 101 success + 1801 failure
```

The product runner starts every coordinate from the section 6 canonical
Behavior-clean baseline for its TypeKind: clear all Behavior rows and both
Behavior-coupled flags, remove only dependencies no longer referenced by any DTO
source, retain Method/callable/Reflection/Relation/Layout/KindPayload dependencies,
sort, then add the primary row and the statically declared companion recipe.
`MakeMinimalSchema(Delegate)` routes through the complete Delegate fixture, so
this cleanup is mandatory before adding a product row; its OrderedMethod/callable
state and their dependencies remain intact.

Each static literal product row carries one of these mechanical companion recipes.
The expansion helper reads the recipe as data and never derives expected legality
or error values:

| Primary represented coordinate | Mechanical companion state |
|---|---|
| Class Construct, any target/owner/cardinality coordinate | add the same number of canonical Script Factory rows with independent nonzero keys/ABI/owners |
| Class Factory, any target/owner/cardinality coordinate | add the same number of canonical Script Construct rows with independent nonzero keys/ABI/owners |
| Destruct on Class, Struct or Delegate | set `HasDestructor`; forbidden-form Destruct rows keep the form's canonical flags so the Behavior row is the sole form contradiction |
| Script CopyConstruct on Struct or Delegate, owner present-nonzero | for every primary row, add one exact Script Construct peer with the same `{key, ABI, owner}` tuple |
| Script CopyConstruct on Struct or Delegate, owner absent | add no Construct alias peer; the primary CopyConstruct row itself is the first optional-owner failure |
| Script CopyFactory on Class, owner present-nonzero | for every primary row, add one exact Script Factory peer plus one canonical count-matching Script Construct row |
| Script CopyFactory on Class, owner absent | add neither Factory nor Construct companion, retaining valid Class counts `0/0`; the primary CopyFactory row itself is the first optional-owner failure |
| Environment CopyConstruct/CopyFactory | add no Script peer; the environment coordinate is independent |
| every other represented coordinate | no Behavior companion beyond its canonical clean baseline |

The `self`, `other-A` and `other-B` product owner shapes are all nonzero and use
the exact-alias recipe; only the `absent` shape uses the no-earlier-peer recipe.
The table is indexed by the static represented coordinate, not by an executable
expected-value predicate. Companion rows use contiguous ordinals and canonical group order. Their
Declaration/EnvironmentAbi dependencies are merged with all retained sources,
canonical-sorted and finalized after assembly. Thus each of the 101 success cells
reaches success, while an owner/target/form/cardinality failure cannot be masked by
an accidental Class count, destructor-flag or earlier companion-owner fault. In
particular, no owner-absent Copy coordinate recreates the B1-owned Delegate Script
Construct/absent-owner fixture.

### 8.2 Statics and form total

Add one canonical nonempty statics UClass row for each known BehaviorKind:

```text
17 calls = 0 success + 17 failure
```

Row-local enum/key/ABI/ordinal/tag validation runs without looking ahead to
Reflection. A row that is otherwise valid for ordinary Class reaches later
`ReflectionFormClosure`, which rejects the first physical statics Behavior row.

Together with section 6:

```text
represented nonempty after B1 1902 = 101 success + 1801 failure
eleven empty legal forms         11 =  11 success +    0 failure
statics nonempty                 17 =   0 success +   17 failure
----------------------------------------------------------------
Behavior form/product total    1930 = 112 success + 1818 failure
```

### 8.3 Focused Behavior rows

The old research's “19 sequence calls” is arithmetically inconsistent with its
own listed components, and it does not satisfy the released per-kind ordinal
requirement. This packet uses the following non-overlapping ledger:

| Partition | Calls | Success | Failure | Exact content |
|---|---:|---:|---:|---|
| raw BehaviorKind | 3 | 0 | 3 | `0`, `18`, `255` -> `UnknownEnumValue` |
| target envelope | 6 | 0 | 6 | raw ReferenceKind `0/10/255`; known wrong ScriptType; zero key; missing ABI |
| per-kind ordinal and group order | 35 | 0 | 35 | one gap for each of the 16 BehaviorKinds not already covered by B1 Construct, with three gap rows also carrying the later owner-tag faults below; duplicate ordinal for all 17 kinds; one true complete-row within-group reorder; one BehaviorKind group disorder |
| Class Construct/Factory counts | 4 | 0 | 4 | `1/0`, `0/1`, `2/1`, `1/2` -> `InvalidPresence` at first unmatched row |
| script copy aliases | 8 | 0 | 8 | CopyConstruct and CopyFactory each: key, ABI, owner and no-peer mismatch -> `InvalidQualifierCombination` |
| remaining owner value/tag precedence | 2 | 0 | 2 | canonical Environment present-zero plus Script present-zero/later-gap; the three ordinal-winning pairs are embedded in three per-kind gap rows |
| Environment copy anti-alias | 4 | 4 | 0 | CopyConstruct/CopyFactory each with unrelated Script peer and equal StableKey bytes under different ReferenceKind |
| abstract ordinary Class | 1 | 1 | 0 | valid Construct/Factory count pair remains locally legal |
| Method/VFT/Behavior reuse | 1 | 1 | 0 | same opAssign FunctionKey across all three roles is locally legal |
| **focused total** | **64** | **6** | **58** | |

The abstract ordinary-Class success is deliberately retained although the flag
and non-abstract Construct/Factory paths have separate positive rows. Section 9.1
of the normative matrix explicitly states the cross-field fact that abstractness
does not suppress captured constructor/factory groups; this combined control is
the only row that detects an accidental local instantiability rule.

The 14 legal singleton kinds at cardinality two with ordinals `0,1` are already
present in the 1,904-cell represented product and fail `InvalidPresence`. They are
not copied into the focused ledger. The 17 duplicate-ordinal calls use `0,0` and
prove `DuplicateOrdinal` wins before singleton cardinality or TemplateCallback/form
presence. Thus both precedence branches are covered without duplicate scenario
calls.

The sixteen new per-kind gap calls use an otherwise canonical two-row group with
ordinals `0,2`; B1 retains Construct's first-gap authority. Freeze these three
dual-purpose rows so the paired-owner accounting cannot drift:

- `ListConstruct` on Struct/Script uses owner absent and expects `OrdinalGap`;
- `AddRef` on Class/Environment uses owner present-zero and expects `OrdinalGap`;
- `Release` on Class/Environment uses owner present-nonzero and expects
  `OrdinalGap`.

The other twelve non-TemplateCallback calls use the locally correct target/owner
arm for their kind. TemplateCallback has no legal V1 target arm; its gap fixture
uses a wire-valid, active-value-valid ScriptFunction target with a nonzero owner so
`OrdinalGap` wins before the later explicit-DTO `InvalidPresence`. All seventeen
duplicate calls use otherwise identical rows with ordinals `0,0` and expect
`DuplicateOrdinal`, including TemplateCallback under the same earlier-phase setup.
The one within-group reorder uses two valid Construct rows stored as ordinals
`1,0`; the group-disorder call stores otherwise valid Copy before Construct while
retaining each group's exact ordinal set.

Environment CopyConstruct/CopyFactory with no Script peer are already success
cells in the represented product. The four focused positives add the two
independence hazards that the product does not encode: an unrelated valid Script
peer and equal StableKey bytes under a different ReferenceKind. Environment copy
is never locally rejected for failing to alias a Script peer. For each
CopyConstruct control, the Script peer is an otherwise-valid Construct row. For
each Class CopyFactory control, the Script Factory peer is accompanied by a
canonical count-matching Script Construct row; this prevents the Class count
closure from masking the anti-alias success.

The owner/ordinal authority uses five observable scenarios but only two extra
focused calls. Three scenarios are intentionally reused as three of the sixteen
per-kind gap rows because their released result is still `OrdinalGap`:

| # | Fixture | Literal result |
|---:|---|---|
| 1 | canonical Environment owner present-zero | `InvalidPresence`; inactive value not interpreted |
| 2 | Script owner present-zero + later ordinal gap | extra call: `ZeroStableKey` |
| 3 | Script owner absent + later ordinal gap | one named non-Construct per-kind gap call: `OrdinalGap` |
| 4 | Environment owner present-zero + later ordinal gap | a second named non-Construct per-kind gap call: `OrdinalGap` |
| 5 | Environment owner present-nonzero + later ordinal gap | a third named non-Construct per-kind gap call: `OrdinalGap` |

The represented product already contains the canonical Script-owner-absent and
Environment-owner-present-nonzero failures. The paired rows are nevertheless
required because they prove the released phase ordering.

### 8.4 Behavior total

```text
form/product total 1930 = 112 success + 1818 failure
focused total        64 =   6 success +   58 failure
----------------------------------------------------
Behavior total     1994 = 118 success + 1876 failure
```

## 9. Fixture assembly, dependencies and finalization

Small helpers may assemble Method, VFT, Behavior and static literal table rows.
They may also mechanically rebuild canonical fixture dependencies. They may not
select expected legality or error values.

For every representable non-hash mutation:

```text
mutate the target coordinate
-> remove only dependencies no longer referenced by any DTO source
-> add the exact Declaration or EnvironmentAbi dependency for new targets
-> merge equal cross-role coordinates
-> canonical-sort dependencies
-> call FinalizeValidFixtureHashes
-> call the target producer or decoder assertion
```

This applies to raw enums, zero keys, missing ABI, wrong ReferenceKind, ordinals,
stored order, roles, owners, cardinality, alias tuples, flags and form-forbidden
rows. When an invalid target necessarily repeats the same root fault in its
dependency coordinate, close the set as far as that root permits; never leave an
unrelated missing/extra dependency or stale TypeLayoutHash.

Focused Script CopyConstruct/CopyFactory alias negatives start from the canonical
owner-present-nonzero exact-peer fixtures frozen in section 8.1. Key, ABI and owner
mismatch calls retain all peers and mutate exactly that one Copy tuple component.
The CopyConstruct no-peer call removes its exact Construct peer. The Class
CopyFactory no-peer call removes both the exact Factory peer and the canonical
Construct row that existed solely to balance it, leaving valid Class counts
`0/0`; it does not leave a `1/0` count mismatch. Each operation then rebuilds
dependencies, canonical-sorts and finalizes before the assertion. The Environment
anti-alias controls likewise retain every required Class Construct/Factory
companion and differ only in the explicitly named peer relationship.

The helper is fixture assembly, not a second semantic validator. It must not be
used to compute the expected result, and positive cross-role dependency merge
controls must remain visible in literal assertions.

Slice 5 adds no missing/extra/duplicate/conflicting Dependency negative; those are
owned exactly once by Slice 6 method
`NormalProducerRejectsDependencyCoverageAndConflictsAtomically`. Slice 5 adds no
stale TypeLayoutHash negative; Slice 6 owns final stored-hash failure.

Do not use the physical malformed-ordinal rehash helper. Do not infer validity
from `FinalizeValidFixtureHashes` returning success.

## 10. Exact local order and ownership boundary

Normal producer performs a raw-enum DTO preflight in wire order, then the shared
local phases are:

```text
header/flags
-> Metadata
-> Relations field-local
-> LayoutInputs field-local
-> Layout scalar/local hashes except final TypeLayoutHash
-> Properties field-local
-> Methods field-local
-> VFT field-local
-> Behaviors field-local
-> KindPayload field-local
-> Reflection field-local
-> Dependencies field-local shape/order/duplicate/conflict
-> ReflectionFormClosure
-> script copy alias closure
-> HasDefault necessary + HasDestructor parity
-> relation/LayoutInput pairing
-> locally derived exact Dependency-set equality
-> layout replay
-> TypeLayoutHash last
-> publish
```

Within Method/VFT/Behavior arrays:

```text
raw enum domain
-> active required key/ABI values in stored-row order
-> DuplicateOrdinal
-> OrdinalGap
-> NonCanonicalOrder
-> role / allowed target arm / optional-owner tag
-> duplicate Method/VFT FunctionKey
-> cross-field closures
```

A present Script Behavior owner value is active and checked nonzero before
ordinals. A missing Script owner and every present Environment owner are tag-shape
failures after ordinal checks; an Environment owner value is never interpreted.
All field-local checks through Dependencies precede every cross-field closure.

Local validation owns only DTO-observable facts. ModuleSnapshot graph owns target
existence/entity, actual declaration owner/module, declaration/ancestor ABI,
inherited suffix and VFT reconstruction, constructor parameters/defaults,
unique zero-parameter Construct and corresponding Class Factory, compatible
opAssign, and graph record/declaration coverage.

## 11. Future source-authoring checkpoints

After this packet receives independent 0C/0I release, author the one test TU in
these checkpoints:

1. Repair IC-172/173/177 existing producer/decoder authority and add exact decoder
   helper support. Recount the repaired decoder matrix and verify the eleven forms.
2. Add dependency-safe mechanical fixture assembly helpers with no expected-
   validity branch.
3. Add the 121-call Method/VFT method and mechanically audit every partition.
4. Add the 1,930-call Behavior form/product partitions.
5. Add the 64 focused Behavior calls and the five decoder paired-owner calls.
6. Scan the exact TU for forbidden dynamic expectation helpers, stale hash setup,
   broad dependency deletion and B1 duplication.
7. Compile the complete exact TU once through the wrapper below.
8. Freeze post-source SHA-256, Git blob, bytes, LF/CR/final-LF and method count;
   obtain an independent exact-source 0C/0I review.

No Runtime implementation starts at any checkpoint. IC-145 still blocks a
truthful linked/focused Automation RED until real C2 Manifest and B5–B7 decoder-
bridge prerequisites exist.

## 12. Only allowed compile wrapper

The future source candidate may be syntax/complete-TU compiled only with:

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 `
  -Label cache-b2-typeschema-producer-red-slice5-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

Acceptance requires one intended complete-TU compile action, exit code zero and no
compiler diagnostics. A partial TU, full link, focused Automation, PIE, package
run or differently labelled build is not equivalent evidence.

## 13. Packet release gate and non-claims

Before any C++ change, an independent reviewer must verify this exact file against
the immutable authority and source frontier and report:

- 0 Critical / 0 Important; every Minor explicitly accepted or repaired;
- exact arithmetic for 121 Method/VFT and 1,994 Behavior calls;
- all eleven real empty forms;
- all nine B1 exclusions with no double subtraction;
- no duplicate singleton-overflow calls hidden in the focused ledger;
- per-kind gap/duplicate coverage and all four owner/ordinal paired winners;
- exact prior-test repair coordinates;
- canonical dependency/finalizer discipline;
- unique Slice-6 ownership of Dependency negatives and stale final hash; and
- no graph-owned rule inside a local producer expectation.

Until that review exists, the current disposition remains:

```text
authority correction: RELEASED
authority patch:      RELEASED
Slice-5 ready packet: CANDIDATE / HOLD
test source:          unchanged
Runtime source:       unchanged
build/Automation:     not run
B2:                   open
B3:                   unauthorized
```
