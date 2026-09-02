# Wave B next Parser Sema actions (B-parser-expr)

> **For later exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild.ps1 -NoXGE` then the SemaAuthority prefix **before** filling `as_parser.cpp` / `as_sema*`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2 / 5.3.

**Goal:** Exact TDD map for the exclusive-UBT Wave B slice **after** lambda. Intern a Call plan during parse so an incomplete argument list still records callee / nargs / reverse-formal children. This is the smallest Clang-shaped **expression** action (Parser reduces a call and Sema acts; it does not wait for `WalkOne` of a complete function body). This is **not** 13.2 close and **not** production `Build()` routing.

**Prerequisite (do not redo; do not start this UBT slice until green):**

| TEST_METHOD | File |
| --- | --- |
| `ParserActOnLambdaDeclBeforeBodyParseFails` | `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| `ParserActOnLambdaDoesNotDuplicateOnSuccessfulParse` | same |

If those two are still red, finish **B-parser-lambda** first (`attachments/wave-b-parser-lambda.md`).

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode
  → incremental NotifySema / ActOn for declarations (including lambda after that slice)
  → expression / call / lifetime still ActOnExprFromNode of a complete parser node
        during ActOnStmtFromNode of the finished function body
  → asCBuilder / asCCompiler
  → isolated asCBytecodeCodeGen::Generate()
```

LLVM/Clang is a **shape reference only**. Clang Parser calls `Sema::ActOnCallExpr` when the postfix call reduces, not after the enclosing function body is finished. Copy that **shape**, not Clang source.

Already true (reuse):

- `ParseFunction` ActOn + `asSDeclContextScope` so `CurrentDeclContext()` inside `Entry` is `Entry`
- `ActOnCall` / `FindBestCallee` / `LookupCandidatesFrom` / reverse-formal store / default / named args
- Dump already prints Call `callee=` `nargs=` `args=` `receiver=` `route=`
- `NotifySema` is **declaration** `ActOnParsedDeclaration` / `WalkOne`. It must **not** be used for calls (WalkOne of `snFunctionCall` is not a decl case; it would no-op or mis-parent)

---

## Header (this attachment)

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-parser-expr** (`attachments/async-work.md` §6) |
| Mode now | **Attachment only.** Do not edit fork sources. Do not run UBT. Do not mark `tasks.md`. |
| Mode later | Exclusive UBT **after B-parser-lambda**. **Do not mark 13.2.** |
| UBT mutex | One UBT user in `D:\as-cta`. Do not share `as_parser.cpp` / `as_sema*` with a CodeGen writer. `-NoXGE`. |
| Order | incomplete call → duplicate-on-success → then stop. Do not start assignment / conversion / lifetime in this slice. |

虚标 = checking 13.2 because Parser called `ActOnExprFromNode` once. Criterion (4) is still false (`asCCompiler`). Leave 13.2 `[ ]`.

---

## Global constraints

- Same fork dialect as `wave-b-parser-lambda.md`. No script `funcdef` / `@` / `is`.
- TDD. SemaAuthority first, then Compiler CanonicalAST. Never All. Never production `Build()`. Never Ready()/CANONICAL.
- **Hard no:** CALL-without-callee as a seal/verifier firewall. Empty `callee=` on an **incomplete** call is allowed until Sema binds; a **successful** bind must not be first-name. Do not make missing callee fail `Seal()` / `asCASTVerify`.
- Dump printer not required.
- Implementer files: `as_parser.cpp` (`ParseFunctionCall` / `ParseArgList`), `as_sema.h` / `as_sema.cpp` (optional `ActOnParsedExpr` / last-acted expr), `as_sema_expr.cpp` (reuse Call by range+name so WalkOne does not duplicate). Do not edit `as_compiler.cpp`, `as_module.cpp` `Build()`, `as_ast_verifier.cpp`, `as_bytecode_codegen.cpp`.
- After green, **13.2 / 5.3 / 5.9 stay `[ ]`**.

---

## Why this is the smallest expression action

Decl ActOn is landed except fork-rejected `funcdef`. 13.2 remaining identity is:

```text
expression / call / lifetime still ActOnExprFromNode / ActOnStmtFromNode
  of asCScriptNode after the enclosing body exists
