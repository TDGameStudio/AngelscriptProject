# Typed AST matcher/query layer and semantic ShadowDiff — 2026-08-23

Change: `refactor-as-canonical-typed-ast-compiler`  
Task: 2.12  
Scope: test-facing typed AST assertions plus deterministic diagnostic diff; no
production AST mutation, no Cache input, and no Clang/LLVM dependency.

## Outcome

The Canonical Typed AST can now be tested through exact semantic facts instead
of parsing its human-readable dump. The compact helpers in
`AngelscriptNativeCanonicalASTTestSupport.h` cover:

- one declaration with an exact stable key;
- exact canonical type key and qualifier mask on Decl/Type/Expr nodes;
- a named traversal edge and same-role occurrence;
- one resolved Call/Construct callee and an explicit zero-callee assertion;
- a call receiver with an exact expression kind;
- an explicit conversion with exact source and destination type keys;
- an exact control-transfer kind and target kind;
- one or more cleanup expressions resolving an exact destructor stable key;
- an exact logical source and half-open byte range.

Every result carries `Node`, optional `Related`, `MatchCount`, and a precise
failure message. Queries whose meaning is unique fail when cardinality is zero
or greater than one. Cleanup deliberately means “at least one” and reports its
count because one source temporary can legitimately produce cleanup nodes for
multiple exit paths.

`asCASTShadowDiff` is no longer the old declaration-only token accumulator. It
now compares the first differing fact in deterministic order:

```text
Source sections
  -> Type table
  -> Decl table
  -> Stmt table
  -> Expr table
```

It covers source identity/content/line offset, translation-unit and table
counts, canonical Type facts, every persisted Decl/Stmt/Expr scalar, qualified
type, string and ordered child/reference array. A mismatch is reported once as:

```text
mismatch path=D1/decl-child[1]/D3.traits left=0 right=1
mismatch path=D1/decl-body[0]/S1/stmt-child[1]/S3.safePointRole left=0 right=2
mismatch path=T1.primitiveToken left=74 right=75
```

The path is derived from the sealed graph's structural parent-edge index. An
unsealed or detached node falls back to its deterministic `D/T/S/E` table ID.
Snapshot-owner values, Engine-local IDs, arena pointers, and addresses are not
printed.

## Clang comparison and adopted boundary

This work borrows the useful testing and diagnosis properties of Clang AST
Matchers and AST structural comparison without importing their machinery:

| Clang capability | AngelScript implementation |
| --- | --- |
| typed node predicates and bound nodes | explicit AS-specific C++ helper functions returning `FCanonicalASTMatch` |
| named child/semantic relationships | shared `as_ast_traversal` edge roles |
| exact source/type/declaration assertions | stable key, QualType, source-range and resolved-target helpers |
| structural-equivalence failure localization | first typed fact mismatch plus structural node path |
| generated matcher hierarchy / dynamic query DSL | intentionally not implemented |
| ASTImporter/PCH structural merge | intentionally not implemented; Cache V2 keeps explicit DTO/remap |

The smaller API is intentional. AngelScript tests need stable assertions for
its own handle/reference/call/control/cleanup semantics, not a C++ template- and
macro-generated matcher language. The matcher header is test support, while
`asCASTShadowDiff` is host-neutral diagnostic infrastructure.

## AST-first test migration

Representative SemaAuthority tests no longer treat flat dump spelling as their
semantic oracle:

- overload selection asserts both exact declaration stable keys, exactly one
  `F(int)` resolved call, and zero calls to the float overload;
- integer-to-float parameter conversion asserts the exact `int -> configured
  float` conversion and the exact resolved `G(float)` call;
- `continue` asserts a typed `ContinueStmt -> WhileStmt` target;
- destructor cleanup asserts the unique `T::~T()` declaration and one-or-more
  typed cleanup expressions resolving that declaration.

The existing Shadow tests were also migrated from vague `owner/type/trait/
source/dependency` substring checks to exact mismatch fields:
`.parent`, `.type`, `.traits`, `.range`, and `.dependencies[0]`.

This preserves or strengthens the original facts. The dump remains a developer
inspection format, not the test API contract.

## TDD and failure-driven corrections

The initial test file was added before the matcher types/functions existed.
The expected RED build failed on missing `FCanonicalASTMatch` and matcher APIs:

- `Saved/Build/cta-ast-matcher-diff-red/20260823_213217_497_cc2fcb76/RunMetadata.json`

The first implementation build was blocked by an independent missing include
in the concurrently accumulated Cache ExactWarm test. The test used
`FAngelscriptCacheRecordArchive` without including
`AngelscriptCacheArchive.h`; the minimal include was restored. That failed run
is not GREEN evidence:

- `Saved/Build/cta-ast-matcher-diff-green-build/20260823_213939_430_61b9f57f/RunMetadata.json`

The first complete SemaAuthority run was 255/256. It exposed that requiring a
unique cleanup was semantically wrong: `T().X` produced four valid cleanup
sites for different transfers. The matcher was corrected to mean at least one
and expose `MatchCount`; no AST node was removed and no production behavior was
relaxed. The failed diagnostic run is retained as learning evidence, not a
passing gate:

- `Saved/Tests/cta-ast-matcher-diff-sema-authority/20260823_214316_467_63d2897a/RunMetadata.json`

The first complete Frontend run then identified two compatibility tests still
asserting the old vague ShadowDiff tokens. Those tests were migrated to the new
field-path contract and the full prefix was rerun. Again, the failed 121/123
run is not final evidence:

- `Saved/Tests/cta-ast-matcher-diff-frontend-canonical/20260823_214548_776_2be38806/RunMetadata.json`

## Final verification

- Runtime/Editor build after matcher, Sema migration, and Shadow test migration:
  `Saved/Build/cta-ast-matcher-diff-shadow-tests-build/20260823_214705_308_b39dda4a/RunMetadata.json`
  — exit 0.
- Isolated matcher and differential tests:
  `Saved/Tests/cta-ast-matcher-diff-final-isolated/20260823_214812_349_86b9bd35/RunMetadata.json`
  — **2/2 PASS**.
- Complete SemaAuthority:
  `Saved/Tests/cta-ast-matcher-diff-sema-authority-rerun/20260823_214501_117_a41b4d01/RunMetadata.json`
  — **256/256 PASS**.
- Complete Frontend CanonicalAST:
  `Saved/Tests/cta-ast-matcher-diff-frontend-canonical-rerun/20260823_214724_346_983297e2/RunMetadata.json`
  — **123/123 PASS**.
- Standalone, including an independent rebuild of `as_ast_dump.cpp` and its
  CanonicalAST/differential CTests:
  `Saved/StandaloneTests/cta-ast-matcher-diff-standalone_01_Standalone/20260823_214852_277_17a177ea/RunMetadata.json`
  — **21/21 PASS**.

## Files changed by this slice

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Support/AngelscriptNativeCanonicalASTTestSupport.h`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTMatcherAndDiffTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTShadowTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheExactWarmStartupTests.cpp` (missing direct include only)

## Remaining boundary

This closes task 2.12, not the compiler cutover. It does not add AST mutation,
rewriting, a matcher DSL, CFG, Cache encoding, LLVM lowering, or HIR removal.
Task 2.13 still owns the lease-safe developer/commandlet surfaces for `list`,
filtered `dump`, `verify`, `query`, and `diff`.
