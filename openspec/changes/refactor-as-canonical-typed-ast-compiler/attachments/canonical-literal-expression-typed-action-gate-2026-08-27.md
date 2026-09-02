# Canonical literal-expression typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-24 — replace CANONICAL literal token/node decoding with one owned, pointer-free Parser→Sema action |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | direct action over `42 true 1.5f 2.5 nullptr "line\\n"`, followed by a real Parser source fixture that proves the retained native literal node already has an exact `ExprId` |
| Sealed/constructed AST facts | integer/bool/float32/float64/null/string kinds, exact scalar values, float-vs-double canonical types, decoded string bytes and half-open source ranges |
| Architecture fact | the action owns token kind, spelling and offsets; it contains no `asCScriptNode*`; Parser binds the returned `ExprId` while still returning the native syntax tree |
| Expected RED | the desired `asSLiteralExprAction` and `asCSema::ActOnLiteralExprAction` API do not exist |
| Downstream gate | complete SemaAuthority plus ProductionCodeGen literal execution/string-factory coverage and retained native ScriptNode shape |

## Target contract

Parser recognizes one literal token and copies only its token kind, exact raw
spelling and half-open processed-source offsets into a short-lived action.
Sema prepares the source session, validates the action family, decodes the
owned spelling and creates the exact Canonical Expr. The action does not retain
Runtime pointers, numeric TypeIds, AST snapshot IDs from another context, or a
Parser node.

After the action returns, Parser binds the resulting `ExprId` to the retained
native literal node for the duration of the same build. Parent expression
construction may retrieve that identity but must not inspect the literal
node's token or children. A missing identity fails closed with a stable
diagnostic instead of re-decoding `snConstant`.

The native `snConstant` path remains intact for explicit LEGACY compilation,
syntax/recovery tests, reference and rollback. This slice removes only
CANONICAL semantic reconstruction from that node.

## Permanent tests

1. `SemaLiteralSyntaxActionOwnsTokenMeaningWithoutScriptNode` calls the
   action without creating any `asCScriptNode` and asserts the exact
   AST facts listed above.
2. `ParserLiteralActionBindsExactExprIdentityBeforeParentReplay` parses a real
   function body containing `return 41;`, confirms that the independent native
   `snConstant` node still exists, and requires
   `FindParsedExpressionIdentity` to return the exact IntegerLiteral identity,
   value and source range immediately after parsing.
3. Existing compile/seal and ProductionCodeGen literal tests remain downstream
   behavioral gates; they are not substituted by source-text assertions.

## RED evidence

The first test-only build intentionally failed before production edits:

`Saved/Build/cta-s24-literal-action-red2/20260827_214946_391_3f1be476/RunMetadata.json`.

The remaining errors name only the missing `asSLiteralExprAction` and
`asCSema::ActOnLiteralExprAction` contract (plus dependent lambda parse errors
caused by that missing type). This is the valid compile-time RED.

An earlier test-only build also exposed a fixture mistake: the canonical AST
uses one `asAST_EXPR_FLOAT_LITERAL` kind and distinguishes float32/float64 by
canonical type; there is no `asAST_EXPR_DOUBLE_LITERAL`. The test was corrected
to assert `FloatLiteral + type=float/double`, then RED was rerun. This was a
test-design issue, not a production compiler defect.

After the pointer-free Sema API existed but before Parser wiring, the real
Parser integration test failed **0/1** with the exact missing-identity
assertion at:

`Saved/Tests/cta-s24-parser-literal-identity-red/20260827_215558_245_71d6a44a/RunMetadata.json`.

That is the runtime RED proving that a direct action API alone did not remove
Parser-side node replay.

## Implemented boundary

`asSLiteralExprAction` now owns only token kind, copied spelling, and half-open
processed-source offsets. `asCSema::ActOnLiteralExprAction` validates the
range, decodes the owned token spelling, creates the exact typed literal, and
returns its `ExprId` without accepting an `asCScriptNode*`.

`asCParser::ParseConstant()` still constructs and returns the native
`snConstant` node for LEGACY/reference/recovery use. In CANONICAL retention
mode it additionally copies the token action, calls Sema, and binds the
returned identity to that node. `ActOnExprFromNode(snConstant)` is now
identity-only: it returns the Parser-bound expression or emits the stable
`literal-expression-action-missing` diagnostic. It no longer reads token text,
token kind, or node children. The old `ActOnParsedStringLiteral` node adapter
has been deleted.

## GREEN evidence

- direct pointer-free action fixture: **1/1 PASS** at
  `Saved/Tests/cta-s24-literal-action-api-green2/20260827_215425_271_7194f31e/RunMetadata.json`;
- real Parser identity fixture: **1/1 PASS** at
  `Saved/Tests/cta-s24-parser-literal-identity-green/20260827_215855_955_e910f505/RunMetadata.json`;
- complete Canonical SemaAuthority: **344/344 PASS** at
  `Saved/Tests/cta-s24-sema-authority-green/20260827_215934_603_b7321122/RunMetadata.json`;
- retained native ScriptNode shape: **32/32 PASS** at
  `Saved/Tests/cta-s24-scriptnode-green2/20260827_220113_116_70d19cda/RunMetadata.json`;
- ProductionCodeGen: **114/114 PASS** at
  `Saved/Tests/cta-s24-production-codegen-green2/20260827_220146_628_c0c2e8ce/RunMetadata.json`;
- Runtime/Editor builds passed before both focused GREEN runs at
  `Saved/Build/cta-s24-literal-action-api-green-build/20260827_215229_934_6c9703b0/RunMetadata.json`
  and
  `Saved/Build/cta-s24-parser-literal-identity-green-build/20260827_215827_500_237f33f1/RunMetadata.json`.

The live-source scan after the change finds zero
`ActOnParsedStringLiteral`. Native `snConstant` production is intentionally
positive because the native AST is retained.

Two commands are recorded as non-evidence. The first direct-action selector
omitted the CQTest fixture-class segment and matched zero tests at
`Saved/Tests/cta-s24-literal-action-api-green/20260827_215300_322_c5869533/RunMetadata.json`.
The first ScriptNode selector similarly omitted the `Frontend` segment and
matched zero tests at
`Saved/Tests/cta-s24-scriptnode-green/20260827_220022_912_3076d676/RunMetadata.json`.
A parallel ProductionCodeGen invocation was rejected by the per-worktree
build/test lock before execution. The corrected serialized commands above are
the only GREEN evidence.

## Explicit non-claims

- Decl-ref, call, prefix/postfix, binary, assignment and conditional node
  replay remain outside this literal slice.
- Statement/control/function-body/default/initializer/lifetime adapters remain
  open.
- Builder Runtime-shell authority and complete language CodeGen are not closed.
- Compiler default remains LEGACY; Cache V2 remains default-disabled; native
  AST/Builder/Compiler and explicit LEGACY are retained.
