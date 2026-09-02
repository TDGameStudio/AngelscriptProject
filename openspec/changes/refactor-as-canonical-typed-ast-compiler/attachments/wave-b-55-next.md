# Wave B — exact next 5.5 bite after remaining 5.4 traces GREEN

> **Attachment only now.** Do **not** edit `Plugins/`. Do **not** UBT. Do **not** flip `tasks.md` 5.5 / 5.6. Later exclusive UBT is queued **after** `B-54-traces-remain` GREEN (`wave-b-54-traces-remain.md`).
>
> **This is NOT 5.5 close and NOT 5.6 close.** Backends still rerun Sema (`LEGACY` default still `asCCompiler`; CANONICAL `Generate` is a subset). Do **not** require `safepoint=` in `asCASTVerify`. Do **not** invent stmt-level cleanup-plan POD. Keep source `try` / `catch` rejected.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. LLVM/Clang is a shape reference only.

Companions: `async-work.md`, `async-dispatch.md`, `wave-b-56-safepoint-next.md` (**landed**), `wave-b-56-body-owner-next.md` (**landed**). `sema-remaining-fixture-matrix.md` / `wave-b-sema-remainder.md` rows that still say “fallthrough target / For-If phases / safepoint missing” are **stale**.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Package | **B-55-next** (research). Later UBT: 5.5 statement/control tests |
| Gate | `B-54-traces-remain` GREEN. Do not start this UBT while returnSlot / IsolatedProperty `RunLocal` / Isolated VALUE temp is RED |
| Do not mark | **5.5 / 5.6 / 5.4 / 13.2 / 4.2 / 9.5** |
| Commands (later UBT only) | `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` from `D:\as-cta`, always `-NoXGE` |

Task 5.5 text (keep original meaning, box stays `[ ]`):

> Add failing statement/control tests for block, declaration/expression statement, if/else, for/while/do, switch/case/default/fallthrough, break/continue/return, initializer/condition/body/increment phases, and safe-point roles.

Honesty: **most of that list already has dump/verifier coverage and is GREEN.** 5.5 drifted because kind-only intern tests and “script compiles under the canonical flag” were greened before phases/targets existed; the later B-56 / For-If / jump dump slices then recorded the facts **without adding the remaining compile-seal tests 5.5 still names**. Do not redo those oracles. The next bite is only the **first missing tests**.

---

## 1. Already GREEN — do not redo

Do **not** rewrite, retarget, or re-implement these. Prefix greens are regression locks, not 5.5/5.6 close.

### Compile-seal dump (SemaAuthority)

| 5.5 named item | TEST_METHOD | Token already locked |
| --- | --- | --- |
| continue → loop | `ContinueTargetsEnclosingWhileOnCompileSealPath` | `kind=Continue` + `target=` > 0; `kind=While` present. **Does not** assert target == While id |
| break → nearest switch | `BreakTargetsNearestSwitchNotOuterLoop` | Break `target=` == Switch id, not While id |
| fallthrough → next case | `FallthroughTargetsNextCase` | Fallthrough `target=` == second `kind=Case`, not Switch / first Case |
| for init/body/incr | `ForStmtRecordsNamedPhasesOnCompileSealPath` | For line `init=` / `body=` / `incr=` three distinct > 0 ids |
| for children (weaker) | `ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal` | `expr=` **or** `cond=` plus `children=` with ≥2 commas. **Do not** add a `cond=` dump key |
| if then/else | `IfStmtRecordsNamedThenElseOnCompileSealPath` | If line `then=` / `else=` two distinct > 0 ids |
| safe-point roles | `LoopReturnCallAndTransferRecordSafePointRolesOnCompileSealPath` | `safepoint=FunctionEntry` (Block), `LoopBackedge` (While), `LoopEntry` (While `body=`), `Call`, `Return`, `Transfer` (Break/Continue). **Does not** lock `safepoint=Statement` or `SwitchInvalidValue` |

