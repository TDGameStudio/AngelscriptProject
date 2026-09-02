# Current overall progress review — 2026-09-02 04:20 CST

## Executive result

- **Authoritative OpenSpec checklist progress:** **111/136 = 81.6%**.
- **Unchecked rows:** **25**.
- **Calibrated engineering implementation progress:** **about 86%**;
  reasonable review range **84–88%**.
- **Default-CANONICAL product/cutover readiness:** approximately **73%**;
  reasonable review range **70–76%**.
- **Recommended single number for overall engineering planning:** **86%**.
- **Recommended auditable number for formal reporting:** **81.6%**.

The formal numerator has not changed after CTA-S183. That does not mean the
work has stalled: CTA-S182 authored the first direct-temporary full-expression
lifetime slice and CTA-S183 made Canonical Bytecode consume its authenticated
plan at the correct destruction boundary. Task 5.7 still owns multiple
remaining source lifetime families and therefore cannot yet be checked.

Do not describe the branch as release-ready or ready for default CANONICAL
selection. The remaining rows are fewer than their raw count suggests, but
they contain the highest-risk language breadth, Bytecode/TypedASTJIT consumer,
publication, cutover and final verification work.

## Current authoritative state

The current commands report:

```text
openspec instructions apply --change refactor-as-canonical-typed-ast-compiler --json
progress.total     = 136
progress.complete  = 111
progress.remaining = 25

openspec validate refactor-as-canonical-typed-ast-compiler
Change 'refactor-as-canonical-typed-ast-compiler' is valid
```

`openspec status --change ... --json` may report the change artifacts as
complete. That means proposal/design/spec/tasks artifacts exist; it does not
mean all 136 task checkboxes are complete.

## Exact section status

| Section | Done | Total | Remaining |
|---|---:|---:|---|
| 0 AST-first quality gate | 3 | 5 | `0.2, 0.3` |
| 1 Baselines | 6 | 6 | — |
| 2 SourceManager / AST foundation | 13 | 13 | — |
| 3 Public AST / module / lease | 8 | 8 | — |
| 4 Declaration / type Sema | 7 | 7 | — |
| 5 Expression / statement / lifetime Sema | 7 | 10 | `5.7, 5.8, 5.9` |
| 6 Cache containment | 12 | 12 | — |
| 7 TypedASTJIT migration | 5 | 8 | `7.2, 7.4, 7.5` |
| 8 Generate / diagnostics | 9 | 9 | — |
| 9 Canonical Bytecode | 5 | 9 | `9.1, 9.5, 9.6, 9.7` |
| 10 Product cutover / LEGACY isolation | 2 | 9 | `10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9` |
| 11 Public API / docs | 5 | 5 | — |
| 12 Final verification | 4 | 6 | `12.2, 12.4` |
| 13 Review convergence | 8 | 12 | `13.2, 13.6, 13.8, 13.12` |
| 14 Type identity / Runtime boundary | 6 | 6 | — |
| 15 Lifetime protocol subplan | 11 | 11 | — |
| **Total** | **111** | **136** | **25** |

The exact unchecked list is:

`0.2, 0.3, 5.7, 5.8, 5.9, 7.2, 7.4, 7.5, 9.1, 9.5, 9.6, 9.7,
10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9, 12.2, 12.4, 13.2, 13.6,
13.8, 13.12`.

## Why the useful engineering number is about 86%

The raw `111/136` ratio gives every checkbox equal weight. The task graph does
not have equal-sized rows, and several remaining umbrella rows overlap work
that is already implemented and checked in their detailed subplans.

The 25 unchecked rows divide more honestly into four classes:

| Class | Count | Rows | Interpretation |
|---|---:|---|---|
| Final process, publication or verification umbrellas | 8 | `0.2, 0.3, 10.2, 10.7, 10.9, 12.2, 12.4, 13.12` | Mainly wait for dependencies, then run, record and enforce the final gates. They are not eight untouched implementations. |
| Mechanism substantially present, but own umbrella cannot close | 4 | `5.8, 7.5, 9.1, 13.8` | Core protocol/view/transaction/snapshot mechanisms exist; the row remains open because its complete matrix or all publishers/consumers are not yet closed. |
| Substantial production implementation exists, but language/entry-point coverage is incomplete | 12 | `5.7, 5.9, 7.2, 7.4, 9.5, 9.6, 10.1, 10.3, 10.4, 10.6, 13.2, 13.6` | These are the main remaining engineering body. They are neither zero-percent nor closure-ready. |
| Early coverage only | 1 | `9.7` | Isolated differential fixtures exist, but the required active SDK and project corpus differential matrix is not yet built. |

This explains why treating every unchecked row as completely unimplemented
would understate the result. In particular, section 15's eleven completed
tasks contain the real B2 lifetime protocol, verified shared view, Bytecode and
TypedASTJIT consumption boundary, partial construction, aggregate progress and
Sidecar boundary. Task 5.8 overlaps those mechanisms and is not a fresh blank
implementation.

