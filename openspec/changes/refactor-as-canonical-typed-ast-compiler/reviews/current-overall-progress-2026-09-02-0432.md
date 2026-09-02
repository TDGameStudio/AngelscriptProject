# Current overall progress review — 2026-09-02 04:32 CST

## Executive result

- **Authoritative OpenSpec checklist:** **111/136 = 81.6%**.
- **Unchecked rows:** **25**.
- **Calibrated engineering implementation:** **about 86%**, with a reasonable
  review range of **84–88%**.
- **Default-CANONICAL cutover readiness:** **about 73%**, with a reasonable
  review range of **70–76%**.
- **Recommended single planning number:** **86%**.
- **Recommended auditable/formal number:** **81.6%**.

This review does not promote a checklist row. The numerator remains unchanged
because CTA-S182 and CTA-S183 are completed slices inside the still-open
lifetime/consumer umbrellas rather than closure of every source family owned
by Tasks 5.7, 5.8, 7.5, 9.5 and 13.6.

The worktree is not stalled. The last two committed plugin checkpoints added
the first exact constructor-temporary `FULL_EXPRESSION` protocol and made
Canonical Bytecode consume it at the expression-statement boundary. The next
audited gaps are narrower, but affect high-risk ownership and fallback
boundaries, so the branch is not ready for default CANONICAL selection.

## Fresh authoritative checks

At 2026-09-02 04:32 CST:

```text
openspec instructions apply --change refactor-as-canonical-typed-ast-compiler --json
progress.total     = 136
progress.complete  = 111
progress.remaining = 25

openspec validate refactor-as-canonical-typed-ast-compiler
Change 'refactor-as-canonical-typed-ast-compiler' is valid
```

Repository state at review time:

```text
parent HEAD  1c83ba39  [CanonicalAST] Docs: record direct temporary Bytecode consumer gate
plugin HEAD  0816dd4   [CanonicalAST] Fix: destroy direct temporaries at full-expression boundaries
tracked parent/plugin changes: none before this review record
unrelated parent untracked paths preserved: .claude/skills/openspec-design.md, list/
```

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

Exact unchecked list:

```text
0.2, 0.3,
5.7, 5.8, 5.9,
7.2, 7.4, 7.5,
9.1, 9.5, 9.6, 9.7,
10.1, 10.2, 10.3, 10.4, 10.6, 10.7, 10.9,
12.2, 12.4,
13.2, 13.6, 13.8, 13.12
```

## Why the useful implementation estimate is 86%

The 25 unchecked rows are not 25 untouched implementations:

| Remaining class | Count | Rows | Current interpretation |
|---|---:|---|---|
| Final process/publication/verification umbrellas | 8 | `0.2, 0.3, 10.2, 10.7, 10.9, 12.2, 12.4, 13.12` | Mostly dependency-driven closure and final runs; not eight blank implementations. |
| Mechanism substantially present, umbrella still open | 4 | `5.8, 7.5, 9.1, 13.8` | Core mechanisms exist, but not every source family/consumer/publication invariant is closed. |
| Substantial implementation exists, breadth incomplete | 12 | `5.7, 5.9, 7.2, 7.4, 9.5, 9.6, 10.1, 10.3, 10.4, 10.6, 13.2, 13.6` | Main remaining engineering body. |
| Early coverage only | 1 | `9.7` | Full active SDK and project-corpus differential is not yet built. |

Section 15's completed 11/11 subplan already contains the B2 lifetime
protocol, verified shared view, partial-construction and aggregate machinery,
and established Bytecode/TypedASTJIT boundaries. The remaining lifetime rows
therefore overlap substantial completed work. However, the gaps listed below
are product-critical, so the estimate stays below 90%.

## Most recent completed work

### CTA-S182: direct constructor temporary lifetime authority

Plugin `41cafb7`, parent `77f9473a`:

- source Sema authors one pointer-free
  `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record;
- the record names the materialized ExprId, exact destructor DeclId, owning
  ExprStmt semantic region, and `NORMAL | EXCEPTION` routes;
- the shared verifier authenticates the relationship in both directions and
  derives the exact `FULL_EXPRESSION` plan;
- malformed/missing/foreign destructor and forged record relations fail
  closed.

Final recorded evidence includes build PASS, Frontend Verifier **80/80**,
SemaAuthority **567/567**, focused production **1/1**, and AST Body Sidecar
**27/27**.

### CTA-S183: direct temporary Canonical Bytecode consumer

Plugin `0816dd4`, parent `1c83ba39`:

- authentic RED: `FTracked(7);` remained live until the function epilogue, so
  the following return observed `0` instead of `7`;
- Canonical Bytecode now consumes only the owning ExprStmt's authenticated
  `FULL_EXPRESSION` plan after expression evaluation;
- the exact Materialize ExprId resolves to its backend-local slot, the exact
  destructor is called, the slot becomes `UNINIT`, and the object is retired
  from generic epilogue cleanup;
- behavior now returns `7` and remains `7` after execution, proving correct
  timing and no second destruction (`77`);
- publisher provenance is Canonical and LEGACY invocation count is zero.

Fresh recorded GREEN evidence:

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-s183-direct-temp-codegen-green/20260902_041145_634_87fe466a` |
| Focused direct temporary | **1/1 PASS** | `Saved/Tests/cta-s183-direct-temp-codegen-green/20260902_041203_747_21ba57b3` |
| ProductionCodeGen owner | **235/235 PASS** | `Saved/Tests/cta-s183-production-owner/20260902_041245_215_3023a927` |
| AST Body Sidecar | **27/27 PASS** | `Saved/Tests/cta-s183-sidecar-regression/20260902_041831_991_3b5f70e1` |
| SemaAuthority | **567/567 PASS** | `Saved/Tests/cta-s183-sema-regression/20260902_041910_961_d98a4de2` |
| Frontend Verifier | **80/80 PASS** | `Saved/Tests/cta-s183-verifier-regression/20260902_042045_841_93a07ffa` |

These close one real source/consumer slice, not the entire lifetime matrix.

## Newly confirmed open gaps

### 1. TypedASTJIT misclassifies a legal full-expression temporary protocol

The direct `FTracked(7);` lifetime protocol is legal, sealed and executable in
Canonical Bytecode, but the TypedASTJIT summary cannot currently authenticate
it precisely:

- `EAngelscriptTypedASTJITLifetimeExitPlanFlags` has Normal, Transfer and
  ForEach, but no `FullExpression` bit;
- summary construction expects declaration-backed storage and does not have a
  path for `SUBJECT_TEMPORARY` whose identity is a sealed
  `MATERIALIZE_TEMPORARY` ExprId;
- the legal record therefore collapses to an unverified/default summary and
  eligibility reports `InvalidCleanupPlan` instead of the required precise
  typed `UnsupportedLifetime` fallback;
- provider diagnostics validation accepts only `0x07`, so a future exact
  `FullExpression` diagnostic bit (`0x08`) would be rejected unless the
  manifest becomes `0x0f` and the diagnostics schema revision advances from
  2 to 3;
- the stable lifetime key already covers plan kind/order, but the typed ABI
  key does not currently cover exit-plan flags/count; the exact typed
  full-expression requirement must be added to that semantic ABI identity so
  different cleanup-plan families cannot alias;
- Provider entry ABI layout itself does not change solely because this
  diagnostic/summary flag is added, so this finding does not justify an
  unrelated provider entry ABI revision bump.

Required closure is an authenticated pointer-free summary containing the
exact destructor/type ABI identity, record/plan counts and
`FullExpression`, followed by a precise per-function fallback because native
object-frame cleanup is still unsupported. Provider publication must remain
downstream of this authoritative Typed eligibility/emission gate.

This is a real Task 5.8/7.5/15.8 closure gap. It does not invalidate CTA-S183's
Bytecode result, but it prevents calling the full shared-consumer boundary
complete.

### 2. Scalar Return intermediate temporary lacks an exact lifetime plan

For:

```angelscript
int Entry()
{
    return FTracked().Value + 1;
}
```

the current AST already has the important expression shape:

```text
ReturnStmt
  -> numeric Binary
     -> generated getter Call
        -> receiver Cleanup
           -> MaterializeTemporary
              -> Construct FTracked
```

However:

- only expression statements call `ActOnFinishFullExpression`;
- the Return Sema action does not call it;
- current lifetime classification/verifier completeness accepts only an
  ExprStmt as a full-expression owner;
- Return CodeGen captures the return value and performs TRANSFER cleanup, but
  has no authenticated Return `FULL_EXPRESSION` plan between those steps.

The existing lifetime protocol revision and enum vocabulary are sufficient:
this remains a `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record whose
semantic region is the ReturnStmt. The fix should not invent a new phase,
subject/action kind, public ABI or protocol revision for this bounded source
family.

The intended ordering is:

```text
evaluate return expression
-> capture scalar return value
-> destroy Return intermediate temporary (FULL_EXPRESSION)
-> destroy lexical live objects (TRANSFER)
-> jump to return
```

A strong behavioral oracle is:

```angelscript
int DestructionTrace = 0;

