# Wave B exclusive UBT — 5.6 remaining safe-point roles + control-target verifier oracles (B-56-safepoint)

> **For the later exclusive-UBT worker:** REQUIRED SUB-SKILL: `superpowers:test-driven-development`. Write the failing methods **first**. `RunBuild.ps1 -NoXGE` then SemaAuthority / Verifier **before** filling `as_sema*` / dump / verifier. Do **not** check `tasks.md` 5.6 / 13.2.

**Goal:** Exact remaining 5.6 hole: dump-lock **safe-point roles** on compile→seal, and add the verifier oracles 5.6 still names (wrong-kind, non-ancestor, skipped-nearer, dangling, duplicate-case/default-order, invalid fallthrough) **without** reopening Wave C 2.8.

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode (recovery)
  → dedicated ActOn* intern (If / While / For / Switch / Break / Continue / Fallthrough landed)
  → controlStack + NearestControl (continue skips switch; break accepts loop|switch)
  → FinishSwitchStmt → WireFallthroughTargets (next Case)
  → dump STMT target= / For init= body= incr= / If then= else=
  → asCASTVerify: ancestor/wrong-kind/dangling-id/duplicate-case/duplicate-default/fallthrough-switch
  → CANONICAL Build fail-closes on Sema / Seal; LEGACY still asCCompiler
