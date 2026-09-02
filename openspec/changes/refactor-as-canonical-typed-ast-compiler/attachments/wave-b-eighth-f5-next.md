# Wave B exclusive UBT — B-eighth-f5 Param/Enumerator identity

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:test-driven-development` then `superpowers:verification-before-completion` before claiming GREEN. One exclusive UBT. Do **not** check `tasks.md` 13.2 / 4.2 / 5.4 / 5.6 / 9.5. Do **not** start while F4 native still holds the UBT mutex.

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-eighth-f5-identity**.
Companions: `attachments/async-work.md` §4 Hole 2 / §8; `attachments/async-dispatch.md`; `attachments/eighth-pass-verified.md` F5; `reviews/implementation-rereview-2026-08-22-eighth-pass.md` F5; `reviews/implementation-rereview-2026-08-22-seventh-pass.md` F10.

**This is the next exclusive UBT after F4 native GREEN.** It shares `as_sema.cpp` with F4 `ActOnDeclRefExpr` and with 1070 DeclRef lookup. Sequential, not parallel. One UBT user in `D:\as-cta`.

Do not implement from the research agent that wrote this file. Do not run UBT from that agent.

---

## Goal

Param and Enumerator intern reuse **same owner + same source range** (or in-flight identity), **not** bare name.

- Incremental Parser `ActOnParsedParam` / `ActOnParsedEnumerator` plus complete WalkOne of the **same** name/type token **must** keep returning the first id (replay).
- Source that actually writes two same-name params or enumerators at **distinct ranges** **must** be a true duplicate: Sema diagnostic **and** a second node (or fail-closed invalid), **not** `return sibling`.
- Anonymous params stay distinct.
- Existing `duplicate-param:` lock on `GeneratedLifecycleImportOriginAndDuplicateParam` stays.

Do **not** close 4.2 / 13.2. This is eighth-pass F5 identity, not Parser action-only.

## Architecture

```text
Parser ParseParameterList
  ActOnParsedParam
    RangeOf(nameNode or typeNode)     authored, per-token
    ActOnStartParamDecl(fn, name, type, range)

WalkOne / WalkParameterSequence
  same RangeOf(nameNode or typeNode)
  ActOnStartParamDecl(...)            MUST reuse if range == existing

int Dup(int A, int A)
  first ident A  range R1
  second ident A range R2 != R1
  today:  name-only hit → duplicate-param:A, return first id, dump ONE Param A
  F5:    R2 != R1 → ActOnParamDecl (already records duplicate-param:A AND creates
          a second PARAM). WalkOne of R1/R2 then reuses each by range.

enum ETeam { Red, Red }
  today:  name-only VAR reuse, NO diagnostic, dump ONE Var Red
  F5:     distinct range → duplicate-enumerator:Red + second const VAR

construction-API empty asCSourceRange() twice, named "A"
  today and F5: ID-equal (in-flight identity). Must NOT be treated as a
  true duplicate. Existing SemaStartParamDeclActionRecordsParamWithoutScriptNode.

anonymous int F(int, int)
  empty names; type tokens have distinct authored ranges
  never collapse two slots, including two empty construction-API ranges
```

Reuse identity (already used for functions via `FindExistingFunctionLike` name-token offset, `as_sema_decl.cpp:997-1028`): **same owner + same source range**, not bare name. Distinct range + same name → diagnostic + second node.

Clang/LLVM is a **shape** reference only (ParmVarDecl / EnumConstantDecl identity is location, not spelling). No link. No Unreal types in fork frontend files.

Preferred algorithm inside `ActOnStartParamDecl` / `ActOnStartEnumeratorDecl` (file-local, no header change):

```text
replay id = invalid
sawDistinctSameName = false
for each sibling of owner:
  kind matches (PARAM or enumerator VAR)
  name matches (named path only)
    if sibling.range == incoming.range: replay = sibling; break
    else: sawDistinctSameName = true
if replay valid: return replay          // NO diagnostic
if sawDistinctSameName: fall through    // ActOnParamDecl records duplicate-param
                                        // enumerator records duplicate-enumerator then ActOnVarDecl
anonymous PARAM:
  reuse only when sibling name empty AND incoming.range is authored
  (fileID != 0) AND sibling.range == incoming.range
  two default-empty ranges never reuse
