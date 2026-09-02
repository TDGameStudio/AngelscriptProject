# Wave B — StaticJIT unique `F(float)` identity (exclusive UBT)

Package: **B-jit-identity-float**.
Worktree: `D:\as-cta`. One UBT user. `-NoXGE`.
Leave **13.2** and **13.3** `[ ]`. Do not start Wave D Task 6. Do not archive / commit.

## Goal

Make `UniqueSignatureOverloadsBindExactStableKeys` bind Runtime `F(float)` to AST `stableKey` `F(float)` with a unique non-zero DeclId, without first-name bind or DeclId 0 fallback. Identity prefix must go **3/3**.

## Already true (do not redo)

- Test file exists: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITCanonicalASTIdentityTests.cpp`
- Prefix: `Angelscript.TestModule.StaticJIT.CanonicalASTIdentity`
- Snapshot bind is `Decl->stableKey.Equals(Expected)` in `BindCanonicalFunctionDeclValue` (`AngelscriptStaticJITGenerationSnapshot.cpp`)
- Eligibility rejects DeclId 0 (`EvaluateAngelscriptTypedASTJITEligibilityFromCanonical`)
- Last run: **2/3** — Namespace twins PASS, Zero Decl PASS, Unique FAIL at line 263: `F(float) must bind a unique AST decl, not DeclId 0`
- Snapshot dump of Unique fixture: two `F` rows, empty ns, sealed=y, `int F(const int)` declId=2, `int F(const float)` declId=0

## Root cause

Script keyword `float` interned as `ttFloat` → AST type key `"float"` → decl `F(float)`.

Runtime `asCDataType::GetTokenType()` for that param is `ttFloat64` (`asEP_FLOAT_IS_FLOAT64=1`).

`PrimitiveAstTypeKey` currently:

```cpp
if (Token == ttFloat || Token == ttDouble) return "float";
```

`ttFloat64` / `ttFloat32` return `""` → Expected key `F()` → no AST match → DeclId 0.

Do **not** map `ttFloat64` to `"double"`. `InternPrimitive(ttDouble)` is `"double"`, but this dialect’s AST key for script `float` is `"float"`.

## TDD status

RED already observed for Unique. Do not add a new Unique test. Do not weaken needles (`const int` / `const float` match Runtime `GetDeclaration`). Implement the token map, rebuild, watch Unique GREEN while twins + zero stay GREEN.

## Production change (minimal)

File: `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGenerationSnapshot.cpp`

In `PrimitiveAstTypeKey`, treat all Runtime float-width tokens as AST `"float"`:

- `ttFloat`
- `ttDouble`
- `ttFloat32`
- `ttFloat64`

If Unique still fails after that, dump `BuildRuntimeAstIdentityKey` vs every function/method `stableKey` in the sealed AST. Do not invent a second key dialect. Do not fall back to name+param-count.

Do **not** edit fork `as_sema.cpp` / `InternPrimitive` for this package unless the dump proves AST keys are not `F(float)`.

## Commands (only these, from `D:\as-cta`)

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-jit-identity-float
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.CanonicalASTIdentity" -Label wave-b-jit-identity-float
```

If 3/3 GREEN, optional regression (same mutex, do not start if Unique still red):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-jit-identity-float-canonical
```

Copy identity log to `C:\Users\scottmei\AppData\Local\Temp\grok-goal-cafa12c46849\implementer\canonical-ast-identity.log` when present.

## Stop conditions

- Identity **3/3** → stop. Do not add method/ctor/dtor/mixin/lambda tests in this package (that is **B-jit-identity-forms**).
- Do not check `tasks.md` 13.2 / 13.3.
- Do not start production `Build()` / Ready() / D Task 6.
- Do not spawn a second UBT.
- `UE4Editor` at `W:\CA0917` is CAEngine, not this mutex.
