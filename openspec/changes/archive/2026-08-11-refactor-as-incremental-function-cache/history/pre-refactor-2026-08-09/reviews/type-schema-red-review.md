# TypeSchema RED Review And Remediation Record

Status: active remediation; this record does not approve RED or GREEN.

Frozen reviewed test:

```text
Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
lines: 1252
bytes: 63736
sha256: D5799DC913365A184CA197BC3A0EC61777EA72EB34783E914A1ADF5776AC5373
```

Final independent read-only verdict on 2026-08-08:

```text
NEEDS FIXES — 2 Critical / 7 Important / 0 Minor
```

The reviewer changed no file, ran no build/test, wrote no `Saved/` artifact,
and made no commit. The old missing-header run remains historical RED only; it
does not prove that the test contract is correct or that the full test
translation unit compiles.

## Critical 1 — sole decoded-record ownership boundary

The rejected test required a second public
`FAngelscriptValidatedTypeSchema` owning token and a direct TypeSchema decoder.
Final V1 instead has one trust and ownership path:

```text
declared RecordId + exact canonical payload + Limits + caller Budget
    -> FAngelscriptDecodedCacheRecord::TryDecode
    -> TOptional<FAngelscriptDecodedCacheRecordHandle>
```

The factory recomputes RecordId, dispatches a private record-specific decoder,
captures offsets, finishes local validation, charges the immutable token once,
and only then emplaces the sole
`TSharedRef<const FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>`.
Failure resets the optional. V1 exposes no per-kind owning token, nullable
`TSharedPtr`, raw owning pointer, mutable DTO/variant, DTO-to-token constructor,
or public record-specific decoder.

SourceIndex and ModuleInterface are part of the correction. The existing
Task 2B-1 `FAngelscriptValidatedSourceIndex` is transitional; final V1 removes
its public owning/graph role rather than wrapping or double-charging it.
Eligibility consumes the common token's const SourceIndex view and rejects a
wrong record kind.

Required RED evidence:

- factory signature and sole handle type;
- token copy/move construction and copy/move assignment are all impossible;
- declared RecordId mismatch before dispatch;
- failure clears a pre-populated optional;
- TypeSchema const typed view, const canonical bytes, and const offset lookup;
- handle copy performs no DTO/payload/control allocation and no budget charge;
- a canonical-payload view owned by the old output token remains alive through
  the call via a local reference-count-only guard before output reset;
- no public DTO-to-token reconstruction route.

## Critical 2 — negatives must execute the real decoder

Most rejected negative cases called the producer serializer or test-only
predicate. They could remain green if the real decoder skipped local
validation entirely. Every mandatory local negative must now:

1. begin from a complete valid physical fixture;
2. inject a precise semantic or byte-level mutation;
3. recompute the declared RecordId over those exact mutated bytes;
4. call the common record factory;
5. assert exact `Error`, `Stage`, `RecordKind`, and `ByteOffset`; and
6. prove the sentinel output optional is unset.

A unit-test-gated physical-only writer/span recorder may encode malformed wire,
but it performs no semantic/hash validation, is never passed as trusted input,
and cannot substitute for a decoder assertion.

## Important 1 — complete local matrices

The corrected RED must cover every local, non-graph predicate from
`type-schema-matrix-v1.md` sections 12.1 through 12.7:

- all eleven legal reflection forms, including ordinary UClass, StaticsClass,
  UStruct, and explicit zero-mask `OrderedUFunctionMembers`;
- class-reflection masks `0..0x3ff` plus each unknown high bit;
- property masks `0..0x7ffff`, owner allowlists, replication implications,
  and ReplicationCondition `0..16/17/0xff`;
- relation section/cardinality/order/SemanticOrdinal/reference-shape rows;
- BaseType, CodeRoot, and StructHeader local role/presence rows;
- StorageKind x CanonicalDataType/qualifier, property ordinal/overflow/tail
  alignment, and storage/fingerprint rules;
