# B2 Slice 5 Source and Compile Report

Recorded: 2026-08-09, Asia/Shanghai.

This attachment records the source materialization and complete single-translation-
unit compile that followed released ready packet
`2B51C3601888B53DABDFB2C021605138113DF937773C2450DA653C43D47AF625`.
It supersedes `.superpowers/sdd/b2-slice5a-report.md` for the current source
identity. The older report remains historical evidence for the earlier A-only
checkpoint.

## Scope and evidence ceiling

Only
`Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`
was intentionally changed in this Slice-5 source round. Runtime producer and
decoder behavior were not changed. The achieved state is **Compile Frontier**:
the complete test TU compiles, but the new methods have not yet linked or executed
through UE Automation. B2 remains unchecked, B3 remains unauthorized, and none
of Store, editor, PIE or package behavior is implied.

The current source identity is:

| Property | Value |
|---|---|
| SHA-256 | `18A55226D0786BC0C9C7E120492D55A9DB487CBC0070A1612BE3AB1BE356D5F9` |
| Read-only Git content hash | `40100ff6fc04d6c296ac43edae66d6333261b8c6` |
| Bytes | `680701` |
| LF / CR | `15693 / 0` |
| Final LF | yes |
| `TEST_METHOD` count | `63` |

The Git content hash was computed with `git hash-object` as a read-only content
identity. This report does not claim that a commit, stage operation or branch
publication occurred.

## Existing-authority repairs

The source now materializes the ready-packet repairs for IC-172, IC-173 and
IC-177:

- the three retained producer reverse default-constructor rows use normal local
  success because ModuleSnapshot graph, not TypeSchema local validation, owns
  zero-parameter constructor parity;
- decoder default-constructor form/flag expectations now distinguish
  `InvalidPresence` form/count failures from later
  `InvalidQualifierCombination` flag parity failures;
- the 952 unencoded cardinality-zero ghost calls were removed and replaced by the
  eleven concrete legal empty forms; and
- Class count, Behavior target and owner-precedence diagnostics use the physical
  row/subfield coordinate selected by the wire observer.

## Mechanical fixture assembly

The source adds mechanical helpers for clearing Method/VFT or Behavior-owned
state, recomputing dependency reachability, sorting canonical dependencies and
regenerating final hashes. These helpers inspect DTO references and rebuild
mechanical state; they do not decide whether a semantic coordinate is legal.

The IC-185 guard is materialized: Behavior cleanup no longer deletes every
Declaration or EnvironmentAbi dependency. Relation, Layout, nested Property,
Method, VFT, Behavior, callable, Typedef and Reflection references that remain
reachable are retained; newly referenced targets are merged by role, sorted and
finalized. The source-level scan and successful complete-TU compile close the
fixture-construction hazard for this slice. Slice 6 still owns deliberate
missing/extra/duplicate/conflicting Dependency negatives.

## Method and VFT producer matrix

`NormalProducerRejectsMethodAndVftSequencesIndependently` materializes exactly:

```text
form/role product after two named B1 exclusions   86 = 18 success + 68 failure
raw enum                                           6 =  0 success +  6 failure
ordinal/order                                     12 =  0 success + 12 failure
duplicate FunctionKey within one array             2 =  0 success +  2 failure
zero key / missing ABI                              4 =  0 success +  4 failure
owner matrix                                      10 =  1 success +  9 failure
cross-array same FunctionKey                        1 =  1 success +  0 failure
--------------------------------------------------------------------------
Method/VFT total                                  121 = 20 success + 101 failure
```

## Behavior producer matrix

The Behavior product is driven by one static literal table of 45 cells: 28 Script
cells and 17 Environment cells. Its expected result is literal data, not a runner-
derived legality predicate. Companion recipes mechanically close Class
Construct/Factory counts, destructor flag parity and Script Copy aliases while
keeping owner-absent primary rows free of an earlier invalid peer.