```

LLVM/Clang is a **shape reference only**. Do not link Clang/LLVM. HIR `asETypedSemanticSafePointRole` is the **oracle name list**, not a type to reuse on AST nodes.

This is **not** 13.2 close. Named For/If phases are **already landed** — do not redo them. LEGACY still `asCCompiler`.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-56-safepoint** (`attachments/async-work.md` §7) |
| Mode now | **Attachment only.** Do not edit `Plugins/` production/test sources. Do not run UBT / `RunBuild` / `RunTests`. Do not mark `tasks.md` 5.6 / 13.2. Do not commit. Do not archive. |
| Mode later | Exclusive UBT after **B-param-identity GREEN**. TDD. One UBT user. Always `-NoXGE`. |
| Do not mark | 5.6 / 13.2 / 13.3 / 5.4 / 5.9 / 4.2 / 9.5 |
| 2.8 firewall | **CLOSED.** Do not reopen CALL-without-callee. `asCASTVerify` must still succeed on unsealed graphs (`Seal()` calls it **before** `sealed=true`). |

---

## Global constraints

- Fork dialect unchanged: no script `funcdef` / `@` / `is`; `nullptr` = `ttNull`; mixin **functions**; mutable script globals intern then reject; host `RegisterFuncdef` legal; source `try` / `catch` stays rejected. No C labeled break.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE`. `RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after impl.
- **Hard no:** CALL-without-callee as a seal/verifier firewall. Default `canonicalCompilerPipeline = true`. CANONICAL `CompileFunction`. Check 5.6 / 13.2 from prefix green. Second UBT in `D:\as-cta`. Invent stmt-level cleanup-plan POD fields (CLEANUP / MATERIALIZE stay expr kinds). Reuse `literalBits` for a role (that field is Call `receiver=`).
- Do **not** make `asCASTVerify` require a safe-point role to be present. Default `None` must still verify, or `RepeatedBuildsDumpIdenticallyWithoutPointers` and every construction-API fixture fail Seal.
- Do **not** rewrite `ForStmtRecordsNamedPhasesOnCompileSealPath` / `IfStmtRecordsNamedThenElseOnCompileSealPath` / `ContinueTargetsEnclosingWhileOnCompileSealPath` / `BreakTargetsNearestSwitchNotOuterLoop` / `FallthroughTargetsNextCase`. Additive tokens only.
- Do not edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, or `as_bytecode_codegen.cpp`. Do not flip Wave G.

---

## 1. Honest landed vs remaining

Cite dump tokens as they exist **now**. SemaAuthority **199/199** `wave-b-sema-phases-sema` (then **200/202** `wave-b-param-sema` — identity RED is **B-param-identity**, not this package).

### Already landed (do not redo)

| Fact | Dump / verifier token | TEST_METHOD |
| --- | --- | --- |
| Continue → enclosing While | STMT `kind=Continue` + `target=` (Atoi `> 0`; While present) | `ContinueTargetsEnclosingWhileOnCompileSealPath` |
| Break → nearest Switch, not outer While | Break `target=` equals Switch id, not While id | `BreakTargetsNearestSwitchNotOuterLoop` |
| Fallthrough → next Case, not Switch | Fallthrough `target=` equals second `kind=Case` id | `FallthroughTargetsNextCase` |
| Clang ForStmt named phases | `kind=For` line `init=` / `body=` / `incr=` (three distinct >0 ids) | `ForStmtRecordsNamedPhasesOnCompileSealPath` |
| Clang IfStmt named arms | `kind=If` line `then=` / `else=` (two distinct >0 ids) | `IfStmtRecordsNamedThenElseOnCompileSealPath` |
| Break non-ancestor | `asAST_VERIFY_WRONG_KIND` / `break-ancestor` | `RejectsBreakTargetNotAncestor` |
| Continue / Break wrong-kind target | `continue-target` / `break-target` (code; no dedicated continue-to-switch test) | verifier loop at `as_ast_verifier.cpp` ~266–289 |
| Dangling stmt target / expr | `stmt-target` / `ctrl-target` / `stmt-expr` (code; no dedicated named test) | verifier ~237–240, ~266–273 |
| Duplicate case constant / duplicate default | `duplicate-case` / `duplicate-default` (code; **no tests**) | verifier ~291–322 |
| Fallthrough not under Switch | `fallthrough-switch`; missing owner `fallthrough-owner` | `RejectsFallthroughOutsideSwitch` |
| Unsealed publication vs unsealed verify | `asCASTVerify` OK unsealed; `asCASTVerifyPublication` `unsealed-publication` | `RejectsUnsealedPublication` |
| 2.8 remainder | stmt-multi-owner, stmt-cycle, cleanup-dtor, CALL-without-callee **hard no** | Wave C closed |

Current STMT dump (`as_ast_dump.cpp` ~203–253):

```text
STMT id=%u kind=%s expr=%u children=%s [target=%u] [init=%u body=%u incr=%u | then=%u else=%u | body=%u | vars=%u body=%u]
```

**There is no `safepoint=` field and no role enum on `asCStmt` / `asCExpr`.** `as_stmt.h` is `id/kind/owner/range/target/expr/decl/children`. `as_expr.h` is `id/kind/range/type/valueCategory/resolvedDecl/literal/literalBits/children`. HIR dump token `safePoint=Return` lives only on `asSTypedSemanticStatement` / `asSTypedSemanticExpression`.

### Remaining 5.6 hole (this package)

Task 5.6 original meaning: structured control targets **and** source-order phases **and** verifier reject wrong-kind / non-ancestor / skipped-nearer / dangling / duplicate-case/default-order / invalid fallthrough, using migrated HIR control tests. Phases + nearest targets dump. **Safe-point roles do not. Several named verifier oracles have no tests, and skipped-nearer / default-order / fallthrough-target-is-next-case are not coded.**

| Remaining | Kind | Now | This package |
| --- | --- | --- | --- |
| Safe-point roles | dump | **not a dump field** | smallest new token `safepoint=` + `asEASTSafePointRole` |
| skipped-nearer | verifier | ancestor-only (`StmtContains`); HIR requires **nearest** legal ancestor | RED `break-skipped-nearer` / `continue-skipped-nearer` |
| default-order | verifier | duplicate-default only; HIR + current compiler `TXT_DEFAULT_MUST_BE_LAST` | RED `default-order` |
| invalid fallthrough edge | verifier | under-switch only; dump already locks next-Case on the happy path | RED `fallthrough-target` when `target` is set and is not the next Case |
| duplicate-case | verifier | code, no test | oracle lock (likely GREEN immediately) |
| dangling target | verifier | code `stmt-target`, no dedicated test | fold into skipped-nearer file as a sibling method **or** skip if count must stay 4 — see Task 3 |
| wrong-kind / non-ancestor | verifier | coded; break-ancestor tested | do not reopen; do not require missing `target` |

**Verdict:** remaining 5.6 is **not dump-only**. It is **dump-lock safe-point roles plus verifier oracles** (skipped-nearer, default-order, invalid fallthrough target; duplicate-case as a lock). It is still **not** 5.6 close after this slice if backends still rerun `asCCompiler` and HIR control tests are not fully migrated (SwitchInvalidValue / Statement-on-every-stmt / cleanup-on-transfer). **Leave 5.6 `[ ]`.**

### Smallest dump token (required — field does not exist)

Add **one** role enum and **one** dump key. Do **not** invent cleanup-plan arrays, loop-phase POD, or stmt-level lifetime lists.

```cpp
// as_ast_kind.h — names match HIR ToString(), type is AST-local
enum asEASTSafePointRole : asBYTE
{
	asAST_SAFEPOINT_NONE = 0,
	asAST_SAFEPOINT_POSITION,
	asAST_SAFEPOINT_FUNCTION_ENTRY,
	asAST_SAFEPOINT_STATEMENT,
	asAST_SAFEPOINT_CALL,
	asAST_SAFEPOINT_LOOP_ENTRY,
	asAST_SAFEPOINT_LOOP_BACKEDGE,
	asAST_SAFEPOINT_TRANSFER,
	asAST_SAFEPOINT_SWITCH_INVALID_VALUE,
	asAST_SAFEPOINT_RETURN,
};
```

Where it lives:

| Node | Field | When Sema sets it | Dump |
| --- | --- | --- | --- |
| `asCStmt` | `asEASTSafePointRole safePointRole` (default `NONE`) | Function body Block → `FUNCTION_ENTRY`; While/For/DoWhile/Foreach stmt → `LOOP_BACKEDGE`; that loop's **body child** → `LOOP_ENTRY`; Return → `RETURN`; Break/Continue → `TRANSFER` | append ` safepoint=FunctionEntry` (etc.) only when `!= NONE` |
| `asCExpr` | same field | `asAST_EXPR_CALL` in `ActOnCall` → `CALL` | append ` safepoint=Call` on the Call/Construct line only when `!= NONE` |

Construction APIs (2.4; do not poke POD from tests):

```cpp
int SetStmtSafePointRole(asASTStmtId id, asEASTSafePointRole role);
int SetExprSafePointRole(asASTExprId id, asEASTSafePointRole role);
```

Copy `SetTarget` (`as_ast_context.cpp` ~689–701). Init the field in `asCStmt` / `asCExpr` constructors to `asAST_SAFEPOINT_NONE`.

Dump placement: **after** existing named phases so a For line stays:

```text
STMT id=N kind=For expr=E children=A,B,C init=A body=B incr=C safepoint=LoopBackedge
```

Do **not** dump `safepoint=None`. Do **not** require `safepoint=Statement` on every If/Decl this slice (HIR does; backends need entry/backedge/call/transfer/return first). Defer `SwitchInvalidValue` / `Position` (no test in the four methods).

HIR name list for dump strings (must match exactly): `FunctionEntry`, `LoopEntry`, `LoopBackedge`, `Call`, `Transfer`, `Return`.

---

## 2. File map

| Path | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | One compile→seal dump method after `IfStmtRecordsNamedThenElseOnCompileSealPath` (~1541) |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` | Three methods after `RejectsCleanupResolvedDeclNotDestructor` (~201) |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_kind.h` | `asEASTSafePointRole` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_stmt.h` | `safePointRole` field + ctor init |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_expr.h` | `safePointRole` field + ctor init |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_context.h/.cpp` | `SetStmtSafePointRole` / `SetExprSafePointRole` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | append `safepoint=` when role `!= NONE` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp` | set loop/return/transfer/function-entry roles |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp` | `ActOnCall` → Call role; `ActOnBreak` / `ActOnContinue` → Transfer (or stmt file) |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` | `AttachParsedFunctionBody` (~1142) set `FUNCTION_ENTRY` on the body Block |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp` | skipped-nearer; default-order; fallthrough-target. **Do not** require role presence. **Do not** require CALL `resolvedDecl` |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-b-results.md` | later UBT: copy `Summary.json`, record counts |
| `tasks.md` 5.6 | **progress note only**. Box stays `[ ]` |

Do **not** add files. Do **not** touch `as_typed_semantic_ir.*` (HIR stays the migration oracle, not the AST store).

### Overlap with 5.4 (B-54-single-eval)

| File | 5.4 | 5.6 | Conflict |
| --- | --- | --- | --- |
| `as_sema_expr.cpp` / `as_sema.cpp` `ActOnSequence` | OpaqueValue / Sequence wrap | `ActOnCall` sets Call role | **yes** — serialize `ActOnCall` / `as_sema.cpp` |
| `as_expr.h` | Sequence children / maybe extra expr field | `safePointRole` on expr | **yes** — one POD field add each; merge if both land |
| `as_ast_dump.cpp` | Sequence / single-eval tokens | `safepoint=` | **yes** — dump.cpp must be one writer at a time |
| `as_ast_kind.h` | maybe OpaqueValue kind | `asEASTSafePointRole` | low — different enums |
| `as_ast_context.h/.cpp` | maybe Sequence helpers | `Set*SafePointRole` | low — additive APIs |
| `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | append methods | append methods | low — append-only |
| `as_sema_stmt.cpp` / `as_stmt.h` | no | **this package** | none |
| `as_ast_verifier.cpp` / Verifier tests | no | **this package** | none |

