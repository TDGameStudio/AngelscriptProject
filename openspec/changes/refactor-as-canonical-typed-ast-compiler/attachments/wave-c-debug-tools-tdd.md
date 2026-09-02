# Wave C debug tools — first printer TDD (`asCASTFormatVerifyResult`)

> **For later exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Write the failing Dump tests first. RunBuild then the Dump prefix **before** filling `as_ast_dump.cpp`. Do **not** check `tasks.md`. C-28 / 2.8 / 13.5 are already closed.

**Goal:** Land an address-free observer formatter for `asSAstVerifyResult` plus dump-on-verify-fail, locked on the existing Frontend CanonicalAST Dump prefix.

**Architecture:** Formatter lives in `as_ast_dump.*` only. It reads `{category, range, detail}` and optionally appends the existing `asCASTDump` text. It does not change verifier behavior, sidecar bytes, Cache, Provider, or `asCASTDump` grammar.

**Tech Stack:** Maintained AngelScript fork (`asCString`, `asCASTContext`, `asSAstVerifyResult`). CQTest Dump prefix. No Unreal types in fork files. No Clang/LLVM.

## Header (this attachment)

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **C-debug-tdd** (`attachments/async-work.md` §9) |
| Mode now | **LANDED 2026-08-21.** Dump prefix **6/6**. Observer formatter only. Did not mark `tasks.md`. |
| Mode later | Do not redo. Do not start D Task 6. |
| UBT mutex | **Queued after Wave B control-body and D-r09-2-7.** One UBT user in `D:\as-cta`. Must not share files with `as_sema*` or `as_bytecode_codegen*` writers. If this worktree's `UnrealBuildTool` is live, wait. CAEngine `UE4Editor` is not this mutex. `-NoXGE`. |

`attachments/wave-c-debug-tools.md` is **stale** where it says `asCASTVerifyPublication` was not landed. The formatter grammar, dump-on-fail companion, observer rules, and Clang-as-reference-only notes in that inventory are still the intended first tool. This file is the executable TDD plan.

---

## Global constraints

- TDD. Dump tests only. Prefix `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump`.
- Fork files: no Unreal types, no `FString` / `TCHAR` / `TEXT`. Tests may use those.
- Clang `Stmt::dump` / `dumpColor` / `TextNodeDumper` is a **design reference only**. Do not link Clang/LLVM, copy Clang headers, print `0x` pointers, or ship colored dumps.
- Dumps stay observers. Never a Cache / Provider / sidecar `contentHash` / ExactStartup input. Do not edit `as_ast_sidecar.cpp`.
- Do **not** edit `as_ast_verifier.h` or `as_ast_verifier.cpp` in this package. Formatter lives in dump.
- `asCASTVerify` must still succeed on unsealed graphs (`Seal()` calls it before `sealed = true`). Publication helper already fails unsealed. Do not change that.
- **Hard no:** CALL-without-callee as a seal / dump / verifier firewall.
- Do not change `asCASTDump` line grammar. `RepeatedBuildsDumpIdenticallyWithoutPointers` must stay PASS.
- Do not edit `as_sema*`, `as_bytecode_codegen*`, or `Core/angelscript.h`.
- Do not run `All`. Do not claim 2.8 / 13.5 (already closed). This package does not close any remaining `tasks.md` box.
- Do not commit. Do not archive.

---

## C-28 publication helper — already landed (do not re-implement)

`asCASTVerifyPublication` **exists**. Tasks 2.8 / 13.5 are closed.

Header `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.h`:

```cpp
struct asSAstVerifyResult
{
	asEASTVerifyCategory category;
	asCSourceRange range;
	asCString detail;

	asSAstVerifyResult() : category(asAST_VERIFY_OK) {}
};

ANGELSCRIPTRUNTIME_API int asCASTVerify(const asCASTContext& context, asSAstVerifyResult& result);
ANGELSCRIPTRUNTIME_API int asCASTVerifyPublication(const asCASTContext& context, asSAstVerifyResult& result);
```

Implementation `as_ast_verifier.cpp` (do not touch):

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

