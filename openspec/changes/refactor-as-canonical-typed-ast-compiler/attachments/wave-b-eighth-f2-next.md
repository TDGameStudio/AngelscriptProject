# Wave B exclusive UBT — B-eighth-f2-call-identity

> **For the exclusive-UBT worker:** REQUIRED SUB-SKILL: `superpowers:test-driven-development`. Write the five SemaAuthority methods first. `RunBuild.ps1` then the SemaAuthority prefix. Do **not** check `tasks.md` 13.2 / 13.3 / 4.2 / 5.4 / 5.6 / 9.5. Do **not** start this UBT while `wave-b-54-eval-once-next.md` still holds `as_bytecode_codegen.cpp`.

Worktree: `D:\as-cta` (junction → `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-eighth-f2-call-identity**.
**TDD. One UBT user. Do not mark boxes.**

F1 **dump** already GREEN (`MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath`, SemaAuthority **214/214** `wave-b-f1-sema`). That is **not** F2. Current exclusive UBT (not this package) is `attachments/wave-b-54-eval-once-next.md` — `EmitCall` `literalBits` re-eval in `as_bytecode_codegen.cpp` only.

Companions: `reviews/implementation-rereview-2026-08-22-eighth-pass.md` F2; `attachments/eighth-pass-verified.md` F2 row; `attachments/async-work.md` §4 Hole 2.

This machine has one UBT mutex. This attachment is the map. The implementer runs UBT **after** eval-once GREEN.

---

## Goal

Parser action and WalkOne/ExprTerm replay intern **one** CALL for `Game::F()` and **one** CALL for unresolved `F()`. Reuse is the FunctionCall node's full source range, not the identifier token. Unresolved CALL is reusable. Offset 0 is a real identity. Same-begin wider CALL / rewrite CALL must not steal.

## Architecture

Keep `FindExistingExpr` as kind + `range.begin.fileID` + `range.begin.offset`, skip offset 0. Term already taught that incomplete nodes grow `tokenLength`; a global full-span change would miss or steal Unary/Index/Sequence wrappers.

Replace **only** the ident-offset + `resolvedDecl` loop inside `InternParsedCall` with one CALL full-span scan on the FunctionCall range already computed at `as_sema_expr.cpp:1452`. Do not add a second scan beside it. Do not put a pending action id on `asCScriptNode` (destructor is protected; the node has no id slot).

`asCASTVerify` must still succeed on unsealed legal graphs, including CALL-without-callee. Publication is the unsealed gate. Do not firewall missing callee.

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-eighth-f2-call-identity** |
| Mode now | Plan-only here. Next exclusive UBT after eval-once GREEN. |
| Evidence now | SemaAuthority **214/214** `wave-b-f1-sema`. F2 still live. |
| Do not mark | **13.2 / 13.3 / 4.2 / 5.4 / 5.6 / 9.5** |

---

## Global constraints / hard nos

- Fork dialect: no script `funcdef` / `@` / `is`. Host `RegisterFuncdef` remains legal. No Clang/LLVM link. No Unreal types in fork frontend files.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE`. Never All. `RunTests.ps1` does not UBT — Build first.
- Default `canonicalCompilerPipeline` stays LEGACY. `CompileFunction` stays mixed COMPILER.
- Do **not** globally change `FindExistingExpr` / `FindExistingStmt` to full-span.
- Do **not** restore whole-term CALL `FindExistingExpr` in `InternParsedExprTerm` (Term lesson).
- Do **not** retarget `CALL.range.begin` to the identifier token of `Game::F()`.
- Do **not** edit `as_bytecode_codegen.cpp` (eval-once owns it).
- Do **not** make CALL-without-callee an unsealed `asCASTVerify` firewall.
- Do **not** start F3 `T()` VALUE_OBJECT or F4 same-arity / unresolved→int. Same file `as_sema_expr.cpp` — F3/F4 wait until this UBT is GREEN.
- Do not check 13.2 / 13.3 / 4.2 / 5.4 / 5.6 / 9.5. Do not archive. Do not commit unless asked.
- Second UBT in `D:\as-cta`. Wave E–G. Default CANONICAL.

---

## Live defect (verify these lines before editing)

Reuse loop — `InternParsedCall` `as_sema_expr.cpp:1471-1486`:

```1471:1486:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp
	const asUINT callOffset = ident ? (asUINT)ident->tokenPos : (asUINT)node->tokenPos;
	if( callOffset != 0 )
	{
		for( asUINT i = 1; i <= context.GetExprCount(); ++i )
		{
			const asCExpr* existing = context.GetExpr(asASTExprId(i));
			if( existing
				&& existing->kind == asAST_EXPR_CALL
				&& existing->resolvedDecl.IsValid()
				&& existing->range.begin.fileID == range.begin.fileID
				&& existing->range.begin.offset == callOffset )
			{
				return existing->id;
			}
		}
	}
```

`range` is already the FunctionCall node (`ExprRange` at `:1452`, which uses `node->tokenPos` / `node->tokenLength`). The loop ignores that range and keys on the identifier token.

Why `Game::F()` mismatches:

1. `ParseFunctionCall` (`as_parser.cpp:1842-1868`) calls `ParseOptionalScope(node)` first (`as_parser.cpp:322-389`).
2. `scope->lastChild` is true for `Game::`, so `node->AddChildLast(scope)` runs.
3. `asCScriptNode::AddChildLast` (`as_scriptnode.cpp:108-131`) calls `UpdateSourcePos`. A fresh FunctionCall starts `tokenPos=0, tokenLength=0` (`as_scriptnode.cpp:45-57`); first child sets begin to `Game`.
4. Identifier `F` is a later child. `callOffset = ident->tokenPos` is `F`, not `Game`.
5. `ActOnCallExpr` (`as_sema_expr.cpp:493-557`) then `ActOnCall` (`as_sema.cpp:778-802`) stores `CALL.range = range` (begin at `Game`).
6. Parser `ActOnParsedExpr` `snFunctionCall` (`as_sema_decl.cpp:1773-1775`) intern once. WalkOne / `InternParsedExprTerm` replay intern again. Lookup compares `existing->range.begin.offset` (`Game`) to `callOffset` (`F`) → miss → second resolved CALL.

Unresolved `F()`: reuse requires `existing->resolvedDecl.IsValid()`. First CALL is interned with invalid callee and type `int` (`ActOnCallExpr` `:536-544`). Replay never reuses it.

Offset 0: `if( callOffset != 0 )` skips reuse when the FunctionCall identifier is the first byte of the section. `FindExistingExpr` (`as_sema_expr.cpp:35-52`) also skips `range.begin.offset == 0`. A CALL at offset 0 is therefore invisible to both scanners.

kind+begin steal: `FindExistingExpr` matches kind + begin only and ignores `end`. A wider rewrite/wrapper CALL that shares `begin.offset` with `F()` would be returned as "this call". The ident-offset loop does the same when `resolvedDecl` is valid: it never compares `range.end`. Term already dropped whole-term CALL FindExisting because `v-3` / `Make()[0]` share a begin with an inner CALL (`InternParsedExprTerm` comment `:1542-1544`). Do not reintroduce that globally.

`ActOnCall` never de-dupes. Identity must be decided in `InternParsedCall` before the second `ActOnCallExpr`.

Reviewer snapshot line numbers `1331-1364` are stale. Live loop is **1471-1486**.

---

## Chosen identity rule (do not invent a third scan)

**In `InternParsedCall` only**, after `const asCSourceRange range = ExprRange(...)` and after walking children for ident/args/scope, reuse with this predicate and no other:

```text
existing->kind == asAST_EXPR_CALL
&& range.begin.fileID != 0
&& existing->range.begin.fileID == range.begin.fileID
&& existing->range.begin.offset == range.begin.offset
&& existing->range.end.fileID == range.end.fileID
&& existing->range.end.offset == range.end.offset
```

Spellings the implementer must not invent:

| Forbidden | Why |
| --- | --- |
| Change `FindExistingExpr` to compare `end.offset` | Term: incomplete nodes grow `tokenLength`; Unary/Index/Sequence at the same begin would miss or steal |
| Keep the ident-offset loop **and** add a full-span loop | Third arena scan. Replace 1471-1486; do not leave both |
| `FindExistingExpr(context, asAST_EXPR_CALL, range)` from InternParsedCall | Skips offset 0; ignores end; would steal a wider CALL at the same begin |
| Set `CALL.range.begin` to `ident->tokenPos` so the old loop hits | Leaves a CALL at `F` while the FunctionCall node begins at `Game`. Parser vs WalkOne still disagree on any path that uses node range |
| Parser-held pending expr id on `asCScriptNode` | Node has no id slot; destructor is protected; that is a later action-protocol UBT, not this one |
| Require `resolvedDecl.IsValid()` to reuse | Unresolved `F()` can never be replayed |
| Skip `range.begin.offset == 0` in this CALL intern | File-leading `F()` is a real range |

Suggested static helper in `as_sema_expr.cpp` next to `FindExistingExpr`, **called only from `InternParsedCall`**:

```cpp
static asASTExprId FindExistingCallByFullRange(asCASTContext& context, const asCSourceRange& range)
{
	if( range.begin.fileID == 0 )
	{
		return asASTExprId();
	}
	for( asUINT i = 1; i <= context.GetExprCount(); ++i )
	{
		const asCExpr* existing = context.GetExpr(asASTExprId(i));
		if( existing
			&& existing->kind == asAST_EXPR_CALL
			&& existing->range.begin.fileID == range.begin.fileID
			&& existing->range.begin.offset == range.begin.offset
			&& existing->range.end.fileID == range.end.fileID
			&& existing->range.end.offset == range.end.offset )
		{
			return existing->id;
		}
	}
	return asASTExprId();
}
```

`InternParsedCall` then:

```cpp
	const asCSourceRange range = ExprRange(context.GetSourceManager(), file, node);
	const asASTExprId existingCall = FindExistingCallByFullRange(context, range);
	if( existingCall.IsValid() )
	{
		return existingCall;
	}
	// ... existing ident/args/scope walk, ResolveCallee, ReorderNamedArguments,
	// AppendDefaultArguments, ActOnCallExpr ...
```

If `ActOnCallExpr` returns a CALL whose `resolvedDecl` is invalid, record **one** diagnostic `unresolved-call:<name>` via `AddDiagnostic` (same style as `duplicate-param:` / `ambiguous-overload`). Record it only on the creating path, not on reuse. Do **not** change the CALL type (F4 still owns unresolved→int). Do **not** fail `asCASTVerify` for missing callee.

Member `Make().Get()` FunctionCall node range is `Get()`, not the whole term. Full-span CALL intern does not collide with `callee=Make()`. Do not touch `ParseFunctionCall(false)` or the Sequence pop in `InternParsedExprTerm`.

---

## Files

| Path | Role |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | **Only fork edit.** Replace InternParsedCall reuse (`:1471-1486`) with `FindExistingCallByFullRange`. Optional one-shot `unresolved-call:` diagnostic after `ActOnCallExpr`. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Five new methods on `FCanonicalASTSemaAuthorityTests`. Helpers in `CanonicalASTSemaAuthorityTest`. |
| `attachments/wave-b-results.md` | Record GREEN after the UBT. |
| `attachments/eighth-pass-verified.md` | Patch F2 row after GREEN. |

Do **not** edit: `as_bytecode_codegen.cpp`, `as_parser.cpp`, `as_sema.cpp` (unless `AddDiagnostic` needs a one-line comment — it already exists at `as_sema.cpp:597`), `as_ast_verifier.cpp`, `as_ast_dump.cpp`, `FindExistingExpr` (`:35-52`), `InternParsedExprTerm` CALL comment (`:1542-1544`).

Dump has **no** `range=` on EXPR lines (`as_ast_dump.cpp:338-387`). Uniqueness of `callee=Game::F()` is dump-countable. "No CALL at ident offset" must use `Context.GetExpr` / `range.begin.offset`.

Test file is SemaAuthority unless a sibling is better. Existing unscoped uniqueness is `ParserActOnCallDoesNotDuplicateOnSuccessfulParse` (`:5268`). Incomplete `F(3` is `ParserActOnCallSelectsIntOverloadBeforeFunctionCloseFails` (`:5320`). Scoped bind-without-count is `NamespaceOverloadSelectsScopedFunctionNotGlobal` (`:390`). Stay in this file. Do not weaken those methods.

`asCScriptNode` destructor is protected (`as_scriptnode.h:137`). Do **not** stack-allocate nodes. Use `asCParser` / `FParserAccessor` MemStack nodes.

---

### Task 1: Failing SemaAuthority methods <!-- TDD -->

**Files:**
- Modify: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` (helpers in `CanonicalASTSemaAuthorityTest` after `CountDumpLinesContaining`; methods after `ParserActOnCallDoesNotDuplicateOnSuccessfulParse` ~5318)
- Do not modify fork sources in this task

**Interfaces:**
- Consumes: `asCParser::SetSema`, `ParseScript`, `FParserAccessor::ParseExpressionSnippet`, `asCSema::InternParsedCall`, `ActOnCall`, `asCASTDump`, `asCASTVerify`, `Context.Seal`, `DumpSealedCanonicalAst`
- Produces: five RED methods the intern fix must turn GREEN

- [ ] **Step 1: Add helpers** (inside `namespace CanonicalASTSemaAuthorityTest`, after `CountDumpLinesContaining`)

```cpp
	static asCScriptNode* FindFirstNodeOfType(asCScriptNode* Node, eScriptNode Type)
	{
		if (Node == nullptr)
		{
			return nullptr;
		}
		if (Node->nodeType == Type)
		{
			return Node;
		}
		for (asCScriptNode* Child = Node->firstChild; Child; Child = Child->next)
		{
			if (asCScriptNode* Hit = FindFirstNodeOfType(Child, Type))
			{
				return Hit;
			}
		}
		return nullptr;
	}

	static int32 CountCallExprs(asCASTContext& Context)
	{
		int32 Count = 0;
		for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
		{
			const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
			if (Expr && Expr->kind == asAST_EXPR_CALL)
			{
				++Count;
			}
		}
		return Count;
	}

	static int32 CountCallExprsWithBeginOffset(asCASTContext& Context, asUINT Offset)
	{
		int32 Count = 0;
		for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
		{
			const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
			if (Expr && Expr->kind == asAST_EXPR_CALL && Expr->range.begin.offset == Offset)
			{
				++Count;
			}
		}
		return Count;
	}

	static int32 CountDumpCallLinesWithCallee(const FString& Text, const TCHAR* CalleeToken)
	{
		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		int32 Count = 0;
		for (const FString& Line : Lines)
		{
			if (Line.Contains(TEXT("kind=Call")) && Line.Contains(CalleeToken))
			{
				++Count;
			}
		}
		return Count;
	}

	static int32 CountDumpEmptyCalleeCalls(const FString& Text)
	{
		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		int32 Count = 0;
		for (const FString& Line : Lines)
		{
			if (!Line.Contains(TEXT("kind=Call")))
			{
				continue;
			}
			const int32 CalleeAt = Line.Find(TEXT("callee="));
			if (CalleeAt == INDEX_NONE)
			{
				continue;
			}
			const FString After = Line.Mid(CalleeAt + 7);
			if (After.StartsWith(TEXT(" ")) || After.StartsWith(TEXT("nargs=")) || After.Len() == 0)
			{
				++Count;
			}
		}
		return Count;
	}

	static bool SemaHasDiagnosticPrefix(const asCSema& Sema, const char* Prefix)
	{
		if (Prefix == nullptr || Prefix[0] == 0)
		{
			return false;
		}
		const asUINT PrefixLen = static_cast<asUINT>(std::strlen(Prefix));
		for (asUINT i = 0; i < Sema.GetDiagnostics().GetLength(); ++i)
		{
			const asCString& Text = Sema.GetDiagnostics()[i];
			if (Text.GetLength() >= PrefixLen && std::strncmp(Text.AddressOf(), Prefix, PrefixLen) == 0)
			{
				return true;
			}
		}
		return false;
	}
```

`<cstring>` is already available through the native support headers; `std::string` / `std::strlen` already used in this file.

- [ ] **Step 2: Write `ParserActOnScopedCallDoesNotDuplicateOnSuccessfulParse`**

Insert immediately after `ParserActOnCallDoesNotDuplicateOnSuccessfulParse`. Do not change that unscoped `F(1, 2)` method.

```cpp
	TEST_METHOD(ParserActOnScopedCallDoesNotDuplicateOnSuccessfulParse)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaActionOnlyScopedCallOnce");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaActionOnlyScopedCallOnce module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			namespace Game
			{
				int F(int a)
				{
					return a;
				}
			}

			int F(int a)
			{
				return 0;
			}

			int Entry()
			{
				return Game::F(3);
			}
			)AS");
		Code.SetCode("SemaActionOnlyScopedCallOnce.as", ScriptSource.c_str(), true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("complete Game::F(3) must parse")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("action-only scoped call graph should verify")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("Parser call action plus WalkOne must intern callee=Game::F(int) once. dump:\n%s"), *Text);
		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountDumpCallLinesWithCallee(Text, TEXT("callee=Game::F(int)")), *DumpMsg));
		ASSERT_THAT(AreEqual(0, CanonicalASTSemaAuthorityTest::CountDumpCallLinesWithCallee(Text, TEXT("callee=F(int)")),
			TEXT("Game::F(3) must not also intern the global F(int). dump:\n") + Text));

		const char* const Needle = "Game::F(3)";
		const char* const Found = std::strstr(ScriptSource.c_str(), Needle);
		ASSERT_THAT(IsTrue(Found != nullptr, TEXT("fixture must contain Game::F(3)")));
		const asUINT IdentF = static_cast<asUINT>((Found - ScriptSource.c_str()) + 6);
		ASSERT_THAT(AreEqual(0, CanonicalASTSemaAuthorityTest::CountCallExprsWithBeginOffset(Context, IdentF),
			TEXT("CALL.range.begin must stay at Game, not the identifier F. A naive ident-offset retarget leaves a CALL at F")));
	}