**Gate vs 5.4:** no semantic dependency. May run **after or beside** 5.4. They **share** `as_ast_dump.cpp`, `as_expr.h`, and `ActOnCall` in `as_sema.cpp`. Beside is allowed only as **sequential exclusive UBT** (never two UBT users). If 5.4 is in-flight, wait. If 5.4 has not started, 5.6 may go first (stmt/verifier meat does not need Sequence).

**Hard gate:** after **B-param-identity GREEN**. That package currently owns SemaAuthority (200/202) and `as_sema_decl.cpp`. Do not start this UBT while identity is red or while that worker holds the mutex.

---

## 3. Four TEST_METHOD names (TDD)

Prefer SemaAuthority compile→seal dumps. Verifier tests use construction APIs on **unsealed** graphs and must leave `asCASTVerify` OK on legal unsealed graphs.

### Task 1 — failing dump test (RED: no `safepoint=`)

**Files:** SemaAuthority tests, after `IfStmtRecordsNamedThenElseOnCompileSealPath`.

- [ ] **Step 1: Add this method. Do not add the enum/field yet.**

```cpp
	TEST_METHOD(LoopReturnCallAndTransferRecordSafePointRolesOnCompileSealPath)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));

		asIScriptModule* const Module = ScriptEngine->GetModule("SemaSafePoint", asGM_ALWAYS_CREATE);
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaSafePoint module")));
		ASSERT_THAT(AreEqual(0, Module->SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)));
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int Target(int Value)
			{
				return Value + 1;
			}

			int Entry()
			{
				int I = 0;
				while (I < 1)
				{
					I = Target(I);
					if (I > 0)
					{
						break;
					}
					continue;
				}
				return I;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, Module->AddScriptSection("SemaSafePoint.as", ScriptSource.c_str())));
		asCString Dump;
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst(Module, Dump),
			TEXT("safe-point module must seal a dumpable AST")));
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("compile→seal must dump safepoint= on loop/return/call/transfer. dump:\n%s"), *Text);

		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		bool bWhileBackedge = false;
		bool bBodyEntry = false;
		bool bReturnRole = false;
		bool bCallRole = false;
		bool bBreakTransfer = false;
		bool bContinueTransfer = false;
		bool bFunctionEntry = false;
		int32 WhileBodyId = 0;
		for (const FString& Line : Lines)
		{
			if (Line.Contains(TEXT("kind=While")) && Line.Contains(TEXT("safepoint=LoopBackedge")))
			{
				bWhileBackedge = true;
				const int32 BodyAt = Line.Find(TEXT("body="));
				if (BodyAt != INDEX_NONE)
				{
					WhileBodyId = FCString::Atoi(*Line.Mid(BodyAt + 5));
				}
			}
			if (Line.Contains(TEXT("kind=Return")) && Line.Contains(TEXT("safepoint=Return")))
			{
				bReturnRole = true;
			}
			if (Line.Contains(TEXT("kind=Call")) && Line.Contains(TEXT("callee=Target(int)"))
				&& Line.Contains(TEXT("safepoint=Call")))
			{
				bCallRole = true;
			}
			if (Line.Contains(TEXT("kind=Break")) && Line.Contains(TEXT("safepoint=Transfer")))
			{
				bBreakTransfer = true;
			}
			if (Line.Contains(TEXT("kind=Continue")) && Line.Contains(TEXT("safepoint=Transfer")))
			{
				bContinueTransfer = true;
			}
			if (Line.Contains(TEXT("kind=Block")) && Line.Contains(TEXT("safepoint=FunctionEntry")))
			{
				bFunctionEntry = true;
			}
		}
		if (WhileBodyId > 0)
		{
			for (const FString& Line : Lines)
			{
				if (!Line.Contains(TEXT("STMT id=")))
				{
					continue;
				}
				const int32 IdBegin = Line.Find(TEXT("id="));
				const int32 Id = FCString::Atoi(*Line.Mid(IdBegin + 3));
				if (Id == WhileBodyId && Line.Contains(TEXT("safepoint=LoopEntry")))
				{
					bBodyEntry = true;
				}
			}
		}

		ASSERT_THAT(IsTrue(bWhileBackedge, *DumpMsg));
		ASSERT_THAT(IsTrue(bBodyEntry, *DumpMsg));
		ASSERT_THAT(IsTrue(bReturnRole, *DumpMsg));
		ASSERT_THAT(IsTrue(bCallRole, *DumpMsg));
		ASSERT_THAT(IsTrue(bBreakTransfer, *DumpMsg));
		ASSERT_THAT(IsTrue(bContinueTransfer, *DumpMsg));
		ASSERT_THAT(IsTrue(bFunctionEntry, *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Continue")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("target=")), *DumpMsg));
	}
```

