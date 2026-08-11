# Implementation Issue Ledger

Status: living OpenSpec attachment. This file records problems discovered while
planning, testing, implementing, building, integrating, packaging, and running
`refactor-as-incremental-function-cache`.

This ledger is evidence and decision history, not a second normative schema.
Normative resolutions are copied into the named design/wire/spec artifact; the
ledger then links to that authority. `tasks.md` remains a clean implementation
checklist, while command results remain in `verification.md`.

## Recording rule

Record an issue as soon as it is confirmed, before relying on its proposed
fix. Keep rejected approaches and pre-existing environmental failures because
they affect interpretation of later evidence. Every entry uses:

```text
ID / date / phase / severity / status
Problem
Impact
Evidence
Resolution or current decision
Required closure evidence
Authority or related artifact
```

Statuses are `Open`, `Fix in progress`, `Resolved`, `Accepted baseline`, and
`Deferred by scope`. A problem is `Resolved` only after the relevant focused
verification and review gate; editing a design or source file alone is not
closure.

## Issue index

| ID | Area | Severity | Status | Short description |
|---|---|---:|---|---|
| IC-001 | Worktree/build | Important | Resolved | Original isolated-worktree path exceeded Windows action-path limits |
| IC-002 | Baseline StaticJIT | Baseline | Accepted baseline | Eleven AOT tests require a missing local fixture |
| IC-003 | Artifact identity RED | Important | Resolved | Domain goldens, raw-path rejection, and forbidden-field guards were incomplete |
| IC-004 | Record envelope | Important | Resolved | Unchecked RecordId/intrusive-unset input and input/output alias safety |
| IC-005 | Type layout design | Critical | Resolved in design | Cold exact hit incorrectly required selected-module live layouts |
| IC-006 | TypeSchema validation | Important | Resolved in design | Wire/local/hash precedence was not uniquely implementable |
| IC-007 | Current layout memoization | Important | Resolved in design | Raw current layout availability was conflated with consumer presence masks |
| IC-008 | First TypeSchema RED | Critical | Superseded, not closure | Invented a second public owning token/direct decoder |
| IC-009 | First TypeSchema RED | Critical | Superseded, not closure | Mandatory negatives did not execute the real decoder |
| IC-010 | Unified decoded boundary | Critical | Open | Transitional SourceIndex/ModuleInterface APIs violate the sole-handle boundary |
| IC-011 | Decoded allocation accounting | Critical | Open | Requested element counts undercharge actual allocator capacity and token control allocation |
| IC-012 | Shared read budget | Critical | Open | Public Reset can erase conservative charges while handles remain alive |
| IC-013 | Decoded alias lifetime | Critical | Open | Resetting an output that owns the input view can cause use-after-free |
| IC-014 | Captured diagnostics | Important | Design resolved, code open | SourceIndex/ModuleInterface nested offsets and wrong-kind rules were incomplete |
| IC-015 | RED evidence quality | Important | Open | Missing-header compile RED is not a behavioral RED |
| IC-016 | Revised TypeSchema RED | Critical | Fix in progress | Mandatory negatives omit complete diagnostic tuple assertions |
| IC-017 | Revised TypeSchema RED | Critical | Fix in progress | Sole factory/handle construction and copy-cost evidence remains incomplete |
| IC-018 | TypeSchema truncation | Important | Fix in progress | Field inventory is self-reported by writer trace |
| IC-019 | TypeSchema optional tags | Important | Fix in progress | Several optional-tag families have no raw 2/0xff physical-decode case |
| IC-020 | TypeSchema ordinals | Important | Fix in progress | Property coverage is missing and several fixtures misclassify gaps as duplicates |
| IC-021 | TS-SCR | Important | Fix in progress | Allocation/failure-exit oracles and unchanged-counter evidence are incomplete |
| IC-022 | TypeSchema fixtures | Important | Fix in progress | Several fixtures labelled valid omit required alias/dependency closure |
| IC-023 | TypeSchema matrices | Important | Fix in progress | Reflection optional arms and focused local matrices remain incomplete |
| IC-024 | KindPayload wire | Critical | Fix in progress | Inactive union arms are not representable decoder negatives |
| IC-025 | TypeSchema precedence | Important | Fix in progress | Several required deterministic local winner pairs are absent |
| IC-026 | Typed stable keys | Important | Fix in progress | Same-domain equality exists but full-width/domain isolation is not frozen |
| IC-027 | Property/layout matrix | Important | Fix in progress | Multi-property ordinal/layout/range/input-role rows are substantially incomplete |
| IC-028 | TS-SCR probe contract | Important | Open | Allocation-site diagnostic/event evidence lacks an independent public test contract |
| IC-029 | TS-SCR site coverage | Critical | Open | One target allocation per family/variant does not cover every actual allocator site |
| IC-030 | TS-SCR09 callable arm | Important | Design resolved, test open | Delegate/Funcdef were incorrectly assigned a nonexistent signature-string allocation site |

## Detailed entries

### IC-001 — isolated worktree path exceeded Windows action-path limits

- Date/phase: 2026-08-08, implementation bootstrap.
- Severity/status: Important / Resolved.
- Problem: the first isolated worktree name made generated UHT/action paths
  exceed the Windows 260-character boundary.
- Impact: a build failure would have been environmental rather than evidence
  about Cache V2 source correctness.
- Evidence: the original worktree was discarded before source edits; the
  replacement path is `D:\Workspace\AngelscriptProject\.worktree\as-cache`.
- Resolution: use the shorter `as-cache` worktree and bootstrap its parent and
  plugin submodule independently.
- Closure evidence: baseline build succeeded with 119 actions at the short
  path; details are in `verification.md`.
- Authority: repository `AGENTS.md` worktree/submodule rules and
  `verification.md`.

### IC-002 — StaticJIT AOT baseline requires an unavailable local fixture

- Date/phase: 2026-08-08, isolated baseline.
- Severity/status: Baseline / Accepted baseline.
- Problem: 11 of 30 broad StaticJIT tests fail because
  `StaticJITAotFixture.Cache` and matching generated `.jit.cpp/.jit.hpp`
  prerequisites are absent locally.
- Impact: those failures cannot be attributed to Cache V2 changes and cannot
  serve as final compatibility evidence until their fixture prerequisite is
  supplied or the intended runner prepares it.
- Evidence: broad baseline was 19/30; the focused legacy precompiled-data
  prefix was independently 4/4.
- Resolution: preserve the failure as a named baseline, do not hide or count it
  as Cache V2 regression. Final affected-suite verification must distinguish
  fixture availability from product failures.
- Closure evidence: final StaticJIT run with the proper AOT prerequisite, or an
  authoritative runner classification proving the cases are intentionally
  external-fixture tests.
- Authority: `verification.md` baseline section.

### IC-003 — artifact-identity RED was not independently sufficient

- Date/phase: 2026-08-08, Task 1 review.
- Severity/status: Important / Resolved.
- Problem: the first identity tests lacked per-domain full-width goldens,
  allowed a raw absolute-path route toward ModuleKey, and used vacuous local
  forbidden-field evidence.
- Impact: truncated/cross-domain hashes or host-path-dependent identities could
  pass while invalidating cross-start cache reuse.
- Resolution: add a non-default typed logical path, fail-closed path/ModuleKey
  constructors, complete independent 64-hex goldens for every domain, and
  compile-time descriptor-shape guards.
- Closure evidence: focused build and Identity 8/8 at that repair point,
  followed by later Identity 10/10 and independent 0C/0I/0M approval.
- Authority: `identity-golden-vectors.md`, `design.md`, `verification.md`.

### IC-004 — record-envelope public input and alias safety gaps

- Date/phase: 2026-08-08, Task 2A review.
- Severity/status: Important / Resolved.
- Problem: the first envelope API did not fully reject unchecked RecordId or
  intrusive-unset inputs, and its input/output arrays could alias unsafely.
- Impact: malformed identities could enter the archive boundary, or resetting
  output could invalidate bytes still being read.
- Resolution: fail closed on invalid identifiers/views, preserve the frozen
  empty-payload form, and define/test safe alias behavior.
- Closure evidence: Envelope 13/13 plus independent 0C/0I/0M approval.
- Authority: `record-wire-v1.md`, `archive-format-vectors.md`,
  `verification.md`.

### IC-005 — cold exact hits depended on live selected-module layout

- Date/phase: 2026-08-08, TypeSchema/layout combined design review.
- Severity/status: Critical / Resolved in design; production evidence pending.
- Problem: an earlier candidate called `CurrentLayouts` for selected-module
  Base/ScriptType coordinates even though those live types do not exist before
  restore materializes them.
- Impact: every legitimate cold exact hit could fail as
  `CurrentSymbolMissing`, defeating first-start generation and warm restore.
- Resolution: close same-module Script* and numeric-layout authority through
  immutable TypeSchema records; only external/environment inputs can consult
  the per-engine current resolver. A prospective validated-local-layout view
  supports nested local value types without materialization.
- Closure evidence: combined design rereview 0C/0I/0M. Production and cold-hit
  tests remain required in Tasks 2.4/2.5 and final lifecycle acceptance.
- Authority: `type-layout-authority-v1.md`, `type-schema-matrix-v1.md`,
  `design.md`.

### IC-006 — TypeSchema validation and hash precedence was ambiguous

- Date/phase: 2026-08-08, TypeSchema/layout combined design review.
- Severity/status: Important / Resolved in design; production evidence pending.
- Problem: later KindPayload/Dependencies were checked before earlier fields,
  while LayoutInputHash could be recomputed after property hashes.
- Impact: competing malformed fields could produce different errors and byte
  offsets depending on implementation structure.
- Resolution: one order is now frozen: physical decode and trailing exhaustion;
  exact top-level field-local wire order; cross-field layout/dependency checks;
  LayoutInputHash; per-property StorageLayoutHash and
  PropertyLayoutFingerprint; EnumAuthorityHash; TypeLayoutHash last.
- Closure evidence: approved combined design; paired behavioral RED/GREEN with
  exact diagnostic tuples remains open.
- Authority: `type-schema-matrix-v1.md`, `record-wire-v1-remaining.md`.

### IC-007 — raw current layout and consumer presence were conflated

- Date/phase: 2026-08-08, TypeSchema/layout correction.
- Severity/status: Important / Resolved in design; production evidence pending.
- Problem: one raw CodeRoot may expose boundary plus alignment, while root and
  derived UClasses intentionally consume different subsets. Comparing raw
  optionals directly to each consumer would reject valid derived schemas.
- Resolution: memoize the raw role result by
  `{InputKind,ReferenceKind,StableKey}`, then apply each validated consumer's
  stored presence mask before equality/hash comparison.
- Closure evidence: design rereview approval; future resolver-call counters and
  root/derived CodeRoot tests remain open.
- Authority: `type-layout-authority-v1.md`.

### IC-008 — first TypeSchema RED invented a second owning boundary

- Date/phase: 2026-08-08, first Task 2B-2A RED review.
- Severity/status: Critical / Superseded, not closure.
- Problem: the rejected test required public
  `FAngelscriptValidatedTypeSchema` ownership and a direct TypeSchema decoder.
- Impact: SourceIndex, ModuleInterface, and TypeSchema would have separate trust,
  lifetime, offset, and budget paths, allowing validated DTO reconstruction or
  double charging.
- Resolution: V1 has one public
  `FAngelscriptDecodedCacheRecordHandle` produced only by declared-RecordId plus
  exact-payload `TryDecode`; all per-record decoders are private.
- Closure evidence: revised RED must prove the boundary and production must
  delete the transitional alternatives. This is still open through IC-010 and
  IC-017.
- Authority: `decoded-record-boundary-audit.md`,
  `record-wire-v1-remaining.md`.

### IC-009 — first TypeSchema negatives bypassed the decoder under test

- Date/phase: 2026-08-08, first Task 2B-2A RED review.
- Severity/status: Critical / Superseded, not closure.
- Problem: many malformed cases exercised a producer predicate or serializer
  instead of the real common decoder.
- Impact: the tests could remain green even if the decoder skipped local
  validation.
- Resolution: every mandatory negative starts from a complete physical
  fixture, mutates exact bytes/semantics, recomputes RecordId, calls the common
  factory, and checks the complete diagnostic tuple plus atomic output.
- Closure evidence: revised test repair and independent 0C/0I review; IC-016
  proves the current snapshot is still insufficient.
- Authority: `type-schema-red-review.md`.

### IC-010 — transitional SourceIndex/ModuleInterface public APIs conflict with the sole handle

- Date/phase: 2026-08-08, unified-boundary preflight.
- Severity/status: Critical / Open.
- Problem: Task 2B-1 still exposes an owning validated SourceIndex token and a
  mutable/direct ModuleInterface decoder. No production consumers require
  compatibility.
- Impact: retaining wrappers would preserve multiple trust paths, lose nested
  offsets, complicate graph ownership, and risk double budget charges.
- Decision: delete the old public owning/direct APIs; migrate tests and
  eligibility to common immutable decoded-record handles. Do not add a
  compatibility wrapper because the plugin is in development.
- Closure evidence: compile RED for removed signatures/new sole signature,
  behavior RED through the valid-path kernel, focused Source/MI/TypeSchema
  GREEN, forbidden-symbol scan, independent review.
- Authority: `decoded-record-boundary-audit.md`, `implementation-plan.md`,
  Tasks 2.2/2.3/2.5/2.5a.

### IC-011 — decoded memory accounting underestimates physical allocation

- Date/phase: 2026-08-08, unified-boundary audit.
- Severity/status: Critical / Open.
- Problem: existing readers charge requested element/string sizes rather than
  `CalculateSlackReserve`/`GetAllocatedSize`; TotalDecoded also omits DTO,
  captured-offset, and the allocator-quantized shared token/controller block.
- Impact: hostile or merely slack-heavy records can exceed actual memory limits
  while reported budgets remain within limits.
- Decision: reserve before allocation using allocator-authoritative capacity;
  charge physical decoded allocation in both TotalDecoded and conservative
  Resident dimensions; charge captured offsets and the one `MakeShared`
  allocation exactly once.
- Closure evidence: allocation-family exact/one-byte-short tests, unchanged
  allocation probe on rejected reserve, live peak accounting, and independent
  review.
- Authority: `decoded-record-boundary-audit.md`, TS/MS/AR-SCR rows.

### IC-012 — public read-budget Reset can invalidate live accounting

- Date/phase: 2026-08-08, unified-boundary audit.
- Severity/status: Critical / Open.
- Problem: `FAngelscriptCacheReadBudget::Reset()` can zero conservative
  retained charges while decoded handles backed by those allocations remain
  alive.
- Impact: the same session budget could admit additional records beyond the
  configured resident limit.
- Decision: remove public session-budget Reset in V1; use fresh stack budgets
  for new sessions. Keep only move-only scoped scratch release, with explicit
  `PromoteToRetained` where candidate scratch becomes published ownership.
- Closure evidence: forbidden-API compile scan and success/failure/promotion
  accounting tests.
- Authority: `decoded-record-boundary-audit.md`, Task 2.5a.

### IC-013 — aliased output reset can invalidate the input payload

- Date/phase: 2026-08-08, unified-boundary audit.
- Severity/status: Critical / Open.
- Problem: a caller may pass a payload view owned by the handle currently held
  in `OutRecord`; resetting that optional at factory entry can release the last
  owner before the bytes are decoded.
- Impact: use-after-free during RecordId recomputation or physical decode.
- Decision: take a local reference-count-only guard to the old handle before
  resetting output; the guard performs no DTO/payload/control allocation and no
  budget charge.
- Closure evidence: aliased-input behavior test plus handle-copy allocation and
  charge probe.
- Authority: `decoded-record-boundary-audit.md`.

### IC-014 — SourceIndex/ModuleInterface captured offsets were incomplete

- Date/phase: 2026-08-08, unified-boundary follow-up.
- Severity/status: Important / Design resolved, code open.
- Problem: prior per-record APIs did not retain a complete typed coordinate map
  for nested DataType/reference/dependency/metadata/parameter/slot failures;
  exact-fast-path wrong-kind behavior was not fully frozen.
- Resolution: append-only SourceIndex `u16 0..89` and ModuleInterface
  `u16 0..88`, exact P/S/T rules, recursive DataType pre-order ordinals, and
  wrong-kind error 48 / actual kind / ModuleGraph stage 5 / offset zero /
  false-empty output / unchanged budget before any access/allocation.
- Closure evidence: common-handle migration tests for every coordinate,
  wrong-kind, missing/extra/out-of-bounds index, absent optional, and present
  offset zero.
- Authority: `source-interface-captured-offsets-v1.md`.

### IC-015 — missing-header compile failure is not behavioral RED

- Date/phase: 2026-08-08, TypeSchema RED/preflight.
- Severity/status: Important / Open.
- Problem: the existing build fails first on missing
  `Cache/AngelscriptCacheTypeSchema.h`; this proves an interface is absent but
  cannot prove negative cases execute and fail for the expected reasons.
- Impact: declaring GREEN after making the translation unit compile could hide
  vacuous/unreachable tests or producer `check` crashes.
- Decision: capture two gates separately: whole-TU declaration/stub compile,
  then a minimal valid-path kernel that lets the exact TypeSchema prefix run and
  fail behaviorally. Missing headers, unresolved symbols, crashes, and producer
  assertions are never behavioral RED.
- Closure evidence: complete compile log followed by focused test report with
  expected test assertion failures and no process crash.
- Authority: `decoded-record-boundary-audit.md`, Task 2.5a.

### IC-016 — revised TypeSchema negatives omit the complete diagnostic tuple

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Critical / Fix in progress.
- Problem: many mandatory negatives assert Error and output reset but omit one
  or more of Stage, RecordKind, and captured ByteOffset. Confirmed areas include
  reflection, Method/VFT, Property/Layout, focused Behavior, and TS-SCR.
- Impact: an implementation can reject at the wrong layer or wrong field and
  still satisfy the test.
- Current action: the reviewer is producing a deduplicated line-numbered list;
  repair helpers must require the full tuple rather than rely on ad hoc
  assertions.
- Closure evidence: new frozen test SHA plus independent 0C/0I review.
- Authority: `type-schema-red-review.md`.

### IC-017 — revised sole-handle evidence is incomplete

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Critical / Fix in progress.
- Problem: static type assertions do not yet prove handle-copy zero
  allocation/zero charge, all construction entry points are closed, or typed
  offset wrong-kind/extra-index behavior.
- Impact: production could expose an alternate reconstruction route or make
  handle copy a hidden budget/allocation operation.
- Current action: add runtime allocation/budget probes and compile-time entry
  closure assertions; exhaust typed coordinate invalid shapes.
- Closure evidence: new frozen test SHA and independent approval, then matching
  production GREEN.
- Authority: `decoded-record-boundary-audit.md`,
  `source-interface-captured-offsets-v1.md`.

