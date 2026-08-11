# B1 TypeSchema RED independent review — A6EE78A1

Date: 2026-08-09
Review mode: fresh, read-only, exact-SHA, line-by-line independent review
Verdict: **NEEDS FIXES — 0 Critical / 1 Important / 0 Minor**

## Reviewed identity and evidence

The candidate was recomputed before review and exactly matched the frozen B1
packet:

- candidate:
  `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypeSchemaTests.cpp`;
- SHA-256:
  `A6EE78A19AC83A6F93AB86AD2072BF7E0758C0B699436D46D396DCAEB19CE66A`;
- 466,853 bytes, 10,671 LF bytes, 55 `TEST_METHOD` definitions, final LF;
- fresh single-TU artifact:
  `Saved/Build/cache-b1-typeschema-red-tu/20260809_010843_164_0d3abd53`;
- `RunMetadata.json` records the exact candidate as `-SingleFile`, includes
  `-NoHotReloadFromIDE`, and records `ProcessExitCode=0`, `ExitCode=0`, and no
  timeout; `Build.log` records
  `[1/1] Compile [x64] AngelscriptCacheTypeSchemaTests.cpp` and
  `Result: Succeeded`.

The UE 5.8 toolchain in that artifact is consistent with the current B1 packet:
IC-142 corrects the stale UE 5.7 wording at
`implementation-issues.md:93-109`, and IC-143 freezes the executable
`-ExtraArgs` form at `implementation-issues.md:111-130`.

I read the complete candidate and the complete current versions of all four
frozen authorities:

- `type-layout-authority-v1.md`, SHA-256
  `1BECE7C51AB4D6185273DABD7ABE17DFEE36EC408775A21F0B0723C7C3C0F253`;
- `type-schema-matrix-v1.md`, SHA-256
  `14465BC4BE414B4EDBA18DD1E41F3963E82943193264DD35AFF80B507D9973AD`;
- `record-wire-v1-remaining.md`, SHA-256
  `9F9B19DF727BD07FC6A16555638D6A473C6DBDB4E3F92FDB5C8BCE9A33DAC71C`;
- `remaining-record-captured-offsets-v1.md`, SHA-256
  `8A0F30ACB8A4FBD226F5ADBAA69BB9C302C7A2EB9AAA2AD5A705B38E097F7EA3`.

I also reviewed IC-138/139 at `implementation-issues.md:26-58` and the
current B1 packet at `implementation-plan.md:265-331`.

## Finding

### I-1 — the normal producer RED omits the explicitly required unknown-flag result case

IC-138 requires exact **producer result** cases spanning
“conflict/duplicate, unknown enum/flag, ordinals, shapes and immutable layout
replay” (`implementation-issues.md:34-40`). The B1 packet says the exact current
candidate must be reviewed for IC-138/139 coverage and requires zero Important
findings (`implementation-plan.md:319-323`). This is a current B1 acceptance
condition, not merely a later exhaustive-B2 aspiration.

The sole normal-producer canonical-local method is
`NormalProducerRejectsCanonicalLocalSemanticViolationsAtomically` at candidate
lines 5960-6249. Its 32 calls through
`ExpectExactProducerFailureAndInputUnchanged` cover:

- duplicate and conflicting layout inputs at lines 5962-5977;
- ordinal failures across relations, properties, methods, VFT, behaviors,
  reflected members and enum rows at lines 5979-5998, 6078-6100, 6138-6158,
  6204-6209 and 6219-6224;
- shape/presence/owner/flag-combination/dependency failures at lines
  6000-6043, 6059-6076, 6087-6136 and 6145-6248;
- two unknown-enum producer results (`PropertyStorageKind=3` and
  `MemberAccess=4`) at lines 6045-6057.

