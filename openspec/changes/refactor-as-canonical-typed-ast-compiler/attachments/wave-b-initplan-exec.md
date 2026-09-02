# Wave B exclusive UBT — InitPlan execute 42 (local STMT_DECL + sibling Construct)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-initplan-exec**. **This is the exclusive UBT now.**
Companions: `async-work.md`, `async-dispatch.md`, `wave-b-initplan-next.md` (dump bite, **landed**).

This bite is **not** a 5.4 / 5.7 / 5.8 / 13.2 / 9.5 close. Do not check those boxes.

LLVM/Clang is a **shape** reference only. Do not link. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Exclusive UBT. Systematic debug then **one** hypothesis fix. TDD test already exists and is RED (got=0) |
| Gate | InitPlan dump GREEN SemaAuthority **240/240**. F2 Phase A+B ProductionCodeGen was **38/38** before this method |
| Do not mark | **any remaining OpenSpec box** |

---

## 0. Already true — do not redo

Landed:

- Sema `asCDecl::inits` + `asCASTContext::AddDeclInit`
- `AttachConstructorMemberInits` on every `DECL_CONSTRUCTOR` (user and generated); no `SetBody` overwrite
- Dump `init=` on Constructor DECL; test `UserCtorMemberDefaultFortyPlusOneRecordsTypedAssignBeforeBodyOnCompileSealPath` GREEN
- CodeGen `Emit()` emits `decl->inits` then body; **`EmitConstructorMemberDefaults` atoi deleted**
- F2 exact native METHOD/ctor/factory/opIndex CALLSYS. `RankArgument` integer-to-integer rank 1. `EmitIndex` FindFunc-only
- Dummy VALUE `STMT_DECL` skips if `HasConstructAssignTo`; else `resolvedDecl = FindInternedZeroArgConstructor`
- Generated Get inlining **only when `FindFunc` misses** (always-inline was tried and **reverted** — broke accessors, still got=0)

Must-stay-green: ProductionCodeGen named rows including array/method/member/ctor/factory/index 42, generated accessors (CALL, not always-inline), `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes`, Isolated **4/4**, Semantics **12/12**, SemaAuthority **240/240**.

---

## 1. Live problem

Test already exists: `CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody`

```angelscript
struct FValue
{
    int Value = 40 + 1;
    FValue() { Value = Value + 1; }
}
int Entry()
{
    FValue Object;
    return Object.Value;
}
```

| Oracle | Status |
| --- | --- |
| Dump: ctor `init=` Assign of interned `40+1`, body still `Value=Value+1` | **GREEN** 240/240 |
| Execute: `Entry()` **42**, publisher `CANONICAL_CODEGEN` | **RED got=0** |
| Isolated `FValue().Value+1` (user ctor Trace-only, atoi era) | GREEN 12/12 |
| Generated `FValue Object; return Object.Value+1` (`Value=41`, no user ctor) | GREEN |

RED is **not** atoi-40 (that predicts **41**). got=0 means the object `Entry` later reads was **never written** (or was reconstructed empty). Dump GREEN only proves the user-ctor **function** has a typed plan, not that Entry CALL hits that function, and not that `this` writes `Object` at objvar pos=1.

Three tactical fixes already failed (do **not** retry):

1. Skip dummy if sibling Construct — still 0
2. Always-inline generated Get even when FindFunc hits — still 0, **and** broke two accessor tests (**reverted in tree, `.44` may be stale**)
3. Dummy `FindInternedZeroArgConstructor` — still 0 (dummy is skipped when sibling exists)

Phase 4.5: stop stacking CodeGen tactics. Prove **which CALL** Entry emits, then one fix.

---

## 2. Hypotheses — one at a time

### H1 (try first) — Entry CALL is not the user ctor

`FValue Object;` → `EmitLocalDeclStmts` → `AppendDefaultValueConstruct` → `ActOnConstruct` **0-arg** (`as_sema_stmt.cpp:90-105`).