### IC-018 — TypeSchema truncation inventory trusts the writer trace

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Important / Fix in progress.
- Problem: `EveryTypeSchemaV1FieldBoundary...` iterates only
  `Trace.GetAllV1Spans()`. If the physical writer and trace both omit a V1
  field, the test never notices.
- Impact: an incomplete wire implementation can pass an apparently exhaustive
  truncation test.
- Current action: define an independent expected field/shape inventory and
  exact occurrence counts for one all-fields-present fixture; compare that set
  to trace before using trace solely for mutation coordinates.
- Closure evidence: inventory mismatch must fail even when writer and trace
  agree with each other.
- Authority: `record-wire-v1-remaining.md`, `type-schema-red-review.md`.

### IC-019 — invalid optional-tag exhaustion is incomplete

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Important / Fix in progress.
- Problem: raw optional-tag tests currently cover only Relation semantic
  ordinal, LayoutInput boundary, and Behavior declaring owner. Missing families
  include LayoutInput alignment, reflection ConfigName/StaticClassGlobalName,
  CanonicalDataType TypeReference, Dependency ExpectedContentOrValue, and any
  other optional tags enumerated by the independent wire inventory.
- Impact: invalid raw `2`/`0xff` tags can be accepted or diagnosed at the wrong
  offset.
- Current action: generate one physical decoder case per independent optional
  field, asserting Error/Stage/RecordKind/ByteOffset/output reset.
- Closure evidence: exact inventory-to-test count and independent review.
- Authority: `record-wire-v1-remaining.md`.

### IC-020 — ordinal negative fixtures are incomplete or mislabeled

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Important / Fix in progress.
- Problem: UFunction, Method, and VFT tests use `Position + 1`; at the last
  position `[0,1,3]` is a gap, not DuplicateOrdinal, while middle `[0,2,2]`
  combines a gap and duplicate. Property ordinal coverage is tracked
  separately by IC-027.
- Impact: precedence and exact offending offset are not actually frozen.
- Current action: build separate single-fault constructors for gap, duplicate,
  and out-of-order at each required position, and assert complete tuples.
- Closure evidence: each named fixture proves its exact wire shape before
  decode and independently reaches the expected diagnostic.
- Authority: `type-schema-matrix-v1.md` sections 12.3/12.4 and
  `type-schema-red-review.md`.

### IC-021 — TS-SCR probes do not close all allocation/failure exits

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Important / Fix in progress.
- Problem: exact and one-byte-short values are partly supplied by the same
  probe being tested; failures do not consistently assert unchanged allocation
  attempt/capacity counters, and physical/hash/scratch-failure exits are not all
  covered. Some success/failure fixtures are self-reported rather than
  independently asserted.
- Impact: a decoder could allocate before budget acquisition, leak live scratch,
  or compute the required limit incorrectly and still pass.
- Current action: add independent family/cardinality/variant expectations,
  pre/post allocation counters, physical/local/hash exit cases, zero live
  scratch on every return, and exactly-once retained promotion/charge.
- Closure evidence: TS-SCR-01..14 exact-limit and one-byte-short matrix plus
  allocation probe equality and independent review.
- Authority: `type-layout-authority-v1.md`,
  `decoded-record-boundary-audit.md`.

### IC-022 — fixtures labelled valid omit required local closure

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Important / Fix in progress.
- Problem: confirmed examples include CopyFactory without the required
  Factory/Construct alias family, duplicate Shadow/Code dependency targets, and
  a VFT family missing a Declaration dependency.
- Impact: allocation or matrix tests can fail before reaching their target
  family, making exact/short results and allocation statistics meaningless.
- Current action: validate each fixture independently through the common factory
  before using it as a budget/mutation baseline; make closure dependencies
  explicit and assert the intended observed family.
- Closure evidence: all baseline fixtures decode successfully at unlimited
  limits; every malformed variant changes exactly its named predicate.
- Authority: `type-schema-matrix-v1.md`, `type-schema-red-review.md`.

### IC-023 — reflection optional arms and focused local matrices are incomplete

- Date/phase: 2026-08-08, revised exact-SHA independent review.
- Severity/status: Important / Fix in progress.
- Problem: the broad loops do not yet prove every required reflection optional
  string/union arm and several focused local first/middle/last or cardinality
  cases. Property-mask exhaustion itself does execute all `5 × 524288` masks
  through the common factory and is not the missing area.
- Impact: matrix size can look exhaustive while individual semantic axes or
  exact diagnostics remain untested.
- Current action: reconcile an independent requirement-row inventory against
  executed case counters and add focused exact-tuple tests for uncovered rows.
- Closure evidence: requirement-row count/assertions and independent 0C/0I
  review.
- Authority: `type-schema-matrix-v1.md`, `type-schema-red-review.md`.

### IC-024 — inactive KindPayload arms cannot be decoder negatives in V1

- Date/phase: 2026-08-08, revised exact-SHA final independent review.
- Severity/status: Critical / Fix in progress.
- Problem: Class+Enum, Enum+Callable, and a Metadata-precedence fixture place an
  inactive in-memory union arm into the DTO and expect the common decoder to
  return `InvalidPresence` (test lines 2087, 1250, and 4116).
- Impact: frozen V1 wire has only `TypeKind` as the union tag and writes no
  second arm-presence tag. A correct writer either omits the inactive arm, so
  the decoder cannot observe it, or emits trailing bytes, which must fail as
  `TrailingData/PayloadDecode`. The current test demands impossible behavior or
  silently creates test-only wire semantics.
- Decision: keep inactive-arm rejection as a producer/serializer DTO test and
  require empty output bytes. Decoder KindPayload negatives mutate bytes that
  really exist in the selected Enum/Callable/Typedef arm. Replace the Metadata
  precedence pair with a representable later Enum-payload semantic fault.
- Closure evidence: no decoder test depends on inactive DTO state; producer
  rejection and representable decoder mutations have distinct exact oracles;
  independent review confirms no second wire tag was introduced.
- Authority: `record-wire-v1-remaining.md` TypeKind union rules,
  `type-schema-matrix-v1.md`, `type-schema-red-review.md`.

### IC-025 — deterministic local precedence pairs are incomplete

- Date/phase: 2026-08-08, revised exact-SHA final independent review.
- Severity/status: Important / Fix in progress.
- Problem: four useful prior remediation pairs and derived-hash ordering exist,
  but required local pairs are missing: unknown flag versus missing required
  flag; invalid UTF-8 versus later presence fault; trailing byte versus enum
  authority hash; relation order versus type-layout hash; property ordinal gap
  versus property fingerprint; reflection form versus type-layout hash. The
  existing Metadata/inactive-arm pair is invalid under IC-024.
- Impact: implementations can choose different winners for simultaneous faults
  while still passing all current single-fault tests.
- Decision: add every purely local pair from the normative precedence table,
  with two demonstrably simultaneous representable mutations and a complete
  diagnostic tuple. Graph/current pairs stay in ModuleSnapshot RED and are
  linked by executable test name.
- Closure evidence: requirement-row-to-test mapping and independent 0C/0I
  review.
- Authority: `type-schema-matrix-v1.md` section 12.8,
  `type-layout-authority-v1.md`.

### IC-026 — stable-key equality does not yet prove domain isolation

- Date/phase: 2026-08-08, revised exact-SHA final independent review.
- Severity/status: Important / Fix in progress.
- Problem: tests use same-domain typed equality but do not prove typed
  `operator!=`, full 256-bit comparison, or non-invocability/coercion across
  Type/Function/Property/Module key domains.
- Impact: a future generic cross-wrapper operator or truncated comparison could
  satisfy existing tests while collapsing identity domains.
- Decision: add same-domain `==`/`!=` compile/runtime checks for each relevant
  wrapper, values differing only in a late hash byte, and compile-time
  non-invocability for every cross-domain pair.
- Closure evidence: compile assertions and focused runtime full-width vectors,
  followed by independent review.
- Authority: `type-schema-red-review.md`, identity domain rules in
  `design.md`/`identity-golden-vectors.md`.

### IC-027 — property/layout local matrix is substantially incomplete

- Date/phase: 2026-08-08, revised exact-SHA final independent review.
- Severity/status: Important / Fix in progress.
- Problem: no negative mutation of `Property.LayoutOrdinal` exists. A useful
  one-property fixture covers several cursor/alignment cases but misses
  first/middle/last gap/duplicate/reorder, overlap, exact tail padding,
  checked end/terminal overflow, above-INT32_MAX ranges, aggregate/minimum
  alignment, property structural fields, forbidden-form property presence,
  empty-form controls, and exhaustive BaseType/CodeRoot/StructHeader
  role/presence/target/hash rows.
- Impact: property-mask exhaustion can be fully real while the layout replay
  and record-structure contract remains under-specified and under-tested.
- Decision: add at least a three-property fixture; independent ordinal and
  layout mutations; checked numeric edge fixtures; legal/illegal form controls;
  and a complete local LayoutInput role/presence table. Do not pull graph or
  current-layout resolution into the local decoder.
- Closure evidence: exact tuple assertions for each row and requirement-row
  inventory approved at 0C/0I.
- Authority: `type-schema-matrix-v1.md` sections 12.3/12.4,
  `type-layout-authority-v1.md`.

### IC-028 — TS-SCR allocation-site diagnostics lack an independent probe contract

- Date/phase: 2026-08-08, revised RED repair.
- Severity/status: Important / Open.
- Problem: mandatory budget negatives must freeze the exact allocation-site
  Stage/RecordKind/ByteOffset and prove no allocation attempt occurred after a
  one-byte-short reservation failure. The planned production test probe exposes
  family totals and self-derived limit helpers, but no independently specified
  failure coordinate or allocation-event before/after snapshot.
- Impact: the RED can either omit the required diagnostic tuple or obtain the
  expected offset/event count from the same implementation observer it is
  testing; both would leave C1/I6 unresolved.
- Decision: the RED owns an allocation-site table and the independent wire
  coordinate-to-offset mapping. A narrow read-only probe reports chronological
  observed events and counters only; it may not manufacture the expected site,
  Stage, ByteOffset, exact limit, or one-byte-short limit. Snapshot event
  counters before and after the rejected reserve and require equality. The
  exact contract is frozen in `type-layout-authority-v1.md` section 11.1.
- Closure evidence: the complete TS-SCR-01..14 matrix asserts independent
  expected limits, exact diagnostic tuples, unchanged target allocation events,
  and entry-value scratch/resident restoration on all physical/local/hash exits.
- Authority: `decoded-record-boundary-audit.md`,
  `type-schema-red-review.md`, `type-layout-authority-v1.md` TS-SCR inventory.

### IC-029 — one target allocation per family/variant is not site exhaustion

- Date/phase: 2026-08-08, revised RED repair.
- Severity/status: Critical / Open.
- Problem: the draft TS-SCR loop selects one probe-defined target allocation
  for each `{Family,Variant}`. Several variants contain multiple independently
  allocating strings, arrays, recursive subtype nodes, metadata keys/values,
  and parallel captured-offset storage.
- Impact: aggregate family totals can be correct while an individual site
  allocates before reserve, charges the wrong capacity, reports the wrong
  offset, or leaks scratch. A single target does not prove the exhaustive
  family requirements already frozen by TS-SCR-01..14.
- Decision: expand test-owned site templates into a case per actual allocator
  site and applicable first/middle/last/recursive occurrence. Each site has an
  independent allocator-size oracle, static owner coordinate and Stage. The
  probe is an observed chronological event stream only. Streaming/inline sites
  prove the absence of an event rather than inventing a zero-byte allocation.
- Closure evidence: exact-limit and one-byte-short behavior for every expanded
  site; unchanged attempt counters; exact entry-state restoration; a count/set
  assertion that every observed event maps to exactly one expected site and no
  expected live site is absent.
- Authority: `type-layout-authority-v1.md` section 11.1,
  `type-schema-matrix-v1.md` allocation family matrix.

### IC-030 — Delegate/Funcdef have no signature-string allocation site

- Date/phase: 2026-08-08, revised RED allocation-site expansion.
- Severity/status: Important / Design resolved, test open.
- Problem: the first TS-SCR09 site-template draft named a
  `DelegateSignatureString` allocation. Frozen wire stores only
  `SignatureFunctionKey`, `ExpectedSignatureAbi`, and `bMulticast` for Delegate
  and Funcdef; `CallableSignature` is a diagnostic coordinate, not an FString.
- Impact: the RED would require a nonexistent DTO allocation, encouraging the
  Runtime implementation to add redundant signature text or a test-only site
  that changes budget accounting without any wire authority.
- Decision: remove the signature-string site. Delegate/Funcdef callable payload
  is inline and proves zero DTO string/container allocation. TS-SCR09 still
  owns its parallel selected-arm offset storage; Enum owns enumerator/name/
  metadata allocations, and Typedef owns any real CanonicalDataType subtype
  arrays.
- Closure evidence: no `DelegateSignatureString` test/probe/site remains;
  callable-arm tests assert inline/zero DTO allocation while the selected-arm
  offset capacity is still charged exactly once.
- Authority: `record-wire-v1-remaining.md` lines 834-843,
  `type-layout-authority-v1.md` section 11.1.

### IC-031 — TypeSchema public captured-coordinate behavior is not exhaustive

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Critical / Open.
- Problem: numeric assertions freeze TypeSchema coordinates `0..38`, but the
  public typed lookup matrix exercises only scalar fields, a Property row/key,
  one recursive PropertyType, one unapplicable Enum coordinate, and wrong-kind
  overloads. Most relation, layout, method/VFT/behavior, reflection,
  dependency, Metadata and selected-arm coordinates lack present, surplus,
  out-of-range, unapplicable and allocation-free lookup proof.
- Impact: Runtime can store the right DTO yet expose a wrong or allocating
  captured-offset API, defeating exact diagnostics and the StaticJIT boundary.
- Decision: table-drive every TypeSchema field's exact P/S/T consumption,
  recursive preorder, zero offset, surplus/out-of-range/unapplicable and wrong
  record kind. Snapshot Budget and allocation attempts across every lookup.
- Closure evidence: exact coordinate inventory and independent 0C/0I review.
- Authority: `record-wire-v1-remaining.md`,
  `source-interface-captured-offsets-v1.md`,
  `type-layout-authority-v1.md`.

### IC-032 — allocation observer remains semantic and circular

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Critical / Open.
- Problem: Runtime events echo SiteKind, FixtureVariant, P/S/T, requested
  capacity and entry counters. The RED uses those observed values to choose a
  site and reconstruct expected charge, prefix and ByteOffset. Baseline Struct
  strings and malformed Enum physical fields are also omitted by variant-
  filtered templates, so a truthful all-site observer cannot satisfy the
  current exact-count assertion.
- Impact: production and tests can share the same wrong semantic answer; a
  conforming observer can fail while a probe that suppresses real allocation
  sites passes.
- Decision: make the production probe semantic-blind. RED owns fixture shape,
  site identity, P/S/T, order, requested count/capacity, lifetime, Stage and an
  independent wire coordinate-to-offset scanner. Compare only a generic
  chronological event stream and raw counters.
- Closure evidence: no semantic/variant/coordinate echo in the probe contract;
  exact ordered one-to-one event mapping from a test-owned oracle.
- Authority: `type-layout-authority-v1.md` section 11.1, IC-028, IC-029.

### IC-033 — canonical-payload owned-byte allocation is absent from TS-SCR-01

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Critical / Open.
- Problem: the 50 SiteKinds/66 templates contain controller, offsets and DTO
  sites but no immutable token-owned canonical-payload `TArray<uint8>` site.
  Exact reconstruction starts at zero and therefore either rejects a compliant
  event or approves an implementation that fails to charge the bytes.
- Impact: TotalDecoded/Resident limits, ownership, aliasing and handle lifetime
  can all be wrong while the most important byte-retention cost is invisible.
- Decision: correct TS-SCR-01 authority and add exactly one payload site per
  decode. Derive requested count from payload bytes, calculate actual allocator
  capacity, charge Total and Resident once, prove caller-array non-aliasing,
  distinct Total/Resident one-short failures, and lifetime through handle copy.
- Closure evidence: updated static counts, exact event/prefix reconstruction,
  alias/lifetime checks and independent 0C/0I review.
- Authority: `decoded-record-boundary-audit.md`,
  `record-wire-v1-remaining.md`, `type-layout-authority-v1.md` section 11.1.

### IC-034 — TS-SCR template exhaustion, site-specific slack and scratch disposition are incomplete

- Date/phase: 2026-08-08, repaired RED focused rereview.
- Severity/status: Critical / Open.
- Problem: Enum Metadata and Typedef subtype templates never expand; scratch
  TS-SCR-12..14 accepts an empty event stream based on production's
  `bProvenZeroAllocation`; combined fixtures omit simultaneously live sites;
  and each family uses one representative element type for slack boundaries
  even though its containers have different element sizes/allocators.
- Impact: individual reserve-before-allocate, capacity and cleanup bugs can
  hide behind family totals or unreachable templates.
- Decision: every template declares `Required`, `StreamingZero`, or
  `InvalidFixtureOnly`; every Required site expands at least once. Generate
  `0/1/site-specific-slack/many` from the actual element type, include
  first/middle/last/recursive and combined-live sites, and reject missing,
  duplicate, extra or reordered events.
- Closure evidence: template reachability report and exact ordered event-set
  test with no production zero-allocation oracle.
- Authority: `type-layout-authority-v1.md` section 11.1, IC-029, IC-030.

### IC-035 — Resident, temporary and PeakLive reconstruction is not independent

- Date/phase: 2026-08-08, repaired RED focused rereview.
- Severity/status: Critical / Open.
- Problem: expected peak reads production `EntryResident` and
  `EntryTemporary`; per-site short cases lower Total only and deliberately leave
  Resident loose. Final Resident, temporary chronology, promotion and both
  limit dimensions are not frozen independently.
- Impact: allocation can be charged to the wrong lifetime, occur before
  reservation, leak temporary bytes or violate Resident limits while tests
  pass.
- Decision: freeze each site's retained/temporary disposition and independently
  replay Total, Resident, Temporary and Peak prefixes. Run separate Total-short
  and Resident-short cases for every applicable site and verify entry retained
  state, zero later attempts, exact cleanup and output reset.
- Closure evidence: exact success/failure counter traces for both dimensions
  and independent 0C/0I review.
- Authority: `decoded-record-boundary-audit.md`,
  `record-wire-v1-remaining.md`, `type-layout-authority-v1.md`.

### IC-036 — reference/relocation budget has no exact or one-short RED

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Important / Open.
- Problem: `MaxReferencesAndRelocations` is not set in exact limits. The file
  only checks handle-copy stability and shared-budget monotonicity; it never
  independently counts nested reference consumers or freezes the first
  overflowing coordinate.
- Impact: nested references may be missed, double-charged or charged after
  mutation without a failing test.
- Decision: add a grammar-derived reference/relocation counter, exact success,
  one-short failure per reference-bearing family, exact diagnostic coordinate,
  unchanged failed consume/allocation state and reset output.