- independent OrderedMethods and VFT kind/ordinal/owner shapes;
- all 17 BehaviorKind values across the seven TypeKinds, local cardinality,
  grouping, reference shape, and owner-optional predicates; and
- every TypeKind/KindPayload and reflection optional-string presence form.

Declaration ownership, target existence/ABI, ancestor reconstruction,
interface closure, same-module linked layout, prospective view, and current
resolver outcomes remain graph/current RED. Local tests must not fake those
successes.

## Important 2 — deterministic paired precedence

In addition to the already useful pairs, the corrected suite requires these
complete double-mutation assertions:

```text
LayoutInputHash mismatch
    wins before PropertyLayoutFingerprint mismatch

PropertyLayoutFingerprint mismatch
    wins before noncanonical Dependencies

self-consistently rehashed wrong property offset
    loses to noncanonical Dependencies because all field-local checks precede
    cross-field layout replay

EnumAuthorityHash mismatch
    wins before TypeLayoutHash mismatch at the exact KindPayload offset
```

Every pair asserts the complete diagnostic tuple and output reset.

## Important 3 — allocator-authoritative TS-SCR-01..14

One generic cumulative-budget case is forbidden as a substitute. For each
local allocation family, parameterize empty, one, the actual allocator slack
boundary, and many. Assert actual `CalculateSlackReserve`/`GetAllocatedSize`
capacity, exact-limit success, one-byte-short failure before grow/allocation,
unchanged allocation probe, sentinel output, scratch release on physical/local/
hash failure, and exactly-once retained charge.

TS-SCR-12..14 must either measure their actual local index/replay scratch or
prove the implementation is streaming and allocates zero. The budget needs an
authoritative peak of simultaneously live
`ResidentDecodedBytes + TemporaryResidentDecodedBytes`; final resident plus an
independent temporary peak is not a valid reconstruction. TS-SCR-15..22 remain
the ModuleGraph/current/candidate slice.

## Important 4 — hidden compile blockers

The original missing-header RED hid two errors:

- use `FAngelscriptCachedMetadataEntry::CanonicalKey`, not nonexistent `Key`;
- compare stable key wrappers as their typed values. The corrected RED makes
  the product choice to add uniform typed `operator==`/`operator!=` support to
  the stable-key wrappers rather than repeatedly reaching through `.Hash`;
  equality remains full 256-bit equality and does not introduce coercion
  between different key domains.

The next authoritative RED must compile the entire test translation unit
against declarations/stubs before claiming its expected behavioral failure.

## Important 5 — raw scalar exhaustion

Run the real factory for raw `0`, every legal value, `max+1`, and `0xff` for
TypeKind, RelationKind, MemberAccess, MethodSlotKind, BehaviorKind,
ReflectionKind, StorageKind, and LayoutInputKind. Add ReplicationCondition
`0..16/17/0xff`, canonical boolean `0/1/2/0xff`, optional tag
`0/1/2/0xff`, and known-invalid versus unknown flag winners. A static assertion
or writer predicate is not decoder evidence.

## Important 6 — physical field-boundary exhaustion

Use one all-fields-nonempty independent fixture and cover one-byte truncation at
every new top-level and nested boundary, every optional tag, each enum and
boolean, the first unread byte, exact PayloadDecode offset, TypeSchema kind,
and clearing of a previously valid handle. The test span recorder supplies only
mutation/expected coordinates and is never an input to the factory's private
offset table.

## Important 7 — malformed fixtures must not pre-assert

The old `RefreshDerivedHashes` called `check` for all hash helpers, then used it
on intentionally malformed storage, enum, typedef, and presence fixtures. A
fail-closed public hash helper may legitimately reject those inputs before the
decoder under test runs. The corrected suite uses a result-returning
`FinalizeValidFixtureHashes` only for fully valid fixtures. Normal malformed
wire retains stale stored hashes because its earlier field-local error must
win. Only a named field-locally-valid, self-consistent cross-field precedence
fixture may perform its narrowly required rehash.