Dump already emits (observer, `as_ast_dump.cpp` ~286–320): For `init=/body=/incr=`; If `then=/else=`; While/DoWhile `body=`; ForEach `vars=/body=`; `safepoint=` when role `!= NONE`. Condition for If/While/Do/For/Switch is **`expr=` on that STMT line**, not a second `cond=` field. Do not invent `cond=` / `phase=Condition` / HIR `loopPhase=` tokens.

### Dedicated intern (kind= / no compile-seal phases)

These prove Clang-shaped `ActOn*` without `ActOnStmtFromNode`. They are **not** the missing 5.5 compile-seal locks. Do not strengthen them into phase tests; add new compile-seal methods instead.

| Method | What it actually locks |
| --- | --- |
| `SemaCompoundStmtActionRecordsChildrenWithoutScriptNode` | `kind=Block` + `kind=Return` |
| `SemaCompoundStmtActionAttachesBlockAsFunctionBody` | `SetBody` is Block, Return is a child |
| `SemaLocalDeclStmtActionRecordsVarAndInitWithoutScriptNode` | `kind=DeclStmt` + `kind=Var name=i` + `kind=Assign` (API, not compile-seal sibling) |
| `SemaExpressionStmtActionRecordsCallWithoutScriptNode` | `kind=ExprStmt` + `callee=F(int)` |
| `SemaIfStmtActionRecordsCondWithoutScriptNode` | `kind=If` only |
| `SemaWhileStmtActionRecordsCondWithoutScriptNode` | `kind=While` only |
| `SemaForStmtActionRecordsPhasesWithoutScriptNode` | `kind=For` only |
| `SemaDoWhileStmtActionRecordsCondWithoutScriptNode` | `kind=DoWhile` only |
| `SemaSwitchStmtActionRecordsCondWithoutScriptNode` | `kind=Switch` only |
| `SemaCaseStmtActionRecordsValueWithoutScriptNode` | `kind=Case` under Switch |
| `SemaReturnStmtActionRecordsValueWithoutScriptNode` | `kind=Return` |
| `SemaBreakStmtActionRecordsWhileTargetWithoutScriptNode` | Break `target=` == While id |
| `SemaContinueStmtActionRecordsForTargetWithoutScriptNode` | Continue `target=` == For id |
| `SemaFallthroughStmtActionRecordsKindWithoutScriptNode` | `kind=Fallthrough` (**no** `target=`; wiring is `FinishSwitchStmt`) |

### Parser intern identity (keep)

`ParserActOnIfThenReturnIsIfChildNotFunctionBody`, `ParserActOnIfElseReturnsAreIfChildren`, `ParserActOnWhileReturnIsWhileChildNotFunctionBody`, `ParserActOnSwitchCaseReturnIsCaseChild`, `ParserActOnExprStmt*`, `ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails`, `ParserActOnContinueRecordsForTargetBeforeBodyCloseFails`, `ParserActOnBreakRecordsSwitchTargetOnSuccessfulParse`, `ParserActOnDoWhile*`, `ParserActOnFor*`, `ParserActOnWhile*`, `ParserActOnSwitch*`. These are NotifySema intern-once / child-owner tests, not 5.5 compile-seal phase dumps.

### Verifier oracles (5.6 dump slice — landed; **not** 5.6 close)

| Method | Token |
| --- | --- |
| `RejectsBreakTargetNotAncestor` | `break-ancestor` |
| `RejectsFallthroughOutsideSwitch` | `fallthrough-switch` |
| `RejectsStmtMultiOwner` / `RejectsStmtCycle` | `stmt-multi-owner` / `stmt-cycle` |
| `RejectsBreakSkippedNearerLoop` | `break-skipped-nearer` + dangling `stmt-target`/`ctrl-target` |
| `RejectsDuplicateCaseAndDefaultNotLast` | `duplicate-case` + `default-order` |
| `RejectsFallthroughTargetNotNextCase` | `fallthrough-target` |
| `RejectsUnsealedPublication` | `asCASTVerify` OK on unsealed Return+literal **with no safepoint set**; publication is the unsealed gate |

