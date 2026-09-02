# Wave B sequential exclusive UBTs — F3 `T()` type then F4 fail-closed lookup

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:test-driven-development`. Two sequential exclusive UBTs after F2. Do **not** start while eval-once or F2 owns `as_sema_expr.cpp`. Do **not** check `tasks.md` 13.2 / 4.2 / 5.4 / 5.6 / 9.5.

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
**Attachments-only research until the exclusive UBT mutex is free.** This file is the ready-to-execute TDD map. No UBT from this research agent.

Companions: `reviews/implementation-rereview-2026-08-22-eighth-pass.md` F3/F4; `attachments/eighth-pass-verified.md`; `attachments/async-work.md` §4 Hole 3; `attachments/wave-b-eighth-f2-next.md` (F2 identity — **next** exclusive UBT after eval-once, **before** this map).

---

## Header — two sequential exclusive UBTs (not parallel)

| Package | After | Files | Why it is its own UBT |
| --- | --- | --- | --- |
| **B-eighth-f3-construct-type** | F2 GREEN | `as_sema_expr.cpp` `ConstructFromCallee`; `as_ast_dump.cpp` `typeKind=` | One function + dump field. Independently reviewable. |
| **B-eighth-f4-fail-closed** | F3 GREEN | `as_sema_expr.cpp` `ResolveCallee` / `ActOnCallExpr`; `as_sema.cpp` `ActOnDeclRefExpr` | Different contract (diagnostics + ERROR type). Can fail `AmbiguousOverload*` / construction-API tests without reverting F3. |

They share `as_sema_expr.cpp`, so they are **not parallel**. They are **not** one bite-sized UBT: F4 changes lookup control-flow and two ActOn paths; a reviewer can accept F3 and reject F4. Default (honored): **two sequential exclusive UBTs, same file, F3 then F4**.

**Shared-file mutex**

```text
now:     B-54-eval-once-codegen   as_bytecode_codegen.cpp only
next:    B-eighth-f2-call-identity as_sema_expr.cpp
then:    B-eighth-f3-construct-type as_sema_expr.cpp + as_ast_dump.cpp
then:    B-eighth-f4-fail-closed    as_sema_expr.cpp + as_sema.cpp
```

Do **not** start F3 while eval-once holds the UBT mutex, even though eval-once does not edit `as_sema_expr.cpp`. Do **not** start F3 or F4 while F2 is the exclusive UBT. One UBT user in `D:\as-cta`.

---

## Goal

1. **F3:** `T()` construction QualType follows the class descriptor / `asAST_TRAIT_VALUE`, not a hard-coded `VALUE_OBJECT`. Script `class C()` is `REFERENCE_OBJECT` + implicit handle. Script `struct S()` is `VALUE_OBJECT`.
2. **F4:** Member overload miss stays fail-closed after `FindBestCallee`. Unresolved DeclRef/Call intern `asAST_TYPE_ERROR` `"<unresolved>"` plus a diagnostic — never a silent successful `int`.

**Unresolved-type choice (F4, do not substitute):** keep `asAST_EXPR_CALL` / `asAST_EXPR_DECL_REF` node kinds (dump still says Call/DeclRef). Intern **one** named type `context.InternNamedType(asAST_TYPE_ERROR, "<unresolved>", 0)`. Do **not** use `asAST_EXPR_ERROR` as the node kind (dump maps unknown kinds to `"Expr"` and hides that it was a call/ref). Do **not** invent a fake `int` success node. Do **not** require `CALL.resolvedDecl` on unsealed `asCASTVerify`. Publication fail-closed is **Sema diagnostics → `asCBuilder::SealCanonicalAST` already returns `asINVALID_DECLARATION`** (`as_builder.cpp:691-704`). `Context.Seal()` stays `asCASTVerify` only.

---

## Architecture

```text
T() / C() / S()
  FindBestCallee → CLASS (or CONSTRUCTOR)
  ConstructFromCallee
    today: InternNamedType(VALUE_OBJECT, name)     // F3 defect
    F3:    QualTypeFromClassDecl(traits + intern)

member v.Get(...)
  FindBestCallee(typeDecl)
    hit → method
    miss + ambiguous-overload diagnostic → invalid
    miss, no viable
  today: first METHOD with same name + param count   // F4 defect
  F4:    return invalid; do not search free functions

ActOnCallExpr / ActOnDeclRefExpr miss
  today: InternPrimitive(ttInt) + valid-looking node
  F4:    AddDiagnostic + InternNamedType(ERROR, "<unresolved>")
         CALL/DECL_REF keep kinds; resolvedDecl stays invalid
```

Clang/LLVM is a **shape** reference only (CXXConstructExpr type follows the record; failed lookup is an error type, not `int`). No link. No Unreal types in fork frontend files.

---

## Global constraints

- Default pipeline stays **LEGACY**. CANONICAL is per-Engine in these tests only.
- `CompileFunction` stays mixed **COMPILER**.
- Script `class` is **REF + implicit handle**; script `struct` is **VALUE**. Do not reverse sixth-pass runtime flags (`asOBJ_REF|asOBJ_IMPLICIT_HANDLE` vs `asOBJ_VALUE`). Do not edit `as_bytecode_codegen.cpp` / `as_runtime_type_bridge.cpp` in these UBTs.
- Do not invent script `funcdef` / `@` / `is`. Host `RegisterFuncdef` remains legal (existing `ParserActOnFuncdef*` tests stay).
- Unsealed `asCASTVerify` must still succeed on legal construction graphs. Do **not** require CALL `resolvedDecl` on unsealed verify. `asCASTVerifyPublication` remains the unsealed-publication gate (`UNSEALED_PUBLICATION`).
- No ABI matrix (1/2-byte, >8-byte, handle AddRef, list construct). No F6 atomic install. No 5.4 Generate / OpaqueValue / 1070.
- Inline AS: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`. Always `-NoXGE` on `RunBuild.ps1`. `RunTests.ps1` does not UBT. Implementer **must** `RunBuild.ps1` before `RunTests.ps1`. Never All.
- Do not check **13.2 / 4.2 / 5.4 / 5.6 / 9.5**. Do not archive. Do not commit unless asked.