Do **not** assert `safepoint=Statement` on the `if` or local Decl. Do **not** touch For `init=`/`body=`/`incr=` asserts (that test stays as-is). Keep Continue `target=` still present.

- [ ] **Step 2: RED**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-56-red -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-56-sema-red -TimeoutMs 600000
```

Expected: method compiles; dump asserts fail because no `safepoint=`. If Build fails with C2039 on a type you already used in the test, you jumped ahead — tests must compile against **current** headers (parse the dump string only; do not name `asEASTSafePointRole` in the dump test).

---

### Task 2 — three failing verifier methods (do not break unsealed OK)

**Files:** `AngelscriptNativeCanonicalASTVerifierTests.cpp`. Construction APIs only (`CreateStmt`, `AddStmtChild`, `SetTarget`, `SetStmtExpr`, `CreateExpr`). Do **not** write `stmt->safePointRole` through a raw pointer. Do **not** `Seal()` these negative fixtures.

- [ ] **Step 1: Add these three methods.**

```cpp
	TEST_METHOD(RejectsBreakSkippedNearerLoop)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("SkipV");
		const asASTStmtId Outer = Context.CreateStmt(asAST_STMT_WHILE, Tu, asCSourceRange());
		const asASTStmtId Inner = Context.CreateStmt(asAST_STMT_WHILE, Tu, asCSourceRange());
		const asASTStmtId Brk = Context.CreateStmt(asAST_STMT_BREAK, Tu, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Outer, Inner), TEXT("inner under outer")));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Inner, Brk), TEXT("break under inner")));
		ASSERT_THAT(AreEqual(0, Context.SetTarget(Brk, Outer), TEXT("break skips inner, targets outer")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_WRONG_KIND, asCASTVerify(Context, Result),
			TEXT("break must target the nearest enclosing loop or switch, not a skipped outer loop")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("break-skipped-nearer"),
			TEXT("detail token must be break-skipped-nearer")));

		asCASTContext Dangling;
		const asASTDeclId DTu = Dangling.CreateTranslationUnit("DangleV");
		const asASTStmtId Loop = Dangling.CreateStmt(asAST_STMT_WHILE, DTu, asCSourceRange());
		const asASTStmtId DBrk = Dangling.CreateStmt(asAST_STMT_BREAK, DTu, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Dangling.AddStmtChild(Loop, DBrk), TEXT("break under loop")));
		ASSERT_THAT(AreEqual(0, Dangling.SetTarget(DBrk, asASTStmtId(99)), TEXT("dangling target id")));
		asSAstVerifyResult DanglingResult;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_DANGLING_ID, asCASTVerify(Dangling, DanglingResult),
			TEXT("break target must resolve in the stmt table")));
		ASSERT_THAT(IsTrue(
			DanglingResult.detail.Equals("stmt-target") || DanglingResult.detail.Equals("ctrl-target"),
			TEXT("detail token must stay stmt-target or ctrl-target")));
	}

	TEST_METHOD(RejectsDuplicateCaseAndDefaultNotLast)
	{
		asCASTContext Dup;
		const asASTDeclId Tu = Dup.CreateTranslationUnit("DupCaseV");
		const asCQualType IntType = Dup.InternPrimitive(ttInt, 0);
		const asASTStmtId Sw = Dup.CreateStmt(asAST_STMT_SWITCH, Tu, asCSourceRange());
		const asASTStmtId CaseA = Dup.CreateStmt(asAST_STMT_CASE, Tu, asCSourceRange());
		const asASTStmtId CaseB = Dup.CreateStmt(asAST_STMT_CASE, Tu, asCSourceRange());
		const asASTExprId LitA = Dup.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		const asASTExprId LitB = Dup.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Dup.SetLiteral(LitA, "1")));
		ASSERT_THAT(AreEqual(0, Dup.SetLiteral(LitB, "1")));
		ASSERT_THAT(AreEqual(0, Dup.SetLiteralBits(LitA, 1)));
		ASSERT_THAT(AreEqual(0, Dup.SetLiteralBits(LitB, 1)));
		ASSERT_THAT(AreEqual(0, Dup.SetStmtExpr(CaseA, LitA)));
		ASSERT_THAT(AreEqual(0, Dup.SetStmtExpr(CaseB, LitB)));
		ASSERT_THAT(AreEqual(0, Dup.AddStmtChild(Sw, CaseA)));
		ASSERT_THAT(AreEqual(0, Dup.AddStmtChild(Sw, CaseB)));
		asSAstVerifyResult DupResult;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_INVALID_CHILD, asCASTVerify(Dup, DupResult),
			TEXT("duplicate normalized case constants must fail")));
		ASSERT_THAT(IsTrue(DupResult.detail.Equals("duplicate-case"),
			TEXT("detail token must be duplicate-case")));

		asCASTContext Order;
		const asASTDeclId OTu = Order.CreateTranslationUnit("DefOrderV");
		const asASTStmtId OSw = Order.CreateStmt(asAST_STMT_SWITCH, OTu, asCSourceRange());
		const asASTStmtId DefaultCase = Order.CreateStmt(asAST_STMT_CASE, OTu, asCSourceRange());
		const asASTStmtId LaterCase = Order.CreateStmt(asAST_STMT_CASE, OTu, asCSourceRange());
		const asASTExprId LaterLit = Order.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Order.SetLiteral(LaterLit, "2")));
		ASSERT_THAT(AreEqual(0, Order.SetLiteralBits(LaterLit, 2)));
		ASSERT_THAT(AreEqual(0, Order.SetStmtExpr(LaterCase, LaterLit)));
		ASSERT_THAT(AreEqual(0, Order.AddStmtChild(OSw, DefaultCase), TEXT("default first (no expr)")));
		ASSERT_THAT(AreEqual(0, Order.AddStmtChild(OSw, LaterCase), TEXT("valued case after default")));
		asSAstVerifyResult OrderResult;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_INVALID_CHILD, asCASTVerify(Order, OrderResult),
			TEXT("default must be last in source order (current dialect TXT_DEFAULT_MUST_BE_LAST)")));
		ASSERT_THAT(IsTrue(OrderResult.detail.Equals("default-order"),
			TEXT("detail token must be default-order")));
	}

	TEST_METHOD(RejectsFallthroughTargetNotNextCase)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("FallTargetV");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asASTStmtId Sw = Context.CreateStmt(asAST_STMT_SWITCH, Tu, asCSourceRange());
		const asASTStmtId Case0 = Context.CreateStmt(asAST_STMT_CASE, Tu, asCSourceRange());
		const asASTStmtId Case1 = Context.CreateStmt(asAST_STMT_CASE, Tu, asCSourceRange());
		const asASTStmtId Fall = Context.CreateStmt(asAST_STMT_FALLTHROUGH, Tu, asCSourceRange());
		const asASTExprId Lit0 = Context.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		const asASTExprId Lit1 = Context.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.SetLiteralBits(Lit0, 0)));
		ASSERT_THAT(AreEqual(0, Context.SetLiteralBits(Lit1, 1)));
		ASSERT_THAT(AreEqual(0, Context.SetStmtExpr(Case0, Lit0)));
		ASSERT_THAT(AreEqual(0, Context.SetStmtExpr(Case1, Lit1)));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Sw, Case0)));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Sw, Case1)));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Case0, Fall)));
		ASSERT_THAT(AreEqual(0, Context.SetTarget(Fall, Sw), TEXT("fallthrough targets the switch, not next case")));
		asSAstVerifyResult Result;
		ASSERT_THAT(IsTrue(asCASTVerify(Context, Result) != (int)asAST_VERIFY_OK,
			TEXT("fallthrough target must be the next ordered case")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("fallthrough-target"),
			TEXT("detail token must be fallthrough-target")));
	}
