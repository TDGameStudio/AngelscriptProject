# B2 Slice-3 authority-correction review

Date: 2026-08-09 (Asia/Shanghai)
Reviewer scope: read-only authority review of IC-153 through IC-155. No source,
candidate, normative-document, OpenSpec-record, Git-state, or test edit was
made by this review.

## Verdict

**NOT APPROVED — 0 Critical / 1 Important / 0 Minor.**

The amended normative authority answers IC-153, IC-154, and IC-155 coherently.
However, the correction packet's statement that no test source used the flawed
forbidden-cardinality table is false: the current decoder Cartesian fixture
still calculates `ConflictingKey` for a two-row forbidden `Compose` relation.
That is an Important contradiction in the reviewed packet because it preserves
the very error classification IC-154 corrects and will disagree with the
amended authority when that fixture or the decoder is brought into conformance.
Approval requires that existing fixture/issue-record discrepancy to be
reconciled in its owning change before Slice-3 is authorized.

## Exact correction identity and review integrity

| Item | SHA-256 before review | SHA-256 after review | Result |
|---|---|---|---|
| `.superpowers/sdd/b2-slice-3-authority-audit.md` | `F576A7C5252D72EB79154EF8AA9AC7855EF896CE4291C93BD85CD062662F0E9A` | same | Matches the requested `F576…` discovery-audit identity. |
| `reviews/b2-slice3-authority-correction.md` | `E0A2D85DC1170E913267BAE016FF72CF632C8C10B1D0D96D615A7709BED5B47E` | same | Matches the requested `E0A2…` correction identity; it was not changed. |

The only file written in this review is this report. The report SHA is not a
substitute for either reviewed artifact identity.

## Authority determinations

### 1. Individually valid stored tuple mismatch

**Confirmed.** Once field-local reference validation has passed, a differing
stored `{ReferenceKind, StableKey, ExpectedAbi}` tuple is exactly
`InvalidQualifierCombination / LocalSemantic` at the enclosing `LayoutInput`
field offset.

Evidence:

- Correction lines 26-41 expressly set the literal error, retain
  `InvalidPresence` for missing/extra/wrong role or optional masks, retain
  common field-local errors for malformed references, and put dependency
  coverage later.
- `type-layout-authority-v1.md` lines 299-313 gives the same exact pairing
  predicate and error/offset. `type-schema-matrix-v1.md` lines 681-697 repeats
  it in the relation error table.
- `record-wire-v1-remaining.md` lines 1815-1833 places pairing after all
  field-local checks and restates the exact error and LayoutInput offset.
- The older audit had identified this as unresolved rather than silently fixing
  it (audit lines 187-202); its now-proposed pair rows are at lines 169-170 and
  183.

This is also compatible with the frozen local precedence: Relations and
LayoutInputs are validated field-locally first; pairing comes before dependency
coverage, layout replay, and TypeLayoutHash. See `type-schema-matrix-v1.md`
lines 1077-1121 and `type-layout-authority-v1.md` lines 612-643.

### 2. Local stored-coordinate equality versus graph ownership

**Confirmed.** The amendment deliberately checks equality of stored bytes of
the three coordinates; it does not resolve what those coordinates denote.

Evidence:

- Correction lines 43-47 reserve resolved entity/reflection category, owner,
  linked ABI, and proof of the actual code-root class for `ModuleGraph`.
- `type-layout-authority-v1.md` lines 315-320 says the same: local equality is
  allocation-free and does not move resolved same-code-root validation out of
  the graph pass.
- `type-schema-matrix-v1.md` lines 667-675 separates raw stored-coordinate
  equality from resolved target category, actual same-code-root, owner, linked
  ABI, and closure. Its graph order resolves relations and their ABI at lines
  1129-1146.
- The wire authority confirms that this is raw stored-coordinate equality only
  and reserves target/category/owner/ABI/code-root semantics to ModuleGraph
  (`record-wire-v1-remaining.md` lines 1828-1833).

The remaining graph wording that LayoutInput targets “exactly match” relation/
dependency authorities (`type-layout-authority-v1.md` lines 412-429) is
reachable only as a defensive recheck after local validation. It does not
provide a second error mapping or override the explicitly earlier local pairing
rule, so it is not a contradictory result contract.

### 3. Cardinality, duplicate, and conflict mapping

**Confirmed in the amended normative authority.** The correction's four-case
table is sound:

- `0..N`: two distinct legal rows are valid;
- allowed singleton (`0..1`) and required singleton (exactly `1`): two distinct
  legal rows are `ConflictingKey`;
- forbidden (`0`): one or two rows are `InvalidPresence`; and
- an identical duplicate is separately `DuplicateKey` on a legal relation
  form.

This follows the cardinality allowlist and Compose-zero rule in
`type-schema-matrix-v1.md` lines 622-661, and its error mapping at lines
681-693. It is repeated literally by correction lines 49-63. The normal-
producer coverage attachment directs tests to every form/kind/cardinality,
including always-forbidden Compose (`producer-b2-coverage-audit.md` lines
158-171), while its required normal-producer expectation is a direct literal,
not a predicate (`producer-b2-coverage-audit.md` lines 315-337).