---

## Live defects (verified 2026-08-22)

### F3 — `ConstructFromCallee` always `VALUE_OBJECT`

```471:488:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp
static asASTExprId ConstructFromCallee(asCSema& sema, asCASTContext& context, asASTDeclId callee, const asCArray<asASTExprId>& args, const asCSourceRange& range)
{
	const asCDecl* decl = context.GetDecl(callee);
	if( decl == 0 )
	{
		return asASTExprId();
	}
	const asCDecl* classDecl = decl;
	if( decl->kind == asAST_DECL_CONSTRUCTOR )
	{
		classDecl = context.GetDecl(decl->parent);
	}
	if( classDecl == 0 || classDecl->kind != asAST_DECL_CLASS )
	{
		return asASTExprId();
	}
	const asCQualType type = context.InternNamedType(asAST_TYPE_VALUE_OBJECT, classDecl->name.AddressOf(), 0);
	return sema.ActOnConstruct(type, args, range);
}
```

`asAST_TRAIT_VALUE` is already set for script `struct` at `as_sema_decl.cpp:1302-1305` (`node->tokenType == ttStruct`). Runtime flags already land in ProductionCodeGen `ScriptClassIsRefImplicitHandleAndStructIsValue`. Construction expr type did not follow.

`InternType` (`as_ast_context.cpp:216-239`) keys on **kind + primitiveToken + stableKey**. A `VALUE_OBJECT` `"C"` and a `REFERENCE_OBJECT` `"C"` are two `asCType`s. F3 must intern the class construction as `REFERENCE_OBJECT` so it can reuse an already-interned ref/handle type.

### F4 — same-arity-first fallback + unresolved `int`

```421:468:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp
static asASTDeclId ResolveCallee(...)
{
	if( implicitReceiver.IsValid() )
	{
		...
		const asASTDeclId method = FindBestCallee(context, typeDecl, name, withoutReceiver, &sema);
		if( method.IsValid() )
		{
			return method;
		}
		if( const asCDecl* cls = context.GetDecl(typeDecl) )
		{
			for( asUINT c = 0; c < cls->children.GetLength(); ++c )
			{
				const asCDecl* child = context.GetDecl(cls->children[c]);
				if( child && child->kind == asAST_DECL_METHOD && child->name.Equals(name)
					&& CountParams(context, child) == withoutReceiver.GetLength() )
				{
					return child->id;   // F4: DELETE this fallback
				}
			}
		}
	}
	... FindBestCallee(searchOwner) ...   // F4: do not reach this after a member miss
}
```

`FindBestCallee` (`as_sema_expr.cpp:1156-1261`) already records `"ambiguous-overload"` and returns invalid. Same-arity walk undoes that. After deleting the walk, a member miss must **return invalid immediately** — falling through to free-function `FindBestCallee(searchOwner)` would bind a global `Get(int)` from `v.Get(3)`.

Unresolved `int`:

```536:544:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp
	asCQualType type = context.InternPrimitive(ttInt, 0);
	if( const asCDecl* decl = context.GetDecl(callee) )
	{
		if( decl->type.IsValid() )
		{
			type = decl->type;
		}
	}
	const asASTExprId call = ActOnCall(callee, args, type, range);
```

```698:706:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp
	asCQualType type = context.InternPrimitive(ttInt, 0);
	if( const asCDecl* decl = context.GetDecl(target) )
	{
		if( decl->type.IsValid() )
		{
			type = decl->type;
		}
	}
	const asASTExprId ref = ActOnDeclRef(target, type, range);
```

`asAST_TYPE_ERROR` / `asAST_EXPR_ERROR` already exist in `as_ast_kind.h:78,91`. Verifier allows `asAST_EXPR_ERROR` with optional type (`as_ast_verifier.cpp:488-504`) and does **not** require CALL `resolvedDecl`. Keep that. `asCASTVerifyPublication` (`:544-550`) only rejects unsealed graphs, then calls `asCASTVerify`.

Existing tests that must stay green (do not weaken):

| Test | Why it matters |
| --- | --- |
| `ConstructorOverloadsSelectExactCtorNotFirstName` | struct `T v(3)` ctor identity |
| `DestructorCallSiteRecordsCallee` | struct `T().X` cleanup |
| `ParserActOnConstructTemporaryBeforeArgListCloseFails` | class `FValue(` construct/lifetime intern |
| `SemaConstructActionSelectsIntCtorWithoutScriptNode` | direct `ActOnConstruct` still selects `T::T(int)` — **bypass** of `ConstructFromCallee`; do not retcon it to VALUE_OBJECT |
| `AmbiguousOverloadIsRejectedNotFirstName` | free `F(1,2)` no first-name; **`Context.Seal()==0`** (missing callee is not a verifier firewall) |
| `CallSelectsExactIntOverloadNotFirstName` / `SemaCallExprActionSelectsIntOverloadWithoutScriptNode` | exact overload |
| `SemaDeclRefExprActionSelectsInnerVarNotGlobalWithoutScriptNode` | successful DeclRef type=float |
| `ParserActOnMemberOverloadCallBeforeArgListCloseFails` | `v.Get(3` binds `T::Get(int)` not float |
| `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` | F1 dump |
| `RejectsUnsealedPublication` | unsealed `asCASTVerify` OK; publication is the gate |
| ProductionCodeGen class/struct flags | sixth-pass runtime flags — do not reverse |

---

## File map