```

Do **not** record `duplicate-param:` on the replay return. `ActOnParamDecl` (`as_sema.cpp:369-393`) already records it when it **creates** the second node. Today's StartParam records **then** returns the sibling, so Parser+WalkOne of a true duplicate can emit the diagnostic three times and still dump one Param.

Fail-closed fallback (only if a second PARAM/VAR makes `asCASTVerify` fail — it currently does **not**; verifier has no duplicate-param/enumerator rule): return an invalid id after the diagnostic, still **not** the first sibling. Prefer the second node.

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-eighth-f5-identity** |
| Mode | Exclusive UBT **after** F4 native GREEN. TDD. |
| Live evidence | F5 **Partial** (`eighth-pass-verified.md`): diagnostic lock only |
| Do not mark | **13.2 / 13.3 / 4.2 / 5.4 / 5.6 / 9.5 / 9.1 / 13.6 / 10.2 / 10.4** |

## Global constraints (copy of `attachments/async-work.md` §8)

- 虚标: do not check 13.2 / 13.3 / 9.5 / 9.1 / 13.6 / 10.2 / 10.4 / 4.2 / 5.4 / 5.6 / 5.9 from prefix greens.
- CALL-without-callee as a seal/verifier firewall. `asCASTVerify` must still succeed on unsealed legal graphs. Publication is the unsealed gate.
- Second UBT in `D:\as-cta`. New worktree. Archive. Commit unless asked.
- Clang/LLVM link. Unreal types in fork frontend files.
- Script `funcdef` / `@` / `is`. Invent `dictionary`. Re-enable mutable globals as language. C labeled break.
- Default `canonicalCompilerPipeline = true`.
- CANONICAL `CompileFunction` (F2 keep mixed).
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`. Always `-NoXGE`.
- `RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after impl. Do not run tests against a failed build.
- `NotifySema` for nested statements (`ActOnParsedDeclaration` → `WalkOne` → leftover steal). Incremental stmt intern is `ActOnParsedStmt`.
- Globally changing `FindExistingStmt` / `FindExistingExpr` to full-span match.
- Weakening `decl-body`. Requiring `safepoint=` in `asCASTVerify`.
- Mutable script globals as Trace counters (`ConstGlobalTraitAndMutableReject`). Use `Trace(...)` / object fields.
- Restoring script same-arity fallback to bind `Get(bool)` from `v.Get(3)`.

Also this UBT:

- Default pipeline stays **LEGACY**. CANONICAL is per-Engine in existing F4 tests only; F5 tests parse/seal only.
- Inline AS: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Unsealed `asCASTVerify` must still succeed on legal construction graphs. Do **not** require CALL `resolvedDecl` on unsealed verify.
- No 1070 / OpaqueValue / RankArgument / F4 native remainder. No F6. No Wave E–G.
- Do not invent script `funcdef` / `@` / `is`. Host `RegisterFuncdef` remains legal (`ParserActOnFuncdef*` stay).

---

## Live defects (do not guess)

### `ActOnStartParamDecl` — name-only reuse after recording `duplicate-param:`

```395:415:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp
asASTDeclId asCSema::ActOnStartParamDecl(asASTDeclId parent, const char* name, const asCQualType& type, const asCSourceRange& range)
{
	if( const asCDecl* owner = context.GetDecl(parent) )
	{
		if( name && *name )
		{
			for( asUINT i = 0; i < owner->children.GetLength(); ++i )
			{
				const asCDecl* sibling = context.GetDecl(owner->children[i]);
				if( sibling && sibling->kind == asAST_DECL_PARAM && sibling->name.Equals(name) )
				{
					asCString msg;
					msg.Format("duplicate-param:%s", name);
					diagnostics.PushLast(msg);
					return sibling->id;
				}
			}
		}
	}
	return ActOnParamDecl(parent, name, type, range);
}
```

`ActOnParamDecl` `:369-393` already records `duplicate-param:%s` **and** `CreateTypedDecl` a second PARAM. The Start path never reaches it for a same-name sibling.

Callers (do not need edits if range identity is correct):

| Site | Role |
| --- | --- |
| `ActOnParsedParam` `as_sema_decl.cpp:613` | Parser incremental intern, `RangeOf(nameNode or typeNode)` |
| `WalkParameterSequence` `as_sema_decl.cpp:567` | WalkOne fill-extract, **same** `RangeOf` |
| Direct `ActOnStartParamDecl` | construction-API tests, often `asCSourceRange()` empty |

`asCSourceRange::operator==` compares `begin` and `end` (`as_source_location.h:61-64`). Default empty is `fileID=0, offset=0`. `RangeOf` (`as_sema_decl.cpp:83-90`) returns empty if `file==0` or `node==0`; otherwise `MakeRange(file, tokenPos, tokenPos+tokenLength)`.

### `ActOnStartEnumeratorDecl` — name-only VAR reuse, no diagnostic

```417:435:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp
asASTDeclId asCSema::ActOnStartEnumeratorDecl(asASTDeclId parent, const char* name, const asCSourceRange& range)
{
	if( name && *name )
	{
		if( const asCDecl* owner = context.GetDecl(parent) )
		{
			for( asUINT i = 0; i < owner->children.GetLength(); ++i )
			{
				const asCDecl* sibling = context.GetDecl(owner->children[i]);
				if( sibling && sibling->kind == asAST_DECL_VAR && sibling->name.Equals(name) )
				{
					return sibling->id;
				}
			}
		}
	}
	const asCQualType constInt = context.InternPrimitive(ttInt, asAST_QUAL_CONST);
	return ActOnVarDecl(parent, name, constInt, range);
}
```

Callers: `ActOnParsedEnumerator` `as_sema_decl.cpp:652`; WalkOne `snEnum` `:1347`; WalkOne `snIdentifier` `:1538`. All pass `RangeOf(..., ident/child/node)`.

Do **not** route enumerators through `ActOnStartVarDecl` (`as_sema_decl.cpp:1664-1672` is still name-only `FindExistingNamedDecl` for vars). That would re-swallow duplicates.

### Existing tests (locks vs the hole)

| TEST_METHOD | File | What it locks | F5 hole |
| --- | --- | --- | --- |
| `SemaStartParamDeclActionRecordsParamWithoutScriptNode` | `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:2389-2416` | two `ActOnStartParamDecl(Fn,"A",IntType, empty Range)` → **ID-equal**, dump **one** `kind=Param name=A`, `key=F(int)` | empty-range in-flight identity. Does **not** assert diagnostic. Do not add `duplicate-param:` here (that would lock the bug). |
| `SemaStartEnumeratorDeclActionRecordsEnumeratorWithoutScriptNode` | `:2418-2456` | two `ActOnStartEnumeratorDecl(En,"Red", empty Range)` → **ID-equal**, one `kind=Var name=Red`, `key=ETeam::Red`, `quals=1` | same empty-range replay. No distinct-range case. |
| `ParserActOnParamDoesNotDuplicateOnSuccessfulParse` | `:2491-2525` | `int F(int A) { return A; }` → **one** `kind=Param name=A` | replay of one authored range. No second `A`. |
| `ParserActOnParamBeforeParameterListCloseFails` | `:2458-2489` | `int F(int A, float` parse `< 0`, Function F + Param A | keep. |
| `ParserActOnEnumDoesNotDuplicateOnSuccessfulParse` | `:2852-2909` | `enum ETeam { Red, Blue }` → one `Var name=Red` | replay. `Red` ≠ `Blue`. |
| `ParserActOnEnumDeclAndEnumeratorBeforeListCloseFails` | `:2794-2850` | incomplete `Blue =` still interned `ETeam` + const `Red` | keep. |
| `GeneratedLifecycleImportOriginAndDuplicateParam` | `AngelscriptNativeCanonicalASTSemaTests.cpp:154-194` (Frontend prefix) | `int Dup(int A, int A)` records **`duplicate-param:A`**. Seal 0. Does **not** count Param lines | **diagnostic lock**. Today dump still has **one** Param A. After F5 dump may show two; this test stays GREEN because it only checks the diagnostic. |

`asCSourceRange Range;` in the two construction-API ID-equal tests is the **same empty range** twice. That is replay, not a true duplicate.

---

## File map

| Path | This UBT |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp` | **Only impl file.** `ActOnStartParamDecl` `:395-415` and `ActOnStartEnumeratorDecl` `:417-435`. File-local range-identity helper. Enumerator diagnostic `duplicate-enumerator:%s` via `diagnostics.PushLast` (same style as `duplicate-param:`). Do **not** change `ActOnParamDecl` create+diagnostic unless a proven double-record on the create path. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Append the RED methods before the closing `};` of `FCanonicalASTSemaAuthorityTests` (after `UnresolvedCallDoesNotPublishFakeIntSuccess` `:10419`). |
| `as_ast_dump.cpp` | **Do not edit.** `kind=Param name=A` / `kind=Var name=Red` already dump. No new token. |
| `as_sema.h` / `as_sema_decl.cpp` / `as_parser.cpp` / `as_sema_expr.cpp` / `as_ast_verifier.cpp` / `as_bytecode_codegen.cpp` | **Do not edit.** |
| Frontend `AngelscriptNativeCanonicalASTSemaTests.cpp` | **Do not weaken** `GeneratedLifecycleImportOriginAndDuplicateParam`. Do not add `Count==1` Param. |

---

## Must stay green (do not weaken)

| Test | Contract |
| --- | --- |
| `SemaStartParamDeclActionRecordsParamWithoutScriptNode` | empty-range named `A` twice → same id, **one** `kind=Param name=A`, `key=F(int)` |
| `SemaStartEnumeratorDeclActionRecordsEnumeratorWithoutScriptNode` | empty-range `Red` twice → same id, one const enumerator |
| `ParserActOnParamDoesNotDuplicateOnSuccessfulParse` | one authored `A` → one Param, `key=F(int)` |
| `ParserActOnEnumDoesNotDuplicateOnSuccessfulParse` | one `Red` + one `Blue` |
| `ParserActOnParamBeforeParameterListCloseFails` | incomplete list keeps Function F + Param A |
| `ParserActOnEnumDeclAndEnumeratorBeforeListCloseFails` | incomplete `Blue =` keeps const `Red` |
| `GeneratedLifecycleImportOriginAndDuplicateParam` | still sees `duplicate-param:A` |
| `MemberSameArityTypeMismatchDoesNotBindFirstMethod` | F4: `v.Get(3)` no `callee=T::Get(bool)`, no `callee=Get(int)`, `unresolved-callee:` |
| `MemberAmbiguousOverloadDoesNotBindFirstSameArity` | F4: no first `T::Get(int,float)` |
| `MixinCallBindsReceiverNotFreeGlobal` | Mixin: `v.MixHelper(3)` binds mixin |
| `UnresolvedCallMissingIsErrorTypeNotInt` | F4 construction-API ERROR; unsealed verify OK |
| `UnresolvedDeclRefMissingIsErrorTypeNotInt` | F4 DeclRef ERROR |
| `UnresolvedCallDoesNotPublishFakeIntSuccess` | CANONICAL Build `!= 0` for `Missing()` |
| `ClassTemporaryConstructInternsReferenceObjectNotValueObject` | F3 |
| `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` | F1 dump |
| ProductionCodeGen class/struct flags | sixth-pass runtime flags — do not reverse |

---

## Exact TDD RED tests

Append these `TEST_METHOD`s to `FCanonicalASTSemaAuthorityTests`. Match file style: Allman braces, `ASTEST_AS_ANSI(R"AS( ... )AS")`, `CountDumpLinesContaining` / `DiagnosticEquals` already in `CanonicalASTSemaAuthorityTest`.

**Honest first-run matrix (current tree, tests added, no impl yet):**

| New TEST_METHOD | First run |
| --- | --- |
| `SemaStartParamDeclDistinctRangeDuplicateCreatesSecondParam` | **RED** (`First==Second`, dump count 1). `duplicate-param:A` already present |
| `ParserDuplicateParamDistinctRangeInternsSecondParamAndDiagnostic` | **RED** (dump count 1). Diagnostic already present |
| `SemaStartParamDeclAnonymousParamsStayDistinct` | **GREEN lock** today (`if(name && *name)` skips). Will RED if reuse ignores empty names |
| `ParserAnonymousParamsStayDistinct` | **GREEN lock** today. Same risk |
| `SemaStartParamDeclSameAuthoredRangeReplayReusesWithoutDuplicateDiagnostic` | **RED** on `!duplicate-param:A` (today records on name match even when ranges equal). ID-equal already holds |
| `SemaStartEnumeratorDeclDistinctRangeDuplicateCreatesSecondVar` | **RED** (ID-equal, no diagnostic, dump count 1) |
| `ParserDuplicateEnumeratorDistinctRangeInternsSecondVarAndDiagnostic` | **RED** (dump count 1, no diagnostic) |
| `ParserSameNameParamOnDifferentFunctionsIsNotDuplicate` | **GREEN lock** (different owners) |

Do not rewrite existing ID-equal tests weaker. Do not assert `duplicate-param:` on empty-range replay.

### Construction-API + parser tests (paste)

```cpp
	TEST_METHOD(SemaStartParamDeclDistinctRangeDuplicateCreatesSecondParam)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaDupParamRange");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const char* const Src = "int Dup(int A, int A);";
		const asASTFileID File = Context.AddSourceSection(
			"SemaDupParamRange.as",
			asAST_SOURCE_AUTHORED,
			Src,
			FCStringAnsi::Strlen(Src));
		ASSERT_THAT(IsTrue(File != 0, TEXT("authored section must have fileID != 0")));
		const asCSourceRange FirstRange = Context.GetSourceManager().MakeRange(File, 12u, 13u);
		const asCSourceRange SecondRange = Context.GetSourceManager().MakeRange(File, 19u, 20u);
		ASSERT_THAT(IsTrue(FirstRange.IsValid() && SecondRange.IsValid(),
			TEXT("distinct authored param ranges must be valid")));
		ASSERT_THAT(IsTrue(!(FirstRange == SecondRange),
			TEXT("F5 true duplicate is distinct range, not empty-range replay")));
		const asASTDeclId Fn = Sema.ActOnStartFunctionDecl(Tu, "Dup", IntType, FirstRange);
		const asASTDeclId First = Sema.ActOnStartParamDecl(Fn, "A", IntType, FirstRange);
		const asASTDeclId Second = Sema.ActOnStartParamDecl(Fn, "A", IntType, SecondRange);
		ASSERT_THAT(IsTrue(First.IsValid() && Second.IsValid(),
			TEXT("both Dup(int A, int A) params must intern")));
		ASSERT_THAT(IsTrue(First.value != Second.value,
			TEXT("distinct-range same-name param must be a second PARAM, not return sibling")));

		asSAstVerifyResult Verify;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
			TEXT("unsealed duplicate-param graph must still asCASTVerify")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("duplicate-param is a Sema diagnostic, not a verifier firewall")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
		const FString DumpMsg = FString::Printf(
			TEXT("distinct-range Dup(int A, int A) must dump two Param A and duplicate-param:A. dump:\n%s\ndiag:\n%s"),
			*Text, *Diag);
		ASSERT_THAT(AreEqual(2, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Param name=A")), *DumpMsg));
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "duplicate-param:A"), *DumpMsg));
	}

	TEST_METHOD(ParserDuplicateParamDistinctRangeInternsSecondParamAndDiagnostic)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaParserDupParam");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaParserDupParam module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int Dup(int A, int A)
			{
				return A;
			}
			)AS");
		Code.SetCode("SemaParserDupParam.as", ScriptSource.c_str(), true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("duplicate param names must still parse")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("duplicate-param is Sema diagnostic, Seal stays structural")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
		const FString DumpMsg = FString::Printf(
			TEXT("Parser+WalkOne of Dup(int A, int A) must intern two Param A, not swallow the second as replay. dump:\n%s\ndiag:\n%s"),
			*Text, *Diag);
		ASSERT_THAT(AreEqual(2, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Param name=A")), *DumpMsg));
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "duplicate-param:A"), *DumpMsg));
	}

	TEST_METHOD(SemaStartParamDeclAnonymousParamsStayDistinct)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaAnonParam");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asCSourceRange Range;
		const asASTDeclId Fn = Sema.ActOnStartFunctionDecl(Tu, "F", IntType, Range);
		const asASTDeclId First = Sema.ActOnStartParamDecl(Fn, "", IntType, Range);
		const asASTDeclId Second = Sema.ActOnStartParamDecl(Fn, "", IntType, Range);
		ASSERT_THAT(IsTrue(First.IsValid() && Second.IsValid(),
			TEXT("anonymous params must intern")));
		ASSERT_THAT(IsTrue(First.value != Second.value,
			TEXT("two empty-range anonymous params must stay distinct slots")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		int32 AnonymousParams = 0;
		for (asUINT Index = 1; Index <= Context.GetDeclCount(); ++Index)
		{
			const asCDecl* Decl = Context.GetDecl(asASTDeclId(Index));
			if (Decl && Decl->kind == asAST_DECL_PARAM && Decl->parent == Fn && Decl->name.GetLength() == 0)
			{
				++AnonymousParams;
			}
		}
		const FString DumpMsg = FString::Printf(
			TEXT("empty-range anonymous ActOnStartParamDecl must not collapse. dump:\n%s"), *Text);
		ASSERT_THAT(AreEqual(2, AnonymousParams, *DumpMsg));
		ASSERT_THAT(IsTrue(!CanonicalASTSemaAuthorityTest::SemaHasDiagnosticPrefix(Sema, "duplicate-param:"), *DumpMsg));
	}

	TEST_METHOD(ParserAnonymousParamsStayDistinct)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaParserAnonParam");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaParserAnonParam module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int F(int, int)
			{
				return 0;
			}
			)AS");
		Code.SetCode("SemaParserAnonParam.as", ScriptSource.c_str(), true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("anonymous param list must parse")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("anonymous params graph should verify")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("int F(int, int) must intern two PARAM slots (distinct type-token ranges), not one. dump:\n%s"),
			*Text);
		ASSERT_THAT(AreEqual(2, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Param")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("key=F(int,int)")), *DumpMsg));
		ASSERT_THAT(IsTrue(!CanonicalASTSemaAuthorityTest::SemaHasDiagnosticPrefix(Sema, "duplicate-param:"), *DumpMsg));
	}

	TEST_METHOD(SemaStartParamDeclSameAuthoredRangeReplayReusesWithoutDuplicateDiagnostic)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaReplayParamRange");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const char* const Src = "int F(int A);";
		const asASTFileID File = Context.AddSourceSection(
			"SemaReplayParamRange.as",
			asAST_SOURCE_AUTHORED,
			Src,
			FCStringAnsi::Strlen(Src));
		ASSERT_THAT(IsTrue(File != 0, TEXT("authored section must have fileID != 0")));
		const asCSourceRange Range = Context.GetSourceManager().MakeRange(File, 10u, 11u);
		ASSERT_THAT(IsTrue(Range.IsValid(), TEXT("replay identity is a valid authored range")));
		const asASTDeclId Fn = Sema.ActOnStartFunctionDecl(Tu, "F", IntType, Range);
		const asASTDeclId First = Sema.ActOnStartParamDecl(Fn, "A", IntType, Range);
		const asASTDeclId Second = Sema.ActOnStartParamDecl(Fn, "A", IntType, Range);
		ASSERT_THAT(IsTrue(First.IsValid(), TEXT("first ActOnStartParamDecl intern")));
		ASSERT_THAT(AreEqual(First.value, Second.value,
			TEXT("same owner + same authored range is Parser/WalkOne replay, not a duplicate")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
		const FString DumpMsg = FString::Printf(
			TEXT("same-range replay must dump one Param A and must not emit duplicate-param:A. dump:\n%s\ndiag:\n%s"),
			*Text, *Diag);
		ASSERT_THAT(AreEqual(1, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Param name=A")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("key=F(int)")), *DumpMsg));
		ASSERT_THAT(IsTrue(!CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "duplicate-param:A"), *DumpMsg));
	}

	TEST_METHOD(SemaStartEnumeratorDeclDistinctRangeDuplicateCreatesSecondVar)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaDupEnumRange");
		const char* const Src = "enum ETeam { Red, Red }";
		const asASTFileID File = Context.AddSourceSection(
			"SemaDupEnumRange.as",
			asAST_SOURCE_AUTHORED,
			Src,
			FCStringAnsi::Strlen(Src));
		ASSERT_THAT(IsTrue(File != 0, TEXT("authored section must have fileID != 0")));
		const asCSourceRange FirstRange = Context.GetSourceManager().MakeRange(File, 13u, 16u);
		const asCSourceRange SecondRange = Context.GetSourceManager().MakeRange(File, 18u, 21u);
		ASSERT_THAT(IsTrue(FirstRange.IsValid() && SecondRange.IsValid(),
			TEXT("distinct authored enumerator ranges must be valid")));
		ASSERT_THAT(IsTrue(!(FirstRange == SecondRange),
			TEXT("F5 true duplicate enumerator is distinct range")));
		const asASTDeclId En = Sema.ActOnStartEnumDecl(Tu, "ETeam", FirstRange);
		const asASTDeclId First = Sema.ActOnStartEnumeratorDecl(En, "Red", FirstRange);
		const asASTDeclId Second = Sema.ActOnStartEnumeratorDecl(En, "Red", SecondRange);
		ASSERT_THAT(IsTrue(First.IsValid() && Second.IsValid(),
			TEXT("both Red enumerators must intern")));
		ASSERT_THAT(IsTrue(First.value != Second.value,
			TEXT("distinct-range same-name enumerator must be a second VAR, not return sibling")));

		asSAstVerifyResult Verify;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
			TEXT("unsealed duplicate-enumerator graph must still asCASTVerify")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("duplicate-enumerator is a Sema diagnostic, not a verifier firewall")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
		const FString DumpMsg = FString::Printf(
			TEXT("distinct-range enum { Red, Red } must dump two const Var Red and duplicate-enumerator:Red. dump:\n%s\ndiag:\n%s"),
			*Text, *Diag);
		ASSERT_THAT(AreEqual(2, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Var name=Red")), *DumpMsg));
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "duplicate-enumerator:Red"), *DumpMsg));
	}

	TEST_METHOD(ParserDuplicateEnumeratorDistinctRangeInternsSecondVarAndDiagnostic)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaParserDupEnum");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaParserDupEnum module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			enum ETeam
			{
				Red,
				Red
			}

			int Entry()
			{
				return 0;
			}
			)AS");
		Code.SetCode("SemaParserDupEnum.as", ScriptSource.c_str(), true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("duplicate enumerator names must still parse")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("duplicate-enumerator is Sema diagnostic, Seal stays structural")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
		const FString DumpMsg = FString::Printf(
			TEXT("Parser+WalkOne of enum { Red, Red } must intern two Var Red, not swallow the second as replay. dump:\n%s\ndiag:\n%s"),
			*Text, *Diag);
		ASSERT_THAT(AreEqual(2, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Var name=Red")), *DumpMsg));
		ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "duplicate-enumerator:Red"), *DumpMsg));
	}

	TEST_METHOD(ParserSameNameParamOnDifferentFunctionsIsNotDuplicate)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaParamPerOwner");
		ASSERT_THAT(IsNotNull(Module, TEXT("SemaParamPerOwner module")));
		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int F(int A)
			{
				return A;
			}

			int G(int A)
			{
				return A;
			}
			)AS");
		Code.SetCode("SemaParamPerOwner.as", ScriptSource.c_str(), true);

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("same param name on two functions must parse")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("per-owner param names are not duplicates")));

		asCString Dump;
		asCASTDump(Context, Dump);
		const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("F(int A) and G(int A) must intern two Param A under different owners, no duplicate-param:A. dump:\n%s"),
			*Text);
		ASSERT_THAT(AreEqual(2, CanonicalASTSemaAuthorityTest::CountDumpLinesContaining(Text, TEXT("kind=Param name=A")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("key=F(int)")), *DumpMsg));
		ASSERT_THAT(IsTrue(Text.Contains(TEXT("key=G(int)")), *DumpMsg));
		ASSERT_THAT(IsTrue(!CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "duplicate-param:A"), *DumpMsg));
	}
```

Do **not** assert `key=F(int)` on the distinct-range Dup tests. After two PARAM children, `FinishDecl(parent)` yields `key=Dup(int,int)`. That is expected.

`CountDumpLinesContaining(..., TEXT("kind=Param name="))` is **unsafe** (it also matches `kind=Param name=A`). Anonymous construction-API test counts decls; parser anonymous test uses `kind=Param` in a fixture that has no other params.

---

### Task 1: Write the failing tests (no impl)

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` (append before `};` of `FCanonicalASTSemaAuthorityTests`)
- Do not edit `as_sema.cpp` yet

- [ ] **Step 1: Paste the eight TEST_METHODs** from the block above. Do not touch the existing empty-range ID-equal methods.

- [ ] **Step 2: RED build**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f5-red -NoXGE -TimeoutMs 1800000
```