```

Today this fails because dump has **two** `kind=Call` `callee=Game::F(int)` lines (Parser action + WalkOne). Do not "fix" it by moving `CALL.range.begin` to `F`.

- [ ] **Step 3: Write `ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse`**

```cpp
	TEST_METHOD(ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaActionOnlyUnresolvedCallOnce");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaActionOnlyUnresolvedCallOnce module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int Entry()
			{
				return F();
			}
			)AS");
		Code.SetCode("SemaActionOnlyUnresolvedCallOnce.as", ScriptSource.c_str(), true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("unresolved F() must still parse")));

		asSAstVerifyResult Verify;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
			TEXT("asCASTVerify must still accept an unsealed unresolved CALL; publication is the unsealed gate")));

		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("unresolved CALL must not fail Seal for missing callee")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("unresolved F() must intern one CALL with empty callee plus unresolved-call:F. dump:\n%s"), *Text);
		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountDumpEmptyCalleeCalls(Text), *DumpMsg));
		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountCallExprs(Context), *DumpMsg));
		ASSERT_THAT(AreEqual(1, static_cast<int32>(Sema.GetDiagnostics().GetLength()), *DumpMsg));
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::SemaHasDiagnosticPrefix(Sema, "unresolved-call:F"), *DumpMsg));
	}