- Closure evidence: independent count vectors and exact/short matrix.
- Authority: `record-wire-v1-remaining.md` budget contract,
  `type-layout-authority-v1.md` section 11.1.

### IC-037 — independent wire inventory and failure offsets cover only simple arms

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Important / Open.
- Problem: the independent inventory covers only Delegate and Enum shapes;
  complex Relation, LayoutInput, VFT, reflected UFunction and nested occurrences
  are absent. TS-SCR failure offsets still come from the writer trace and ignore
  tertiary coordinates.
- Impact: writer and trace can co-omit or co-misplace a field and still validate
  each other, producing wrong exact diagnostics.
- Decision: build comprehensive all-fields plus union-arm inventories of
  `{Field,P,S,T,ExpectedOffset}` with a test-owned wire scanner; compare the
  writer trace to it and use only the independent offset for failures.
- Closure evidence: exact inventory count/set/offsets for every physical shape.
- Authority: IC-018, `record-wire-v1-remaining.md`,
  `type-layout-authority-v1.md`.

### IC-038 — several focused fixtures are invalid or multi-fault

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Important / Open.
- Problem: TS-SCR dependency/constructor fixtures violate their own local
  invariants; Delegate/Funcdef zero-DTO cases conflict with a generic
  cardinality assertion; duplicate-ordinal rows copy full identities and thus
  introduce multiple simultaneous faults; required isolated relation rows are
  still absent.
- Impact: intended allocator/ordinal/relation paths may never be reached and
  exact error assertions may freeze incidental precedence.
- Decision: every allocation fixture first proves unlimited common-factory
  success and returns a typed disposition. Create otherwise-distinct valid rows
  before mutating only the ordinal; add self-reference, zero/missing ABI,
  duplicate-interface and relation-form cases with one intended fault.
- Closure evidence: fixture validity assertions, one-mutation witnesses and
  exact tuple tests.
- Authority: `type-schema-matrix-v1.md` sections 12.3/12.8, IC-020.

### IC-039 — property/layout numeric and structural boundaries remain incomplete

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Important / Open.
- Problem: no above-INT32 storage-size/alignment, Base boundary greater than
  semantic size, terminal AlignUp overflow, or several structural-form rows
  required by section 12.4. The existing above-INT32 mutation changes aggregate
  SemanticSize, not the required property storage witnesses.
- Impact: checked arithmetic, alignment replay and class-form validation remain
  implementation-dependent.
- Decision: add each explicit numeric/form row with a valid control, exact full
  diagnostic tuple and no unrelated graph/current mutation.
- Closure evidence: section 12.4 row-to-test inventory at 0C/0I.
- Authority: `type-schema-matrix-v1.md` section 12.4, IC-027.

### IC-040 — two precedence repairs do not construct the normative fault pairs

- Date/phase: 2026-08-08, repaired RED independent rereview.
- Severity/status: Important / Open.
- Problem: unknown flag is paired with missing KindPayload rather than missing
  required flag; invalid UTF-8 is paired with duplicate Enum name rather than a
  later presence fault.
- Impact: the required deterministic winner remains unproven.
- Decision: construct simultaneous representable pairs such as an unknown Class
  bit plus cleared required ReferenceType, and invalid UTF-8 plus a later
  `InvalidPresence`; assert both faults exist and the exact winner tuple.
- Closure evidence: direct mutation witnesses and exact precedence assertions.
- Authority: `type-schema-matrix-v1.md` section 12.8, IC-025.

### IC-041 — handle-copy zero-allocation proof runs outside the allocation probe

- Date/phase: 2026-08-08, repaired RED focused rereview.
- Severity/status: Important / Open.
- Problem: the allocation probe scope ends before two handle copies occur, so
  unchanged counters are vacuous and the first copy is not included in the
  snapshot.
- Impact: a copying handle implementation could allocate a new controller or
  token and still pass.
- Decision: keep the probe active, bind the original by reference, snapshot,
  copy once, and compare controller/DTO/payload/offset identities and every
  allocation/Budget counter. Reset the original and prove the copy remains
  readable until its final destruction.
- Closure evidence: in-scope zero-delta copy and lifetime test.
- Authority: `decoded-record-boundary-audit.md`, IC-011.

### IC-042 — physical/local/hash cleanup tests do not prove target sites were reached

- Date/phase: 2026-08-08, repaired RED focused rereview.
- Severity/status: Important / Open.
- Problem: truncation and early semantic faults often occur before the target
  scratch family exists. Cleanup checks only a temporary sentinel and do not
  cover retained entry state, exact monotonic prefix, references, later events,
  allocation/free balance or a concurrently live decoded handle.
- Impact: the test can report successful cleanup merely because nothing was
  allocated, while real late-exit leaks remain invisible.
- Decision: put each injected failure after a proved target event, hold a prior
  retained handle plus temporary sentinel, snapshot all counters/allocator
  state, then assert exact prefix, no later event, entry-state restoration,
  fixture allocation balance, reset output and unrelated-handle readability.
- Closure evidence: per-family physical/local/hash traces showing target reach
  and complete restoration.
- Authority: `type-layout-authority-v1.md` section 11.1, IC-028/029.

### IC-043 — TypeSchema `0..38` enum lacked an exhaustive P/S/T authority

- Date/phase: 2026-08-08, replacement RED authoring.
- Severity/status: Critical / Design resolved, test open.
- Problem: `record-wire-v1-remaining.md` froze field numbers and general lookup
  behavior but did not state every field's exact Primary/Secondary/Tertiary
  consumption. PropertyMetadata, optional BehaviorDeclaringOwner and
  EnumEnumeratorMetadata were independently ambiguous.
- Impact: the RED or Runtime could choose incompatible coordinate meanings,
  making a supposedly append-only diagnostic API unstable and leaving nested
  exact offsets untestable.
- Decision: add the exhaustive range table to the wire authority. Field 19 is
  `{PropertyOrdinal,MetadataOrdinal,U}`; field 29 is
  `{BehaviorOrdinal,U,U}` and absent means unset; field 32 is
  `{EnumeratorOrdinal,MetadataOrdinal,U}`. Nested array-count offsets for 19
  and 32 remain decoder-internal; they are not overloaded public coordinates.
  Every unused index must be `U=MAX_uint32`.
- Closure evidence: full `0..38` valid/surplus/out-of-range/absent/
  inapplicable/zero-offset allocation-free RED and fresh 0C/0I review.
- Authority: `record-wire-v1-remaining.md` TypeSchema coordinate table,
  `type-schema-matrix-v1.md`.

### IC-044 — a partial common token would make controller accounting unstable

- Date/phase: 2026-08-08, unified-handle GREEN preflight.
- Severity/status: Critical / Design resolved, implementation open.
- Problem: only SourceIndex/ModuleInterface DTOs currently exist, but the sole
  token must expose seven kinds and its exact `MakeShared` controller charge
  depends on final token size. Adding later by-value alternatives changes the
  charge; pimpl/type erasure introduces another persistent owner allocation.
- Impact: an early two-kind token would freeze invalid budget goldens or require
  a compatibility/storage rewrite forbidden by the sole-owner contract.
- Decision: declare all seven DTO/coordinate/offset types first, then define
  `AngelscriptCacheDecodedRecord.h` with one final in-place by-value seven-arm
  `{DTO,offsets}` variant. No partial token, pimpl or per-kind owner.
- Closure evidence: final complete type/controller size compile oracle and
  seven-kind factory/handle tests at 0C/0I.
- Authority: `record-wire-v1-remaining.md`, `implementation-plan.md` file map.

### IC-045 — controller quantization used declared rather than effective new alignment

- Date/phase: 2026-08-08, UE 5.8 source preflight.
- Severity/status: Important / Design resolved, test and implementation open.
- Problem: prior RED used `alignof(FController)` in `QuantizeSize`, while UE's
  replacement ordinary `operator new` uses alignment 8 for size <=8 and
  `__STDCPP_DEFAULT_NEW_ALIGNMENT__` otherwise; only over-aligned types use
  their declared alignment.
- Impact: allocator-size charges can differ across allocator/configuration even
  if the current Binned size class happens to mask the error.
- Decision: freeze the effective-new-alignment formula for the exact final
  intrusive controller. Never call `GetAllocSize` on the token's interior
  object pointer; a test-only exact-controller base allocation measures actual
  capacity, while production remains one private-token `MakeShared`.
- Closure evidence: independent formula, measured exact-controller allocation,
  one production construction and zero-delta handle-copy evidence.
- Authority: UE 5.8 `SharedPointer.h`, `SharedPointerInternals.h`,
  `Modules/Boilerplate/ModuleBoilerplate.h`, `record-wire-v1-remaining.md`.

### IC-046 — split decoded/resident acquisitions permit half-charged allocations

- Date/phase: 2026-08-08, unified-handle GREEN preflight.
- Severity/status: Critical / Design resolved, implementation open.
- Problem: current callers can consume TotalDecoded and then fail Resident, or
  reserve Temporary without consuming Total. Current peak records only maximum
  temporary bytes.
- Impact: one physical allocation can leave a half transaction, evade total
  accounting, or report a false combined-live peak.
- Decision: replace split public helpers with atomic
  `TryConsumeRetainedDecoded` and `TryReserveTemporaryDecoded`; both preflight
  Total and combined live before changing counters. Add direct combined-live
  peak sampling and `PromoteToRetained` reclassification without second charge.
- Closure evidence: exact/one-short tests for both dimensions, target counters
  unchanged on rejection, release/promotion and combined-live timeline tests.
- Authority: `record-wire-v1-remaining.md` one-budget section,
  `decoded-record-boundary-audit.md`.

### IC-047 — envelope payload copy is outside allocator-authoritative decoded accounting

- Date/phase: 2026-08-08, unified-handle GREEN preflight.
- Severity/status: Important / Open.
- Problem: envelope decode has no mandatory caller Budget path and copies the
  payload without charging the actual owned-byte `TArray` capacity to Total and
  Resident.
- Impact: multi-record sessions undercount before token decode and cannot apply
  one shared limit consistently.
- Decision: add the Budget overload; convenience overload delegates with a
  fresh Budget. Preflight actual owned-byte capacity atomically before copy and
  preserve alias/failure reset behavior.
- Closure evidence: capacity boundary/exact/short/alias tests and shared-session
  cumulative envelope+token evidence.
- Authority: `record-wire-v1-remaining.md`, `AngelscriptCacheArchive.*`.

### IC-048 — SourceIndex/ModuleInterface candidates discard most nested offsets

- Date/phase: 2026-08-08, unified-handle GREEN preflight.
- Severity/status: Critical / Open.
- Problem: current stack offset structs retain only ten/eight shallow values
  and are destroyed after decode. Nested options, rows, optional values,
  recursive data types, parameters, metadata, slots and dependencies are not
  publishable through the frozen coordinate APIs.
- Impact: exact graph/query diagnostics would require forbidden payload rescans
  or offset-zero fallback.
- Decision: private per-kind candidates own DTO plus exhaustive parallel offset
  trees/arrays with recursive pre-order spaces and a nonzero absence sentinel;
  move them into the final token after local validation.
- Closure evidence: SourceIndex `0..89`, ModuleInterface `0..88`, nested
  diagnostics, zero-offset and no-rescan tests.
- Authority: `source-interface-captured-offsets-v1.md`,
  `decoded-record-boundary-audit.md`.

### IC-049 — codec, validation and eligibility allocation charges remain approximate

- Date/phase: 2026-08-08, unified-handle GREEN preflight.
- Severity/status: Critical / Partial fix implemented, dynamic verification open.
- Problem: common array/string reads charge requested counts; empty strings and
  allocator slack diverge. Source/MI validation uses fixed payload-based scratch
  estimates, query scratch omits Total, and output uses `sizeof(row)+Len`
  instead of actual array/string capacities.
- Impact: wrapping old decoders in the new handle would still violate every
  allocator-authoritative exact/short invariant and could allocate before a
  successful reservation.
- Decision: split count/minimum-wire checks from typed reserve/setnum; compute
  each actual allocator capacity, atomically charge before growth, and verify
  `GetAllocatedSize`. Replace every fixed/semantic estimate for retained,
  scratch and output sites.
- Closure evidence: per-site exact/Total-short/Resident-short/no-attempt tests
  across codec, Source/MI local validation and eligibility output.
- Authority: `type-layout-authority-v1.md`,
  `decoded-record-boundary-audit.md`, Source/MI acceptance matrix.

### IC-050 — zero-byte temporary acquisition had no guard-state contract

- Date/phase: 2026-08-08, atomic Budget RED preflight.
- Severity/status: Important / Fix implemented, dynamic verification open.
- Problem: the one-budget authority required a successful temporary acquisition
  to install a move-only guard but did not say whether a zero-byte request was
  an active reservation or an allocation-free no-op.
- Impact: an active zero-byte guard would represent no physical allocation,
  make promotion semantics ambiguous, and allow implementations/tests to
  disagree about whether an existing guard may be replaced by a zero-byte call.
- Decision: zero-byte temporary acquisition succeeds only into an inactive
  guard, leaves it inactive, and changes no counter or peak. Any active output
  guard rejects every request including zero; inactive/zero promotion returns
  false. Zero retained consumption is likewise a successful no-op.
- Closure evidence: focused zero-byte success/active-output rejection,
  Reset/destructor, promotion and complete counter/peak invariance tests.
- Authority: `record-wire-v1-remaining.md` one-budget section.

### IC-051 — RecordId hashing allocated its fixed semantic header on the heap

- Date/phase: 2026-08-08, Budget-taking envelope implementation.
- Severity/status: Important / Fix implemented, dynamic verification open.
- Problem: `BuildRecordIdUnchecked` built its fixed 31-byte domain/version/kind/
  payload-size prefix in a temporary `TArray<uint8>` before hashing.
- Impact: every envelope validation, including a later decoded-budget rejection,
  performed an unbudgeted heap allocation with no retained or scratch owner;
  this weakened allocation-before-rejection evidence and added avoidable hot-path
  work.
- Decision: encode the exact same bytes into a fixed-size stack array using the
  existing little-endian rules, assert the final cursor, and hash that view.
- Closure evidence: unchanged RecordId/envelope goldens, focused envelope tests,
  allocation/static review and final Cache prefix.
- Authority: frozen RecordId golden in `record-wire-v1.md` and the one-budget
  allocation ownership rule in `record-wire-v1-remaining.md`.

### IC-052 — primitive decoded-budget tests equated wire bytes with owned capacity

- Date/phase: 2026-08-08, canonical-codec allocator GREEN.
- Severity/status: Important / Partial fix implemented, RED and dynamic verification open.
- Problem: the canonical DataType cumulative-budget test used
  `NestedBytes.Num()` as the decoded-memory exact limit, while string and array
  readers charged requested element bytes rather than the default UE allocator's
  reserved capacity. This made the test and implementation share the same false
  model and could miss allocator slack.
- Impact: a cache record could allocate more owned memory than its decoded budget
  reports; Total and Resident one-short behavior depended on payload length rather
  than the physical allocation site, and diagnostics had no named decode stage.
- Decision: derive string and typed-array charges independently with each actual
  `ElementAllocatorType::CalculateSlackReserve`, atomically consume the capacity
  before `Reserve`/`SetNum`, release any prior destination capacity first, and
  report physical budget failures at `PayloadDecode` with the count/string field
  offset. Measure the single-read decoded total before constructing a cumulative
  session limit instead of reusing payload size.
- Closure evidence: canonical string and recursive DataType exact-capacity,
  Total-short, Resident-short, empty-zero-allocation, allocation-size, counter
  invariance and staged-offset tests; focused primitive GREEN plus final Cache
  prefix.
- Authority: `record-wire-v1-remaining.md` one-budget section,
  `type-layout-authority-v1.md`, IC-049.

### IC-053 — one public scratch guard cannot accumulate a decoded-token candidate

- Date/phase: 2026-08-08, TypeSchema declaration-GREEN preflight.
- Severity/status: Critical / Private transaction implemented and declaration-compiled;
  canonical charge-sink/factory integration remains open.
- Problem: the public temporary API intentionally rejects every acquisition
  into an already-active reservation. A decoded token, however, has a dynamic
  sequence of controller, canonical-payload, DTO string/array and captured-
  offset allocations that are not publishable until the final local/hash
  checks succeed. Charging them directly as retained leaks conservative
  Resident on pre-publication failure; creating one public guard per site
  requires another dynamically allocated guard container and cannot perform
  one atomic final promotion.
- Impact: the unified factory cannot simultaneously provide per-site atomic
  one-short rejection, failure cleanup, one Total charge, one combined-live
  charge and all-or-nothing scratch-to-retained publication with the current
  public primitive alone.
- Decision: keep the public active-output rejection contract, but add
  a private, Budget-friended decoded-candidate transaction that can extend one
  existing temporary reservation after each independently preflighted physical
  site. It owns one aggregate reserved-byte count, releases the aggregate
  temporary live bytes on failure, and promotes the aggregate exactly once
  immediately before publishing the handle. Extension remains inaccessible to
  callers and cannot reset/refund TotalDecoded.
- Closure evidence: compile-time absence of a public extension API; per-site
  Total/Resident one-short with no target allocation; multiple successful
  extensions followed by failure restoring entry Temporary; final promotion
  moving the aggregate to Resident without changing Total/Peak; allocation-
  probe chronology and one common token publication.
- Authority: `record-wire-v1-remaining.md` one-budget candidate/promotion rules,
  `decoded-record-boundary-audit.md`, Task 2.5a.

### IC-054 — decoded-token candidate lifetime in the replacement RED is contradictory

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Critical / Design/authority resolved, RED repair open.
- Problem: allocation events are labelled retained and charge Resident directly,
  while pre-publication failures expect accepted Resident bytes to be rolled back.
  Resident is monotonic, so no Budget implementation can satisfy both.
- Decision: decoded-token candidate allocations form one private aggregate
  Temporary transaction. Each site extends it atomically before allocation;
  failure releases only live Temporary bytes while Total remains monotonic; success
  promotes the aggregate exactly once immediately before handle publication.
- Closure evidence: updated authority, chronological Temporary events, exact
  failure cleanup, one final promotion, and no public transaction-extension API.

### IC-055 — TypeSchema exact and one-short runs do not share expanded site cases

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Critical / AA4808 reused the expanded short cases but still used
  unlimited success; exact-limit success repair remains open.
- Problem: success uses broader allocator-boundary cardinalities, but per-site Total
  and Resident one-short runs fall back to `{1,17}`. String prefix/terminator,
  first/middle/last occurrences and recursive sites are not exhausted.
- Decision: one test-owned expanded-case table drives exact, Total-short and
  Resident-short for each actual element type and occurrence, including reverse
  cardinality selection for strings whose request includes fixed text.
- Closure evidence: every Required nonzero site and occurrence passes all three
  runs at its own allocator slack boundary.

### IC-056 — TypeSchema precedence RED uses an unrepresentable missing selected arm

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Critical / AA4808 replaced the unrepresentable arm with legal
  `Enum + None`, so the intended later fault still does not exist; repair open.