Expected: build OK. CAEngine `UE4Editor`/`MSBuild`/`link` on this machine is **not** this lock.

- [ ] **Step 3: RED SemaAuthority**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f5-red -TimeoutMs 600000
```

Expected: prefix **not** all-green. Failures **only** on the new distinct-range / no-diagnostic-on-replay methods listed in the first-run matrix. Existing F1 / F3 / F4 / Mixin / empty-range ID-equal / `ParserActOnParamDoesNotDuplicateOnSuccessfulParse` stay PASS.

If F1/F3/F4 intern tests are RED, stop and systematic-debug those first. That is not F5.

Copy `Saved\Tests\wave-b-eighth-f5-red\*\Summary.json` (or the report dir `RunTests.ps1` prints).

### Task 2: Minimal `as_sema.cpp` identity fix

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp:395-435`

**Interfaces:**
- Consumes: `asCDecl::{kind,name,range,id}`, `asCSourceRange::operator==`, `ActOnParamDecl`, `ActOnVarDecl`
- Produces: replay return of the same id; true duplicate falls through to create + diagnostic

- [ ] **Step 4: Implement range identity**

Keep a file-local helper next to the two ActOnStart functions (no `as_sema.h` change):

```cpp
static bool SameReplayRange(const asCSourceRange& existing, const asCSourceRange& incoming)
{
	return existing == incoming;
}

static bool IsAuthoredRange(const asCSourceRange& range)
{
	return range.begin.fileID != 0;
}
```