struct FTracked
{
    int Id;
    int Value;
    FTracked(int InId) { Id = InId; Value = InId; }
    ~FTracked() { DestructionTrace = DestructionTrace * 10 + Id; }
}

int Entry()
{
    FTracked Local(1);
    DestructionTrace = 0;
    return FTracked(7).Value + 1;
}
```

Required result is return value `8` and trace `71`: the return value is
captured first, temporary `7` dies at the return full-expression boundary,
then lexical local `1` dies on transfer. The current incomplete route is
expected to expose `17` or another incorrect/double-cleanup result.

This slice is deliberately distinct from returned-value ownership/RVO and
lifetime extension. Those remain separate lifetime families and must not be
silently claimed by the scalar-return fix.

The ordering follows the retained LLVM/Clang reference model: Clang completes
return conversion before `ActOnFinishFullExpr`, and its CodeGen captures the
scalar return value before forcing the full-expression cleanup scope and then
branching through outer lexical cleanups. Relevant local reference anchors are
`Reference/llvm-project/clang/lib/Sema/SemaStmt.cpp:3716`,
`Sema/SemaExprCXX.cpp:6611`, `CodeGen/CGStmt.cpp:1636`, and
`AST/ByteCode/Compiler.cpp:2913`.

### 3. Broad cutover blockers remain

After the two focused lifetime/Typed fixes above, the largest remaining work
still includes:

- containers/templates, delegates, closures, funcdefs, imports, mutable and
  constant globals, generated lifecycle/default/accessor/list-factory bodies,
  and active SDK source families;
- complete TypedASTJIT call/dependency and lifetime disposition;
- detached Bytecode artifact/install, debug/cleanup metadata, full relocation
  and failure-rollback closure;
- all production build purposes, CompileFunction policy, default selection,
  explicit LEGACY rollback and no silent fallback;
- active SDK plus project Script corpus differential;
- focused final matrix and `All` with the accepted Disabled baseline only.

These are why cutover readiness is lower than implementation progress.

## Permanent `+=` disposition

The semantic correctness ledger remains authoritative and records exactly
four distinct resolved compound-assignment defects:

1. overloaded lvalue `Object += 7` needed a resolved `opAddAssign` Call;
2. rvalue `Make() += 7` needed one-time receiver materialization;
3. indexed `+=` needed RHS-first `3,1,2` evaluation order;
4. scalar-reference RHS aliasing needed a pre-mutation value snapshot, giving
   `11` instead of `21`.

The separate `Tail += 100` probe is **REDUCED / NOT REPRODUCIBLE**, not a fifth
defect. Its strengthened oracle is **1/1 PASS** at
`Saved/Tests/cta-s179-tail-declid-strengthened/20260902_011308_781_6e3217c8`:
fresh and reused contexts produce `0 -> 100 -> 0`, and initializer, compound
lhs and Return share the same exact DeclId. Task 9.2 remains checked.

## Cache V2 boundary

The prior user decision remains in force:

- Cache V2/V12 production restore redesign is **deferred and non-gating**;
- opt-in restore prototypes may continue as non-blocking regression coverage;
- the Cache V2 default-disabled lifecycle boundary remains part of the final
  cutover gate, because no hidden restore path may affect CANONICAL selection;
- AST Body Sidecar remains in scope and continues to carry required snapshot
  evidence where its current schema is sufficient.

No percentage in this review treats deferred Cache product redesign as work
required to reach 136/136.

## Recommended next sequence

1. Close the TypedASTJIT `FullExpression` temporary summary/fallback and
   provider-diagnostics grammar gap with source/authentication and forgery
   tests first.
2. Add the scalar Return intermediate-temporary Sema/verifier RED, then make
   Return CodeGen consume the exact plan after result capture and before
   TRANSFER cleanup.
3. Continue the remaining lifetime families until Tasks 5.7/5.8 can close as
   complete matrices rather than isolated slices.
4. Advance the broad active-language, TypedASTJIT, Bytecode/install and
   production-entry matrices.
5. Run the default-cutover gate only after the semantic/consumer rows are
   complete, followed by focused SDK/Cache/HotReload/StaticJIT and final All.

## Bottom line

The honest current report is:

> **Formal checklist: 81.6%. Engineering implementation: about 86%.
> Default-CANONICAL cutover readiness: about 73%.**

Recent work is real and verified, but it has advanced high-risk slices inside
large lifetime/consumer umbrellas, so the formal numerator has correctly
remained at 111 rather than being inflated. The branch is progressing, is not
release-ready, and the immediate blockers are now specific enough for the next
TDD cards rather than being an unexplained plateau.