## Re-approval gate

Before production TypeSchema behavior begins:

- [ ] no `FAngelscriptValidatedTypeSchema` or public direct TypeSchema decoder;
- [ ] every mandatory local negative reaches the common factory;
- [ ] all local matrices and paired precedence rows are executable;
- [ ] TS-SCR-01..14 is allocation-family based;
- [ ] raw scalar and every-field physical exhaustion is present;
- [ ] malformed fixtures cannot assert before decode;
- [ ] whole test TU compiles against the frozen declarations/stubs;
- [ ] a behavioral RED is captured under the exact TypeSchema prefix;
- [ ] fresh independent review reports zero Critical and zero Important;
- [ ] strict OpenSpec and parent/plugin diff checks pass.

## Revised RED frozen for independent review

The corrected test-only snapshot is:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 4DDC1A19C3E5777B259669242A11AF2D86C90276061832E309B0F3164317309C
Bytes: 196186
Lines: 4532
CQTest methods: 36
```

The author self-audit reports every prior 2C/7I item addressed, including the
sole shared handle/factory, aliased-input lifetime, public destructor/deleted
token special members, typed offsets `0..38`, all decoder negatives through the
factory, the complete local matrices, the explicit local-versus-graph Behavior
split, paired precedence, raw scalar and field-truncation exhaustion, narrow
rehashing, and allocator-family TS-SCR-01..14 probes. Property-mask exhaustion
still sends all `5 × 524288` masks through the factory, while prebuilding
sentinel/payload/trace bases prevents repeated writer work from dominating.

This is author evidence, not approval. A fresh independent reviewer is now
checking the exact frozen SHA against every prior finding and the later unified
decoded-boundary audit. Production declarations or behavior remain gated on
zero Critical and zero Important review findings.

## Revised RED independent-review checkpoint

The independent reviewer has completed a full line-by-line read of the frozen
4532-line file and checked it against the five governing authorities. The
checkpoint is **not an approval** and currently reports at least:

```text
2 Critical / 7 Important
```

The reviewer is still deduplicating the findings and attaching exact line
numbers, so this checkpoint does not replace the final verdict. The confirmed
Critical classes are:

1. Mandatory local negatives commonly assert only Error/output reset and do
   not freeze the complete Stage/RecordKind/ByteOffset tuple. This affects
   reflection, Method/VFT, Property/Layout, focused Behavior, and TS-SCR paths.
2. The sole decoded-record boundary is not yet proven end to end: handle-copy
   zero-allocation/zero-charge, complete construction-entry closure, and typed
   captured-offset wrong-kind/extra-index behavior remain incomplete.

Confirmed Important classes include:

- physical field truncation derives its inventory solely from
  `Trace.GetAllV1Spans()` and has no independent expected span set/count;
- invalid optional tags cover only three optional families and omit, among
  others, LayoutInput alignment, reflection Config/Static names,
  CanonicalDataType TypeReference, and Dependency expected content/value;
- Property LayoutOrdinal lacks first/middle/last gap, duplicate, and
  out-of-order coverage;
- UFunction/Method/VFT `Position + 1` mutations misclassify the final
  `[0,1,3]` shape as DuplicateOrdinal instead of a gap;
- TS-SCR exact/one-byte-short probes rely on a self-reported fixture and do not
  prove unchanged allocation counters or physical/hash/scratch-failure exits;
- several fixtures labelled valid omit required alias/dependency closure; and
- reflection optional arms and multiple local focused matrices remain
  incomplete.

No production declaration or behavior implementation may start from this
snapshot. After the final line-numbered verdict, the test author must repair
the complete non-overlapping finding set, freeze a new SHA, and obtain a fresh
independent zero-Critical/zero-Important review.

## Revised RED final independent verdict

The exact-SHA read-only review is complete:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 4DDC1A19C3E5777B259669242A11AF2D86C90276061832E309B0F3164317309C
Lines: 4532
CQTest methods: 36
Verdict: NEEDS FIXES — 3 Critical / 9 Important / 0 Minor
```

