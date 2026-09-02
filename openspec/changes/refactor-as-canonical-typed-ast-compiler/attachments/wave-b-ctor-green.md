# Wave B exclusive UBT — F2 Phase B ctor / factory / opIndex exact bind

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-ctor-green**. **This is the exclusive UBT now.**
Companions: `async-work.md`, `async-dispatch.md`, `wave-b-ninth-f2-exact-binding.md` §2.4–2.5 / §4.3 methods 3–5.
Phase A map (done, do not redo): `wave-b-tenth-f2-wire.md`.

This bite is **not** a 9.4 / 13.2 / 5.4 / 5.5 / 4.2 close. Do not check those boxes.

LLVM/Clang is a **shape** reference only. Do not link. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Exclusive UBT TDD GREEN of already-written ctor/factory/opIndex tests |
| Gate | Phase A Method+Member GREEN `wave-b-ninth-f2-prod-g` **35/35**, SemaAuthority **239/239** |
| Do not mark | **any remaining OpenSpec box** |

---

## 0. Already true — do not redo Phase A

Landed and last fully green:

- `FindExactRegisteredMethod` wired; `EmitCall` name+arity **deleted**.
- Native METHOD miss skips `asNEW` (`continue`), does not fail whole Generate.
- Unique match prefers instance over template-base.
- Tests save `RegisterObjectMethod` ids.
- ProductionCodeGen **35/35** `wave-b-ninth-f2-prod-g`. SemaAuthority **239/239** `wave-b-ninth-f2-sema`.

Must-stay-green: `CanonicalArrayIntBuildPublishesCodeGenAndExecutes`, script overload, generated accessors, FValue, import CALLBND, Method execute 42, Member execute 42.

---

## 1. Live problem (Phase B, in the tree, last run AV)

RED tests **already exist** in `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`:

| Method | Contract |
| --- | --- |
| `CanonicalNativeSameArityConstructorExecutesSelectedNotFirstRegistered` | VALUE `FBindCtor` poison `void f(bool)` FIRST, `void f(int)` SECOND, `b(3)` execute **42**, CALLSYS int not bool. Flags: `asOBJ_VALUE\|POD\|APP_CLASS\|CONSTRUCTOR\|MORE_CONSTRUCTORS`. Poison helper is `ProdBindBoxConstructFloatPoison` (sets Stored=0) — **do not** re-register float (ALLINTS + float failed). |
| `CanonicalNativeSameArityFactoryExecutesSelectedNotFirstRegistered` | REF `FBindHost` NOCOUNT IMPLICIT_HANDLE, poison factory(bool) FIRST, factory(int) SECOND, `h(3)` execute **42**. |
| `CanonicalNativeSameArityIndexExecutesSelectedNotFirstRegistered` | array + poison `opIndex(bool)` FIRST then `opIndex(uint)`; execute 42, CALLSYS uint not bool. |

Implementation already in source (untested after last intern patch):

- Sema `InternNativeCallablesForType` → `InternNativeBehaviourList` (ctors/factories as `DECL_CONSTRUCTOR`, skip hidden/template first param). **Not** called from `InternNativeMethods`.
- `ActOnConstruct` interns **only if** `args.GetLength() > 0` (`as_sema.cpp:1025-1028`). **This is the last untested patch.** Previous intern-on-every-construct pulled `array<T>` factory into binds and AV'd `CanonicalArrayInt` (`CallSystemFunction` read 0x38 / write 0x00000003000002a6).
- `ActOnIndexExpr` already `InternNativeMethods(..., "opIndex")` then `FindBestCallee`.
- CodeGen `FindExactRegisteredConstructor` after `FindExactRegisteredMethod` in emitDecls.
- Native METHOD/CONSTRUCTOR no body not GENERATED → `continue` (no `asNEW`).
- `FindFunc` returns 0 if `!decl.IsValid()`.
- Dummy VALUE `STMT_DECL` construct: `resolvedDecl = asASTDeclId()` (`:2701-2704`).
- 0-arg dummy **still** `FindConstructorId(0)` / `FindFactoryId(0)` (`:2007-2020`). **Keep this until 0-arg intern is a separate bite.**
- REF SYSTEM `!isValue` treated as factory (CALLSYS + STOREOBJ) (`:2000-2006`, `:2027-2048`).
- `EmitIndex` FindFunc then **first-opIndex fallback** (`:2208-2227`). Exact opIndex is **after** ctor/factory GREEN.

Last evidence: `wave-b-ninth-f2-ctor-g13` ProcessExitCode 3 AV **before** intern-only-if-args>0. Earlier non-crash RED `wave-b-ninth-f2-ctor-g7` 33/38 (ArrayInt + Constructor + Factory + Index + Method).

Do **not** intern 0-arg in this mutex. Do **not** call `InternNativeCallablesForType` from `InternNativeMethods`. Do **not** restore `asCExpr` dummy without zeroing `resolvedDecl` (`asCExpr()` does **not** zero it — garbage DeclId hits a bind).

---

## 2. Task order (TDD, this mutex)

### 2.1 Force Runtime rebuild, then observe

`as_bytecode_codegen.cpp` is often plugin git `??`. Adaptive UBT skips it.