```

Do **not** rewrite every `ParseAssignment` / `ParseCondition` in one slice.

Pick **one** form: ordinary call `F(1, 2)`.

Clang shape for this slice:

1. Parser still builds `snFunctionCall` + `snArgList` (recovery).
2. After each parsed argument is attached — and when `ParseArgList` returns because `)` is missing — Parser calls Sema **on that call node** with `CurrentDeclContext()` as owner (`Entry`), not `WalkOne` of the finished `Entry` body.
3. Sema `ActOnExprFromNode(snFunctionCall)` already knows how to resolve `F`, intern args, reverse-formal store, `ActOnCall`.
4. `asCScriptNode` remains recovery.

`NotifySema` is the wrong hook (`ActOnParsedDeclaration`). Add a Parser-local call:

```cpp
if( sema )
{
	sema->ActOnExprFromNode(callNode, script, /*file*/, sema->CurrentDeclContext());
}
```

FileID: follow `ActOnParsedDeclaration` (it already maps `script` to a file). Prefer a small `asCSema::ActOnParsedExpr(asCScriptNode*, asCScriptCode*)` that looks up the file the same way as `ActOnParsedDeclaration`, so Parser does not invent FileIDs.

`ParseArgList` today (`as_parser.cpp` ~1844–1950): after the second argument `2`, the next token is not `)` or `,` → `Error(ExpectedTokens(")", ","))` → `return node` **with two children already on `snArgList`**. Incremental ActOn can therefore see `nargs=2` on the incomplete source.

Do not ActOn only after a successful `)`. That would make the incomplete test stay red forever and is not Clang-shaped.

---

## Exclusive-UBT order (TDD)

Add both methods after the lambda methods. `RunBuild.ps1 -NoXGE` from `D:\as-cta`. SemaAuthority RED → implement → SemaAuthority GREEN → CanonicalAST.

```text
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-parser-expr -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-expr-red -TimeoutMs 600000
```

After green, same prefix with label `wave-b-parser-expr-green`, then Compiler CanonicalAST `wave-b-parser-expr-canonical`. Never All.

Expected first RED: two new methods fail (incomplete dump has `key=F(int,int)` / `key=Entry()` and **no** Call `callee=F(int,int)`). Duplicate-on-success may already pass via complete WalkOne — keep it as the guard.

---

### 1. `ParserActOnCallExprBeforeArgListCloseFails`

| Field | Value |
| --- | --- |
| File | `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int F(int a, int b)
	{
		return a;
	}

	int Entry()
	{
		return F(1, 2
	)AS");
```

**Why this fixture:** `F` is a complete global, already interned by `ParseFunction` NotifySema. `Entry` is interned the same way. The call `F(1, 2` is inside `Entry` with a missing `)`. `ParseArgList` has both argument nodes and then errors. Today Parser never calls Sema on `snFunctionCall`, and `isSyntaxError` prevents `ActOnStmtFromNode` of a complete body, so there is no Call expr.

**Must appear:** an EXPR dump line with `callee=F(int,int)`; `nargs=2`; `args=` reverse-formal `2,1` (same spelling as `ReverseFormalChildrenMatchStoredOrder`). `kind=Function name=F` / `key=F(int,int)` / `kind=Function name=Entry` may also appear.

**Must not appear:** binding `callee=Entry()`; empty `callee=` as the only Call; requiring `Seal()` success; using `FindNamedDecl` first-same-name if a second `F` exists (this fixture has one `F`).

**Expected first RED:** dump has `key=F(int,int)` and `key=Entry()` and **no** `callee=F(int,int)` on an EXPR Call. Code today: `ParseFunctionCall` ~1798–1811 returns after `ParseArgList` with no Sema call.

Do not `NotifySema` the call node (decl WalkOne). Do not `WalkOne(snReturn)` — `ActOnReturnStmt` steals `Entry`'s body.

---

### 2. `ParserActOnCallDoesNotDuplicateOnSuccessfulParse`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int F(int a, int b)
	{
		return a;
	}

	int Entry()
	{
		return F(1, 2);
	}
	)AS");
```

**Must appear:** exactly **one** EXPR Call line with `callee=F(int,int)`; `nargs=2`; reverse-formal `args=2,1`.

**Must not appear:** two Call lines with `callee=F(int,int)` (incremental ActOn plus later `ActOnStmtFromNode` of `Entry`'s body).

**Expected first RED if incomplete is implemented without reuse:** two Calls. Code today (no incremental ActOn): this method may already pass via complete WalkOne. Keep it.

Reuse strategy (after RED only): `ActOnExprFromNode(snFunctionCall)` looks for an existing Call expr owned by the same `owner` with the same `range.begin.offset` (or the same callee key + nargs) and returns that id instead of `ActOnCall` again. Do not merge graphs. Do not invent a verifier rule.

Count Call lines the same way typedef counted `kind=Typedef name=Count`.

---

## Implementation notes (after RED only)

`ParseFunctionCall`:

```text
ParseOptionalScope
ParseIdentifier
ParseArgList          // even on missing ')', arg children exist
if (sema) ActOnParsedExpr(node, script)
return node
```

Call `ActOnParsedExpr` when `snArgList` has at least one child **or** when the identifier exists and `ParseArgList` ran (empty `F(` is allowed to intern `nargs=0` / empty callee; this slice's tests use two args). Prefer acting whenever `sema` is set, including `isSyntaxError`, so the incomplete fixture works.

`ActOnParsedExpr` must use `CurrentDeclContext()` as owner so `F` resolves from `Entry`'s enclosing TU via `LookupCandidatesFrom`.

Do not ActOn `snReturn` incrementally.

Do not start: construct calls, `opAdd`, property rewrite, index, conversion, lambda **invoke**, lifetime. Those stay later slices.

Do not mark 13.2: production Bytecode is still `asCCompiler`; other expr forms still WalkOne.

---

## Checkbox discipline

| After these two methods are green | Box |
| --- | --- |
| 13.2 | stays `[ ]` |
| 5.3 call plans | stays `[ ]` — dumps already had callee; Parser incremental is not production consumption |
| 5.9 / 4.2 | stay `[ ]` |
| 2.4 / 2.6 / 2.8 / 13.4 / 13.5 | stay `[x]` |
| 13.6 / 9.1 / section 10 | stay `[ ]` |

Append evidence to `attachments/wave-b-results.md`. Do not rewrite remaining `tasks.md` boxes down.

---

## File map (paths relative to `D:\as-cta`)

| Path | Role |
| --- | --- |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-b-parser-expr.md` | This map |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Add the two methods |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp` | `ParseFunctionCall` / possibly `ParseArgList` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.h` / `as_sema.cpp` | `ActOnParsedExpr` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | Call reuse |

Do not touch: `as_compiler.cpp` emit, `as_module.cpp` `Build()`, `as_bytecode_codegen.cpp`, `as_ast_verifier.cpp`, `Core/angelscript.h`.
