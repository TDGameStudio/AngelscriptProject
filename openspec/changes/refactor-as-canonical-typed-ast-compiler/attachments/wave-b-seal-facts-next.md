# Wave B exclusive UBT — remaining compile→seal Sema facts (not construction-API)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-seal-facts**. **This mutex.** One UBT. `-NoXGE`.

Companions: `attachments/async-work.md` §4; `attachments/async-dispatch.md`.
This bite is **not** a 13.2 / 5.4 / 5.5 / 5.6 / 5.9 / 4.2 / 9.5 close. Do not check those boxes.

LLVM/Clang is **shape only**. Do not link. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | **LANDED 2026-08-22.** Exclusive UBT closed. SemaAuthority **246/246**, CanonicalAST **313/313**, Compiler **503/503** (`succeeded=502`, `succeededWithWarnings=1`). Did **not** mark `tasks.md`. |
| Live | Four compile-seal oracles on `Build()`+retain. Bite 1/2/4 already-green intern. Bite 3 interned namespace VAR `NotifySema` before later function bodies. |
| Do not mark | **any remaining OpenSpec box** |
| Skills | `superpowers:test-driven-development` then `superpowers:verification-before-completion` |

---

## 0. Already true — do not redo / do not restore

- InitPlan execute 42. `ParseConditionAsAssignment` when Sema on.
- Native 0-arg intern. Factory STOREOBJ. Dummy VALUE invent CONSTRUCT **deleted**.
- `FindConstructorId` / `FindFactoryId` **definitions may remain**. **Call sites must stay gone.**
- MemberRef execute 42. `UnwrapAssignLhs`. Sealed native `byteOffset`. Dump `offset=`.
- `GetFirstProperty` **gone** from `as_bytecode_codegen.cpp`. Do not restore.
- FindExistingExpr: kind + begin; **when request end nonzero, also match end**. Do **not** globally full-span `FindExistingExpr` / `FindExistingStmt`.
- ObjectTypeFromExpr: unwrap wrappers then **only** `bridge->Resolve`. Do not restore `GetTypeInfoByName` / only-VALUE guess.
- Compile-seal dumps already exist for: exact call overload, call-arg conversion dest=/src=, cast, ternary arms, ctor overload, operators including opSub/opMul/opNeg, logical &&, hidden args, receiver=, import route, property Get/Set, MemberRef field, InitPlan, Materialize+Cleanup, dtor callee, OpaqueValue, control phases/targets/safepoint.

Must-stay-green: SemaAuthority previous 242, ProductionCodeGen named rows (InitPlan 42, MemberRef 42, 0-arg, accessors, ArrayInt, overload CALL).

---

## 1. Goal

Sema-owned **overload / conversion / call / lifetime** facts that today only construction-API (or Parser-fail / Parse+Seal) tests cover must appear on:

```text
SetCompilerPipeline(CANONICAL)
  → AddScriptSection
  → SetASTRetentionPolicy(RETAIN)
  → Build()
  → GetCanonicalASTContext()
  → asCASTDump
```

Helper already on disk: `CanonicalASTSemaAuthorityTest::DumpSealedCanonicalAst` in
`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.

Do **not** treat `asCASTContext` + `asCSema.ActOn*` (no module `Build()`) as compile-seal.
Do **not** treat `Parser.ParseScript` + `Context.Seal()` (no `Build()`) as compile-seal.
Do **not** treat parse-fail mid-function dumps as compile-seal.

---

## 2. Bites (task order; one TDD cycle each)

Add tests to the **same** SemaAuthority file. Names must be unique. Use `ASTEST_AS` / `ASTEST_AS_ANSI`. Follow existing `DumpSealedCanonicalAst` tests (`CompileSealConversionDumpsNamedSrcAndDestTypes` ~9936).

### Bite 1 — Assign conversion on compile-seal

Construction-API only today: `SemaAssignActionInsertsNamedConversionWithoutScriptNode` (`float x` + int `3` dumps `kind=Conversion dest=float src=int`).

Call-arg conversion (`G(3)` with `G(float)`) is **already** compile-seal. Do **not** duplicate that.

Suggested source:

```angelscript
int Entry()
{
    float x = 3;
    return 1;
}
```

Assert a dump line with `kind=Conversion` and `dest=float` and `src=int`. `Build()==0`. Retain snapshot.

If this PASSes immediately: intern already happens on WalkOne assign. Record in the agent return. Do not change production code. Go to Bite 2.

### Bite 2 — Lambda capture on Build()+retain

Construction-API: `SemaLambdaCaptureActionRecordsCaptureWithoutCodeGenWalk`.
Parse+Seal only: `ParserCapturingLambdaRecordsCaptureOnSealedDump` (no `Build()`).
Execute already GREEN: `CanonicalCapturingLambdaBuildPublishesCodeGenAndExecutes`.

Suggested source (same as the parse-seal fixture):

```angelscript
int Entry()
{
    int X = 21;
    return function()
    {
        return X;
    }();
}
```

Assert `DECL` `name=<lambda>` has `captures=X`. Prefer also a Call line that lists `captures=X` if the dump already prints it on CALL (parse-seal test requires both).

If this PASSes immediately: capture is already on the retain path. Record. Do not change production code. Go to Bite 3.

### Bite 3 — Inner shadowed var on compile-seal

Construction-API only: `SemaDeclRefExprActionSelectsInnerVarNotGlobalWithoutScriptNode` (`Game::x` float vs global `x` int).

Namespace **function** overload is **already** compile-seal (`NamespaceOverloadSelectsScopedFunctionNotGlobal`). This bite is **variables**.

Suggested source:

```angelscript
int x = 1;

