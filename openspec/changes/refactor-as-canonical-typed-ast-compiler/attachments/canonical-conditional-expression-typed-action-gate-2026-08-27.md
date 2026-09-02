# Canonical conditional-expression typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-26 — replace CANONICAL ternary `snCondition` replay with one owned, pointer-free composite Parser→Sema action |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Test source | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Direct fixture | `SemaConditionalExprActionOwnsOperandsAndRangeWithoutScriptNode`, source `true ? 1 : 2` |
| Parser fixture | `ParserConditionalExprActionBindsExactCompositeIdentityBeforeStatementReplay`, source `int Entry(bool b) { return b ? 1 : 2; }` |
| Constructed AST facts | exact `ConditionalExpr`, condition/then/else child identities, canonical result type and complete half-open source range |
| Architecture fact | action owns three build-local `ExprId`s and offsets; it contains no `asCScriptNode*`; complete ternary Sema no longer decodes `snCondition` children |
| Expected RED | action API absent, then Parser returns no exact identity for the complete conditional node |
| Downstream gate | complete SemaAuthority, complete Semantics, ProductionCodeGen, retained native ScriptNode shape and LEGACY/CANONICAL differential execution |

## Target contract

Parser may continue to construct the independent native `snCondition` tree for
explicit LEGACY compilation, syntax recovery, reference tests and rollback.
For CANONICAL semantics it must instead collect the exact already-built child
identities, copy the complete source range into `asSConditionalExprAction`,
call `asCSema::ActOnConditionalExprAction`, and bind the returned composite
identity to that same native node.

The action carries only condition, then-expression and else-expression
`asASTExprId`s plus half-open begin/end offsets. These IDs are ASTContext-local
construction identities. They are neither snapshot-stable nor Runtime
identities and may not cross the current semantic build. The action contains
no Parser node, token-buffer pointer, Engine pointer or Runtime numeric TypeId.

Sema validates ownership/range, performs conditional-arm conversion and result
type selection, and constructs the typed node. Complete three-child
`snCondition` Sema cases are identity-only and fail closed with
`conditional-expression-action-missing`. A one-child transparent condition
wrapper may continue to retrieve its already-built child identity; it may not
reconstruct a ternary.

## Exact identity versus recovery identity

This slice exposed that broad expression-identity recovery was unsafe for
composite construction. A parent expression and its first child may share a
section and beginning offset. In `b ? 1 : 2`, both the outer conditional and
`b` begin at the same offset. The earlier recovery key could therefore return
the child's `DeclRefExpr` while a caller believed it had found the parent.

The boundary is now explicit:

1. `FindExactParsedExpressionIdentity(node)` performs pointer-exact lookup;
2. Parser action composition uses that exact-only API and crosses only
   transparent native wrappers;
3. `FindParsedExpressionIdentity(node)` remains a recovery API, but its
   structural key is section+node-kind+offset+length;
4. distinct exact descendants under an unmigrated composite fail closed.

As each composite family migrates, its exact binding becomes the stopping
point for parent action construction. Recovery lookup must never be treated as
a semantic identity authority.

## Permanent tests

1. `SemaConditionalExprActionOwnsOperandsAndRangeWithoutScriptNode` creates
   bool/int/int child expressions through direct Sema APIs, invokes only the
   pointer-free conditional action, and proves exact children, result type and
   source range.
2. `ParserConditionalExprActionBindsExactCompositeIdentityBeforeStatementReplay`
   parses a real function, proves retained native `snCondition` still has
   three children, then requires exact-only lookup to return one
   `ConditionalExpr` with the expected child kinds and range.
3. `ParserActOnConditionalBeforeElseCloseFails` retains malformed-source
   recovery coverage and proves the action is published when all three exact
   children exist even if an enclosing call delimiter is missing.
4. `IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace` separately
   compiles and executes LEGACY and CANONICAL Engines and compares maintained
   observable behavior.

## RED and issue evidence

### Missing action contract

The initial test-only build failed because `asSConditionalExprAction` and
`asCSema::ActOnConditionalExprAction` did not exist:

`Saved/Build/cta-s26-conditional-action-red/20260827_222949_003_5cd11879/RunMetadata.json`.

### CTA-S26-I1 — range recovery produced a false parent identity

The first Parser runtime attempt failed at:

`Saved/Tests/cta-s26-parser-conditional-identity-red/20260827_223336_872_49fcc689/RunMetadata.json`.

It returned a `DeclRefExpr` for the outer conditional because the broad
section+offset fallback collided with the first leaf. This was useful diagnosis
but is not the final architecture RED: it proved the test itself used an
ambiguous recovery API.

Adding the required exact-only API first produced the intended compile RED:

`Saved/Build/cta-s26-exact-expression-identity-red/20260827_223501_537_fff1e1ef/RunMetadata.json`.