- Problem: resetting the selected Enum DTO arm before physical serialization omits
  bytes; the wire has no independent selected-arm presence tag, so this cannot
  encode the claimed later `InvalidPresence` semantic fault.
- Decision: retain a complete selected arm, add a later representable presence
  fault, prove it alone with an exact tuple, then combine it with earlier invalid
  UTF-8 to freeze precedence.
- Closure evidence: independent scanner offset and exact single/combined tuples.

### IC-057 — replacement RED still derives exact failure offsets from writer trace

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / Independently accepted in AA4808; next repaired SHA
  must retain raw-scanner authority.
- Problem: much of the malformed-input matrix uses the payload writer trace as the
  expected ByteOffset oracle, allowing writer and decoder mistakes to agree.
- Decision: expected offsets come only from the independent raw scanner inventory;
  writer trace is restricted to mutation targeting and cross-checking.
- Closure evidence: no expected-result helper consumes writer trace.

### IC-058 — ordinal fixtures contain multiple faults and stale derived hashes

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / AA4808 improved single-axis mutations but reintroduced
  valid-fixture finalization on malformed ordinals and left replay fingerprints stale;
  repair remains open.
- Problem: UFunction/property/method/VFT/direct-interface cases duplicate whole
  identity rows or reorder rows without recomputing downstream hashes, so the named
  ordinal predicate is not isolated.
- Decision: construct distinct valid rows, mutate only ordinal/order, recompute all
  affected hashes, and prove each single fault before combinations.
- Closure evidence: exact local tuple per isolated ordinal predicate.

### IC-059 — Required TypeSchema allocation fixtures are not all locally valid

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / AA4808 fixed the base fixture but still marks an
  impossible Typedef subtype and incomplete dependency closures Required; repair open.
- Problem: one UClass fixture asserts a nonzero base boundary it does not construct,
  and dependency fixtures may lack matching local authority closure. A malformed
  fixture can currently mark a Required site as expanded.
- Decision: every Required fixture first passes the unlimited-budget common factory;
  add a dedicated nonzero-base fixture and complete dependency authorities, or mark
  the case `InvalidFixtureOnly`.
- Closure evidence: valid-success precheck gates every Required expansion.

### IC-060 — reference coverage does not freeze the reference-bearing set

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / AA4808 added per-occurrence shorts but still derives
  the exact occurrence set from the fixture DTO; independent static authority open.
- Problem: the matrix proves only that at least one family has a reference, so
  omitted family/variant occurrences or changed ordering can pass.
- Decision: maintain a test-owned exact ordered family/variant/occurrence set and
  verify exact/reference-short prefixes, no later attempts and cleanup.
- Closure evidence: exact set/count/order equality and per-reference short rows.

### IC-061 — 53 TypeSchema SiteKinds/templates are not frozen exhaustively by code

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / RED repair open.
- Problem: the count is a manual observation; no enum sentinel, fixed-size table,
  one-template-per-kind frequency check or valid-only Required closure exists.
- Decision: add `Count`, a fixed expected count, exact frequency/disposition checks,
  and let only successfully decoded fixtures close Required coverage.
- Closure evidence: static/runtime exhaustion rejects gaps and duplicates.

### IC-062 — StreamingZero reachability and successful-handle cleanup are not proved

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / AA4808 independently closed the twelve checkpoints and
  in-probe handle reset, but the caller-owned fixed-view/overflow probe contract is open.
- Problem: zero allocation can be observed even if the intended validator never ran;
  several successful handles are destroyed after the allocation probe.
- Decision: expose semantic-blind validation checkpoints, add success/later-fault
  rows for every StreamingZero path, and reset output while the probe is active.
- Closure evidence: checkpoint chronology, zero attempts/bytes and in-probe balance.

### IC-063 — producer inactive-arm rejection lacks a frozen exact tuple

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `44432F...`.
- Severity/status: Important / Authority and RED repair open.
- Problem: producer rejection checks only `Error`, leaving Class, RecordKind, Stage
  and ByteOffset ambiguous.
- Decision: freeze `InvalidPresence / CanonicalSemantic / TypeSchema / None / 0`
  with empty output because no producer-stage or payload coordinate exists.
- Closure evidence: authority text and unified exact-result assertion.

### IC-064 — primitive array RED does not force allocator slack or a recursive second site

- Date/phase: 2026-08-08, independent canonical-codec allocator review.
- Severity/status: Important / Fix independently approved 0C/0I; Runtime compile/link
  green, primitive Automation pending.
- Problem: the fixture reserves one large DTO and its child has no subtype array.
  Capacity may equal requested count, so the old `Count * sizeof(T)` model can pass,
  and no second recursive allocation offset/prefix is exercised.
- Decision: dynamically find a real slack count, use it in a child subtype array,
  independently calculate both capacities and run exact plus Total/Resident one-short
  at the second allocation while preserving the first accepted charge.
- Closure evidence: `ReservedCapacity > RequestedCapacity`, exact two-site bytes,
  second-site `PayloadDecode` offset and no partial target charge.

### IC-065 — primitive budget rejection does not observe allocation attempts

- Date/phase: 2026-08-08, independent canonical-codec allocator review.
- Severity/status: Important / Fix implemented; Runtime compile/link green,
  primitive automation blocked by the TypeSchema declaration RED.
- Problem: public decode uses a local candidate. An incorrect implementation could
  allocate locally, check Budget afterward, destroy the candidate and still leave the
  caller output/counters exactly as current tests expect.
- Decision: add a test-only allocation-site/event probe for string and typed array,
  assert Budget consumption precedes exact allocation, and assert zero target attempts
  for Total/Resident rejection. Also cover a destination with pre-existing capacity.
- Closure evidence: event chronology and zero-attempt short runs, not final capacity alone.

### IC-066 — primitive trailing-data diagnostics still report Stage None

- Date/phase: 2026-08-08, independent canonical-codec allocator review.
- Severity/status: Important / Fix implemented; Runtime compile/link green,
  primitive automation blocked by the TypeSchema declaration RED.
- Problem: standalone canonical string/DataType wrappers route trailing bytes through
  the legacy local `Failure`, producing `Stage=None`; the test checks only Error.
- Decision: use an explicit `PayloadDecode` result at the first trailing byte without
  globally changing producer-side failure staging, and freeze the complete tuple.
- Closure evidence: string/DataType trailing tests assert Error, `Class=Malformed`,
  invalid RecordKind, `Stage=PayloadDecode` and exact first-trailing ByteOffset.

### IC-067 — canonical reader hardcodes retained charging and cannot join a decoded candidate

- Date/phase: 2026-08-08, private candidate transaction implementation audit.
- Severity/status: Critical / retained sink and explicit per-call observation implemented;
  candidate binding and Automation remain open.
- Problem: `FReader::ReadString` and `ReadArrayCountAndReserve` call
  `TryConsumeRetainedDecoded` directly. A private aggregate transaction alone cannot
  make TypeSchema, SourceIndex or ModuleInterface DTO allocations Temporary before
  publication; copying the reader or selecting behavior through global state would
  create divergent codecs or unsafe cross-session behavior.
- Decision: give the private canonical reader a required semantic-blind decoded
  allocation-charge sink/context. Standalone primitive decoding binds a retained
  sink; the sole all-record factory binds its private candidate transaction. Both
  paths perform the same capacity calculation, limit preflight, diagnostics and
  allocation chronology. The choice is constructor-owned and never process-global.
- Closure evidence: compile-time no public mode/extension escape; identical primitive
  bytes/results under retained mode; record factory events charge Temporary until one
  promotion; SourceIndex/ModuleInterface migration uses the same reader rather than a
  copied codec; concurrent independent Budgets cannot cross-route charges.
- Authority: `record-wire-v1-remaining.md` one-budget section,
  `decoded-record-boundary-audit.md`, IC-053/IC-054.
- Current evidence: a Primitive compile RED failed only on the absent explicit-capture
  facade. `FReader` now requires an immutable two-pointer `FDecodedChargeSink`, the
  retained adapter lives outside the codec, ambient TLS capture was removed, the
  canonical header contains zero `TryConsumeRetainedDecoded` calls and still has one
  physical `Reserve`. Runtime, Primitive and Budget single TUs compile and the Runtime
  module links. A fresh exact-SHA independent source review of the four-file slice
  returned **0 Critical / 0 Important / 0 Minor** and confirmed required by-value
  sink ownership, charge-before-the-single-Reserve, semantic blindness, same-path
  capture facades, caller-owned saturation, alias lifetime safety and complete non-
  test macro exclusion. The future unified factory must still bind the private
  candidate adapter and prove Temporary-to-Resident publication through the same
  reader; Primitive/Budget Automation also remains gated by the TypeSchema header.

### IC-068 — Budget one-owner wording did not freeze a concurrency model

- Date/phase: 2026-08-08, decoded-candidate transaction preflight.
- Severity/status: Important / Thread-affine checks implemented and declaration-compiled;
  dynamic/cross-thread invariant verification remains open.
- Problem: counters and transaction state are plain integers. Calling per-site
  updates "atomic" without freezing thread affinity could be misread as allowing
  multiple workers to share one mutable Budget; independent preflights can then
  both pass and exceed limits or interleave release/promotion into underflow.
- Decision: Cache V2 Budget is a thread-affine, single-owner mutable session object.
  Decode, candidate, scratch, graph and query mutation is sequential on the owner
  thread. Published thread-safe handles may cross threads; Budget may not.
- Closure evidence: authority text, owner-thread and active-transaction invariant
  tests, and no claim that separate atomics provide a multi-counter commit.

### IC-069 — predicted allocator charge has no safe post-allocation correction

- Date/phase: 2026-08-08, decoded-candidate transaction preflight.
- Severity/status: Important / Canonical string/array fix independently approved
  0C/0I and Runtime compile/link green; shared-token/controller verification remains open.
- Problem: if `CalculateSlackReserve`/`QuantizeSize` predicts fewer bytes than the
  actual allocation, charging the difference after `Reserve` or `MakeShared` is
  already too late and can violate a one-byte-short limit.
- Decision: supported allocator/platform combinations prove predicted bytes equal
  `GetAllocatedSize`/controller-base `GetAllocSize`; development/test builds fail
  fast on divergence. Unsupported combinations fail closed.
- Closure evidence: exact controller/array/string allocator probes on each supported
  target and zero post-allocation Budget adjustment paths.

### IC-070 — primitive allocation observer was globally active in every unit-test decode

- Date/phase: 2026-08-08, independent review of IC-064..IC-066 implementation.
- Severity/status: Critical / Fix implemented; Runtime compile/link green,
  primitive dynamic verification open.
- Problem: the fixed 64-event thread-local buffer recorded unconditionally whenever
  `WITH_ANGELSCRIPT_UNITTESTS` was enabled. Unrelated SourceIndex/ModuleInterface or
  future TypeSchema decoding could fill it and trigger `checkf` even when no test was
  observing primitive allocation chronology.
- Decision: capture is default-off and enabled only by a non-nestable scoped observer;
  scope construction clears the fixed buffer, destruction disables recording, and
  production decode outside the scope is inert.
- Closure evidence: fresh Runtime compile/link, default-off unrelated decode test,
  scope/nesting behavior and focused primitive automation after the TypeSchema gate.

### IC-071 — primitive observer exposed its event-record mutation entry publicly

- Date/phase: 2026-08-08, independent review of IC-064..IC-066 implementation.
- Severity/status: Important / Fix independently approved 0C/0I and Runtime
  compile/link green; non-test final target verification remains open.
- Problem: `RecordAllocationEventForTests` was declared in the public Runtime cache
  header, allowing test or consumer code to forge observed production events.
- Decision: public unit-test surface exposes only scoped capture and read access;
  the record function declaration lives exclusively in the Runtime private canonical
  codec header, carries no DLL export, and remains compiled out of non-test builds.
- Closure evidence: public-header and exported-symbol forbidden scans plus a fresh
  Runtime compile.

### IC-072 — Budget test friend initially remained available in non-test builds

- Date/phase: 2026-08-08, private candidate transaction compile review.
- Severity/status: Important / Fix independently approved 0C/0I/0M; Runtime
  compilation green, later non-test target verification remains open.
- Problem: the global `FAngelscriptCacheBudgetTests` forward/friend declaration was
  initially unconditional. A non-test consumer could define that name and obtain the
  private candidate mutation surface, contradicting the no-public-extension rule.
- Decision: both the forward declaration and friendship exist only under
  `WITH_ANGELSCRIPT_UNITTESTS`; production friendship remains limited to the sole
  decoded-record factory.
- Closure evidence: preprocessor/public-surface scan plus Editor and non-test target
  compilation after the final token implementation is available.

### IC-073 — CQTest macro uses a struct class-key for the Budget test friend

- Date/phase: 2026-08-08, private candidate transaction declaration build.
- Severity/status: Important / Fix implemented and declaration-compiled.
- Problem: the first test-only friend forward used `class`, while
  `TEST_CLASS_WITH_FLAGS` defines the fixture with `struct`, producing MSVC `C4099`;
  the first correction changed only the forward and left `friend class`, causing the
  same diagnostic in Runtime and Test unities.
- Decision: use `struct` consistently for both guarded forward and friend, still only
  under `WITH_ANGELSCRIPT_UNITTESTS`.
- Closure evidence: the subsequent wrapper compiles Runtime unities and the Budget
  test unity past this diagnostic; only the known TypeSchema header remains.

### IC-074 — allocation chronology marker was separable from the actual allocation

- Date/phase: 2026-08-08, independent review of the repaired canonical primitive
  allocator slice.
- Severity/status: Important / Fix independently approved 0C/0I and Runtime
  compile/link green; Automation pending.
- Problem: string and typed-array readers emitted an `AllocationAttempt` test event
  in one statement and called `Reserve` in another. The focused tests therefore
  proved only that production did not emit its own marker; a regression could move
  or add a real allocation before Budget preflight while leaving the marker in its
  old location and still satisfy the chronology oracle.
- Decision: every canonical container reserve SHALL pass through one reader-owned
  instrumented allocation helper. That helper emits attempt, performs the actual
  reserve, observes the real allocated bytes, verifies them against the preflighted
  allocator prediction and then emits success. Call sites may not invoke the same
  reserve operation separately.
- Closure evidence: forbidden direct-reserve scans for the supported string/array
  decode sites, attempt/success/actual-byte event tests, target-short tests with no
  target allocation event, and fresh Runtime plus focused Automation results.

### IC-075 — the primitive observer had no caller-owned overflow protocol

- Date/phase: 2026-08-08, independent review of the repaired canonical primitive
  allocator slice.
- Severity/status: Important / Fix independently approved 0C/0I and Runtime
  compile/link green; IC-079 boundary fixtures and Automation pending.
- Problem: Runtime owned a fixed 64-event TLS buffer. A 65th event asserted in check
  builds or was silently truncated in non-check builds, so a test could not
  distinguish a complete 64-event trace from an overflowed one. This also violated
  the frozen caller-provided fixed-capacity-view contract.
- Decision: the observing test supplies a fixed-capacity event view. The capture
  stores count plus an explicit overflow bit, never grows, logs or allocates, and
  discards excess events after setting overflow. Normal focused tests require no
  overflow; a deliberately undersized view proves decode behavior is unaffected and
  overflow is observable.
- Closure evidence: undersized fixed-buffer overflow fixture, allocation-free observer
  surface scan, no fixed Runtime event array, and focused Automation results.

### IC-076 — a TLS observer scope did not bind its destruction thread

- Date/phase: 2026-08-08, independent review of the repaired canonical primitive
  allocator slice.
- Severity/status: Important / Fix independently approved 0C/0I and Runtime
  compile/link green; IC-079 invariant fixture remains open.
- Problem: the observer used thread-local active state but the RAII object did not
  retain its construction thread. Destruction on another thread would operate on a
  different TLS slot and leave the origin thread active, with a check-only symptom
  in Development and silent stale state in Shipping-style configurations.
- Decision: the scoped observer captures the creating thread ID and requires same-
  thread destruction before clearing the exact TLS capture pointer. The type remains
  non-copyable and non-movable; nested capture remains rejected.
- Closure evidence: declaration/implementation scan, owner-thread invariant test or
  test-only check evidence, and fresh Runtime compilation.

### IC-077 — decoded-candidate transactions borrowed mutable Limits storage

- Date/phase: 2026-08-08, independent review of the private candidate transaction.
- Severity/status: Important / Fix independently approved 0C/0I/0M; Runtime
  compile/link and pre-fatal Test-unity parsing green, Automation pending.
- Problem: a transaction retained a raw pointer to the caller's
  `FAngelscriptCacheReadLimits`. A temporary argument could expire before the first
  extension, and a named Limits object could be modified mid-transaction so one
  candidate used different policies at different allocation sites.
- Decision: Begin snapshots only the two decoded-allocation limits owned by this
  transaction (`MaxTotalDecodedBytes` and `MaxResidentDecodedBytes`) by value.
  Extensions never dereference caller storage.
- Closure evidence: focused temporary-Limits and mutated-source-Limits cases plus a
  forbidden stored-Limits-pointer scan and fresh build/Automation results.

### IC-078 — cross-Budget candidate move-assignment could outlive its new owner

- Date/phase: 2026-08-08, independent review of the private candidate transaction.
- Severity/status: Important / Fix independently approved 0C/0I/0M; Runtime
  compile/link and pre-fatal Test-unity parsing green, Automation pending.
- Problem: move-assignment could transfer a raw Budget owner from a shorter-lived
  source into a longer-lived destination transaction. Development caught the active
  transaction during Budget destruction, but non-check builds could later call
  release through a dangling owner pointer.
- Decision: the private transaction supports move construction only. Move-assignment
  is deleted because the sole factory needs return/ownership transfer, not arbitrary
  rebinding. Natural declaration order keeps every transaction inside its Budget
  lifetime without introducing a lifetime-token graph.
- Closure evidence: `!is_move_assignable` plus move-construction, destruction and
  promotion exactly-once fixtures, followed by fresh build/Automation results.

### IC-079 — canonical observer boundary fixtures are not yet exhaustive

- Date/phase: 2026-08-08, independent review of canonical repair SHA `1263BBB...`.
- Severity/status: Minor / One-slot, zero-capacity and invalid-view tests implemented;
  source behavior independently approved 0C/0I, build/Automation pending.
- Problem: the caller-owned capture implementation safely handles zero capacity,
  invalid positive-size/null storage, nested scopes and wrong-thread destruction,
  but focused tests currently cover default-off, normal capture, two-slot overflow
  and the zero-event empty string only. The authority attachment also said
  "one-event buffer" while the implementation test deliberately uses two slots of a
  four-event decode; both demonstrate overflow, but the recorded fixture is stale.
