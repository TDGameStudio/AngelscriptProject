# Wave C 2.8 / 13.5 remainder — verifier publication firewall

> **For agentic workers:** Use superpowers:test-driven-development. Write the failing tests first. RunBuild then the Verifier prefix **before** editing `as_ast_verifier.cpp`. Do not check `tasks.md` 2.8 / 13.5 until the close criteria at the bottom hold.

**Goal:** `asCASTVerify` rejects stmt multi-ownership, stmt cycles, fallthrough outside switch, and CLEANUP `resolvedDecl` that is not a destructor; `asCASTVerifyPublication` emits `asAST_VERIFY_UNSEALED_PUBLICATION` on unsealed graphs. `asCASTVerify` itself must still succeed on unsealed construction graphs because `Seal()` calls it **before** setting `sealed`.

**Worktree:** `D:\as-cta`. Exclusive UBT. If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are running, **wait or stop** — do not start a second build.

## Global constraints

- TDD. No Unreal types in fork files. No Clang/LLVM.
- Default pipeline stays LEGACY. `Ready()` stays false. Do not route `Build()` through `Generate()`.
- **Hard no:** requiring CALL/CONSTRUCT missing `resolvedDecl`. BodySema/CodeGen graphs must still seal.
- Do **not** make `asCASTVerify` fail because the context is unsealed.
- Do **not** add empty cleanup-plan fields to `asCStmt` / `asCExpr`. CLEANUP and MATERIALIZE already exist as expr kinds.
- Construction APIs only (`AddStmtChild`, `SetResolvedDecl`, `SetDeclKind`, …). Public `Get*` are const-only.
- Do not edit `as_sema*` unless a new check rejects a current BodySema graph — then **narrow the check**.
- Optional one-line: CodeGen `Generate` may call `asCASTVerifyPublication` instead of duplicating `!IsSealed()`. Do not rewrite Generate’s install/rollback.
- Do not archive or commit unless the user asks.

## File map