```

Today this fails: two empty-callee CALLs (`resolvedDecl` required for reuse) and zero Sema diagnostics. Do **not** assert `asCASTVerify != OK` for missing callee.

`as_ast_verifier.h` is already included by `AngelscriptNativeCanonicalASTTestSupport.h`.

- [ ] **Step 4: Write `InternParsedCallReusesOffsetZeroUnresolvedCall`**

Expression snippet `"F()"` so the FunctionCall identifier is file offset 0. `asCParser::Reset` does not clear `sema`. `FParserAccessor::ParseExpressionSnippet` is the in-tree way to get a MemStack FunctionCall node (do not stack-allocate `asCScriptNode`).

```cpp
	TEST_METHOD(InternParsedCallReusesOffsetZeroUnresolvedCall)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaOffsetZeroCall");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaOffsetZeroCall module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const char* const Src = "F()";
		Code.SetCode("SemaOffsetZeroCall.as", Src, true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		AngelscriptNativeTestSupport::FParserAccessor Parser(&Builder);
		Parser.SetSema(&Sema);
		asCScriptNode* const Root = Parser.ParseExpressionSnippet(&Code);
		ASSERT_THAT(IsNotNull(Root, TEXT("F() expression snippet must parse")));
		asCScriptNode* const CallNode = CanonicalASTSemaAuthorityTest::FindFirstNodeOfType(Root, snFunctionCall);
		ASSERT_THAT(IsNotNull(CallNode, TEXT("snippet must contain snFunctionCall")));
		ASSERT_THAT(AreEqual(0, static_cast<int32>(CallNode->tokenPos), TEXT("FunctionCall begin must be offset 0")));

		asASTExprId FirstCall;
		for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
		{
			const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
			if (Expr && Expr->kind == asAST_EXPR_CALL)
			{
				FirstCall = Expr->id;
				break;
			}
		}
		ASSERT_THAT(IsTrue(FirstCall.IsValid(), TEXT("parser ActOnParsedExpr must intern the offset-0 CALL")));
		const asCExpr* const FirstExpr = Context.GetExpr(FirstCall);
		ASSERT_THAT(IsTrue(FirstExpr != nullptr && FirstExpr->range.begin.offset == 0,
			TEXT("interned CALL range.begin.offset must be 0")));

		const asASTFileID File = FirstExpr->range.begin.fileID;
		const asASTDeclId Owner = Context.GetTranslationUnit();
		const asASTExprId Second = Sema.InternParsedCall(CallNode, &Code, File, Owner);
		ASSERT_THAT(AreEqual(FirstCall.value, Second.value,
			TEXT("InternParsedCall must reuse the offset-0 CALL; ident-offset skip currently creates a second")));
		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountCallExprs(Context),
			TEXT("offset-0 unresolved F() must remain a single CALL")));
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::SemaHasDiagnosticPrefix(Sema, "unresolved-call:F"),
			TEXT("creating path records unresolved-call:F once")));
		ASSERT_THAT(AreEqual(1, static_cast<int32>(Sema.GetDiagnostics().GetLength()),
			TEXT("replay must not record a second unresolved-call:F")));

		asSAstVerifyResult Verify;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
			TEXT("unsealed offset-0 CALL-without-callee must still verify")));
	}