| Path | F3 | F4 |
| --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | `ConstructFromCallee` + `QualTypeFromClassDecl` | `ResolveCallee` (delete `:444-454`, member miss returns invalid); `ActOnCallExpr` unresolved branch |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | `AppendTypeKind` next to `AppendSafePoint` | no change unless F3 dump already landed |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp` | none | `ActOnDeclRefExpr` miss → ERROR type + `unresolved-identifier:` |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | 3 methods | 5 methods |
| `as_ast_verifier.cpp` / `as_bytecode_codegen.cpp` / `as_sema_decl.cpp` / runtime flags | **do not edit** | **do not edit** |

Helpers to add in `namespace CanonicalASTSemaAuthorityTest` (same file, before the TEST_CLASS):

```cpp
static FString JoinDiagnostics(const asCSema& Sema)
{
	FString Text;
	const asCArray<asCString>& Diags = Sema.GetDiagnostics();
	for (asUINT i = 0; i < Diags.GetLength(); ++i)
	{
		if (i)
		{
			Text += TEXT("\n");
		}
		Text += UTF8_TO_TCHAR(Diags[i].AddressOf() ? Diags[i].AddressOf() : "");
	}
	return Text;
}

static const asCExpr* FindFirstExprOfKind(asCASTContext& Context, asEASTExprKind Kind)
{
	for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
	{
		const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
		if (Expr && Expr->kind == Kind)
		{
			return Expr;
		}
	}
	return nullptr;
}

static bool DiagnosticEquals(const asCSema& Sema, const char* Token)
{
	const asCArray<asCString>& Diags = Sema.GetDiagnostics();
	for (asUINT i = 0; i < Diags.GetLength(); ++i)
	{
		if (Diags[i].Equals(Token))
		{
			return true;
		}
	}
	return false;
}