```

Keep `RejectsUnsealedPublication` behavior: a Return+literal graph with **no** safe-point set must still `asCASTVerify` == OK. If a new check fails that fixture, **narrow the check** (missing role is not a defect).

Expected first run:

| Method | First result |
| --- | --- |
| `RejectsBreakSkippedNearerLoop` skipped-nearer half | **RED** — current code accepts outer ancestor (`StmtContains`) |
| dangling half | **GREEN immediately** — already `stmt-target` / `ctrl-target`. That is an oracle lock, not a 2.8 reopen |
| `RejectsDuplicateCaseAndDefaultNotLast` duplicate-case | **GREEN immediately** — code exists |
| default-order half | **RED** — verifier does not check default last |
| `RejectsFallthroughTargetNotNextCase` | **RED** — verifier does not check next-Case target |

If duplicate-case is unexpectedly RED (literal compare needs `literal` + `literalBits` as the existing loop does), fix the fixture to match `as_ast_verifier.cpp` ~314–318, do not weaken the check.

- [ ] **Step 2: RED prefixes**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-56-ver-red -TimeoutMs 600000
```

Existing 13 must stay green (`RejectsUnsealedPublication` still OK on unsealed legal graphs).

---

### Task 3 — minimal implementation (GREEN)

- [ ] **Step 1: enum + fields + construction APIs + dump**