`FCanonicalASTVerifierTests::RejectsUnsealedPublication` already locks: `asCASTVerify` OK on an unsealed construction graph; `asCASTVerifyPublication` returns `asAST_VERIFY_UNSEALED_PUBLICATION` with detail `unsealed-publication`; the same graph then `Seal()`s; publication of the sealed graph is OK.

Formatter tests **hand-build** `asSAstVerifyResult`. They must not call `asCASTVerify` / `asCASTVerifyPublication` to obtain tokens.

---

## File map

| Path | This exclusive slice |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.h` | **Modify.** Declare both APIs. `#include "as_ast_verifier.h"`. No Unreal types. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | **Modify.** File-static `VerifyCategoryName`. Implement both APIs. Do **not** change `asCASTDump` / `asCASTShadowDiff`. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTDumpTests.cpp` | **Modify.** Add the five TEST_METHODs below. Keep `RepeatedBuildsDumpIdenticallyWithoutPointers`. Include `source/as_ast_verifier.h`. |

**Do not touch**

| Path | Why |
| --- | --- |
| `as_ast_verifier.h` / `as_ast_verifier.cpp` | C-28 closed. Formatter is not a verifier change. |
| `as_ast_sidecar.cpp` / `as_ast_sidecar.h` | Wave F. Dump text must not become a Cache input. |
| `as_sema*` | Wave B exclusive writers. |
| `as_bytecode_codegen*` | Wave D exclusive writers. |
| `as_ast_context.cpp` (`Seal`) | Seal still returns `int` only. No diagnostic wiring in this slice. |
| `Core/angelscript.h` | Public engine header out of scope. |
| `AngelscriptNativeCanonicalASTVerifierTests.cpp` | C-28 owns Verifier prefix. |
| `tasks.md` | Observer tool. No box to check. |

`as_ast_dump.h` may include the verifier header. The verifier must **not** include dump.

---

## APIs (fork, no Unreal types)

Add to `as_ast_dump.h` after the existing `asCASTDump` / `asCASTShadowDiff` declarations:

```cpp
ANGELSCRIPTRUNTIME_API void asCASTFormatVerifyResult(const asSAstVerifyResult& result, asCString& out);
ANGELSCRIPTRUNTIME_API void asCASTDumpOnVerifyFail(const asCASTContext& context, const asSAstVerifyResult& result, asCString& out);
```

Full header after the edit:

```cpp
#ifndef AS_AST_DUMP_H
#define AS_AST_DUMP_H

#include "as_ast_context.h"
#include "as_ast_verifier.h"
#include "as_string.h"

BEGIN_AS_NAMESPACE

ANGELSCRIPTRUNTIME_API void asCASTDump(const asCASTContext& context, asCString& out);
ANGELSCRIPTRUNTIME_API void asCASTShadowDiff(const asCASTContext& left, const asCASTContext& right, asCString& out);
ANGELSCRIPTRUNTIME_API void asCASTFormatVerifyResult(const asSAstVerifyResult& result, asCString& out);
ANGELSCRIPTRUNTIME_API void asCASTDumpOnVerifyFail(const asCASTContext& context, const asSAstVerifyResult& result, asCString& out);

END_AS_NAMESPACE

#endif
```

### Grammar (address-free, one line, trailing newline)

```text
VERIFY category=<TOKEN> detail=<token> range=<fileID>:<begin>-<fileID>:<end>\n
```

Exact examples:

```text
VERIFY category=OK detail= range=0:0-0:0
VERIFY category=UNSEALED_PUBLICATION detail=unsealed-publication range=0:0-0:0
VERIFY category=DANGLING_ID detail=expr-id range=1:4-1:8
VERIFY category=UNKNOWN detail= range=0:0-0:0
```

Rules:

- `<TOKEN>` is the `asEASTVerifyCategory` enumerator **without** the `asAST_VERIFY_` prefix.
- Empty `detail` → `detail=` (nothing between `=` and the following space).
- `result.range.IsValid()` true → print the four numbers as `%u`.
- `result.range.IsValid()` false (default ctor, `fileID==0`, cross-file, inverted offsets) → `range=0:0-0:0`. Do **not** print the raw invalid fields.
- `asCASTFormatVerifyResult` **replaces** `out` (use `asCString::Format`). It does not append.
- Never `0x`. Never a pointer. Never ANSI color. Never a second line.