```text
represented nonempty product after two B1 exclusions
                                                1902 = 101 success + 1801 failure
eleven legal empty forms                         11 =  11 success +    0 failure
seventeen static-function negatives              17 =   0 success +   17 failure
--------------------------------------------------------------------------
form/product total                              1930 = 112 success + 1818 failure

raw kind                                           3 = 0 success +  3 failure
target envelope                                    6 = 0 success +  6 failure
ordinal/order                                     35 = 0 success + 35 failure
count mismatch                                     4 = 0 success +  4 failure
Script alias negatives                             8 = 0 success +  8 failure
owner precedence                                   2 = 0 success +  2 failure
Environment anti-alias controls                    4 = 4 success +  0 failure
abstract ordinary Class control                    1 = 1 success +  0 failure
Method/VFT/Behavior key reuse control               1 = 1 success +  0 failure
--------------------------------------------------------------------------
focused total                                     64 = 6 success + 58 failure

Behavior total                                  1994 = 118 success + 1876 failure
Slice-5 producer total                           2115 = 138 success + 1977 failure
```

Five paired-owner decoder cases were added for canonical Environment present-zero,
Script present-zero plus later ordinals, Script absent plus later ordinals,
Environment present-zero plus later ordinals, and Environment present-nonzero plus
later ordinals. The repaired Behavior decoder region contains no dynamic
`bExpected` legality derivation, no malformed-ordinal helper, no container-level
`BehaviorSlots` coordinate and no zero-cardinality ghost loop.

## IC-191 compile-local diagnostic mapping

The first allowed wrapper execution failed during compilation:

```powershell
$TypeSchemaTestTu = (Resolve-Path `
  'Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp').Path
& .\Tools\RunBuild.ps1 `
  -Label cache-b2-typeschema-producer-red-slice5-tu `
  -TimeoutMs 1800000 -NoXGE `
  -ExtraArgs @("-SingleFile=$TypeSchemaTestTu", '-NoHotReloadFromIDE')
```

Artifact:
`Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/20260809_102901_365_9387a66e`.
The source used logical captured field `BehaviorDeclaringOwner`, but the test wire
span enum intentionally exposes `BehaviorDeclaringOwnerOptionalTag`. The wire
scanner captures the logical owner value through that field at the same primary
row with `SecondaryIndex=1`. This was a test-coordinate spelling defect, not a
Runtime behavior RED.

The assertion helper was minimally extended to accept a secondary index, and the
owner assertions now use `BehaviorDeclaringOwnerOptionalTag`, primary physical
row, secondary `1`. No Runtime/header enum was added. Re-running the same wrapper
and label succeeded:

```text
artifact  Saved/Build/cache-b2-typeschema-producer-red-slice5-tu/
          20260809_103033_382_7db8e595
actions   1 (AngelscriptCacheTypeSchemaTests.cpp)
process   0
wrapper   0
```

## Source checks

- SHA/byte/LF/method inventory was recomputed after the successful compile.
- Braces balance mechanically.
- the literal Behavior table contains exactly 45 cells: 28 Script, 17
  Environment and 101 mechanically counted success coordinates;
- the repaired Behavior decoder region has zero dynamic expectation predicates,
  malformed-ordinal helpers, broad dependency resets and ghost-empty loops; and
- `git -C Plugins/Angelscript diff --check` reports no whitespace errors.

This is a main-thread source audit and compile result. No independent source
review is claimed: current design and implementation work is intentionally
serial because the decoder/Manifest/producer sequence shares contracts and is not
an independent-task parallelization boundary.

## Remaining critical path

This section records the pre-link checkpoint that led to IC-145. Its original
serial order was:

1. implement the decoder bridge and C2 declaration surface;
2. link and execute the focused normal-producer Automation prefix;
3. accept only returned result/output mismatches as RED; and
4. then implement B3 through the sole shared canonical-local semantic owner and
   prove focused GREEN.

The following sections supersede this checkpoint with the achieved link, B5 GREEN
and B2/B6 RED evidence. IC-145 is closed only as a link/evidence-order constraint;
B6/B7 and C2 behavior remain open.