```

Today `callOffset == 0` skips the loop, so the second `InternParsedCall` allocates another CALL.

- [ ] **Step 5: Write `InternParsedCallDoesNotStealWiderCallAtSameBegin`**

Parse `"          F()                    "` **without** Sema so the FunctionCall at offset 10 is not interned. `ActOnCall` a resolved wrapper spanning `[10, 30]`. Then `InternParsedCall` the FunctionCall node (`F()` end ~13). kind+begin (and today's ident-offset + `resolvedDecl`) returns the wrapper. Full-span must not.

```cpp
	TEST_METHOD(InternParsedCallDoesNotStealWiderCallAtSameBegin)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaCallBeginSteal");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaCallBeginSteal module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const char* const Src = "          F()                    ";
		Code.SetCode("SemaCallBeginSteal.as", Src, true);
		ASSERT_THAT(IsTrue(FCStringAnsi::Strlen(Src) >= 30, TEXT("wrapper end 30 must sit inside the section")));

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaCallBeginSteal");
		const asASTFileID File = Context.AddSourceSection(
			"SemaCallBeginSteal.as",
			asAST_SOURCE_AUTHORED,
			Src,
			FCStringAnsi::Strlen(Src));
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, Context.GetSourceManager().MakeRange(File, 10u, 13u));
		asCArray<asASTExprId> NoArgs;
		const asCSourceRange Wide = Context.GetSourceManager().MakeRange(File, 10u, 30u);
		const asASTExprId Wrapper = Sema.ActOnCall(Fn, NoArgs, IntType, Wide);
		ASSERT_THAT(IsTrue(Wrapper.IsValid(), TEXT("wider CALL at begin 10 must intern")));
		const asCExpr* const WrapperExpr = Context.GetExpr(Wrapper);
		ASSERT_THAT(IsTrue(WrapperExpr != nullptr && WrapperExpr->range.begin.offset == 10
			&& WrapperExpr->range.end.offset == 30,
			TEXT("wrapper range must be [10,30]")));

		AngelscriptNativeTestSupport::FParserAccessor Parser(&Builder);
		asCScriptNode* const Root = Parser.ParseExpressionSnippet(&Code);
		ASSERT_THAT(IsNotNull(Root, TEXT("padded F() snippet must parse")));
		asCScriptNode* const CallNode = CanonicalASTSemaAuthorityTest::FindFirstNodeOfType(Root, snFunctionCall);
		ASSERT_THAT(IsNotNull(CallNode, TEXT("snippet must contain snFunctionCall")));
		ASSERT_THAT(AreEqual(10, static_cast<int32>(CallNode->tokenPos), TEXT("padded F() FunctionCall begin must be 10")));

		const asASTExprId Interned = Sema.InternParsedCall(CallNode, &Code, File, Tu);
		ASSERT_THAT(IsTrue(Interned.IsValid(), TEXT("InternParsedCall must intern F()")));
		ASSERT_THAT(IsTrue(Interned.value != Wrapper.value,
			TEXT("InternParsedCall must not steal the wider CALL that only shares begin.offset")));
		const asCExpr* const InternedExpr = Context.GetExpr(Interned);
		ASSERT_THAT(IsTrue(InternedExpr != nullptr
			&& InternedExpr->kind == asAST_EXPR_CALL
			&& InternedExpr->range.begin.offset == 10
			&& InternedExpr->range.end.offset == CallNode->tokenPos + CallNode->tokenLength,
			TEXT("F() CALL must keep the FunctionCall node end, not wrapper end 30")));

		const asASTExprId Again = Sema.InternParsedCall(CallNode, &Code, File, Tu);
		ASSERT_THAT(AreEqual(Interned.value, Again.value,
			TEXT("second InternParsedCall of the same FunctionCall range must reuse")));
	}
