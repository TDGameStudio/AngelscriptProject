# Wave B compile→seal operator/conversion/logical dumps (B-compile-seal)

> **For exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Tests are already on disk. Run the SemaAuthority prefix **before** editing `as_sema_expr.cpp`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2.

**Goal:** On the real `Build()` + retain path, sealed dumps must record `v - 3` as `callee=T::opSub(int)` (not builtin Binary `literal=-`), plus lock Cast conversion and `&&` short-circuit facts already interned by Parser ActOn / WalkOne.

**Architecture:** Parser still builds `asCScriptNode`. Sema `ActOnExprFromNode` for `snExpression` currently rewrites only `ttPlus` → `opAdd`. Production Bytecode stays `asCCompiler`. This package only grows interned call/conversion/logical facts on compile→seal.

**Tech Stack:** Maintained AngelScript fork (`asCSema`, `asCASTDump`). CQTest SemaAuthority prefix. No Unreal types in fork files. No Clang/LLVM.

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-compile-seal** |
| Mode now | **LANDED 2026-08-21.** SemaAuthority **102/102**, CanonicalAST **117/117**, Compiler **305/305**. Did not mark `tasks.md`. |
| UBT mutex | One UBT user in `D:\as-cta`. CAEngine `UE4Editor` is not this lock. `-NoXGE`. |

## Global constraints

- TDD. Watch RED of `OperatorMinusSelectsOpSubNotBuiltinBinary` before filling `opSub`.
- Do not mark 13.2 / 4.2 / 5.9 / 13.3 / 9.1 / 13.6.
- Do not start production `Build()` routing / Ready() / default CANONICAL.
- Do not make missing callee a verifier / Seal hard no.
- Do not add `opMul` / `opDiv` / `opNeg` without a new failing test.
- Do not edit `as_compiler.cpp`, `as_module.cpp` `Build()`, `as_ast_verifier.cpp`, or `as_bytecode_codegen.cpp`.
- Fork dialect: no script `funcdef` / `@` / `is`. Host `RegisterFuncdef` already covered by B-call-callee.
- After GREEN, 13.2 stays `[ ]` because production backends still rerun `asCCompiler`.

## Files

- Test (already written, do not restyle): `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  - `OperatorMinusSelectsOpSubNotBuiltinBinary`
  - `CastConversionRecordsOnCompileSealPath`
  - `LogicalShortCircuitRecordsOnCompileSealPath`
- Implement: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` snExpression (~1098–1141)

## Tests already on disk (do not rewrite)

`OperatorMinusSelectsOpSubNotBuiltinBinary` — `struct T { int opSub(int a) { return a; } }; return v - 3;`

Must dump:

- `key=T::opSub(int)`
- `callee=T::opSub(int)`

Must not dump:

- `kind=Binary` with `literal=-`

`CastConversionRecordsOnCompileSealPath` — `return G(Cast<float>(1));` with `int G(float a)`.

Must dump `kind=Conversion` and `callee=G(float)`, not `callee=G(int)`. May already PASS.

`LogicalShortCircuitRecordsOnCompileSealPath` — `return F(1) && G(2);` with `F(int)` / `F(float)` / `G(int)`.

Must dump `kind=Logical`, `callee=F(int)`, `callee=G(int)`, not `callee=F(float)`. May already PASS.

## Step 1: Confirm RED

From `D:\as-cta`:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-compile-seal-red -TimeoutMs 600000
```

Expected:

- Count **102** methods (99 previous GREEN + 3 new).
- `OperatorMinusSelectsOpSubNotBuiltinBinary` FAIL: dump has `kind=Binary literal=-` and lacks `callee=T::opSub(int)`.
- Cast / Logical may PASS.
- Other 99 stay PASS.

If opSub already PASSes, the rewrite landed elsewhere — stop and record; do not restyle.

If the test errors (crash / compile), fix the test typo first; do not implement `opSub` until the failure is the missing callee.

## Step 2: Minimal GREEN

In `as_sema_expr.cpp` snExpression, replace the `ttPlus`-only block with a token→method name helper. Keep `FindBestCallee` METHOD name match. Do not change Binary fallback when no method exists.

```cpp
static const char *OperatorMethodName(eTokenType token)
{
	if( token == ttPlus ) return "opAdd";
	if( token == ttMinus ) return "opSub";
	return 0;
}
```

Use `const char *methodName = OperatorMethodName(child->tokenType);` then `if( methodName ) { ... FindBestCallee(..., methodName, ...); method->name.Equals(methodName) ... }`.

Do not add `ttStar` / `opMul` here.

## Step 3: Confirm GREEN

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-compile-seal-green -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-compile-seal-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-compile-seal-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-compile-seal-compiler -TimeoutMs 600000
```

Expected: SemaAuthority **102/102**. CanonicalAST and Compiler no new fails vs last GREEN (**114/114**, **302/302** plus the three new methods if they live only under SemaAuthority).

Copy reports to `C:\Users\scottmei\AppData\Local\Temp\grok-goal-cafa12c46849\implementer\` if that scratch exists.

Leave `tasks.md` 13.2 / 4.2 / 5.9 `[ ]`. Do not start D Task 6.

## Why this is not 13.2

Production Bytecode is still `asCCompiler` (criterion 4). Parser still builds `asCScriptNode`. This package only stops dumps from lying about `opSub` on compile→seal.