Verifier already implements `continue-skipped-nearer` (`as_ast_verifier.cpp` ~322) with **no** dedicated method. That is an oracle lock to add, not a new check.

Body-owner Seal: reuse BLOCK iff `owner == fn` (`AttachParsedFunctionBody`). Frontend CanonicalAST **85/85**. Do not reopen `decl-body`. Do not globally full-span `FindExistingStmt`.

### Not 5.5 evidence (do not migrate into this bite)

| Surface | Why not |
| --- | --- |
| `FCanonicalASTBodySemaTests.ExpressionsCallsSequenceAndControlLowerToCanonicalAST` | `kind=If` / `While` / `Switch` presence. 虚标 of 5.5 |
| `VerifierRejectsWrongBreakContinueAndDuplicateCase` | Overlaps Frontend Verifier; keep |
| `Semantics.LoopsSwitchTransfersAndSafePoints` | VM + **HIR** kinds/roles. Default pipeline still `asCCompiler` |
| Isolated differential control | Execution parity, not AST facts |
| HIR `CompilerCapturesStructuredWhilePhasesAndSafePointTargets` / DoWhile / For increment list / `safePoint=Statement` | Migration **oracles**. While/For/If/safepoint subset already on AST dump. Remainder is this bite + later 5.6, not a HIR rewrite |

---

## 2. What 5.5 still actually lacks

| 5.5 item | Landed? | First missing test? |
| --- | --- | --- |
| block | dedicated Compound + FunctionEntry + body-owner | compile-seal FunctionEntry children vs wrapping local-init Block |
| declaration / expression statement | dedicated LocalDecl + ExprStmt | **compile-seal** `int I = 1;` sibling `DeclStmt` + `ExprStmt` (F4 trap) |
| if/else | `then=`/`else=` compile-seal | If-without-else `else=0` is **second bite**, not this package |
| for | named `init=/body=/incr=` | comma increment list is **second bite** (HIR). Do not add `cond=` |
| while | Continue + safepoint While `body=` / LoopBackedge / LoopEntry | Do not duplicate the safepoint method |
| **do** | kind= intern + Parser intern-once only | **Yes — compile-seal `body=` + `expr=` + loop roles** |
| switch / case / fallthrough | Fallthrough next-Case dump + verifier | **default Case last, `expr=0` on compile-seal** |
| break / continue / return | nearest targets + Return safepoint | Continue skipped-nearer **verifier sibling** (code exists, no method) |
| phases | For/If named; While/DoWhile dump already prints `body=` | DoWhile compile-seal lock of already-emitted tokens |
| safe-point roles | FunctionEntry / LoopEntry / LoopBackedge / Call / Transfer / Return | **Do not** add `safepoint=Statement` or `SwitchInvalidValue` in this bite. **Do not** put `safepoint=` into `asCASTVerify` |

Deferred (5.6 remainder, **not** this bite): Statement-on-every-stmt, SwitchInvalidValue, fallthrough-last, cleanup-on-transfer, HIR `phase=` spelling. `tasks.md` 5.6 already names those as deferred.

---

## 3. Exact next bite (four methods)

One TDD slice after traces GREEN. Append-only. **Do not** edit landed For/If/safepoint/fallthrough/break methods. **Do not** touch `as_bytecode_codegen.cpp` (traces own it until GREEN, then F2 binding is sequential exclusive).

### Files