```

Today `callOffset` is 10 and the wrapper is a resolved CALL at begin 10, so InternParsedCall returns `Wrapper`.

- [ ] **Step 6: Write `ScopedCallInternsOnceOnCompileSealPath`**

Compile-seal twin of the action-only scoped test. `NamespaceOverloadSelectsScopedFunctionNotGlobal` only `Contains` `callee=Game::F(int)` — two copies still pass. Do not weaken it.

```cpp
	TEST_METHOD(ScopedCallInternsOnceOnCompileSealPath)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));

		asIScriptModule* const Module = ScriptEngine->GetModule("SemaScopedCallOnce", asGM_ALWAYS_CREATE);
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaScopedCallOnce module")));
		ASSERT_THAT(AreEqual(0, Module->SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)));
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			namespace Game
			{
				int F(int a)
				{
					return a;
				}
			}

			int F(int a)
			{
				return 0;
			}

			int Entry()
			{
				return Game::F(3);
			}
			)AS");
		ASSERT_THAT(AreEqual(0, Module->AddScriptSection("SemaScopedCallOnce.as", ScriptSource.c_str())));
		asCString Dump;
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst(Module, Dump),
			TEXT("Game::F(3) module must seal a dumpable AST")));
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("compile→seal Game::F(3) must intern one callee=Game::F(int) CALL. dump:\n%s"), *Text);
		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountDumpCallLinesWithCallee(Text, TEXT("callee=Game::F(int)")), *DumpMsg));
		ASSERT_THAT(AreEqual(0, CanonicalASTSemaAuthorityTest::CountDumpCallLinesWithCallee(Text, TEXT("callee=F(int)")), *DumpMsg));
	}
