# B2 Slice 3 authority correction

Date: 2026-08-09, Asia/Shanghai
Scope: IC-153–IC-155 Relations/LayoutInputs normal-producer packet correction
Evidence level: normative OpenSpec clarification before Slice-3 test authoring;
no source, build, Automation or behavior claim.

## Discovery

The read-only Slice-3 audit correctly found that the frozen documents ordered
relation-to-LayoutInput pairing but did not name the exact error for two
individually valid stored targets that disagree. A root reread also found two
packet hazards. The later independent review established that the first hazard
was already present in the existing decoder Cartesian fixture and therefore must
be repaired before new Slice-3 test authoring:

1. the audit generalized a two-row `ConflictingKey` result to relation kinds
   whose legal cardinality is zero, although the normative relation table maps a
   disallowed kind/cardinality to `InvalidPresence`; and
2. the sentence “a producer seeing Compose returns NotCacheable” did not
   distinguish live capture eligibility from explicit DTO/payload validation,
   whose disallowed-relation result is `InvalidPresence`.

## Frozen decisions

### Pairing mismatch

The exact local pairing error is
`EAngelscriptCacheValidationError::InvalidQualifierCombination`.

The boundary is deliberately narrow:

- role absence/extra/wrong role and wrong optional mask remain
  `InvalidPresence`;
- malformed InputKind/reference kind/key/ABI retain their common field-local
  error;
- once both stored references are individually valid, BaseType must equal Base
  and CodeRoot must equal both ShadowSuper and CodeSuper over the exact
  `{ReferenceKind, StableKey, ExpectedAbi}` tuple;
- inequality of those valid tuples is the contradictory combination and returns
  `InvalidQualifierCombination` at the LayoutInput enclosing-field offset; and
- dependency coverage is later and retains `MissingCoverage`,
  `UnexpectedRecord` or common conflict errors.

The local pass compares stored coordinates only. ModuleGraph still resolves the
target and owns entity/reflection category, owner, linked ABI and proof that the
common environment coordinate denotes the actual code-root class. The phrase
“same-code-root constraints are graph-owned” therefore means resolved semantics,
not permission for three stored coordinate tuples to disagree locally.

### Relation cardinality table

The exhaustive table must apply these fixed rules per form/kind/count cell:

| Frozen cardinality | Count 0 | Count 1 | Count 2 with distinct valid targets |
|---|---|---|---|
| `0..N` | Success | Success | Success |
| `0..1` | Success | Success | `ConflictingKey` |
| exactly `1` | `InvalidPresence` | Success | `ConflictingKey` |
| forbidden (`0`) | Success | `InvalidPresence` | `InvalidPresence` |

An identical repeated row is separately `DuplicateKey` and must use a legal
relation form so duplicate detection is not conflated with a forbidden form.
`ConflictingKey` applies to an allowed singleton coordinate with two distinct
targets, not to a relation kind whose valid maximum is zero.

### Compose capture versus archive behavior

Compose remains reserved and has valid cardinality zero in Cache V1.

- Live source capture that observes Compose makes that module NotCacheable and
  must not emit a TypeSchema.
- The normal TypeSchema serializer and decoder are validation boundaries, not
  the capture planner. An explicitly supplied DTO/payload with one or more
  Compose rows returns `InvalidPresence/LocalSemantic` as a disallowed relation
  kind/cardinality.

## Packet impact

The existing decoder Cartesian fixture must first be repaired so its executable
expectations use the same four-pattern authority: a count-two result is
`ConflictingKey` only when the selected form/kind coordinate permits a singleton;
a forbidden coordinate remains `InvalidPresence`. The existing earlier
`WrongReferenceKind` precedence for a nonzero malformed target remains unchanged.

After that repair receives exact-SHA review, the Slice-3 implementation brief
must treat the read-only audit as superseded on these three points. It may reuse
the audit's obligation inventory and exclusions, but its fixed table data must
use this correction and the amended normative documents. No production helper or
second semantic validator may calculate test expectations.

Before authoring new Slice-3 assertions, require a complete-TU compile and
independent exact-SHA review of the decoder fixture repair, strict OpenSpec
validation, and a fresh independent read-only review of this correction against:

- `type-schema-matrix-v1.md` sections 6 and 11;
- `type-layout-authority-v1.md` sections 6 and 10;
- `record-wire-v1-remaining.md` local validation order; and
- `producer-b2-coverage-audit.md` sections 4.4–4.5.

## Review and repair disposition

The first independent authority review,
`b2-slice3-authority-correction-review.md`, SHA-256
`FDC924CF0B95E0D677FFEE722072E943228A8D836766CF297450F6F2AEFB53F4`,
returned 0 Critical / 1 Important / 0 Minor. It found that the existing decoder
Cartesian fixture already implemented the audit's forbidden count-two
misclassification. That review is retained as rejected discovery evidence; it is
not overwritten or treated as approval.

The isolated executable repair is now immutable:

- starting Slice-2 plugin blob
  `64478db37c4dfb8613b3b5f1d5aba501eb8f4cc0`;
- repaired plugin blob `4164f9f66e8f89915d13ae3dc25c131822925b1e`;
- repaired complete-TU SHA-256
  `AA41A0ADCD14B3151DF95E36C4B49E05C8E4D8737E239652CE88C515EADA6813`;
- 28 insertions, zero deletions, still 58 methods; and
- complete-TU SingleFile compile artifact
  `Saved/Build/cache-b2-slice3-decoder-cardinality-authority-repair-tu/20260809_031909_287_9b3b7e4a/`,
  wrapper/process exit `0/0`, exactly one compile action and no diagnostics.

Fresh exact-SHA source review
`.superpowers/sdd/b2-slice3-decoder-cardinality-repair-review.md`, SHA-256
`26C5D7F40B22928380C130732FAA2779C0F4B6A85A0456E64D97FDA63B3B22C8`,
returned **APPROVED — 0 Critical / 0 Important / 0 Minor** after independently
enumerating all 495 form/kind/cardinality/reference cells with zero mismatch.

This closes the executable repair review, not the whole correction packet. A
fresh read-only authority rereview must still confirm the amended normative
documents, this attachment and the repaired exact test candidate agree before
IC-153/IC-154 close or Slice 3 begins.
