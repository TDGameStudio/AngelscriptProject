# Wave D sixth-pass F5 execute — exclusive UBT (LEGACY 1-arg lambda `F()` = 42)

Worktree: `D:\as-cta`. Exclusive UBT package **D-sixth-f5-exec**.
Change: `refactor-as-canonical-typed-ast-compiler`.

**REQUIRED SUB-SKILLS:** `superpowers:systematic-debugging` first, then `superpowers:test-driven-development`, then `superpowers:verification-before-completion`.

Do **not** check `tasks.md` 9.5 / 13.2 / 13.3 / 10.2 / 9.1 / 13.6.
Do **not** archive. Do **not** commit unless the user asks.
Do **not** spawn a second UBT. Do **not** run UBT against `D:\Workspace\AngelscriptProject` (main).
Do **not** implement F1 remainder, F6, ctor/dtor intern, Wave E–G, or CANONICAL `CompileFunction`.

Default pipeline stays LEGACY. These tests must **not** `SetCompilerPipeline`. Publisher must stay `COMPILER`.
No Clang/LLVM link. No Unreal types in fork frontend files.
No script `funcdef` / `@` / `is`. Host `RegisterFuncdef` remains legal. `nullptr` = `ttNull`.

---

## Goal

Default LEGACY 0-arg **and** 1-arg lambda-to-host-funcdef compile **and execute 42**.

Arity/names are **already in source**. 0-arg execute is GREEN. The remaining failure is 1-arg `SetArgDWord` AV.

## Why this is not the original F5 layout bug

Sixth-pass F5 (`reviews/implementation-rereview-2026-08-22-sixth-pass.md`):

- `ParseLambda` emits `snIdentifier("function")` + `snParameterList` + block.
- Old `ImplicitConvLambdaToFunc` walked **direct children** of `snFunction` and counted `"function"` as a parameter.

Landed (do **not** redo):

- `as_compiler.cpp:11521-11593` `ImplicitConvLambdaToFunc`: enter `snParameterList`; count identifiers; skip `"function"`; type-check list `snDataType` only on the pre–Wave-B sibling layout.
- `as_builder.cpp:5500-5582` `RegisterLambda`: names from list identifiers; else sibling walk skipping `"function"`; dummy pad `_pN` if names shorter than funcdef arity.
- Dialect-legal 0-arg fixture (script cannot take funcdef by value without `@`):

```angelscript
int F()
{
    return Invoke(function()
    {
        return 42;
    });
}
```

Host: `RegisterFuncdef("int ZeroArg()")` + `RegisterGlobalFunction("int Invoke(ZeroArg&in)", asFUNCTION(LegacyInvokeZeroArg), asCALL_GENERIC)`.

Evidence: `wave-d-f5-decl` ZeroArg **Success**. `wave-d-f5-hostin` / `wave-d-f5-top2` same.

## Why 1-arg still AVs

Keep the existing method `LegacyOneArgLambdaToHostFuncdefExecutes42` in:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeCompilerCoreTests.cpp`

Current script (legal; do not restore `Unary U = function(...)` by-value):

```angelscript
int F()
{
    return Invoke(function(int X)
    {
        return X + 1;
    }, 41);
}
```

Host: `RegisterFuncdef("int Unary(int)")` + `RegisterGlobalFunction("int Invoke(Unary&in, int)", asFUNCTION(LegacyInvokeUnary), asCALL_GENERIC)`.

After Build, live facts already asserted:

- compile `== 0`
- module has `$` function with `parameterTypes.GetLength()==1`
- `parameterNames[0]=="X"`
- `GetDeclaration()` (copy immediately; the buffer is recycled) is `int $int F()$0(const int)`

Then `FSdkFunctionInvoker.AddArg(int32(41))` crashes:

```text
wave-d-f5-decl
D:\as-cta\Saved\Tests\wave-d-f5-decl\20260822_102856_252_de1a7ae3
1/2  ZeroArg Success; OneArg AV
AngelscriptNativeCompilerCoreTests.cpp:460
asCContext::SetArgDWord  as_context.cpp:943
reading address 0
```

Root cause — late lambda never laid out:

| Step | When | What happens to the `$` lambda |
| --- | --- | --- |
| `BuildLayoutFunctions` `:796-811` | **Before** `CompileFunctions` | `LayoutFunction` → `CalculateParameterOffsets()` on `functions[]` **then** |
| `RegisterLambda` `:5500` | **Inside** compiling `F()` | Appends a new `sFunctionDescription` + `AddScriptFunction` **after** layout |
| `RegisterScriptFunction` `:5902` | At RegisterLambda | Copies `parameterTypes` / `parameterNames`. **Does not** call `CalculateParameterOffsets` |
| `CalculateParameterOffsets` call sites | layout `:4442`, factory `:810`, **funcdef** `:2488` | None of these run for a lambda registered during `CompileFunctions` |
| Empty `asCArray` | `as_array.h:111-116` | `array=0`, `length=0` |
| `SetArgDWord` `:941-947` | Test / nested generic | `parameterOffsets[arg]` with `array==0` → AV at address 0 |
| `Prepare` `:643` | Invoker.IsValid was true | `m_argumentsSize = spaceNeededForArguments` which stays **0**, so Prepare succeeds |

0-arg GREEN because `LegacyExecuteFuncdef` only writes arg 0 when `GetParamCount() > 0`. Nested generic on 1-arg hit the same empty offsets (`wave-d-f5-arity` / `wave-d-f5-host2`). Direct Invoker on the `$` lambda isolates it (not a nested-VM-only bug).

This is **not** the Engine `CreateDelegate` / `asFUNC_DELEGATE` deferred limitation in `AngelscriptNativeEngineObjectServiceTests.cpp`. Do not “fix” F5 by skipping execute or by marking 1-arg compile-only.

## Required test shape (TDD; existing methods)

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.Core`