static bool DiagnosticStartsWith(const asCSema& Sema, const char* Prefix)
{
	const asCArray<asCString>& Diags = Sema.GetDiagnostics();
	for (asUINT i = 0; i < Diags.GetLength(); ++i)
	{
		if (Prefix && Prefix[0] && Diags[i].StartsWith(Prefix))
		{
			return true;
		}
	}
	return false;
}
```

Dump field (F3): `typeKind=ValueObject|ReferenceObject|Primitive|Error|...` appended on every EXPR line. Existing `Contains(TEXT("type=int"))` tests keep working.

---

## F3 rule — class `C()` vs struct `S()`

| Source | Decl trait | Construct QualType | Construct plan |
| --- | --- | --- | --- |
| `class C { } … C()` | no `asAST_TRAIT_VALUE` | `InternNamedType(asAST_TYPE_REFERENCE_OBJECT, "C", asAST_QUAL_HANDLE \| asAST_QUAL_AUTO_HANDLE)` | factory / implicit-handle temporary; still `ActOnConstruct` (existing Materialize/Cleanup wrap stays) |
| `struct S { } … S()` | `asAST_TRAIT_VALUE` | `InternNamedType(asAST_TYPE_VALUE_OBJECT, "S", 0)` | value construction (today’s accidental plan, now correct) |

If `classDecl->type` is already interned with the **matching kind**, reuse `asCType` id and apply the quals above. Do not intern a second `VALUE_OBJECT` `"C"` when a `REFERENCE_OBJECT` `"C"` already exists.

Do **not** retcon `ActOnQualType` for all script class names in this UBT (task 4.3). Handle assignment/return is locked **only if already interned** (direct-action reuse test).

Do **not** require CANONICAL `Build()==0` execute of `C tmp = C();` — that is F6/9.5 ABI. F3 is parse+seal dump + GetType kind.

---

## F4 rule — fail-closed

1. Delete `ResolveCallee` `:444-454` same-arity-first walk.
2. If `implicitReceiver` is valid and `FindBestCallee` misses: **`return asASTDeclId();`** — do not search free functions.
3. `FindBestCallee` keeps `"ambiguous-overload"` (already recorded).
4. `ActOnCallExpr` when `!callee.IsValid()`:
   - `AddDiagnostic` `"unresolved-callee:" + name`
   - `InternNamedType(asAST_TYPE_ERROR, "<unresolved>", 0)`
   - `ActOnCall(asASTDeclId(), args, errorType, range)`
   - `SetLiteral(call, name)` so dump shows `literal=Missing` / `literal=Get` with **empty** `callee=`
5. `ActOnDeclRefExpr` when `!target.IsValid()`:
   - `AddDiagnostic` `"unresolved-identifier:" + name`
   - same ERROR QualType
   - `ActOnDeclRef(asASTDeclId(), errorType, range)` + `SetLiteral(name)`
6. Unsealed `asCASTVerify` unchanged. `AmbiguousOverloadIsRejectedNotFirstName` still `Seal()==0`.
7. CANONICAL `Module->Build()` of unresolved `Missing()` stays **non-zero** via existing `SealCanonicalAST` diagnostic drain. That is publication fail-closed. Do not add CALL-callee to `asCASTVerify`.

Diagnostic tokens (exact):

| Case | Token |
| --- | --- |
| Ambiguous member/free (already) | `ambiguous-overload` |
| No-viable / missing call | `unresolved-callee:<name>` |
| Missing DeclRef | `unresolved-identifier:<name>` |

---

# Package 1 — B-eighth-f3-construct-type

**Exclusive UBT after F2 GREEN.**

**Files:**
- Modify: `as_sema_expr.cpp:471-488`
- Modify: `as_ast_dump.cpp` (AppendTypeKind before AppendSafePoint at `:508`)
- Test: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` (append three methods before the class-closing `};`). Add `#include "source/as_ast_verifier.h"` next to `as_ast_dump.h` (needed for the reuse test's `asCASTVerify`; F4 uses the same include).

**Interfaces:**
- Consumes: `asAST_TRAIT_VALUE`, `InternNamedType`, `ActOnConstruct`, `AddDeclTrait`
- Produces: `QualTypeFromClassDecl` used only by `ConstructFromCallee`. F4 does not depend on dump `typeKind=` except to assert `typeKind=Error`.

### Task 1: Failing F3 tests + dump field lock

- [ ] **Step 1: Write the three failing tests** (and the helpers above). Add `TEST_METHOD`s at the end of `FCanonicalASTSemaAuthorityTests`.

```cpp
TEST_METHOD(ClassTemporaryConstructInternsReferenceObjectNotValueObject)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaClassCtorType");
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaClassCtorType module")));
	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptCode Code;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		class C
		{
		}

		int Entry()
		{
			return 0;
			C();
		}
		)AS");
	Code.SetCode("SemaClassCtorType.as", ScriptSource.c_str(), true);

	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	asCParser Parser(&Builder);
	Parser.SetSema(&Sema);
	ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("class C() fixture must parse")));
	ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("class C() graph must still seal; this is not a verifier firewall")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("class C() must intern REFERENCE_OBJECT + handle, not VALUE_OBJECT. dump:\n%s"), *Text);

	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Class name=C")), *DumpMsg));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Construct")), *DumpMsg));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("type=C")), *DumpMsg));
	bool bDumpConstructRef = false;
	TArray<FString> Lines;
	Text.ParseIntoArrayLines(Lines);
	for (const FString& Line : Lines)
	{
		if (!Line.Contains(TEXT("kind=Construct")))
		{
			continue;
		}
		ASSERT_THAT(IsTrue(Line.Contains(TEXT("typeKind=ReferenceObject")), *DumpMsg));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("typeKind=ValueObject")), *DumpMsg));
		bDumpConstructRef = true;
	}
	ASSERT_THAT(IsTrue(bDumpConstructRef, *DumpMsg));

	bool bConstructIsRefHandle = false;
	for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
	{
		const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
		if (Expr == nullptr || Expr->kind != asAST_EXPR_CONSTRUCT)
		{
			continue;
		}
		const asCType* Ty = Context.GetType(Expr->type.type);
		ASSERT_THAT(IsNotNull(Ty, *DumpMsg));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_REFERENCE_OBJECT, (int)Ty->kind, *DumpMsg));
		ASSERT_THAT(IsTrue((Expr->type.quals & asAST_QUAL_HANDLE) != 0, *DumpMsg));
		ASSERT_THAT(IsTrue((Expr->type.quals & asAST_QUAL_AUTO_HANDLE) != 0, *DumpMsg));
		bConstructIsRefHandle = true;
	}
	ASSERT_THAT(IsTrue(bConstructIsRefHandle, *DumpMsg));
}

TEST_METHOD(StructTemporaryConstructInternsValueObject)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaStructCtorType");
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaStructCtorType module")));
	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptCode Code;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		struct S
		{
		}

		int Entry()
		{
			return 0;
			S();
		}
		)AS");
	Code.SetCode("SemaStructCtorType.as", ScriptSource.c_str(), true);

	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	asCParser Parser(&Builder);
	Parser.SetSema(&Sema);
	ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("struct S() fixture must parse")));
	ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("struct S() graph must still seal")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("struct S() must stay VALUE_OBJECT with no handle. dump:\n%s"), *Text);

	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Class name=S")), *DumpMsg));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Construct")), *DumpMsg));
	bool bDumpConstructValue = false;
	TArray<FString> StructLines;
	Text.ParseIntoArrayLines(StructLines);
	for (const FString& Line : StructLines)
	{
		if (!Line.Contains(TEXT("kind=Construct")))
		{
			continue;
		}
		ASSERT_THAT(IsTrue(Line.Contains(TEXT("typeKind=ValueObject")), *DumpMsg));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("typeKind=ReferenceObject")), *DumpMsg));
		bDumpConstructValue = true;
	}
	ASSERT_THAT(IsTrue(bDumpConstructValue, *DumpMsg));

	bool bConstructIsValue = false;
	for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
	{
		const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
		if (Expr == nullptr || Expr->kind != asAST_EXPR_CONSTRUCT)
		{
			continue;
		}
		const asCType* Ty = Context.GetType(Expr->type.type);
		ASSERT_THAT(IsNotNull(Ty, *DumpMsg));
		ASSERT_THAT(AreEqual((int)asAST_TYPE_VALUE_OBJECT, (int)Ty->kind, *DumpMsg));
		ASSERT_THAT(IsTrue((Expr->type.quals & asAST_QUAL_HANDLE) == 0, *DumpMsg));
		bConstructIsValue = true;
	}
	ASSERT_THAT(IsTrue(bConstructIsValue, *DumpMsg));
}

TEST_METHOD(ClassConstructReusesInternedReferenceHandleType)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaClassCtorReuse");
	const asCSourceRange Range;
	const asDWORD HandleQuals = asAST_QUAL_HANDLE | asAST_QUAL_AUTO_HANDLE;
	const asCQualType Interned = Context.InternNamedType(asAST_TYPE_REFERENCE_OBJECT, "C", HandleQuals);
	const asASTDeclId ClassId = Sema.ActOnClassDecl(Tu, "C", Range);
	(void)ClassId;
	asCArray<asASTExprId> Args;
	const asASTExprId Call = Sema.ActOnCallExpr(Tu, "C", Args, Range);
	ASSERT_THAT(IsTrue(Call.IsValid(), TEXT("ActOnCallExpr(C) must intern a construct")));

	const asCExpr* Construct = CanonicalASTSemaAuthorityTest::FindFirstExprOfKind(Context, asAST_EXPR_CONSTRUCT);
	ASSERT_THAT(IsNotNull(Construct, TEXT("C() must intern a Construct node")));
	ASSERT_THAT(AreEqual(Interned.type.value, Construct->type.type.value,
		TEXT("C() must reuse the already-interned REFERENCE_OBJECT C, not a new VALUE_OBJECT C")));
	ASSERT_THAT(IsTrue((Construct->type.quals & asAST_QUAL_HANDLE) != 0,
		TEXT("reused class construct is an implicit handle")));

	const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "Make", Interned, Range);
	const asASTExprId RetVal = Sema.ActOnCallExpr(Fn, "C", Args, Range);
	const asASTStmtId Body = Sema.ActOnReturnStmt(Fn, RetVal, Range);
	(void)Body;
	const asCExpr* RetConstruct = nullptr;
	for (asUINT i = 1; i <= Context.GetExprCount(); ++i)
	{
		const asCExpr* Expr = Context.GetExpr(asASTExprId(i));
		if (Expr && Expr->kind == asAST_EXPR_CONSTRUCT && Expr->id != Construct->id)
		{
			RetConstruct = Expr;
			break;
		}
	}
	if (RetConstruct)
	{
		ASSERT_THAT(AreEqual(Interned.type.value, RetConstruct->type.type.value,
			TEXT("return C() reuses the same interned REFERENCE_OBJECT when already interned")));
	}

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("typeKind=ReferenceObject")),
		TEXT("dump must show ReferenceObject for interned class C()")));
	asSAstVerifyResult Verify;
	ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
		TEXT("unsealed/sealed-legal construction graph must still asCASTVerify")));
}
```

`return 0; C();` keeps `Entry` well-typed so Seal is not blocked by a typed return of `C`. The `C()` expr is still interned as a second statement (not unreachable-eliminated by the parser).

If parse drops `C();` after `return`, switch the body to:

```text
C Make()
{
	return C();
}
```

**Do not** then require `Build()==0` or VM execute. Parse+seal dump only. If `C Make()` return QualType is still `VALUE_OBJECT` from `ActOnQualType`, **ignore the function return type** and still lock the **Construct expr** kind. That QualType hole is 4.3, not F3.

- [ ] **Step 2: Build, then RED (SemaAuthority)**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f3-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f3-red -TimeoutMs 600000
```

Expected RED:

- `ClassTemporaryConstructInternsReferenceObjectNotValueObject` — Construct `GetType()->kind == VALUE_OBJECT` (live `:487`) and/or dump missing `typeKind=ReferenceObject`.
- `StructTemporaryConstructInternsValueObject` — may already have VALUE_OBJECT kind; it goes RED if `typeKind=` is missing, then GREEN with dump+no-handle. If it is already fully green before dump lands, keep it as the struct lock.
- `ClassConstructReusesInternedReferenceHandleType` — Construct intern is `VALUE_OBJECT` `"C"`, so `type.value` ≠ interned `REFERENCE_OBJECT` `"C"`.

Record the exact assertion in `attachments/wave-b-results.md`. `RunTests.ps1` does not UBT.

### Task 2: Minimal F3 implementation

- [ ] **Step 3: Dump `typeKind=` then `QualTypeFromClassDecl`**

In `as_ast_dump.cpp`, next to `AppendSafePoint`:

```cpp
static const char* TypeKindName(asEASTTypeKind kind)
{
	switch( kind )
	{
	case asAST_TYPE_VOID: return "Void";
	case asAST_TYPE_PRIMITIVE: return "Primitive";
	case asAST_TYPE_ENUM: return "Enum";
	case asAST_TYPE_FUNCDEF: return "FuncDef";
	case asAST_TYPE_VALUE_OBJECT: return "ValueObject";
	case asAST_TYPE_REFERENCE_OBJECT: return "ReferenceObject";
	case asAST_TYPE_TEMPLATE: return "Template";
	case asAST_TYPE_ERROR: return "Error";
	default: return "Invalid";
	}
}

static void AppendTypeKind(asCString& line, const asCASTContext& context, const asCQualType& type)
{
	const asCType* named = context.GetType(type.type);
	if( named == 0 )
	{
		return;
	}
	if( line.GetLength() && line[line.GetLength() - 1] == '\n' )
	{
		line.SetLength(line.GetLength() - 1);
	}
	line += " typeKind=";
	line += TypeKindName(named->kind);
	line += "\n";
}
```

Call `AppendTypeKind(line, context, expr->type);` immediately before `AppendSafePoint(line, expr->safePointRole);`.

In `as_sema_expr.cpp`, replace the `InternNamedType(asAST_TYPE_VALUE_OBJECT, …)` line with:

```cpp
static asCQualType QualTypeFromClassDecl(asCASTContext& context, const asCDecl* classDecl)
{
	const bool isValue = classDecl && (classDecl->traits & asAST_TRAIT_VALUE) != 0;
	const asEASTTypeKind kind = isValue ? asAST_TYPE_VALUE_OBJECT : asAST_TYPE_REFERENCE_OBJECT;
	const asDWORD quals = isValue ? 0 : (asAST_QUAL_HANDLE | asAST_QUAL_AUTO_HANDLE);
	if( classDecl && classDecl->type.IsValid() )
	{
		if( const asCType* named = context.GetType(classDecl->type.type) )
		{
			if( named->kind == kind )
			{
				return asCQualType(named->id, quals);
			}
		}
	}
	const char* name = (classDecl && classDecl->name.GetLength()) ? classDecl->name.AddressOf() : "";
	return context.InternNamedType(kind, name, quals);
}
```

`ConstructFromCallee` then:

```cpp
	const asCQualType type = QualTypeFromClassDecl(context, classDecl);
	return sema.ActOnConstruct(type, args, range);
```

Do not change `ActOnConstruct` wrapping. Do not change `FindBestCallee` CLASS return (that is how `T()` becomes construct). Do not set `asAST_TRAIT_VALUE` on `ActOnClassDecl` (parse `ttStruct` already does). Direct-action class without the trait is REFERENCE — that matches script `class`.

- [ ] **Step 4: Build, then GREEN prefixes (SemaAuthority then CanonicalAST)**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f3 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f3-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-eighth-f3-canonical -TimeoutMs 600000
```

Expected: SemaAuthority **live+3** (or live total if dump-only methods already counted). CanonicalAST live+3. Existing ctor/dtor/FValue( / F1 dump tests still PASS.

Do **not** run All. Do **not** run ProductionCodeGen ABI. Do **not** check 13.2 / 5.4 / 9.5.

- [ ] **Step 5: Record, do not commit**

Append `## B-eighth-f3-construct-type` to `attachments/wave-b-results.md` with RED/GREEN report paths. Patch `eighth-pass-verified.md` F3 row: construction expr follows traits; ABI matrix still open. Leave `tasks.md` boxes `[ ]`.

---

# Package 2 — B-eighth-f4-fail-closed

**Exclusive UBT after F3 GREEN.** Same `as_sema_expr.cpp`. Do not start in parallel with F3.

**Files:**
- Modify: `as_sema_expr.cpp` `ResolveCallee` `:421-468` and `ActOnCallExpr` `:508-544`
- Modify: `as_sema.cpp` `ActOnDeclRefExpr` `:680-712`
- Test: same SemaAuthority file (five methods). Add `#include "source/as_ast_verifier.h"` next to the existing `as_ast_dump.h` include so `asCASTVerify` / `asCASTVerifyPublication` compile.
- Do **not** edit `as_ast_verifier.cpp`

**Interfaces:**
- Consumes: F3 dump `typeKind=`; `FindBestCallee` `ambiguous-overload`; `SealCanonicalAST` diagnostic drain
- Produces: ERROR QualType `"<unresolved>"`; tokens `unresolved-callee:<name>` / `unresolved-identifier:<name>`

### Task 3: Failing F4 tests

- [ ] **Step 1: Write the five failing tests**

```cpp
TEST_METHOD(MemberAmbiguousOverloadDoesNotBindFirstSameArity)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaMemberAmbiguous");
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaMemberAmbiguous module")));
	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptCode Code;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		class T
		{
			int Get(int a, float b)
			{
				return 1;
			}

			int Get(float a, int b)
			{
				return 2;
			}
		}

		int Entry()
		{
			T v;
			return v.Get(1, 2);
		}
		)AS");
	Code.SetCode("SemaMemberAmbiguous.as", ScriptSource.c_str(), true);

	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	asCParser Parser(&Builder);
	Parser.SetSema(&Sema);
	ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("tie-score member overloads must still parse")));
	ASSERT_THAT(AreEqual(0, Context.Seal(),
		TEXT("ambiguous member call must still seal; missing callee is not a verifier firewall")));
	asSAstVerifyResult Verify;
	ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
		TEXT("unsealed-legal graph: asCASTVerify must not require CALL resolvedDecl")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
	const FString DumpMsg = FString::Printf(
		TEXT("v.Get(1, 2) must not bind the first same-arity Get. dump:\n%s\ndiag:\n%s"), *Text, *Diag);

	ASSERT_THAT(IsTrue(Text.Contains(TEXT("key=T::Get(int,float)")), *DumpMsg));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("key=T::Get(float,int)")), *DumpMsg));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("callee=T::Get(int,float)")), *DumpMsg));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("callee=T::Get(float,int)")), *DumpMsg));
	ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticEquals(Sema, "ambiguous-overload"), *DumpMsg));
}

TEST_METHOD(MemberSameArityTypeMismatchDoesNotBindFirstMethod)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "SemaMemberNoViable");
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaMemberNoViable module")));
	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptCode Code;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Get(int a)
		{
			return 99;
		}

		class T
		{
			int Get(bool a)
			{
				return 1;
			}
		}

		int Entry()
		{
			T v;
			return v.Get(3);
		}
		)AS");
	Code.SetCode("SemaMemberNoViable.as", ScriptSource.c_str(), true);

	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	asCParser Parser(&Builder);
	Parser.SetSema(&Sema);
	ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("same-arity mismatch member call must still parse")));
	ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("no-viable member must still seal structurally")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	const FString Diag = CanonicalASTSemaAuthorityTest::JoinDiagnostics(Sema);
	const FString DumpMsg = FString::Printf(
		TEXT("v.Get(3) must not bind T::Get(bool) or free Get(int). dump:\n%s\ndiag:\n%s"), *Text, *Diag);

	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("callee=T::Get(bool)")), *DumpMsg));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("callee=Get(int)")), *DumpMsg));
	ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticStartsWith(Sema, "unresolved-callee:"), *DumpMsg));

	bool bErrorCall = false;
	TArray<FString> Lines;
	Text.ParseIntoArrayLines(Lines);
	for (const FString& Line : Lines)
	{
		if (Line.Contains(TEXT("kind=Call")) && Line.Contains(TEXT("literal=Get")) && !Line.Contains(TEXT("callee=T::")))
		{
			ASSERT_THAT(IsTrue(Line.Contains(TEXT("type=<unresolved>")) || Line.Contains(TEXT("typeKind=Error")), *DumpMsg));
			ASSERT_THAT(IsTrue(!Line.Contains(TEXT("type=int")), *DumpMsg));
			bErrorCall = true;
		}
	}
	ASSERT_THAT(IsTrue(bErrorCall || Diag.Contains(TEXT("unresolved-callee:")), *DumpMsg));
}

TEST_METHOD(UnresolvedCallMissingIsErrorTypeNotInt)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaMissingCall");
	const asCSourceRange Range;
	asCArray<asASTExprId> Args;
	const asASTExprId Call = Sema.ActOnCallExpr(Tu, "Missing", Args, Range);
	ASSERT_THAT(IsTrue(Call.IsValid(), TEXT("ActOnCallExpr(Missing) must still return a node for unsealed construction")));

	const asCExpr* Expr = Context.GetExpr(Call);
	ASSERT_THAT(IsNotNull(Expr, TEXT("missing call node")));
	ASSERT_THAT(AreEqual((int)asAST_EXPR_CALL, (int)Expr->kind, TEXT("keep CALL kind; do not switch to EXPR_ERROR")));
	ASSERT_THAT(IsTrue(!Expr->resolvedDecl.IsValid(), TEXT("lookup miss must not invent a callee")));
	const asCType* Ty = Context.GetType(Expr->type.type);
	ASSERT_THAT(IsNotNull(Ty, TEXT("ERROR type must be interned")));
	ASSERT_THAT(AreEqual((int)asAST_TYPE_ERROR, (int)Ty->kind, TEXT("Missing() is ERROR, not primitive int")));
	ASSERT_THAT(IsTrue(Ty->stableKey.Equals("<unresolved>"), TEXT("stable key <unresolved>")));
	ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticStartsWith(Sema, "unresolved-callee:Missing"),
		TEXT("diagnostic must name Missing")));

	asSAstVerifyResult Verify;
	ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
		TEXT("unsealed construction API: asCASTVerify must succeed without CALL resolvedDecl")));
	ASSERT_THAT(AreEqual((int)asAST_VERIFY_UNSEALED_PUBLICATION, asCASTVerifyPublication(Context, Verify),
		TEXT("publication of an unsealed graph stays fail-closed")));
	ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("structurally valid ERROR-typed CALL may Seal via asCASTVerify")));
	ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerifyPublication(Context, Verify),
		TEXT("sealed ERROR-typed CALL is still a legal construction graph; Build publication is diagnostics")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Call")), TEXT("dump Call")));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("type=<unresolved>")), TEXT("dump must not look like type=int success")));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("typeKind=Error")), TEXT("dump type-kind Error")));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("literal=Missing")), TEXT("preserve the missing name")));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("callee=Missing")), TEXT("empty callee; not a resolved function named Missing")));
}

TEST_METHOD(UnresolvedDeclRefMissingIsErrorTypeNotInt)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaMissingRef");
	const asCSourceRange Range;
	const asASTExprId Ref = Sema.ActOnDeclRefExpr(Tu, "Missing", Range);
	ASSERT_THAT(IsTrue(Ref.IsValid(), TEXT("ActOnDeclRefExpr(Missing) must still return a node")));

	const asCExpr* Expr = Context.GetExpr(Ref);
	ASSERT_THAT(IsNotNull(Expr, TEXT("missing DeclRef node")));
	ASSERT_THAT(AreEqual((int)asAST_EXPR_DECL_REF, (int)Expr->kind, TEXT("keep DeclRef kind")));
	ASSERT_THAT(IsTrue(!Expr->resolvedDecl.IsValid(), TEXT("lookup miss must not invent a target")));
	const asCType* Ty = Context.GetType(Expr->type.type);
	ASSERT_THAT(IsNotNull(Ty, TEXT("ERROR type must be interned")));
	ASSERT_THAT(AreEqual((int)asAST_TYPE_ERROR, (int)Ty->kind, TEXT("Missing is ERROR, not int lvalue")));
	ASSERT_THAT(IsTrue(CanonicalASTSemaAuthorityTest::DiagnosticStartsWith(Sema, "unresolved-identifier:Missing"),
		TEXT("diagnostic must name Missing")));

	asSAstVerifyResult Verify;
	ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Verify),
		TEXT("unsealed DeclRef without target must still asCASTVerify")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = CanonicalAstDumpToFString(Dump);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=DeclRef")), TEXT("dump DeclRef")));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("type=<unresolved>")), TEXT("not type=int")));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("typeKind=Error")), TEXT("dump type-kind Error")));
}

TEST_METHOD(UnresolvedCallDoesNotPublishFakeIntSuccess)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));
	asIScriptModule* const Module = ScriptEngine->GetModule("SemaMissingPublish", asGM_ALWAYS_CREATE);
	ASSERT_THAT(IsNotNull(Module, TEXT("SemaMissingPublish module")));
	ASSERT_THAT(AreEqual(0, Module->SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)));
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			return Missing();
		}
		)AS");
	ASSERT_THAT(AreEqual(0, Module->AddScriptSection("SemaMissingPublish.as", ScriptSource.c_str())));
	const int Built = Module->Build();
	ASSERT_THAT(IsTrue(Built != 0,
		TEXT("CANONICAL Build must not publish Missing() as a successful int call")));

	asCModule* const Concrete = static_cast<asCModule*>(Module);
	const asCASTContext* const Ctx = Concrete != nullptr ? Concrete->GetCanonicalASTContext() : nullptr;
	if (Ctx != nullptr)
	{
		asCString Dump;
		asCASTDump(*Ctx, Dump);
		const FString Text = CanonicalAstDumpToFString(Dump);
		const FString DumpMsg = FString::Printf(
			TEXT("published-or-retained dump must not present Missing() as type=int success. dump:\n%s"), *Text);
		bool bFakeIntCall = false;
		TArray<FString> Lines;
		Text.ParseIntoArrayLines(Lines);
		for (const FString& Line : Lines)
		{
			if (Line.Contains(TEXT("kind=Call"))
				&& Line.Contains(TEXT("literal=Missing"))
				&& Line.Contains(TEXT("type=int"))
				&& Line.Contains(TEXT("typeKind=Primitive")))
			{
				bFakeIntCall = true;
			}
		}
		ASSERT_THAT(IsTrue(!bFakeIntCall, *DumpMsg));
	}
}
```

`RankArgument` returns `-1` for `bool` vs `int` (`as_sema_expr.cpp:1125-1153`) — that is why `Get(bool)` + `v.Get(3)` is a real no-viable, not a conversion. `Get(float)` would convert and must **not** be this fixture.

- [ ] **Step 2: Build, then RED**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f4-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f4-red -TimeoutMs 600000
```

Expected RED:

- `MemberAmbiguousOverloadDoesNotBindFirstSameArity` — dump contains `callee=T::Get(int,float)` (declaration-order first).
- `MemberSameArityTypeMismatchDoesNotBindFirstMethod` — `callee=T::Get(bool)` and/or `callee=Get(int)`.
- `UnresolvedCallMissingIsErrorTypeNotInt` — `Ty->kind == PRIMITIVE` / `type=int`.
- `UnresolvedDeclRefMissingIsErrorTypeNotInt` — int lvalue DeclRef, no diagnostic.
- `UnresolvedCallDoesNotPublishFakeIntSuccess` — if Build already `!= 0` (Generate miss), RED is the fake `type=int` dump, **not** Build==0. Do not weaken to `Build()==0`.

### Task 4: Minimal F4 implementation

- [ ] **Step 3: Implement**

`ResolveCallee` member branch after `FindBestCallee`:

```cpp
				const asASTDeclId method = FindBestCallee(context, typeDecl, name, withoutReceiver, &sema);
				if( method.IsValid() )
				{
					return method;
				}
				return asASTDeclId();
```

Delete the `for` over `cls->children` name+count. Do not fall through to `FindBestCallee(searchOwner, …)`.

`ActOnCallExpr` after `ResolveCallee` / `ConstructFromCallee`, **before** the int default:

```cpp
	if( !callee.IsValid() )
	{
		asCString msg = "unresolved-callee:";
		if( name && name[0] )
		{
			msg += name;
		}
		AddDiagnostic(msg.AddressOf());
		const asCQualType errorType = context.InternNamedType(asAST_TYPE_ERROR, "<unresolved>", 0);
		const asASTExprId call = ActOnCall(asASTDeclId(), args, errorType, range);
		if( name && name[0] )
		{
			context.SetLiteral(call, name);
		}
		return call;
	}
```

Leave the conversion loop and `ActOnCall(callee, …)` for **valid** callees. Do not default `InternPrimitive(ttInt)` on miss.

`ActOnDeclRefExpr` after the hit scan:

```cpp
	if( !target.IsValid() )
	{
		asCString msg = "unresolved-identifier:";
		if( name && name[0] )
		{
			msg += name;
		}
		AddDiagnostic(msg.AddressOf());
		const asCQualType errorType = context.InternNamedType(asAST_TYPE_ERROR, "<unresolved>", 0);
		const asASTExprId ref = ActOnDeclRef(asASTDeclId(), errorType, range);
		if( name && name[0] )
		{
			context.SetLiteral(ref, name);
		}
		return ref;
	}
	asCQualType type = context.InternPrimitive(ttInt, 0);
	if( const asCDecl* decl = context.GetDecl(target) )
	{
		if( decl->type.IsValid() )
		{
			type = decl->type;
		}
	}
	const asASTExprId ref = ActOnDeclRef(target, type, range);
	...
```

Do **not** add `if( !expr->resolvedDecl.IsValid() ) fail` to `asCASTVerify`. Do not change `AmbiguousOverloadIsRejectedNotFirstName`’s `Seal()==0`.

`ActOnCall` with invalid callee currently sets literal `"call:reverse-formal"` then we overwrite with `SetLiteral(name)`. Dump `callee=` stays empty because `resolvedDecl` is invalid — that is the “not a fake success” lock.

- [ ] **Step 4: Build, then GREEN (SemaAuthority then CanonicalAST; Frontend verifier)**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-eighth-f4 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-eighth-f4-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-eighth-f4-canonical -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-eighth-f4-frontend -TimeoutMs 600000
```

Expected: SemaAuthority live+5; CanonicalAST includes them; Frontend CanonicalAST live (Verifier `RejectsUnsealedPublication` still PASS). `AmbiguousOverloadIsRejectedNotFirstName` still Seal==0 with no `callee=F(int,float)`.

Never All.

- [ ] **Step 5: Record, do not commit**

Append `## B-eighth-f4-fail-closed` to `attachments/wave-b-results.md`. Patch `eighth-pass-verified.md` F4 row. Leave 13.2 / 4.2 / 5.4 / 5.6 / 9.5 `[ ]`.

---

## What GREEN is not

| Not this | Why |
| --- | --- |
| **13.2** Sema authority close | Parser still builds `asCScriptNode`; LEGACY still `asCCompiler`; F2 identity is a different slice |
| **4.2** | `ActOnQualType` script class names may still intern VALUE_OBJECT; not retconned here |
| **5.4** Generate / OpaqueValue / 1070 | eval-once is a different UBT; this map does not execute `Make().Get()` traces |
| **5.6** | control oracles already dumped; not this |
| **9.5 / F6** | no ABI matrix, no atomic install, no handle AddRef |
| **F9** CALL-callee on unsealed `asCASTVerify` | forbidden; publication gate stays `asCASTVerifyPublication` + Sema diagnostics on `SealCanonicalAST` |
| Default CANONICAL / CANONICAL `CompileFunction` | stay LEGACY / mixed COMPILER |
| Wave E–G / archive | forbidden now |

F3 GREEN is: class `C()` Construct `REFERENCE_OBJECT`+handle, struct `S()` `VALUE_OBJECT`, intern reuse when the ref type already exists, dump `typeKind=`.

F4 GREEN is: no same-arity-first bind, no free-function steal after member miss, `Missing()` / `Missing` dump `type=<unresolved> typeKind=Error` + diagnostic, Build does not publish a fake int success, unsealed `asCASTVerify` still OK without callee.

---

## Self-review

- Eighth-pass F3/F4 sentences each have a task (QualTypeFromClassDecl; delete fallback; ERROR type; diagnostics; tests listed in the review matrix).
- No TBD. Exact file:line, exact tokens, exact `RunBuild`/`RunTests` from `D:\as-cta` with `-NoXGE`.
- Unresolved type is `asAST_TYPE_ERROR` `"<unresolved>"` on CALL/DECL_REF — not `int`, not `asAST_EXPR_ERROR` node kind, not a verifier callee firewall.
- F3 vs F4 remain two exclusive UBTs because F4 can be rejected without reverting F3, and they must not run in parallel on `as_sema_expr.cpp`.
