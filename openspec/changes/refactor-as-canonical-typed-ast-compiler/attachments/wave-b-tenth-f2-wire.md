# Wave B exclusive UBT — tenth-pass F2 exact Runtime bind (wire `FindExactRegisteredMethod`)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-tenth-f2-wire**. **This is the exclusive UBT now.**
Design map (do not re-research): `wave-b-ninth-f2-exact-binding.md`.
Companions: `async-work.md`, `async-dispatch.md`.

This bite is **not** a 9.4 / 13.2 / 5.4 / 5.5 close. Do not check those boxes.

LLVM/Clang is a **shape** reference only. Do not link. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Exclusive UBT TDD GREEN of already-RED Method+Member tests |
| Gate | Isolated traces GREEN. 5.5 dump locks GREEN. Mutex free |
| Do not mark | **any remaining OpenSpec box** |

---

## 0. Already true — do not redo

- `FindExactRegisteredMethod` is in `as_bytecode_codegen.cpp` **:96–213** (unique match on name + substituted return/param token/typeinfo/ref/handle + inOut). **Not called.**
- RED tests exist in `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`:
  - `CanonicalNativeSameArityMethodExecutesSelectedNotFirstRegistered` (~1070)
  - `CanonicalNativeSameArityMemberExecutesSelectedNotFirstRegistered` (~1170)
- Evidence `wave-b-ninth-f2-red-exec` **0/2**:
  - Method: `Build()!=0`; dump already `callee=array<int>::insertLast(const int&in)` (Sema selected; Generate dropped interned METHOD)
  - Member: Build succeeded; `GetMethodByDecl("int Get(int)")` null — **test helper**, not execute-0 yet
- Helpers `ProdCanonicalArrayInsertLastBoolPoison`, `FProdBindBox`, `ProdBindBoxGetBoolPoison`, `ProdBindBoxGetInt`, `ProdBindBoxConstruct` already exist
- Must-stay-green named ProductionCodeGen rows (array single-overload, script overload, generated accessors, FValue, import) stay as-is

---

## 1. Root cause (do not invent a second one)

Collect (`Generate` ~3141–3148):

```text
body.IsValid()
|| kind == FUNCTION
|| kind == CONSTRUCTOR
|| (kind == METHOD && TRAIT_GENERATED)
|| kind == DESTRUCTOR
```

Interned native METHOD (`InternNativeMethods`): no body, not GENERATED → **excluded** → never `binds.PushLast` → `FindFunc` miss → `EmitCall` `FindMethodUntil` first same-arity SYSTEM.

`CanonicalDeclIsFunctionLike` already includes METHOD. The extra GENERATED filter is the miss.

---

## 2. Phase A (must finish this mutex)

### 2.1 Collect

In the `functionDecls` loop, also push interned native METHOD:

```text
|| (kind == METHOD && !body && not GENERATED)
```

Keep generated methods and script bodies on the existing path (they still `asNEW` + emit).

### 2.2 Bind before `asNEW`

In the `emitDecls` loop, **immediately after** `FindRegisteredGlobalFunction` succeeds-or-not, **before** `asNEW asCScriptFunction`:

```cpp
if( asCScriptFunction* hostMethod = FindExactRegisteredMethod(engine, bridge, context, decl) )
{
    asSCodeGenFuncBind bind;
    bind.decl = decl->id;
    bind.func = hostMethod;
    bind.captureBegin = 0;
    bind.captureCount = 0;
    binds.PushLast(bind);
    continue;   // do not asNEW a script function for a SYSTEM method
}
```

If `decl->kind == METHOD` and `!decl->body.IsValid()` and not GENERATED and `FindExactRegisteredMethod` returns 0:

```cpp
failed = true;
error = asNO_FUNCTION;
// Abandon + DiscardAllocatedGlobals + return error
```

Do **not** fall through to `asNEW` for a native METHOD. That would publish a fake SCRIPT function.

### 2.3 Delete EmitCall name+arity

Delete the `FindMethodUntil` block at live `:2288-2305` (the `for (search = objType; ... templateBaseType)` arity walk).

After `FindFunc` miss, generated-Get inlining (`:2228-2262`) may stay for this bite if generated methods remain in `functionDecls` and `FindFunc` hits — do not expand property inlining.

Change bind-miss `FailAt(__LINE__, asNO_MODULE)` at `:2311` to `asNO_FUNCTION` when the miss is an unresolved CALL (native METHOD not in table). Keep `asNO_MODULE` only for real module/import absence if that path is distinct.

### 2.4 Member test helper