| Path | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Three compile-seal methods **after** `LoopReturnCallAndTransferRecordSafePointRolesOnCompileSealPath` |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` | One method **after** `RejectsBreakSkippedNearerLoop` |
| Production | **Only if** method 1 stays RED after the tests compile. Then `as_sema_stmt.cpp` LocalDecl sibling intern — keep `EmitLocalDeclStmts` DECL + sibling EXPR at the **declaration** range. For-init already prefers wrapping BLOCK (`stmt-multi-owner`). Do not nest init as `DeclStmt.expr` |

### Expected first-run colors (honest)

| Method | Likely first result | Why |
| --- | --- | --- |
| `LocalDeclAndExprStmtAreSiblingsOnCompileSealPath` | **maybe RED** | `ActOnLocalDeclStmt` wraps init in a Block; `InternParsedCompoundStmt` `EmitLocalDeclStmts` wants flat siblings. Duplicate DeclStmt or init nested in Decl is the F4 trap |
| `DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath` | **likely GREEN immediately** | Dump already prints DoWhile `body=`; `ApplyLoopSafePoints` already sets LoopBackedge/LoopEntry. Oracle lock 5.5 still lacks |
| `SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath` | **likely GREEN immediately** | Default is `kind=Case` with no expr (`asAST_STMT_CASE` only; **no** `kind=Default`). Verifier already has `default-order` on construction graphs |
| `RejectsContinueSkippedNearerLoop` | **likely GREEN immediately** | Same nearer walk as break; detail token already `continue-skipped-nearer` |

GREEN-immediately is still 5.5 work (the tests do not exist). It is **not** a reason to skip them, and **not** a reason to check 5.5.

### Method 1 — block + declaration / expression statement

Fixture: function-body local init, not for-init (for-init wrapping BLOCK is a different owner rule).

```cpp
	TEST_METHOD(LocalDeclAndExprStmtAreSiblingsOnCompileSealPath)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));

		asIScriptModule* const Module = ScriptEngine->GetModule("SemaLocalSiblings", asGM_ALWAYS_CREATE);
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaLocalSiblings module")));
		ASSERT_THAT(AreEqual(0, Module->SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)));
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int Entry()
			{
				int I = 1;
				return I;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, Module->AddScriptSection("SemaLocalSiblings.as", ScriptSource.c_str())));
		asCString Dump;
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst(Module, Dump),
			TEXT("local-decl sibling module must seal a dumpable AST")));
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("int I = 1 must intern DeclStmt + sibling ExprStmt Assign at the declaration, not DeclStmt.expr. dump:\n%s"),
			*Text);

		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=DeclStmt")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Var name=I")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Assign")), *DumpMsg));

		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		int32 DeclStmtId = 0;
		int32 DeclStmtExpr = -1;
		int32 FunctionEntryId = 0;
		FString FunctionEntryChildren;
		TMap<int32, FString> StmtLineById;
		for (const FString& Line : Lines)
		{
			if (!Line.Contains(TEXT("STMT id=")))
			{
				continue;
			}
			const int32 IdBegin = Line.Find(TEXT("id="));
			const int32 Id = FCString::Atoi(*Line.Mid(IdBegin + 3));
			StmtLineById.Add(Id, Line);
			if (Line.Contains(TEXT("kind=DeclStmt")))
			{
				DeclStmtId = Id;
				const int32 ExprAt = Line.Find(TEXT("expr="));
				DeclStmtExpr = ExprAt == INDEX_NONE ? -1 : FCString::Atoi(*Line.Mid(ExprAt + 5));
			}
			if (Line.Contains(TEXT("kind=Block")) && Line.Contains(TEXT("safepoint=FunctionEntry")))
			{
				FunctionEntryId = Id;
				const int32 ChildAt = Line.Find(TEXT("children="));
				if (ChildAt != INDEX_NONE)
				{
					FString Rest = Line.Mid(ChildAt + 9);
					int32 Space = INDEX_NONE;
					Rest.FindChar(TCHAR(' '), Space);
					FunctionEntryChildren = Space == INDEX_NONE ? Rest : Rest.Left(Space);
				}
			}
		}
		ASSERT_THAT(IsTrue(DeclStmtId > 0 && FunctionEntryId > 0, *DumpMsg));
		ASSERT_THAT(AreEqual(0, DeclStmtExpr, *DumpMsg)); // init is not DeclStmt.expr

		auto ParseIds = [](const FString& List) -> TArray<int32>
		{
			TArray<FString> Parts;
			List.ParseIntoArray(Parts, TEXT(","), true);
			TArray<int32> Ids;
			for (const FString& Part : Parts)
			{
				if (Part.Len() > 0)
				{
					Ids.Add(FCString::Atoi(*Part));
				}
			}
			return Ids;
		};

		bool bSiblings = false;
		const TArray<int32> EntryKids = ParseIds(FunctionEntryChildren);
		auto BlockHasDeclAndAssignExpr = [&](const TArray<int32>& Kids) -> bool
		{
			bool bHasDecl = false;
			bool bHasAssignExprStmt = false;
			for (const int32 Kid : Kids)
			{
				const FString* KidLine = StmtLineById.Find(Kid);
				if (KidLine == nullptr)
				{
					continue;
				}
				if (KidLine->Contains(TEXT("kind=DeclStmt")))
				{
					bHasDecl = true;
				}
				if (KidLine->Contains(TEXT("kind=ExprStmt")))
				{
					const int32 ExprAt = KidLine->Find(TEXT("expr="));
					const int32 ExprId = ExprAt == INDEX_NONE ? 0 : FCString::Atoi(*KidLine->Mid(ExprAt + 5));
					for (const FString& ExprLine : Lines)
					{
						if (ExprLine.Contains(TEXT("EXPR id="))
							&& FCString::Atoi(*ExprLine.Mid(ExprLine.Find(TEXT("id=")) + 3)) == ExprId
							&& ExprLine.Contains(TEXT("kind=Assign")))
						{
							bHasAssignExprStmt = true;
						}
					}
				}
			}
			return bHasDecl && bHasAssignExprStmt;
		};
		if (BlockHasDeclAndAssignExpr(EntryKids))
		{
			bSiblings = true;
		}
		else
		{
			// Allowed F4 shape: wrapping BLOCK at the declaration range (for-init / two-stmt LocalDecl).
			for (const int32 Kid : EntryKids)
			{
				const FString* KidLine = StmtLineById.Find(Kid);
				if (KidLine == nullptr || !KidLine->Contains(TEXT("kind=Block")))
				{
					continue;
				}
				if (KidLine->Contains(TEXT("safepoint=FunctionEntry")))
				{
					continue;
				}
				const int32 ChildAt = KidLine->Find(TEXT("children="));
				if (ChildAt == INDEX_NONE)
				{
					continue;
				}
				FString Rest = KidLine->Mid(ChildAt + 9);
				int32 Space = INDEX_NONE;
				Rest.FindChar(TCHAR(' '), Space);
				if (BlockHasDeclAndAssignExpr(ParseIds(Space == INDEX_NONE ? Rest : Rest.Left(Space))))
				{
					bSiblings = true;
					break;
				}
			}
		}
		ASSERT_THAT(IsTrue(bSiblings, *DumpMsg));
	}