`ActOnStartParamDecl` replacement shape (preserve `ActOnParamDecl` as the create path):

```cpp
asASTDeclId asCSema::ActOnStartParamDecl(asASTDeclId parent, const char* name, const asCQualType& type, const asCSourceRange& range)
{
	if( const asCDecl* owner = context.GetDecl(parent) )
	{
		const bool named = name && *name;
		for( asUINT i = 0; i < owner->children.GetLength(); ++i )
		{
			const asCDecl* sibling = context.GetDecl(owner->children[i]);
			if( sibling == 0 || sibling->kind != asAST_DECL_PARAM )
			{
				continue;
			}
			if( named )
			{
				if( sibling->name.Equals(name) && SameReplayRange(sibling->range, range) )
				{
					return sibling->id;
				}
			}
			else if( sibling->name.GetLength() == 0
				&& IsAuthoredRange(range)
				&& SameReplayRange(sibling->range, range) )
			{
				return sibling->id;
			}
		}
	}
	return ActOnParamDecl(parent, name, type, range);
}
```

Scan **all** siblings for a range hit **before** treating a same-name miss as a new duplicate. If the first sibling is `A@R1` and the incoming range is `R2`, do not `return sibling->id`. Fall through so `ActOnParamDecl` records `duplicate-param:A` and creates the second node. A later WalkOne of `R2` then hits `SameReplayRange` on the second node.