It contains no producer call whose expected result is `UnknownFlags` and no
invalid high flag bit. The nearby exhaustive type-flag test does not close this
producer obligation: the loop is bounded to `Mask <= 0xff` at lines 6262-6267,
uses the normal producer only for expected-valid masks at lines 6274-6278, and
routes invalid masks through `SerializeTypeSchemaPhysicalForTests` and the
decoder at lines 6280-6307. Its explicit high-bit case sets `0x100` but again
calls `DecodePhysicalOnlyFixture` and asserts a decoder-side `UnknownFlags /
LocalSemantic` result at lines 6311-6318. The other paired high-bit example at
lines 9262-9271 is likewise a physical-writer/decoder fixture. Decoder coverage
does not prove the IC-138 normal producer boundary.

This omission is Important because the required B1 disposition is 0C/0I and
because producer-side unknown-bit rejection is an explicit named member of the
IC-138 evidence set. Add at least one self-consistent normal-producer fixture
with a valid baseline TypeKind and one high unknown semantic-flag bit (for
example `TypeSemanticFlags |= 0x100u`), recompute the fixture's derived hashes so
the high bit is the isolated first fault, and route it through
`ExpectExactProducerFailureAndInputUnchanged` expecting `UnknownFlags`. That
must preserve the same exact producer tuple, sentinel clearing and input
immutability assertions as the other producer cases.

#### B1/B2 boundary disposition

There is no irreconcilable plan contradiction and therefore no separate plan
finding. `implementation-plan.md:134-137` assigns B2 the larger job of adding a
normal-producer RED for **every** canonical-local obligation. That future
exhaustive expansion is additive. It does not waive B1's current, narrower but
explicit IC-138 spanning gate, which independently names both unknown enum and
unknown flag. The missing unknown-flag representative is consequently a B1
candidate defect; the remaining not-yet-exhaustive cells belong to B2 and are
not charged as additional B1 findings.

## Checks that passed

### IC-139 literal hash vectors independently recompute

Candidate lines 5802-5822 contain literal expected hex for the CodeRoot
`LayoutInputHash` baseline and a mutation changing only
`AlignmentContribution` from 8 to 16. Candidate lines 5824-5846 contain literal
expected hex for the three-row `EnumAuthorityHash` baseline and a mutation
changing only enumerator 2 from `MAX_int32` to `MIN_int32`.

I independently constructed the canonical streams from the frozen rules, not
from `ComputeLayoutInputHash`, `ComputeEnumAuthorityHash`, a production writer,
or a test-local hash helper. The independent stream used:

- `UEAS-ARTIFACT`, NUL, identity schema `u32le(1)`, and length-prefixed UTF-8
  domain;
- exact little-endian scalar, bool/optional-tag and full 32-byte hash encoding;
- `CodeRoot=2`, `EnvironmentSymbol=7`, key bytes `a4*32`, ABI bytes `a5*32`,
  present-zero boundary, and present alignment;
- TypeKey bytes `41*32`, three ordered enum rows, signed values encoded as
  fixed-width two's-complement `u32le`, and independently sorted canonical
  metadata.

An independent BLAKE3 implementation, first checked against the standard empty
input digest
`af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262`,
produced:

| Vector | Canonical bytes | Independently recomputed BLAKE3 | Candidate literal |
|---|---:|---|---|
| LayoutInput alignment 8 | 124 | `19903c25b6a2d207614125561a1285221a021062c8219ba41c85a84b89abd04c` | exact match, lines 5811-5813 |
| LayoutInput alignment 16 | 124 | `c36d242e8b167abedfad69a23577d0651e9e0edab2118d95dcccd448b67a9ac7` | exact match, lines 5818-5820 |
| Enum enumerator 2 = `MAX_int32` | 194 | `bc379827084ce82a8635f56600fae4de208534bf92a6d229ab0fa3688fce58e1` | exact match, lines 5834-5836 |
| Enum enumerator 2 = `MIN_int32` | 194 | `ef456bfeaf07d858e493bd128c2f90534a225bf716854b62113ff14d3d5053ad` | exact match, lines 5842-5844 |

