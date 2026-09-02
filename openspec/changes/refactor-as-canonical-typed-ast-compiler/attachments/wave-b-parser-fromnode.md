# Wave B remaining FromNode interiors → Parser Sema actions

> **For exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild.ps1 -NoXGE` then the SemaAuthority prefix **before** filling `as_parser.cpp` / `as_sema*`. Do **not** check `tasks.md` 13.2 / 13.3 / 4.2 / 5.9. Do **not** start Wave D Task 6. Do **not** redo Wave C 2.4 / 2.8.

**Goal:** Parser Sema actions intern remaining statement/expression interiors during parse (including incomplete syntax that never reaches the second complete-function `NotifySema`), so sealed dumps record Break/Continue/Fallthrough targets, unary ops, expr-stmts, assignments, variable refs, bare return, and construct calls without waiting for `WalkOne` of a complete `asCScriptNode` tree.

This is **not** 13.2 close (production Bytecode is still `asCCompiler`) and **not** production `Build()` routing.

**Architecture:**

```text
legacy Parser → asCScriptNode (recovery)
  → incremental NotifySema / ActOnParsed*
        (existing) decls, calls, Cast/index/&&/ternary/lambda, return-with-value,
        assignment-missing-';', complete if/while/for/do-while/switch/foreach
  → THIS SLICE Parser ActOn at:
        ParseBreak / ParseContinue / ParseFallthrough
        ParseExpressionStatement success ';'
        ParseAssignment / ParseVariableAccess
        ParseExprPreOp / ParseExprTerm without postfix
        ParseReturn bare 'return;'
        ParseConstructCall after arg list
        control stub + controlStack push at loop/switch header after ')' BEFORE body
  → ActOnParsed* may still call FromNode as the implementation / recovery
        FindExisting* must reuse Parser-interned nodes on the later complete-function WalkOne
  → asCBuilder / asCCompiler                      (production Bytecode — do not route)
```

LLVM/Clang is a **shape reference only**. Do not link Clang/LLVM.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-parser-fromnode** |
| Mode | Exclusive UBT |
| UBT mutex | One UBT user in `D:\as-cta`. `-NoXGE`. CAEngine `UE4Editor`/`MSBuild`/`link` is **not** this lock |
| Scratch | `C:\Users\scottmei\AppData\Local\Temp\grok-goal-cafa12c46849\implementer` — copy SemaAuthority / CanonicalAST / Compiler logs here after GREEN |

## Global constraints

- Always `Set-Location D:\as-cta` then `Tools\RunBuild.ps1 -NoXGE` after new tests.
- Commands only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`.
- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null`; mixin **functions**; mutable script globals intern then `mutable-global-rejected`; `asEP_REQUIRE_ENUM_SCOPE=1`; host `RegisterFuncdef` allowed; script `float` stays `"float"`.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Native Core layer: existing file `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.
- **Hard no:** CALL-without-callee as seal/verifier firewall. `asCASTVerify` must still succeed on unsealed graphs. Do not invent stmt-level cleanup-plan POD fields.
- Do not edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, `as_ast_verifier.cpp` firewall, or `as_bytecode_codegen.cpp`.
- Do not mark `tasks.md` 13.2 / 13.3 / 4.2 / 5.9 / 9.1 / 13.6 / section 10.
- Do not archive. Do not commit.
- Never All. Never production `Build()` routing. Never flip `Ready()` / default CANONICAL.

## Files

- Modify tests: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- Modify parser: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
- Modify Sema: `as_sema.h`, `as_sema.cpp`, `as_sema_stmt.cpp`, `as_sema_expr.cpp`, `as_sema_decl.cpp` (only if `ActOnParsed*` / control-stack API needs it)
- Optional dump: `as_ast_dump.cpp` only if Break `target=` / Unary facts cannot be asserted with the current printer. Reuse `kind=` / `target=` / `callee=` / `name=`.
- Evidence: append counts to this file after GREEN; do not rewrite `tasks.md` boxes.

Reuse existing helpers in the SemaAuthority file: `FNativeTestEngine`, `CreateBuilderModule`, `Parser.SetSema`, `asCASTDump`, `CanonicalAstDumpToFString`. Copy the shape of `ParserActOnAssignBeforeSemicolonFails` / `ParserActOnAssignDoesNotDuplicateOnSuccessfulParse` / `ParserActOnWhileBodyBeforeBlockCloseFails`.

## Why these tests are RED today (do not “fix” the test)

`ParseFunction` `NotifySema`s after name+params **before** the body exists. The body is then parsed. `ParseScript` does a **second** `NotifySema(decl)` only when `!isSyntaxError` (~2661). That second call `WalkOne`s the complete `snFunction` including the body.