| Path | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` | Four new methods (plus keep existing 8) |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.h` | Declare `asCASTVerifyPublication` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp` | Stmt parent map / cycle / fallthrough-under-switch / cleanup-dtor / publication helper |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | Optional: unsealed gate → `asCASTVerifyPublication` |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-c-results.md` | Record new counts |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md` | Check 2.8 / 13.5 **only** after close criteria |

Existing `asCASTVerify` (~L95–346) already covers decl/stmt/expr ids, decl parent/child, decl-cycle, body-owner, break-ancestor, duplicate-case, expr type, operand arity. Fallthrough currently only requires `owner` (`fallthrough-owner`).

`AddStmtChild` is an unguarded `PushLast` — two parents can list the same child. That is the multi-owner fixture.

## Detail tokens (stable)

| Case | Category | Detail |
| --- | --- | --- |
| Two stmt parents list the same child | `asAST_VERIFY_INVALID_CHILD` | `stmt-multi-owner` |
| Stmt child cycle | `asAST_VERIFY_INVALID_CHILD` | `stmt-cycle` |
| Fallthrough not a descendant of a switch | `asAST_VERIFY_WRONG_KIND` or `INVALID_CHILD` | `fallthrough-switch` |
| Publication of an unsealed graph | `asAST_VERIFY_UNSEALED_PUBLICATION` | `unsealed-publication` |
| CLEANUP `resolvedDecl` set but not `asAST_DECL_DESTRUCTOR` | `asAST_VERIFY_WRONG_KIND` | `cleanup-dtor` |

CLEANUP with **no** `resolvedDecl` must still verify (Sema often cannot find a dtor). MATERIALIZE has no extra kind check.

## Task 1 — failing tests (RED)

Append these methods inside `FCanonicalASTVerifierTests`. Do not remove existing methods.

```cpp
	TEST_METHOD(RejectsStmtMultiOwner)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("StmtMulti");
		const asASTStmtId LoopA = Context.CreateStmt(asAST_STMT_WHILE, Tu, asCSourceRange());
		const asASTStmtId LoopB = Context.CreateStmt(asAST_STMT_WHILE, Tu, asCSourceRange());
		const asASTStmtId Inner = Context.CreateStmt(asAST_STMT_BLOCK, Tu, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(LoopA, Inner), TEXT("inner under loop A")));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(LoopB, Inner), TEXT("same inner under loop B")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_INVALID_CHILD, asCASTVerify(Context, Result),
			TEXT("a stmt must not have two parents")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("stmt-multi-owner"), TEXT("detail token must be stmt-multi-owner")));
	}

	TEST_METHOD(RejectsStmtCycle)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("StmtCycle");
		const asASTStmtId BlockA = Context.CreateStmt(asAST_STMT_BLOCK, Tu, asCSourceRange());
		const asASTStmtId BlockB = Context.CreateStmt(asAST_STMT_BLOCK, Tu, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(BlockA, BlockB), TEXT("A owns B")));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(BlockB, BlockA), TEXT("B owns A")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_INVALID_CHILD, asCASTVerify(Context, Result),
			TEXT("stmt child lists must be acyclic")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("stmt-cycle"), TEXT("detail token must be stmt-cycle")));
	}

	TEST_METHOD(RejectsFallthroughOutsideSwitch)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("FallV");
		const asASTStmtId Block = Context.CreateStmt(asAST_STMT_BLOCK, Tu, asCSourceRange());
		const asASTStmtId Fall = Context.CreateStmt(asAST_STMT_FALLTHROUGH, Tu, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Block, Fall), TEXT("fallthrough under a bare block")));
		asSAstVerifyResult Result;
		ASSERT_THAT(IsTrue(asCASTVerify(Context, Result) != (int)asAST_VERIFY_OK,
			TEXT("fallthrough must sit under a switch")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("fallthrough-switch"), TEXT("detail token must be fallthrough-switch")));
	}

	TEST_METHOD(RejectsUnsealedPublication)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("PubV");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asASTDeclId Fn = Context.CreateDecl(asAST_DECL_FUNCTION, Tu, asCSourceRange(), "F");
		const asASTStmtId Body = Context.CreateStmt(asAST_STMT_RETURN, Fn, asCSourceRange());
		const asASTExprId Lit = Context.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.SetBody(Fn, Body), TEXT("set body")));
		ASSERT_THAT(AreEqual(0, Context.SetStmtExpr(Body, Lit), TEXT("return literal")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Result),
			TEXT("asCASTVerify must still accept an unsealed construction graph so Seal() can run")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_UNSEALED_PUBLICATION, asCASTVerifyPublication(Context, Result),
			TEXT("publication of an unsealed graph must fail closed")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("unsealed-publication"), TEXT("detail token must be unsealed-publication")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("same graph must seal")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerifyPublication(Context, Result),
			TEXT("publication of a sealed verified graph must succeed")));
	}

	TEST_METHOD(RejectsCleanupResolvedDeclNotDestructor)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("CleanupV");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asASTDeclId Fn = Context.CreateDecl(asAST_DECL_FUNCTION, Tu, asCSourceRange(), "NotDtor");
		const asASTExprId Inner = Context.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		const asASTExprId Cleanup = Context.CreateExpr(asAST_EXPR_CLEANUP, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.AddExprChild(Cleanup, Inner), TEXT("cleanup arity 1")));
		ASSERT_THAT(AreEqual(0, Context.SetResolvedDecl(Cleanup, Fn), TEXT("point cleanup at a non-destructor")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_WRONG_KIND, asCASTVerify(Context, Result),
			TEXT("CLEANUP resolvedDecl if set must be a destructor")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("cleanup-dtor"), TEXT("detail token must be cleanup-dtor")));
	}
```

If `RejectsUnsealedPublication` needs a function-like body owner for the return stmt, keep `SetBody`. If Seal fails for an unrelated missing type/operand, fix the fixture (give the literal a type — already `InternPrimitive`) rather than weakening verify.

Do **not** add `RejectsCallWithoutResolvedDecl`.

## Task 2 — prove RED

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-28-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-c-28-red -TimeoutMs 600000
```

