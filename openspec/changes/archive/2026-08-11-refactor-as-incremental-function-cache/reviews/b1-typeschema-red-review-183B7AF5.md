# B1 TypeSchema RED independent rereview — 183B7AF5

Date: 2026-08-09
Review mode: fresh, read-only, exact-SHA, complete-candidate independent rereview
Verdict: **APPROVE — 0 Critical / 0 Important / 0 Minor**

## Reviewed identity and frozen evidence

The candidate was recomputed at the start of this rereview and exactly matched
the amended B1 packet:

- candidate:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`;
- SHA-256:
  `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`;
- 467,181 bytes, 10,678 LF bytes, zero CR/CRLF bytes, 55 `TEST_METHOD`
  definitions and final LF;
- fresh single-TU artifact:
  `Saved/Build/cache-b1-typeschema-red-tu-rereview/20260809_012321_011_77e2f449`;
- `RunMetadata.json` records the exact worktree project, UE 5.8, the exact
  candidate in `-SingleFile`, `-NoHotReloadFromIDE`, `TimedOut=false`,
  `ProcessExitCode=0` and `ExitCode=0`; `Build.log` records exactly
  `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` and
  `Result: Succeeded`.

I reviewed the complete exact candidate, not only the amended hunk. As an
additional whole-file regression proof, removing candidate lines 6175–6181
in memory removes exactly 328 bytes and 7 LF bytes and reconstructs the
rejected predecessor byte-for-byte:

- reconstructed predecessor SHA-256:
  `A6EE78A19AC83A6F93AB86AD2072BF7E0758C0B699436D46D396DCAEB19CE66A`;
- reconstructed predecessor shape: 466,853 bytes and 10,671 LF bytes.

Therefore the amended exact candidate is the previously complete-reviewed
file plus only the intended seven-line IC-144 repair. I regressed all findings
and passed checks from
`reviews/b1-typeschema-red-review-A6EE78A1.md`; none of the previously reviewed
10,671 LF bytes changed.

The current B1 packet is frozen at `implementation-plan.md:276-347`. It names
this exact amended SHA and shape at lines 291-295, requires exact-candidate
IC-138/139, literal-hash, sentinel/input and no-duplicate-oracle review at lines
335-339, and leaves focused behavior execution `N/A` until the later private
decoder/full-module linkage at lines 343-347. I also reviewed the current issue
definitions at `implementation-issues.md:28-60` and the IC-144 amendment record
at lines 134-165.

During the rereview, the primary agent appended IC-145 and corresponding B3
link-prerequisite wording at `implementation-issues.md:167-185` and
`implementation-plan.md:136-153`. That non-normative scheduling clarification
does not alter B1 acceptance, IC-138/139/144, this candidate, Runtime or any of
the four frozen authorities. I recomputed all six frozen code/authority
identities after the append. This report does not review or approve IC-145/B3.

The four frozen authorities were rechecked at their unchanged exact identities:

- `type-layout-authority-v1.md`, SHA-256
  `1BECE7C51AB4D6185273DABD7ABE17DFEE36EC408775A21F0B0723C7C3C0F253`;
- `type-schema-matrix-v1.md`, SHA-256
  `14465BC4BE414B4EDBA18DD1E41F3963E82943193264DD35AFF80B507D9973AD`;
- `record-wire-v1-remaining.md`, SHA-256
  `9F9B19DF727BD07FC6A16555638D6A473C6DBDB4E3F92FDB5C8BCE9A33DAC71C`;
- `remaining-record-captured-offsets-v1.md`, SHA-256
  `8A0F30ACB8A4FBD226F5ADBAA69BB9C302C7A2EB9AAA2AD5A705B38E097F7EA3`.

## IC-144 repair and normal-producer boundary

The sole Important finding in the predecessor review is fixed without widening
the test-local semantic boundary.

### Isolated fixture

The amended case at candidate lines 6175-6180:

1. obtains `MakeMinimalSchema(Class)`;
2. adds only the unknown `TypeSemanticFlags` bit `0x100u`;
3. recomputes its derived hashes through `FinalizeValidFixtureHashes`;
4. calls `ExpectExactProducerFailureAndInputUnchanged`; and
5. expects exactly `UnknownFlags` with the context
   `unknown TypeSemanticFlags bit`.

The baseline is valid and isolated. `MakeMinimalSchema` gives Class exactly the
known `ReferenceType` semantic flag, zero semantic size, alignment 8 and no
reflection at candidate lines 428-434, then finalizes its hashes at line 474.
The amendment changes no kind, name, relation, property, method, behavior,
reflection, dependency or selected-arm field.

The second rehash is material rather than cosmetic. The shared fixture helper
at candidate lines 178-209 recomputes all present LayoutInput, property, Enum
and TypeLayout derived hashes. For this minimal Class only TypeLayoutHash is
present. The production `ComputeTypeLayoutHash` writes the raw
`TypeSemanticFlags` into its canonical stream at
`AngelscriptCacheTypeSchema.cpp:1618`; its entry validation at lines 1535-1543
checks only the stable type key and TypeKind range. Consequently the rehash
succeeds and incorporates `0x100u`; the producer failure cannot be explained by
a stale derived hash.

### Real producer call and exact failure tuple

The assertion helper at candidate lines 798-840 uses the guarded physical
writer only for before/after immutable-input snapshots. The behavior under test
is the real production
`FAngelscriptCacheTypeSchemaArchive::SerializeTypeSchema` call at lines
813-815. It asserts:

- the exact expected error at lines 816-817;
- the error-derived Class at lines 818-820;
- `RecordKind=TypeSchema` at lines 821-823;
- `Stage=None` at lines 824-826;
- `ByteOffset=0` at lines 827-828;
- atomically cleared sentinel output at lines 812 and 829-830; and
- byte-identical physical input semantics before and after the call at lines
  805-810 and 832-839.

That tuple matches the frozen producer-side rule: an inactive producer
coordinate is exactly `{TypeSchema, None, 0}`, with empty output and no input
mutation. The producer API receives no read Budget, captured-offset table or
current resolver, so the case is independent of all three.

Runtime inspection confirms the production boundary rather than a test
surrogate. `SerializeTypeSchema` resets output, copies/canonicalizes the input,
calls `ValidateProducerShape`, and writes only after validation at
`AngelscriptCacheTypeSchema.cpp:1636-1652`. The producer validator rejects any
bit outside `KnownMask` as `UnknownFlags` at lines 483-487. The test therefore
exercises a normal returned result; it does not depend on a missing symbol,
crash/check-only path, test-local validator or decoder result.

### IC-138 span and B1/B2 disposition

The normal-producer method now occupies candidate lines 5960-6256 and makes 33
calls through the exact-result/immutability helper. It spans the IC-138 B1
representatives: duplicate/conflicting singleton keys, unknown enum values,
the new unknown flag, ordinal gaps, shape/presence/owner/flag-combination and
dependency failures, while retaining immutable layout replay and atomic output
proof.

This closes the specific IC-144 review finding and its exact-SHA rereview
acceptance condition. The issue ledger still says “rereview pending” because
this review was authorized to write only this report; the primary agent can now
mark IC-144 closed using this evidence. B2 remains correctly responsible for a
future normal-producer RED for every canonical-local semantic obligation, as
specified by `implementation-plan.md:134-141` and
`implementation-issues.md:161-165`. That exhaustive expansion is not a missing
B1 requirement and produces no finding here.

## IC-139 literal vectors — fresh independent recomputation

The frozen literal region at candidate lines 5802-5846 is byte-identical to the
reviewed predecessor and was independently recomputed again for this exact
candidate.

I constructed the canonical streams independently, without calling
`ComputeLayoutInputHash`, `ComputeEnumAuthorityHash`, a production canonical
writer, or any test-local expected-hash helper. The reconstruction used:

- ASCII `UEAS-ARTIFACT`, NUL, identity-schema `u32le(1)` and a
  length-prefixed UTF-8 domain;
- exact little-endian scalar, bool/optional tag and full 32-byte hash encoding;
- `CodeRoot=2`, `EnvironmentSymbol=7`, key bytes `a4*32`, ABI bytes `a5*32`, a
  present-zero boundary and a present alignment;
- TypeKey bytes `41*32`, three ordered enum rows, signed values encoded as
  fixed-width two's-complement `u32le`, and independently canonicalized
  metadata.

Fresh independent BLAKE3 results were:

| Vector | Canonical bytes | Independently recomputed BLAKE3 | Candidate literal |
|---|---:|---|---|
| LayoutInput alignment 8 | 124 | `19903c25b6a2d207614125561a1285221a021062c8219ba41c85a84b89abd04c` | exact match, lines 5811-5813 |
| LayoutInput alignment 16 | 124 | `c36d242e8b167abedfad69a23577d0651e9e0edab2118d95dcccd448b67a9ac7` | exact match, lines 5818-5820 |
| Enum enumerator 2 = `MAX_int32` | 194 | `bc379827084ce82a8635f56600fae4de208534bf92a6d229ab0fa3688fce58e1` | exact match, lines 5834-5836 |
| Enum enumerator 2 = `MIN_int32` | 194 | `ef456bfeaf07d858e493bd128c2f90534a225bf716854b62113ff14d3d5053ad` | exact match, lines 5842-5844 |

Each mutation changes one semantic field and produces a distinct digest. The
candidate obtains only the observed production hash and compares it with a
literal. It contains no second expected-value hash oracle. IC-139's literal
region therefore did not regress and its exact-current-candidate evidence is
accepted.

## Complete-candidate regression checks

### No forbidden semantic decoder, hash oracle or writer duplicate

The exact candidate contains no reference to
`FAngelscriptArtifactCanonicalWriter`, no `FBlake3::HashBuffer`/local `blake3`
expected-hash implementation and no local `SerializeTypeSchema` definition.
The physical writer remains confined to physically representable hostile
decoder fixtures and immutable-input snapshots; it does not supply normal
producer semantics.

The sole `FIndependentTypeSchemaWireScannerForTests` begins at candidate lines
2048-2096. It scans raw wire bytes for physical boundaries, captured
coordinates and stable-reference occurrences. Its contract at lines 2336-2338
explicitly excludes DTOs, writer traces, captured tables and decoder events as
the source of expected offsets/cardinality. It does not publish a decoded DTO,
validate semantic legality or compute any expected hash. It remains the
independent raw offset/TS-SCR oracle required by the frozen allocation and wire
authorities, not a duplicate semantic decoder.

### Frozen diagnostics, offsets and precedence

The unchanged complete-file portions retain the predecessor's accepted
consistency with all four frozen authorities:

- normal producer failures use the inactive `{TypeSchema, None, 0}` coordinate,
  clear output and preserve input;
- decoder failures clear sentinel token output and use independently scanned
  enclosing-field offsets;
- physical exhaustion precedes semantic and derived-hash validation at
  candidate lines 9090-9159;
- derived-hash and field-local/layout replay precedence remains frozen at
  candidate lines 9160-9358;
- the append-only TypeSchema captured-coordinate and P/S/T usage remain
  consistent with the frozen `0..38` contract; and
- `remaining-record-captured-offsets-v1.md` governs the other four record kinds
  and introduces no competing TypeSchema coordinate rule.

No amendment touched the scanner, diagnostic, precedence, hostile physical
fixture or literal regions. The exact predecessor reconstruction above proves
that those accepted bytes are unchanged.

## Final disposition

**APPROVE — 0 Critical / 0 Important / 0 Minor.**

The amended exact candidate satisfies the B1 review gate. IC-144's missing
normal-producer unknown-flag representative is now isolated, rehashed, routed
through the real production entry, and checked for the exact inactive tuple,
sentinel clearing and input immutability. IC-139's four literal hashes freshly
recompute, and the complete candidate introduces no forbidden semantic decoder,
hash oracle or production-writer duplicate. The candidate SHA was unchanged at
the end of content review. Post-write verification recomputed the candidate as
SHA-256 `183B7AF583AD723963F5632BC7EDFBB10AA44F3C84DB3F8232D817A7C5B6F269`,
467,181 bytes, 10,678 LF, zero CR/CRLF, 55 methods and final LF; it is identical
to the candidate accepted above.