Dump helper next to `StmtKindName`:

```cpp
static const char* SafePointName(asEASTSafePointRole role)
{
	switch( role )
	{
	case asAST_SAFEPOINT_FUNCTION_ENTRY: return "FunctionEntry";
	case asAST_SAFEPOINT_STATEMENT: return "Statement";
	case asAST_SAFEPOINT_CALL: return "Call";
	case asAST_SAFEPOINT_LOOP_ENTRY: return "LoopEntry";
	case asAST_SAFEPOINT_LOOP_BACKEDGE: return "LoopBackedge";
	case asAST_SAFEPOINT_TRANSFER: return "Transfer";
	case asAST_SAFEPOINT_SWITCH_INVALID_VALUE: return "SwitchInvalidValue";
	case asAST_SAFEPOINT_RETURN: return "Return";
	case asAST_SAFEPOINT_POSITION: return "Position";
	default: return 0;
	}
}
```

After STMT named-phases append (and after EXPR Call/Construct line is built), if `SafePointName(node->safePointRole)` is non-null, strip trailing `\n`, `+= " safepoint="`, `+= name`, `+= "\n"`.

- [ ] **Step 2: Sema sets roles (no new ActOn APIs)**

| Site | Role |
| --- | --- |
| `AttachParsedFunctionBody` after `SetBody(fn, block)` | `SetStmtSafePointRole(block, asAST_SAFEPOINT_FUNCTION_ENTRY)` |
| `ActOnReturnStmt` after `CreateStmt` | `RETURN` |
| `ActOnBreak` / `ActOnContinue` after `SetTarget` | `TRANSFER` |
| `ActOnCall` after `MakeExpr` | `CALL` |
| `ActOnWhileStmt` / `ActOnForStmt` / `ActOnDoWhileStmt` / `ActOnForeachStmt` when the loop is filled | loop stmt `LOOP_BACKEDGE`; **body child** `LOOP_ENTRY` (For body is `children[1]`; While/DoWhile body is `children[0]`; Foreach body is `children[1]`) |

