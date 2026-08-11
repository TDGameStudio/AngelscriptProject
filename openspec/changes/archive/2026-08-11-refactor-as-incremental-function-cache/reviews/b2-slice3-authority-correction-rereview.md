# Fresh combined IC-153–IC-155 authority rereview

Date: 2026-08-09 (Asia/Shanghai)
Scope: read-only pre-Slice-3 authority rereview after the isolated IC-154
decoder-cardinality fixture repair. This review did not edit source, tests,
existing OpenSpec records, the rejected review, Git state, or the approved test
candidate. Its only write is this report.

## Verdict

**APPROVED — 0 Critical / 0 Important / 0 Minor.**

The four normative authorities, the correction attachment, the current ledgers,
and the repaired immutable decoder candidate now agree. The prior Important
finding is fully repaired: forbidden count-two coordinates, including every
Compose coordinate, no longer select `ConflictingKey` in the executable
Cartesian fixture. This is authority and exact-candidate readiness only; it is
not a claim that B2, B3, normal-producer behavior, decoder behavior, focused
Automation, or a linked module build is complete.

**Disposition:** IC-153 and IC-154 may close. IC-155 was already correctly
closed. The queued B2 Slice-3 Relations/LayoutInputs test-authoring packet may
now be materialized from repaired candidate SHA-256
`AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`,
subject to its stated scope and the still-open IC-145 behavior/link boundary.

## Frozen identities — start and end

All requested files were hashed immediately before the rereview and again after
the required validation/diff checks. They were unchanged.

| Frozen authority | Start SHA-256 | End SHA-256 |
|---|---|---|
| `type-schema-matrix-v1.md` | `DAB6D0C61F4ADB7F108C703EA785C3713FC9CF0E494E990464CB959D2B95F159` | `DAB6D0C61F4ADB7F108C703EA785C3713FC9CF0E494E990464CB959D2B95F159` |
| `type-layout-authority-v1.md` | `B9D20D1CE6149CF3C595F757FDA37CE6CA08572A039A5E0BB1DF04C33AD844D4` | `B9D20D1CE6149CF3C595F757FDA37CE6CA08572A039A5E0BB1DF04C33AD844D4` |
| `record-wire-v1-remaining.md` | `98121B7B440A340B51C4FF6B2E6C30F1169D9190598DCC2072FFFDD7D6B582B6` | `98121B7B440A340B51C4FF6B2E6C30F1169D9190598DCC2072FFFDD7D6B582B6` |
| `producer-b2-coverage-audit.md` | `4BD7D466EDC60985B556E58AAA9C72C86FDB3959A4684B67A16DCBFBADEB2EC1` | `4BD7D466EDC60985B556E58AAA9C72C86FDB3959A4684B67A16DCBFBADEB2EC1` |
| `reviews/b2-slice3-authority-correction.md` | `6E45A144AE0F1207546ACB76171E6C519C2AA47BB0EB816E3BAB8E5D4DC35483` | `6E45A144AE0F1207546ACB76171E6C519C2AA47BB0EB816E3BAB8E5D4DC35483` |

Read-only integrity identities also matched the brief:

| Artifact | Verified SHA-256 / identity |
|---|---|
| Original Slice-3 audit | `F576A7C5252D72EB79154EF8AA9AC7855EF896CE4291C93BD85CD062662F0E9A` |
| Rejected first review, retained unchanged | `FDC924CF0B95E0D677FFEE722072E943228A8D836766CF297450F6F2AEFB53F4` |
| IC-154 repair report | `D7AE5DE22DE03227B4FEA88C75C9983C2A8902959B18179BA0B2CC1F3E6FDE62` |
| Approved IC-154 repair review | `26C5D7F40B22928380C130732FAA2779C0F4B6A85A0456E64D97FDA63B3B22C8` |
| Repaired plugin blob | `4164f9f66e8f89915d13ae3dc25c131822925b1e` |
| Repaired complete-TU SHA-256, start and end | `AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813` |

The last item was recomputed directly from the plugin Git blob byte stream and
from the current working candidate; both matched. The test candidate remains
58 methods and contains neither planned Slice-3 producer-method name.

## Findings

| Severity | Count | Finding |
|---|---:|---|
| Critical | 0 | None. |
| Important | 0 | None. |
| Minor | 0 | None. |

## Decision verification

### IC-153 — pairing error, phase, and coordinate

**Confirmed.** After both stored references have independently passed their
field-local checks, `BaseType` must equal `Base`, and `CodeRoot` must equal both
`ShadowSuper` and `CodeSuper`, over the complete
`{ReferenceKind, StableKey, ExpectedAbi}` tuple. A mismatch is exactly
`InvalidQualifierCombination / LocalSemantic` at the offending enclosing
`LayoutInput` field offset.

Evidence is identical across correction lines 28-43,
`type-layout-authority-v1.md` lines 299-313,
`type-schema-matrix-v1.md` lines 681-697, and
`record-wire-v1-remaining.md` lines 1828-1833. Those sources consistently keep
missing/extra/wrong roles and optional masks at `InvalidPresence`, malformed
InputKind/reference/key/ABI at their existing field-local errors, and dependency
coverage at the following cross-field phase.

### Local stored coordinates versus ModuleGraph ownership

**Confirmed.** Equality of the stored tuples is a local, allocation-free
contradiction check; it neither resolves an identity nor consults a resolver.
Resolved target existence, entity/reflection category, module/type ownership,
linked declaration ABI, and proof that the shared environment coordinate is the
actual code-root class remain ModuleGraph work. See correction lines 45-49,
`type-layout-authority-v1.md` lines 315-320,
`type-schema-matrix-v1.md` lines 667-675 and 1127-1146, and
`record-wire-v1-remaining.md` lines 1828-1833. There is no duplicate producer
or current-layout resolver implied by the correction.