Do **not** `diagnostics.PushLast("duplicate-param:")` in `ActOnStartParamDecl`. Replay must be silent. `ActOnParamDecl` already formats `duplicate-param:%s`.

`ActOnStartEnumeratorDecl` replacement shape:

```cpp
asASTDeclId asCSema::ActOnStartEnumeratorDecl(asASTDeclId parent, const char* name, const asCSourceRange& range)
{
	bool sawDistinctSameName = false;
	if( name && *name )
	{
		if( const asCDecl* owner = context.GetDecl(parent) )
		{
			for( asUINT i = 0; i < owner->children.GetLength(); ++i )
			{
				const asCDecl* sibling = context.GetDecl(owner->children[i]);
				if( sibling == 0 || sibling->kind != asAST_DECL_VAR || !sibling->name.Equals(name) )
				{
					continue;
				}
				if( SameReplayRange(sibling->range, range) )
				{
					return sibling->id;
				}
				sawDistinctSameName = true;
			}
		}
	}
	if( sawDistinctSameName && name && *name )
	{
		asCString msg;
		msg.Format("duplicate-enumerator:%s", name);
		diagnostics.PushLast(msg);
	}
	const asCQualType constInt = context.InternPrimitive(ttInt, asAST_QUAL_CONST);
	return ActOnVarDecl(parent, name, constInt, range);
}
```

