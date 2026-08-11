# B2 Slice 5 exact authority-patch candidate

Date: 2026-08-09 (Asia/Shanghai)

Status: **REPAIRED CANDIDATE / HOLD — exact independent review required; no
source-edit authorization**

## 1. Released basis and immutable source frontier

This patch transcribes the independently released proposal
`b2-slice5-authority-correction.md`, exact SHA-256
`D48D94CF54288A09E12400AAA830A0063285D9AAE23D7E7F55E9DE9C746C18E1`.
Its final review is
`reviews/b2-slice5-authority-correction-proposal-final-review.md` with disposition
0 Critical / 0 Important / 1 Minor, RELEASE. The accepted Minor is incorporated:
a duplicate/conflicting singleton Relation or LayoutInput fails in the earlier
field-local pass and is not a `ReflectionFormClosure` branch.

The source frontier remains byte-identical:

```text
TypeSchema test TU SHA-256
9F08A6266F3BF3DEB7D0DB7CCEADCF675E5CBF9AD540DDB2C0EB22A146366D32

TypeSchema producer SHA-256
DB2E14808A533B8BF279A8FDDEECCA1C42973BD90543DECBDBCA97F3F26C6FC4
```

No Runtime, Test, build, registration, decoder, graph, Pack/Manifest, Store or
StaticJIT source belongs to this candidate.

## 2. Exact four-file identity

| File | Previous reviewed SHA / bytes | Candidate SHA / bytes / shape |
|---|---|---|
| `type-schema-matrix-v1.md` | `DAB6D0C61F4ADB7F108C703EA785C3713FC9CF0E494E990464CB959D2B95F159` / 93,343 | `206BA8D6D163419A8535DFFA2F16E5B346E244BC9170D9DAF3D9E060951B0B12` / 102,941 / 1,715 LF / 0 CR / final LF |
| `type-layout-authority-v1.md` | `B9D20D1CE6149CF3C595F757FDA37CE6CA08572A039A5E0BB1DF04C33AD844D4` / 53,095 | `21B84C112EC4B8C2E85FBBF80B155914F689C337F555BC55A83D5C38D398057C` / 56,150 / 944 LF / 0 CR / final LF |
| `record-wire-v1-remaining.md` | `98121B7B440A340B51C4FF6B2E6C30F1169D9190598DCC2072FFFDD7D6B582B6` / 100,587 | `8E290B464AD2F6B885E94DC66E302C07E35EBA9CAA4E9EB0092E7973B8812CD9` / 105,231 / 2,152 LF / 0 CR / final LF |
| `producer-b2-coverage-audit.md` (non-normative) | `86D083C28CE20D960F799339934FA22D57C604ACCB9267C7A40C43DE2E891C32` / 19,376 | `8E9E92F5487F47CB5FBBAF5887745B692075A9F55D1FA43C8121702D32838E38` / 22,222 / 491 LF / 0 CR / final LF |

Any identity mismatch stops review. Review is against the four candidate files as
one atomic authority change; approving only a subset would recreate conflicting
semantic owners.

## 3. Normative decisions transcribed

1. TypeSchema local validation owns only DTO-observable Behavior facts. A
   ScriptFunction owner must be present/nonzero and an EnvironmentSymbol owner
   absent, but actual declaration owner/module/entity/ABI is graph-owned. Exact
   local owner equality exists only inside a CopyConstruct/CopyFactory alias tuple.
2. `HasDefaultConstructor=true` has locally visible necessary group conditions;
   `false` plus opaque Construct rows is locally admissible. ModuleSnapshot graph
   resolves signatures and proves unique zero-parameter Construct plus the
   corresponding Class Factory and complete flag parity. `HasDestructor` remains
   completely locally observable.
3. Each empty Behavior array is tested once per real legal
   TypeKind+Reflection form. Absence is never multiplied by hypothetical Kind,
   target, owner or entity values; all 952 ghost-empty calls remain forbidden.
4. Method/VFT duplicate FunctionKey within one array is always `DuplicateKey` at
   the later valid-ordinal coordinate, regardless of different owner/ABI bytes.
   Cross-role reuse remains legal.
5. The local phase order is raw domain; active row values; ordinal
   duplicate/gap/order; roles and optional tags; duplicate FunctionKey; then
   cross-field closure. A present Script owner value is active; an Environment
   owner value is inactive.