The estimate is nevertheless held at approximately 86%, rather than being
raised above 90%, because the remaining large rows decide whether the system
can actually replace the product-default compiler path:

- complete source lifetime, globals, abort/exception and suspend ownership;
- remaining active language Sema and executable CodeGen surface;
- elimination of CANONICAL semantic replay from native parser nodes;
- complete TypedASTJIT eligibility, call/dependency and lifetime disposition;
- complete detached Bytecode artifact/install/debug/cleanup metadata;
- real entry-point coverage, default selection, no silent fallback;
- current Canonical-vs-LEGACY differential corpus and final focused/All gates.

Therefore the most defensible reporting is:

> **Formal: 81.6%. Engineering: about 86%. Default-cutover readiness: about
> 73%.**

The third number is intentionally lower: architecture and supported semantic
slices are mature, while default product selection remains deliberately late
and gated.

## What has advanced recently

### Structured statement/control semantics closed

Plugin commit `9dd1331` and parent commit `9b119dcc` closed the structured
control semantic checkpoint. The implementation covers source-authored and
verifier-authenticated control facts rather than relying on executable native
parser-tree semantics in the CANONICAL backend. This was a large implementation
checkpoint, not documentation-only progress.

### Direct temporary full-expression lifetime authority landed

Plugin commit `41cafb7` and parent commit `77f9473a` added CTA-S182. For the
direct value-object temporary expression-statement family, Sema now authors a
pointer-free lifetime record with:

- subject `TEMPORARY`;
- action `DESTROY_VALUE` targeting the exact destructor declaration;
- activation tied to the materialized temporary;
- semantic region tied to the owning expression statement;
- phase `FULL_EXPRESSION`;
- supported normal and exception routes;
- a derived success-sensitive full-expression commit/cleanup plan.

The first implementation was not accepted blindly. Read-only review found a
malformed-shape fail-open and insufficient constructor/wrapper authentication.
Focused RED/GREEN verifier work added a three-state
`NOT_CANDIDATE / MALFORMED / VALID` classifier and exact type/owner checks. A
complete Sema run then exposed a reference-object/class temporary regression;
that was also fixed and retained as a source gate.

The final current evidence is:

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-s182-reference-boundary-final/20260902_033534_942_1e2dbb2e` |
| Frontend Verifier | **80/80 PASS** | `Saved/Tests/cta-s182-verifier-final/20260902_033609_637_0e812273` |
| SemaAuthority | **567/567 PASS** | `Saved/Tests/cta-s182-sema-final/20260902_033609_637_f01926f7` |
| Production temporary route | **1/1 PASS** | `Saved/Tests/cta-s182-production-final/20260902_033707_375_9a2b3619` |
| AST Body Sidecar | **27/27 PASS** | `Saved/Tests/cta-s182-sidecar-final/20260902_033707_375_b689e880` |

Each test summary uses `ReportJson` and records zero failures and zero skips.
No new test suite was run solely for this read-only progress review; the table
revalidates the committed checkpoint evidence already present on disk.

### Direct temporary full-expression Bytecode consumer is GREEN

CTA-S183, committed in the plugin at `0816dd4`, closes the production consumer
half of the CTA-S182 direct expression-statement family. The authentic RED
proved the snapshot and exact
full-expression plan were already present, but `FTracked(7);` stayed live until
the function epilogue: the following Return observed destruction trace `0`
instead of `7`. Canonical Bytecode now evaluates once, consumes only the owning
ExprStmt's authenticated `FULL_EXPRESSION` plan, resolves the exact
Materialize ExprId to its backend-local slot, calls the record's exact
destructor and marks that slot uninitialized/dead.

The focused behavior now returns `7`, while the post-execution global also
remains `7`; this proves both boundary timing and absence of duplicate epilogue
destruction. Publisher provenance is Canonical and the LEGACY compiler count is
zero. Current evidence is:

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-s183-direct-temp-codegen-green/20260902_041145_634_87fe466a` |
| Focused direct temporary behavior | **1/1 PASS** | `Saved/Tests/cta-s183-direct-temp-codegen-green/20260902_041203_747_21ba57b3` |
| Complete ProductionCodeGen | **235/235 PASS** | `Saved/Tests/cta-s183-production-owner/20260902_041245_215_3023a927` |
| AST Body Sidecar | **27/27 PASS** | `Saved/Tests/cta-s183-sidecar-regression/20260902_041831_991_3b5f70e1` |
| SemaAuthority | **567/567 PASS** | `Saved/Tests/cta-s183-sema-regression/20260902_041910_961_d98a4de2` |
| Frontend Verifier | **80/80 PASS** | `Saved/Tests/cta-s183-verifier-regression/20260902_042045_841_93a07ffa` |

This materially advances the already-substantial lifetime/Bytecode mechanisms,
but does not warrant increasing the headline engineering estimate above about
86%: Return/call/conditional/multiple temporaries, lifetime extension, returned
ownership, exception/suspend routes and the TypedASTJIT native object-frame
boundary remain open. The formal numerator remains **111/136** because no
umbrella row is honestly complete yet.