```

If RED: keep sibling `STMT_EXPR`; intern ASSIGN/DECL_REF at the **declaration** range; do not `SetStmtExpr` on DeclStmt; do not hide init inside Decl; do not globally change `FindExistingStmt`. Duplicate DeclStmt from `ActOnParsedStmt` + `EmitLocalDeclStmts` is a real fail.

### Method 2 — do (named body + trailing cond)

HIR oracle: `CompilerCapturesStructuredDoWhileBodyBeforeTrailingCondition` (`CountStructuredDoWhile`). Do **not** require HIR `phase=Condition` text.

```cpp
	TEST_METHOD(DoWhileStmtRecordsNamedBodyTrailingCondOnCompileSealPath)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));

		asIScriptModule* const Module = ScriptEngine->GetModule("SemaDoWhilePhases", asGM_ALWAYS_CREATE);
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaDoWhilePhases module")));
		ASSERT_THAT(AreEqual(0, Module->SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)));
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int CountStructuredDoWhile(int Limit)
			{
				int Current = 0;
				do
				{
					Current = Current + 1;
				}
				while (Current < Limit);
				return Current;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, Module->AddScriptSection("SemaDoWhilePhases.as", ScriptSource.c_str())));
		asCString Dump;
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst(Module, Dump),
			TEXT("do-while phase module must seal a dumpable AST")));
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("DoWhile must dump body= distinct from expr= (trailing cond) plus loop roles. dump:\n%s"),
			*Text);

		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		bool bNamed = false;
		bool bBackedge = false;
		int32 BodyId = 0;
		for (const FString& Line : Lines)
		{
			if (!Line.Contains(TEXT("kind=DoWhile")))
			{
				continue;
			}
			const int32 BodyAt = Line.Find(TEXT("body="));
			const int32 ExprAt = Line.Find(TEXT("expr="));
			if (BodyAt == INDEX_NONE || ExprAt == INDEX_NONE)
			{
				continue;
			}
			BodyId = FCString::Atoi(*Line.Mid(BodyAt + 5));
			const int32 ExprId = FCString::Atoi(*Line.Mid(ExprAt + 5));
			bNamed = BodyId > 0 && ExprId > 0 && BodyId != ExprId;
			bBackedge = Line.Contains(TEXT("safepoint=LoopBackedge"));
		}
		bool bBodyEntry = false;
		if (BodyId > 0)
		{
			for (const FString& Line : Lines)
			{
				if (!Line.Contains(TEXT("STMT id=")))
				{
					continue;
				}
				const int32 Id = FCString::Atoi(*Line.Mid(Line.Find(TEXT("id=")) + 3));
				if (Id == BodyId && Line.Contains(TEXT("safepoint=LoopEntry")))
				{
					bBodyEntry = true;
				}
			}
		}
		ASSERT_THAT(IsTrue(bNamed, *DumpMsg));
		ASSERT_THAT(IsTrue(bBackedge, *DumpMsg));
		ASSERT_THAT(IsTrue(bBodyEntry, *DumpMsg));
	}