namespace Game
{
    float x = 2.0f;

    float F()
    {
        return x;
    }
}

int Entry()
{
    return 1;
}
```

Assert a `kind=DeclRef` with `type=float` (the inner `x`). Must not be the only DeclRef of `x` typed `int` inside `Game::F`. If dump does not print DeclRef type, assert `callee=` / resolved field that distinguishes inner float — match existing dump tokens; do not invent new dump syntax unless the GREEN requires a one-line dump token that already exists (`type=`).

If this PASSes immediately: record. Go to Bite 4.

Fork: mutable script globals are **rejected**. Use `const int x = 1` / `const float x = 2.0f` if `int x = 1` fails Build (see `ConstGlobalTraitAndMutableReject`).

### Bite 4 — Unary ++ successful Build()

Construction-API: `SemaUnaryExprActionSelectsOpPostIncWithoutScriptNode`.
Parse-**fail** only: `ParserActOnPostIncSelectsOpPostIncBeforeFunctionCloseFails`.
`opNeg` compile-seal already exists (`OperatorUnaryMinusSelectsOpNegNotBuiltinUnary`).

Suggested source:

```angelscript
struct T
{
    int opPostInc()
    {
        return 1;
    }
}

int Entry()
{
    T v;
    return v++;
}
```

VALUE `T v;` needs sibling Construct (dummy invent is deleted). If Build fail-closes `asNO_FUNCTION`, intern a 0-arg ctor on the struct **or** write `T v();` / give `T` a script ctor that returns via factory rules. Prefer the same VALUE-local pattern as other SemaAuthority struct tests that already `Build()==0`.

Assert dump `callee=T::opPostInc()` and **not** `callee=T::opPreInc()`.

If this PASSes immediately: record. Stop. Do not add a fifth bite in this mutex unless Bites 1–4 all passed immediately **and** you still have UBT time — then only `opPreInc` successful Build(), same pattern.

---

## 3. TDD protocol

For **each** bite:

1. Write the test. Do not edit fork sources first.
2. `RunBuild.ps1 -Label wave-b-seal-facts -NoXGE` if the test file changed (always after impl; first RED of a new test also needs a build).
3. `RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-seal-facts-red -TimeoutMs 600000`
4. Confirm the **new** method FAILs for the missing dump token (not a compile/crash). Previous 242 stay PASS.
5. If the new method PASSes: **do not implement**. Record “already on compile-seal”. Next bite.
6. If RED: minimal intern on Parser→Sema so `Build()` dump contains the token. Prefer extending existing `ActOnAssignExpr` / `ActOnLambdaCapture` / `ActOnDeclRefExpr` / `ActOnUnaryExpr` that construction-API already uses — wire them on the parse/`WalkOne` path, do not add a second Sema.
7. Re-run SemaAuthority until GREEN including the new test.
8. Next bite.

After all bites:

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-seal-facts -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-seal-facts-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-seal-facts-canonicalast -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-seal-facts-compiler -TimeoutMs 600000
```

Copy reports to `C:\Users\scottmei\AppData\Local\Temp\grok-goal-cafa12c46849\implementer\` if that scratch exists.

If CanonicalAST fails on **already-on-disk ABI-width** ProductionCodeGen rows (`CanonicalGeneratedInt64AccessorUsesRdr8NotRdr4` etc.) that you did not touch: **stop**. Record the failure. Do **not** implement ABI width under this mutex.

---

## 4. Hard no

- Do not check 13.2 / 13.3 / 4.2 / 5.4 / 5.5 / 5.6 / 5.9 / 9.5.
- Do not start Wave E–G. CompileFunction stays mixed COMPILER.
- Do not restore `GetFirstProperty`, dummy CONSTRUCT, `FindConstructorId(0)` / `FindFactoryId(0)`.
- Do not globally full-span `FindExistingExpr` / `FindExistingStmt`.
- Do not diagnose parser-range class-member / for-init as `unresolved-identifier:`.
- Do not invent stmt-level cleanup-plan POD.
- Do not intern script `funcdef` / `@` / `is` / try-catch.
- Do not edit `as_compiler.cpp` LEGACY path except if a compile error forces a signature — prefer not to.
- One UBT. `-NoXGE`. Worktree `D:\as-cta` only.
- `as_bytecode_codegen.cpp` often `??`. If UBT says up to date after codegen/sema edits, delete Runtime DLL + `Module.AngelscriptRuntime.44.cpp.obj` (codegen `.44`; sema_expr `.49`; dump `.43`; context `.42`; sema `.48`).

---

## 5. Why this is not 13.2

Even if all four dumps GREEN on `Build()`+retain:

- LEGACY default still `asCCompiler`.
- intern-time `symbols` / `controlStack` / `FindBestCallee` still die with Sema.
- `FindExistingStmt` still kind+begin.
- Parser still `asCScriptNode` recovery.
- Script field offsets still Generate-local.
- Fixture dump tokens are not sealed candidate/conversion/lifetime **plans**.

**Do not check 13.2.**