The reviewer read the complete file, changed no file, ran no build or test,
and made no commit. The final verdict supersedes the preceding checkpoint.

### Final Critical findings

1. **Incomplete diagnostic tuples.** At least eighteen negative-bearing
   methods omit one or more of Stage, RecordKind, ByteOffset, or per-case output
   reset. Confirmed method starts are lines 1930, 1954, 2185, 2286, 2409,
   2460, 2538, 2862, 2921, 2978, 3111, 3190, 3297, 3699, 3889, 4216, 4391,
   and 4498. A shared assertion must consume the exact complete tuple for each
   individual matrix cell, including allocation-site offsets for budget
   failures.
2. **Incomplete sole-boundary proof.** Lines 1659 onward freeze useful type
   shapes, but do not prove handle-copy zero allocation/zero charge, complete
   constructor/entry closure, exact `GetRecordId`/`GetCanonicalPayload` return
   types, or the full captured-coordinate valid/surplus/out-of-range/recursive/
   wrong-record-kind matrix. The offset test at line 1811 is only a small
   subset.
3. **Impossible inactive KindPayload decoder fixtures.** Lines 2087, 1250, and
   4116 expect the decoder to observe an inactive in-memory union arm. V1 writes
   no second arm tag, so this state has no decoder-visible bytes. Move
   inactive-arm rejection to producer/serializer tests, use representable
   selected-arm mutations for decoder RED, and replace the Metadata precedence
   pair accordingly. Adding a hidden test-only arm tag is forbidden.

### Final Important findings

1. Optional tags do not cover every TypeSchema-reachable optional with raw
   `0/1/2/0xff`; individual unknown high bits are missing for type, property,
   reflection, and datatype qualifier flags.
2. `Trace.GetAllV1Spans()` is the only field-boundary inventory; no independent
   expected span set/count can detect writer+trace co-omission.
3. Property/layout local coverage lacks multi-property ordinals, overlap,
   padding, checked range/overflow, aggregate alignment, structural fields,
   forbidden-form controls, and complete LayoutInput role/presence rows.
4. UFunction/Method/VFT `Position + 1` fixtures misclassify `[0,1,3]` as a
   duplicate and mix gap+duplicate in `[0,2,2]`; gap, duplicate, and reorder
   require independent first/middle/last generators.
5. Reflection optional strings, zero-member UClass, relation focused rows,
   invalid Method/VFT owner permutations, and bidirectional default-constructor
   behavior rows remain incomplete.
6. TS-SCR01..14 obtains expected slack/exact/short values from its own probe and
   omits independent allocator capacity, unchanged allocation attempts,
   pre-existing live reservations, per-family physical/local/hash cleanup, and
   handle-copy exactly-once charge evidence.
7. Several TS-SCR fixtures marked valid are not: duplicated CodeRoot dependency
   in relation variants; VFT without Declaration dependency; script
   CopyFactory without Factory/Construct aliases; TS-SCR03 ignoring
   cardinality; TS-SCR10 omitting empty-present strings.
8. Several deterministic local precedence pairs are absent, and the existing
   Metadata/inactive-arm pair is invalid under Critical 3.
9. Typed-key tests do not freeze `operator!=`, full-width late-byte inequality,
   or cross-domain non-invocability/coercion.

The reviewer independently confirmed the meaningful positives: all local
decoder calls use the common factory; alias success/failure paths exist; token
special-member deletion and public destruction are asserted; captured-field
values `0..38` are frozen; all eight named enum domains use the factory; all
`5 × 524288` property masks really execute; all 68 TS-SCR08 variants iterate;
rehashing is narrow; and the local-versus-graph signature split is preserved.
Those positives do not satisfy the zero-Critical/zero-Important gate.

The repaired snapshot must receive a new SHA and a fresh independent review.
Production declaration/stub work remains gated until this final finding set is
closed.