```

Do **not** assert `safepoint=Statement` on the inner Assign. If this method is unexpectedly RED, only fill DoWhile `body=` / `ApplyLoopSafePoints` — do not retouch While safepoint.

### Method 3 — switch default (compile-seal)

Default is a Case with **no** expr. Do **not** add `asAST_STMT_DEFAULT`. Dialect: default last (`TXT_DEFAULT_MUST_BE_LAST`). Happy-path dump; verifier already rejects default-not-last.

```cpp
	TEST_METHOD(SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));

		asIScriptModule* const Module = ScriptEngine->GetModule("SemaSwitchDefault", asGM_ALWAYS_CREATE);
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaSwitchDefault module")));
		ASSERT_THAT(AreEqual(0, Module->SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)));
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int Entry()
			{
				int X = 0;
				switch (X)
				{
				case 0:
					X = 1;
					break;
				default:
					X = 2;
					break;
				}
				return X;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, Module->AddScriptSection("SemaSwitchDefault.as", ScriptSource.c_str())));
		asCString Dump;
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst(Module, Dump),
			TEXT("switch-default module must seal a dumpable AST")));
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("default must be the last Case with expr=0. dump:\n%s"), *Text);

		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		TArray<int32> SwitchCaseIds;
		TMap<int32, int32> CaseExpr;
		for (const FString& Line : Lines)
		{
			if (!Line.Contains(TEXT("STMT id=")))
			{
				continue;
			}
			const int32 Id = FCString::Atoi(*Line.Mid(Line.Find(TEXT("id=")) + 3));
			if (Line.Contains(TEXT("kind=Switch")))
			{
				const int32 ChildAt = Line.Find(TEXT("children="));
				if (ChildAt != INDEX_NONE)
				{
					FString Rest = Line.Mid(ChildAt + 9);
					int32 Space = INDEX_NONE;
					Rest.FindChar(TCHAR(' '), Space);
					TArray<FString> Parts;
					(Space == INDEX_NONE ? Rest : Rest.Left(Space)).ParseIntoArray(Parts, TEXT(","), true);
					for (const FString& Part : Parts)
					{
						SwitchCaseIds.Add(FCString::Atoi(*Part));
					}
				}
			}
			else if (Line.Contains(TEXT("kind=Case")))
			{
				const int32 ExprAt = Line.Find(TEXT("expr="));
				CaseExpr.Add(Id, ExprAt == INDEX_NONE ? 0 : FCString::Atoi(*Line.Mid(ExprAt + 5)));
			}
		}
		ASSERT_THAT(IsTrue(SwitchCaseIds.Num() >= 2, *DumpMsg));
		const int32 Last = SwitchCaseIds.Last();
		const int32 First = SwitchCaseIds[0];
		const int32* LastExpr = CaseExpr.Find(Last);
		const int32* FirstExpr = CaseExpr.Find(First);
		ASSERT_THAT(IsTrue(LastExpr != nullptr && FirstExpr != nullptr, *DumpMsg));
		ASSERT_THAT(AreEqual(0, *LastExpr, *DumpMsg));
		ASSERT_THAT(IsTrue(*FirstExpr > 0, *DumpMsg));
		ASSERT_THAT(IsFalse(Text.Contains(TEXT("kind=Default")), *DumpMsg));
	}