```

Keep `ParserActOnCallDoesNotDuplicateOnSuccessfulParse`, `ParserActOnCallSelectsIntOverloadBeforeFunctionCloseFails`, `ParserActOnCallExprBeforeArgListCloseFails`, `NamespaceOverloadSelectsScopedFunctionNotGlobal`, and `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` unchanged.

---

### Task 2: Build, then prove RED <!-- TDD -->

- [ ] **Step 1: Build**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-f2-identity-red -NoXGE -TimeoutMs 1800000
```

Expected: exit 0. Tests compile. No fork behavior change yet.

- [ ] **Step 2: Run SemaAuthority**

```powershell
Set-Location D:\as-cta
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-f2-sema-red -TimeoutMs 600000
```

Expected RED (not a hang, not a compile error):

| Method | Why it fails on live intern |
| --- | --- |
| `ParserActOnScopedCallDoesNotDuplicateOnSuccessfulParse` | Two `callee=Game::F(int)` CALL lines; ident `F` ≠ node begin `Game` |
| `ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse` | Two empty-callee CALLs; reuse requires `resolvedDecl`; no `unresolved-call:F` |
| `InternParsedCallReusesOffsetZeroUnresolvedCall` | `callOffset == 0` skips reuse; second InternParsedCall allocates |
| `InternParsedCallDoesNotStealWiderCallAtSameBegin` | ident-offset + `resolvedDecl` returns the `[10,30]` wrapper |
| `ScopedCallInternsOnceOnCompileSealPath` | Same ident-offset miss on the CANONICAL parse+WalkOne path |