Do not change For child order (`init`, `body`, `incr`). Named phases must keep dumping.

Do not set `LOOP_ENTRY` on init/incr. Do not set Transfer on Fallthrough (HIR Transfer is break/continue only).

- [ ] **Step 3: verifier oracles (geometry only)**

After the existing BREAK/CONTINUE ancestor block (~284–288), **only when `stmt->target.IsValid()`** and the ancestor check passed:

```text
walk stmtParent from id
nearest = first ancestor that is a legal target
  continue: While | DoWhile | For | Foreach
  break: those loops | Switch
if nearest is valid AND nearest != stmt->target
  Fail WRONG_KIND, "break-skipped-nearer" / "continue-skipped-nearer"
```

Missing target → still OK (incomplete Parser intern / unsealed construction).

Switch children, after the duplicate-default loop: if a no-expr Case is not the last **Case** child → `default-order`. Current dialect: `as_compiler.cpp` ~8203 `TXT_DEFAULT_MUST_BE_LAST`. Do not invent “default may appear anywhere”.

Fallthrough: **only when `stmt->target.IsValid()`**, resolve the enclosing Switch from `stmtParent`, collect Case children in order, find the Case that owns this Fallthrough (or whose descendants contain it), next Case in that list must equal `stmt->target`, else `fallthrough-target`. Missing target still OK (last-case / incomplete `WireFallthroughTargets`). Do **not** add `fallthrough-last` this slice unless you first grep CanonicalAST fixtures for last-case `fallthrough;` — a new last-case reject would fail-close CANONICAL `Seal()` on source LEGACY still warns-and-compiles.

