# Canonical loop/foreach typed-action gate — 2026-08-28

## Outcome

CTA-S42 has completed the loop portion of the control-statement migration.
`while`, `do-while`, `for` and `foreach` now publish Canonical semantics through
pointer-free two-phase Parser-to-Sema actions. The native AngelScript AST is
still built and retained for syntax, recovery, LEGACY compilation, reference
and differential tests; it is no longer the semantic input for these four
CANONICAL statement families.

This card does **not** close CTA-S42 as a whole. `switch/case/default` still use
the bounded native adapter and the temporary kind/owner/file/start identity
bridge. Lifetime/cleanup and backend breadth remain separate gates.

## Architecture now implemented

```text
Parser recognizes complete control header
  -> asSControlStatementHeaderAction
  -> Sema creates exact While/DoWhile/For/ForEach StmtId
  -> Sema pushes that exact identity before body parsing
  -> break/continue actions freeze the same target StmtId
  -> Parser finishes nested expressions/statements as exact IDs
  -> typed loop finish action fills the original StmtId
  -> full source range replaces the bounded header range
  -> Sema pops only the control identity it owns
```

The header range and completed range are deliberately different. The AST
Context therefore exposes a Seal-protected `SetStmtRange`: a control target
must exist before its body, but its final half-open authored range is only
known after that body. This is construction-time mutation inside one private
candidate AST, not mutation of a sealed or published snapshot.

## `while` / `do-while`

`asSWhileStatementAction` carries the exact control, callable owner, condition
ExprId, body StmtId, copied full range and recovery state. Sema validates the
kind/owner/components, fills that exact header, marks loop/body safe points and
pops the owned stack entry. If syntax fails before any body can be entered,
recovery may publish one bounded non-pushed loop without disturbing an
enclosing control.

The `snWhile` and `snDoWhile` semantic cases are physically absent from both
`ActOnParsedStmt` and `ActOnStmtFromNode`.

## `for`

`asSForStatementAction` carries:

- the exact pre-published control StmtId and callable owner;
- the exact optional init StmtId and condition ExprId;
- every increment ExprId in authored order;
- the exact body StmtId, full range and recovery fact.

Sema constructs the increment phase. One increment remains that exact ExprId;
multiple increments become one ordered `SequenceExpr`, wrapped by the named
increment ExprStmt phase. Parser does not rediscover the phase by walking the
completed `snFor` tree. `ActOnForStmtFromNode` and its native token-span helpers
have been physically removed.

## `foreach`

`ParseForeachVariable` now binds the StmtId returned by
`ActOnForeachVariableAction` back to the exact native declaration node in
Parser-local construction state. `asSForeachStatementAction` then carries the
exact value/key declaration statements, range ExprId, body StmtId and control
identity. Sema keeps ownership of protocol resolution, single-evaluation
receiver construction, generated iterator phases and cleanup.

An unsupported range protocol still fails closed through the existing
syntax-shaped diagnostic graph. It does not fall back to native-node semantic
replay. The `snForEach` semantic cases are physically absent from
`ActOnParsedStmt` and `ActOnStmtFromNode`.

## TDD and verification evidence

### `while` / `do-while`

- expected missing-contract RED:
  `Saved/Build/cta-s42-while-action-red/20260828_053016_858_f2f2fab5/RunMetadata.json`;
- first GREEN build attempt timed out at 180 seconds after the public AST
  Context header triggered 168 build actions; no compiler error was reported:
  `Saved/Build/cta-s42-while-action-build-1/20260828_053631_089_09ecd785/RunMetadata.json`;
- successful build with a 600-second budget:
  `Saved/Build/cta-s42-while-action-build-2/20260828_054112_107_f28ac6b7/RunMetadata.json`;
- focused **12/12 PASS**:
  `Saved/Tests/cta-s42-while-action-focused-1/20260828_054604_237_009e5bb5/RunMetadata.json`;
- complete SemaAuthority **386/386 PASS**:
  `Saved/Tests/cta-s42-while-sema-authority-full-1/20260828_054722_598_64d3d3ad/RunMetadata.json`.

The timed-out build is classified as an environment/build-budget issue caused
by broad header invalidation, not as a product compile failure. It was resolved
only by using the already-supported longer timeout; no source workaround or
test weakening was applied.

### `for` / `foreach`

- expected missing-contract RED build:
  `Saved/Build/cta-s42-for-foreach-action-red/20260828_055547_410_3f51e041/RunMetadata.json`;
- GREEN build:
  `Saved/Build/cta-s42-for-foreach-action-build-1/20260828_060448_749_9f0f0e8c/RunMetadata.json`;
- new exact-action/source-boundary tests **3/3 PASS**:
  `Saved/Tests/cta-s42-for-foreach-action-focused-new-1/20260828_060602_630_bf80970c/RunMetadata.json`;
- existing error-recovery/body/overload/target/multi-increment regression set
  **10/10 PASS**:
  `Saved/Tests/cta-s42-for-foreach-action-regression-1/20260828_060644_295_663d53e7/RunMetadata.json`;
- complete SemaAuthority **389/389 PASS**:
  `Saved/Tests/cta-s42-for-foreach-sema-authority-full-1/20260828_060728_779_f3a5e9a7/RunMetadata.json`.

## Problems found and decisions

1. **A header identity cannot use its final range as its lookup key.** The body
   has not been parsed yet. The exact returned StmtId is now the authority and
   the private range is expanded at finish time.
2. **Recovery must not poison an enclosing control stack.** Every typed finish
   failure pops only when its exact control is the current top; a pre-header
   recovery statement is never pushed.
3. **`for` increments are not one syntax child.** Parser passes the ordered
   exact expression IDs; Sema alone authors the SequenceExpr and named phase.
4. **A foreach variable action was being discarded.** Its returned StmtId is
   now bound into Parser-local construction state so the loop action never
   scans a declaration node to rediscover it.
5. **The existing foreach protocol lowering remains useful.** The typed finish
   validates and routes exact IDs into that Sema-owned lowering; it does not
   duplicate the protocol or move overload/lifetime decisions into Parser.

## Progress and remaining boundary

No umbrella `tasks.md` row is truthfully complete, so the mechanical count
remains **87/125 (69.6%)**. The dependency/risk-weighted implementation estimate
advances from about 72% to **about 73%**; safe default-cutover readiness is
**about 46%**; the Parser-to-Sema action-only authority slice is **about 95%**.

The next control task is typed `switch/case/default` construction, including
ordered exact case identities and fallthrough-to-next-case wiring. Only after
that may the temporary start-coordinate identity bridge and remaining generic
control replay cases be deleted. The compiler default remains LEGACY.