Existing 214 methods stay green, including unscoped `ParserActOnCallDoesNotDuplicateOnSuccessfulParse`.

Do not start Task 3 until these five names fail for the reasons above.

---

### Task 3: Minimal intern fix <!-- TDD -->

**Files:**
- Modify: `as_sema_expr.cpp` `InternParsedCall` (`:1446-1518`) only

**Interfaces:**
- Consumes: `ExprRange`, `ActOnCallExpr`, `AddDiagnostic`, existing ident/args/scope walk
- Produces: one CALL per FunctionCall full range, including unresolved and offset 0

- [ ] **Step 1: Add `FindExistingCallByFullRange` and use it**

Replace `as_sema_expr.cpp:1471-1486` with `FindExistingCallByFullRange(context, range)` **before** creating args. Prefer calling it immediately after `range` is computed (`:1452`) so a replay does not re-`ActOnExprFromNode` the arguments. If you keep the child walk first, reuse must still return before `ActOnCallExpr`.

Do not call `FindExistingExpr` here.

- [ ] **Step 2: One-shot unresolved diagnostic**

After `return ActOnCallExpr(...)` is no longer a tail return, if the interned expr is `asAST_EXPR_CALL` and `!resolvedDecl.IsValid()`, `AddDiagnostic` a string `unresolved-call:` plus `name`. Skip when `existingCall` was returned. Do not change type to an error type (F4). Do not touch `as_ast_verifier.cpp`.

Shape:

```cpp
	const asASTExprId call = ActOnCallExpr(searchOwner, name.AddressOf(), args, range, implicitReceiver);
	if( const asCExpr* interned = context.GetExpr(call) )
	{
		if( interned->kind == asAST_EXPR_CALL && !interned->resolvedDecl.IsValid() )
		{
			asCString diagnostic = "unresolved-call:";
			diagnostic += name;
			AddDiagnostic(diagnostic.AddressOf());
		}
	}
	return call;
```

- [ ] **Step 3: Do not touch**

`FindExistingExpr`. `InternParsedExprTerm` Sequence pop / `ParseFunctionCall(false)`. `ActOnCall`. `as_bytecode_codegen.cpp`. Verifier. Dump format.

---

### Task 4: GREEN SemaAuthority <!-- TDD -->