- Decision: retain the independently approved implementation and add explicit
  zero-capacity/invalid-view/nested/owner-thread invariant cases before closing the
  canonical Automation checkpoint. Describe the overflow fixture as an undersized
  caller buffer rather than freezing an unnecessary capacity of one.
- Closure evidence: source cases plus focused Automation after the TypeSchema Test-
  unity declaration gate is removed. This Minor does not reopen the scoped 0C/0I
  implementation approval or close IC-067.

### IC-080 — wrong-record-kind coordinate tests use universally invalid defaults

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `AA4808...`.
- Severity/status: Critical / RED repair in progress.
- Problem: the TypeSchema token is queried with default SourceIndex,
  ModuleInterface, ModuleState, FunctionBody, DebugSidecar and ModuleSnapshot
  coordinates. Their `Field=Invalid` would be unset for every token, so the test
  cannot detect a token that incorrectly accepts another record kind's valid field.
- Decision: query every overload with a frozen legal, present coordinate from that
  other kind and require unset on the TypeSchema handle; the unified-handle matrix
  later supplies the reverse direction with non-TypeSchema records.
- Closure evidence: valid-coordinate construction scans, exact overload assertions
  and the complete all-record handle Automation matrix.

### IC-081 — TypeSchema allocation probe permits a Runtime-owned growing observer

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `AA4808...`.
- Severity/status: Important / RED repair in progress.
- Problem: default-constructed probes expose getter-owned arrays with no caller
  capacity or overflow state. A dynamically growing Runtime `TArray`, or a silently
  truncated fixed buffer, could satisfy the RED and diverge from the canonical
  observer already approved by IC-075.
- Decision: freeze caller-owned fixed views, explicit counts and overflow for every
  generic event/checkpoint stream; normal cases require no overflow and a deliberate
  undersized case must overflow without changing decode behavior. The observer
  remains semantic-blind, allocation-free and non-growing.
- Closure evidence: public declaration shape, undersized fixture, allocation scans
  and focused Automation.

### IC-082 — TypeSchema fault injection invents an unfrozen public validation error

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `AA4808...`.
- Severity/status: Important / RED repair in progress.
- Problem: `InjectedTestFailure` is absent from the append-only public validation
  error range `0..64`, its classifier and every wire authority. Making the RED
  compile would silently extend production protocol solely for a test hook.
- Decision: fault injection returns an already frozen error/result and exposes a
  separate private test-only checkpoint proving the requested injection fired. Test
  observation never changes public validation-enum layout.
- Closure evidence: zero `InjectedTestFailure` references, unchanged enum/classifier
  goldens, injection checkpoint assertions and focused Automation.

### IC-083 — malformed ordinal fixtures call the valid-fixture hash finalizer

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `AA4808...`.
- Severity/status: Important / RED repair in progress.
- Problem: gap/duplicate/reorder fixtures call `FinalizeValidFixtureHashes` after
  becoming semantically malformed. A correct fail-closed public hash helper may
  assert/reject before decode, so the named ordinal tuple is unreachable.
- Decision: use a narrow physical/test-only derived-hash patch path that does not
  claim the DTO is valid, or mutate the serialized bytes and recompute only the
  downstream wire hashes required to isolate the ordinal axis. Public valid-fixture
  helpers never consume intentionally malformed DTOs.
- Closure evidence: forbidden-call scans over all malformed ordinal rows and decoded
  tuple Automation without pre-decode checks.

### IC-084 — property replay fixtures retain stale fingerprints

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `AA4808...`.
- Severity/status: Important / RED repair in progress.
- Problem: overlap and wrong-cursor mutations change `SemanticByteOffset`, which is
  an input to `PropertyLayoutFingerprint`, but expect the later layout replay error
  without recomputing the fingerprint. A correct decoder first returns
  `DerivedHashMismatch`.
- Decision: recompute the per-property fingerprint and final TypeLayoutHash while
  preserving only the intended self-consistent wrong offset, so replay is the first
  failing axis.
- Closure evidence: expected recomputed hashes and exact replay tuple Automation.

### IC-085 — frozen TypeSchema line count did not name its counting convention

- Date/phase: 2026-08-08, independent review of TypeSchema RED SHA `AA4808...`.
- Severity/status: Minor / Record repair in progress.
- Problem: the attachment reported 8,411 lines by counting the trailing empty split,
  while `ReadAllLines`/LF terminators report 8,410 logical lines for the same SHA.
- Decision: every future freeze reports bytes, LF terminators, final-newline state and
  logical-line convention separately; line count is diagnostic identity only, never
  an approval criterion.
- Closure evidence: unambiguous next-SHA freeze metadata.

### IC-086 — Typedef allocation authority contradicted legal V1 aliases

- Date/phase: 2026-08-08, second TypeSchema RED repair preflight.
- Severity/status: Critical authority contradiction corrected; Important allocator-
  evidence gap remains in the `12E890...` candidate.
- Problem: the semantic matrix permits only an unqualified primitive Typedef alias,
  whose subtype count is necessarily zero, while TS-SCR-09 described Typedef subtype
  storage as a Required success allocation. No correct producer/common factory could
  satisfy both statements, encouraging an invalid EnvironmentType alias fixture.
- Decision: a legal primitive alias has a separate zero-event validation checkpoint.
  A physically encoded nonzero subtype count is hostile-input
  `InvalidFixtureOnly`: it proves pre-allocation Budget, exact capacity and candidate
  cleanup before semantic rejection, but never closes Required success exhaustion.
- Independent rereview result: the candidate freezes the disposition and semantic
  rejection, but its shared physical-only helper discards Budget state and installs
  no chronology observer. Add a dedicated hostile Typedef test that proves the exact
  target allocation and semantic rejection, Total/live one-byte-short failure before
  reserve, exact ByteOffset, empty output and zero live/allocation balance. The test
  must also prove that this fixture never closes Required-success coverage.
- Closure evidence: aligned authority text, one InvalidFixtureOnly static template,
  valid primitive checkpoint, hostile physical allocation/cleanup cases and zero
  successful non-primitive Typedef alias fixtures.

### IC-087 — TS-SCR-11 claimed dependency kinds TypeSchema cannot derive

- Date/phase: 2026-08-08, second TypeSchema RED repair preflight.
- Severity/status: Important / Authority corrected; RED repair in progress.
- Problem: allocation authority required successful fixtures for every common
  dependency enum, while TypeSchema can derive only `Inheritance`, `ValueLayout`,
  `Declaration`, `Signature` and `EnvironmentAbi`. Property/global/default/hard/
  initializer/compile-option rows belong to consumer records and are extra coverage
  in TypeSchema; injecting them made Required fixtures locally invalid.
- Decision: Required TS-SCR-11 expanded success is limited to the exact five derived
  kinds with real relation/property/callable/environment carriers. Other enum values
  retain physical/semantic rejection coverage and cannot close the allocation site.
- Closure evidence: authority text, successful common-factory precheck for every
  Required variant, exact derived-coverage graph cases and rejection of extras.

### IC-088 — LayoutInput Target is simultaneously required and treated as optional

- Date/phase: 2026-08-08, TypeSchema GREEN file-map preflight.
- Severity/status: Critical / RED repair in progress.
- Problem: wire authority defines `FAngelscriptCachedTypeLayoutInput::Target` as a
  required direct stable reference, and most tests pass it directly, but one fixture
  calls `IsSet()`/`operator->` as if it were `TOptional`. No coherent public DTO can
  satisfy both shapes without weakening required-field semantics.
- Decision: Target remains a direct `FAngelscriptCacheStableReference`; fixtures
  mutate `Target.StableKey` directly and use an explicitly invalid reference when
  testing zero/invalid identity. No optional wrapper or compatibility accessor is
  introduced.
- Independent rereview result: SHA `12E890...` still contains
  `Input.Target.Reset()` in the role/presence matrix and still assigns Target a
  presence-mask bit. Remove Target from the optional mask, enumerate only Boundary
  and Alignment, then cover zero key, invalid/wrong reference kind and ExpectedAbi
  rules as direct-reference failures. The forbidden scan must include `Reset`,
  `Get`, `GetValue`, `Emplace`, `IsSet` and `operator->`, and the RED must freeze the
  exact direct member type with a static assertion.
- Closure evidence: zero optional-style Target calls, exact DTO type assertion,
  required-reference physical/local failures and compiled TypeSchema declarations.

### IC-089 — expanded allocation cases re-decode every equivalent occurrence

- Date/phase: 2026-08-08, TypeSchema GREEN file-map preflight.
- Severity/status: Important / RED performance repair in progress.
- Problem: the expanded-case generator materializes every allocation event/P/S/T
  occurrence, and each case re-decodes and compares the entire chronology before two
  short runs. Nested properties/metadata therefore approach O(E^2) redundant work,
  obscuring the bounded matrix and making fixed probe capacity unnecessarily large.
- Decision: retain the frozen empty/one/actual-slack/many cardinalities and
  deterministic first/middle/last/nested representatives per site template. Run one
  full chronology/exact success per fixture, then only representative target-short
  cases. Exact reference-prefix coverage remains its separate test-owned matrix and
  is not inferred from this allocation sampling.
- Independent rereview result: fixture deduplication improved, but the fixed filtered
  view's `operator[]` rescans the full tagged chronology for each element and the
  complete comparison loop therefore remains O(E^2). Compare allocation events with
  one forward scan, remove or restrict random access to constant-size uses, and
  freeze the total fixture count, total target count and per-SiteKind representative
  counts so the bounded matrix cannot silently grow.
- Closure evidence: deterministic representative-count assertions, unchanged site-
  template exhaustion, full chronology once per fixture and measured focused runtime.

### IC-090 — TypeSchema header implicitly owns the all-record token surface

- Date/phase: 2026-08-08, TypeSchema GREEN file-map preflight.
- Severity/status: Important / repaired RED candidate frozen; independent approval pending.
- Problem: one test TU includes only Archive, SemanticRecords and TypeSchema headers
  while asserting `FAngelscriptDecodedCacheRecord`, seven typed accessors and graph
  APIs. Satisfying it through the TypeSchema header would create TypeSchema↔token
  responsibility coupling and likely include cycles.
- Decision: `AngelscriptCacheTypeSchema.h` owns TypeSchema DTO/archive/resolver
  declarations only. A separate `AngelscriptCacheDecodedRecord.h` owns the seven-kind
  immutable token, handle, typed coordinate overloads and graph entry; tests include
  it explicitly.
- Closure evidence: include-surface scan, standalone header compilation and no token
  declarations or indirect compatibility include in TypeSchema.

### IC-091 — test support can perturb the allocation and publication behavior it observes

- Date/phase: 2026-08-08, user-requested unit-test architecture expansion.
- Severity/status: Important / canonical and TypeSchema observation RED implemented;
  remaining all-record/store/lifecycle seams pending.
- Problem: allocation, rollback, validation-order and crash-window coverage needs
  internal observability and fault injection, but Runtime-owned growing event arrays,
  process-global mutable probes, public injected error values or test-only decode
  entry points would change the behavior under test and could leak into Shipping.
- Decision: test seams observe the same production path through caller-owned fixed-
  capacity views, explicit overflow, explicit synchronous per-call routing (or a
  thread-affine non-nestable scope only where unavoidable) and Private platform/
  resolver spies. They compile only with `WITH_ANGELSCRIPT_UNITTESTS` or live solely
  in Test/Private code. Injection uses a private checkpoint outcome and never extends
  the frozen public validation/store error enums. Equivalent allocation occurrences
  are sampled deterministically rather than re-decoding a full fixture quadratically.
- Expanded unit-test contract: every seam gets equivalence coverage with observation
  disabled/enabled, zero/undersized/exact capacity, explicit overflow, two independent
  callers and (where applicable) cross-thread isolation. Store/lifecycle substitutes
  implement the same production platform, clock, cancellation and executor interfaces;
  they may report call order or inject a private checkpoint outcome but may not bypass
  validation, fabricate public authority or directly publish a generation. Unit suites
  are layered into pure wire/value, candidate ownership, record factory/graph,
  invalidation planner, store recovery, lifecycle and bounded-concurrency groups so
  failures remain local and the normal suite avoids real package cost.
- Closure evidence: non-test symbol/size scan, zero observer allocations, overflow/
  nesting/thread guards, fault-point cleanup tests, production-versus-observed byte
  equality and focused runtime measurements for each split test translation unit.
  The evolving inventory and mandatory seam-integrity cases are maintained in
  `unit-test-coverage-matrix.md`; its current source baseline is 152 Cache test
  definitions, explicitly not a passing-test claim.

### IC-092 — broad private-namespace import made two Failure helpers ambiguous

- Date/phase: 2026-08-08, IC-067 Runtime single-TU GREEN.
- Severity/status: Important / resolved and recompiled.
- Problem: the first retained charge adapter used a file-scope `using namespace` for
  the canonical private codec. Later code already imported the semantic-record
  private namespace, so unqualified `Failure(...)` calls became ambiguous across the
  two intentionally separate helpers.
- Decision: import only the three required private sink/result/observer types through
  exact aliases. Never expose the canonical namespace through a broad directive in
  this translation unit and do not merge record-specific and byte-cursor failures.
- Closure evidence: the first wrapper compile failed only with the ambiguity; the
  identical single-TU command after the narrow-alias patch succeeded, followed by
  successful Primitive/Budget TUs and Runtime lib/DLL link.

### IC-093 — TypeSchema scoped probe requires hidden ambient routing

- Date/phase: 2026-08-08, TypeSchema GREEN declaration/file-map preflight.
- Severity/status: Critical / RED repair in progress.
- Problem: the frozen TypeSchema RED constructs
  `FAngelscriptCacheScopedTypeSchemaAllocationProbeForTests` around calls to public
  `FAngelscriptDecodedCacheRecord::TryDecode`, but that public signature has no probe
  argument and the scope has no factory/Budget reference. Making the scope affect the
  factory would require a TLS, global active observer, allocator singleton or hidden
  mode, contradicting IC-067/IC-091 and permitting cross-session event routing.
- Decision: delete the scoped-probe contract. Under
  `WITH_ANGELSCRIPT_UNITTESTS`, a narrow
  `FAngelscriptDecodedCacheRecordTestAccess::TryDecodeWithProbe` façade explicitly
  accepts caller-owned fixed probe storage and forwards it into the same private
  internal seven-record factory used by public `TryDecode`. It owns no decoded state,
  performs no validation itself and is not a second decoder. Public calls remain
  observer-inert and are covered by equivalence/non-pollution tests.
- Closure evidence: zero scoped/TLS/global active-probe symbols, exact facade trait
  assertions, two independent caller captures, public-versus-observed byte/result/
  Budget equivalence, explicit observer lifetime and non-test symbol scan.

### IC-094 — CQTest has no `IsNotEqual` matcher

- Date/phase: 2026-08-08, Budget thread-affinity characterization compile.
- Severity/status: Minor / resolved and recompiled.
- Problem: the first new independent-thread assertion used an assumed
  `IsNotEqual` matcher, but this CQTest matcher surface does not provide it. The
  single-file wrapper failed at that one call before any link or Automation step.
- Decision: express the same evidence with `IsTrue(MainThreadId != WorkerThreadId)`;
  do not add a project-local alias just for one assertion.
- Closure evidence: `cache-budget-thread-affinity-tu` failed at the missing matcher;
  `cache-budget-thread-affinity-tu-fix1` compiled the same TU successfully.

### IC-095 — four remaining record coordinate domains were required but never frozen

- Date/phase: 2026-08-08, RemainingRecordTypes declaration inventory.
- Severity/status: Critical / authority and expected compile RED produced;
  independent 0C/0I review pending before declarations.
- Problem: SourceIndex `0..89`, ModuleInterface `0..88` and TypeSchema `0..38`
  have append-only captured-field values and P/S/T rules, but ModuleState,
  FunctionBody, DebugSidecar and ModuleSnapshot have only a prose requirement to
  provide equivalent exhaustive enums. Neither the remaining-wire authority nor the
  RED names their numeric domains, optional tag/value coordinates, nested DataType
  preorder axes or surplus-index behavior. Guessing wire order would silently make
  implementation layout the oracle and destabilize diagnostics/cache readers.
- Decision: add a normative `remaining-record-captured-offsets-v1.md` authority and
  a separate small coordinate RED translation unit before completing
  `AngelscriptCacheRemainingRecordTypes.h`. Freeze all four enum values, exact
  underlying types, P/S/T consumption, optional present/absent behavior, recursive
  preorder, set-zero offset, surplus/unapplicable lookup, wrong-kind typed overloads
  and append-only sentinels. Keep this out of the TypeSchema mega-TU.
- Closure evidence: four exhaustive tables, unique/static numeric assertions, byte-
  exact independent scanner lookup cases, wrong-kind output-atomic factory cases and
  compiled coordinate declarations before any remaining decoder implementation.
- Progress: the normative attachment and a separate nine-method declaration-first
  TU now exist. The repaired frozen pair is
  `C5843B...D9B` / `FC1526...857F`: it adds 19 exact structured-binding
  contracts for all four coordinates and all 15 DTOs, recursive pointer-free
  ownership checks, the complete four-coordinate declaration/axis matrix,
  field-specific optional authority with no caller-provided applicability bit, and
  four explicit root-family/row preorder models. A fresh wrapper compile still
  fails first and exactly at the absent planned
  `AngelscriptCacheRemainingRecordTypes.h`. This preserves the RED boundary; it does
  not yet close IC-095. The exact-SHA review of `C5843B...D9B` /
  `FC1526...857F` rejected it at **0 Critical / 3 Important / 1 Minor**: same-typed
  DTO members can still exchange declaration positions, the public surface does not
  mechanically prohibit an additional caller-Boolean applicability overload, and
  optional authority is still family-global rather than keyed by exact
  family/Primary/Secondary occurrence. The declaration inventory also retains a
  stale pre-authority status. A fourth RED repair is in progress; production
  declarations remain forbidden until its new exact SHA receives 0C/0I.
- Fourth-candidate progress: the three-file freeze is now
  `B65D52...BFDE` (normative coordinates), `181544...363E` (declaration inventory)
  and `55A7BB...5A8F` (11-method RED TU). It binds all 72 DTO members from unique
  aggregate positions back to names, rejects all four `(Coordinate, bool)` lookup
  forms, models optional presence by exact family/Primary/Secondary occurrence and
  executes own/same-family-other/every-unrelated one-hot cases. A fresh wrapper
  still fails first at the intentionally absent production header. Independent
  0C/0I review remains pending, so IC-095 is not closed.

### IC-096 — remaining wire shape does not yet freeze its final C++ member API

- Date/phase: 2026-08-08, RemainingRecordTypes declaration inventory.
- Severity/status: Important / RED/API-shape correction pending.
- Problem: remaining wire order fixes the data semantics, but no RED currently
  freezes exact aggregate members/default behavior for CanonicalValue, GlobalSchema,
  HardValue and DebugSourceReference. FunctionBody also conflicts between normative
  `FunctionSourceDigest`/`FunctionInputDigest` names and implementation-plan
  `SourceDigest`/`InputDigest`. Adding convenient defaults or following the stale
  sketch would turn unreviewed C++ shape into a public contract.