`ActOnConstruct` intern-native only if `args.GetLength() > 0`. `SelectConstructor` still runs for 0-arg (`as_sema.cpp:1023-1078`). If it misses, `resolvedDecl` is invalid.

`HasConstructAssignTo` (`as_bytecode_codegen.cpp:2751+`) is true for **any** sibling Assign-to-var whose RHS unwraps to CONSTRUCT — **it does not require `resolvedDecl`**. Dummy (the only path that calls `FindInternedZeroArgConstructor`) is then **skipped**.

`EmitConstructInto` on invalid resolvedDecl: `FindFunc` miss → `FindConstructorId(0)` (`:561-603`) returns the **first** `asFUNC_SCRIPT` 0-arg in `beh.constructors`.

`RegisterCanonicalScriptTypes` copies `st->beh = engine->scriptTypeBehaviours.beh` (`:3036`). `FillFunctionSignature` then overwrites `beh.construct` and `constructors[0]` **only when that ctor is asNEW'd** (`:3160-3170`). Inherited empty construct can remain first if overwrite misses, or Entry can CALL a different id than the dumped user ctor.

`FindExactRegisteredConstructor` **returns 0 when `decl->body.IsValid()`** (`:245`) — user ctor is asNEW, should be in `binds`. If sibling Construct's `resolvedDecl` is empty, that bind is never used.

**Minimal proof (add to the existing execute test, do not weaken `Value==42`):**

- Capture `Ctor->GetId()` from the first `asBEHAVE_CONSTRUCT` already walked
- Assert Entry bytecode `CALL`/`CALLSYS` target id **equals** that ctor id (reuse `ProdBytecodeCallsFunction` / dump text)
- If mismatch: H1 confirmed. Fix: CodeGen `EmitConstructInto` for 0-arg **script VALUE** must `FindFunc` of Sema `resolvedDecl` or `FindInternedZeroArgConstructor` **before** `FindConstructorId(0)`. Prefer making dummy-skip require `resolvedDecl.IsValid()`. Do **not** intern native 0-arg / `array<T>` factories. Do **not** delete `FindConstructorId(0)` for native SYSTEM 0-arg yet (ArrayInt).
- If ids **match**: H1 false. Do not apply that fix. Go to H2.

### H2 — user ctor `this` does not write objvar pos=1

VM: `asBC_PSF` pushes `l_fp - offset` (`as_context.cpp:1943-1946`). `RDSPtr` reads a pointer from that address (null → exception, not 0). `WRTV4` writes through `valueRegister`.

CodeGen: `thisOffset = 0` (`:692-693`). `PushThisObject` = `PSF 0` + `RDSPtr` (`:1010-1014`). asCCompiler member-through-this is `PSF 0` then `Dereference` then `ADDSi` (`as_compiler.cpp:14806-14816`) — same shape. Generated accessors GREEN on this path.

Ctor bytecode (last RED dump): `SetV4, PSF, RDSPtr, ADDSi, PopRPtr, WRTV4` then body load `CpyRtoV8/PshVPtr/RDR4, SetV4, ADDi, WRTV4`. Body `Value+1` on a 0-read would yield **1**, not 0. **got=0 ⇒ writes miss the object GetValue later reads**, or the called function is not this bytecode (H1).

If H1 ids match: compare **generated** default-ctor bytecode (GREEN local `FValue Object`) vs this user ctor, instruction by instruction. Fix the **delta only**. Do not change `thisOffset` to `-AS_PTR_SIZE` without evidence (`BindParameters` already starts params at `-AS_PTR_SIZE`; `this` is `fp[0]`).

### H3 — Entry return / GetValue / BindParameters slot alias

Only if H1 and H2 are false. `BindParameters` pre-`AllocTyped`s function `DECL_VAR` children (`:1262-1266`) so `STMT_DECL` may skip. `returnSlot` is allocated after that (`:706-720`). Dump said objvar pos=1. Prove `Object` slot vs `returnSlot` vs GetValue dest. Do not restore always-inline Get.