## Repaired RED candidate frozen for rereview

The test author repaired the final `3 Critical / 9 Important` finding set and
the later IC-028/IC-029 allocation-oracle corrections. Root mechanical review
then found one IC-030 residual: the allowed-site table still assigned a
CanonicalDataType subtype allocation to family-9 variant-2 Funcdef. The author
removed that row; only variant-3 Typedef may now expose a selected-arm subtype
array, while Delegate and Funcdef explicitly require exactly one retained
selected-arm offset site and no DTO string/container site.

The new frozen candidate is:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 63C265CCE5325302A7ABFF8D7D9C6AD47BD2EBEEFDB5DE1892D7ECA606BDBE92
Bytes: 308951
Newline-counted lines: 6976
CQTest methods: 46
Allocation-site templates: 66
Semantic allocation SiteKinds: 50
ExpectExactFailureAndReset references: 106 (including the helper definition)
```

Static repair evidence, independently repeated by root:

- property masks remain `5 × 0x80000 = 2,621,440` common-factory cases;
- allocation sites are test-owned templates expanded against chronological
  observation-only events, independent allocator capacity, static Stage, and
  independent physical coordinate/ByteOffset;
- Delegate/Funcdef have no signature string or subtype-array DTO site;
- `MakeOneByteShort*`, target-site/offset/stage helpers, isolated-target and
  budget-failure self-oracles, all three `GetRequired*` exact-limit helpers,
  `DelegateSignatureString`, `Outcome.Result.Error`, and
  `MeasureResult.Error` have zero matches;
- the four remaining `Result.Error` references are the shared exact helper,
  one legal-enum negative comparison, and two producer-only inactive-arm
  serializer rejections;
- raw delimiter counts are braces `873/873`, parentheses `4158/4158`, and
  brackets `219/219`; trailing whitespace is zero; and
- the test file is still an untracked new plugin file, so a no-index diff has
  the expected new-file exit plus line-ending warning rather than a tracked
  baseline diff.

The candidate intentionally declares narrow test-only observed-event/layout
contracts that Runtime does not yet implement. No build or Automation result
is claimed, and a compile gap is still declaration RED rather than behavior
RED. The exact SHA now requires fresh independent rereview against all prior
findings plus `type-layout-authority-v1.md` section 11.1 and IC-028 through
IC-030. Production declaration or behavior remains gated on zero Critical and
zero Important.

## Independent rereview of SHA 63C265... — not approved

Two read-only reviewers independently reverified SHA-256
`63C265CCE5325302A7ABFF8D7D9C6AD47BD2EBEEFDB5DE1892D7ECA606BDBE92`
and read the applicable wire, boundary, TypeSchema and TS-SCR authorities. They
made no edit, build, test, `Saved/` write or commit.

- full cross-document verdict: **NEEDS FIXES — 3 Critical / 6 Important /
  0 Minor**;
- focused handle/budget/TS-SCR verdict: **NEEDS FIXES — 3 Critical /
  7 Important / 0 Minor**.

The raw counts are not added because their scopes overlap. The deduplicated
blocking set is recorded as IC-031 through IC-042 in
`implementation-issues.md`.

### Critical blockers

1. Public TypeSchema captured-offset lookup does not cover the full `0..38`
   coordinate domain with present/surplus/out-of-range/unapplicable/recursive/
   wrong-kind/allocation-free behavior.
2. IC-028/029 remains circular and partly impossible: Runtime echoes semantic
   site/variant/coordinates and entry counters, observed requested capacity is
   used as expected input, failure offsets come from the writer trace, and
   variant-filtered templates omit real baseline/physical allocations.
3. TS-SCR-01 omits the immutable token-owned canonical-payload byte allocation,
   so exact Total/Resident reconstruction freezes a nonconforming factory.
4. The focused audit additionally classifies the same budget area as Critical
   because required Enum Metadata/Typedef subtype sites never expand,
   TS-SCR-12..14 may accept production-self-reported zero allocation, and
   Resident/Peak/temporary lifetimes have no independent reconstruction or
   Resident one-short cases.

### Important blockers

1. The independent wire inventory lacks complex all-fields shapes and does not
   independently calculate tertiary-aware ByteOffsets.
2. Several duplicate-ordinal and allocation fixtures are multi-fault or locally
   invalid; isolated required relation rows remain absent.
3. Property/layout above-INT32 storage witnesses, boundary-versus-size,
   terminal alignment overflow and structural forms remain incomplete.
4. Two precedence pairs use the wrong later fault.
5. `MaxReferencesAndRelocations` has no independent exact/one-short oracle.
6. handle-copy allocation proof occurs outside the probe and is therefore
   vacuous.
7. physical/local/hash cleanup cases do not prove the target family was reached
   and do not restore/compare complete entry state.

### Required next candidate

Before another frozen SHA is offered for review:

- reconcile §11.1 so TS-SCR-01 includes canonical payload and the observer is
  explicitly semantic-blind;
- replace the event-driven expected oracle with a test-owned chronological
  event/lifetime/reference/offset model;
- give every site template `Required`, `StreamingZero`, or
  `InvalidFixtureOnly` disposition and prove every Required site reaches a
  locally valid fixture at its own allocator-type slack boundary;
- run distinct Total-short, Resident-short and reference-short cases;
- complete captured-coordinate, wire-inventory, property/layout, relation,
  precedence, handle-copy and late-exit cleanup rows; and
- obtain a new SHA followed by a fresh read-only `0 Critical / 0 Important`
  review.

The production declaration/behavior gate remains closed.

## Independent review of replacement SHA 44432F... — not approved

The replacement candidate was frozen as:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 44432F811B66BB1BB2AF2E87B927CCD64525482132DA2E63FF87C97AF8F1124E
Bytes: 331959
CQTest methods: 49
Static SiteKinds/templates: 53/53
Public top-level coordinate rows: 39 (0..38)
```