6. All field-local checks through Dependencies finish before
   `ReflectionFormClosure`. The closure then applies deferred form rules in wire
   order, including Class Construct/Factory count, before copy aliases,
   flag/Behavior coupling, relation/input pairing, dependency coverage, layout
   replay and final TypeLayoutHash.
7. Cross-field diagnostics use only existing append-only captured fields and
   physical row indices. A form-selected missing row uses `Reflection`; a Base-
   relation-driven missing input uses its requiring `Relation`; layout parity uses
   `LayoutExpectation`; flags use `TypeSemanticFlags`.
8. Every representable Slice-5 non-hash mutation closes dependencies as far as the
   same coordinate permits and receives a recomputed non-stale TypeLayoutHash.
   Slice 6 retains exclusive stale-final-hash coverage.
9. Dependency row/reference/canonical structure is field-local. After the earlier
   local closures, TypeSchema derives exact Dependency set equality from its DTO:
   missing is `MissingCoverage/LocalSemantic`, extra is
   `UnexpectedRecord/LocalSemantic`. Graph owns target existence/entity/actual
   owner/module/ABI and separate record/declaration coverage, not a second set
   derivation. A missing row uses the physical Dependencies-array/enclosing-field
   error offset without inventing a public captured coordinate; an extra row uses
   its indexed `Dependency` row.

## 4. Required rereview questions

The independent reviewer must answer all of these against the exact files:

- Do all four files state the same local-versus-graph owner and default-
  constructor split with no surviving reverse local implication?
- Do the earlier field passes remain form-independent wherever Reflection is not
  yet available, and does Dependencies local error win every closure?
- Are the array subphases and paired optional-owner winners unique?
- Does every closure failure map to an existing captured field and correct
  physical PrimaryIndex/fallback, including all non-statics forms?
- Is the accepted singleton Minor transcribed as field-local
  `DuplicateKey`/`ConflictingKey` and nowhere as a closure branch?
- Are the 952 ghost-empty cases removed without treating seven TypeKinds as the
  complete eleven-form baseline (IC-182)?
- Does the non-normative producer audit avoid becoming a semantic oracle and keep
  graph-only entity/signature work outside B2 producer evidence?
- Do all four files uniquely assign DTO-derived Dependency set equality locally,
  while preserving graph target/declaration validation and the distinct error
  offsets for missing versus extra rows (IC-183)?
- Do all finalizer statements preserve exactly-once Slice-6 stale-hash ownership?

Release requires 0 Critical / 0 Important. Every Minor must be explicit. Only
after release may a new Slice-5 ready packet rematerialize exact calls, prior-test
repairs, wrapper label and exact-source review gates. That packet itself requires
independent approval before any C++ edit.

## 5. Local document checks

At candidate freeze:

- `openspec validate refactor-as-incremental-function-cache --strict
  --no-interactive`: exit zero;
- parent and plugin `git diff --check`: exit zero, with only the previously known
  unrelated parent LF-to-CRLF warnings;
- all four candidate files have zero CR and a final LF; and
- frozen Test/producer source hashes equal section 1.

These checks prove document integrity only. No build, Automation, PIE, package,
Development/Shipping or multi-launch evidence was executed or claimed.

The first packet identity
`88B55F94470919BB5A01F151CF2F5653AB31D95686E9A463297D0C9D02EA31A3`
was rejected 0 Critical / 1 Important / 0 Minor by
`reviews/b2-slice5-authority-patch-review.md` because the matrix assigned derived
Dependency coverage to both local and graph. The candidate identities in section 2
incorporate IC-183 and are a fresh review boundary; the earlier review does not
approve them.

The first IC-183 repair packet
`32E72EE160E5E6E1ABB57B9533840037E17A896EECA13B3289F08EE8142CC2D8`
was also rejected 0 Critical / 1 Important / 0 Minor by
`reviews/b2-slice5-authority-patch-rereview.md`: one forbidden-extra sentence,
the immutable property graph checklist and both TS-SCR-19 labels still assigned
Dependency coverage to graph. Section 2 now routes forbidden extras locally,
turns graph checks into target/entity/owner/module/ABI resolution, and names
TS-SCR-19 as Dependency-target graph resolution. This is another fresh review
boundary.
