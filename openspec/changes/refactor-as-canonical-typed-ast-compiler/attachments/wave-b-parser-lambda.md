# Wave B next Parser Sema actions (B-parser-lambda)

> **For exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild.ps1 -NoXGE` then the SemaAuthority prefix **before** filling `as_parser.cpp` / `as_sema*`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2.

**Goal:** Exact TDD map for the next exclusive-UBT Wave B Parser-action slice **after** import/typedef. Intern a script lambda during parse (incomplete body must not drop it), reuse it on a successful parse so WalkOne does not duplicate, and keep distinct `<lambda>(int)@offset` keys. This is **not** Sema environment close (13.2) and **not** production `Build()` routing.

**Prerequisite (do not redo; do not start this UBT slice until green):**

| TEST_METHOD | File |
| --- | --- |
| `ParserActOnImportDeclBeforeFromFails` | `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| `ParserActOnImportDoesNotDuplicateOnSuccessfulParse` | same |
| `ParserActOnTypedefDeclBeforeSemicolonFails` | same |
| `ParserActOnTypedefDoesNotDuplicateOnSuccessfulParse` | same |

If those four are still red, finish **B-parser-import-typedef** first (`attachments/async-work.md` §6).

Keep `MultipleLambdasKeepDistinctStableKeys`. Do not weaken it.

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode
  → incremental NotifySema / ActOn
        globals / class / method / local-decl / namespace / enum / interface / mixin / import / typedef
  → lambda still ParseLambda then later ActOnLambdaFromNode of a complete snFunction
  → expression / statement bodies still ActOnExprFromNode / ActOnStmtFromNode
  → asCBuilder / asCCompiler                      (production Bytecode)
  → isolated asCBytecodeCodeGen::Generate()       (test-only)
```

LLVM/Clang is a **shape reference only** (`attachments/llvm-ast-architecture.md`). Do not link Clang/LLVM.

Already true after import/typedef (reuse, do not reimplement):

- `asCSema::PushDeclContext` / `PopDeclContext` / `CurrentDeclContext` / `NoteActedDecl` / `lastActedDecl`
- Parser RAII `asSDeclContextScope` + `PushLastActed()` in `as_parser.cpp`
- `ParseFunction(..., notifySemaAfterParams=true)` ActOn after name+params for globals **and** methods
- Mixin uses `ParseFunction(false, true, mixinToken)`
- `FindExistingFunctionLike` matches name + param types + const trait (name `"function"` will **not** match interned `"<lambda>"` — this slice must fix that)
- `ActOnFunctionLike` already detects lambda when the function name is `"function"` **or** there is no `snParameterList` and there is a statement block
- `FinishDecl` appends `@offset` when `asAST_TRAIT_LAMBDA` is set
- `WalkParameterList` falls back to walking the function node's children when `snParameterList` is missing
- `ParseLambda` currently does **not** add the `function` token as a child and does **not** wrap params in `snParameterList`

---

## Header (this attachment)

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-parser-lambda** (`attachments/async-work.md` §6) |
| Mode now | **Attachment ready.** Exclusive UBT when the mutex is free. |
| Mode later | Exclusive UBT: SemaAuthority TDD, then `as_parser.cpp` + `as_sema_decl.cpp` (FindExisting for lambdas). **Do not mark 13.2.** |
| UBT mutex | One UBT user in `D:\as-cta`. If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are live, wait. `-NoXGE`. |
| Order | failing lambda tests → RED SemaAuthority → implement ParseLambda NotifySema + FindExisting lambda → GREEN SemaAuthority → Compiler CanonicalAST |

虚标 = checking a task whose spec meaning is unmet. Parser actions for lambda are **not** 13.2. Production Bytecode is still `asCCompiler`. `Ready()` is false. Default is LEGACY.

---

## Global constraints

- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` (not `null`); mixin **functions**, not mixin classes; mutable script globals forbidden (`const` only); `asEP_REQUIRE_ENUM_SCOPE=1` so enum values are `ETeam::Red`; host `RegisterFuncdef` / `RegisterEnum` allowed; source spelling `float` stays `float`.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces, indented with surrounding C++ (`Documents/Rules/ASInlineFormattingRule.md`).
- TDD. SemaAuthority prefix first. After green, Compiler CanonicalAST prefix. **Never All.** Never production `Build()` routing. Never flip `Ready()` / default CANONICAL.
- **Hard no:** CALL-without-callee as a seal / verifier firewall. `asCASTVerify` must still succeed on unsealed graphs (`Seal()` needs that). Wave C 2.4 / 2.6 / 2.8 / 13.4 / 13.5 stay closed. Do not invent stmt-level cleanup-plan POD fields.
- Dump printer (`as_ast_dump.cpp`) **not** required. Reuse `kind=` / `name=` / `key=` / `kind=Param`.
- Implementer files: `as_parser.cpp` (`ParseLambda`), `as_sema_decl.cpp` (`FindExistingFunctionLike` / lambda reuse / `ActOnFunctionLike` detection). Touch `as_sema.h` / `as_sema.cpp` only if a dedicated `FindExistingLambda` helper must be declared. Do not add `as_sema_scope.cpp`.
- Do **not** reuse legacy `as_symboltable.h` / `as_variablescope.h`.
- Do not edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, `as_ast_verifier.cpp`, or `as_bytecode_codegen.cpp`.
- Do **not** re-enable `funcdef` / `is` in `as_tokendef.h`.
- After these tests go green, **13.2 / 5.9 / 4.2 stay `[ ]`**. Record evidence in `attachments/wave-b-results.md`.