```powershell
Set-Location D:\as-cta
Remove-Item -Force -ErrorAction SilentlyContinue `
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.44.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.48.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.49.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptRuntime.dll
.\Tools\RunBuild.ps1 -Label wave-b-ninth-f2-ctor-g14 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-ninth-f2-ctor-g14 -TimeoutMs 600000
```

CQTest class name is in the path — **do not** use `...ProductionCodeGen.CanonicalNativeSameArity` (matches nothing). Use the full `...ProductionCodeGen` prefix.

Confirm no `UnrealBuildTool` / `UnrealEditor` with `D:\as-cta` before UBT. CAEngine `UE4Editor`/`MSBuild`/`link` is **not** this lock.

Expected after intern-only-args>0:

- ArrayInt / Method / Member GREEN again (0-arg array default uses `FindFactoryId(0)`, not interned factory).
- Constructor / Factory: execute **42** and selected CALLSYS if intern+`FindExactRegisteredConstructor` unique-match works.
- Index may still luck-GREEN via first-opIndex; treat as **not done**.

If ArrayInt AV again: **stop guessing intern**. Root causes already known: interned factory in binds, dummy garbage DeclId, VALUE ctor path on REF factory. Fix the specific one with evidence. Do not intern 0-arg to “make dummy exact”.

If ctor registration fails: keep bool poison + `MORE_CONSTRUCTORS`. Do not go back to float + `ALLINTS`.

If factory execute 0 or AV: confirm `SYSTEM && !isValue` → factory STOREOBJ; confirm SelectConstructor interned the int factory as `DECL_CONSTRUCTOR` with user arity 1 (hidden type-id skipped); confirm unique `FindExactRegisteredConstructor`.

### 2.2 After ctor/factory execute 42 — delete 1-arg arity walks only

Keep:

```text
expr->children.GetLength() == 0  → FindConstructorId(0) / FindFactoryId(0)
```

Delete any remaining 1-arg `FindConstructorId(argCount)` / `FindFactoryId(userArgCount)` if they still exist outside that 0-arg guard (live source already only 0-arg — confirm with grep, do not reintroduce).

1-arg miss → `asNO_FUNCTION`, not first-arity.

### 2.3 Exact opIndex (same mutex only if 2.1 ctor/factory GREEN and ArrayInt GREEN)

`ActOnIndexExpr` already interns `opIndex`. Make `EmitIndex` **FindFunc-only**: delete `:2210-2227` first-`opIndex` / templateBaseType walk.

Poison `opIndex(bool)` registered FIRST must not win. Index test execute 42 + CALLSYS uint id.

If FindFunc-only AVs array/method again: **restore the fallback**, stop, leave Index RED. Do not intern extra factories to paper over a bind miss.

### 2.4 Stop. Do not start InitPlan / Verifier / ABI / Wave E

No `atoi` rewrite. No `asCDecl.inits`. No `asCASTVerify` CALL-without-callee. No 0-arg intern bite (research package `wave-b-ctor-zeroarg-next.md` owns that design).

Optional same mutex only if 2.1–2.3 all GREEN and time remains: Frontend fail-closed `CanonicalNativeBindMissFailsClosedDoesNotCallFirstArity` from `wave-b-ninth-f2-exact-binding.md` §4.3 method 5. **Skip if anything in 2.1–2.3 is still RED.**

---

## 3. GREEN contract

| Prefix | Label | Pass |
| --- | --- | --- |
| ProductionCodeGen | `wave-b-ninth-f2-ctor-g14` (then `-g15` if more impl) | All named rows + Method/Member 42 + Constructor 42 CALLSYS int + Factory 42 CALLSYS int. Index 42 CALLSYS uint **if** 2.3 landed; else Index may still be fallback |
| SemaAuthority | `wave-b-ninth-f2-sema` | **239/239** after any Sema edit |

Do not weaken dump `callee=` asserts. Dump `callee=` is Sema `stableKey`, not CALLSYS id — execute + `ProdBytecodeCallsFunction` is the contract.

---

## 4. Hard nos

- Second UBT. New worktree. Wave E–G. Archive. Commit unless asked
- Check 13.2 / 4.2 / 5.4 / 5.5 / 5.6 / 9.5 / 9.4 / 13.5
- Intern 0-arg `ActOnConstruct` / `InternNativeCallablesForType` from `InternNativeMethods`
- Leave dummy `asCExpr` `resolvedDecl` uninitialized
- Delete 0-arg `FindConstructorId(0)` / `FindFactoryId(0)` this mutex
- Store `asCScriptFunction*` on sealed `asCDecl`
- Restore `EmitCall` name+arity
- Require CALL-without-callee on unsealed `asCASTVerify`
- Script `funcdef` / `@` / `is` / `dictionary`
- Default CANONICAL. CANONICAL `CompileFunction`
- Globally full-span `FindExistingExpr`
- Mix InitPlan `atoi`, Verifier firewall, ABI width
- Edit `async-work.md` / `async-dispatch.md` / `tasks.md` checkboxes
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`
- Prefix `...ProductionCodeGen.CanonicalNativeSameArity` (matches 0 tests)

---

## 5. Done when

Constructor + Factory execute selected not first-registered; ArrayInt/Method/Member still 42; 1-arg arity walks gone; 0-arg dummy still arity fallback; SemaAuthority 239.

Index FindFunc-only GREEN is in-scope if 2.1 is GREEN; otherwise leave first-opIndex and say so.

Still **not** done: 13.2, 9.4 checkbox, typed InitPlan, 0-arg intern, ABI width, Verifier 13.5, Wave E–G.
