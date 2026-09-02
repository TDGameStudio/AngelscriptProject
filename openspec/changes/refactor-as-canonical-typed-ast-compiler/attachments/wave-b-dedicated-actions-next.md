# Wave B dedicated Sema actions — exclusive UBT plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild` then the SemaAuthority prefix **before** filling `as_sema*`. Do **not** check `tasks.md` 13.2 / 13.3 / 4.2 / 5.9.

**Goal:** Clang-shaped dedicated Sema actions intern cast / construct / return without `ActOn*FromNode`. `ActOnParsedExpr` / `ActOnParsedStmt` dispatch those known kinds to the dedicated APIs. FromNode remains recovery for leftover node kinds. **13.2 stays `[ ]`.**

**Architecture:** Parser may still build `asCScriptNode` as recovery input. Authority is `asCSema::ActOn*` that tests can call with no script node. Dumps must print interned QualType keys (`type=int`, `dest=float`, `src=int`), selected `callee=`, and `kind=Return` / `kind=Construct`. LLVM/Clang is a shape reference only. Do not link Clang/LLVM.

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

- `asCSema::ActOnCallExpr` in `as_sema_expr.cpp`. Tests: `SemaCallExprActionSelectsIntOverloadWithoutScriptNode`, `SemaCallExprActionInsertsNamedConversionWithoutScriptNode`.
- `snFunctionCall` FromNode ends in `ActOnCallExpr`.
- Dump printer: EXPR `type=%s` interned stableKey; Conversion `dest=` + `src=`.
- Incomplete-parse locks: member overload, binary `opSub`, list-pattern.
- Builders already exist: `ActOnConversion`, `ActOnConstruct`, `ActOnReturnStmt`, `ActOnIntegerLiteral`, `ActOnClassDecl`, `ActOnConstructorDecl`, `ActOnParamDecl`.

SemaAuthority last green: **135/135** `wave-b-call-expr-green`. CanonicalAST **173/173** and Compiler **361/361** are **pre-ActOnCallExpr**.

## Files

- Test: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` (`ActOnParsedExpr` / `ActOnParsedStmt` dispatch)
- Optional Parser: `as_parser.cpp` only if a NotifySema hole is proven by a new incomplete-parse RED
- Record: `attachments/wave-b-results.md`, `tasks.md` 13.2 progress note

---

### Task 1: Re-run CanonicalAST + Compiler after ActOnCallExpr

**Files:** none (verify only)

- [ ] **Step 1: SemaAuthority still 135/135**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-call-expr-sema-rerun -TimeoutMs 600000
```

Expected: **135/135**. If red, stop and debug; do not add new tests.

- [ ] **Step 2: CanonicalAST prefix**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-call-expr-canonical -TimeoutMs 600000
```

Expected: green. Live method count will be higher than 173 because SemaAuthority gained `ActOnCallExpr` tests (and ProductionCodeGen is 25). Record exact total/passed.

- [ ] **Step 3: Compiler prefix**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-call-expr-compiler -TimeoutMs 600000
```

Expected: green. Record exact total/passed. Copy both Summary.json files next to the label dirs. Append a `B-call-expr` section to `wave-b-results.md`. **Leave 13.2 `[ ]`.**

If either prefix is red, fix the ActOnCallExpr wiring first (TDD on the failing method). Do not start Task 2 until both are green.

---

### Task 2: RED — dedicated Cast / Construct / Return without script node

**Files:**
- Modify: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` (append after `SemaCallExprActionInsertsNamedConversionWithoutScriptNode`)

Follow the existing `SemaCallExprAction*` pattern: `FNativeTestEngine` + `asCASTContext` + `asCSema`. No `AddScriptSection`. No `ActOnExprFromNode` / `ActOnStmtFromNode`.

- [ ] **Step 1: Write the three failing TEST_METHODs**

```cpp
TEST_METHOD(SemaCastActionInsertsNamedConversionWithoutScriptNode)
{
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	Sema.ActOnTranslationUnit("SemaCastAction");
	const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
	const asCQualType FloatType = Context.InternPrimitive(ttFloat, 0);
	const asCSourceRange Range;
	const asASTExprId Inner = Sema.ActOnIntegerLiteral(3, Range);
	ASSERT_THAT(IsTrue(Sema.ActOnCastExpr(Inner, FloatType, Range).IsValid(),
		TEXT("Clang-shaped ActOnCastExpr must intern a conversion without ActOnExprFromNode")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("ActOnCastExpr(3, float) must dump dest=float src=int. dump:\n%s"),
		*Text);
	bool bNamedConversion = false;
	TArray<FString> Lines;
	Text.ParseIntoArrayLines(Lines);
	for (const FString& Line : Lines)
	{
		if (Line.Contains(TEXT("kind=Conversion"))
			&& Line.Contains(TEXT("dest=float"))
			&& Line.Contains(TEXT("src=int")))
		{
			bNamedConversion = true;
			break;
		}
	}
	ASSERT_THAT(IsTrue(bNamedConversion, *DumpMsg));
}

TEST_METHOD(SemaConstructActionSelectsIntCtorWithoutScriptNode)
{
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaConstructAction");
	const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
	const asCSourceRange Range;
	const asASTDeclId ClassId = Sema.ActOnClassDecl(Tu, "T", Range);
	const asASTDeclId CtorFloat = Sema.ActOnConstructorDecl(ClassId, "T", Range);
	Sema.ActOnParamDecl(CtorFloat, "a", Context.InternPrimitive(ttFloat, 0), Range);
	const asASTDeclId CtorInt = Sema.ActOnConstructorDecl(ClassId, "T", Range);
	Sema.ActOnParamDecl(CtorInt, "a", IntType, Range);
	const asCQualType ClassType = Context.GetDecl(ClassId) ? Context.GetDecl(ClassId)->type : asCQualType();
	asCArray<asASTExprId> Args;
	Args.PushLast(Sema.ActOnIntegerLiteral(3, Range));
	ASSERT_THAT(IsTrue(Sema.ActOnConstruct(ClassType, Args, Range).IsValid(),
		TEXT("ActOnConstruct must intern a construct without ActOnExprFromNode")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("ActOnConstruct(T, 3) must select T::T(int), not first-name T::T(float). dump:\n%s"),
		*Text);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("callee=T::T(int)")), *DumpMsg));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("callee=T::T(float)")), *DumpMsg));
}

