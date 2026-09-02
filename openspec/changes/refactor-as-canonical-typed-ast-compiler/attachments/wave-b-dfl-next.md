# Wave B dedicated DoWhile / Foreach / Lambda — exclusive UBT plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. The failing SemaAuthority methods **already exist**. Do **not** rewrite them. `RunBuild` already failed C2039 (`wave-b-dfl-red`). Implement `as_sema*` next. Do **not** check `tasks.md` 13.2 / 13.3 / 4.2 / 5.9.

**Goal:** Clang-shaped dedicated Sema actions intern do-while / foreach / lambda without `ActOn*FromNode` as the intern. `ActOnParsedStmt` dispatches `snDoWhile` / `snForEach`. Lambda intern goes through `ActOnLambdaExpr`. FromNode remains recovery for leftover node kinds. **13.2 stays `[ ]`.**

**Architecture:** Parser may still build `asCScriptNode` as recovery input. Authority is `asCSema::ActOn*` that tests can call with no script node. LLVM/Clang is a shape reference only. Do not link Clang/LLVM.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. Dual-repo. One UBT user. Always `-NoXGE`. Commands only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`.

## Global constraints

- Do not check 13.2 / 13.3 / 4.2 / 5.9 / 9.5 / 9.1 / 13.6 / 10.2 / 10.4.
- Do not flip default CANONICAL. Do not implement F4 / stored closures / CANONICAL CompileFunction / Wave E–G.
- Do not edit `as_bytecode_codegen.cpp` / `as_compiler.cpp` / `as_module.cpp` unless a proven regression from this dispatch.
- Hard no: CALL-without-callee as a seal/verifier firewall. `asCASTVerify` must still succeed on unsealed graphs.
- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null`; mutable script globals intern then reject; host `RegisterFuncdef` allowed.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- No Unreal types in fork frontend files.
- Do not archive. Do not commit unless asked.
- Copy each `Summary.json` under the label dir, then record counts in `attachments/wave-b-results.md`. Patch `tasks.md` 13.2 **progress notes only**.

## Already landed (do not redo)

- Dedicated Call/Cast/Construct/Return/Assign/Binary/Logical/If/While/For/Switch.
- Builders `ActOnDoWhile` / `ActOnForeach` / `ActOnFunctionDecl` / `AddDeclTrait` / `FinishDecl` (`TRAIT_LAMBDA` appends `@offset`).
- `BeginParsedControl` already stubs `snDoWhile` / `snForEach`.
- Dump printer already maps `asAST_STMT_DO_WHILE` → `DoWhile`, `asAST_STMT_FOREACH` → `ForEach`.
- Three RED tests at `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` after `SemaSwitchStmtActionRecordsCondWithoutScriptNode`.
- Last GREEN: SemaAuthority **146/146** `wave-b-control-green`; CanonicalAST **186/186**; Compiler **374/374**.

RED evidence (do not re-run just to re-prove C2039 unless the tests were lost):

- `D:\as-cta\Saved\Build\wave-b-dfl-red\20260822_062612_433_f6d7cbff`
- C2039: `ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr` are not members of `asCSema`

## Files

- Test (already written, do not rewrite): `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` (`ActOnParsedStmt`, `ActOnLambdaFromNode`, optional `ActOnParsedExpr` `snFunction`)
- Record: `attachments/wave-b-results.md`, `tasks.md` 13.2 progress note

**Interfaces (must match the tests exactly):**

```cpp
asASTStmtId ActOnDoWhileStmt(asASTDeclId owner, asASTStmtId body, asASTExprId cond, const asCSourceRange& range);
asASTStmtId ActOnForeachStmt(asASTDeclId owner, asASTStmtId varStmt, asASTExprId rangeExpr, asASTStmtId body, const asCSourceRange& range);
asASTExprId ActOnLambdaExpr(asASTDeclId owner, const asCQualType& returnType, const asCSourceRange& range);
```

Dump locks: `kind=DoWhile`, `kind=ForEach`, `name=<lambda>`.

---

### Task 1: Declare + implement dedicated actions

**Files:**
- Modify: `as_sema.h` — declare the three APIs next to `ActOnDoWhile` / `ActOnForeach` / `ActOnLambdaFromNode`
- Modify: `as_sema_stmt.cpp` — implement DoWhile/Foreach mirroring `ActOnWhileStmt` / `ActOnForStmt`
- Modify: `as_sema_decl.cpp` or `as_sema.cpp` — implement `ActOnLambdaExpr`

- [ ] **Step 1: Header declarations**

Place after `ActOnDoWhile` / `ActOnForeach` / `ActOnLambdaFromNode`:

```cpp
asASTStmtId ActOnDoWhileStmt(asASTDeclId owner, asASTStmtId body, asASTExprId cond, const asCSourceRange& range);
asASTStmtId ActOnForeachStmt(asASTDeclId owner, asASTStmtId varStmt, asASTExprId rangeExpr, asASTStmtId body, const asCSourceRange& range);
asASTExprId ActOnLambdaExpr(asASTDeclId owner, const asCQualType& returnType, const asCSourceRange& range);
```

Keep `ActOnLambdaFromNode` as the extract wrapper. Do not delete it in this slice until dispatch calls `ActOnLambdaExpr`.

- [ ] **Step 2: `ActOnDoWhileStmt` — copy the While fill/create pattern**

Mirror `ActOnWhileStmt` (`as_sema_stmt.cpp:219-238`) with `asAST_STMT_DO_WHILE` and `ActOnDoWhile`:

```cpp
asASTStmtId asCSema::ActOnDoWhileStmt(asASTDeclId owner, asASTStmtId body, asASTExprId cond, const asCSourceRange& range)
{
	asASTStmtId loop = FindExistingStmt(context, asAST_STMT_DO_WHILE, range);
	if( loop.IsValid() && !ControlNeedsFill(context.GetStmt(loop)) )
	{
		return loop;
	}
	if( !loop.IsValid() )
	{
		loop = ActOnDoWhile(owner, body, cond, range);
		PushControl(loop);
		PopControl();
		return loop;
	}
	context.SetStmtExpr(loop, cond);
	context.ClearStmtChildren(loop);
	context.AddStmtChild(loop, body);
	PopControl();
	return loop;
}
```

- [ ] **Step 3: `ActOnForeachStmt` — copy the For fill/create pattern**

```cpp
asASTStmtId asCSema::ActOnForeachStmt(asASTDeclId owner, asASTStmtId varStmt, asASTExprId rangeExpr, asASTStmtId body, const asCSourceRange& range)
{
	asASTStmtId loop = FindExistingStmt(context, asAST_STMT_FOREACH, range);
	if( loop.IsValid() && !ControlNeedsFill(context.GetStmt(loop)) )
	{
		return loop;
	}
	if( !loop.IsValid() )
	{
		loop = ActOnForeach(owner, varStmt, rangeExpr, body, range);
		PushControl(loop);
		PopControl();
		return loop;
	}
	context.SetStmtExpr(loop, rangeExpr);
	context.ClearStmtChildren(loop);
	context.AddStmtChild(loop, varStmt);
	context.AddStmtChild(loop, body);
	PopControl();
	return loop;
}
```

`ControlNeedsFill` is `!stmt->expr.IsValid()`. Foreach stores the range expr on the stmt, so a filled foreach is not re-filled.

- [ ] **Step 4: `ActOnLambdaExpr` — intern `<lambda>` without a script node**

`ActOnFunctionDecl` calls `FinishDecl` before the lambda trait exists. Add the trait, rename, then `FinishDecl` again so `stableKey` gets `@offset`:

```cpp
asASTExprId asCSema::ActOnLambdaExpr(asASTDeclId owner, const asCQualType& returnType, const asCSourceRange& range)
{
	const asASTDeclId fn = ActOnFunctionDecl(owner, "<lambda>", returnType, range);
	context.AddDeclTrait(fn, asAST_TRAIT_LAMBDA);
	context.SetDeclName(fn, "<lambda>");
	FinishDecl(fn);
	return ActOnDeclRef(fn, returnType, range);
}
```

Dump must contain `name=<lambda>`. Do not take `asCScriptNode*`. Do not call `ActOnLambdaFromNode` from this API.

---

### Task 2: Dispatch ActOnParsed* and FromNode leftover

**Files:**
- Modify: `as_sema_decl.cpp` `ActOnParsedStmt` (`snDoWhile` currently FromNode at the listed-kinds arm; `snForEach` currently `default` FromNode)
- Modify: `as_sema_stmt.cpp` `snDoWhile` / `snForEach` FromNode arms — extract then dedicated action
- Modify: `as_sema_decl.cpp` `ActOnLambdaFromNode` — extract then `ActOnLambdaExpr`; body attach may still `ActOnStmtFromNode` for leftover stmt kinds

- [ ] **Step 1: `ActOnParsedStmt` dedicated cases**

Replace the listed `snDoWhile` FromNode arm and add `snForEach` (today it only hits `default`):

