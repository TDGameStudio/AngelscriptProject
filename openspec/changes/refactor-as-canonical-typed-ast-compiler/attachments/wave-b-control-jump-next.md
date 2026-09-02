# Wave B dedicated Break / Continue / Fallthrough — exclusive UBT plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Write the failing SemaAuthority methods **first**. Watch C2039. Then implement `as_sema*`. Do **not** check `tasks.md` 13.2 / 13.3 / 4.2 / 5.9 / 5.6.

**Goal:** Clang-shaped dedicated Sema actions intern break / continue / fallthrough without `ActOn*FromNode` as the intern. Control targets come from the Sema `controlStack` (`NearestControl`), not from a script node. FromNode remains recovery for leftover node kinds. **13.2 stays `[ ]`.**

**Architecture:** Parser may still build `asCScriptNode` as recovery input. Authority is `asCSema::ActOn*Stmt` that tests can call with no script node after `PushControl`. LLVM/Clang is a shape reference only (`Sema::ActOnBreakStmt` uses `Scope::getBreakParent`; this fork uses `controlStack` + `NearestControl`). Do not link Clang/LLVM. AngelScript has no labeled break.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. Dual-repo. One UBT user. Always `-NoXGE`. Commands only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`.

## Global constraints

- Do not check 13.2 / 13.3 / 4.2 / 5.9 / 5.6 / 9.5 / 9.1 / 13.6 / 10.2 / 10.4.
- Do not flip default CANONICAL. Do not implement F4 / stored closures / CANONICAL CompileFunction / Wave E–G.
- Do not edit `as_bytecode_codegen.cpp` / `as_compiler.cpp` / `as_module.cpp` unless a proven regression from this dispatch.
- Hard no: CALL-without-callee as a seal/verifier firewall. `asCASTVerify` must still succeed on unsealed graphs.
- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null`; mutable script globals intern then reject; host `RegisterFuncdef` allowed. No C labeled break.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- No Unreal types in fork frontend files.
- Do not archive. Do not commit unless asked.
- Copy each `Summary.json` under the label dir, then record counts in `attachments/wave-b-results.md`. Patch `tasks.md` 13.2 **progress notes only**.

## Already landed (do not redo)

- Dedicated Call/Cast/Construct/Return/Assign/Binary/Logical/If/While/For/Switch/DoWhile/Foreach/Lambda/Member/Index/Unary/QualType/DeclRef/LocalDecl/InitList.
- Builders `ActOnBreak` / `ActOnContinue` / `ActOnFallthrough` (`as_sema.cpp:824-857`). Builder ≠ intern.
- `BeginParsedControl` already stubs loops/switch and `PushControl`. `NearestControl(stack, loopsOnly)`: continue skips switch; break accepts loop or switch (`as_sema_stmt.cpp:375-394`).
- Dump printer already emits `STMT id=… kind=Break … target=%u` (`as_ast_dump.cpp:171`).
- Parser dump locks already exist: `ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails`, `ParserActOnContinueRecordsForTargetBeforeBodyCloseFails`, `ParserActOnBreakRecordsSwitchTargetOnSuccessfulParse`. Those intern **through FromNode**. Do not rewrite them.
- Last GREEN: SemaAuthority **157/157** `wave-b-local-green`; CanonicalAST **197/197** `wave-b-local-canonical2`; Compiler **385/385** `wave-b-local-compiler`.
- LocalDecl trap: init assign is a **sibling** `STMT_EXPR`. Do not `SetStmtExpr` on DeclStmt. Do not nest those siblings in a Block.

## Files

- Test: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` — add three methods after `SemaInitListActionRecordsListPatternWithoutScriptNode`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp` (`ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt`; FromNode `snBreak`/`snContinue`/`snFallthrough` extract-then-dedicated)
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` (`ActOnParsedStmt` `snBreak`/`snContinue`/`snFallthrough`)
- Record: `attachments/wave-b-results.md`, `tasks.md` 13.2 progress note

**Interfaces (must match the tests exactly):**

```cpp
asASTStmtId ActOnBreakStmt(asASTDeclId owner, const asCSourceRange& range);
asASTStmtId ActOnContinueStmt(asASTDeclId owner, const asCSourceRange& range);
asASTStmtId ActOnFallthroughStmt(asASTDeclId owner, const asCSourceRange& range);
```

Dump locks: `kind=Break` + `target=` matching the PushControl While id; `kind=Continue` + `target=` matching the PushControl For id; `kind=Fallthrough` (no `target=` required).

`ActOnWhileStmt` / `ActOnForStmt` Push then Pop before return. Tests **must** `PushControl` the filled loop after that, so `NearestControl` sees it. Do not add an explicit target parameter — that would just rename the builder.

---

### Task 1: Write failing tests

**Files:**
- Modify: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` after `SemaInitListActionRecordsListPatternWithoutScriptNode` (~line 3120)

- [ ] **Step 1: Add the three methods. Do not declare the APIs yet.**