```

Do **not** add last-case `fallthrough;` (LEGACY warns-and-compiles; B-56 deferred `fallthrough-last`).

### Method 4 — continue skipped-nearer (verifier oracle lock)

Construction APIs only. Do **not** `Seal()`. Keep `asCASTVerify` OK on unsealed graphs with no role set.

```cpp
	TEST_METHOD(RejectsContinueSkippedNearerLoop)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("ContSkipV");
		const asASTStmtId Outer = Context.CreateStmt(asAST_STMT_WHILE, Tu, asCSourceRange());
		const asASTStmtId Inner = Context.CreateStmt(asAST_STMT_WHILE, Tu, asCSourceRange());
		const asASTStmtId Cont = Context.CreateStmt(asAST_STMT_CONTINUE, Tu, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Outer, Inner), TEXT("inner under outer")));
		ASSERT_THAT(AreEqual(0, Context.AddStmtChild(Inner, Cont), TEXT("continue under inner")));
		ASSERT_THAT(AreEqual(0, Context.SetTarget(Cont, Outer), TEXT("continue skips inner, targets outer")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_WRONG_KIND, asCASTVerify(Context, Result),
			TEXT("continue must target the nearest enclosing loop, not a skipped outer loop")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("continue-skipped-nearer"),
			TEXT("detail token must be continue-skipped-nearer")));
	}
```

Do **not** reopen 2.8. Do **not** require CALL `resolvedDecl`. Do **not** require `safepoint=` presence.

---

## 4. Later exclusive UBT (after traces GREEN)

TDD: write the four methods first. `RunBuild.ps1 -NoXGE` then prefixes **before** any Sema change.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-55-red -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-55-sema-red -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-55-ver-red -TimeoutMs 600000
```

Then only if method 1 is RED, fix LocalDecl intern. Re-run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-55-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-55-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-55-ver -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-55-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-55-canonical -TimeoutMs 600000
```

Copy each `Summary.json`. Append `## B-55-stmt` to `attachments/wave-b-results.md`. Patch `tasks.md` 5.5 **progress notes only**. Boxes stay `[ ]`.