## Post-link B5/B6 execution and authority correction

The link prerequisite is now real. Runtime/Test modules compiled and linked at:

```text
Saved/Build/cache-b5-b7-c2-linked-frontier/20260809_105449_324_a3d8c373
```

This build contains a first-pass private TypeSchema decoder and the frozen
Manifest/Pack declaration surface. The Manifest/Pack implementation is deliberately
only a link stub returning `UnexpectedRecord`; it is not C2 behavior completion.

The first exact TypeSchema method prefix omitted the CQTest class segment and
discovered zero tests. It is preserved only as an addressing failure:

```text
Saved/Tests/cache-b5-typeschema-physical-red/20260809_105534_514_b8713857
```

Correct exact methods include
`FAngelscriptCacheTypeSchemaTests` between `TypeSchema` and the method name. With
that spelling, the linked product produced a trustworthy B6 RED:

```text
method    AllSeventeenBehaviorKindsUseRepresentedNonemptyRowsAndElevenEmptyForms
artifact  Saved/Tests/cache-b5-behavior-kinds-red/
          20260809_105855_049_5c3939e3
result    0/1 PASS; returned decoder result/output assertion mismatch
```

The first invalid represented row is Class/Construct/cardinality-one with a
ScriptFunction target and absent owner. Frozen authority requires
`InvalidPresence/LocalSemantic` and unpublished output. The decoder publishes the
candidate because Behavior validation is not yet part of the shared local validator.

## B5 physical fixes and focused GREEN

Three concrete defects were resolved before claiming B5:

1. fixed-width truncation now reports the first unavailable byte,
   `Bytes.Num()`, not the field start;
2. a representable in-budget array count with an undersized payload is
   `OutOfBounds` at end-of-input, while budget/range/multiplication failures retain
   their stronger classifications; and
3. the independent raw-wire DataType optional-tag call now uses Property `0`,
   preorder node `0` instead of omitting the node coordinate.

Build/test evidence:

```text
Saved/Build/cache-b5-truncation-offset-runtime-tu/20260809_110310_515_e49cbe1f
Saved/Build/cache-b5-truncation-offset-linked/20260809_110323_979_b263ea97
Saved/Build/cache-b5-array-truncation-linked/20260809_110535_826_a8d2b5a5
Saved/Tests/cache-b5-truncation-boundaries-green-2/20260809_110557_312_8091027b
  1/1 PASS
```

The raw-wire coordinate defect first crashed at
`Saved/Tests/cache-b5-raw-domains-red/20260809_110735_609_f0ec2a6d`.
A temporary check-to-diagnostic change identified missing field `67` at
`Primary=0, Secondary=-1`; that diagnostic edit was reverted and the predecessor
SHA reverified before the permanent test-only repair. Diagnostic and final evidence:

```text
Saved/Build/cache-b5-raw-span-diagnostic-linked/20260809_110932_426_9bb35446
Saved/Tests/cache-b5-raw-span-diagnostic/20260809_110952_966_52959757
Saved/Build/cache-b5-raw-coordinate-authority-linked/20260809_111213_253_ca0338bb
Saved/Tests/cache-b5-raw-domains-after-coordinate-fix/20260809_111228_730_e026fdb4
  1/1 PASS
```

The current five-method B5 focus is:

```text
AllTypeSchemaRawEnumsBooleansAndOptionalTagsAreExhausted
IndependentRawWireScannerCoversAllFieldsAndEveryUnionArm
TypeSchemaCapturedCoordinateMatrixZeroThroughThirtyEightIsExactAndFree
EveryIndependentRawWireBoundaryIsOneByteTruncatedThroughFactory
PhysicalExhaustionAndTrailingDataPrecedeSemanticHashes
```

That test name and the `0..38` domain above are preserved as B5 historical
evidence. The current append-only authority is `0..40`, superseded by
`TypeSchemaCapturedCoordinateMatrixZeroThroughFortyIsExactAndFree` after the
ReflectionKind/ClassReflectionFlags additions; no original numeric value changed.

