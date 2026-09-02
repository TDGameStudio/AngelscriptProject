# Current overall progress review — 2026-09-02 05:01 CST

> Historical snapshot. The progress percentages remain current, but the
> blocker identity and dirty-file counts are superseded by
> `reviews/current-overall-progress-2026-09-02-0530.md`, which adds the exact
> Complete-composition `FString` copy-constructor dependency RED.

## Executive result

- Authoritative OpenSpec checklist after evidence correction:
  **110/136 = 80.9%**.
- Unchecked rows: **26**.
- Previous literal checklist before reopening 15.8: **111/136 = 81.6%**.
- Calibrated engineering implementation: **about 85%**, reasonable range
  **84–86%**.
- Default-CANONICAL cutover readiness: **about 72%**, reasonable range
  **70–73%**.
- Recommended planning number: **85%**.
- Recommended auditable number: **80.9%**.

The formal numerator decreased by one after independent review. Task 15.8 had
claimed a precise TypedASTJIT fallback for every authenticated non-empty
lifetime plan, while CTA-S184a proved that a legal FULL_EXPRESSION temporary
was omitted and became InvalidCleanupPlan. The row has therefore been
reopened until generated-provider regeneration, Verify, diagnostic transport
and the focused owner gates are green. CTA-S184a has made real implementation
progress, but its source changes are not committed and Tasks 5.7, 5.8 and 7.5
also remain broad open umbrellas.

The branch is progressing, but it is not default-cutover ready.

## Fresh authoritative state

At this review:

- openspec reports total 136, complete 110, remaining 26 after 15.8 was
  reopened;
- parent HEAD is 84e1c0c41578;
- plugin HEAD is 0816dd453e4a;
- the plugin has seven modified files, 469 insertions and 8 deletions;
- git diff --check reports no whitespace error; only the repository's normal
  LF-to-CRLF warnings are present;
- no generated TestJIT provider file changed because generation aborted before
  publication;
- unrelated parent untracked paths .claude/skills/openspec-design.md and list/
  remain untouched.

The active CTA-S184a worktree paths are:

- four Runtime files for TypedASTJIT lifetime identity and provider diagnostic
  validation;
- three test files for source-authentic summary, installed-provider forgery
  rejection, and generated-provider transport;
- one untracked gate card under attachments, pending final evidence.

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

Exact unchecked list:

    0.2, 0.3,
    5.7, 5.8, 5.9,
    7.2, 7.4, 7.5,
    9.1, 9.5, 9.6, 9.7,
    10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9,
    12.2, 12.4,
    13.2, 13.6, 13.8, 13.12,
    15.8

## Progress since the 04:32 review

### CTA-S184a source-authentic TypedASTJIT summary is green

The source test begins with a real CANONICAL module and retained sealed
snapshot. It independently proves the Sema-authored temporary lifetime record
and full-expression exit plan before asking TypedASTJIT to summarize them.

The implementation now:

- maps Canonical FULL_EXPRESSION to TypedASTJIT exit-plan flag 0x08;
- authenticates the MaterializeTemporary expression, xvalue/value-object
  type, exact destructor declaration and owner class, ExprStmt region,
  activation identity, DestroyValue action and NORMAL plus EXCEPTION routes;
- builds the temporary storage ABI identity from the materialized type and
  destructor owner rather than guessing from a spelling;
- advances the Typed lifetime ABI hash domain from v2 to v3 and includes
  exit-plan flags and exit-plan count;
- returns the precise UnsupportedLifetime fallback
  AuthenticatedFullExpressionTemporaryRequiresNativeObjectFrameABI instead of
  InvalidCleanupPlan;
- continues to make no claim that native object-frame cleanup is executable.

Evidence:

| Gate | Result | Evidence |
|---|---:|---|
| source Typed summary RED | 0/1 expected FAIL | Saved/Tests/cta-s184a-source-typed-red2/20260902_044639_481_314d263b |
| implementation build | PASS | Saved/Build/cta-s184a-typed-full-expression-green-build/20260902_045533_832_733384fd |
| exact source Typed summary | 1/1 PASS | Saved/Tests/cta-s184a-source-typed-green/20260902_045612_706_394644b3 |

### Provider diagnostic grammar and forgery firewall are green

The provider diagnostic catalog now:

- advances its independent diagnostic schema from 2 to 3;
- advances the diagnostic digest domain from v2 to v3;
- accepts the defined FullExpression flag 0x08 while still rejecting unknown
  flag 0x10;
- requires an authenticated non-empty record/plan shape;
- rejects a forged release action, missing NORMAL or EXCEPTION route, native
  frame availability, an old schema and other cross-field contradictions;
- does not bump the provider execution-entry ABI or generated manifest schema,
  because no execution-entry layout changed;
- keeps diagnostic identity separate from artifact-set and provider-generation
  execution identity.

Evidence:

| Gate | Result | Evidence |
|---|---:|---|
| flag/schema RED | 0/1 expected FAIL | Saved/Tests/cta-s184a-provider-diagnostic-red/20260902_044714_216_96a7eeae |
| cross-field forgery RED | 0/1 expected FAIL | Saved/Tests/cta-s184a-provider-crossfield-red/20260902_045324_011_748fb198 |
| installed-provider diagnostic | 1/1 PASS | Saved/Tests/cta-s184a-provider-diagnostic-green/20260902_045646_986_362473b2 |

