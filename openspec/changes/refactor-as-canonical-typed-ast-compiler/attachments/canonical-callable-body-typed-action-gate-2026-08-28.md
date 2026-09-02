# CTA-S39: Canonical callable-body typed-action gate

Date: 2026-08-28

Status: `GREEN`

Function and lambda declarations already owned typed identities, signatures,
parameters and traits, and statement parsing already produced a Canonical
top-level Block. The final attachment still crossed
`ActOnFunctionBodyFromNode`, which searched or reconstructed the block from a
completed native body. CTA-S39 replaces that last declaration-level body
adapter without deleting the native AST/compiler or LEGACY path.

## Action contract

`asSFunctionBodyAction` carries:

- the exact callable DeclId;
- the exact already-published Block StmtId;
- copied half-open body offsets and recovery state.

Sema requires a function/method/constructor/destructor/mixin owner, a
function-owned Block, and exact equality between the Block range and copied
source range. It sets the body and function-entry safe-point role, records
lambda captures, makes an exact repeat idempotent and rejects conflicting body
rebinding. No Parser node, Runtime pointer, numeric TypeId, HIR, dump or replay
payload crosses the action.

During statement-family migration Parser obtains the exact Block ID through
`FindStatementActionIdentity`, which accepts only one exact
kind/owner/full-range match. This is a pointer-free identity lookup, not a
semantic node decoder.

## Required facts

1. A direct action attaches exactly the supplied function-owned Block without
   any native script node.
2. An identical repeat is idempotent; a different body cannot replace the
   existing declaration body.
3. Ordinary functions and lambdas both call the same typed body action.
4. Nested return/control statements cannot steal the callable body.
5. `ActOnFunctionBodyFromNode` and its `AttachParsedFunctionBody` helper are
   physically absent from production.
6. Native `ParseFunction`, `ParseLambda`, `ParseStatementBlock`,
   `asCScriptNode`, Builder, `asCCompiler` and LEGACY remain.

## RED/GREEN implementation

The RED test named the new action and API before production defined them and
failed with the expected missing-type/API compiler errors.

The GREEN implementation adds the exact action and pointer-free identity
lookup, updates both callable Parser paths, and deletes the completed-body node
adapter/helper. Direct action, source-contract, nested-body and lambda identity
tests pass.

## Encountered issue and non-claim

The body Block already existed before `ActOnFunctionBodyFromNode` ran, but the
old helper could fall back to `InternParsedCompoundStmt`. Thus body attachment
was also a latent semantic reconstruction route. The new action fails if the
exact Block action did not run; it never asks declaration Sema to rebuild it.

This does not yet remove generic statement replay. `ActOnParsedStmt`,
`ActOnStmtFromNode`, `ActOnForStmtFromNode`, `InternParsedChildStmt` and
`InternParsedCompoundStmt` still create/assemble statement and control
semantics from native nodes. The identity lookup is explicitly transitional
until Parser directly receives StmtIds from typed return/expression/block/
control/transfer actions. No percentage or gate here claims that statement
authority is closed.

## Verified evidence

- expected missing-action RED build:
  `Saved/Build/cta-s39-callable-body-action-red/20260828_040227_654_1cfcbe29/RunMetadata.json`;
- GREEN implementation/test build:
  `Saved/Build/cta-s39-callable-body-action-build-1/20260828_040338_590_657cee75/RunMetadata.json`;
- focused direct body, function/lambda source contract, nested body ownership
  and lambda identity: **5/5 PASS** at
  `Saved/Tests/cta-s39-callable-body-focused-1/20260828_040415_969_e7b03368/RunMetadata.json`;
- full SemaAuthority: **377/377 PASS** at
  `Saved/Tests/cta-s39-sema-authority-full/20260828_040448_487_74f276ad/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s39-secondary-gates/20260828_040528_980_773ab9fc/RunMetadata.json`.

No umbrella task closes: **87/125 (69.6%)** mechanical, **about 70%** weighted
implementation, **about 43%** safe default readiness and **about 85%** for the
action-only declaration/expression/statement/lifetime slice. Generic statement,
control and lifetime adapters remain the next critical authority closure.