### 4. Live Compose eligibility versus explicit DTO/payload validation

**Confirmed.** These are different boundaries, with no error-namespace
collision:

- live capture observing Compose is `NotCacheable` and emits no TypeSchema;
- an explicit DTO passed to the normal serializer or an explicit payload passed
  to the decoder carries a nonzero forbidden relation and is
  `InvalidPresence / LocalSemantic`.

The correction states this at lines 65-74; the matrix now states both outcomes
at lines 660-675; the issue record closes IC-155 with the same boundary at
`implementation-issues.md` lines 425-438. Existing decoder coverage already
expects a single Compose row to be `InvalidPresence`
(`AngelscriptCacheTypeSchemaTests.cpp` lines 7838-7848), which supports the
DTO/payload half of the split.

### 5. Amended-document synchronization and precedence

**Confirmed for the four nominated amended authorities.** The correction is
mirrored consistently by:

| Authority | Matching evidence |
|---|---|
| `type-schema-matrix-v1.md` | Local raw-coordinate equality versus graph-resolved semantics, Compose split, the exact pairing literal/error offset, and the local-before-cross-field order: lines 667-675, 681-697, 1075-1125. |
| `type-layout-authority-v1.md` | Exact role matrix, tuple predicate, error mapping, graph boundary, and validation order: lines 256-320 and 612-643. |
| `record-wire-v1-remaining.md` | TypeSchema wire order, global validation precedence, and the exact pairing rule: lines 775-814 and 1791-1833. |
| `producer-b2-coverage-audit.md` | Relations/Compose coverage, literal pairing result, no resolver/graph oracle, and scenario ownership: lines 158-191 and 315-374. |

All four preserve the required ordering: full physical exhaustion; field-local
checks in wire order; relation-to-LayoutInput pairing; locally derivable
dependency coverage; layout replay; TypeLayoutHash; then graph and current
eligibility. The correction neither moves a graph resolver into the producer
nor changes a hash/error winner.

## Finding

### Important — existing decoder Cartesian fixture still asserts the superseded forbidden-two-row result

**Evidence.** `AngelscriptCacheTypeSchemaTests.cpp` lines 7989-8236 is the
existing decoder-only form/kind/cardinality Cartesian fixture. It creates
`Compose` rows because the loop covers raw relation kinds `1..5` (lines
8024-8033), and it uses up to two distinct targets (lines 8072-8114). For a
non-success case, the expected error is calculated as `ConflictingKey` whenever
`Cardinality == 2` and the kind is not `ImplementedInterface` (lines 8212-8219).
Therefore a two-row forbidden Compose case with an otherwise locally legal
`ScriptType` target is still asserted as `ConflictingKey`, rather than the
corrected `InvalidPresence`.

This directly contradicts correction lines 53-63 and the matrix's
“disallowed relation kind/cardinality” mapping at
`type-schema-matrix-v1.md` lines 681-693. It also contradicts the IC-154 close
claim that “no test source used the flawed table”
(`implementation-issues.md` lines 409-423).

**Why Important.** The error is not a harmless prose mismatch: this decoder
fixture is an executable authority check for the same TypeSchema relation
contract. Leaving it unchanged makes the test suite preserve the obsolete
classification, masks a source correction, and leaves Slice-3 implementers with
two incompatible asserted outcomes for the same two-row forbidden relation.

**Required disposition (not performed by this review).** Correct the decoder
fixture's expected-result logic or replace it with fixed cardinality data that
maps every forbidden nonzero cardinality to `InvalidPresence`; then revise the
IC-154 “no test source” assertion to match the resulting evidence. Rerun the
independent authority review against the resulting exact SHA before approving
Slice 3.

## Existing implementation/fixture boundary observed

The present producer does not yet implement this corrected behaviour:
`SerializeTypeSchema` copies/canonicalizes and calls `ValidateProducerShape`
(`AngelscriptCacheTypeSchema.cpp` lines 1635-1652); that validator currently
only recomputes LayoutInput hashes in this area (lines 562-575), rather than
performing the new relation/form/role/pairing semantic pass. This is expected
future RED scope, not a second finding. Conversely, no existing decoder pairing
fixture was located; the audit accurately describes those as future pair rows
(audit lines 169-170 and 183).

## Evidence ceiling

This was a document-and-existing-fixture/source inspection only. I read the
full requested discovery audit (SHA `F576…`), the full correction attachment
(SHA `E0A2…`), the amended relevant sections of all four named authorities,
design validation/ownership ordering, the issue record, the existing TypeSchema
decoder fixtures, and the current producer entry point. I did **not** run
OpenSpec validation, build, Automation, decoder, or producer tests; I did not
write a Slice-3 brief or tests. Consequently this verdict establishes
authority/fixture consistency only, not runtime correctness or passing test
status.