Keep `LegacyZeroArgLambdaToHostFuncdefExecutes42` unchanged except if a helper rename is required.

Change `LegacyOneArgLambdaToHostFuncdefExecutes42` so it **fails closed without AV**, then execute `F()` like ZeroArg:

1. Keep pipeline assert `LEGACY`, host `RegisterFuncdef("int Unary(int)")`, host `Invoke(Unary&in, int)`, `CompileNativeModule == 0`, find `$` lambda, `parameterNames[0]=="X"`.
2. **Before any `SetArg*` / `AddArg`:** assert `Lambda->parameterOffsets.GetLength() == Lambda->parameterTypes.GetLength()` (expect 1). An empty-offsets RED must be an assertion, not a crash.
3. **Production execute gate:** `ExecuteScriptFunction(..., "int F()", Value) && Value == 42` — same helper as ZeroArg. Do **not** keep `FSdkFunctionInvoker.AddArg` on the `$` lambda as the only execute path; that is a diagnostic, not the conversion surface. Optional extra: after offsets are non-empty, Invoker AddArg(41) + CallAndReturn 42 is allowed **in addition**.
4. Publisher `asBYTECODE_PUBLISHER_COMPILER`.

Do **not** merge into ProductionCodeGen. Do **not** `SetCompilerPipeline`. Do **not** re-enable tokenizer `funcdef` / `@`. Do **not** use `FScopedNativeModule` as the only Build gate.

File-level helpers `LegacyFuncdefFromGeneric` / `LegacyExecuteFuncdef` / `LegacyInvokeZeroArg` / `LegacyInvokeUnary` may stay. If nested generic still AVs **after** offsets exist, that is a second production bug (RequestContext / Prepare on a generic-owned engine); fix it in the fork, not by skipping execute.

`GetDeclaration()` returns a recycled buffer — copy to `std::string` before any later `GetDeclaration()` call. `asCString` has `StartsWith` / `Equals`, not `Find`.

## Production fix (after the offsets assert is RED without crash)

Preferred (smallest, at the registration site that is unique to lambdas):

`as_builder.cpp` `RegisterLambda`, after `RegisterScriptFunction` succeeds and `functions.GetLength()-1` is the new description:

```cpp
asCScriptFunction *func = engine->scriptFunctions[functions[functions.GetLength()-1]->funcId];
if( func )
	func->CalculateParameterOffsets();
```

`LayoutFunction` (`:4436-4443`) already does exactly that for pre-CompileFunctions entries. Calling it (or the same `CalculateParameterOffsets`) for the late lambda is the honest layout, not a test-only patch.

Acceptable equivalent: `RegisterScriptFunction` always `CalculateParameterOffsets()` on the newly added `engine->scriptFunctions[funcId]` for non-interface functions. That also covers any other late `RegisterScriptFunction` during `CompileFunctions`. Do **not** only call it from the test.

Must not:

- Call `CalculateParameterOffsets` only inside `AngelscriptNativeCompilerCoreTests.cpp`.
- Re-run whole `BuildLayoutFunctions` (would re-layout classes / recompile globals).
- Change `ParseLambda` away from `snParameterList` (Canonical Sema intern depends on it).
- Emit a CANONICAL CodeGen path for these tests.
- Count `"function"` as a parameter again.

## Verification (from `D:\as-cta`, exclusive UBT, `-NoXGE`)

`RunTests.ps1` does **not** UBT. After any impl, `RunBuild.ps1` first. Do **not** run tests against a failed build (old DLL will crash).

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-d-f5-exec
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.Core.FCompilerCoreTests.Legacy" -Label wave-d-f5-exec -TimeoutMs 600000
```

Expected: **2/2 PASS** (ZeroArg + OneArg execute 42).

Then:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-d-f5-compiler -TimeoutMs 600000
```

Expected: previous F4 **414/414** plus these two Core methods (likely **416/416** if both are new vs F4; count from the report, do not invent). Zero failures.

Never All. Never Standalone for this slice.

Record report paths in `attachments/sixth-pass-verified.md` F5 row. **Leave 9.5 / 13.2 `[ ]`.**

## Files

| File | Why |
| --- | --- |
| `AngelscriptNativeCompilerCoreTests.cpp` | Keep ZeroArg. OneArg: offsets assert then `ExecuteScriptFunction` `F()` = 42 |
| `as_builder.cpp` `RegisterLambda` (or `RegisterScriptFunction`) | `CalculateParameterOffsets` on the late `$` function |
| `as_compiler.cpp` `ImplicitConvLambdaToFunc` | **Do not regress** the `snParameterList` walk |

## F5 close / not close

Close: default LEGACY 0-arg and 1-arg lambda-to-host-funcdef compile+execute 42, publisher `COMPILER`, no AV.

Not close: 9.5, 13.2, stored closures, capture plan in Sema, script `funcdef`, CANONICAL CompileFunction, Wave G.