The hash domains and field streams agree with
`type-layout-authority-v1.md:195-254` and
`record-wire-v1-remaining.md:609-678`. The candidate asks production helpers
only for the observed hash and compares them with literal expected values; it
does not compute its expected values through a second hash oracle.

### Producer entry, atomic result and immutable input

`ExpectExactProducerFailureAndInputUnchanged` at candidate lines 798-840:

- snapshots the hostile but physically representable input before the call at
  lines 805-810;
- seeds output with `{aa,bb,cc}` and calls the actual production
  `FAngelscriptCacheTypeSchemaArchive::SerializeTypeSchema` entry at lines
  812-815;
- asserts exact Error, derived Class, `RecordKind=TypeSchema`, `Stage=None`,
  `ByteOffset=0`, and an empty output at lines 816-830;
- serializes the same const input after the call and compares its physical
  semantics byte-for-byte at lines 832-839.

The producer API accepts neither Budget/captured-offset state nor a current
resolver, so these producer cases are independent of all three. Runtime source
inspection shows the entry resets output, canonicalizes a private copy, returns
a validation result and otherwise writes bytes
(`AngelscriptCacheTypeSchema.cpp:1636-1652`). The compiled test calls that
entry directly. Thus the intended RED is a returned-behavior mismatch, not a
missing symbol, link surrogate, crash-only assertion, or test-local semantic
implementation. B1 focused execution remains explicitly N/A until later
private decoder/factory linkage (`implementation-plan.md:325-331`); the fresh
complete-TU compile proves the present declaration/call surface.

### No forbidden duplicate semantic decoder or writer oracle

The test-only physical writer is used only to create physically representable
hostile decoder fixtures and before/after immutable-input snapshots, consistent
with IC-138. The candidate does not implement another TypeSchema serializer or
semantic producer validator.

The independent scanner begins at candidate lines 2048-2096 and reads raw wire
bytes to inventory physical boundaries, captured coordinates and stable-reference
occurrences. Its own contract states that no DTO, writer trace, captured table or
decoder event supplies expected offsets/cardinality at lines 2336-2338. It does
not publish a decoded DTO, compute semantic validity, or compute any expected
hash. Its purpose is the independent offset/TS-SCR oracle required by
`type-layout-authority-v1.md:689-713` and
`record-wire-v1-remaining.md:287-298`, not a second production decoder.

### Frozen tuple, offset, matrix and precedence consistency

Apart from I-1, the candidate's diagnostic tuples and precedence pairs agree
with the frozen authorities:

- producer-side failures use `Stage=None`, offset zero and empty bytes, as
  required by `type-layout-authority-v1.md:382-387`;
- decoder failures use the independent scanner's enclosing-field offsets and
  clear sentinel token output;
- physical exhaustion precedes semantic/hash failures at candidate lines
  9083-9152;
- derived-hash order and field-local/layout replay precedence are frozen at
  candidate lines 9153-9351, matching
  `type-layout-authority-v1.md:589-638` and
  `type-schema-matrix-v1.md:1068-1161`;
- the captured-coordinate scanner and P/S/T uses are consistent with the
  append-only TypeSchema `0..38` contract at
  `record-wire-v1-remaining.md:300-350`. The fourth reviewed offset document is
  for the remaining four record kinds and introduces no conflicting TypeSchema
  coordinate rule (`remaining-record-captured-offsets-v1.md:432-452`).

## Final disposition

**NEEDS FIXES — 0 Critical / 1 Important / 0 Minor.**

The IC-139 vectors, production-entry mechanics, atomic output behavior, input
immutability strategy, resolver independence, raw offset oracle and frozen
diagnostic/precedence structure are acceptable at this exact SHA. B1 cannot
reach its required 0C/0I disposition until the normal producer matrix includes
the explicit `UnknownFlags` result case and the amended exact candidate receives
a fresh exact-SHA review.