These are strong focused results, but they do not yet restore Task 15.8 or
close CTA-S184a because the committed generated provider still needs
regeneration, compilation, verification and transport coverage.

## Current immediate blocker

RunStaticJITTests.ps1 -Mode Generate passed its baseline build:

    Saved/Build/staticjit-testjit_01_baseline_build/
    20260902_045804_119_663a1d2e

The generation commandlet then failed:

    Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/
    20260902_045819_781_2d6bddbd

The first failure is not a schema-3 validation error. Function-fact capture
skipped the entire ASStaticJITAotFixture module because
ObjectLifetimeEntryForAOT used one class-graph dependency not present in its
declared dependency set. The batch reported Candidates=7, Captured=6,
Skipped=1. Because that module was absent from generated output, the later
TypedASTJIT provider probe could not find the authoritative
SemanticScalarBranch declaration and failed with OutputFunctionCount=28 and
ExactMatch missing.

Current classification:

- **OPEN generation/integration blocker**;
- root cause is localized to stable dependency capture versus declared
  execution-envelope dependencies;
- it may be a pre-existing artifact-capture defect exposed by the required
  regeneration, but that has not yet been proven;
- the second error is a cascade from the skipped module, not yet an
  independent TypedASTJIT semantic failure;
- it blocks generated-provider transport validation, Mode All, final review
  and the plugin/parent commits for CTA-S184a;
- it does not invalidate the two focused GREEN tests above or the previously
  committed CTA-S182/CTA-S183 Bytecode result.

The repair must preserve the stable dependency firewall. The generation probe
must not be weakened and no digest should be hand-edited.

## Why the engineering percentage is 85%

The recent work implements a high-risk TypedASTJIT semantic slice, but its
integration closure is still open. The 26 unchecked rows consist of:

| Remaining class | Count | Interpretation |
|---|---:|---|
| Final process/publication/verification umbrellas | 8 | Dependency-driven final gates rather than eight blank implementations |
| Mechanism substantially present, umbrella still open | 5 | Includes reopened 15.8; important breadth and lifecycle gaps remain |
| Substantial implementation exists, breadth incomplete | 12 | Main remaining engineering body |
| Early coverage only | 1 | Full active SDK and project Script differential |

That supports a calibrated implementation estimate of about 85% rather than a
fractional increase from one unclosed slice. Default-cutover readiness is
around 72% because artifact/install
isolation, all production entry points, default selection, no-silent-fallback,
the full differential and final matrices are still product gates.

## Permanent compound-assignment issue record

The semantic correctness issue ledger remains authoritative. Exactly four
resolved compound-assignment defects are recorded:

1. CTA-S146: overloaded lvalue Object += 7 stayed a generic Assign instead of
   a resolved opAddAssign Call.
2. CTA-S157: rvalue Make() += 7 was rejected because receiver materialization
   was confused with lvalue assignability.
3. CTA-S177: indexed += evaluated receiver/index effects before the RHS,
   producing 1,2,3 instead of required RHS-first 3,1,2 order.
4. CTA-S177: a scalar-reference RHS captured an address rather than freezing
   the pre-mutation value, returning 21 instead of 11 even though the trace
   order was already correct.

The separate Tail += 100 investigation is **REDUCED / NOT REPRODUCIBLE**, not
a fifth defect. Its strengthened fresh/reused-context oracle is 1/1 PASS at:

    Saved/Tests/cta-s179-tail-declid-strengthened/
    20260902_011308_781_6e3217c8

It proves 0 -> 100 -> 0 and one exact DeclId shared by initializer,
compound-assignment lhs and Return. Task 9.2 remains checked.

## Cache V2 boundary

The prior user decision remains authoritative:

- Cache V2/V12 production restore redesign is **DEFERRED and non-gating**;
- opt-in restore prototypes remain non-blocking regressions;
- the default-disabled Cache lifecycle boundary remains a final cutover gate;
- AST Body Sidecar remains in scope;
- no percentage in this review counts the deferred product restore redesign
  as work required for 136/136.

## Remaining critical path

1. Diagnose and repair the ObjectLifetimeEntryForAOT stable-dependency capture
   mismatch without weakening fail-closed generation.
2. Regenerate TestJIT, build generated sources, run Verify and the exact
   generated diagnostic transport test; then run the owning TypedASTJIT and
   diagnostics prefixes.
3. Finish CTA-S184a review and dual-repository commit.
4. Add scalar Return intermediate-temporary Sema/verifier/Bytecode closure,
   then continue multiple/call/conditional/lifetime-extension and
   exception/abort/suspend lifetime families.
5. Close TypedASTJIT call/dependency/lifetime matrices and Bytecode detached
   artifact/install/debug/cleanup/relocation/rollback boundaries.
6. Close all production source-build purposes, CompileFunction policy,
   default CANONICAL selection and explicit LEGACY rollback.
7. Run full active SDK plus Script-corpus differential, focused final matrix,
   Cache default-disabled boundary and All.

## Bottom line

The honest current report remains:

> **Formal checklist 80.9%; calibrated implementation about 85%;
> default-CANONICAL cutover readiness about 72%.**

The apparent plateau is caused by large umbrella tasks and strict closure
criteria, not a lack of recent work. The one-point formal decrease is an
evidence correction: Task 15.8 overclaimed coverage of every non-empty plan.
CTA-S184a has two authentic RED-to-GREEN layers, but the generated-provider
integration gate is currently red and must be fixed before 15.8 can be
restored or the slice can be committed.
