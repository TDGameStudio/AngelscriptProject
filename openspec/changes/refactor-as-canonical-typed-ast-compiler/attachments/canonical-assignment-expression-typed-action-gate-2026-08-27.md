# Canonical assignment-expression typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-27 — replace complete CANONICAL `snAssignment` replay with one owned, pointer-free Parser→Sema action |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Test source | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Direct fixture | `SemaAssignExprActionOwnsOperandsOperatorAndRangeWithoutScriptNode`, source `x += 3` |
| Parser fixture | `ParserAssignExprActionBindsExactCompositeIdentityWithoutNodeReplay`, source `int Entry(int i) { i += 2; return i; }` |
| Constructed AST facts | exact `AssignExpr`, exact left/right child identities, owned `+=` operator spelling and complete half-open source range |
| Architecture fact | action owns two build-local `ExprId`s, an `asCString` operator and offsets; it contains no `asCScriptNode*`; complete assignment Sema no longer decodes `snAssignment` children |
| Expected RED | action API absent, then the Parser boundary still uses generic `ActOnParsedExpr` instead of publishing through the dedicated action |
| Downstream gate | complete SemaAuthority, ProductionCodeGen, complete Canonical Semantics and retained native ScriptNode shape |

## Target contract

Parser continues to construct the independent native `snAssignment` tree for
explicit LEGACY compilation, syntax/error recovery, reference tests and
rollback. For CANONICAL semantics, a complete three-child assignment must
instead resolve the exact already-published left and right expression
identities, copy the operator spelling and complete range into
`asSAssignExprAction`, call `asCSema::ActOnAssignExprAction`, and bind the
returned composite identity to the native node.

The action contains only ASTContext-local construction IDs, owned text and
offsets. It contains no Parser node, token-buffer pointer, Engine pointer,
Runtime pointer or numeric TypeId. The IDs must not escape the current
semantic build.

Sema validates source preparation, range, operand ownership and the complete
assignment-operator spelling before delegating to the existing typed
assignment builder. Complete three-child `snAssignment` cases in both Sema
node-entry switches are now identity-only. If the Parser action did not run,
they fail closed with `assignment-expression-action-missing`. A one-child
assignment grammar wrapper may continue to return its already-built child
identity. A two-child/incomplete assignment may not synthesize semantics.

## Permanent tests

1. `SemaAssignExprActionOwnsOperandsOperatorAndRangeWithoutScriptNode`
   constructs left and right expressions through direct Sema APIs, invokes
   only the pointer-free action, and proves exact children, owned `+=`
   spelling and the source range.
2. `ParserAssignExprActionBindsExactCompositeIdentityWithoutNodeReplay`
   parses a real function, proves the retained native `snAssignment` still
   carries left/operator/right children, then requires exact lookup to return
   an `AssignExpr` with `DeclRefExpr` and `IntegerLiteral` children, `+=` and
   the exact composite range.
3. The Parser fixture also isolates the source text of `ParseAssignment` and
   requires `BindAssignExprAction(` while forbidding `ActOnParsedExpr(` in
   that production grammar routine. This architecture assertion is required
   because the old generic replay could produce an apparently valid exact
   assignment identity and otherwise mask a missing typed-action boundary.
4. Complete `CanonicalAST.Semantics` retains isolated LEGACY/CANONICAL
   observable coverage for assignment and property compound-assignment
   execution, including single-evaluation behavior.

## RED and issue evidence

### Missing action contract

The initial test-only build failed only because `asSAssignExprAction` and
`asCSema::ActOnAssignExprAction` did not exist:

`Saved/Build/cta-s27-assignment-action-red/20260827_230010_667_f07a63d7/RunMetadata.json`.

This is the direct API RED. No production assignment lowering changed before
the failure was captured.

### CTA-S27-I1 — generic node replay masked the missing Parser action

After the action API existed but before `ParseAssignment` was wired, the
Parser fixture failed **0/1**:

`Saved/Tests/cta-s27-parser-assignment-action-red/20260827_230209_312_b8a5ba95/RunMetadata.json`.