**Do not** verify `safePointRole != NONE`. **Do not** add CALL-without-callee.

---

### Task 4 — GREEN prefixes. Leave 5.6 / 13.2 `[ ]`

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-56-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-56-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-56-ver -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-56-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-56-canonical -TimeoutMs 600000
```

Expect (live totals after identity GREEN; add the new methods):

| Prefix | Expect |
| --- | --- |
| SemaAuthority | previous all-green **+1** (`wave-b-56-sema`) |
| Verifier | **16/16** if still 13 before this slice (13 + 3) |
| Frontend CanonicalAST | previous green; Dump 6/6; unsealed publication still OK |
| Compiler CanonicalAST | previous green after identity |

Then Compiler prefix only if CanonicalAST is green.

Copy each `Summary.json` under the label dir. Append `## B-56-safepoint` to `attachments/wave-b-results.md`. Patch `tasks.md` 5.6 **progress notes only**.

Done when: dump test holds; verifier three methods hold; existing Continue/Break/Fallthrough/For/If dump tests still hold; `RejectsUnsealedPublication` still has `asCASTVerify` OK on the unsealed Return graph; 2.8 CALL-without-callee still absent; **5.6 and 13.2 still `[ ]`**.

Not done: backends consuming roles (9.6 / TypedASTJIT 7.3 already claimed HIR-era emission — do not treat prefix green as that). SwitchInvalidValue. Statement-on-every-stmt. Fallthrough-last. Cleanup-on-transfer.

---

## 4. Hard nos (this package)

- CALL-without-callee as a seal/verifier firewall.
- Reopen Wave C 2.8 (unsealed `asCASTVerify` must succeed; `asCASTVerifyPublication` stays the unsealed gate).
- Default CANONICAL. CANONICAL `CompileFunction`.
- Check 5.6 / 13.2 / 5.4 / 5.9 from prefix green.
- Redo named For/If phases or nearest Continue/Break/Fallthrough dump tests.
- Stmt-level cleanup-plan POD. Reuse `literalBits` / `target` for a role.
- Require `safepoint=` presence in `asCASTVerify`.
- Script `funcdef` / `@` / `is`. Invent `dictionary`. Re-enable mutable globals as language. C labeled break. Source `try`/`catch`.
- Second UBT in `D:\as-cta`. Archive. Commit unless asked. Clang/LLVM link. Unreal types in fork frontend files.
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`. Skip `-NoXGE`. Run tests against a failed build.

---

## 5. Gate

1. **B-param-identity GREEN** first (SemaAuthority back to all-green, ctor `callee=T::T(int)`, incomplete later function does not steal First). Identity currently **200/202**.
2. May run **after or beside 5.4**. No semantic dependency. Shared files: `as_ast_dump.cpp`, `as_expr.h`, `as_sema.cpp` `ActOnCall`. Stmt/verifier files are 5.6-only. Never two UBT users.
3. Named For/If phases already dump — start from safe-point + remaining oracles, not from `init=` / `then=`.

---

## Self-review (spec coverage)

| 5.6 named item | Task |
| --- | --- |
| structured control targets | landed; not this package |
| source-order phases | landed For/If; not this package |
| safe-point roles | Task 1 dump + Task 3 Sema/dump |
| wrong-kind | landed code; not reopened |
| non-ancestor | landed `RejectsBreakTargetNotAncestor` |
| skipped-nearer | Task 2 `RejectsBreakSkippedNearerLoop` |
| dangling | Task 2 same method, existing `stmt-target`/`ctrl-target` lock |
| duplicate-case | Task 2 oracle lock |
| default-order | Task 2 RED `default-order` |
| invalid fallthrough | Task 2 `fallthrough-target`; happy-path dump already `FallthroughTargetsNextCase` |
| 2.8 unsealed verify / no CALL-without-callee | Global constraints + Task 2 keep `RejectsUnsealedPublication` |
| not 13.2 / not 5.6 check | Header + Task 4 |

No placeholders. Implementer later uses this file as the exclusive-UBT plan.