A fresh read-only independent review returned **NEEDS FIXES — 3 Critical /
7 Important / 0 Minor**. It made no source edit, build, test, `Saved/` write or
commit. The candidate therefore remains a declaration RED input, not an approved
behavioral RED and not authority for a production GREEN implementation.

### Critical findings

1. Candidate ownership is internally contradictory. Allocation events classify
   token/controller/payload/DTO/offset sites as retained and charge Resident,
   while failure cases refund the accepted Resident prefix. The selected repair is
   one private aggregate Temporary candidate transaction with per-site atomic
   extension, failure release and one final promotion before publication (IC-054).
2. Success coverage uses more cardinalities than the per-site Total/Resident
   one-short coverage, which falls back to `{1,17}`. Exact and both short dimensions
   must consume the same site-specific allocator-boundary case set, including
   string prefixes/terminators, occurrences and recursive sites (IC-055).
3. The precedence fixture removes the selected Enum arm before physical writing,
   but wire V1 has no selected-arm presence tag. A full selected arm plus a later
   independently provable, representable presence fault is required (IC-056).

### Important findings

1. A broad malformed-input matrix still derives expected ByteOffsets from writer
   trace rather than the independent raw scanner (IC-057).
2. Several ordinal cases copy an entire identity row or leave derived hashes stale,
   producing multi-fault fixtures (IC-058).
3. The nonzero-base property fixture does not construct a nonzero base contribution,
   and dependency allocation fixtures do not all prove a valid local closure before
   marking Required coverage (IC-059).
4. Reference exact/short coverage proves only that some family has a reference; it
   does not freeze the exact reference-bearing family/variant/occurrence set or
   chronology (IC-060).
5. The observed 53 SiteKinds/templates have no enum sentinel, fixed table size,
   one-template frequency assertion or valid-only disposition closure (IC-061).
6. StreamingZero tests do not prove the intended validation path was reached, and
   several successful handles are destroyed after the allocation probe (IC-062).