### `VerifyCategoryName` (file-static in `as_ast_dump.cpp`, not exported)

Cover **every** enumerator currently in `as_ast_kind.h` (`asEASTVerifyCategory`, lines 99–110). Unknown byte → `UNKNOWN`. Include `UNSEALED_PUBLICATION`.

| Enumerator | Token |
| --- | --- |
| `asAST_VERIFY_OK` | `OK` |
| `asAST_VERIFY_DANGLING_ID` | `DANGLING_ID` |
| `asAST_VERIFY_FOREIGN_ID` | `FOREIGN_ID` |
| `asAST_VERIFY_WRONG_KIND` | `WRONG_KIND` |
| `asAST_VERIFY_INVALID_TYPE` | `INVALID_TYPE` |
| `asAST_VERIFY_INVALID_RANGE` | `INVALID_RANGE` |
| `asAST_VERIFY_INVALID_CHILD` | `INVALID_CHILD` |
| `asAST_VERIFY_POST_SEAL_MUTATION` | `POST_SEAL_MUTATION` |
| `asAST_VERIFY_UNSEALED_PUBLICATION` | `UNSEALED_PUBLICATION` |
| any other `asBYTE` (tests use `255`) | `UNKNOWN` |

There is no `asAST_VERIFY_UNKNOWN` enumerator. `UNKNOWN` is only the fallback token.

### `asCASTDumpOnVerifyFail`

1. Call `asCASTFormatVerifyResult(result, out)` first (replaces `out` with the VERIFY line).
2. If `result.category == asAST_VERIFY_OK`, return. Do **not** call `asCASTDump`.
3. Else format dump into a **local** `asCString`, then `out += dump`. Never pass `out` into `asCASTDump` — that would wipe the VERIFY line (`asCASTDump` starts with `out = "AST\n"`).

OK → formatter line only (no `AST\n` header, no `DECL`).
Fail → formatter line, then the existing dump (`\nAST\n` appears).

---

## Out of scope this slice

These are later dump-grammar growth for Wave B / a later debug slice, **not** this formatter:

- Printing value category (`vc=prvalue|lvalue|xvalue`)
- EXPR type `stableKey` / `typeKey=`
- `receiver=`
- STMT children / owner / expr / decl lists
- ShadowDiff expansion
- `Seal()` diagnostic sink
- TYPE table / public `GetTypeCount()`
- Colored dumps, debugger UI, DAP
- Cleanup-plan POD fields
- Production `Build()` / Ready / default CANONICAL

---

## Current Dump test file (keep this method)

`AngelscriptNativeCanonicalASTDumpTests.cpp` today has **one** method, prefix already correct:

```text
Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump
```

Keep `RepeatedBuildsDumpIdenticallyWithoutPointers` unchanged. After green the prefix is **6/6** (1 existing + 5 new).

Add `#include "source/as_ast_verifier.h"` inside the `StartAngelscriptHeaders` block so `asSAstVerifyResult` is visible even if a future dump header shuffle drops the include:

```cpp
#include "StartAngelscriptHeaders.h"
#include "source/as_ast_context.h"
#include "source/as_ast_dump.h"
#include "source/as_ast_verifier.h"
#include "EndAngelscriptHeaders.h"
```

---

## Task 1: RED — declarations, stubs, failing tests

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.h` (declarations + verifier include)
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` (empty stubs only)
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTDumpTests.cpp`

**Interfaces:**
- Consumes: `asSAstVerifyResult`, `asCASTContext`, `asCASTDump`, `asCSourceLocation` / `asCSourceRange::IsValid`
- Produces: declared `asCASTFormatVerifyResult` / `asCASTDumpOnVerifyFail` that currently write `out = ""`

- [ ] **Step 1: Add declarations to `as_ast_dump.h`**

Use the full header in **APIs** above.

- [ ] **Step 2: Add linking stubs in `as_ast_dump.cpp` (no grammar yet)**

Append **after** `asCASTShadowDiff`, still inside `BEGIN_AS_NAMESPACE`. Do not implement `VerifyCategoryName` yet. Stubs exist so the test binary links and the new methods **run and fail assertions**.

```cpp
void asCASTFormatVerifyResult(const asSAstVerifyResult& result, asCString& out)
{
	(void)result;
	out = "";
}