- Decision: normative wire names win only after an explicit RED amendment: use
  `FunctionSourceDigest` and `FunctionInputDigest`, freeze exact member types/order
  for every nested DTO, and add only fail-closed defaults named by that RED. Byte
  payload remains `u64 byte-count + bytes` even though the DTO uses `TArray<uint8>`;
  `FAngelscriptCachedModuleSnapshotLink` remains manifest-only and cannot enter the
  record DTO header.
- Closure evidence: member-type/order/default trait tests, complete all-fields
  roundtrips/goldens and zero ambiguous/stale member-name references.

### IC-097 — bounded TypeSchema counts were still runtime-selected, not source authority

- Date/phase: 2026-08-08, third TypeSchema RED preflight.
- Severity/status: Important / RED repair in progress.
- Problem: SHA `1A806E...` reduced the success matrix to 42 unique fixtures and 73
  targets, but first generated a large cartesian natural-candidate pool and then
  selected the first unused allocator-slack fixture with `TSet` state. The literal
  counts were consequently post-hoc checks over allocator- and traversal-dependent
  results, not a statically reviewable coverage contract. Empty/one/many fixture
  shapes were also not explicit members of the final representative authority.
- Decision: replace the generator/first-match selection with three source-explicit
  authorities: exactly 45 named fixtures (3 shape + 4 occurrence + 38 variable-site
  slack), exactly 73 named targets (2 fixed + 11 x 3 occurrence + 38 slack), and a
  named 53-SiteKind partition/count table. Resolve each declared slack row with a
  bounded site-specific request model that fails closed; never add/drop authority
  rows from runtime discovery. Construct/scan/plan and compare exact chronology once
  per fixture, and resolve its target rows without probe-driven selection or
  repeated whole-plan scans.
- Closure evidence: constexpr uniqueness/reference/count assertions for 53/40/12/1,
  45 fixtures and 73 targets; 11 named sites with four targets, 29 Required sites
  with one, 13 non-Required sites with zero; no natural cartesian generator,
  first-match selection or runtime target deduplication; fresh exact-SHA independent
  0C/0I review.

### IC-098 — late primitive/record failure can retain live Budget ownership

- Date/phase: 2026-08-08, Cache unit-test gap audit.
- Severity/status: Critical / four current readers use candidate ownership and all
  RED TUs compile; focused behavior plus final seven-record factory remain pending.
- Problem: primitive string/DataType and SourceIndex/ModuleInterface readers still
  bind `FRetainedDecodedChargeContext` directly to allocation sites. A locally owned
  decoded value is destroyed on trailing/local/hash failure, but its accepted charge
  is already classified as retained and has no rollback path. Existing assertions
  prove output clearing and sometimes Temporary cleanup, not return of Resident to
  the caller's pre-decode seed.
- Decision: add late-failure ownership RED for primitive and both record readers,
  including retained/temporary seeds, exact tuple, monotonic Total, baseline
  Resident/Temporary restoration and historical peak. Close the behavior only by
  routing the sole production factory/read transaction through aggregate Temporary
  candidate ownership and one final promotion; do not add a public refund/reset API.
- Closure evidence: the focused late-failure matrix and all-seven-record factory
  tests pass with zero live candidate bytes and empty outputs at every exit.
- Progress: canonical string, canonical DataType, SourceIndex and ModuleInterface no
  longer use the direct retained sink. A single private semantic-candidate adapter
  binds their normal reader allocations to the Budget aggregate Temporary
  transaction, maps only existing Budget/overflow outcomes, and promotes once after
  trailing-data plus local/hash validation succeed. Failure destroys the candidate
  and releases its live bytes without refunding Total. A new Source/Module case
  preserves independent retained and temporary seeds across late derived-hash
  failure. Runtime, primitive and SourceInterface TUs compile. This is a production
  foundation for the sole seven-kind factory, not a claim that 2.5a.4 or IC-098 is
  fully closed.

### IC-099 — canonical string APIs mutated aliased output before input preflight

- Date/phase: 2026-08-08, canonical primitive alias TDD.
- Severity/status: Critical / source fix compiled, Automation pending.
- Problem: canonical string deserialize called `OutValue.Empty()` before validating
  whether the input byte view pointed into the FString's allocation, creating a
  potential dangling input view. Serialize likewise did not enforce the archive's
  existing no-input/output-alias contract.
- Decision: extract the checked address-range/overlap implementation into Runtime
  Private `AngelscriptCacheMemoryView.h`, reuse it in the envelope archive, and
  preflight `FStringView -> TArray<uint8>` and `TConstArrayView<uint8> -> FString`
  before mutation or Budget charge. Overlap maps to the existing
  `AliasedInputOutput`; invalid positive-length views map to `InvalidArrayView`.
- Closure evidence: the new primitive test freezes both directions, empty output and
  zero Budget mutation. SemanticRecords, Archive and test TUs compile separately;
  focused Automation remains blocked by the sibling TypeSchema declaration RED.

### IC-100 — eligibility output charges requested sizes instead of owned capacities

- Date/phase: 2026-08-08, Cache unit-test gap audit.
- Severity/status: Critical / production slice and RED source-compiled;
  behavioral Automation pending.
- Problem: exact fast-path eligibility pre-charges scope rows and diagnostics from
  requested counts/string lengths, then lets Unreal containers reserve their actual
  allocator capacities. At a slack boundary the returned value may own more live
  memory than `ResidentDecodedBytes` records.
- Decision: freeze allocator-authoritative exact, Total-short and combined-live-short
  cases for both the result array and diagnostic strings. Production must calculate
  and charge the actual reserved capacities before allocation and publish atomically.
- Closure evidence: retained charge equals the returned result's actual owned
  allocations for multiple slack-boundary shapes, with one-byte-short rejection
  before allocation and empty output.
- Progress: the RED deliberately selects a scope-array count and diagnostic length
  whose Unreal allocator reserve capacities exceed the requested sizes. The query
  now predicts both allocations with the same allocator authority, reserves the
  complete result as Temporary while its scratch reservation is still live,
  verifies actual owned bytes, then promotes once. Output reset now uses `Empty()`
  so a failed call releases caller-provided stale capacity. Exact Runtime and test
  TUs compile; the new behavior has not been claimed GREEN until focused Automation
  can link after the TypeSchema declaration gate.

### IC-101 — eligibility and whole-record tests still use process-global probes

- Date/phase: 2026-08-08, Cache test-seam isolation audit.
- Severity/status: Important / both global seams removed and source-compiled;
  focused Automation plus non-test symbol scan remain open.
- Problem: `GEligibilityQueryArrayProbe` and
  `GAngelscriptSourceIndexWholeRecordCopyCount` use reset/read global state. Two
  overlapping callers can overwrite evidence, contradicting the caller-owned seam
  contract and making parallel tests order-dependent.
- Decision: remove the global eligibility probe in favor of an explicit per-call,
  caller-owned fixed POD/fixed-capacity capture on the same internal query path,
  with a null observer for production. Prefer deleting the whole-record copy counter
  and proving move-only token/call-local behavior directly; if observation remains
  necessary it must also be operation-local. No TLS, global active observer, growing
  storage or public test error is permitted.
- Closure evidence: observed/unobserved equivalence, zero/undersized/exact capture,
  two concurrent callers with no cross-events, and a non-test/Shipping symbol scan.
- Progress: the eligibility reset/read global and its atomic storage have been
  removed. Production and tests now share one internal query; production passes a
  null capture and the test facade passes an explicit caller-owned fixed view. The
  existing allocator-capacity test consumes two emitted events directly. A new
  concurrent case runs zero-, one- and exact-two-slot callers alongside an
  unobserved baseline and freezes identical validation tuple, eligibility output,
  matching scope and every query-Budget counter; zero/one report overflow without
  changing the query. Runtime and SourceInterface single-TU wrappers compile. This
  The SourceIndex global copy counter and its unit-test-only custom copy operations
  have also been deleted. The replacement contract freezes a move-only validated
  token, const-reference-only access, nothrow moves, move construction/assignment,
  invalid moved-from queries, released output and zero moved-from Budget mutation.
  Runtime and test TUs compile. Full IC-101 closure still waits for focused
  Automation after the TypeSchema gate and the final non-test/Shipping symbol scan.

### IC-102 — installed OpenSpec CLI has no `diff-check` subcommand

- Date/phase: 2026-08-08, progressive record integrity check.
- Severity/status: Minor / resolved with the repository-native check.
- Problem: an assumed `openspec diff-check <change>` command exits with
  `unknown command 'diff-check'`; this installed CLI provides strict validation but
  not a whitespace diff wrapper.
- Decision: use `openspec validate <change> --strict` for OpenSpec structure and run
  `git diff --check` separately in both the parent repository and
  `Plugins/Angelscript` submodule. Do not add a project script or alias for a single
  unsupported command assumption.
- Closure evidence: strict validation succeeds; both scoped Git diff checks report
  no whitespace errors. Git prints only existing LF-to-CRLF checkout warnings for
  tracked parent files, not diff-check failures.

### IC-103 — recursive DataType alias RED initially missed its private fixture namespace

- Date/phase: 2026-08-08, canonical DataType output-alias TDD.
- Severity/status: Minor / resolved in the test source.
- Problem: the first single-TU RED failed at compile time because the new method
  called `MakeInt32Type` without its
  `AngelscriptCachePrimitiveTests_Private` qualifier. This was a test-local lookup
  error and did not exercise production behavior.
- Decision: qualify the existing fixture directly; do not add a duplicate helper or
  widen the private namespace import.
- Closure evidence: `cache-datatype-recursive-alias-red-tu-fix1` compiles the same
  primitive TU successfully.

### IC-104 — shared allocation-range helper was byte-array-specific

- Date/phase: 2026-08-08, canonical DataType recursive output-alias GREEN.
- Severity/status: Important / source fix compiled and Runtime linked; behavioral
  Automation pending the declaration gates.
- Problem: canonical DataType clears its previous value before decoding. An input
  view inside a top-level or nested `OrderedSubTypes` allocation could therefore be
  freed before it was read. The shared alias helper also accepted only
  `TArray<uint8>` and `FString`, so the first Runtime TU could not express the
  required `TArray<FAngelscriptCachedDataType>` allocation range.
- Decision: generalize the existing `TArray` allocation-range overload by element
  and allocator type, then recursively inspect each DataType-owned subtype
  allocation before clearing output. Return the existing `AliasedInputOutput`
  outcome with empty output and zero Budget mutation; add no test-only API/error.
- Closure evidence: top-level and nested capacity fixtures compile in
  `cache-datatype-recursive-alias-green-tu`; the Runtime TU compiles in
  `cache-datatype-recursive-alias-runtime-tu-fix1`, and the complete Runtime module
  links in `cache-datatype-recursive-alias-runtime-link`.

### IC-105 — exact-SHA source review was invalidated by a concurrent parent edit

- Date/phase: 2026-08-08, candidate/eligibility source review.
- Severity/status: Process / review discarded; replacement freeze required.
- Problem: the independent reviewer correctly rehashed its seven-file input during
  review and found `AngelscriptCacheSemanticRecords.cpp` plus the primitive test TU
  had changed while the parent implemented IC-104. Its observations span two
  snapshots and cannot be used as approval.
- Decision: discard the review without findings or approval. Do not restore the old
  files; freeze the completed IC-104 slice and launch a fresh exact-SHA review only
  after the source is stable.
- Closure evidence: reviewer made no edits/builds and explicitly returned no
  Critical/Important/Minor judgment. A replacement review remains required.

### IC-106 — previous DataType output alias scan was recursively unbounded

- Date/phase: 2026-08-08, candidate/eligibility independent source review.
- Severity/status: Important / bounded production fix and focused TUs compile;
  behavioral Automation pending the declaration gates.
- Problem: the IC-104 recursive scan walked a caller-constructed previous
  `FAngelscriptCachedDataType` graph before `BeginRead` without applying nesting or
  cumulative element limits. A hostile deep/wide old output could exhaust the C++
  stack or perform unbounded work even when the new input was small.
- Decision: move the old output into a local owner before mutation, run `BeginRead`
  without dereferencing input, compute the checked input address range once, and
  scan old allocations with `min(caller MaxNestingDepth, 64)` plus cumulative
  `MaxArrayElements`. Map scan failures only to existing public errors and leave
  output empty/Budget unchanged.
- Closure evidence: depth- and element-limited fixtures plus the existing root/nested
  alias fixtures compile. Runtime and primitive TUs pass under labels
  `cache-bounded-datatype-alias-runtime-tu` and
  `cache-bounded-datatype-alias-primitive-tu`.

### IC-107 — eligibility scratch Budget contained 256 ownerless bytes

- Date/phase: 2026-08-08, candidate/eligibility independent source review.
- Severity/status: Important / source fix compiled; behavioral Automation pending.
- Problem: `TryComputeEligibilityScratchBytes` began at 256 although no physical
  allocation owned those bytes. Exact-budget tests therefore froze an estimate in
  addition to allocator-authoritative container capacities.
- Decision: initialize scratch bytes at zero and add only the seven actual reserved
  array allocations. Preserve the existing overlap rule between scratch Temporary
  ownership and result-candidate ownership.
- Closure evidence: the capacity test now derives expected scratch from three hash
  arrays, two indexed-hash arrays, reached flags and the queue only; its TU compiles
  under `cache-eligibility-no-phantom-scratch-tu`.

### IC-108 — canonical observer tests did not prove complete capacity equivalence

- Date/phase: 2026-08-08, candidate/eligibility independent source review.
- Severity/status: Important / focused source contract compiled; Automation pending.
- Problem: separate tests covered explicit observation, overflow and decoded values,
  but did not compare the complete result tuple, semantic output and every Budget
  counter against an unobserved baseline for zero, undersized and exact capture
  capacities across both string and recursive DataType decoding.
- Decision: add one parity matrix that seeds Stored/Decompressed/Reference counters,
  compares `Error/Class/Stage/RecordKind/ByteOffset`, output and all seven Budget
  getters, and requires overflow to affect capture metadata only. String uses
  capacities 0/3/4; a two-allocation recursive DataType uses 0/7/8.
- Closure evidence: the initial TU exposed IC-110; after its fixture-only repair,
  `cache-canonical-observer-parity-tu-fix1` compiles.

### IC-109 — TypeSchema filtered event view was indexed as an array

- Date/phase: 2026-08-08, fourth TypeSchema exact-SHA independent review.
- Severity/status: Important / resolved and independently approved.
- Problem: two RED assertions used `GetInjectedOverflowCheckpoints()[0]`, but the
  deliberately constrained filtered view supplies only `Num`, `IsValidIndex` and
  `FindAtForConstantLookup`.
- Decision: use `FindAtForConstantLookup(0)` after the existing exact-count assertion;
  do not widen the view API.
- Closure evidence: the repaired file is frozen at SHA-256
  `60BE380E68EE0E6083F153C69FAD59952C51C84CF9C0A43FBAAE325EEF3C4EB0`
  (447,273 bytes, 10,246 LF, 54 methods). A fresh independent start/mid/end rehash
  review returned `0 Critical / 0 Important / 0 Minor` and approved the RED as the
  declaration authority. No TypeSchema production GREEN is implied.

### IC-110 — CQTest assertion macro cannot live in a value-returning lambda

- Date/phase: 2026-08-08, canonical observer-equivalence test implementation.
- Severity/status: Minor / resolved in the test fixture.
- Problem: `ASSERT_THAT` contains a no-value early return. Using it in the two
  decode-run lambdas forced their deduced return type to `void` and produced C3487/
  C2562 before the new test could compile.
- Decision: report the impossible seed failure through `TestRunner->AddError` inside
  the value-returning lambdas and keep value assertions outside them.
- Closure evidence: the failing wrapper label is
  `cache-canonical-observer-parity-tu`; the unchanged behavioral matrix compiles
  under `cache-canonical-observer-parity-tu-fix1`.

### IC-111 — candidate preflight attachment retained obsolete primitive wording

- Date/phase: 2026-08-08, progressive record consistency audit.
- Severity/status: Minor / documentation corrected.
- Problem: `decoded-candidate-transaction-preflight.md` still said canonical
  primitive decoding charged retained ownership directly, although string and
  DataType already use the same aggregate Temporary candidate transaction as
  records.
- Decision: state the current invariant: primitive and record decodes use the active
  aggregate candidate and promote once only after their complete validation
  boundary.
- Closure evidence: attachment wording now matches the compiled private charge-sink
  path and IC-098 progress.

### IC-112 — proposed Cache fixture mode reused an obsolete clone name

- Date/phase: 2026-08-08, isolated test-engine architecture audit.
- Severity/status: Minor / design wording corrected before implementation.
- Problem: the first Cache fixture note called its cheap mode `SharedClone`, but the
  project already removed the clone mechanism. Existing `*CloneEngine` helpers are
  documented compatibility forwarders to shared/fresh Full engines.
- Decision: use `SharedModuleClean`, backed by the current
  `FAngelscriptTestEnginePool`, plus `IsolatedFull` and `ProductionLike`. Keep
  `FAngelscriptTestEngine` static-only and compose it into the Cache fixture rather
  than subclassing `FAngelscriptEngine`.
- Closure evidence: the unit-test matrix now references the actual acquisition
  boundaries (`CreateFullTestEngine`, shared Full-engine pool and production-like
  resolver) and explicitly forbids restoring clone or subclass engine models.

### IC-113 — two-dimensional optional RED changed both identity axes together

- Date/phase: 2026-08-08, remaining-record fourth exact-SHA review.
- Severity/status: Important / fifth RED repaired and frozen; independent rereview
  in progress.
- Problem: `GlobalTypeReference`, `HardValueTypeReference` and
  `InitializationActionDependencyExpectedValue` each used only two occurrences
  whose Primary and Secondary indices both differed. Implementations ignoring
  either axis could therefore pass the one-hot matrix.
- Decision: freeze A=`{0,0}`, B=`{0,1}` and C=`{1,0}` for every two-dimensional
  family. Require Presence to remain queryable and every controlled enclosing/
  subfield to be own-only against same-Primary/other-Secondary,
  other-Primary/same-Secondary and every unrelated-family one-hot state.
- Closure evidence: the fifth candidate contains three explicit axis-independent
  matrices and nine exact identity declarations. Source is frozen for independent
  review; no production header or GREEN is claimed.

### IC-114 — Boolean-overload prohibition covered only const/const-lvalue calls

- Date/phase: 2026-08-08, remaining-record fourth exact-SHA review.
- Severity/status: Important / fifth RED repaired and frozen; independent rereview
  in progress.
- Problem: the negative concept invoked a const decoded record with a const
  coordinate lvalue only. A forbidden overload taking mutable lvalue/rvalue
  coordinates or a non-const receiver could remain publicly callable.