---

## Why lambda is the next 4.2 form

Task 4.2 lists Parser Sema-action entry points for TU / namespace / typedef / enum / **funcdef** / interface / class / function / method / ctor-dtor / variable / property / import / parameter.

Landed as Parser ActOn: namespace, typedef, enum, interface, class, function, method, ctor/dtor (via method ParseFunction), local variable, import, parameter.

Remaining:

| Form | Status |
| --- | --- |
| Script `funcdef` | **fork-rejected**. Tokenizer stays commented. Do not write tests. Host `RegisterFuncdef` is a different surface. |
| Lambda | **this slice**. `ParseLambda` builds `snFunction` and only `ActOnLambdaFromNode` after a complete expr/stmt walk. |
| Property | Generated accessors already dump on complete parse (method 21). Not this slice. |
| Expression / call / stmt body | Next package `wave-b-parser-expr.md`, after lambda. |

`ParseLambda` live shape (`as_parser.cpp` ~1707–1773):

1. `CreateNode(snFunction)`.
2. Consume the `function` identifier token — **not** added as a child.
3. Parse optional type / type-mod / identifier **directly onto the function node** (no `snParameterList`).
4. `ParseFunctionStatementBlock()`.
5. No `NotifySema`.

`ActOnFunctionLike` lambda detection (`as_sema_decl.cpp` ~685–690):

```text
name.Equals("function")
  || (no snParameterList && ident != 0 && snStatementBlock present)
```

If you `NotifySema` the current incomplete node (no block yet), `FunctionNameNode` returns the **parameter name** (`x`), `isLambda` is false, and Sema interns `kind=Function name=x`. That is the wrong GREEN. The tests below reject it.

Mixin already solved a similar trap: prepend the mixin token as `prefixChild` before `NotifySema`. Lambda must prepend a `function` identifier child (and should wrap params in `snParameterList`) so `FunctionNameNode` is `"function"` even before the body exists.

`FindExistingFunctionLike` matches child `name` to `FunctionNameNode` text. After ActOn, the interned name is `"<lambda>"`, so reuse will miss unless this slice teaches FindExisting that a `"function"` node matches `TRAIT_LAMBDA` / `"<lambda>"` with the same param types. Without that, the successful-parse method duplicates.

Do **not** `WalkOne(snReturn)` incrementally inside the lambda body (`ActOnReturnStmt` steals the function body — class/method-body first GREEN 13/36). Local `snDeclaration` NotifySema may stay as today.

---

## Exclusive-UBT order (TDD)

Add both methods, `RunBuild.ps1 -NoXGE` from `D:\as-cta`, SemaAuthority RED, then implement, SemaAuthority GREEN, then CanonicalAST. Never All.

Shared skeleton: `FNativeTestEngine` + `ON_SCOPE_EXIT { Engine.Destroy(); }` + `CreateBuilderModule` + `Builder.silent = true` + `Parser.SetSema` + **no** `Module->Build()`. Incomplete methods assert `ParseResult < 0` and dump **without** requiring `Seal()`. Complete methods `Seal()`.

ProjectFile must be `D:\as-cta\AngelscriptProject.uproject`. Adaptive skip from the main workspace is stale.

```text
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-parser-lambda -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-lambda-red -TimeoutMs 600000
```

After green:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-lambda-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-parser-lambda-canonical -TimeoutMs 600000
```

Expected RED before impl: total=55 passed=53 failed=2 (the two new methods). `MultipleLambdasKeepDistinctStableKeys` stays green.

Expected GREEN: SemaAuthority **55/55**, then CanonicalAST **70/70** (68 + 2). If CanonicalAST already includes the new methods under SemaAuthority, the CanonicalAST total is 68+2. Do not invent extra methods.

---

### 1. `ParserActOnLambdaDeclBeforeBodyParseFails`

| Field | Value |
| --- | --- |
| File | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |
| Place | After `ParserActOnTypedefDoesNotDuplicateOnSuccessfulParse` |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int Entry()
	{
		function(int x) { return
	)AS");
```