```cpp
case snDoWhile:
	{
		const asCSourceRange range = RangeOf(context.GetSourceManager(), parsedFile, node);
		const asASTStmtId body = ActOnStmtFromNode(node->firstChild, script, parsedFile, owner);
		const asASTExprId cond = ActOnExprFromNode(node->firstChild ? node->firstChild->next : 0, script, parsedFile, owner);
		ActOnDoWhileStmt(owner, body, cond, range);
		return;
	}
case snForEach:
	{
		const asCSourceRange range = RangeOf(context.GetSourceManager(), parsedFile, node);
		asCScriptNode* child = node->firstChild;
		asASTStmtId varStmt;
		while( child && child->nodeType == snDeclaration )
		{
			const asASTStmtId part = ActOnStmtFromNode(child, script, parsedFile, owner);
			if( !varStmt.IsValid() )
			{
				varStmt = part;
			}
			child = child->next;
		}
		const asASTExprId rangeExpr = ActOnExprFromNode(child, script, parsedFile, owner);
		child = child ? child->next : 0;
		const asASTStmtId body = ActOnStmtFromNode(child, script, parsedFile, owner);
		ActOnForeachStmt(owner, varStmt, rangeExpr, body, range);
		return;
	}
```

Child extraction may still FromNode. The intern of DoWhile / ForEach must go through the dedicated action.

- [ ] **Step 2: FromNode `snDoWhile` / `snForEach` call dedicated actions**

Today those arms fill the stub inline (`as_sema_stmt.cpp` ~521–604). Change them to extract then `return ActOnDoWhileStmt(...)` / `return ActOnForeachStmt(...)`, keeping the existing FindExisting + ControlNeedsFill early-return **before** extract so a filled loop is not interned twice (same bug as If/Switch first GREEN **139/146**).

If WalkOne of a complete body still re-walks a filled do-while/foreach, early-return the filled stmt the same way While/For already do.

- [ ] **Step 3: `ActOnLambdaFromNode` becomes extract-then-`ActOnLambdaExpr`**

Keep parameter walk + body attach (body may still `ActOnStmtFromNode` until leftover stmt kinds move). After `FindExistingFunctionLike` miss, intern via `ActOnLambdaExpr` instead of `ActOnFunctionLike` when the node is a lambda (`FunctionNameNode` text `"function"`). Then `SetBody` from dedicated/from-node stmts. Return the `ActOnDeclRef` from `ActOnLambdaExpr` or an equivalent DeclRef.

If `ActOnParsedExpr` can dispatch `snFunction` that is a lambda to extract-then-`ActOnLambdaExpr`, do that. Named functions must stay on the decl WalkOne path — do not intern every `snFunction` as a lambda.

`ActOnLambdaFromNode` remaining as a named FromNode is OK only as the extract wrapper. The intern of the `<lambda>` decl must be `ActOnLambdaExpr`.

---

### Task 3: GREEN SemaAuthority then CanonicalAST then Compiler

- [ ] **Step 1: Build**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-dfl-green
```

Expected: compile success. If C2039 remains, the declarations did not land in the header the tests include.

- [ ] **Step 2: SemaAuthority GREEN**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-dfl-green -TimeoutMs 600000
```

Expected: previous 146 + 3 new = **149/149** (or the live count). Zero failures. Existing ParserActOn do-while/foreach/lambda dumps must stay green.

If Seal fails with `stmt-multi-owner` / unsealed publication, WalkOne re-walked a filled do-while/foreach. Early-return filled loops (copy If/Switch). Do not weaken verifier.

If lambda dump lacks `name=<lambda>`, `SetDeclName` / `FinishDecl` after `TRAIT_LAMBDA` is missing.

- [ ] **Step 3: CanonicalAST then Compiler**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-dfl-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-dfl-compiler -TimeoutMs 600000
```

Expected: both green. Record exact totals. Copy `Summary.json` next to each label dir.

- [ ] **Step 4: Record. Do not check 13.2.**

Append `B-dowhile-foreach-lambda` to `attachments/wave-b-results.md`. Patch `tasks.md` 13.2 progress: dedicated DoWhile/Foreach/Lambda landed; FromNode remains recovery for leftover kinds (members/QualType/local decl/init-list/break); **box stays `[ ]`**.

Do not commit. Do not archive. Do not start F4. Do not start Wave E–G.

---

## What this slice does not close

- 13.2: FromNode still recovery for `snExprTerm` members/index/unary, QualType, local decl, init-list, Break/Continue/Fallthrough, conditional. LEGACY still `asCCompiler`. 4.2–5.9 incomplete.
- 13.3: production identity still snapshot keys; default pipeline still LEGACY.
- 9.5 / F4 / stored closures / Wave E–G.
- Treating `ActOnLambdaFromNode` itself as dedicated.

Next exclusive UBT after this GREEN: remaining FromNode kinds from `wave-b-leftover-after-dfl.md` (expected `snExprTerm` then `ActOnQualType`), still Wave B, still no 13.2 checkbox.