### IC-154 — cardinality, duplicates, and reference precedence

**Confirmed.** The correction's four-pattern table (lines 51-65) matches the
matrix allowlist and error mapping (`type-schema-matrix-v1.md` lines 622-661 and
681-693):

- `0..N` accepts counts 0, 1, and 2 with distinct legal targets;
- allowed `0..1` and exact-one coordinates use `ConflictingKey` for two
  distinct legal rows, while exact-one count zero is `InvalidPresence`;
- forbidden coordinates use `InvalidPresence` for every nonzero count; and
- identical repeated legal rows are `DuplicateKey`, not a cardinality conflict.

The repaired fixture is the one existing bounded decoder oracle, not a producer
semantic owner. Its local form/kind allowlist is at
`AngelscriptCacheTypeSchemaTests.cpp` lines 8030-8056, and its error precedence
is at lines 8239-8247: success first, then nonzero malformed ScriptFunction
target as `WrongReferenceKind`, then count-two conflict only for an allowed
non-ImplementedInterface singleton, otherwise `InvalidPresence`.

I independently enumerated the full 11 forms × 5 relation kinds × 3
cardinalities × 3 reference cases = **495 cells** from the frozen table and
candidate logic. The independently derived result totals exactly match the
approved repair review: 167 `None`, 208 `InvalidPresence`, 110
`WrongReferenceKind`, and 10 `ConflictingKey`; there were zero mismatches. Every
nonzero Compose cell is `InvalidPresence` for a structurally valid ScriptType or
EnvironmentSymbol target and retains earlier `WrongReferenceKind` for the
malformed ScriptFunction target. Compose cannot reach `ConflictingKey`.

### IC-155 — capture versus archive validation

**Confirmed.** Compose remains a valid-cardinality-zero reserved relation.
Live source capture that observes it is `NotCacheable` and emits no TypeSchema;
an explicit DTO to the serializer or payload to the decoder with any Compose row
is `InvalidPresence / LocalSemantic`. Correction lines 67-76 and
`type-schema-matrix-v1.md` lines 660-675 match the current implementation issue
ledger and distinguish capture planning from archive validation. The distinction
does not add a second error namespace or alter local cardinality precedence.

### Validation order and owner boundaries

**Confirmed.** All normative sources retain the same ordering:

1. physical recursive decode including enum/reference/optional validation and
   complete payload exhaustion;
2. field-local semantic checks in top-level wire order, including Relations then
   LayoutInputs and their individual hashes;
3. cross-field pairing, locally derivable dependency coverage, then layout
   replay;
4. TypeLayoutHash last; then immutable graph validation and current eligibility.

The authoritative text is `type-schema-matrix-v1.md` lines 1075-1125,
`type-layout-authority-v1.md` lines 612-643, and
`record-wire-v1-remaining.md` lines 1791-1833. No corrected rule advances a
hash, graph, or current-resolver error over an earlier local error.

`producer-b2-coverage-audit.md` lines 158-191 and 315-374 preserve normal
producer ownership: future Slice-3 normal-producer rows carry fixed literal
expected results and may not use a test-side semantic predicate, decoder,
resolver, or graph as their behavioral oracle. B3 remains responsible for
routing producer and decoder through the sole production canonical-local
validator; this rereview does not authorize B3 behavior work.

## Prior Important finding: complete and honest disposition

The rejected first review is still present at its original SHA and remains
rejected discovery evidence. Correction lines 101-125 and the repair report/
review explicitly acknowledge that it found the existing Cartesian fixture's
forbidden count-two misclassification. The repair changed the exact immutable
candidate from blob `64478db37c4dfb8613b3b5f1d5aba501eb8f4cc0` to
`4164f9f66e8f89915d13ae3dc25c131822925b1e`, added only the method-local
allowlist plus its use in the count-two branch (28 insertions, zero deletions),
and received the independent 495-cell zero-mismatch review.

Current ledgers record this accurately as an approved IC-154 executable repair
pending this combined rereview: `status.md` lines 29, 43, 110-112 and 138-142;
`verification.md` lines 393-459; `implementation-issues.md` lines 31-33; and
`implementation-plan.md` lines 276-354. They do not misstate the prior compile
artifact as focused behavior: IC-145 remains open, and the repair evidence is a
SingleFile complete-TU compile frontier only.

## Required validation and diff checks

Fresh commands executed in this rereview:

```text
openspec validate refactor-as-incremental-function-cache --strict
  → exit 0: Change 'refactor-as-incremental-function-cache' is valid

git -C D:\Workspace\AngelscriptProject\.worktree\as-cache diff --check
  → exit 0

git -C D:\Workspace\AngelscriptProject\.worktree\as-cache\Plugins\Angelscript diff --check
  → exit 0
```

The parent/plugin checks reported no whitespace errors. Git emitted only line-
ending conversion warnings on unrelated pre-existing dirty files; none was
changed by this rereview. The frozen authority and repaired-test identities were
then recomputed and remained exactly as shown above.

## Evidence ceiling

This report establishes fresh document/ledger/immutable-test consistency and
required repository validation only. It intentionally does not claim or rerun
focused Automation, full module link, decoder behavior, normal-producer RED,
B2 completion, B3 completion, or Runtime implementation correctness. The prior
SingleFile artifact is recorded only as independently reviewed complete-TU
compile evidence.