## Why 5.7 and 5.8 still do not move the numerator

CTA-S182 is the first direct temporary family inside Task 5.7, not the entire
lifetime acceptance matrix. The remaining live source/consumer families are:

1. multiple temporaries and call/conditional/Return full expressions;
2. lifetime extension and returned-temporary ownership;
3. non-POD/value-object `&out`, `&inout`, and reference-return aliases;
4. object global initialization failure and reverse shutdown destruction;
5. supported abort/exception routes and suspend/resume ownership;
6. source-authored delegating construction;
7. matching Bytecode and TypedASTJIT execution or exact typed fallback.

Section 15 has already closed the lifetime architecture. It should not be
reimplemented. Task 5.8 remains open because it is an umbrella that also
requires the complete 5.7 source matrix and full relevant consumers.

There is one documentation-quality issue: the historical “Why this is still
open” text beneath Task 5.8 still mentions missing protocol, early AOT local
activation and missing construction prefixes. Those facts were superseded by
15.1–15.11. The checkbox should remain open, but the explanatory text should
eventually be rewritten to name the live matrix/consumer gaps, preventing a
future reviewer from mistaking historical blockers for current architecture.

## Remaining critical path

The shortest honest dependency order is:

1. finish Task 5.7 source lifetime families, then close the 5.8 umbrella;
2. close broad Sema coverage 5.9 and Sema-authority convergence 13.2;
3. finish TypedASTJIT 7.2/7.4/7.5;
4. finish Canonical Bytecode/install 9.1/9.5/9.6 and convergence 13.6;
5. build the complete differential corpus 9.7 and close the remaining
   multi-publisher snapshot audit 13.8;
6. prove all real entry points and remove residual CANONICAL parser-node
   semantic replay under 10.1/10.3/10.4/10.6;
7. run the pre-cutover matrix, switch the reversible default, prove no silent
   fallback, then close 10.2/10.7/10.9;
8. reconcile all AST-first cards and run current focused plus All gates for
   0.2/0.3/12.2/12.4/13.12.

Task 9.7 is the least mature single remaining feature row. The higher immediate
semantic risk, however, remains 5.7/5.9/13.2 and 9.5/13.6 because those decide
whether the complete language can be compiled from one sealed canonical AST.

## Permanent semantic ledger, including `+=`

The permanent ledger remains at
`reviews/semantic-correctness-issue-ledger-2026-09-01.md`. The compound
assignment disposition is exactly four resolved defects:

1. overloaded lvalue `Object += 7` required the exact resolved `opAddAssign`
   call rewrite;
2. rvalue `Make() += 7` required single-evaluation receiver materialization;
3. indexed compound assignment required RHS-first side-effect order `3,1,2`;
4. scalar-reference RHS aliasing required a pre-mutation value snapshot,
   returning `11`, not `21`.

`Tail += 100` remains **REDUCED / NOT REPRODUCIBLE**, not a fifth defect. Its
strengthened oracle is **1/1 PASS** at
`Saved/Tests/cta-s179-tail-declid-strengthened/20260902_011308_781_6e3217c8`.
The initializer, compound-assignment lhs and Return share one exact DeclId, and
fresh/reused contexts produce `0 -> 100 -> 0`.

This review does not reopen Task 9.2 and does not erase the historical Tail
observation; it preserves the reduced result and the distinction from the four
real compound-assignment defects.

## Cache V2 boundary

The user's prior scope decision remains in force:

- Cache V2/V12 product restore redesign is **deferred and non-gating**;
- completed Cache containment requirements stay complete;
- opt-in restore prototype regressions do not block this change's default-off
  boundary;
- AST Body Sidecar remains in scope because it is the pointer-free Canonical
  snapshot transport, not the deferred product restore redesign.

The current Sidecar result is **27/27 PASS**. This evidence must not be used to
claim that the deferred Cache V2 product path has been completed or reopened.

## Worktree/integration state

- parent base before this CTA-S183 evidence commit: `77f9473a`;
- plugin HEAD and updated parent gitlink: `0816dd4`;
- plugin worktree: clean after the CTA-S183 commit;
- parent CTA-S183 gate/task/review/gitlink update: recorded by the commit that
  contains this review;
- unrelated untracked paths remain untouched:
  `.claude/skills/openspec-design.md` and `list/`;
- `git diff --check` is clean for parent and plugin;
- no checkbox was changed by this read-only review;
- no merge, archive, release, default-pipeline or completion claim is made.

## Bottom line

> The current defensible answer is **81.6% formal, about 86% engineering, and
> about 73% default-cutover ready**. Recent work has not been idle: structured
> control closed, the first exact temporary full-expression lifetime authority
> landed, and Canonical Bytecode now consumes that authenticated plan at the
> correct destruction boundary. The
> formal numerator stays at 111 because Task 5.7 is an umbrella. The remaining
> work is no longer foundation-building; it is the difficult product closure
> across lifetime breadth, advanced Sema, Bytecode/TypedASTJIT consumers,
> entry-point/default cutover and complete current verification.
