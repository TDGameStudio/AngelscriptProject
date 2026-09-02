# Expression-graph verifier firewall and Parser baseline alignment — 2026-08-23

## Expression-cycle finding

`asCASTVerify()` already performed a depth-first cycle check over statement
children (`VisitStmtCycle`), but its expression pass checked only:

1. node/table identity;
2. exact operand count for fixed-arity expression kinds; and
3. existence/kind of every listed operand and receiver.

It did not traverse expression `children` or the effective-call `receiver`
edge.  A malformed sealed candidate could therefore contain either a child
cycle or a multi-node receiver cycle.  CodeGen, dump, or a public AST visitor
would then be able to recurse indefinitely after the graph had passed the
structural verifier.

## Repair

`as_ast_verifier.cpp` now has `VisitExprCycle`, using the same white/gray/black
DFS discipline as the statement verifier.  It traverses both `children` and
the `receiver` edge and emits the stable result:

```text
category = asAST_VERIFY_INVALID_CHILD
detail   = expr-cycle
```

The pass runs only after the existing per-expression identity, type, operand,
and receiver validity checks.  That ordering preserves the more precise
existing diagnostics for dangling or wrong-kind IDs.

Two new regression cases in
`AngelscriptNativeCanonicalASTVerifierTests.cpp` cover independent malformed
graphs:

| Test | Invalid graph |
| --- | --- |
| `RejectsExprCycle` | `UnaryA.children = [UnaryB]`, `UnaryB.children = [UnaryA]` |
| `RejectsExprReceiverCycle` | `CallA.receiver = CallB`, `CallB.receiver = CallA` |

Expression *multi-owner* rejection is deliberately not included in this
small repair.  `as_sema_expr.cpp` currently has source-range based
`FindExistingExpr` reuse to make repeated Parser→Sema callbacks idempotent.
Before making every multi-parent expression invalid, the migration must define
which reuse is transient callback deduplication and which becomes a durable
sealed DAG edge.  That remains a task 13.5 / Sema-authority follow-up, not a
reason to allow cycles.

## TDD evidence

| Stage | Command / label | Result |
| --- | --- | --- |
| Red build | `RunBuild.ps1 -NoXGE` `cta-verifier-expr-cycle-red-build` | success |
| First red invocation | `cta-verifier-expr-cycle-red` | invalid test selector: CQTest path also contains `FCanonicalASTVerifierTests`; no test ran |
| Effective red | `cta-verifier-expr-cycle-red-real` | **0/1 pass**, child-cycle case failed at the intended assertion |
| Effective red (both) | `cta-verifier-expr-cycle-red-both` | **3/5 pass, 2/5 fail**; only the two new cycle cases failed |
| Green build | `RunBuild.ps1 -NoXGE` `cta-verifier-expr-cycle-green-build` | success |
| Green verifier | `cta-verifier-expr-cycle-green` | **22/22 pass, 0 fail, 0 skip** |

Saved red/green reports:

- `Saved/Tests/cta-verifier-expr-cycle-red-real/20260823_072425_810_f282ed78`
- `Saved/Tests/cta-verifier-expr-cycle-red-both/20260823_072536_631_199ba38e`
- `Saved/Tests/cta-verifier-expr-cycle-green/20260823_072654_268_41fa3aa8`

## Frontend baseline drift discovered during regression

The broad Frontend run initially reported five failures unrelated to the
expression verifier.  The failures all asserted that `interface` and
`typedef` remained rejected at the tokenizer/parser boundary.

The active worktree already changed `as_tokendef.h` to classify both spellings
as `ttInterface` / `ttTypedef`, and `as_parser.cpp` now dispatches to
`ParseInterface()` / `ParseTypedef()`.  The code was therefore ahead of the
older baseline tests, not regressing because of the verifier change.

The legacy parser tests were realigned to assert observable parser output:

- interface declaration and class implementation produce `snInterface` and
  `snClass` nodes;
- an interface method is preserved as an `snFunction` node;
- a typedef declaration produces `snTypedef`;
- tokenizer taxonomy recognizes `interface` and `typedef` as their active
  keyword tokens.

This establishes parser/tokenizer support only.  It does **not** assert that
the legacy Builder can fully register/compile every interface or typedef
program, nor does it close canonical Sema authority task 4.2 / review task
13.2.

| Stage | Command / label | Result |
| --- | --- | --- |
| Drift detection | Frontend prefix `cta-verifier-expr-cycle-frontend` | **5 failures**: stale interface/typedef rejection expectations |
| Baseline build | `RunBuild.ps1 -NoXGE` `cta-parser-keyword-baseline-align-build` | success |
| Final Frontend regression | Frontend prefix `cta-parser-keyword-baseline-align-frontend` | **268/268 pass, 0 fail, 0 skip** |

Final report:

- `Saved/Tests/cta-parser-keyword-baseline-align-frontend/20260823_072958_623_4a736b84`

## Non-claims

This attachment records a verifier hardening slice and test-baseline
alignment.  It does not mark the broad verifier firewall task closed again,
does not make the Canonical pipeline the default, and does not remove
`asCScriptNode` from the Sema input path.  Public AST V1 traversal/source
contract, Cache DTO fidelity, Sema authority, and default-codegen cutover all
remain separate live work.