Enumerator create stays `ActOnVarDecl` + const int. Do **not** call `ActOnStartVarDecl` (name-only intern).

Forbidden in this step:

- Globally changing `FindExistingExpr` / `FindExistingStmt` to full-span.
- Changing `FindExistingNamedDecl` / `ActOnStartVarDecl` name-only reuse.
- Requiring CALL `resolvedDecl` in `asCASTVerify`.
- Touching `ActOnDeclRefExpr` (1070 / F4).
- Restoring script same-arity.
- Default CANONICAL / CANONICAL `CompileFunction`.
- Inventing script `funcdef` / `@` / `is` / `dictionary`.

- [ ] **Step 5: GREEN build + SemaAuthority + CanonicalAST**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f5-sema -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f5-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-eighth-f5-canonical -TimeoutMs 600000
```

Expected:

- SemaAuthority **0 failed**. Live total = previous 227 (or post-F4-native live) **+ 8** new methods (expected **235/235** if F4 native added none).
- CanonicalAST full prefix **0 failed** (total = previous + 8).
- Must-stay-green list above still PASS.

Optional lock (not required to close the UBT, but cheap):

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Sema" -Label wave-b-eighth-f5-frontend -TimeoutMs 600000
```

Expected: `GeneratedLifecycleImportOriginAndDuplicateParam` still sees `duplicate-param:A`.