7. Producer-side inactive-arm rejection asserts only Error; authority must freeze
   the complete producer tuple. The selected tuple is
   `InvalidPresence / CanonicalSemantic / TypeSchema / None / 0`, with empty bytes
   because no decoder stage or payload coordinate exists (IC-063).

### Confirmed improvements

- canonical payload is now a distinct site and its ownership is tested as non-aliasing;
- the observer is substantially narrower and semantic-blind;
- handle copy now occurs in the active allocation probe;
- the public top-level coordinate domain has 39 rows for `0..38`;
- an independent scanner exists and already owns part of the offset matrix;
- StreamingZero is a static test-side disposition; and
- no public session Budget reset remains.

### Reapproval gate

The next frozen SHA must repair IC-054 through IC-063, pass static forbidden-pattern
and fixture-validity checks, and receive a new independent review with zero Critical
and zero Important. Only then may the complete seven-kind shared-token declaration
and TypeSchema behavior GREEN begin.

## Independent rereview of SHA 12E890... — not approved

After the intervening `AA4808...` candidate was rejected and repaired, the author
froze:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 12E890CA7C905D01839A5FE92DDAEBC59D672CC43836E880A975B83FF86090A1
Bytes: 383981
LF terminators/logical lines: 8930 / 8930
Final LF: yes
CQTest methods: 53 unique
TS-SCR dispositions: 40 Required / 12 StreamingZero / 1 InvalidFixtureOnly
Reference-authority rows: 78 unique
Required dependency variants: exactly 5
```

The fresh independent read-only review returned **NEEDS FIXES — 1 Critical / 2
Important / 1 Minor**. It made no edit, build, test, `Saved/` write or commit.

### Remaining findings

1. **Critical / IC-088:** the layout-input role/presence matrix still invokes
   `Input.Target.Reset()` and assigns a presence bit to Target even though the
   frozen DTO requires a direct `FAngelscriptCacheStableReference`. The next repair
   must enumerate only optional Boundary/Alignment, test direct zero-key, invalid/
   wrong kind and ExpectedAbi rules separately, add an exact member-type assertion,
   and scan every optional-style Target accessor.
2. **Important / IC-086:** changing Typedef subtype storage to
   InvalidFixtureOnly did not create the required allocator-authoritative proof.
   The hostile physical fixture needs exact-capacity semantic rejection, Total/live
   one-byte-short before reserve, target chronology/offset proof, empty output and
   zero live/allocation balance, without closing Required success.
3. **Important / IC-089:** the caller-owned fixed event view is non-growing, but its
   indexed filtered lookup rescans the tagged chronology. The full event comparison
   is still O(E^2). It must become one forward scan and freeze deterministic fixture,
   target and per-SiteKind representative counts.
4. **Minor:** the final coverage diagnostic still describes the old unlimited path;
   it must name exact Total/live common-factory success.

The gate therefore remains closed. The next candidate must repair these findings,
freeze a new exact SHA and receive a fresh independent review with zero Critical and
zero Important before production TypeSchema declarations begin.

### Subsequent declaration-preflight blocker

The exact declaration/file-map inventory then found a distinct Critical contract
problem not counted in the read-only `1C/2I/1M` verdict: the RED still uses
`FAngelscriptCacheScopedTypeSchemaAllocationProbeForTests` around a public
`FAngelscriptDecodedCacheRecord::TryDecode` call which has no observer parameter.
There is no legal connection between that scope and factory without ambient TLS/
global routing. IC-093 requires deletion of the scope API and explicit injection via
a unit-test-only façade which forwards into the same private factory. The third
candidate must include this fix and scan out every scoped/TLS/global active-probe
route before it can be frozen for rereview.

## Preflight of SHA 1A806E... — explicit-authority repair required

The third author candidate was frozen as:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 1A806E00FCA853471BE8C94F646DC2407493272128E9AD3FC09A8EAD9028CAF3
Bytes: 408170
LF terminators/logical lines: 9467 / 9467
Final LF: yes
CQTest methods: 54 unique
```