In `CanonicalNativeSameArityMemberExecutesSelectedNotFirstRegistered`, save the function pointer/id at `RegisterObjectMethod` time:

```cpp
const int BoolGetId = ScriptEngine->RegisterObjectMethod(... "int Get(bool)" ...);
const int IntGetId  = ScriptEngine->RegisterObjectMethod(... "int Get(int)" ...);
// later: GetFunctionById / engine->GetFunctionById
```

Do not `GetMethodByDecl("int Get(int)")` after Build. That lookup was null on RED.

Same pattern is fine for Method test (array `GetMethodByDecl` after instantiate **did** work on RED — keep if still non-null; if not, save registration ids / instantiate-template method ids another way).

### 2.5 Force Runtime rebuild

`as_bytecode_codegen.cpp` is often plugin git `??` untracked. Adaptive UBT can skip it.

Before `RunBuild.ps1`, if the previous build said up-to-date after a codegen edit:

```powershell
Remove-Item -Force -ErrorAction SilentlyContinue `
  D:\as-cta\Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptRuntime.dll
Get-ChildItem D:\as-cta\Plugins\Angelscript\Intermediate -Recurse -Filter "Module.AngelscriptRuntime*.obj" |
  Remove-Item -Force
```

Then:

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-ninth-f2-bind -NoXGE -TimeoutMs 1800000
```

Always `-NoXGE`. `RunTests.ps1` does **not** UBT — never test against a failed or skipped rebuild.

Confirm no `UnrealBuildTool` / `UnrealEditor` with `D:\as-cta` before UBT. CAEngine `UE4Editor`/`MSBuild`/`link` is **not** this lock.

### 2.6 Verify Phase A

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.CanonicalNativeSameArity" -Label wave-b-ninth-f2-prod-g -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-ninth-f2-prod-all -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-ninth-f2-sema -TimeoutMs 600000
```

GREEN contract:

- Method: `Build()==0`, publisher `CANONICAL_CODEGEN`, execute **42** (poison is **1**), CALLSYS int insertLast not bool
- Member: execute **42** (poison is **0**), CALLSYS `Get(int)` not `Get(bool)`
- Must-stay-green: `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` still 42; script `F(int)` vs `F(float)` still selected; generated accessors; FValue construct; import CALLBND

Do not weaken dump `callee=` asserts. Do not check OpenSpec boxes.

---

## 3. Phase B (same mutex only if Phase A is GREEN)

Add tests 3–5 from `wave-b-ninth-f2-exact-binding.md` §4.3 (ctor / factory / construction-API fail-closed). Intern native constructors/factories/`opIndex` the same way as methods (Generate-local bind; **no** `asCScriptFunction*` on `asCDecl`). Delete `FindConstructorId` / `FindFactoryId` fallbacks in `EmitConstructInto` and first-`opIndex` in `EmitIndex`. Dummy VALUE `STMT_DECL` construct binds interned 0-arg ctor already in `binds`.

If Phase A is still RED or rebuild is long, **stop after Phase A**. Do not start InitPlan / Verifier / ABI / Wave E.

Frontend fail-closed method lives in `AngelscriptNativeCanonicalASTCodeGenTests.cpp`. Prefix:

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label wave-b-ninth-f2-codegen -TimeoutMs 600000
```

---

## 4. Hard nos

- Second UBT. New worktree. Wave E–G. Archive. Commit unless asked
- Check 13.2 / 5.5 / 5.6 / 5.4 / 4.2 / 9.5 / 9.4 / 13.5
- Store live function pointers on sealed AST
- Keep `FindMethodUntil` name+arity after Phase A “just in case”
- Require CALL-without-callee on unsealed `asCASTVerify`
- Script `funcdef` / `@` / `is` / `dictionary`
- Default CANONICAL. CANONICAL `CompileFunction`
- Globally full-span `FindExistingExpr`
- Mix leftover FromNode, returnSlot, 5.5 dump tests, InitPlan `atoi` rewrite, Verifier firewall
- Edit `async-work.md` / `async-dispatch.md` / `tasks.md` checkboxes
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`

---

## 5. Done when

Phase A: Method+Member execute selected not first-registered; ProductionCodeGen prefix not regressing named rows; SemaAuthority still 239; `FindMethodUntil` arity walk gone from `EmitCall`; native METHOD miss is `asNO_FUNCTION`.

Still **not** done: 13.2, 9.4 checkbox, ctor/factory/opIndex if Phase B skipped, typed InitPlan, ABI width, Verifier 13.5.
