# Current overall progress review — 2026-09-02 05:30 CST

## Executive result

- Authoritative OpenSpec checklist: **110/136 = 80.9%**.
- Unchecked rows: **26**.
- Calibrated engineering implementation: **about 85%**, reasonable range
  **84–86%**.
- Default-CANONICAL cutover readiness: **about 72%**, reasonable range
  **70–73%**.
- Recommended planning number: **85%**.
- Recommended auditable number: **80.9%**.

There is no new checkbox closure since the 05:01 review. There is, however,
material diagnostic progress: CTA-S184a now has a real Complete-composition
artifact regression test that identifies the exact missing dependency as the
environment `FString(const FString&inout)` copy constructor. That is stronger
evidence than the earlier module-level Generate symptom, but it remains RED;
therefore it does not restore Task 15.8 or increase the formal percentage.

The branch is still progressing, but it is not default-cutover ready.

## Fresh authoritative state

At this review:

- `tasks.md` contains 136 checklist rows: 110 checked and 26 unchecked;
- parent HEAD is `84e1c0c41578`;
- plugin HEAD is `0816dd453e4a`;
- the plugin worktree has eight modified files, 618 insertions and 8
  deletions;
- four Runtime/test files implement the CTA-S184a typed full-expression
  summary and provider diagnostic schema/firewall;
- three existing focused test files cover source-authentic typed summary,
  installed-provider forgery rejection and generated-provider transport;
- one new generation-facts test captures the Complete-composition dependency
  mismatch directly;
- generated TestJIT provider output is still unchanged because Generate has
  not reached successful publication;
- unrelated parent paths `.claude/skills/openspec-design.md` and `list/`
  remain untouched.

## Exact checklist status

| Section | Done | Total | Remaining |
|---|---:|---:|---|
| 0 AST-first quality gate | 3 | 5 | 0.2, 0.3 |
| 1 Baselines | 6 | 6 | — |
| 2 SourceManager / AST foundation | 13 | 13 | — |
| 3 Public AST / module / lease | 8 | 8 | — |
| 4 Declaration / type Sema | 7 | 7 | — |
| 5 Expression / statement / lifetime Sema | 7 | 10 | 5.7, 5.8, 5.9 |
| 6 Cache containment | 12 | 12 | — |
| 7 TypedASTJIT migration | 5 | 8 | 7.2, 7.4, 7.5 |
| 8 Generate / diagnostics | 9 | 9 | — |
| 9 Canonical Bytecode | 5 | 9 | 9.1, 9.5, 9.6, 9.7 |
| 10 Product cutover / LEGACY isolation | 2 | 9 | 10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9 |
| 11 Public API / docs | 5 | 5 | — |
| 12 Final verification | 4 | 6 | 12.2, 12.4 |
| 13 Review convergence | 8 | 12 | 13.2, 13.6, 13.8, 13.12 |
| 14 Type identity / Runtime boundary | 6 | 6 | — |
| 15 Lifetime protocol subplan | 10 | 11 | 15.8 |
| **Total** | **110** | **136** | **26** |

Exact unchecked rows:

    0.2, 0.3,
    5.7, 5.8, 5.9,
    7.2, 7.4, 7.5,
    9.1, 9.5, 9.6, 9.7,
    10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9,
    12.2, 12.4,
    13.2, 13.6, 13.8, 13.12,
    15.8

## Progress since the 05:01 review

### Core fixture control is green

The existing Core-composition generation-facts test remains green:

- test:
  `LargeFixtureBuildsVerifiedFactsWithoutCacheRecords`;
- result: **1/1 PASS**;
- evidence:
  `Saved/Tests/cta-s184a-generation-facts-root-red/`
  `20260902_052136_692_f1d71890`.

That run captures all four Core modules and disproves a universal or random
failure in function-artifact dependency capture.

### Complete fixture now has an exact authentic RED

A new test,
`CompleteFixtureFunctionRelocationsHaveDeclaredDependencies`, compiles the
real seven-module Complete fixture, writes and validates the real
`UStaticJITAotFunctionCarrier::ObjectLifetimeEntryForAOT` function artifact,
and requires every `FUNCTION_SIGNATURE` relocation to have an exact
`SIGNATURE/FUNCTION` compiler dependency.