After the API existed but before Parser bound the composite, the corrected
fixture produced the real runtime RED, exact identity absent **0/1**:

`Saved/Tests/cta-s26-parser-conditional-exact-identity-red/20260827_223557_360_9d38d827/RunMetadata.json`.

### CTA-S26-I2 — action publication skipped valid exact children during recovery

The first complete SemaAuthority run was **347/348**, not green:

`Saved/Tests/cta-s26-sema-authority-green/20260827_224026_317_0837f855/RunMetadata.json`.

`ParserActOnConditionalBeforeElseCloseFails` has a missing close delimiter in
an enclosing call. All three ternary operands had already published exact
identities. The first implementation skipped the composite action on that
recovery path. Parser now attempts the action whenever all three exact child
IDs exist, while still failing closed for missing then/colon or absent
operands. The focused recovery test then passed **1/1**:

`Saved/Tests/cta-s26-conditional-recovery-green/20260827_224231_756_c01be398/RunMetadata.json`.

## Implemented boundary

- `as_sema.h` defines the pointer-free action and exact-only identity API;
- `as_sema_expr.cpp` validates IDs/range and delegates conversion/result-type
  decisions to the existing typed conditional builder;
- `as_sema.cpp` separates exact identity from structural recovery and records
  node kind/length in recovery bindings;
- `as_parser.cpp` gathers exact children, invokes the action on complete and
  recoverable-complete ternaries, and binds the returned parent identity;
- `as_sema_decl.cpp` binds exact identities for still-transitional expression
  families so later parent actions can consume them bottom-up;
- complete ternary `snCondition` replay is identity-only in both Sema entry
  switches.

The `as_sema_decl.cpp` binding is transitional plumbing, not completion of
call/cast/construct/assignment/binary/term action migration. It makes their
current typed results addressable by exact ID; those semantic results are
still constructed from native nodes until dedicated action slices land.

## GREEN evidence

- direct action API build: **PASS** at
  `Saved/Build/cta-s26-conditional-action-api-green-build/20260827_223026_104_17e95678/RunMetadata.json`;
- direct pointer-free action: **1/1 PASS** at
  `Saved/Tests/cta-s26-conditional-action-api-green/20260827_223056_456_07b78381/RunMetadata.json`;
- exact-identity API build: **PASS** at
  `Saved/Build/cta-s26-exact-expression-identity-green-build/20260827_223530_258_224f6ee5/RunMetadata.json`;
- Parser action build: **PASS** at
  `Saved/Build/cta-s26-parser-conditional-action-green-build/20260827_223920_158_b65b619d/RunMetadata.json`;
- Parser exact composite identity: **1/1 PASS** at
  `Saved/Tests/cta-s26-parser-conditional-identity-green/20260827_223948_125_383c80e4/RunMetadata.json`;
- focused recovery: **1/1 PASS** at
  `Saved/Tests/cta-s26-conditional-recovery-green/20260827_224231_756_c01be398/RunMetadata.json`;
- complete SemaAuthority: **348/348 PASS** at
  `Saved/Tests/cta-s26-sema-authority-green2/20260827_224308_159_745eddfe/RunMetadata.json`;
- exact LEGACY/CANONICAL conditional differential: **1/1 PASS** at
  `Saved/Tests/cta-s26-conditional-vm-differential-green/20260827_224400_884_dcb46998/RunMetadata.json`;
- ProductionCodeGen: **114/114 PASS** at
  `Saved/Tests/cta-s26-production-codegen-green/20260827_224437_797_e1f38af8/RunMetadata.json`;
- retained native ScriptNode shape: **32/32 PASS** at
  `Saved/Tests/cta-s26-scriptnode-green/20260827_225326_393_a5ed1d48/RunMetadata.json`;
- complete Canonical Semantics: **12/12 PASS** at
  `Saved/Tests/cta-s26-semantics-green/20260827_225402_089_520caf1e/RunMetadata.json`.

The live Parser source now contains **14** `ActOnParsedExpr` calls, down from
**18**. `ParseCondition` contains none. Native `CreateNode(snCondition)`
remains intentionally positive. Complete three-child Sema cases contain only
identity lookup and `conditional-expression-action-missing`, not semantic
reconstruction.

## Explicit non-claims

- Call/member/index, cast/construct, unary/binary/logical, assignment,
  init-list and general expr-term families still have node-replay work.
- Exact binding added for those transitional results is not their action-only
  migration.
- Statement/control/function-body/default/initializer/lifetime adapters remain
  open.
- Builder Runtime-shell narrowing and complete language CodeGen remain open.
- Tasks 4.2, 5.2, 5.4, 10.3, 10.6 and 13.2 remain open.
- Compiler default remains LEGACY; Cache V2 remains default-disabled; native
  AST/Parser/Builder/Compiler and explicit LEGACY remain intentionally
  retained.
