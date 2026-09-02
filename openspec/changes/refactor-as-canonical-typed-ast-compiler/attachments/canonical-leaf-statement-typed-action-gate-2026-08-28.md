# CTA-S40: Canonical leaf-statement typed-action gate

Date: 2026-08-28

Status: `GREEN`

Expression statements, returns, break, continue and fallthrough already had
low-level Canonical statement constructors, but Parser still published their
completed native nodes through `ActOnParsedStmt`. The return adapter also
owned signature-driven numeric conversion and value-object transfer cleanup.
CTA-S40 moves those semantic facts behind one pointer-free typed action while
retaining the native Parser tree and explicit LEGACY compiler.

## Action contract

`asSLeafStatementAction` carries:

- one bounded leaf kind: expression, return, break, continue or fallthrough;
- the exact callable owner DeclId;
- an optional exact already-published ExprId;
- copied half-open source offsets and recovery state.

Sema validates the callable owner, source range and expression contract before
creating a statement. Expression statements retain the supplied ExprId.
Returns freeze value-object transfer cleanup and signature-driven numeric
conversion into the Canonical graph. Break and continue freeze the nearest
active control target; fallthrough publishes its explicit transfer kind. No
Parser node, Runtime pointer, numeric TypeId, HIR, dump or replay payload
crosses the action.

## Required facts

1. A direct expression-statement action retains the exact supplied ExprId.
2. A direct return action inserts the callable-signature conversion without
   decoding `snReturn`.
3. Break and continue record the active loop/switch target selected by Sema.
4. Parser success and missing-semicolon recovery paths publish the same typed
   action without `ActOnParsedStmt`.
5. Successful parsing does not duplicate leaf statements.
6. `ActOnParsedStmt` and `ActOnStmtFromNode` physically contain no leaf
   semantic cases; their transitional callers may only find an already-
   published exact leaf statement.
7. Native `asCScriptNode`, Parser, Builder, `asCCompiler` and LEGACY remain.

## RED/GREEN implementation

The RED tests named `asSLeafStatementAction`, its bounded kind and
`ActOnLeafStatementAction` before production defined them. UBT failed with the
expected missing-type, missing-enumerator and missing-member diagnostics.

The GREEN implementation:

- adds the pointer-free leaf action and Sema entry point;
- makes `ParseExpressionStatement`, `ParseReturn`, `ParseBreak`,
  `ParseContinue` and `ParseFallthrough` publish it on success and bounded
  recovery paths;
- moves return conversion and value-object transfer cleanup out of the native
  statement adapter;
- removes all five leaf cases from `ActOnParsedStmt` and
  `ActOnStmtFromNode`;
- makes residual block/control assembly fail closed if the matching typed leaf
  action is missing.

## Encountered issues and non-claims

### Control-target construction is still transitional

Break and continue now cross no native leaf node, but their exact target is
selected from `asCSema::controlStack`. During this migration that stack is
still populated by node-based `BeginParsedControl` for while/for/foreach/
do-while/switch. CTA-S40 therefore freezes the correct current target but does
not close loop/switch construction authority. The control-header actions must
create/push their exact StmtIds before parsing their bodies in later slices.

Fallthrough is also only a leaf-kind closure. Its final next-case target and
case-order validity remain owned by switch/case finishing and must migrate with
that family; this gate does not claim complete fallthrough semantics.

### Block assembly still re-identifies leaf statements

The Parser helper returns the exact new StmtId, but `ParseStatementBlock` still
calls generic `ActOnParsedStmt` after each native child and
`InternParsedCompoundStmt` still maps the native child kind/range to the
already-published statement. Those paths no longer reconstruct leaf semantics,
but they remain native identity adapters. The next Block/If slice must carry
ordered exact child StmtIds directly and remove this lookup dependency.

These dependencies are recorded as open work. No percentage or task checkbox
here claims generic statement/control authority is complete.

## Verified evidence

- expected missing-action RED build:
  `Saved/Build/cta-s40-leaf-statement-action-red/20260828_042359_594_ed002795/RunMetadata.json`;
- GREEN implementation/test build:
  `Saved/Build/cta-s40-leaf-statement-action-build-1/20260828_042950_057_df31c8f8/RunMetadata.json`;
- focused direct action, source contract, recovery, de-duplication and control
  target tests: **17/17 PASS** at
  `Saved/Tests/cta-s40-leaf-statement-focused-1/20260828_043105_617_a0176912/RunMetadata.json`;
- full SemaAuthority: **380/380 PASS** at
  `Saved/Tests/cta-s40-sema-authority-full/20260828_043211_489_19dc3dba/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s40-secondary-gates/20260828_043254_834_fc203488/RunMetadata.json`.

No umbrella task closes: **87/125 (69.6%)** mechanical, **about 71%** weighted
implementation, **about 44%** safe default readiness and **about 88%** for the
action-only declaration/expression/statement/lifetime slice. Block/If typed
assembly is the next statement-authority milestone.