TEST_METHOD(SemaReturnStmtActionRecordsValueWithoutScriptNode)
{
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaReturnAction");
	const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
	const asCSourceRange Range;
	const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, Range);
	const asASTExprId Value = Sema.ActOnIntegerLiteral(7, Range);
	ASSERT_THAT(IsTrue(Sema.ActOnReturnStmt(Fn, Value, Range).IsValid(),
		TEXT("ActOnReturnStmt must intern kind=Return without ActOnStmtFromNode")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("ActOnReturnStmt must dump kind=Return. dump:\n%s"),
		*Text);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Return")), *DumpMsg));
}
```

If `ActOnConstruct` already selects the int ctor when given interned args, the construct test may go green without a new API — that is acceptable **only** if the dump shows `callee=T::T(int)` and the test never calls FromNode. `ActOnCastExpr` must be a **new** dedicated action (do not call `ActOnConversion` from the test; the test names the Clang-shaped API). `ActOnReturnStmt` already exists; the test locks that it works without FromNode.

If class QualType from `ActOnClassDecl` is empty, intern a named VALUE type the same way existing SemaAuthority class fixtures do (search this file for `ActOnClassDecl` + dump `T::T(`). Do not weaken the selected-ctor assert to “any Construct”.

- [ ] **Step 2: Build then run SemaAuthority — expect RED**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-dedicated-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-dedicated-red -TimeoutMs 600000
```

Expected: **compile fail** (`ActOnCastExpr` missing) and/or SemaAuthority **135+n / failed** on the new methods only. Existing 135 must stay green. Record the RED label. Do not implement until this RED is saved.

---

### Task 3: GREEN — implement dedicated actions + ActOnParsed dispatch

**Files:**
- Modify: `as_sema.h` — declare `asASTExprId ActOnCastExpr(asASTExprId inner, const asCQualType& dest, const asCSourceRange& range);`
- Modify: `as_sema_expr.cpp` — implement `ActOnCastExpr` as the overload/conversion authority for casts (call `ActOnConversion` internally is OK). Keep `ActOnConstruct` selecting ctor by arg QualTypes (same pattern as `ActOnCallExpr` / `SelectConstructor`).
- Modify: `as_sema_decl.cpp` `ActOnParsedExpr` / `ActOnParsedStmt`:

```cpp
switch( node->nodeType )
{
case snFunctionCall:
	ActOnExprFromNode(node, script, parsedFile, owner); // already ends in ActOnCallExpr; next slice can peel extraction
	return;
case snCast:
	{
		// extract dest QualType + inner expr, then:
		ActOnCastExpr(inner, dest, range);
		return;
	}
case snConstructCall:
	{
		ActOnConstruct(type, args, range);
		return;
	}
// ... other known kinds stay as-is until a later slice ...
default:
	ActOnExprFromNode(node, script, parsedFile, owner);
	return;
}
```

```cpp
switch( node->nodeType )
{
case snReturn:
	{
		// extract value expr (may still ActOnExprFromNode the *child*), then:
		ActOnReturnStmt(owner, value, range);
		return;
	}
default:
	ActOnStmtFromNode(node, script, parsedFile, owner);
	return;
}
```

Child extraction may still walk `asCScriptNode` — that is Parser recovery input. The intern of Conversion / Construct / Return must go through the dedicated action, not `ActOnStmtFromNode(snReturn)` / `ActOnExprFromNode(snCast)`.

Reuse `FindExisting*` so complete-body WalkOne does not duplicate.

If `snCast` extraction is easier by keeping a thin FromNode arm that **immediately** returns `ActOnCastExpr(...)`, that is acceptable. What is **not** acceptable: `ActOnParsedExpr` `case snCast:` falling through to generic FromNode as the only path.

- [ ] **Step 1: Implement the minimum to compile and pass the three new tests**
- [ ] **Step 2: Run SemaAuthority GREEN**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-dedicated-green
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-dedicated-green -TimeoutMs 600000
```

Expected: previous 135 + 3 new = **138/138** (or the live count if construct needed extra helpers). Zero failures.

- [ ] **Step 3: CanonicalAST then Compiler**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-dedicated-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-dedicated-compiler -TimeoutMs 600000
```

Expected: both green. Record counts in `wave-b-results.md` under `B-dedicated-actions`. Patch `tasks.md` 13.2 progress: dedicated Cast/Construct/Return landed; `ActOnParsed*` FromNode is recovery/default only for leftover kinds; **box stays `[ ]`**.

- [ ] **Step 4: Do not commit. Do not archive. Do not start F4.**

---

## What this slice does not close

- 13.2: FromNode still recovery for assignment, control, lambda, qual types, members, logical, conditional, foreach, etc. LEGACY still `asCCompiler`. 4.2–5.9 incomplete.
- 13.3: production identity still snapshot keys; default pipeline still LEGACY.
- 9.5 / F4 / stored closures / Wave E–G.

Next exclusive UBT after this GREEN: remaining FromNode kinds from `wave-b-fromnode-inventory.md`, still Wave B, still no 13.2 checkbox.