Done when: the four methods hold; landed For/If/safepoint/fallthrough/break dumps still hold; `RejectsUnsealedPublication` still has `asCASTVerify` OK without `safepoint=`; **5.5 and 5.6 still `[ ]`**.

Not done after this bite: backends consuming roles; full HIR control migration; For comma-increment list; If-without-else; Continue `target=` == While id strengthen; `safepoint=Statement`; 13.2 Sema environment.

---

## 5. Explicitly not this bite

| Item | Why not |
| --- | --- |
| Redo For `init=/body=/incr=`, If `then=/else=`, While safepoint, Fallthrough next-Case, Break nearest Switch | Already GREEN |
| New dump key `cond=` / `phase=` / `kind=Default` | Condition is `expr=`; default is Case `expr=0` |
| `safepoint=` required in `asCASTVerify` | Unsealed construction + Dump tests would fail Seal. Hard no |
| `safepoint=Statement` on every If/Decl/ExprStmt | HIR has it; B-56 deferred. 5.6 remainder |
| `SwitchInvalidValue` | Deferred with Statement-on-every-stmt |
| Stmt-level cleanup-plan POD | CLEANUP/MATERIALIZE stay expr kinds. 5.7/5.8 |
| Intern `try`/`catch` as language | Keep rejected (`try-catch-rejected`) |
| For increment comma list (`Index = Index + Step, Step = Step + 1`) | HIR `CompilerCapturesStructuredForPhasesAndOrderedIncrementList`. **Second 5.5 bite** after this one |
| If without else `else=0` | Dump already prints `else=0`. Oracle lock, second bite |
| Strengthen `ContinueTargetsEnclosingWhile` to target == While id | Do not rewrite the landed method; optional later additive method |
| Ninth-pass F2 exact binding / leftover FromNode / 13.2 environment | Different packages. F2 shares `as_bytecode_codegen.cpp` |
| Wave E–G, default CANONICAL, CANONICAL `CompileFunction` | Forbidden |
| Check 5.5 because four methods pass | 5.5 names the full statement/control matrix including HIR remainder. Four tests ≠ close |
| Check 5.6 because verifier has continue-skipped-nearer | Backends still rerun Sema; HIR not fully migrated |

---

## 6. Hard nos

- Check 5.5 / 5.6 / 5.4 / 13.2 / 4.2 / 9.5 from prefix greens or from these four methods.
- Require `safepoint=` in `asCASTVerify`. CALL-without-callee firewall.
- Redo landed dump/verifier oracles.
- Invent stmt-level cleanup-plan POD. Intern try/catch. Script `funcdef` / `@` / `is`. C labeled break.
- Second UBT in `D:\as-cta` while traces or F2 hold `as_bytecode_codegen.cpp`.
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` from `D:\as-cta`. Skip `-NoXGE`.
- Implement this package in the research session that wrote this file.

---

## 7. Self-review

| 5.5 named item | This bite | Already GREEN |
| --- | --- | --- |
| block | method 1 FunctionEntry vs wrapping local Block | Compound attach + body-owner |
| declaration/expression statement | method 1 sibling DeclStmt + ExprStmt | dedicated LocalDecl / ExprStmt |
| if/else | not this bite | `IfStmtRecordsNamedThenElseOnCompileSealPath` |
| for/while/do | method 2 DoWhile only | For named phases; While safepoint |
| switch/case/default/fallthrough | method 3 default Case | Fallthrough next-Case + verifier |
| break/continue/return | method 4 continue skipped-nearer | nearest targets + Return role |
| initializer/condition/body/increment phases | method 2 `body=`/`expr=` | For `init=/body=/incr=`; If `then=/else=` |
| safe-point roles | method 2 reuses landed loop roles on DoWhile | FunctionEntry/Call/Transfer/Return/While |
| not 5.5 / not 5.6 close | Header + §5 | backends still rerun Sema |

No placeholders. Later exclusive-UBT worker uses this file as the TDD plan.