- Decision: for all four coordinate types, statically reject the Cartesian six
  call forms: const/non-const record lvalue receiver times const lvalue, mutable
  lvalue and rvalue coordinate, always with the second Boolean argument.
- Closure evidence: the fifth candidate instantiates 24 prohibited call shapes.
  Exact-SHA independent review remains the declaration gate.

### IC-115 — normative attachments retained superseded TLS/retained wording

- Date/phase: 2026-08-08, TypeSchema GREEN preflight consistency audit.
- Severity/status: Important / normative documents corrected before production
  implementation.
- Problem: despite the approved explicit caller-owned probe and aggregate candidate
  implementation, `decoded-candidate-transaction-preflight.md` and
  `type-layout-authority-v1.md` still described scoped thread-local capture, while
  `record-wire-v1-remaining.md` still assigned primitive decoding directly to a
  retained sink. Following those words would reintroduce IC-093 or split ownership.
- Decision: require explicit synchronous per-call capture through the test-access
  façade into the same private factory, with no ambient lifecycle, and bind both
  primitive and record operations to aggregate candidates with one final promotion.
  Append the final TypeSchema exact-SHA approval to its dedicated review attachment.
- Closure evidence: all three normative passages and `type-schema-red-review.md`
  now agree with SHA `60BE380...`, IC-098 and the compiled canonical charge path.

### IC-116 — remaining-record fifth RED receives independent approval

- Date/phase: 2026-08-08, task 2.4d fifth exact-SHA rereview.
- Severity/status: Gate / resolved, `0C/0I/0M`.
- Result: start/mid/end hashes remained `8A0F30AC...F7EA3`,
  `181544F5...EF363E` and `9A91DB07...49F67F`. The reviewer independently
  reconfirmed both IC-113/114 repairs and every previously approved enum,
  coordinate, DTO, pointer-free, digest and record-only structural gate.
- Decision: open remaining-record production declaration GREEN without changing the
  frozen field numbers, occurrence rules or aggregate member shapes. Keep header,
  decoder/factory compilation and Automation as separate evidence.

### IC-117 — remaining declaration GREEN reaches the shared decoded-record boundary

- Date/phase: 2026-08-08, task 2.4d production declaration GREEN.
- Severity/status: Expected integration gate / declaration header implemented;
  focused TU blocked at the separately owned shared factory boundary.
- Result: `AngelscriptCacheRemainingRecordTypes.h` now declares exactly the approved
  nine `uint8` enums (including the two support enums), four continuous `uint16`
  captured-field enums, four coordinate aggregates and fifteen owning DTOs. It
  includes `AngelscriptCacheSemanticRecords.h` and reuses every common value instead
  of redeclaring a second representation.
- Build discovery: the repository-wrapper single-file compile advanced past the
  former missing remaining-record header and stopped at test line 2 with C1083 for
  the still-absent `Cache/AngelscriptCacheDecodedRecord.h`. That header and its sole
  seven-kind factory are shared work owned outside this declaration slice.
- Decision: do not create a test substitute, placeholder decoded record, second
  factory, or speculative lookup overload. Preserve the declaration header and stop
  this slice at the explicit shared boundary. The complete TU remains non-GREEN
  until the shared header is integrated and the exact same wrapper compile is rerun.
- Evidence: `cache-remaining-record-header-green-tu/20260808_222906_937_bd23bdea/`,
  `ProcessExitCode 6 / FinalExitCode 1`; declaration-header SHA-256
  `2832DFDD01890B01473D8C9370CB167FF5386562C9D69275D9A8808374978FB0`,
  12,055 bytes / 437 LF, no trailing whitespace or NUL.

### IC-118 — approved remaining RED had not been compiled under project warnings

- Date/phase: 2026-08-08, task 2.4d shared-boundary integration compile.
- Severity/status: Process gate / source repaired, fresh exact-SHA independent rereview pending.
- Problem: after `AngelscriptCacheDecodedRecord.h` made the complete test TU reachable,
  the first project-wrapper compile failed with C4458 because the local
  `DebugSidecarFields` function-body coordinate array shadowed the class-level
  `DebugSidecarFields` enum authority table. The earlier exact-SHA review was a
  source review and therefore did not detect the project's warnings-as-errors rule.
- Decision: rename only the local array to `FunctionDebugSidecarFields`; do not
  change its elements, the optional-occurrence call, any assertion, enum value,
  coordinate matrix or normative attachment. Reopen checkpoint 2.4d until the new
  exact source SHA receives an independent rereview.
- Evidence: the failing wrapper result is
  `cache-remaining-record-shared-boundary-tu2/20260808_223706_140_775f379d/`
  (`ProcessExitCode 6 / FinalExitCode 1`, C4458 at line 2105). The identical
  wrapper compile then passed at
  `cache-remaining-record-shared-boundary-tu3/20260808_223739_408_99d2ad1a/`
  (`ProcessExitCode 0 / FinalExitCode 0`). The repaired candidate is SHA-256
  `77C56BC6D8264A7BC93EF4BF7830CDBE36BCB383CC6ECF8C7339F23E0655CEE0`,
  117,378 bytes / 2,493 LF / 11 methods / final LF.
- Closure: a fresh reviewer hashed the repaired test at start, middle and end,
  proved in memory that reversing exactly the two local identifier occurrences
  reproduces the previously approved `9A91DB07...49F67F` byte stream, rechecked all
  fifth-RED gates and the TU3 evidence, and returned **0 Critical / 0 Important /
  0 Minor**. Checkpoint 2.4d is reclosed on `77C56BC...5CEE0`.

### IC-119 — partial decoded token used a forbidden heap pimpl

- Date/phase: 2026-08-08, task 2.5a.4 shared declaration independent review.
- Severity/status: Critical / redesign required before decoder implementation.
- Problem: the first `FAngelscriptDecodedCacheRecord` declaration stored
  `FAngelscriptCacheDecodedRecordStorage` through `TUniquePtr`. That creates a
  second persistent heap allocation outside the single shared controller/object
  allocation and makes the measured controller size exclude real token storage.
- Decision: define the final storage completely before the token and hold it
  directly by value. The immutable token must not use pimpl, type-erased heap
  ownership, per-kind heap owners or a partial layout that grows after allocator
  measurements are frozen.

### IC-120 — seven-kind variant alternatives did not own their offset tables

- Date/phase: 2026-08-08, task 2.5a.4 shared declaration independent review.
- Severity/status: Critical / final seven-alternative shape required.
- Problem: the initial private variant contained seven bare DTOs and one separate
  TypeSchema offset array. It had no SourceIndex, ModuleInterface, ModuleState,
  FunctionBody, DebugSidecar or ModuleSnapshot offset storage and no six matching
  construction paths.
- Decision: each of the seven private variant alternatives is one aggregate that
  owns both its DTO and its complete decoder-captured immutable offset table. The
  token owns that final variant in place; lookup dispatches only to the active
  alternative. A bare DTO variant plus later-growing side arrays is prohibited.

### IC-121 — common-token SourceIndex and ModuleInterface coordinates were placeholders

- Date/phase: 2026-08-08, task 2.5a.4 shared declaration independent review.
- Severity/status: Critical / complete authority required before controller freeze.
- Problem: the initial public enums exposed only `Invalid` and
  `PayloadSchemaVersion`, while `source-interface-captured-offsets-v1.md` already
  freezes 90 SourceIndex values (`0..89`) and 89 ModuleInterface values (`0..88`).
  Publishing placeholder enums would make most approved fields unnameable and
  would falsely freeze an incomplete seven-kind API.
- Decision: import the complete append-only enum and P/S/T coordinate authority
  before final token-size measurement or decoder implementation. No compatibility
  wrapper or later renumbering is allowed.

### IC-122 — transitional owning decoders still compete with the sole factory

- Date/phase: 2026-08-08, task 2.5/2.5a.4 migration audit.
- Severity/status: Important / accepted only as an explicit migration state.
- Problem: `DeserializeSourceIndex` still publishes a separate validated owner and
  `DeserializeModuleInterface` still publishes a mutable DTO, so the new
  `FAngelscriptDecodedCacheRecord::TryDecode` declaration is not yet the sole
  owning validated boundary in the repository.
- Decision: reuse their private validation algorithms, migrate every production
  consumer to the common immutable handle, and then remove both public owning
  decoders. Guarded raw physical test access, if still needed, must enter the same
  private decode path and may not retain a second owner/factory.

### IC-123 — approved TypeSchema RED had not passed a complete project TU

- Date/phase: 2026-08-08, task 2.4c declaration-first integration compile.
- Severity/status: Process gate / compile-only repair applied, fresh exact-SHA
  independent rereview pending.
- Problem: once the production declarations made the 447 KiB TypeSchema TU fully
  reachable, the first project compile exposed test-source defects that static
  exact-SHA review did not detect: a non-constexpr helper used by static authority,
  one switch declaration crossing later case labels, CQTest's one-argument
  `ASSERT_THAT` receiving 60 contextual second arguments, one value-returning
  fixture lambda using early-return assertions, two extra closing parentheses and
  three remaining filtered-view `operator[]` calls.
- Decision: preserve every matcher, context, fixture, authority row and method. Move
  the pure authority predicate to namespace-scope constexpr, scope the affected
  case, make the fixture lambda return type explicit and report impossible setup
  failures through `TestRunner`, remove only the two extra parentheses, use the
  existing constant-lookup API, and provide a TU-local one/two-argument assertion
  dispatcher with the stock early-return behavior. Both dispatcher branches are
  single `do/while(false)` statements, the two-argument branch adds the preserved
  context only after the original matcher fails, and all macros are undefined at
  the end of the TU.
- Evidence: `cache-typeschema-production-declaration-tu5/20260808_224537_593_b55f6465/`
  crosses all test parser/macro errors and stops at the next production semantic
  declaration gap: `FAngelscriptCacheStableReference` has no same-type equality for
  `TArray::Contains` at test line 6743. The repaired candidate is SHA-256
  `431F0B494C3ADB738C08D815E59983D353E89C72BEDCCD673BA2677A0E393DF0`,
  448,518 bytes / 10,282 LF / 54 methods / final LF. Checkpoint 2.4c is
  reopened until fresh independent review approves this exact source.
- Resolution evidence: add same-domain, full-width value equality for
  `FAngelscriptCacheStableReference` (`Kind + StableKey + ExpectedAbi`) and
  `FAngelscriptCacheSemanticDependency` (`Kind + Target + optional
  ExpectedContentOrValue presence/value`). TU6 reached only the latter missing
  equality. TU7 then compiled the complete test TU successfully with process/exit
  zero at `cache-typeschema-production-declaration-tu7/20260808_224717_175_0cf54459/`.
  These production value-model additions do not change the repaired test SHA and
  do not constitute link or Automation GREEN.

- Equality detail: same-domain, full-field equality for
  `FAngelscriptCacheStableReference` compares `Kind + StableKey + ExpectedAbi`.
  `FAngelscriptCacheSemanticDependency` compares `Kind`, the full target and exact
  optional presence/value. These semantics support canonical set-like preparation,
  add no cross-domain stable-key equality and do not close link or Automation.

### IC-124 — three Critical decoded-token declaration defects are repaired

- Date/phase: 2026-08-08, task 2.5a.4 final declaration shape.
- Severity/status: Critical repair / shared-header independent rereview pending.
- Problem: IC-119 through IC-121 left a heap pimpl, a bare seven-DTO variant with
  TypeSchema-only side offsets, two placeholder coordinate enums and a second
  private-storage truth which would invalidate final controller measurement.
- Decision: the token now owns the final seven-alternative `TVariant` by value.
  Every alternative owns its DTO plus its own complete captured-offset storage;
  TypeSchema retains separate frozen parallel/flat offset arrays so allocator-site
  accounting stays observable without copying. SourceIndex imports exact values
  `0..89` and ModuleInterface imports exact values `0..88`. The obsolete private
  pimpl storage header is deleted, and the private TypeSchema codec accepts the
  final in-place TypeSchema offset storage directly. No controller size is frozen
  by this declaration-only change.
- Evidence: header/Test SingleFile TU8 succeeds at
  `cache-typeschema-final-token-declaration-tu8/20260808_225113_117_9372912a/`;
  Runtime `AngelscriptCacheSemanticRecords.cpp` SingleFile TU9 succeeds at
  `cache-typeschema-runtime-semantic-tu9/20260808_225133_664_07526223/`.
  Both are compile-only evidence, not link or Automation GREEN.
- Exact independent-review source set (all final LF):
  - `AngelscriptCacheDecodedRecord.h` — SHA-256
    `C5E8D963B0194F6B802FECC9A65E1B21E747D75667761A1F0069262766E87DE6`,
    13,201 bytes / 386 LF;
  - `Private/AngelscriptCacheTypeSchemaCodec.h` — SHA-256
    `1351B360F4D9D1DEA7388B8DF32D171E945E0A301BCD9072A3396D29318619EF`,
    708 bytes / 22 LF;
  - `AngelscriptCacheTypeSchema.h` — SHA-256
    `9E373AA8172371867352C7439BCF4F977744141D4EF9E317CB8EA2D3140F776A`,
    19,303 bytes / 676 LF;
  - `AngelscriptCacheRemainingRecordTypes.h` — SHA-256
    `2832DFDD01890B01473D8C9370CB167FF5386562C9D69275D9A8808374978FB0`,
    12,055 bytes / 437 LF;
  - `AngelscriptCacheSemanticRecords.h` — SHA-256
    `4C3D80C1B9642F73A4AE4B224D29F4745063D3C4402F73139D8292E191978CCC`,
    25,848 bytes / 816 LF.

### IC-125 — GREEN file map retained the deleted second-storage header

- Date/phase: 2026-08-08, post-IC-124 normative consistency audit.
- Severity/status: Important documentation drift / corrected before codec work.
- Problem: `type-schema-green-file-map.md` still instructed implementation to add
  `Private/AngelscriptCacheDecodedRecordStorage.h`, although IC-124 had deleted that
  second storage truth and moved the final complete seven-alternative by-value
  layout before the token class in `AngelscriptCacheDecodedRecord.h`.
- Decision: make the decoded-record header the only declaration site for the final
  `{DTO, captured offsets}` alternatives and `TVariant`. The optional private
  TypeSchema codec may accept the final TypeSchema offset storage but may not define
  another storage model or decoder. This prevents a later implementer from
  accidentally reintroducing the IC-119/120 pimpl/partial-token architecture.

### IC-126 — `_Private` namespace did not provide C++ access control

- Date/phase: 2026-08-08, IC-124 exact-source independent rereview.
- Severity/status: Important / source repaired, compile and fresh rereview pending.
- Problem: although the by-value storage namespace was named
  `AngelscriptCacheDecodedRecord_Private`, its namespace-scope offset entries,
  seven alternatives and `FRecordVariant` remained publicly nameable and mutable.
  The public constructor signature also named that namespace-scope variant. This
  did not satisfy the normative requirement that constructor plumbing, typed
  variant, offset tables and per-kind aggregates are C++-private.
- Decision: move all offset-entry/storage templates, all seven alternatives and
  the final variant into `FAngelscriptDecodedCacheRecord::private`. Keep the public
  constructor callable only with its private construction token, and expose no
  storage type. A forward-declared, precisely friended private codec bridge is the
  only non-member allowed to name the nested TypeSchema offset storage; its header
  declares no second owner or variant.
- Repaired source candidates: `AngelscriptCacheDecodedRecord.h` SHA-256
  `31ADE29770453A4E6AA5029176C5A9F4BF028919798CDAFE737EC2467AEA9E1C`
  (13,235 bytes / 390 LF) and `Private/AngelscriptCacheTypeSchemaCodec.h`
  SHA-256 `07E7A2AE7051A09634E4ECEB7F5D8C5CC80CCB432A8D2531E076C48048154B97`
  (764 bytes / 25 LF), both final LF. The earlier IC-124 source-set approval gate
  remains open until these declarations compile and receive fresh independent
  review.
- Compile evidence: the complete TypeSchema declaration TU remains GREEN at
  `cache-typeschema-private-token-declaration-tu10/20260808_230242_455_0741848b/`.
  A dedicated guarded compile contract includes the private codec header and proves
  with C++20 negative requirements that external code cannot name `FRecordVariant`,
  `FTypeSchemaCapturedOffsetStorage` or `FSourceIndexRecord`; it also freezes the
  bridge as empty/non-owning and the token as non-default/copy/move constructible.
  Its source SHA is `0836FD58BCBCEDFEB8DA31A8377C289247358F908A7BA958AEEF376833D944FD`
  (1,673 bytes / 52 LF / one method), and TU11 is GREEN at
  `cache-decoded-record-private-compile-contract-tu11/20260808_230329_220_4c7b84d9/`.
- Closure: a fresh start/middle/end exact-SHA rereview of the repaired two-header
  set returned **0 Critical / 0 Important / 0 Minor**. It independently confirmed
  true class-private access, the exact friend bridge, seven by-value alternatives,
  twelve TypeSchema offset arrays, absence of every second owner/storage truth, the
  corrected file map and both TU10/TU11 evidence. The final declaration shape is
  approved; codec/factory implementation, link and Automation remain open.

### IC-127 — TypeSchema test-local assertion macro was not restored for Unity

- Date/phase: 2026-08-08, IC-123 compile-repair independent rereview.
- Severity/status: Important / repaired, fresh exact-SHA rereview pending.
- Problem: the local one/two-argument `ASSERT_THAT` dispatcher was undefined at
  end-of-file without restoring CQTest's original definition. Because the test
  module enables Unity builds and `CQTest.h` is once-only, a future source included
  later in the same Unity chunk could see no `ASSERT_THAT` macro. SingleFile TU7
  could not expose this cross-source preprocessor-state leak.
- Decision: save the upstream macro with `#pragma push_macro`, install the local
  dispatcher, remove its helpers, restore the exact upstream definition with
  `#pragma pop_macro`, and fail compilation if `ASSERT_THAT` is not present after
  restoration. No matcher, context, test method or TypeSchema authority row changed.
- Evidence: repaired source SHA-256
  `F0BDD6169DE49443874F53BC4E42A5AB16E03D355044603297092B2A71C10F47`,
  448,700 bytes / 10,288 LF / 54 methods / final LF. Repository-wrapper SingleFile
  compile `cache-typeschema-unity-macro-restore-tu12/20260808_230421_737_ca81f505/`
  succeeds with Process/Final exit zero. Fresh exact-SHA source review remains the
  2.4c gate.
- Closure: a fresh read-only review rehashed the candidate at start, middle and
  end, proved the net change from `431F0B49...93DF0` is exactly 182 bytes / 6 LF of
  push/pop/guard plumbing, reconfirmed 592 single-argument plus 60 contextual
  assertions and every 53/45/73/78/5 authority, and returned **0 Critical / 0
  Important / 0 Minor**. Checkpoint 2.4c is reclosed on `F0BDD616...10F47`.