The test builds successfully but is authentically RED:

- build: **PASS** at
  `Saved/Build/cta-s184a-complete-fixture-dependency-red-build/`
  `20260902_052346_566_c7fd05fd`;
- exact test: **0/1 expected FAIL** at
  `Saved/Tests/cta-s184a-complete-fixture-dependency-red/`
  `20260902_052413_511_370e5778`;
- exact missing declaration: `FString(const FString&inout)`;
- exact owner: `FString`;
- exact stable key:
  `5dd2e37454d592763ad2d32ca5788dc8ad3b050821c766703d27811006302af6`;
- failure source: function artifact use 3 is present, but the exact compiler
  dependency is absent.

This corrects the earlier wording: the current root symptom is not merely an
unspecified `ObjectLifetimeEntryForAOT` dependency mismatch. It is a concrete
copy-constructor relocation/dependency mismatch selected by the Complete
composition.

### Root-cause status

The current production code strongly localizes the omission:

- `EmitCopyConstructValue` resolves the exact copy constructor and emits a
  `CALL` or `CALLSYS` containing its function id;
- unlike the destructor and ordinary resolved-call paths, that helper does
  not currently call `builder->MarkDependency(copyCtor, 0, 0)` before the
  call;
- the artifact writer therefore observes the function-signature relocation,
  while the dependency capture lacks the exact declaration.

This is the leading root-cause hypothesis and is now backed by an exact
pointer-level regression oracle. Production has not yet been changed, so the
status remains **OPEN / RED**, not fixed.

Independent review also found a separate containment concern: the current
facts-only capture treats a function failure as a whole-module skip even
though final provider routing is per-function. That amplification should be
handled as a separate fail-closed isolation slice after the exact missing
dependency is fixed. It must not be used to weaken the dependency firewall or
to declare `ObjectLifetimeEntryForAOT` valid without its copy-constructor edge.

## CTA-S184a gate state

| Gate | Result | Evidence |
|---|---:|---|
| source Typed summary RED | 0/1 expected FAIL | `Saved/Tests/cta-s184a-source-typed-red2/20260902_044639_481_314d263b` |
| implementation build | PASS | `Saved/Build/cta-s184a-typed-full-expression-green-build/20260902_045533_832_733384fd` |
| exact source Typed summary | 1/1 PASS | `Saved/Tests/cta-s184a-source-typed-green/20260902_045612_706_394644b3` |
| provider schema/flag RED | 0/1 expected FAIL | `Saved/Tests/cta-s184a-provider-diagnostic-red/20260902_044714_216_96a7eeae` |
| provider cross-field forgery RED | 0/1 expected FAIL | `Saved/Tests/cta-s184a-provider-crossfield-red/20260902_045324_011_748fb198` |
| installed-provider diagnostics | 1/1 PASS | `Saved/Tests/cta-s184a-provider-diagnostic-green/20260902_045646_986_362473b2` |
| Core generation-facts control | 1/1 PASS | `Saved/Tests/cta-s184a-generation-facts-root-red/20260902_052136_692_f1d71890` |
| Complete dependency oracle | 0/1 expected FAIL | `Saved/Tests/cta-s184a-complete-fixture-dependency-red/20260902_052413_511_370e5778` |
| StaticJIT Generate | FAIL | `Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/20260902_045819_781_2d6bddbd` |
| generated-source build | NOT RUN | blocked by Generate |
| Verify | NOT RUN | blocked by Generate/build |
| generated diagnostic transport | NOT RUN | blocked by generated provider |
| owner prefixes | NOT RUN | wait for corrected provider |

Task 15.8 therefore remains correctly reopened. Source-level summary and
installed-provider validation are green, but generated-provider publication
is not.

## Permanent compound-assignment record

The semantic-correctness issue ledger remains authoritative. The `+=` family
contains exactly four resolved defects, each with a distinct invariant:

1. **CTA-S146 — overloaded lvalue:** `Object += 7` stayed a generic Assign
   instead of a resolved `opAddAssign` Call.
2. **CTA-S157 — rvalue receiver:** `Make() += 7` was rejected because
   one-time receiver materialization was confused with lvalue assignability.
3. **CTA-S177-ORDER — indexed sequencing:** receiver/index effects ran before
   the RHS, producing `1,2,3` instead of required RHS-first `3,1,2`.
4. **CTA-S177-SCALAR-REF-SNAPSHOT — aliasing:** a scalar-reference RHS kept an
   address instead of freezing the pre-mutation value, producing `21` instead
   of `11` despite the correct trace order.

The separate `Tail += 100` investigation remains **REDUCED / NOT
REPRODUCIBLE**, not a fifth compound-assignment defect. Its strengthened
fresh/reused-context oracle is **1/1 PASS** at:

    Saved/Tests/cta-s179-tail-declid-strengthened/
    20260902_011308_781_6e3217c8

It proves `0 -> 100 -> 0` and one exact DeclId shared by the initializer,
compound-assignment lhs and Return. Task 9.2 remains checked. The current
`FString` copy-constructor dependency defect is unrelated to `+=` and is
tracked separately as a generation-integrity blocker.

## Why the formal percentage still looks flat

The 26 unchecked rows are broad closure umbrellas, not 26 equally small code
changes:

| Remaining class | Count | Interpretation |
|---|---:|---|
| Final process/publication/verification umbrellas | 8 | Dependency-driven final gates, not blank implementations |
| Mechanism substantially present, umbrella still open | 5 | Includes reopened 15.8; breadth/lifecycle evidence remains |
| Substantial implementation exists, breadth incomplete | 12 | Main remaining engineering body |
| Early coverage only | 1 | Full active SDK and project Script differential |

Recent work has been closing semantic correctness in narrow, testable slices:
call rewriting, explicit evaluation order and alias snapshots, statement and
control targets, enum/switch sentinel authority, source-authored temporary
lifetime, direct Bytecode cleanup, and now TypedASTJIT/provider lifetime
summary transport. These improve implementation confidence inside open
umbrella rows without automatically checking them.

That is why the honest pair remains **80.9% auditable / about 85%
engineering-complete**. The lower **about 72% cutover-readiness** reflects the
remaining detached artifact/install/rollback boundaries, all production
entry points, product-default selection, full differential and final matrices.

## Cache V2 boundary

The prior user decision remains authoritative:

- Cache V2/V12 production restore redesign is **DEFERRED / NON-GATING**;
- opt-in restore prototypes remain non-blocking regressions;
- the Cache default-disabled lifecycle boundary remains a final cutover gate;
- AST Body Sidecar remains in scope;
- no percentage here counts the deferred production restore redesign as a
  requirement for 136/136.

## Remaining critical path

1. Make the copy-constructor dependency RED green without weakening exact
   dependency authority; rerun the Complete dependency oracle and the full
   GenerationFacts owner.
2. Rerun StaticJIT Generate, generated-source build, Verify, generated
   diagnostic transport and the TypedASTJIT/provider owner prefixes; then
   review whether Task 15.8 can be restored.
3. Separately prove function-level fail-closed fact-capture isolation and
   dependent-caller closure so one invalid function cannot evict independent
   functions from the same module.
4. Finish the remaining lifetime families, TypedASTJIT call/dependency matrix,
   Bytecode artifact/install/debug/relocation/rollback boundary and full
   differential coverage.
5. Close all source-build entry points, default CANONICAL selection, explicit
   LEGACY rollback, the Cache default-disabled boundary and final focused/All
   matrices.

## Bottom line

> **Formal checklist 80.9%; calibrated implementation about 85%;
> default-CANONICAL cutover readiness about 72%.**

The percentage is unchanged because the newest evidence is still RED, but the
blocker is materially better understood: it is the missing exact `FString`
copy-constructor dependency in the Complete function artifact. The `+=`
history is permanently retained as exactly four closed semantic defects;
`Tail += 100` is explicitly not a fifth one.
