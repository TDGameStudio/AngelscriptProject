# CTA-S38: Canonical local-variable declarator typed-action gate

Date: 2026-08-28

Status: `GREEN`

Local variable headers already crossed `asSVariableHeaderAction`, but each
optional initializer still crossed `ActOnLocalVariableDeclaratorFromNode`.
Statement Sema then interpreted the retained native initializer and recursively
re-entered `ActOnExprFromNode`. CTA-S38 removes that declaration/statement
authority while retaining native `ParseDeclaration`, `asCScriptNode`, Builder,
`asCCompiler` and the explicit LEGACY pipeline.

## Action contract

`asSLocalVariableDeclaratorAction` carries only copied or Canonical identities:

- the exact local VarDecl ID;
- no initializer, one exact expression, or direct construction;
- ordered exact argument ExprIds for direct construction;
- copied half-open declarator offsets and recovery state.

It carries no Parser/token/source-buffer pointer, native AST node, Runtime
object pointer, numeric Runtime TypeId, HIR object, dump or replay payload.
Sema validates the owner/source/identity contract before mutation and owns
DeclStmt publication, exact init attachment, assignment effects and default
construction. The enclosing source declaration is still finalized through the
pointer-free `ActOnLocalVariableDeclarationAction`, including `for` initializer
declaration sequences.

## Required facts

1. A direct action binds an already-published Binary expression to the exact
   local VarDecl and emits DeclStmt followed by its initialization effect.
2. Parser `40 + 1` initialization retains the exact Binary root rather than
   reconstructing it from native nodes.
3. Comma-separated locals and `for` initializer declarators remain distinct,
   ordered and executable through CANONICAL.
4. No-initializer locals keep the existing typed default-construction route;
   parenthesized construction carries ordered exact argument identities.
5. Invalid/missing expression identities and rebinding fail before statement
   publication. The Parser performs one action publication per declarator.
6. `ActOnLocalVariableDeclaratorFromNode` is physically absent from production,
   while the original AngelScript AST/compiler and LEGACY path remain.

## RED/GREEN implementation

The RED tests introduced `asSLocalVariableDeclaratorAction` and
`ActOnLocalVariableDeclaratorAction` before production defined them, producing
the expected missing-type/API compile failure.

Parser now converts each local declarator into the typed action. Ordinary and
initializer-list forms use exactly one already-published root; direct
construction uses the ordered argument action list and rejects named arguments
for this grammar. Sema validates every ID, builds a Construct only for the
explicit direct form, attaches the exact init to the local declaration and
emits the existing typed local statement sequence. Existing inits are rejected
before Construct or statement mutation.

The old node adapter and its recursive `ActOnExprFromNode` calls are physically
deleted. This does not remove native declarations or their syntax tree.

## Encountered issues and non-claims

The former local adapter had two semantic routes: ordinary expressions were
re-read as a completed node, while parenthesized construction walked native
arguments and recreated each expression. That meant expression-level generic
replay could appear closed while local declaration Sema still reconstructed
the same semantics. The new action makes the boundary explicit and exact.

This slice does not claim complete value-object lifetime/cleanup lowering.
No-initializer locals still use the existing Canonical default-construction
plan, and initialized locals still emit the existing typed assignment effect.
Destructor/cleanup placement across return, break, continue, switch and
exceptional exits remains a separate statement/lifetime and CodeGen gate. It
must fail closed where the sealed cleanup plan is incomplete.

## Verified evidence

- expected missing-action RED build:
  `Saved/Build/cta-s38-local-variable-declarator-action-red/20260828_035341_491_57ad8492/RunMetadata.json`;
- GREEN implementation/test build:
  `Saved/Build/cta-s38-local-variable-declarator-action-build-1/20260828_035511_594_854d28f9/RunMetadata.json`;
- focused direct action, Parser exact identity, comma/`for` execution, source
  contract and existing typed local statement route: **5/5 PASS** at
  `Saved/Tests/cta-s38-local-variable-declarator-focused-1/20260828_035549_358_72281f8f/RunMetadata.json`;
- full SemaAuthority: **376/376 PASS** at
  `Saved/Tests/cta-s38-sema-authority-full/20260828_035621_161_913fc474/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s38-secondary-gates/20260828_035704_811_146d04ff/RunMetadata.json`.

No umbrella task row closes, so mechanical progress remains **87/125
(69.6%)**. The medium declaration/statement-authority closure advances the
weighted implementation estimate to **about 70%**, safe default readiness to
**about 42%**, and the action-only declaration/expression/statement/lifetime
slice to **about 83%**. Function/lambda body assembly plus generic statement,
control-transfer and lifetime node adapters remain on the authority critical
path.