Artifact
`Saved/Tests/cache-b5-physical-focused-green/20260809_111346_019_36ca749b`
reports total `5`, passed `5`, failed `0`, skipped `0`. This closes B5 at its
physical/captured-offset/trailing-data scope; it does not close B6 or B7.

## Current authority identity and normal-producer RED

The previous source SHA
`18A55226D0786BC0C9C7E120492D55A9DB487CBC0070A1612BE3AB1BE356D5F9`
is retained as historical compile-frontier evidence but is superseded for Runtime
behavior by the coordinate repair. Current source identity is:

```text
SHA-256  2ACBD5E2005141805586D2D04FFE815E72B564F38FAE203D9C92D8810023E5EB
Git blob 1d9709a896e1b493b08fdbeeb94d740a7a0dbec7
bytes    680,785
LF/CR    15,695 / 0
methods  63
final LF yes
```

The normal producer now also reaches a trustworthy behavior RED:

```text
method    NormalProducerRejectsBehaviorGroupsOwnersFlagsAndAliasesAtomically
artifact  Saved/Tests/cache-b2-behavior-producer-red/
          20260809_111447_046_077c5b75
result    total=1, passed=0, failed=1, skipped=0
```

Failures are returned semantic/result/output mismatches across the represented
Behavior matrix. They are not unresolved symbols, checks, crashes or timeouts.
B2 remains open until all eleven `NormalProducer...` methods are discovered and
executed; B3 and B6 then share one canonical-local production validator.

## Superseding linked execution and first shared-validator slice

The preceding source/compile narrative is retained as history. It has now been
superseded by linked execution:

- IC-197 materialized the two missing methods, so the executable normal-producer
  authority contains all eleven planned methods. Its initial trustworthy mixed
  RED was `1 passed / 10 failed / 0 skipped` at
  `Saved/Tests/cache-b2-eleven-normal-producer-red/20260809_113425_474_134b2368`;
  B2 is checked.
- IC-198/199 record and close the invalid-finalizer, `TArray` self-alias and
  malformed-union physical-snapshot crashes that had to be removed before the
  RED could be trusted.
- One Runtime rule owner now validates Behavior for both normal serialization and
  private decode. The implementation separates `ValidateBehaviorFieldLocal` from
  `ValidateBehaviorCrossFieldClosure`: the former does not look ahead to
  Reflection; the latter runs after Dependencies field-local validation.
- Decoder presentation receives an optional logical field coordinate and resolves
  it through retained offset groups. Producer presentation remains normalized
  (`Stage=None`, byte zero) and the public producer still accepts no resolver.
- IC-201 corrects a statics fixture to the normative lowest-physical-row rule;
  IC-202 fixes group/count proving rows; IC-204 acknowledges that a Copy ABI
  mismatch is an earlier Dependency conflict and retains key/owner/no-peer as the
  reachable alias-closure proofs.

Final focused evidence for this slice is:

```text
build     Saved/Build/cache-b3-b6-dependency-before-alias-linked/
          20260809_120215_108_6bcca30a
tests     Saved/Tests/cache-b3-b6-behavior-phase-split-green-2/
          20260809_120235_410_1be0ff56
result    total=5, passed=5, failed=0, skipped=0
B5 rerun  Saved/Tests/cache-b5-physical-regression-green/
          20260809_115744_789_776dd23c (5/5 PASS)
producer  Saved/Tests/cache-b3-normal-producer-progress/
          20260809_115708_767_537ef85e (2/11 PASS, 9 expected B3 failures)
```

Current identities:

```text
Runtime TypeSchema.cpp
  SHA-256  BC2841B44A965EEA97F15F3990CA0E53BF2129FBE0A8C23F64755ACE0DD87976
  bytes/LF 108,998 / 3,440

TypeSchemaTests.cpp
  SHA-256  65071FEA1089383B835CD14826D042F3DBD7E177473B0CA123D79932D97C9D16
  Git blob 57fd2b0fce3268fd088588aac25f0527ed79ab67
  bytes/LF 687,925 / 15,832
  CR/final 0 / yes
  methods  65
```