Expected: new methods RED (`asCASTVerifyPublication` missing → compile fail on the publication test is an acceptable first RED; add the declaration returning “not implemented” / always OK only if needed to compile, then keep the assertion RED). Existing 8 stay green.

If UBT is busy, write the tests, stop, and record the lock in `wave-c-results.md`. Do not start a second build.

## Task 3 — minimal verifier (GREEN)

`as_ast_verifier.h`:

```cpp
ANGELSCRIPTRUNTIME_API int asCASTVerify(const asCASTContext& context, asSAstVerifyResult& result);
ANGELSCRIPTRUNTIME_API int asCASTVerifyPublication(const asCASTContext& context, asSAstVerifyResult& result);
```

`asCASTVerifyPublication`:

```cpp
int asCASTVerifyPublication(const asCASTContext& context, asSAstVerifyResult& result)
{
	if( !context.IsSealed() )
	{
		return Fail(result, asAST_VERIFY_UNSEALED_PUBLICATION, asCSourceRange(), "unsealed-publication");
	}
	return asCASTVerify(context, result);
}
```

`asCASTVerify` additions (stmt loop):

1. **Parent map.** `asCArray<asASTStmtId> parentOf` sized `GetStmtCount()+1`, invalid default. For each stmt, for each child: if child already has a different parent → `stmt-multi-owner`. Else record parent.
2. **Cycles.** DFS/color on stmt children (white/gray/black). Gray re-entry → `stmt-cycle`. Reuse the existing `visiting` idea in `StmtContains`; do not infinite-loop on the cycle fixture.
3. **Fallthrough.** For each `asAST_STMT_FALLTHROUGH`, walk recorded parents (or scan all switches’ descendants). If no ancestor `asAST_STMT_SWITCH` → `fallthrough-switch`. Keep the existing `fallthrough-owner` check for missing decl owner.
4. **Cleanup.** After the existing `resolvedDecl` dangling check: if `expr->kind == asAST_EXPR_CLEANUP` and `resolvedDecl` is valid, `GetDecl` kind must be `asAST_DECL_DESTRUCTOR` else `cleanup-dtor`.

Do not require return `target` completeness if BodySema seals returns without it — record that skip in `wave-c-results.md`.

Optional CodeGen: replace the `if (!context.IsSealed())` block with `asCASTVerifyPublication`.

## Task 4 — prove GREEN and no BodySema/CodeGen regression

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-28-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-c-28-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-c-28-frontend -TimeoutMs 600000
```

Expected: Verifier all PASS (8 old + 5 new). Frontend CanonicalAST includes BodySema + CodeGen + Dump; must stay green. Cutover still LEGACY / Ready false if you touch CodeGen.

If Seal/BodySema/CodeGen go red because of CALL-without-callee — **revert that check**. If they go red because of fallthrough/cleanup, inspect whether Sema actually emits illegal graphs; only then narrow.

## Close criteria (2.8 / 13.5)

May check `tasks.md` 2.8 and 13.5 **only if all** of:

- [ ] Stmt/expr table-index mismatch still rejected (`stmt-id` / `expr-id`)
- [ ] Decl parent/child + decl-cycle still rejected
- [ ] Stmt multi-owner + stmt-cycle rejected with the tokens above
- [ ] Fallthrough outside switch rejected (`fallthrough-switch`)
- [ ] Break-ancestor still rejected
- [ ] CLEANUP `resolvedDecl` if set is a destructor (`cleanup-dtor`); missing callee on CLEANUP still verifies
- [ ] `asCASTVerifyPublication` emits `UNSEALED_PUBLICATION` / `unsealed-publication`; `asCASTVerify` still OK on the same unsealed graph; `Seal()` still works
- [ ] No CALL-without-callee check
- [ ] Verifier + Frontend CanonicalAST prefixes green after RunBuild
- [ ] Production default still LEGACY; Ready false; `Build()` still `asCCompiler`

Still **do not** check 13.2 / 5.9 / 9.5 / 13.6 / 10.* from these greens.

Record counts and report paths in `attachments/wave-c-results.md`.