- [ ] **Step 1: Build, then SemaAuthority**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-f2-identity -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-f2-sema -TimeoutMs 600000
```

Expected: **219/219** if F1 dump baseline is still 214 SemaAuthority methods and these five are the only adds. If eval-once or another landed method moved the live total, require **live+5 / live+5**, zero failed.

Locks that must stay green:

| Method | Lock |
| --- | --- |
| `ParserActOnCallDoesNotDuplicateOnSuccessfulParse` | one `callee=F(int,int)` |
| `ParserActOnCallSelectsIntOverloadBeforeFunctionCloseFails` | incomplete `F(3` → `callee=F(int)` |
| `ParserActOnCallExprBeforeArgListCloseFails` | incomplete `F(1, 2` interned |
| `NamespaceOverloadSelectsScopedFunctionNotGlobal` | `callee=Game::F(int)`, not global |
| `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` | one `Make()`, one `T::Get()` with `receiver=`, zero empty callee |

---

### Task 5: CanonicalAST after GREEN <!-- TDD -->

`RunTests.ps1` does not UBT. The Task 4 Build covers the test binary.

```powershell
Set-Location D:\as-cta
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-f2-canonical -TimeoutMs 600000
```

Expected: live CanonicalAST total + 5 (SemaAuthority methods sit under this prefix). Zero failed. Do **not** run All. Do **not** run Compiler-wide unless a SemaAuthority dump shows a sibling prefix regression — then stop and report; do not "fix" F3/F4 while here.

If eval-once already added a Semantics method, CanonicalAST live is 262+that before F2. Report the JSON success count honestly (`success` vs `succeededWithWarnings`).

---

### Task 6: Record, do not check boxes <!-- Non-TDD -->

- [ ] Append `## B-eighth-f2-call-identity` to `attachments/wave-b-results.md` with labels, JSON success counts, and the five method names.
- [ ] Patch `attachments/eighth-pass-verified.md` F2 row to **landed intern identity** (not 13.2).
- [ ] Leave `tasks.md` 13.2 / 13.3 / 4.2 / 5.4 / 5.6 / 9.5 `[ ]`.
- [ ] Do not commit. Do not archive. Do not start F3/F4 UBT until this record exists.

---

## Shared-file warning

F3 (`ConstructFromCallee` VALUE_OBJECT at `as_sema_expr.cpp:487`) and F4 (`ResolveCallee` same-arity walk `:444-454`, unresolved→int) are the same `as_sema_expr.cpp`.

**F2 is the next exclusive UBT after eval-once.** F3/F4 wait. Do not mix F3/F4 into this intern change. Do not spawn a second UBT against `as_sema_expr.cpp`.

Eval-once must not edit `as_sema_expr.cpp`. F2 must not edit `as_bytecode_codegen.cpp`.

---

## What GREEN is not

F2 GREEN means Parser action and WalkOne intern one FunctionCall-ranged CALL, including scoped, unresolved, and offset 0, without stealing a same-begin wider CALL.

It is **not**:

- 13.2 Sema environment so backends do not rerun Sema
- 13.3 / 4.2 Parser action-only for the language
- 5.4 single-evaluation / OpaqueValue memo / `EmitDeclRef` 1070
- 5.6 safepoint oracles complete
- 9.5 production `Build()` CodeGen completeness
- Replacing arena scan everywhere (`FindExistingExpr` / `FindExistingStmt` stay begin-only)
- Publication-requiring callee on unsealed `asCASTVerify` (F9). `asCASTVerify` stays OK on unsealed legal graphs; `asCASTVerifyPublication` remains the unsealed gate
- F3 `T()` class vs struct construction type
- F4 fail-closed overload / unresolved error type (unresolved CALL may still dump `type=int`)
- CANONICAL `CompileFunction` or default pipeline
- F1 Generate eval-once (`literalBits` in `EmitCall`)

---

## Must stay true after GREEN

| TEST_METHOD | Dump / arena lock |
| --- | --- |
| `ParserActOnScopedCallDoesNotDuplicateOnSuccessfulParse` | exactly one `callee=Game::F(int)`; zero CALL at ident `F` of `Game::F(3)` |
| `ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse` | one empty-callee CALL; one `unresolved-call:F`; `asCASTVerify` OK unsealed |
| `InternParsedCallReusesOffsetZeroUnresolvedCall` | first and second InternParsedCall same id; `range.begin.offset==0` |
| `InternParsedCallDoesNotStealWiderCallAtSameBegin` | interned id ≠ wrapper `[10,30]`; replay reuses interned |
| `ScopedCallInternsOnceOnCompileSealPath` | exactly one `callee=Game::F(int)` on compile→seal |
| `ParserActOnCallDoesNotDuplicateOnSuccessfulParse` | still one `callee=F(int,int)` |
| `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` | still one `Make()` / one `T::Get()` with `receiver=` |

---

## Forbidden

- Sharing UBT with eval-once / F3 / F4 / 5.4 / 5.6 / Wave E–G
- Globally full-span `FindExistingExpr` / `FindExistingStmt`
- Restoring whole-term CALL FindExisting in `InternParsedExprTerm`
- Retargeting CALL range to identifier offset
- Ident-offset scan **plus** full-span scan
- Pending action id on `asCScriptNode`
- Stack-allocated `asCScriptNode` (protected destructor)
- CALL-without-callee as unsealed verifier firewall
- Script `funcdef` / `@` / `is`
- Clang/LLVM link; Unreal types in fork frontend files
- `as_bytecode_codegen.cpp`
- Default `canonicalCompilerPipeline = true`
- CANONICAL `CompileFunction`
- Checking 13.2 / 13.3 / 4.2 / 5.4 / 5.6 / 9.5
- `RunTests.ps1` without a successful `RunBuild.ps1` after impl
- Suite All