Honest RED window: inner construct is finished (or finished-enough) **and** the function is still a syntax error (missing `}`), so the second `NotifySema` never runs, **and** the parent control/block does not `ActOnParsedStmt` that inner node.

Do **not** assert only `kind=Break` inside `while (1) { break` missing `}` — `ParseWhile` already `ActOnParsedStmt`s on body error and FromNode-walks Break. That test would pass immediately and prove the wrong authority.

Do **not** weaken DoesNotDuplicate tests to `AssignCount >= 1` or accept DeclId 0.

---

### Task 1: Expression-statement success `;` without complete-function WalkOne

**Files:** SemaAuthority tests; then `ParseExpressionStatement` in `as_parser.cpp`.

- [ ] **Step 1: Write the failing tests** (append near the other `ParserActOn*` methods)

```cpp
TEST_METHOD(ParserActOnExprStmtSuccessBeforeFunctionCloseFails)
{
	// ParseExpressionStatement success ';' does not ActOn.
	// Missing function '}' skips ParseScript's second NotifySema.
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaActionOnlyExprStmt");
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaActionOnlyExprStmt module")));
	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptCode Code;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int F(int x)
		{
			return x;
		}

		int F(float x)
		{
			return 0;
		}

		int Entry()
		{
			F(1);
	)AS");
	Code.SetCode("SemaActionOnlyExprStmt.as", ScriptSource.c_str(), true);

	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	asCParser Parser(&Builder);
	Parser.SetSema(&Sema);
	const int ParseResult = Parser.ParseScript(&Code);
	ASSERT_THAT(IsTrue(ParseResult < 0, TEXT("function missing '}' must fail parse")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("Parser must ActOn the complete 'F(1);' expr-stmt before the missing '}'. dump:\n%s"), *Text);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("callee=F(int)")), *DumpMsg));
	ASSERT_THAT(IsFalse(Text.Contains(TEXT("callee=F(float)")), *DumpMsg));
}

TEST_METHOD(ParserActOnExprStmtDoesNotDuplicateOnSuccessfulParse)
{
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaActionOnlyExprStmtOnce");
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaActionOnlyExprStmtOnce module")));
	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptCode Code;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int F(int x)
		{
			return x;
		}

		int F(float x)
		{
			return 0;
		}

		int Entry()
		{
			return F(1);
		}
		)AS");
	Code.SetCode("SemaActionOnlyExprStmtOnce.as", ScriptSource.c_str(), true);

	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	asCParser Parser(&Builder);
	Parser.SetSema(&Sema);
	ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("complete expr-stmt path must parse")));
	ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("action-only expr-stmt graph should verify")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("Parser expr-stmt action plus WalkOne must intern one F(int) call. dump:\n%s"), *Text);
	TArray<FString> Lines;
	Text.ParseIntoArrayLines(Lines);
	int32 CalleeInt = 0;
	for (const FString& Line : Lines)
	{
		if (Line.Contains(TEXT("callee=F(int)")))
		{
			++CalleeInt;
		}
	}
	ASSERT_THAT(AreEqual(1, CalleeInt, *DumpMsg));
	ASSERT_THAT(IsFalse(Text.Contains(TEXT("callee=F(float)")), *DumpMsg));
}
```

Note: `ParserActOnExprStmtDoesNotDuplicateOnSuccessfulParse` uses `return F(1);` because `ParseReturn` already ActOn's after the value. The **new** hole is the first test (`F(1);` as expr-stmt). If the DoesNotDuplicate case for a pure expr-stmt `F(1); return 0;` is easier to count, prefer that after Task 1 GREEN and assert a single `kind=Call` / `callee=F(int)`.

- [ ] **Step 2: Rebuild and watch RED**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -TimeoutMs 1800000 -Label b-parser-fromnode-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label b-parser-fromnode-red -TimeoutMs 600000
```

Expected: new methods FAIL because `callee=F(int)` is missing on the incomplete function (success `;` never ActOn; missing `}` skips WalkOne). Fail for missing feature, not compile error.

- [ ] **Step 3: Minimal GREEN**

In `ParseExpressionStatement`, after a successful `;` (the path that currently `return node` at ~4608 with no Sema call), call `sema->ActOnParsedStmt(node, script)` the same way the missing-`;` path already does at ~4601. Keep `FindExistingStmt` so complete-parse WalkOne does not duplicate.

- [ ] **Step 4: Re-run SemaAuthority. Expect the two new methods PASS. Existing ParserActOn* stay green.**

---

### Task 2: Break / Continue / Fallthrough Parser ActOn

**Files:** SemaAuthority tests; `ParseBreak` / `ParseContinue` / `ParseFallthrough`.

Honest RED (no enclosing while that ActOn's on body error):

```cpp
TEST_METHOD(ParserActOnBreakBeforeFunctionCloseFails)
{
	// ParseBreak never ActOn. Missing '}' skips complete-function WalkOne.
	// No while parent, so FromNode cannot intern Break.
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			break;
	)AS");
	// parse fails; dump must contain kind=Break
}

