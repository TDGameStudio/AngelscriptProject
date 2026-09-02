# Current progress and blockers — 2026-09-01

Snapshot time: **2026-09-01 01:39 CST (UTC+08:00)**.

This is a point-in-time review of the actively changing worktree at `D:\as-cta`.
Another TDD loop was still editing and running tests while this review was sampled,
so later results must supersede this report explicitly rather than silently changing
its percentages.

## Executive conclusion

- Exact OpenSpec completion: **103/136 = 75.7%**.
- Estimated core engineering implementation: **about 95%**.
- Estimated default-CANONICAL cutover readiness: **about 81%**.
- Estimated integration/merge readiness: **about 60%**.
- Weighted overall engineering completion: **about 89% (confidence range ±3%)**.

The change is architecturally mature and most of the difficult ownership,
snapshot, lifetime, identity, Cache and AOT boundaries are implemented. It is
not complete, default-ready, archive-ready or merge-ready. The formal count must
remain the exact status when a single auditable percentage is required; the 89%
number is a risk-weighted engineering estimate, not an OpenSpec task count.

The weighted estimate uses 70% core implementation, 20% default-cutover
readiness and 10% integration readiness:

`0.70 * 95 + 0.20 * 81 + 0.10 * 60 = 88.7%`.

## Material movement since the 2026-08-31 review

1. OpenSpec moved from `102/136` to **`103/136`**. Task **4.3** is newly checked:
   CANONICAL Stage 2 now fail-closes the remaining script-path
   `CreateDataTypeFromNode` adapter while preserving explicit LEGACY and Sema-less
   host-registration routes.
2. The post-4.3 Runtime/Editor build passed with exit code `0`:
   `Saved/Build/cta-s125-remaining-sites/20260901_011700_387_399e9e21/RunMetadata.json`.
3. The 4.3 broad gates passed: SemaAuthority **481/481** and Frontend CanonicalAST
   **189/189**.
4. During this review, the first Task 4.4 combined declaration gate progressed
   from RED to focused GREEN **1/1**, followed by a broadened SemaAuthority
   result of **482/482**. This is real progress but Task 4.4 remains unchecked;
   no post-4.4 Frontend or ProductionCodeGen full-prefix result existed at the
   snapshot time.

## Review findings

### P1 — ProductionCodeGen is not currently green

The latest complete ProductionCodeGen prefix result is **196/197**, with one
failure:

`PreparedNativeNonPodGeneratedGetterSealsAndInvokesExactCopyConstructor`

Evidence:

- `Saved/Tests/codex-review-current-production-codegen-2/20260831_222706_510_5cbcf689/Summary.json`
- `Saved/Tests/codex-review-native-nonpod-getter/20260831_223620_337_ec9bd6c0/Summary.json`

The relevant source ordering is still present in
`as_sema_expr.cpp`: a resolved field whose type satisfies
`RequiresExactValueObjectPlan(fieldType)` returns `MemberRef` before
`TryRewritePropertyGet` is attempted. The existing failing test requires the
generated getter and exact copy-constructor plan. The storage/lvalue rationale
in the code and the established generated-getter contract therefore still need
an explicit semantic decision and a green regression result.

No fresh full ProductionCodeGen prefix was available after the 2026-09-01 4.3
and 4.4 edits. The current state must be reported as **unverified with one known
prior failure**, not as green.

### P1 — Task 4.4 has a good first gate but is not closed

The new combined fixture proves a default parameter (`b = 7`), named argument
call (`F(a: 3)`), lambda body and list-factory pattern origin in one sealed
Canonical AST. Current evidence is:

- focused 4.4 case: **1/1 PASS**;
- SemaAuthority prefix after the change: **482/482 PASS**;
- build `cta-s126-decl-44-green2`: exit code `0`.

However, Task 4.4 covers a broader family: function signatures, defaults/named
arguments, access specifiers, traits, virtual properties, mixins, lambdas and
list patterns while retaining public registration and diagnostics. The task row
is still `[ ]`, the latest Frontend result predates this change, and there is no
fresh ProductionCodeGen regression result. The focused green is therefore a
slice gate, not completion of Task 4.4.

### P1 — Default cutover remains intentionally incomplete

The product default is still **LEGACY**. Section 10 is only **2/9 complete**;
the default transition, all source-build entry points, direct Canonical
Bytecode publication, removal of semantic native-tree use on the CANONICAL
path, final product-default selection and cutover gate remain open.

This is why the previous review's `94% default-cutover readiness` is too
optimistic for the current evidence. The architecture can be about 98% mature
while default readiness remains materially lower.

### P2 — Final verification is incomplete

The following completion evidence remains open:

- the complete AST gate matrix before a default change (Task 0.3);
- the cutover gate (Task 10.9);
- the final focused multi-prefix matrix with exact counts (Task 12.2);
- the configured `All` suite with permitted baseline Disabled cases only
  (Task 12.4);