void asCASTDumpOnVerifyFail(const asCASTContext& context, const asSAstVerifyResult& result, asCString& out)
{
	(void)context;
	(void)result;
	out = "";
}
```

- [ ] **Step 3: Add the five failing TEST_METHODs inside `FCanonicalASTDumpTests`**

Paste these methods **after** `RepeatedBuildsDumpIdenticallyWithoutPointers` and **before** the class closing `};`. Match the file’s tab indentation.

```cpp
	TEST_METHOD(FormatVerifyResultOkIsAddressFreeAndStable)
	{
		asSAstVerifyResult Result;
		asCString Text;
		Text = "junk";
		asCASTFormatVerifyResult(Result, Text);
		const FString Line = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
		ASSERT_THAT(IsTrue(Line.Equals(TEXT("VERIFY category=OK detail= range=0:0-0:0\n")),
			TEXT("OK default result must be one address-free VERIFY line with empty detail and zero range")));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("0x")), TEXT("formatter must not spell pointers")));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("junk")), TEXT("formatter must replace out, not append")));

		Result.range.begin = asCSourceLocation(1, 0);
		Result.range.end = asCSourceLocation(2, 4);
		asCASTFormatVerifyResult(Result, Text);
		const FString Invalid = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
		ASSERT_THAT(IsTrue(Invalid.Equals(TEXT("VERIFY category=OK detail= range=0:0-0:0\n")),
			TEXT("invalid range must print range=0:0-0:0, not the raw fields")));
	}

	TEST_METHOD(FormatVerifyResultUnsealedPublication)
	{
		asSAstVerifyResult Result;
		Result.category = asAST_VERIFY_UNSEALED_PUBLICATION;
		Result.detail = "unsealed-publication";
		asCString Text;
		asCASTFormatVerifyResult(Result, Text);
		const FString Line = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
		ASSERT_THAT(IsTrue(Line.Equals(TEXT("VERIFY category=UNSEALED_PUBLICATION detail=unsealed-publication range=0:0-0:0\n")),
			TEXT("UNSEALED_PUBLICATION token must drop the asAST_VERIFY_ prefix")));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("0x")), TEXT("formatter must not spell pointers")));
	}

	TEST_METHOD(FormatVerifyResultDanglingIdWithDetailAndRange)
	{
		asSAstVerifyResult Result;
		Result.category = asAST_VERIFY_DANGLING_ID;
		Result.detail = "expr-id";
		Result.range.begin = asCSourceLocation(1, 4);
		Result.range.end = asCSourceLocation(1, 8);
		asCString Text;
		asCASTFormatVerifyResult(Result, Text);
		const FString Line = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
		ASSERT_THAT(IsTrue(Line.Equals(TEXT("VERIFY category=DANGLING_ID detail=expr-id range=1:4-1:8\n")),
			TEXT("DANGLING_ID must print detail token and valid fileID:offset range")));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("0x")), TEXT("formatter must not spell pointers")));
	}

	TEST_METHOD(FormatVerifyResultCategoryTokensCoverEveryEnumerator)
	{
		struct FCategoryToken
		{
			asEASTVerifyCategory Category;
			const TCHAR* Expected;
		};
		const FCategoryToken Rows[] = {
			{ asAST_VERIFY_OK, TEXT("VERIFY category=OK detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_DANGLING_ID, TEXT("VERIFY category=DANGLING_ID detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_FOREIGN_ID, TEXT("VERIFY category=FOREIGN_ID detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_WRONG_KIND, TEXT("VERIFY category=WRONG_KIND detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_INVALID_TYPE, TEXT("VERIFY category=INVALID_TYPE detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_INVALID_RANGE, TEXT("VERIFY category=INVALID_RANGE detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_INVALID_CHILD, TEXT("VERIFY category=INVALID_CHILD detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_POST_SEAL_MUTATION, TEXT("VERIFY category=POST_SEAL_MUTATION detail= range=0:0-0:0\n") },
			{ asAST_VERIFY_UNSEALED_PUBLICATION, TEXT("VERIFY category=UNSEALED_PUBLICATION detail= range=0:0-0:0\n") },
		};
		for (const FCategoryToken& Row : Rows)
		{
			asSAstVerifyResult Result;
			Result.category = Row.Category;
			asCString Text;
			asCASTFormatVerifyResult(Result, Text);
			const FString Line = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
			ASSERT_THAT(IsTrue(Line.Equals(Row.Expected),
				TEXT("VerifyCategoryName must cover every asEASTVerifyCategory enumerator")));
			ASSERT_THAT(IsTrue(!Line.Contains(TEXT("0x")), TEXT("category tokens must stay address-free")));
		}

		asSAstVerifyResult Unknown;
		Unknown.category = static_cast<asEASTVerifyCategory>(255);
		asCString UnknownText;
		asCASTFormatVerifyResult(Unknown, UnknownText);
		const FString UnknownLine = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(UnknownText);
		ASSERT_THAT(IsTrue(UnknownLine.Equals(TEXT("VERIFY category=UNKNOWN detail= range=0:0-0:0\n")),
			TEXT("unknown asEASTVerifyCategory byte must print UNKNOWN, not a pointer or integer dump")));
	}

	TEST_METHOD(DumpOnVerifyFailIncludesAstHeaderOnlyOnFailure)
	{
		auto BuildSample = [](asCASTContext& Context) -> int
		{
			const asASTDeclId Tu = Context.CreateTranslationUnit("DumpMod");
			const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
			const asASTDeclId Fn = Context.CreateDecl(asAST_DECL_FUNCTION, Tu, asCSourceRange(), "F");
			Context.SetDeclType(Fn, IntType);
			const asASTStmtId Body = Context.CreateStmt(asAST_STMT_RETURN, Fn, asCSourceRange());
			Context.SetBody(Fn, Body);
			const asASTExprId Lit = Context.CreateExpr(asAST_EXPR_INTEGER_LITERAL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
			Context.SetLiteral(Lit, "7");
			Context.SetStmtExpr(Body, Lit);
			return Context.Seal();
		};

		asCASTContext Sealed;
		ASSERT_THAT(AreEqual(0, BuildSample(Sealed), TEXT("sealed DumpMod sample must verify and seal")));

		asSAstVerifyResult Ok;
		asCString OkText;
		OkText = "junk";
		asCASTDumpOnVerifyFail(Sealed, Ok, OkText);
		const FString OkLine = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(OkText);
		ASSERT_THAT(IsTrue(OkLine.Equals(TEXT("VERIFY category=OK detail= range=0:0-0:0\n")),
			TEXT("OK dump-on-fail must be the formatter line only")));
		ASSERT_THAT(IsTrue(!OkLine.Contains(TEXT("AST\n")), TEXT("OK path must not append the AST dump header")));
		ASSERT_THAT(IsTrue(!OkLine.Contains(TEXT("DECL")), TEXT("OK path must not contain DECL lines")));
		ASSERT_THAT(IsTrue(!OkLine.Contains(TEXT("0x")), TEXT("OK dump-on-fail must not spell pointers")));

		asSAstVerifyResult Fail;
		Fail.category = asAST_VERIFY_DANGLING_ID;
		Fail.detail = "translation-unit";
		asCString FailText;
		asCASTDumpOnVerifyFail(Sealed, Fail, FailText);
		const FString Combined = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(FailText);
		ASSERT_THAT(IsTrue(Combined.StartsWith(TEXT("VERIFY category=DANGLING_ID detail=translation-unit range=0:0-0:0\n")),
			TEXT("fail path must lead with the formatter line")));
		ASSERT_THAT(IsTrue(Combined.Contains(TEXT("\nAST\n")), TEXT("fail path must append asCASTDump, which starts with AST\\n")));
		ASSERT_THAT(IsTrue(Combined.Contains(TEXT("DECL id=2 kind=Function name=F")),
			TEXT("fail path dump must be the context dump, not an empty string")));
		ASSERT_THAT(IsTrue(!Combined.Contains(TEXT("0x")), TEXT("combined dump must stay address-free")));
	}
```

Hand-built results only. Do not call `asCASTVerify` / `asCASTVerifyPublication` in these methods.

---

## Task 2: RED — build and Dump prefix

**Files:** none (run only).

- [ ] **Step 1: Confirm exclusive UBT is free**

If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are live, **stop**. This slice is queued after Wave B dump remainder and must not start a second build.

- [ ] **Step 2: Build**

From `D:\as-cta`:

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-debug-format-red -TimeoutMs 1800000 -NoXGE
```

Expected: build succeeds (stubs link). If the test file was added without the header declarations, the compiler fails on missing `asCASTFormatVerifyResult` / `asCASTDumpOnVerifyFail` — that is also RED; add the declarations and stubs, then rebuild.

- [ ] **Step 3: Run Dump prefix**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump" -Label wave-c-debug-format-red -TimeoutMs 600000
```

Expected:

| Method | RED result |
| --- | --- |
| `RepeatedBuildsDumpIdenticallyWithoutPointers` | **PASS** (dump grammar unchanged) |
| `FormatVerifyResultOkIsAddressFreeAndStable` | **FAIL** — empty `out` is not `VERIFY category=OK detail= range=0:0-0:0\n` |
| `FormatVerifyResultUnsealedPublication` | **FAIL** — missing `UNSEALED_PUBLICATION` line |
| `FormatVerifyResultDanglingIdWithDetailAndRange` | **FAIL** — missing `detail=expr-id range=1:4-1:8` |
| `FormatVerifyResultCategoryTokensCoverEveryEnumerator` | **FAIL** — first enumerator line mismatch |
| `FormatVerifyResult` unknown / dump-on-fail | **FAIL** — empty `out`; fail path has no `\nAST\n` |

Do not “fix” tests to match the stubs. Do not run `All`.

---

## Task 3: GREEN — implement formatter + dump-on-fail

**Files:**
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` only (replace stubs)

**Interfaces:**
- Consumes: Task 1 declarations and failing tests
- Produces: grammar-accurate `asCASTFormatVerifyResult` / `asCASTDumpOnVerifyFail`

- [ ] **Step 1: Replace stubs with `VerifyCategoryName` + both APIs**

Keep `asCASTDump` / `asCASTShadowDiff` byte-identical. Match dump.cpp style (`switch( kind )`, tabs, `if( `).

```cpp
static const char* VerifyCategoryName(asEASTVerifyCategory category)
{
	switch( category )
	{
	case asAST_VERIFY_OK: return "OK";
	case asAST_VERIFY_DANGLING_ID: return "DANGLING_ID";
	case asAST_VERIFY_FOREIGN_ID: return "FOREIGN_ID";
	case asAST_VERIFY_WRONG_KIND: return "WRONG_KIND";
	case asAST_VERIFY_INVALID_TYPE: return "INVALID_TYPE";
	case asAST_VERIFY_INVALID_RANGE: return "INVALID_RANGE";
	case asAST_VERIFY_INVALID_CHILD: return "INVALID_CHILD";
	case asAST_VERIFY_POST_SEAL_MUTATION: return "POST_SEAL_MUTATION";
	case asAST_VERIFY_UNSEALED_PUBLICATION: return "UNSEALED_PUBLICATION";
	default: return "UNKNOWN";
	}
}

void asCASTFormatVerifyResult(const asSAstVerifyResult& result, asCString& out)
{
	const char* category = VerifyCategoryName(result.category);
	const char* detail = result.detail.AddressOf() ? result.detail.AddressOf() : "";
	asUINT beginFile = 0;
	asUINT beginOffset = 0;
	asUINT endFile = 0;
	asUINT endOffset = 0;
	if( result.range.IsValid() )
	{
		beginFile = result.range.begin.fileID;
		beginOffset = result.range.begin.offset;
		endFile = result.range.end.fileID;
		endOffset = result.range.end.offset;
	}
	out.Format("VERIFY category=%s detail=%s range=%u:%u-%u:%u\n",
		category,
		detail,
		beginFile,
		beginOffset,
		endFile,
		endOffset);
}

void asCASTDumpOnVerifyFail(const asCASTContext& context, const asSAstVerifyResult& result, asCString& out)
{
	asCASTFormatVerifyResult(result, out);
	if( result.category == asAST_VERIFY_OK )
	{
		return;
	}
	asCString dump;
	asCASTDump(context, dump);
	out += dump;
}
```

`asCString` empty `AddressOf()` returns the local buffer (`""`), not null. The ternary is still required if a future `asCString` change returns null. Empty detail still prints `detail=`.

- [ ] **Step 2: Build green**

From `D:\as-cta`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-debug-format-green -TimeoutMs 1800000 -NoXGE
```

Expected: build succeeds.

- [ ] **Step 3: Dump prefix green**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump" -Label wave-c-debug-format-green -TimeoutMs 600000
```

Expected: Dump prefix **6/6 PASS**.

| Method | GREEN lock |
| --- | --- |
| `RepeatedBuildsDumpIdenticallyWithoutPointers` | existing dump identity, no `0x`, `DECL id=2 kind=Function name=F` |
| `FormatVerifyResultOkIsAddressFreeAndStable` | OK line + invalid range coerced to zeros |
| `FormatVerifyResultUnsealedPublication` | `UNSEALED_PUBLICATION` + `unsealed-publication` |
| `FormatVerifyResultDanglingIdWithDetailAndRange` | `DANGLING_ID` + `expr-id` + `1:4-1:8` |
| `FormatVerifyResultCategoryTokensCoverEveryEnumerator` | all nine enumerators + `255` → `UNKNOWN` |
| `DumpOnVerifyFailIncludesAstHeaderOnlyOnFailure` | OK has no `AST\n`; fail has `\nAST\n` and the DumpMod `DECL` line |

Do **not** run `All`. Do **not** run Verifier / SemaAuthority / CodeGen / Cache as a close gate. Do **not** mark 2.8 / 13.5 / 13.2 / 5.9.

Optional later (not this package): Frontend CanonicalAST regression only if someone accidentally edited `asCASTDump`. This plan does not edit dump text, so Dump prefix is the gate.

---

## Observer / Cache rules (do not “fix” in this package)

Already true; leave them:

- `asCASTRejectNonSidecarInput` treats leading `AST\n` as `asAST_SIDECAR_UNSUPPORTED_INPUT`.
- Cache `OldSchemaDumpAndHirInputsAreSafeMisses` and HotReload snapshot tests lock that.
- `asCASTEncodeSidecar` currently **embeds** `asCASTDump` text. Decode ignores it. That is Wave F debt. A new VERIFY line is a **separate API**, so sidecar bytes do not churn.

This package must:

- Not feed formatter output into Cache DTO, Provider, `contentHash`, or ExactStartup.
- Not make `asCASTDecodeSidecar` parse dump or VERIFY text.
- Not edit `as_ast_sidecar.cpp`.

---

## Close criteria (later exclusive UBT, not this attachment)

May land C-debug-impl when:

- `asCASTFormatVerifyResult` matches the grammar; no `0x`; no UE types in dump.cpp
- `asCASTDumpOnVerifyFail` prefixes that line and appends `asCASTDump` **only** on non-OK
- `VerifyCategoryName` covers every current `asEASTVerifyCategory` enumerator including `UNSEALED_PUBLICATION`; unknown → `UNKNOWN`
- Dump prefix 6/6; `RepeatedBuildsDumpIdenticallyWithoutPointers` still PASS
- `as_ast_verifier.cpp` / `as_ast_sidecar.cpp` / `as_sema*` / `as_bytecode_codegen*` untouched in the slice
- No CALL-without-callee; no cleanup-plan POD; no colored dump; no Cache/Provider input path
- `asCASTVerify` still OK on unsealed graphs; publication helper still fails unsealed (pre-existing, not retested as a Dump gate)
- No `tasks.md` box checked

---

## What this attachment did **not** do (2026-08-21)

- Did not edit fork / test sources.
- Did not run `RunBuild` / `RunTests` / UBT.
- Did not mark `tasks.md`.
- Did not commit or archive.
- Did not re-open C-28.

Implementation waits for exclusive UBT after Wave B dump remainder, Dump prefix only.
