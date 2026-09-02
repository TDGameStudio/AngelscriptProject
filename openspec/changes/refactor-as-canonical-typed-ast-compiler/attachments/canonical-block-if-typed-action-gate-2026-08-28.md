# CTA-S41 Block/If typed-action gate (2026-08-28)

## Result

CTA-S41 moves authored statement-block and `if` assembly to pointer-free
Parser-to-Sema actions. The retained native Parser still constructs
`asCScriptNode` for grammar, recovery, LEGACY compilation and differential
reference, but completed Block/If semantics are no longer reconstructed by
walking those nodes.

This is a completed vertical slice, not completion of the statement/control
umbrella. `for`, `foreach`, `while`, `do-while`, `switch` and `case` still use
bounded native-node control adapters and are the CTA-S42 critical path.

## AST-first contract

The RED build introduced the following retained tests in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`:

- `SemaBlockAndIfTypedActionsOwnExactChildrenWithoutScriptNode`;
- `ParserBlockAndIfTypedActionsPreserveOrderedNestedStatements`;
- `ParserBlockAndIfUsePointerFreeTypedActionsWithoutNodeReplay`.

They require:

- a Block action to carry exact ordered `StmtId` children rather than native
  child pointers;
- local declaration-sequence carriers to be named explicitly and flattened
  only by Sema;
- an If action to carry the exact condition `ExprId` and exact then/else
  `StmtId` identities;
- nested Block/If source structure and ordering to survive construction;
- the action records to contain no `asCScriptNode*`;
- the production `ParseStatementBlock` and `ParseIf` paths not to call
  `ActOnParsedStmt`;
- completed `snStatementBlock` and `snIf` semantics not to be handled by
  `ActOnParsedStmt` or `ActOnStmtFromNode`.

Expected RED evidence:

- `Saved/Build/cta-s41-block-if-action-red/20260828_044017_644_ac43e42f/RunMetadata.json`;
- failure reason: the two typed action records and their Sema entry points did
  not yet exist.

## Implementation

### Pointer-free actions

`as_sema.h` adds:

- `asSBlockStatementAction`: callable owner, ordered child IDs, explicit local
  declaration-sequence IDs, copied half-open offsets and recovery state;
- `asSIfStatementAction`: callable owner, exact condition/then/else IDs,
  copied half-open offsets and recovery state.

`asCSema::ActOnBlockStatementAction` validates ownership and ranges, flattens
only explicitly listed local-declaration carriers, relinquishes their
temporary ownership edges, and creates the final ordered Block.

`asCSema::ActOnIfStatementAction` validates the owner/range/condition and
branch ownership, permits a missing then branch only on a recovery action, and
publishes the exact If through `ActOnIfStmt`.

### Parser-local construction identity

`asCParser` adds a short-lived native-node-to-`StmtId` table. The pointer never
crosses the typed Sema boundary; it is only Parser construction state used to
connect an already-published typed child into an enclosing typed action.

Leaf statement actions and local declaration completion bind their exact
returned IDs. `ParseStatementBlock` collects those IDs in source order and
publishes one Block action. `ParseIf` publishes one If action from the exact
condition and exact branch identities. Function and lambda body actions now
attach the exact Parser-bound Block identity.

### Retained transition for unfinished controls

The old loop/switch adapters publish a control stub before parsing their body.
The stub start coordinate is stable but its end coordinate is not. Until those
families get typed actions, `ParseStatement` binds the already-published
control ID through the unique `(kind, owner, file, begin)` identity. This does
not replay the control semantics, but it remains a native-adapter dependency
and must be deleted by CTA-S42.

`StmtKindForNode` and `InternParsedCompoundStmt` still contain Block/If kind or
identity routing used by transitional native compound handling. The semantic
`case snStatementBlock` / `case snIf` branches are absent from
`ActOnParsedStmt` and `ActOnStmtFromNode`; the remaining mappings are not being
reported as physical removal of every native-kind reference.

## Regression found and repaired

The first full SemaAuthority run produced **368/383 PASS**, with 15 failures
concentrated in loops, foreach, switch and one local/for recovery case:

- `Saved/Tests/cta-s41-sema-authority-full-1/20260828_045019_544_b56efd19/RunMetadata.json`.

The diagnostic was `statement-action-identity-missing`. Root cause was the
old control adapter's early stub range: its end did not match the completed
Parser node after body parsing. The transition lookup was narrowed to a unique
kind/owner/file/start identity. The 15-case recheck and the full suite then
passed.

This lookup is intentionally not generalized into a durable identity model.
It exists only for unfinished control actions and is a deletion requirement
for CTA-S42.

## Final evidence

- GREEN implementation build:
  `Saved/Build/cta-s41-block-if-action-build-1/20260828_044650_219_0abe8008/RunMetadata.json`;
- focused Block/If action and source-contract gate: **8/8 PASS**:
  `Saved/Tests/cta-s41-block-if-focused-1/20260828_044906_752_d3f227de/RunMetadata.json`;
- repair build:
  `Saved/Build/cta-s41-control-identity-build-2/20260828_045753_104_779a640c/RunMetadata.json`;
- 15 failed-control regression recheck: **15/15 PASS**:
  `Saved/Tests/cta-s41-regression-recheck-2/20260828_045823_738_4a97ef96/RunMetadata.json`;
- final SemaAuthority: **383/383 PASS**:
  `Saved/Tests/cta-s41-sema-authority-full-2/20260828_045902_938_7e975366/RunMetadata.json`;
- ProductionCodeGen **114**, Canonical Semantics **12** and retained native
  ScriptNode **32**: combined **158/158 PASS**:
  `Saved/Tests/cta-s41-secondary-gates/20260828_045948_830_f9ca48a3/RunMetadata.json`.

Both parent/plugin `git diff --check` pass, reporting only existing line-ending
conversion warnings. Strict OpenSpec validation is recorded after this
attachment and the progress records are updated.

## Open issues after CTA-S41

1. `for`, `foreach`, `while`, `do-while`, `switch` and `case` still cross
   `BeginParsedControl` / `ActOnParsedStmt` native-node adapters.
2. Their transfer-target phases and lifetime/cleanup edges are not yet fully
   action-only.
3. The start-coordinate identity bridge must disappear when those typed
   actions land.
4. `recovered` is a bounded construction/recovery signal; Block does not yet
   persist it as a durable public AST property.
5. Complete UE `All`, StaticJIT, Standalone Release and default-cutover matrices
   were not rerun for this focused slice.

## Progress effect

No umbrella checkbox in `tasks.md` is fully satisfied, so mechanical progress
remains **87/125 (69.6%)**. Weighted implementation advances conservatively to
**about 72%**, safe default-CANONICAL readiness to **about 45%**, and the
action-only declaration/expression/statement/lifetime Sema estimate to **about
91%**. The default remains LEGACY.