---

## 3. Task order this mutex

1. Force Runtime rebuild (Get-inline revert may not be in `.44`). Confirm accessors GREEN again; InitPlan execute still 0; capture ctor/entry dumps.
2. Add the CALL-id oracle to the existing execute test (still require `Value==42`). Rebuild + run **that method** then full ProductionCodeGen prefix.
3. Apply **one** H1 or H2 fix from evidence. Rebuild + full ProductionCodeGen.
4. If GREEN 39/39: run SemaAuthority 240/240. **Stop.** Do not start ABI width / Verifier 13.5 / 0-arg native intern / Wave E.
5. If still RED after one evidence-based fix: **stop**. Write the new evidence into this file. Do not apply fix #2 in the same mutex.

---

## 4. GREEN contract

| Prefix | Label | Pass |
| --- | --- | --- |
| ProductionCodeGen | `wave-b-initplan-exec-g2` | All prior named rows **plus** user-ctor execute **42**. Accessors GREEN (not always-inline). Generated default ctor still 42 |
| SemaAuthority | `wave-b-initplan-sema` | **240/240** after any Sema edit (skip if CodeGen-only) |

Do not weaken dump `init=` / `literal=40` / body Assign. Do not accept 41. Do not accept Isolated-style luck.

---

## 5. Commands (only these, from `D:\as-cta`)

`as_bytecode_codegen.cpp` is often plugin git `??`. Adaptive UBT skips it. Delete Runtime DLL + `.44` (codegen) before every rebuild after impl.

```powershell
Set-Location D:\as-cta
Remove-Item -Force -ErrorAction SilentlyContinue `
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.44.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptRuntime.dll
.\Tools\RunBuild.ps1 -Label wave-b-initplan-exec-g2 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-initplan-exec-g2 -TimeoutMs 600000
```

CQTest class name is in the path — **do not** use `...ProductionCodeGen.CanonicalUserCtor` (may match 0). Use the full `...ProductionCodeGen` prefix.

`RunTests.ps1` does **not** UBT. Always `RunBuild.ps1` first after impl.

Confirm no `UnrealBuildTool` / `UnrealEditor` with `D:\as-cta` before UBT. CAEngine `UE4Editor`/`MSBuild`/`link` is **not** this lock.

---

## 6. Hard nos

- Second UBT in `D:\as-cta`. New worktree. Wave E–G. Archive. Commit unless asked
- Check 13.2 / 13.3 / 4.2 / 5.4 / 5.5 / 5.6 / 5.7 / 5.8 / 9.5. Silent uncheck of 9.2 / 9.4 / 13.5
- Restore generated-Get always-inline
- Expand `atoi` / `strtoll` / `IntegerInitText` so `40+1` becomes 41
- Hand-write `Value = 41` (or `40+1`) in the user ctor
- Intern native 0-arg / call `InternNativeCallablesForType` from `InternNativeMethods` / intern-on-every-construct
- Delete 0-arg `FindFactoryId(0)` this mutex (ArrayInt)
- Store `asCScriptFunction*` on sealed `asCDecl`
- Require CALL-without-callee on unsealed `asCASTVerify`
- Change `thisOffset` to `-AS_PTR_SIZE` without H2 evidence
- Script `funcdef` / `@` / `is` / `dictionary`. Default CANONICAL. CANONICAL `CompileFunction`
- Globally full-span `FindExistingExpr`. Mix ABI width / Verifier 13.5
- Edit `async-work.md` / `async-dispatch.md` / `tasks.md` checkboxes
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`

---

## 7. Done when

`CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody` returns **42** on the local `STMT_DECL` + sibling Construct / GetValue path, no atoi, accessors still GREEN, generated default ctor still GREEN, ProductionCodeGen full prefix GREEN.

Still **not** done: 13.2, 5.4, 5.7/5.8, 9.5, native 0-arg intern, ABI width, Verifier 13.5, Wave E–G.