TEST_METHOD(ParserActOnBreakBeforeSemicolonFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			break
	)AS");
	// parse fails; dump must contain kind=Break
}

TEST_METHOD(ParserActOnContinueBeforeFunctionCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			continue;
	)AS");
	// parse fails; dump must contain kind=Continue
}

TEST_METHOD(ParserActOnFallthroughBeforeFunctionCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry(int n)
		{
			switch (n)
			{
			case 1:
				fallthrough;
	)AS");
	// parse fails. Dump must contain kind=Fallthrough.
	// Switch may already intern from ParseSwitch body-error ActOn; Fallthrough today
	// is only a ParseCase child with no ActOn — if parent FromNode already interned
	// it, this test is the wrong window. Prefer a switch-less 'fallthrough;' at
	// function scope if the dialect accepts that token there; otherwise keep this
	// fixture and assert Fallthrough exists even when the case list is incomplete.
}
```

Also add DoesNotDuplicate for complete:

```as
int Entry()
{
	while (1)
	{
		break;
	}
	return 0;
}
```

Assert exactly one `kind=Break`. Same for Continue. For Fallthrough, complete:

```as
int Entry(int n)
{
	switch (n)
	{
	case 1:
		fallthrough;
	default:
		break;
	}
	return 0;
}
```

Assert one `kind=Fallthrough`.

GREEN: `ParseBreak` / `ParseContinue` / `ParseFallthrough` call `sema->ActOnParsedStmt(node, script)` after `;` **and** on missing `;` (after `Error(ExpectedToken(";"))`), matching `ParseExpressionStatement` missing-`;`. `FindExistingStmt` already keys on kind+file+offset.

---

### Task 3: Unary / ExprTerm without postfix

Honest RED: unary minus as a finished-enough expr-stmt whose function never WalkOne's.

```cpp
TEST_METHOD(ParserActOnUnaryMinusBeforeFunctionCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			-1;
	)AS");
	// parse fails (missing '}'). Dump must contain a Unary / opNeg fact.
	// Accept either kind=Unary with the minus, or callee=opNeg if a rewrite fires.
	// Must not be only IntegerLiteral 1 with the sign dropped.
}
```

If `-1` tokenizes as a single negative integer constant in this fork, use a prefix on a non-literal:

```as
int Entry(int i)
{
	-i;
```

GREEN: `ParseExprTerm` ActOnParsedExpr when any `snExprPreOp` child exists, not only postfix. Optionally also ActOn after preops even if `ParseExprValue` then fails (`int Entry() { -`). Do not ActOn `ParseExprPreOp` alone without a term if that would intern a unary with a null inner — prefer ActOn the ExprTerm after the operand when present, and on syntax error after the preop list if the operand is missing.

`FindExistingExpr` already keys on kind+file+offset.

---

### Task 4: Assignment success `;` and VariableAccess

`ParserActOnAssignBeforeSemicolonFails` already covers missing `;`. Add the success-`;` incomplete-function window:

```cpp
TEST_METHOD(ParserActOnAssignSuccessBeforeFunctionCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry(int i)
		{
			i = 1;
	)AS");
	// parse fails; dump must contain kind=Assign and kind=Param name=i
}

TEST_METHOD(ParserActOnVariableAccessBeforeFunctionCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry(int i)
		{
			i;
	)AS");
	// parse fails; dump must contain Param name=i as a DeclRef / expr-stmt
}
```

GREEN: `ParseExpressionStatement` success ActOn (Task 1) plus `ParseAssignment` ActOnParsedExpr after both sides when an assign op was parsed, and `ParseVariableAccess` ActOnParsedExpr after the identifier. FindExisting prevents duplicates with `ParserActOnAssignDoesNotDuplicateOnSuccessfulParse`.

---

### Task 5: Bare `return;` and ConstructCall

```cpp
TEST_METHOD(ParserActOnBareReturnBeforeFunctionCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		void Entry()
		{
			return;
	)AS");
	// parse fails; dump must contain kind=Return
}

TEST_METHOD(ParserActOnConstructCallBeforeArgListCloseFails)
{
	// ParseConstructCall is TYPE ARGLIST, not identifier FUNCCALL.
	// Existing ParserActOnConstructTemporaryBeforeArgListCloseFails uses `return FValue(`
	// which is ParseFunctionCall (already ActOn). Use a real type construct:
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		class T
		{
		}

		int Entry()
		{
			T(
	)AS");
	// If this fixture still hits FUNCCALL, switch to a builtin/value construct the
	// parser classifies as CONSTRUCTCALL. Dump must show Construct / MaterializeTemporary
	// / callee=T::T() as appropriate. Do not add script '@'.
}
```

GREEN: `ParseReturn` ActOnParsedStmt on the `ttEndStatement` early-return path (~5304) as well as the value path. `ParseConstructCall` ActOnParsedExpr after `ParseArgList` (and on arg-list syntax error if children already exist).

---

### Task 6: Clang-shaped control stack at header after `)` before body

This is the slice that makes Break/Continue **targets** Parser facts during the body, not after FromNode of the complete While.

Add tests:

```cpp
TEST_METHOD(ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			while (1)
			{
				break;
	)AS");
	// parse fails. Dump must contain kind=While, kind=Break, and Break target= matching
	// the While id (STMT ... kind=Break ... target=N with a While id=N).
}

TEST_METHOD(ParserActOnContinueRecordsForTargetBeforeBodyCloseFails)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			for (;;)
			{
				continue;
	)AS");
	// parse fails. Continue target= must match the For id.
}

TEST_METHOD(ParserActOnBreakRecordsSwitchTargetOnSuccessfulParse)
{
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry(int n)
		{
			switch (n)
			{
			default:
				break;
			}
			return 0;
		}
		)AS");
	// complete parse + Seal. One Break whose target= is the Switch id. No duplicates.
}
```

**Do not** ActOn the complete While after `)` before the body — that was the old bug (`ParserActOnWhileBeforeCloseParenFails` locks that the incomplete `)` path may ActOn, but the successful `)` must wait for the body).

Required shape:

1. Expose `asCSema::PushControl(asASTStmtId)` / `PopControl()` (controlStack is currently private).
2. After successful `)` in `ParseWhile` / `ParseFor` / `ParseSwitch` / `ParseForeach` (and after `do` STATEMENT starts for do-while: push after intern of the DoWhile stub **before** the body statement): intern a **stub** control stmt (`ActOnWhile`/`ActOnFor`/`ActOnSwitch`/`ActOnDoWhile`/`ActOnForeach` with empty body), `PushControl(stub)`, then parse the body, then `ActOnParsedStmt` of the complete node.
3. Change `ActOnStmtFromNode` FindExisting early-return for While/For/Switch/DoWhile/Foreach: if the existing stub has no cond/body yet, **fill** `SetStmtExpr` / children instead of returning the empty stub. Then `PopControl` once.
4. `ParseBreak` / `ParseContinue` (Task 2) then see `NearestControl` during the body parse.

Do not push at `case` `:`. Fallthrough target remains “next case” when the switch finishes (already in `ActOnStmtFromNode` snSwitch).

---

### Task 7: Prefixes (leave boxes `[ ]`)

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -TimeoutMs 1800000 -Label b-parser-fromnode-green
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label b-parser-fromnode-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label b-parser-fromnode-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label b-parser-fromnode-compiler -TimeoutMs 600000
```

Copy logs to `{SCRATCH}/sema-authority.log`, `canonical-ast.log`, `compiler.log`.

Record exact `N/N` in this file. **Leave `tasks.md` 13.2 / 13.3 / 4.2 / 5.9 `[ ]`.** Patch only the progress notes if a count changed.

If a new test PASSES immediately, it is testing WalkOne / parent FromNode — rewrite the fixture to the incomplete-function window described above. Do not “green” by asserting something the old walk already provided.

## Done when

- New ParserActOn* methods were watched RED, then GREEN.
- SemaAuthority prefix green including the new methods.
- CanonicalAST and Compiler prefixes green (regression).
- 13.2 / 13.3 still `[ ]`.
- Production `Build()` still `asCCompiler`. `Ready()` still false. Default still LEGACY.
- Wave C 2.4 / 2.8 / 13.4 / 13.5 untouched.

## Evidence (fill after GREEN)

| Prefix | Label | Result |
| --- | --- | --- |
| SemaAuthority | b-parser-fromnode-sema | 128/128 PASS |
| Compiler CanonicalAST | b-parser-fromnode-canonical | 143/143 PASS |
| Compiler | b-parser-fromnode-compiler | 331/331 PASS |