Do **not** run All. Do **not** run ProductionCodeGen as the primary of this UBT (F4 native already owns array `insertLast`). If a drive-by SemaAuthority F4 intern test is RED, that is a regression — revert F5, do not weaken F4.

### Task 3: Record, do not commit

- [ ] **Step 6: Record**

Append `## B-eighth-f5-identity` to `attachments/wave-b-results.md` with RED `wave-b-eighth-f5-red` and GREEN `wave-b-eighth-f5-sema` / `wave-b-eighth-f5-canonical` report paths.

Patch `eighth-pass-verified.md` F5 row: distinct-range second Param/VAR + `duplicate-param:` / `duplicate-enumerator:` ; replay still ID-equal; **not** 4.2 / 13.2.

Leave `tasks.md` boxes `[ ]`. A one-paragraph progress note on 4.2/13.2 is allowed; do not check them.

Patch `async-dispatch.md` exclusive row to **landed** only if SemaAuthority 0 failed and CanonicalAST 0 failed.

Do not commit. Do not archive. Do not start 1070 / OpaqueValue / Wave E.

---

## Hard no (this UBT)

- Globally changing `FindExistingExpr` / `FindExistingStmt` to full-span.
- Unsealed `asCASTVerify` requiring CALL `resolvedDecl`.
- Default `canonicalCompilerPipeline = true`.
- CANONICAL `CompileFunction`.
- Inventing script `funcdef` / `@` / `is` / `dictionary`.
- Checking 13.2 / 4.2 / 5.4 / 9.5 from these prefix greens.
- Second UBT in `D:\as-cta` (F5 vs 1070 vs leftover F4 native).
- Weakening `GeneratedLifecycleImportOriginAndDuplicateParam` or the empty-range ID-equal tests.
- Collapsing anonymous params by empty range.
- Recording `duplicate-param:` on same-range replay (would fail `SemaStartParamDeclSameAuthoredRangeReplayReusesWithoutDuplicateDiagnostic` and mis-label WalkOne).
- Routing enumerators through `ActOnStartVarDecl`.