It closed the direct-Target, hostile-Typedef, explicit caller-owned probe and
single-forward chronology findings. A separate read-only preflight nevertheless
found **IC-097 Important** before exact-SHA approval: its 42-fixture/73-target
selection is still produced by a natural cartesian generator followed by runtime
first-match and `TSet` selection. Literal result checks do not make allocator- and
traversal-dependent selection into source authority.

The candidate is therefore not approved. Its retained fixes remain valid input,
but the next SHA must use explicit tables for:

- 45 named fixtures: 3 shape, 4 occurrence/nested and 38 site-specific slack;
- 73 named targets: 2 fixed, 33 first/middle/last and 38 slack; and
- all 53 SiteKinds with named disposition/count rows, proving 40 Required,
  12 StreamingZero, 1 InvalidFixtureOnly, 11 four-target Required sites, 29
  one-target Required sites and 13 zero-target non-Required sites.

Each fixture is constructed/scanned/planned and full-chronology decoded once.
Runtime resolution may calculate a declared slack row's platform allocator
cardinality, but it cannot discover, add, drop, deduplicate or choose an authority
row. Fresh exact-SHA 0C/0I review remains mandatory.

## Final approval of SHA 60BE380... — approved

The fourth candidate first froze at `548D029...` and received an independent
`0 Critical / 1 Important / 0 Minor` verdict solely because two assertions indexed
`FTsScrFilteredProbeEventViewForTests` with `operator[]`, which that intentionally
restricted view does not provide. Both sites retained their exact-count assertion
and changed only to `FindAtForConstantLookup(0)`.

The repaired authority is:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 60BE380E68EE0E6083F153C69FAD59952C51C84CF9C0A43FBAAE325EEF3C4EB0
Bytes: 447273
LF terminators: 10246, final LF present
CQTest methods: 54 unique
```

A fresh read-only reviewer rehashed this exact file at start, middle and end and
returned **APPROVED — 0 Critical / 0 Important / 0 Minor**. It reconfirmed the
53/40/12/1 site partition, 45 explicit fixtures, 73 explicit targets, 78 relocation
authority rows, five Required dependency variants, direct non-optional layout
Target, hostile Typedef, full coordinate/offset/error-precedence coverage, one
fixture chronology, caller-owned explicit probe, candidate Total/live rollback and
single promotion/publication ordering. Forbidden scans found no runtime authority
search, first-match selection, TSet, natural cartesian discovery, ambient/TLS/global
probe or filtered-view `operator[]`.

This exact SHA was the production declaration/GREEN authority at review time.
Approval did not claim the production TypeSchema header, implementation, build or
Automation was already complete.

## Compile-only repair supersedes the approved SHA — rereview pending

The first complete project TU made previously unreachable test-source syntax
compile and exposed only test-local C++ shape defects: constexpr placement, switch
scope, CQTest one/two-argument assertion dispatch, a value-returning fixture lambda,
two unmatched parentheses and filtered-view constant lookup. Every matcher,
context, authority row, fixture and test method was retained. The two assertion
branches are single `do { ... } while (false)` statements; the contextual branch
calls `TestRunner->AddError(context)` only after the same matcher fails, and the
TU-local macros are undefined at file end.

The replacement file is:

```text
File: Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp
SHA-256: 431F0B494C3ADB738C08D815E59983D353E89C72BEDCCD673BA2677A0E393DF0
Bytes: 448518
LF terminators: 10282, final LF present
CQTest methods: 54 unique
```

After the production value objects gained their complete same-type equality,
SingleFile TU7 compiled this replacement successfully at
`cache-typeschema-production-declaration-tu7/20260808_224717_175_0cf54459/`.
The old `60BE380E...4EB0` approval does not transfer to a different file SHA.
Checkpoint 2.4c is therefore reopened until a fresh independent exact-SHA review
returns zero Critical and zero Important. SingleFile compilation is not link or
Automation GREEN.