- final section 13 convergence gates.

Whole-engine Script corpus results from 2026-08-31 were green twice at 15/15,
but they predate the latest 4.3/4.4 edits and cannot replace the final matrices.

### P2 — Integration/merge readiness trails implementation

At the snapshot:

- parent worktree: **63** status entries (`8` tracked, `55` untracked), branch
  divergence `12 behind / 33 ahead` of `main`;
- `Plugins/Angelscript`: **92** status entries (`89` tracked, `3` untracked),
  branch divergence `0 behind / 30 ahead`;
- plugin tracked diff: **89 files**, approximately `+29,970 / -9,494` lines.

The three plugin untracked source/test files are still outside the tracked
change. This state is appropriate for active development but not for merge or
archive handoff.

`git diff --check` passes for both the parent and plugin repositories; reported
LF-to-CRLF messages are warnings, not whitespace errors.

## Review-directory audit

All review artifacts inspected by this pass are under this `reviews/` directory.
Before adding this report, it contained **38 files / 919,763 bytes**. The oldest
was `implementation-review-2026-08-21.md`; the latest was
`current-progress-and-blockers-2026-08-31.md` at 2026-08-31 09:27.

The directory is useful as an evidence archive but is not yet a reliable single
current-status surface:

1. The latest prior report says `102/136`, about 98% architecture, about 95%
   implementation and about 94% default readiness. The task count is now stale,
   and the default-readiness estimate is not supported by the open cutover gates
   and known/unverified ProductionCodeGen regression.
2. `implementation-progress-snapshot-2026-08-28.md` contains multiple appended
   snapshots with incompatible denominators and conclusions in the same file:
   `94/136`, `88/125`, about 81%, about 79%, about 53% default readiness and about
   50% default readiness. It is useful chronology but unsafe as one current
   status source.
3. The folder mixes whole-change reviews, focused design/code audits, gate
   evidence and process decisions without a `README.md` index or one explicit
   `CURRENT` pointer.
4. Six of the newest review files are untracked, including the 2026-08-31 current
   progress report. A future handoff could therefore omit the very reports that
   appear most current locally.

Recommended documentation cleanup before final handoff:

- add a small `reviews/README.md` with document type, timestamp and
  superseded-by links;
- keep one date-stamped current status report immutable once written;
- always report exact OpenSpec completion separately from engineering,
  default-cutover and integration estimates;
- attach the exact build/test `Summary.json` paths and source snapshot/commit to
  each headline percentage.

## Current evidence table

| Evidence | Result | Interpretation |
|---|---:|---|
| OpenSpec apply instructions | `103/136` | Exact formal completion, 33 rows open |
| OpenSpec Node CLI strict validation | PASS | Current legacy-layout change artifacts validate |
| Build `cta-s125-remaining-sites` | exit `0` | Post-4.3 production build green |
| Build `cta-s126-decl-44-green2` | exit `0` | 4.4 focused implementation builds |
| 4.4 focused declaration gate | `1/1` | New slice green |
| SemaAuthority after 4.4 | `482/482` | Broad Sema regression green |
| Latest Frontend CanonicalAST | `189/189` | Green after 4.3, but before 4.4 |
| Latest full ProductionCodeGen | `196/197` | One known failure; no newer full rerun |
| Parent/plugin `git diff --check` | PASS/PASS | No diff whitespace errors |
| Final focused matrix / All | not run for current snapshot | Completion gate remains open |

The portable Rust manifest CLI's `doctor` reports `OS-LEGACY-LAYOUT` and
`OS-MISSING-MANIFEST` because this worktree still uses the pre-manifest OpenSpec
layout and has no `openspec/project.yaml`. That result is not treated as a
failure of this legacy-layout change's Node CLI validation, but it must be
resolved separately before this checkout can be managed as a Rust manifest
repository.

## Remaining critical path

1. Resolve the non-POD generated-getter/storage semantic conflict and restore a
   complete ProductionCodeGen green run.
2. Finish Task 4.4's full surface and complete the remaining declaration,
   expression, statement and lifetime rows in sections 4 and 5.
3. Close direct Canonical Bytecode and all product entry-point/default-cutover
   work in sections 9 and 10.
4. Run the exact focused matrix and final `All` suite on a stable source
   snapshot, then update task evidence without counting stale reports.
5. Track/commit the intended parent and plugin files, reconcile branch
   divergence, and create a clean review index before archive/merge handoff.

## Bottom line

Use **75.7%** when reporting auditable OpenSpec task completion. Use **about 89%**
when discussing practical engineering progress, with the explicit qualifier
that default cutover is about **81%** and merge readiness about **60%**. The next
confidence-changing event is not another focused Sema green; it is a fresh full
ProductionCodeGen green followed by the post-change Frontend/cutover/final
verification matrices.
