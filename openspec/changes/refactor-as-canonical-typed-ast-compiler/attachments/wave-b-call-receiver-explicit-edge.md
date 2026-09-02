# Wave B — explicit CALL receiver edge

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Date: 2026-08-23. Scope: canonical AST semantic facts and CANONICAL CodeGen.

## Problem

`asCExpr::literalBits` carried two unrelated meanings:

1. the exact scalar payload of integer, boolean, and floating literals; and
2. for `CALL`, the ID of the implicit member-call receiver.

That overloaded a value field with a graph edge. A downstream consumer could not
tell whether a non-zero `literalBits` value was a literal constant or an
expression reference without depending on producer-specific convention. It also
made HIR/LLVM-style lowering need to reconstruct an implicit relation instead of
reading a typed AST fact.

## Implemented canonical model

`asCExpr` now owns a distinct `asASTExprId receiver` field.

```text
before: CALL.literalBits = receiver-expression-ID
after:  CALL.receiver    = receiver-expression-ID
        CALL.literalBits = literal payload only
```

`asCASTContext::SetExprReceiver(call, receiver)` is the only construction API
for this relation. Before seal it rejects a missing receiver, a non-`CALL`
target, and a self-reference; after seal it rejects all mutation. The AST
verifier independently requires any receiver edge to originate at `CALL`, refer
to a live expression in the same snapshot, and not self-reference.

The semantic and generation consumers are migrated together:

- `asCSema::ActOnCallExpr` records the implicit receiver through
  `SetExprReceiver` for both resolved and unresolved calls.
- postfix-call continuation and lambda capture discovery read `expr->receiver`.
- `asCASTDump` renders `receiver=<expr-id>` from the explicit edge.
- `asCBytecodeCodeGen::EmitCall` uses the explicit edge for the receiver
  conversion skip, reuse check, and receiver evaluation.

This does **not** alter ordinary argument ordering, receiver ABI layout, member
resolution, default compiler selection, or the still-limited CANONICAL CodeGen
feature surface. It only replaces an implicit AST encoding with an explicit,
sealed semantic relation.

## TDD and verification

RED first: `CallReceiverUsesExplicitExpressionEdge` was added to
`AngelscriptNativeCanonicalASTContextTests.cpp`. It requires the public
construction API, confirms `CALL.receiver` retains the receiver ID while
`literalBits == 0`, verifies the graph, seals it, and proves post-seal mutation
is rejected. The expected missing-feature build failure was recorded at:

```text
Saved/Build/cta-call-receiver-red-build/20260823_025251_649_085ba315
```

The failure was exactly `asCASTContext::SetExprReceiver` and
`asCExpr::receiver` missing, so the test could not pass against the former
overloaded representation.

GREEN evidence:

| Verification | Result | Evidence |
| --- | --- | --- |
| Editor build | PASS | `Saved/Build/cta-call-receiver-green-build/20260823_025437_651_08b3fcbd` |
| Explicit-edge test | `1/1 PASS` | `Saved/Tests/cta-call-receiver-focused-green/20260823_025616_971_8c75561e` |
| CANONICAL ProductionCodeGen regression | `53/53 PASS` | `Saved/Tests/cta-call-receiver-production-codegen/20260823_025658_211_51837aa7` |
| Native Compiler regression | `518/518 PASS` | `Saved/Tests/cta-call-receiver-compiler/20260823_025851_887_5aab6149` |

The first focused invocation omitted the CQTest class segment from the Automation
path and therefore found zero tests. The corrected, fully qualified prefix is:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Context.FCanonicalASTContextTests.CallReceiverUsesExplicitExpressionEdge" -NoXGE -Label cta-call-receiver-focused-green -TimeoutMs 600000
```

The `aqProf`, `VtuneApi`, and pre-existing native-fixture C5038/C4191 warnings
seen in command output are unrelated to this change; all commands above ended
with exit code zero for their green runs.