### IC-128 — Manifest RED missing-header frontier hid two deterministic C++ errors

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Critical / repair in progress.
- Problem: two reachability fixtures copy-initialized `TArray` from native C
  arrays. UE 5.8 has no matching implicit single-array constructor, but the line-1
  missing production header prevented the compiler from reaching those sites.
- Decision: explicitly construct from `MakeArrayView`. After the production header
  is declared, the complete TU must compile before declaration RED approval is
  considered sufficient.

### IC-129 — Manifest reachability projection omitted TypeSchema and graph authority

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Critical / RED expansion required.
- Problem: the frozen projection had no TypeSchema node/edge, no independent
  manifest-versus-decoded SourceSnapshot coordinate, and no observable per-root
  module-graph validation call. Its negative matrix covered only DebugSidecar,
  one extra and one root-module mismatch, allowing incomplete traversal to pass.
- Decision: freeze every keyed TypeSchema, every expected target kind, exact
  SourceSnapshot comparison, exactly-once per-root module-graph calls and every
  missing/wrong/unreachable root/child/debug case. The final visited set must equal
  the manifest index exactly; the guarded seam must remain a projection into the
  same production traversal, not a second validator.

### IC-130 — Manifest Budget authority conflicted with the active candidate model

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Critical normative conflict / authority and RED repair required.
- Problem: `manifest-pack-wire-v1.md` still described ResidentDecodedBytes as only
  monotonic cumulative with no live allocator role, while the later approved
  candidate transaction and tests use retained plus temporary combined-live peak
  for `MaxResidentDecodedBytes`. The attachment declared the older wire text
  normative, so no implementation could satisfy both.
- Decision: explicitly supersede the stale paragraph and align the wire authority,
  test attachment and exact/one-short cases with current Budget semantics:
  monotonic total decoded accounting plus separately tracked live retained and
  temporary candidate bytes, with a combined-live peak and no refund of monotonic
  totals. Pack raw-buffer lifetime/charging must be named unambiguously.

### IC-131 — Manifest RED lacked codec-size and decompression mismatch behavior

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Important / RED expansion required.
- Problem: error 67 was only classified numerically. No behavior triggered decoded
  output shorter/longer than RawSize, None stored/raw mismatch, invalid zero Zlib
  sizes, stored-not-smaller Zlib, canonical-payload one-short or the complete later
  non-empty gap/backwards/range combinations.
- Decision: add independent physical fixtures for each rule and freeze their exact
  stage/error/offset/atomic-output precedence.

### IC-132 — Manifest local-invariant matrix was incomplete

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Important / RED expansion required.
- Problem: zero ModuleKey/PackId/RecordId content hashes, wrong ModuleSnapshot root
  kind, missing SourceIndex/root record-index occurrence and manifest-to-pack
  StoredSize/RawSize/Codec/RawChecksum mismatch were not behaviorally frozen.
- Decision: add single-fault rows for every local invariant and every location
  equality dimension while retaining duplicate-versus-conflict and graph
  precedence.

### IC-133 — forced-serial and forward fixtures were the same input order

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Important / scheduling authority missing.
- Problem: both fixtures passed the identical `{Source, Function, Debug}` array to
  a synchronous pack builder. Reverse/random proved canonical input sorting but not
  that worker completion schedule leaves grouping/bytes/IDs unchanged.
- Decision: freeze a pure production preparation/aggregation seam with explicit
  completion ordinals. Exercise forced serial, forward, reverse and seeded-random
  completion schedules through the same aggregator; no real threads are required
  for this deterministic contract.

### IC-134 — two publication-atomicity checks began with empty outputs

- Date/phase: 2026-08-08, task 2.7 first exact-SHA independent review.
- Severity/status: Important / RED repair required.
- Problem: record-read and generation-failure helpers started with unset outputs,
  so remaining unset did not prove the API clears a previously published owned
  handle/generation on failure.
- Decision: first obtain successful owned outputs, invoke each failure with those
  outputs prepopulated, and assert atomic clearing plus unchanged caller Budget and
  source-call chronology as applicable.

### IC-135 — final token accessors and allocation-free coordinate lookup land first

- Date/phase: 2026-08-08, task 2.5a.4 GREEN implementation frontier.
- Severity/status: Progress slice / compile GREEN, factory publication still open.
- Result: `AngelscriptCacheDecodedRecord.cpp` now implements the private-token
  constructor/destructor, all seven const typed getters and all seven one-argument
  captured-coordinate lookups against the final by-value alternatives. Wrong-kind
  queries return null/unset. Coordinate matching includes Field plus all P/S/T axes;
  TypeSchema visits its twelve frozen offset groups through stack-only array views
  and returns at the first match. Lookup allocates and mutates nothing.
- Boundary: the sole factory, candidate transaction, controller measurement,
  decoder bridge, publication and graph validator remain intentionally undefined;
  this compile slice does not publish a partial token or claim behavioral GREEN.
- Evidence: source SHA-256
  `1EC8330F81068CB64CEB1BC59CD06AF5F029C16F9A0FF389C2C9B878703A25E2`,
  5,940 bytes / 176 LF / final LF. The first TU and early-return refinement both
  compile; final evidence is
  `cache-decoded-record-accessor-tu13-fix1/20260808_232017_351_060c690c/`,
  Process/Final exit zero.

### IC-136 — TypeSchema physical trace cannot use aggregate row spans

- Date/phase: 2026-08-08, TypeSchema pure-producer GREEN slice.
- Severity/status: Important / fixed in the producer candidate; behavioral
  Automation remains open.
- Problem: the first shared-writer trace draft treated a complete Relation row as
  a nonexistent `Relation` test field and treated several row/string/optional
  aggregates as one span. The frozen RED authority instead requires exact
  field-local `Field/P/S/T` spans: string spans exclude their `u32` byte count,
  row markers have size zero, and optional-tag spans contain only the tag byte.
  The first repository-wrapper compile caught the nonexistent enum member before
  any behavioral claim.
- Decision: canonical bytes continue to have one production writer. The guarded
  test-only trace now scans only that writer's completed byte array with a bounded
  physical cursor and emits the exact frozen span inventory; it does not construct
  DTOs, validate semantics, publish records, charge a Budget, or become a second
  production decoder. `SerializeTypeSchemaPhysicalForTests` atomically clears both
  byte and trace outputs if this internal writer/trace invariant ever disagrees.
- Evidence: the failing frontier is
  `typeschema-producer-green-tu1b/20260808_232206_119_d1591bfc/`; the repaired
  producer TU is
  `typeschema-producer-final-tu5/20260808_233133_329_eec67dba/`, both under
  `Saved/Build/`. Exact physical-trace behavioral comparison awaits the linkable
  focused TypeSchema Automation run and is not inferred from SingleFile compile.

### IC-137 — the sole factory kernel must not wrap transitional record decoders

- Date/phase: 2026-08-08, unified decoded-record factory GREEN implementation.
- Severity/status: Critical architecture invariant / first kernel slice compiled;
  seven-codec link and behavioral evidence remain open.
- Problem: calling the public SourceIndex or ModuleInterface deserializers from the
  new common factory would create a nested decoded-candidate transaction, a second
  charge sink and either a second owning token or a mutable intermediate DTO. It
  would double-charge/double-promote successful reads and make failure cleanup and
  final retained capacity unverifiable. Clearing `OutRecord` before preserving an
  old shared handle would also invalidate a legal input view aliased to that old
  handle's canonical payload.
- Decision: `TryDecodeInternal` is the sole candidate/controller/payload/publication
  owner. It first copies the old optional handle as a lifetime guard, clears output,
  recomputes the declared RecordId with zero decoded charge, begins one candidate,
  charges the allocator-quantized final intrusive controller, constructs the exact
  active final variant alternative, charges and copies one token-owned canonical
  payload, then dispatches only to private codec bridges that borrow the same sink.
  One promotion precedes the final no-fail const-handle publication. The current
  compiled slice connects only the not-yet-defined TypeSchema private bridge;
  SourceIndex/ModuleInterface and the four remaining codecs intentionally do not
  call their legacy public decoders. This is an implementation frontier, not a
  narrower final seven-kind solution.
- Evidence: `AngelscriptCacheDecodedRecord.cpp` SHA-256
  `53BE02F60D7EDC9123402D66ECF417569A5F328A105E808FFD07B2455EC04EC4`,
  20,112 bytes / 629 LF / final LF; repository-wrapper SingleFile TU
  `cache-decoded-factory-kernel-tu14/20260808_233828_342_541d6eb1/` has
  Process/Final exit zero. A forbidden-source scan finds no legacy deserializer,
  `MakeShareable`, direct `new` token, TLS, global or ambient probe. Link,
  exact-allocation chronology, injected-fault cleanup, all seven decoders and
  Automation remain required before tasks 2.5/2.5a.4 can close.

### IC-138 — producer wire/hash validation accepted self-consistent illegal schema semantics

- Date/phase: 2026-08-08, independent review of TypeSchema producer SHA
  `DB2E1480...C6FC4`.
- Severity/status: Important / open; producer SHA not approved.
- Problem: `SerializeTypeSchema` canonicalizes a copy and checks selected union-arm,
  common values and stored derived hashes, but its normal producer validator does
  not yet enforce the full frozen local-semantic matrix. A concrete counterexample
  is two LayoutInputs with the same singleton `InputKind` and different targets:
  when both row hashes and the final TypeLayoutHash are recomputed, the current
  producer can emit bytes instead of returning `ConflictingKey`. The same gap
  includes unknown/self-consistent property access/storage/replication/flag values,
  relation/cardinality/ordinal rules, method/VFT/behavior/reflection/enum shape and
  immutable layout replay. Decoder-only hostile fixtures correctly use the guarded
  physical writer, but that does not prove the normal producer fails closed.
- Decision: extract/extend one producer-side canonical-local validator which is
  independent of Budget, offsets and current resolvers. Normal serialization must
  reject every frozen local semantic violation and atomically clear sentinel output
  without mutating the caller DTO. The guarded physical writer remains able to emit
  physically representable hostile bytes for decoder tests. Do not alter the five
  independently reviewed hash field streams or create a second writer.
- Required evidence: focused normal-producer duplicate/conflict/unknown-enum/flag/
  ordinal/shape/layout-replay cases with exact producer result tuples, sentinel
  output clearing and input equality; new exact source/test SHAs, SingleFile compile,
  focused Automation and fresh independent 0C/0I review.

### IC-139 — two TypeSchema hash domains lack independent fixed vectors

- Date/phase: 2026-08-08, TypeSchema producer evidence review.
- Severity/status: Important test-evidence gap / open; the reviewed implementation
  order appears specification-correct, but independent executable proof is missing.
- Problem: the frozen test contains expected hex for StorageLayoutHash,
  PropertyLayoutFingerprint and TypeLayoutHash plus complete payload/RecordId/
  envelope bytes. Its Delegate fixture has no LayoutInput and is not an Enum, so
  `LayoutInputHash` and `EnumAuthorityHash` are only recomputed by the same public
  helpers used to prepare fixtures. A helper and producer could drift together.
  A previously requested `type-schema-wire-goldens-v1.md` filename does not exist;
  the missing filename itself is not a source defect and shall not become a new
  redundant authority document.
- Decision: add literal expected-hex vectors for LayoutInputHash and
  EnumAuthorityHash to the existing authoritative TypeSchema test/golden section,
  and record those five hash domains plus payload/RecordId/envelope in the existing
  TypeSchema authority attachment. Do not introduce another production hash helper
  or duplicate wire implementation.
- Required evidence: both vectors are computed independently from the frozen domain
  and field sequence, fail on a one-field mutation, compile with the full RED source,
  pass focused Automation once the decoder/factory links, and survive fresh exact-SHA
  review.

### IC-140 — nested canonical allocations bypassed the factory probe and rejection count

- Date/phase: 2026-08-08, independent review of the first decoded-record factory
  kernel.
- Severity/status: Critical / factory-side repair compiles; TypeSchema bridge and
  behavioral GREEN remain open.
- Problem: the factory charged its controller and owned payload through the common
  candidate, but constructed the private canonical-reader `FDecodedChargeSink` with
  an empty allocation observer. Strings, arrays and captured-offset arrays therefore
  affected Budget without appearing in the caller-owned exact chronology. Nested
  one-byte-short rejection also failed to increment the probe's rejected-reservation
  count. The production Budget path was present, but the declared exhaustive
  allocation and cleanup proof was false.
- Decision: the sink now receives one stack-local context containing the sole
  candidate transaction and guarded caller-owned probe. Every nested Budget
  rejection is recorded before returning `BudgetExceeded`; every physically
  successful reader allocation forwards its exact requested count, reserved
  capacity, element size/alignment, allocated bytes and field offset into the same
  probe chronology used for controller and owned-payload allocations. There is no
  ambient/global observer and no second candidate or decoder owner.
- Evidence: `cache-decoded-factory-observer-tu15/20260808_235612_351_d4f02462/`
  compiled `AngelscriptCacheDecodedRecord.cpp`, and
  `cache-canonical-observer-compat-tu/20260808_235625_855_c63efc7a/` compiled
  `AngelscriptCacheSemanticRecords.cpp`; both repository-wrapper runs have
  Process/Final exit zero. Exact behavioral closure waits for the private
  TypeSchema bridge and focused Automation.

### IC-141 — declared TypeSchema fault injection and validation checkpoints were dead

- Date/phase: 2026-08-08, independent review of the first decoded-record factory
  kernel.
- Severity/status: Critical / factory/probe lifecycle implemented and compiled;
  decoder checkpoint consumption remains open.
- Problem: the probe exposed setters for physical-after-allocation, local-semantic,
  hash-semantic and validation-checkpoint failures, but no production-path code read
  those settings. Tests could configure a fault that never fired, so they could not
  prove exact late-failure attribution, output reset, candidate rollback or prior
  handle preservation.
- Decision: each decode resets observation counters while preserving the configured
  fault target, records all accepted allocations in one ordinal space, fires a
  physical fault immediately after its exact allocator success, defers local/hash
  faults with the target wire offset, records validation and independently tagged
  injected-overflow events, and closes only call-local live/balance state at scope
  exit. Controller and payload physical faults now return `Overflow/PayloadDecode`;
  the TypeSchema bridge must consume local/hash targets and twelve streaming
  checkpoints at their exact semantic offsets before this issue closes.
- Evidence: factory source SHA-256
  `66231C6614B6A858E772399D8D61704C4D608070F4B07D9118FB9367BFCA1292`
  (25,964 bytes / 811 LF / final LF) compiles in the TU15 evidence above. The same
  evidence does not claim link, fault-matrix behavior or Automation GREEN.

## Next-entry policy

Future implementation issues are appended here in discovery order even if they
are found and fixed in the same work session. Build/test/PIE/package failures
must include the exact wrapper command, label, report/log path, affected
configuration, whether they reproduce on the isolated baseline, and the
resolution status. Performance problems must link raw rows under
`benchmarks/`; crash-recovery/store faults must link their injected fault point
and committed pointer state. Final closure audits must treat every `Open` or
`Fix in progress` entry as unresolved unless its required evidence is present.

## Current repaired-RED review state

IC-016 through IC-030 now have a replacement RED frozen at SHA-256
`44432F811B66BB1BB2AF2E87B927CCD64525482132DA2E63FF87C97AF8F1124E`.
It supersedes the rejected `63C265...` candidate but does not close any GREEN
requirement. The replacement contains 53 static SiteKinds/templates, 39 public
captured-coordinate rows and 49 CQTest methods; the author-side static review
reported 0 Critical, 0 Important and one formatting-only Minor. Fresh independent
review rejected it with **3 Critical / 7 Important / 0 Minor**. The deduplicated
findings are IC-054 through IC-063 and are detailed in
`type-schema-red-review.md`. No TypeSchema GREEN production implementation,
passing build or Automation result may be claimed until a repaired exact SHA
receives zero Critical and zero Important.

A repaired single-file RED candidate is now frozen at SHA-256
`AA4808D0EAB60932C8BAD0A1C2A9D3A0843629041B3D14933B76989D8ACBFFF2`
(361,655 bytes, 8,410 LF terminators with a final newline, 51 unique CQTest
methods, 53 SiteKinds plus the `Count` sentinel). The author-side audit reported
0C/0I, but fresh independent review rejected the exact SHA with **3 Critical / 6
Important / 1 Minor**. IC-055/056/058/059/060/062 remain open and the new distinct
findings are IC-080 through IC-085. A second repair is in progress; TypeSchema GREEN,
compilation and Automation remain forbidden claims until its new exact SHA receives
independent 0C/0I.

The second repaired candidate is frozen at SHA-256
`12E890CA7C905D01839A5FE92DDAEBC59D672CC43836E880A975B83FF86090A1`
(383,981 bytes, 8,930 LF terminators/logical lines, final LF, 53 unique CQTest
methods). Its static authority is 53 sites / 40 Required / 12 StreamingZero / 1
InvalidFixtureOnly, 78 unique reference-authority rows and exactly five TypeSchema
dependency variants. Fresh independent rereview rejected this exact SHA with
**1 Critical / 2 Important / 1 Minor**: IC-088 still treats the direct Target as
optional, IC-086 lacks allocator-authoritative hostile-Typedef evidence, and IC-089
contains an O(E^2) filtered chronology comparison. The Minor is stale Required-
coverage diagnostic wording. A subsequent declaration/file-map audit also found the
distinct Critical IC-093 ambient scoped-probe contract. A third repair must close all
four substantive findings; this is not approval, compilation or Automation.

The third author candidate is frozen at SHA-256
`1A806E00FCA853471BE8C94F646DC2407493272128E9AD3FC09A8EAD9028CAF3`
(408,170 bytes, 9,467 LF logical lines, final LF, 54 unique methods). It closes the
four preceding source-shape findings, but a separate preflight found IC-097
Important: its 42/73 set is still chosen from a runtime cartesian candidate pool.
It is not approved. The active repair replaces that selection with explicit 45
fixture / 73 target / 53 SiteKind authority tables before fresh exact-SHA review.

The fourth candidate's first independent review found only IC-109. The minimal
repair is now frozen at SHA-256
`60BE380E68EE0E6083F153C69FAD59952C51C84CF9C0A43FBAAE325EEF3C4EB0`
(447,273 bytes, 10,246 LF lines, final LF, 54 unique methods). Fresh independent
start/mid/end exact-SHA review approved it at **0 Critical / 0 Important / 0
Minor**. It is now the TypeSchema declaration-first RED authority: production
headers and GREEN work may begin, but no compile/Automation success is claimed yet.

The complete project TU later exposed only test-source compile defects in that
approved byte stream. IC-123 records the assertion-identical repair. The active
compile-repaired candidate is SHA-256
`431F0B494C3ADB738C08D815E59983D353E89C72BEDCCD673BA2677A0E393DF0`
(448,518 bytes, 10,282 LF lines, final LF, 54 unique methods) and now compiles as a
complete SingleFile TU. Exact-SHA approval does not transfer: fresh independent
review remains the gate before 2.4c recloses or production codec GREEN begins.