This is main-thread serial implementation evidence, not an independent source
review. It completes B2 and the Behavior portion of B3/B6 only; it does not close
the other nine local-semantic families or any hash/current-layout work in B7.

## Header/String/TypeSemanticFlags producer continuation

The normal producer now also owns the header/string/type-flag family through the
same shared `ValidateProducerShape` entry. IC-205 corrected three executable test
fixtures/observers without making the production format permissive. Exact linked
evidence is:

```text
build     Saved/Build/cache-b3-header-flags-fixture-fix2-linked/
          20260809_121449_770_bbe0d936
focused   Saved/Tests/cache-b3-header-flags-focused-green-3/
          20260809_121508_408_8012ea2b (1/1 PASS)
producer  Saved/Tests/cache-b3-normal-producer-progress-header-flags/
          20260809_121545_510_187f063f (3/11 PASS, 8 expected RED)
B5 rerun  Saved/Tests/cache-b5-physical-after-unknown-kind-green/
          20260809_121630_317_2699ef2d (5/5 PASS)
```

Current identities supersede the prior Behavior-only snapshot:

```text
Runtime TypeSchema.cpp
  SHA-256  C91EEA8E22F17537AFEC54ED992B5B847E881A660D4626A5E2678751D5582803
  Git blob 826279fee38ed2e5f6cf0a95d2fa86b64ef99be8
  bytes/LF 112,132 / 3,526
  CR/final 0 / yes

TypeSchemaTests.cpp
  SHA-256  7EA1B759F2424D617D9E4F0CB25E003E326E483F50F2A4EBA8FAD304C022FAB0
  Git blob 116fec63b48348dc1e0ebc44d6ba9308950b7cb0
  bytes/LF 688,447 / 15,845
  CR/final 0 / yes
  methods  65
```

This advances B3 but does not close it. Decoder header/flag coordinates remain B6;
the other eight normal-producer families and all B7 derived hashes/current-layout
work remain open.

## Shared Relations continuation

Relations now uses the same production validator for serialization and private
decode. The field-local pass validates raw kind/reference, canonical order,
duplicate target and direct-interface ordinals. The post-Dependencies pass applies
the eleven-form/cardinality matrix and ordinary-`UClass` Shadow/Code pairing. The
normal producer remains resolver-free and atomic; decoder presentation maps the
shared failure coordinate to the retained row or Reflection discriminator.

IC-206 preserves the two test-authority repairs revealed by the 495-cell product:
dependencies must use the full production comparator, and forbidden Statics
Shadow rows must not synthesize an ordinary-class Shadow/Code companion. It also
records one mistaken Behavior method selection and one short-lived test-wrapper
timeout. None required Runtime semantic relaxation.

Bounded structured test logs now expose useful verification totals without one
line per matrix cell:

```text
[CacheV2][TypeSchema][Relations][Producer]
  begin matrix=11 forms x 5 kinds x 3 cardinalities; focused=30; expected-total=195
  complete matrix=165 focused=30 wrong-reference=16 total=195
[CacheV2][TypeSchema][Relations][Decoder]
  begin matrix=11 forms x 5 kinds x 3 cardinalities x 3 references; expected-total=495
  complete total=495 expected-success=167 expected-failure=328
```

Final evidence:

```text
build      Saved/Build/cache-b6-relations-structured-logs-linked/
           20260809_125232_234_9d8fb5ae
focused    Saved/Tests/cache-b3-b6-relations-structured-green/
           20260809_125251_480_9d10a235 (5/5 PASS)
producer   Saved/Tests/cache-b3-normal-producer-progress-relations/
           20260809_124905_758_a5c519a1 (4/11 PASS, 7 expected RED)
behavior   Saved/Tests/cache-b3-b6-behavior-after-relations-green-2/
           20260809_125105_450_15079206 (5/5 PASS)
B5 rerun   Saved/Tests/cache-b5-physical-after-relations-green-2/
           20260809_125645_939_761a4a12 (5/5 PASS)
```