```cpp
	TEST_METHOD(SemaBreakStmtActionRecordsWhileTargetWithoutScriptNode)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaBreakAction");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asCSourceRange Range;
		const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, Range);
		const asASTExprId Cond = Sema.ActOnIntegerLiteral(1, Range);
		const asASTStmtId Body = Sema.ActOnReturnStmt(Fn, Sema.ActOnIntegerLiteral(0, Range), Range);
		const asASTStmtId Loop = Sema.ActOnWhileStmt(Fn, Cond, Body, Range);
		ASSERT_THAT(IsTrue(Loop.IsValid(), TEXT("While must exist before Break")));
		Sema.PushControl(Loop);
		ASSERT_THAT(IsTrue(Sema.ActOnBreakStmt(Fn, Range).IsValid(),
			TEXT("Clang-shaped ActOnBreakStmt must intern kind=Break without ActOnStmtFromNode")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("ActOnBreakStmt must dump kind=Break target= matching the While id. dump:\n%s"),
			*Text);
		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		int32 WhileId = 0;
		int32 BreakTarget = 0;
		for (const FString& Line : Lines)
		{
			if (!Line.Contains(TEXT("STMT id=")))
			{
				continue;
			}
			const int32 IdBegin = Line.Find(TEXT("id="));
			const int32 Id = FCString::Atoi(*Line.Mid(IdBegin + 3));
			if (Line.Contains(TEXT("kind=While")))
			{
				WhileId = Id;
			}
			else if (Line.Contains(TEXT("kind=Break")))
			{
				const int32 TargetBegin = Line.Find(TEXT("target="));
				if (TargetBegin != INDEX_NONE)
				{
					BreakTarget = FCString::Atoi(*Line.Mid(TargetBegin + 7));
				}
			}
		}
		ASSERT_THAT(IsTrue(WhileId != 0, *DumpMsg));
		ASSERT_THAT(AreEqual(WhileId, BreakTarget, *DumpMsg));
	}

	TEST_METHOD(SemaContinueStmtActionRecordsForTargetWithoutScriptNode)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaContinueAction");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asCSourceRange Range;
		const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, Range);
		const asASTDeclId Var = Sema.ActOnVarDecl(Fn, "i", IntType, Range);
		const asASTStmtId Init = Sema.ActOnExprStmt(Fn, Sema.ActOnAssignExpr(Sema.ActOnDeclRef(Var, IntType, Range), Sema.ActOnIntegerLiteral(0, Range), Range), Range);
		const asASTExprId Cond = Sema.ActOnIntegerLiteral(1, Range);
		const asASTExprId Incr = Sema.ActOnIntegerLiteral(1, Range);
		const asASTStmtId Body = Sema.ActOnReturnStmt(Fn, Sema.ActOnIntegerLiteral(0, Range), Range);
		const asASTStmtId Loop = Sema.ActOnForStmt(Fn, Init, Cond, Incr, Body, Range);
		ASSERT_THAT(IsTrue(Loop.IsValid(), TEXT("For must exist before Continue")));
		Sema.PushControl(Loop);
		ASSERT_THAT(IsTrue(Sema.ActOnContinueStmt(Fn, Range).IsValid(),
			TEXT("Clang-shaped ActOnContinueStmt must intern kind=Continue without ActOnStmtFromNode")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("ActOnContinueStmt must dump kind=Continue target= matching the For id. dump:\n%s"),
			*Text);
		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		int32 ForId = 0;
		int32 ContinueTarget = 0;
		for (const FString& Line : Lines)
		{
			if (!Line.Contains(TEXT("STMT id=")))
			{
				continue;
			}
			const int32 IdBegin = Line.Find(TEXT("id="));
			const int32 Id = FCString::Atoi(*Line.Mid(IdBegin + 3));
			if (Line.Contains(TEXT("kind=For")))
			{
				ForId = Id;
			}
			else if (Line.Contains(TEXT("kind=Continue")))
			{
				const int32 TargetBegin = Line.Find(TEXT("target="));
				if (TargetBegin != INDEX_NONE)
				{
					ContinueTarget = FCString::Atoi(*Line.Mid(TargetBegin + 7));
				}
			}
		}
		ASSERT_THAT(IsTrue(ForId != 0, *DumpMsg));
		ASSERT_THAT(AreEqual(ForId, ContinueTarget, *DumpMsg));
	}

	TEST_METHOD(SemaFallthroughStmtActionRecordsKindWithoutScriptNode)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaFallthroughAction");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asCSourceRange Range;
		const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, Range);
		ASSERT_THAT(IsTrue(Sema.ActOnFallthroughStmt(Fn, Range).IsValid(),
			TEXT("Clang-shaped ActOnFallthroughStmt must intern kind=Fallthrough without ActOnStmtFromNode")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("ActOnFallthroughStmt must dump kind=Fallthrough. dump:\n%s"),
			*Text);
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Fallthrough")), *DumpMsg));
	}
```