The old generic `ActOnParsedExpr(node, script)` route still replayed the
three-child native node and could publish an exact-looking assignment. A test
that asserted only the resulting AST identity would therefore have gone green
without proving the required architecture. The permanent fixture now checks
both the exact AST facts and the isolated production source boundary. This is
a test-gate defect found by the slice, not permission to accept source-string
inspection as the only semantic proof: the direct action, exact AST and
downstream execution gates remain mandatory.

### Recovery publication

`ParseAssignment` is right-recursive. If a later delimiter/error is reported
after the recursive right-hand assignment has already published its exact
identity, the outer action is attempted whenever left/operator/right are all
complete. Missing operands or operator still fail closed; Sema never recovers
assignment semantics by walking the parent node.

## Implemented boundary

- `as_sema.h` defines `asSAssignExprAction` and the public Sema entry point;
- `as_sema_expr.cpp` validates action-owned range, operand IDs and the
  assignment spelling set, then applies typed assignment semantics;
- `as_parser.cpp` builds the action from exact operands, publishes it on the
  complete and recoverable-complete routes, and contains no generic expression
  replay inside `ParseAssignment`;
- `as_sema_decl.cpp` and `as_sema_expr.cpp` treat complete native assignment
  nodes as identity-only and emit `assignment-expression-action-missing` if
  the action boundary was skipped;
- native `CreateNode(snAssignment)` remains intentionally positive in three
  grammar/probe sites, preserving the independent native AST.

## GREEN evidence

- direct action API build: **PASS** at
  `Saved/Build/cta-s27-assignment-action-api-green-build/20260827_230109_544_4cc37a30/RunMetadata.json`;
- direct pointer-free action: **1/1 PASS** at
  `Saved/Tests/cta-s27-assignment-action-api-green/20260827_230136_687_f4ec97bc/RunMetadata.json`;
- Parser action build: **PASS** at
  `Saved/Build/cta-s27-parser-assignment-action-green-build/20260827_230411_766_8a7435a4/RunMetadata.json`;
- Parser exact composite/action boundary: **1/1 PASS** at
  `Saved/Tests/cta-s27-parser-assignment-action-green/20260827_230424_696_4ecde666/RunMetadata.json`;
- complete SemaAuthority: **350/350 PASS** at
  `Saved/Tests/cta-s27-sema-authority-check/20260827_230459_102_b56905d5/RunMetadata.json`;
- ProductionCodeGen: **114/114 PASS** at
  `Saved/Tests/cta-s27-assignment-production-codegen-green/20260827_231159_924_e21bcfaf/RunMetadata.json`;
- complete Canonical Semantics: **12/12 PASS** at
  `Saved/Tests/cta-s27-assignment-semantics-green/20260827_231236_142_aadc796d/RunMetadata.json`;
- retained native ScriptNode shape: **32/32 PASS** at
  `Saved/Tests/cta-s27-assignment-scriptnode-green/20260827_231308_343_eec0bca2/RunMetadata.json`.

The live Parser source now contains **12** `ActOnParsedExpr` calls, down from
**14** before this slice and **18** before the conditional slice.
`ParseAssignment` contains none and contains two action-publication attempts
for complete and recoverable-complete paths. Native
`CreateNode(snAssignment)` remains **3**, intentionally.

## Explicit non-claims

- This slice migrates the outer assignment composite only. Property/index
  mutation target construction and their single-evaluation plans still depend
  on the current member/index/expression-term routes until those dedicated
  actions migrate.
- The action validates and preserves every grammar assignment spelling, but
  the new focused fixtures use `+=`; this slice does not claim a new exhaustive
  VM proof for every compound operator beyond the existing language and
  Canonical Semantics suites.
- Binary/logical/unary/call/member/index/cast/construct and init-list families
  still have node-replay work.
- Statement/control/function-body/default/initializer/lifetime adapters remain
  open.
- Builder Runtime-shell narrowing and complete full-language CodeGen remain
  open.
- Tasks 4.2, 5.2, 5.4, 10.3, 10.6 and 13.2 remain open.
- Compiler default remains LEGACY; Cache V2 remains default-disabled; native
  AST/Parser/Builder/Compiler and explicit LEGACY remain intentionally
  retained.