**Why this fixture:** `ParseFunction` already ActOn `Entry` after name+params and pushes that decl context. `ParseLambda` then parses `function(int x)` **before** the lambda body is complete. `ParseScript` will not WalkOne a complete expr tree because `isSyntaxError`. Today there is no `NotifySema` in `ParseLambda`, so the dump has `Entry` and no lambda.

**Must appear:** `kind=Function name=<lambda>` (or `kind=Function` with `name=<lambda>`); `key=` containing `(int)` and `@`; `kind=Param name=x`.

**Must not appear:** `kind=Function name=x` as the lambda; intern the lambda as a TU global `key=x(int)`; `name=function` as a callable TU function; requiring `Seal()` success.

**Expected first RED:** dump contains `kind=Function name=Entry` / `key=Entry()` and **no** `name=<lambda>`. Code today: `ParseLambda` ~1707 returns without `NotifySema`.

Naive NotifySema of the current node (no `function` child, no `snParameterList`, no block) is also a wrong GREEN: `FunctionNameNode` is `x`. The must-not-appear line catches that.

---

### 2. `ParserActOnLambdaDoesNotDuplicateOnSuccessfulParse`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int Entry()
	{
		function(int x) { return x; };
		return 1;
	}
	)AS");
```

**Must appear:** exactly **one** dump line with `name=<lambda>`; that line's `key=` contains `(int)` and `@`; `kind=Param name=x`.

**Must not appear:** two `name=<lambda>` lines; `kind=Function name=x`; dropping `MultipleLambdasKeepDistinctStableKeys`.

**Expected first RED (if incomplete already implemented without FindExisting):** two `<lambda>` decls — ParseLambda NotifySema plus later `ActOnLambdaFromNode` / WalkOne `snFunction`. Code today (no NotifySema): this method may already pass via complete `ActOnLambdaFromNode`. If it is already green on the first RED run, **keep it** as the duplicate guard; the incomplete method is still the authority RED.

Count `name=<lambda>` the same way `ParserActOnTypedefDoesNotDuplicateOnSuccessfulParse` counts `kind=Typedef name=Count`.

---

## Implementation notes (after RED only)

Minimal `ParseLambda` shape (do not call `ParseFunction`; lambda BNF has no return type):

1. `CreateNode(snFunction)`.
2. After accepting the `function` identifier token, add it as an `snIdentifier` child (same idea as mixin `prefixChild`). `CreateNode` + `SetToken` of that token, or a helper equivalent to `ParseIdentifier` for the already-consumed token.
3. Parse `(` then wrap parameter type/mod/name children in `snParameterList` (reuse `ParseParameterList` only if it matches lambda BNF; otherwise build `snParameterList` around the existing loop). Closing `)` stays on the list.
4. `asSDeclContextScope lambdaScope(sema);` then `NotifySema(node); lambdaScope.PushLastActed();` **before** `ParseFunctionStatementBlock()`.
5. Do not NotifySema `snReturn` inside the lambda body.

`FindExistingFunctionLike` / `ActOnFunctionLike`:

- If `FunctionNameNode` text is `"function"` **or** `asAST_TRAIT_LAMBDA` is set on a child, treat the interned name as `"<lambda>"` for matching.
- Match param types (and count) as today. Offset identity: prefer the function-token range so incomplete and complete reuse the same decl (`FinishDecl` `@offset` uses `decl->range.begin.offset`).
- `ActOnFunctionLike` must set `isLambda` from the `function` child **before** the body exists (do not require `snStatementBlock` for that path).

Do not intern lambda as `kind=Mixin`. Do not use `@` handle syntax. Do not call `FindMatchingFuncdef`.

Keep Unreal types out of fork files.

---

## Checkbox discipline

| After these two methods are green | Box |
| --- | --- |
| 13.2 Sema environment | stays `[ ]` — production Bytecode is still `asCCompiler`; expr/stmt still WalkOne |
| 4.2 Parser Sema-action entry points | stays `[ ]` — script `funcdef` fork-rejected; expr/stmt not actions |
| 4.4 / 5.9 lambda coverage | stays `[ ]` — keys already existed; Parser action is not public registration |
| 2.4 / 2.6 / 2.8 / 13.4 / 13.5 | stay `[x]` — do not reopen |
| 13.6 / 9.1 / section 10 | stay `[ ]` — do not route `Build()` |

Append evidence to `attachments/wave-b-results.md` with prefix, label, report path, pass/fail. Do not rewrite remaining `tasks.md` boxes down. A short progress sentence under 4.2 / 13.2 is allowed.

---

## File map (paths relative to `D:\as-cta`)

| Path | Role |
| --- | --- |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-b-parser-lambda.md` | This map |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/async-work.md` | Package table |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Add the two methods |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp` | `ParseLambda` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` | lambda detection + FindExisting |

Do not touch: `as_compiler.cpp` emit, `as_module.cpp` `Build()`, `as_bytecode_codegen.cpp`, `as_ast_verifier.cpp`, `as_tokendef.h` (`funcdef`/`is`), `Core/angelscript.h`.