Current source identities supersede the Header/String/TypeSemanticFlags snapshot:

```text
Runtime TypeSchema.cpp
  SHA-256  8B61282B213D1D2E90587AADF9275CA1C8B18BD56C51018F7205C7E131C729F4
  Git blob e91d019243cc7b685d4f552d747dd462a07a8a43
  bytes/LF 121,834 / 3,814

TypeSchemaTests.cpp
  SHA-256  BE7188DA18DF1BB4FCEC811A3F5F2344BD101157C2C9BC2F42E389980B4682B5
  Git blob 1258600c7616566f4ccf2a7759754fe9693d7355
  bytes/LF 691,742 / 15,928
  CR/final 0 / yes
  methods  65
```

This is a shared Relations slice of B3/B6, not either task's completion. The next
serial source slice is `LayoutInputs`; B7 derived-hash and prospective/current
layout work remains deferred until local role/presence/pairing semantics are
proven.

## Shared LayoutInputs continuation

LayoutInputs now follows the same shared rule-owner pattern as Behavior and
Relations. Field-local validation covers raw roles, stable reference kinds,
optional contribution masks, integer range/alignment, row hash, canonical role
order and singleton duplicates/conflicts. Cross-field validation owns form-role
presence and exact Base/Shadow/Code Relation pairing. Missing-role coordinates
point to the requiring Relation or Reflection discriminator; malformed present
roles point to their exact physical row.

IC-207 records the executable precedence and coordinate corrections. IC-208
records a test-only self-alias assertion. IC-209 records why the legacy Relations
Cartesian fixture needed to isolate its intended Relation fault from newly active
LayoutInput validation; both experimental Runtime phase changes were reverted.

The focused logs are intentionally bounded and structured:

```text
producer total=100
  legal=13 raw=3 missing=5 extra=34 wrong-role=3
  pairing=6 dependency-precedence=2 optional-mask=12
  zero-key=3 missing-abi=3 wrong-reference=6
  invalid-alignment=4 overflow=5 stale-hash=1
decoder matrix total=36; presence total=5; closure total=11
```

Final evidence:

```text
build       Saved/Build/cache-b6-relations-isolated-layout-fixture-linked/
            20260809_132607_778_17d405af
layout      Saved/Tests/cache-b3-b6-layoutinputs-structured-final/
            20260809_132735_879_327c67af (4/4 PASS)
relations   Saved/Tests/cache-b6-relations-isolated-layout-fixture-green/
            20260809_132624_956_445b1450 (1/1 PASS; 495 cells)
regression  Saved/Tests/cache-b3-b5-b6-after-layoutinputs-regression-final/
            20260809_132701_941_ccd52550 (15/15 PASS)
producer    Saved/Tests/cache-b3-normal-producer-progress-layoutinputs-final/
            20260809_132853_348_ee69f1be (6/11 PASS, 5 expected RED)
```

Current source identities supersede the Relations-only snapshot:

```text
Runtime TypeSchema.cpp
  SHA-256  958BA18F5F867AD0E2938FADAF5CB1BC4F71B8A9E531E25E890EAC8E48B8D76F
  Git blob 0183b8de3a73eb889c15edf3ac623232793ffd00
  bytes/LF 133,627 / 4,173
  CR/final 0 / yes

TypeSchemaTests.cpp
  SHA-256  3E458B206CD01E539FB8A1D22A80D498BDDE496F7DE4D1B0526B732444E29CEC
  Git blob fe94a1b077448ce4eb9269ee502dba00d831d27f
  bytes/LF 703,160 / 16,196
  CR/final 0 / yes
  methods  66
```

This is still a partial B3/B6 frontier. The next serial source family is
Dependency coverage/conflicts; B7 current-layout/property/enum/final hashes stay
deferred.