- [ ] **Step 2: Run RED (expect C2039, not a rewritten test)**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-ctrl-red
```

Expected: `C2039: ActOnBreakStmt is not a member of asCSema` (and Continue/Fallthrough). Do not rewrite the tests to call `ActOnBreak`.

---

### Task 2: Declare + implement dedicated actions

**Files:**
- Modify: `as_sema.h` — declare the three APIs next to `ActOnBreak` / `ActOnContinue` / `ActOnFallthrough`
- Modify: `as_sema_stmt.cpp` — implement using `FindExistingStmt` + builders + `NearestControl`

- [ ] **Step 1: Header declarations**

```cpp
asASTStmtId ActOnBreakStmt(asASTDeclId owner, const asCSourceRange& range);
asASTStmtId ActOnContinueStmt(asASTDeclId owner, const asCSourceRange& range);
asASTStmtId ActOnFallthroughStmt(asASTDeclId owner, const asCSourceRange& range);
```

Keep `ActOnBreak` / `ActOnContinue` / `ActOnFallthrough` as builders.

- [ ] **Step 2: Implement in `as_sema_stmt.cpp` (FindExistingStmt / NearestControl are file-static there)**

```cpp
asASTStmtId asCSema::ActOnBreakStmt(asASTDeclId owner, const asCSourceRange& range)
{
	const asASTStmtId existing = FindExistingStmt(context, asAST_STMT_BREAK, range);
	if( existing.IsValid() )
	{
		return existing;
	}
	return ActOnBreak(owner, NearestControl(context, controlStack, false), range);
}

asASTStmtId asCSema::ActOnContinueStmt(asASTDeclId owner, const asCSourceRange& range)
{
	const asASTStmtId existing = FindExistingStmt(context, asAST_STMT_CONTINUE, range);
	if( existing.IsValid() )
	{
		return existing;
	}
	return ActOnContinue(owner, NearestControl(context, controlStack, true), range);
}

asASTStmtId asCSema::ActOnFallthroughStmt(asASTDeclId owner, const asCSourceRange& range)
{
	const asASTStmtId existing = FindExistingStmt(context, asAST_STMT_FALLTHROUGH, range);
	if( existing.IsValid() )
	{
		return existing;
	}
	return ActOnFallthrough(owner, range);
}
```

Do not wire fallthrough `target=` here. That stays `FinishSwitchStmt` → `WireFallthroughTargets`. Do not check 5.6.

---

### Task 3: Dispatch FromNode / ActOnParsedStmt off the syntax walk intern

**Files:**
- Modify: `as_sema_decl.cpp` `ActOnParsedStmt` (`case snBreak` / `snContinue` / `snFallthrough` currently fall through to `ActOnStmtFromNode` at ~1753)
- Modify: `as_sema_stmt.cpp` FromNode `snBreak` / `snContinue` / `snFallthrough` (~690-715)

- [ ] **Step 1: `ActOnParsedStmt` extract-then-dedicated**

Replace the combined `snExpressionStatement` / `snBreak` / `snContinue` / `snFallthrough` arm. Keep `snExpressionStatement` on FromNode for this slice.

```cpp
	case snExpressionStatement:
		ActOnStmtFromNode(node, script, parsedFile, owner);
		return;
	case snBreak:
		{
			const asCSourceRange range = RangeOf(context.GetSourceManager(), parsedFile, node);
			ActOnBreakStmt(owner, range);
			return;
		}
	case snContinue:
		{
			const asCSourceRange range = RangeOf(context.GetSourceManager(), parsedFile, node);
			ActOnContinueStmt(owner, range);
			return;
		}
	case snFallthrough:
		{
			const asCSourceRange range = RangeOf(context.GetSourceManager(), parsedFile, node);
			ActOnFallthroughStmt(owner, range);
			return;
		}
```

- [ ] **Step 2: FromNode leftover becomes extract-then-dedicated**

```cpp
	case snBreak:
		return ActOnBreakStmt(owner, range);
	case snContinue:
		return ActOnContinueStmt(owner, range);
	case snFallthrough:
		return ActOnFallthroughStmt(owner, range);
```

`range` is already computed at the top of `ActOnStmtFromNode`. Keep FindExisting inside the dedicated APIs so WalkOne / Parser ActOn do not intern twice.

---

### Task 4: GREEN + record. Leave 13.2 `[ ]`

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-ctrl-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-ctrl-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-ctrl-compiler -TimeoutMs 600000
```

Expect: SemaAuthority **160/160** (157 + 3), CanonicalAST **200/200**, Compiler **388/388** unless live counts differ.

If CanonicalAST regresses (like LocalDecl 187/197): do **not** hide init/jumps inside a DeclStmt expr or nested Block. Control jumps are already sibling stmts.

Then:

- Copy each `Summary.json` under the label dir.
- Append `## B-control-jump` to `attachments/wave-b-results.md`.
- Patch `tasks.md` 13.2 **progress notes only**. Boxes stay `[ ]`.
- Do not mark 13.3 / 4.2 / 5.9 / 5.6 / later waves.

Done when: the three no-script-node dumps hold, Parser existing Break/Continue target tests still pass, Compiler prefix is green, and 13.2 is still open because FromNode remains for ternary/literals/ExprStmt/Case/WalkOne body and 4.2–5.9 is incomplete.
