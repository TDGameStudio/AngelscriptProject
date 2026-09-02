# Exclusive UBT — remaining 5.4 traces (returnSlot / property RunLocal / VALUE temp)

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
**Exclusive UBT now.** TDD. One UBT user. Do **not** check `tasks.md` 5.4 / 13.2 / 4.2 / 5.6 / 9.5.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM.

Companions: `async-work.md`, `async-dispatch.md`, `wave-b-54-traces-already-green.md` (Logical/Conditional map — **landed GREEN**), `wave-b-54-opaque-next.md` (**landed GREEN**).

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Package | **B-54-traces-remain** |
| Mode | Exclusive UBT. Tests already RED. Systematic-debug then minimal CodeGen fix. |
| Gate | Index mutation GREEN. Isolated Logical/Conditional GREEN. CANONICAL-only `Make().Value += 1` GREEN. |
| Do not mark | **5.4 / 13.2 / 4.2 / 9.5 / 5.6** |

---

## File map

| File | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | Fix returnSlot vs DestroyLiveObjects / generated accessor / VALUE temp. Keep the returnSlot idea (dtor CALL clobbers valueRegister). |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp` | **Do not add methods.** Do not weaken IsolatedProperty / IsolatedValueTemporary asserts. Do not retcon `RunSingleEval`. |
| Sema / Parser / module / dump / verifier | **Do not edit** unless a dump proves the RED is intern, not CodeGen. Current REDs execute after `Build()==0`. |

Do **not** edit `as_sema.cpp` / `as_sema_expr.cpp` for this bite. Do **not** globally full-span `FindExistingExpr`. Do **not** add `EmitDeclRef` literal fallback. Do **not** invent stmt-level cleanup-plan POD.

---

## Already GREEN (do not redo, do not regress)

| Method | Evidence |
| --- | --- |
| `CanonicalIndexCompoundAssignEvaluatesMakeOnce` | Trace `"1,2"` `wave-b-54-opaque-idxmemo` **2/2** |
| `CanonicalIndexCompoundAssignWritesThroughLocal` | result 42 |
| `IsolatedLogicalShortCircuitMatchesLegacyCanonicalTrace` | Success `wave-b-54-traces-iso` |
| `IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace` | Success `wave-b-54-traces-iso` |
| `CanonicalPropertyCompoundAssignEvaluatesMakeOnce` | `"1,2,3"` `wave-b-54-traces-prop` **1/1** (CANONICAL-only `.Value += 1`) |
| IndexCompoundAssign `Build()==0` | SemaAuthority **236/236** `wave-b-54-opaque-sema` |

---

## Live RED (this bite)

### 1. IsolatedProperty CANONICAL `RunLocal`

Test: `IsolatedPropertyCompoundAssignMatchesLegacyCanonicalTrace` (`AngelscriptNativeCanonicalASTVmMatrixTests.cpp:683-794`).

Shared source uses **explicit** `GetValue`/`SetValue` and `T v = T()` because LEGACY `ep.propertyAccessorMode == 0` — `.Value` Get/Set rewrite is CANONICAL-only.

```as
int RunLocal()
{
	T v = T();
	v.SetValue(v.GetValue() + 1);
	return v.Stored;
}
```

`wave-b-54-traces-iso` (`20260822_173825_043_58158db8`):

- LEGACY `RunBoth` passed (or the method would have failed earlier).
- CANONICAL `RunMake` passed (`result 1`, Trace `"1,2,3"`).
- CANONICAL `RunLocal` **Fail**: `CANONICAL RunLocal Stored after += 1` line 745. Expected 42. Actual not printed (AreEqual default). Execute returned true.

This appeared **after** returnSlot (`Emit()` `:346-361`, `STMT_RETURN` `:2308-2326`, epilogue `:378-383`).

### 2. IsolatedValueTemporary CANONICAL

Test: `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` (`:597-681`).

```as
struct FValue { int Value = 41; FValue(){ Trace(1); } ~FValue(){ Trace(2); } }
int Entry() { return FValue().Value + 1; }
```

| Run | Result |
| --- | --- |
| `wave-b-54-traces-temp` **before** returnSlot | Fail `CANONICAL FValue().Value+1 got=0` line 631. No AV. |
| `wave-b-54-traces-iso` **after** returnSlot | Alphabetical order ran Property first (Fail), then this method **Fatal** AV `0xffffffffffffffff` in mimalloc/`FString` at then-line 643 (`FString::Printf` in `RunOnce` after execute). Crash snapshot path in log: `Saved/Angelscript/CrashSnapshots/98032_20260822_173857_258/` |

got=0 before returnSlot matches: epilogue `DestroyLiveObjects` CALLSYS/CALL of `~FValue` clobbers valueRegister, then `Ret` without reload.

AV after returnSlot means the copy-then-destroy path smashed the heap (slot alias / bad `this` / FREE of a live object), then the assert `FString` exploded. Do not treat the AV as “the assert is wrong”.

---

## Hypotheses (check in this order)

Keep returnSlot. The VALUE-temp `got=0` proved dtor clobbers the register. The fix is **which slot is copied, and that Destroy does not destroy that slot**.

### H1 — generated getter already `LoadReturn`s, epilogue overwrites with unwritten returnSlot

`EmitGeneratedAccessor` Get (`:688-696`) does `LoadReturn(dest)` then returns. `Emit()` still always:

```text
Label(0); DestroyLiveObjects(); if (returnSlot valid) LoadReturn(returnSlot); Ret
```

Generated getters have **no** `STMT_RETURN`, so `CopyVar(returnSlot, …)` never runs. `returnSlot` stays uninitialized. Eilogue `LoadReturn(returnSlot)` overwrites the correct register with 0/garbage.

`return v.Stored` is a public field named `Stored`, not `Value`. Confirm in a dump/debug whether CANONICAL intern is `MEMBER_REF` or CALL `GetStored`. If it is generated Get, H1 is sufficient for Property RunLocal.

Fix shape: generated Get should `CopyVar(returnSlot, dest, dwords)` (or skip allocating returnSlot and skip epilogue LoadReturn only when there are no live objects — VALUE temp forbids the skip). Prefer **always** CopyVar into returnSlot from the Get dest, never LoadReturn inside the accessor.

### H2 — `CopyVar(returnSlot, value, returnDwords)` copies a handle/object slot, not the loaded int

`STMT_RETURN` (`:2308-2324`) special-cases only `int&` + `DECL_REF` address mode. `return v.Stored` and `return FValue().Value + 1` go through `EmitExpr`.

`EmitMember` (`:1646-1683`) does `RDR4` into a **new** dest and returns it — that should be the int. Confirm `value` from `EmitExpr` is that dest, not the base handle/VALUE object.

If `value ==` object offset of `v` / the FValue temp, CopyVar copies pointer/object bytes; Destroy then FREEs/dtors that same memory; LoadReturn reads 0 or UAF.

### H3 — returnSlot aliases a live object

`returnSlot = AllocDwords` (`:360`) is **not** pushed to `objects`. `AllocTyped` (`:733-747`) is. Destroy should not touch returnSlot unless a later `AllocTyped` reused the same offset (it should not: `nextLocal` only increases) **or** construct-into used returnSlot as dest.

For `return FValue().Value + 1`: BindParameters has no locals; returnSlot is the first local; construct must `AllocTyped` a **different** offset. Assert that in a debugger/bytecode dump if H1/H2 do not explain got=0→AV.

### H4 — VALUE dtor `this` is wrong (PSF vs PshVPtr)

`DestroyObject` (`:760-779`) for VALUE uses `PSF` of `obj.offset` then CALL `beh.destruct`. Script `~FValue` is a script function. If the temp was stored as a pointer-to-object in a handle-shaped slot, PSF is the address of the slot, not the object — heap smash, then `FString` AV.

Compare LEGACY `asCCompiler` dtor of the same fixture. Do not invent a cleanup-plan POD; fix the existing `objects[]` + `DestroyObject` for script VALUE temps.

---

## Tasks

Tests already exist and are RED. Do **not** write new TEST_METHODs first.

### Task 1: Confirm RED still reproduces (no CodeGen yet if already reproducing)

```powershell
Set-Location D:\as-cta
# Only if sources changed since wave-b-54-traces:
.\Tools\RunBuild.ps1 -Label wave-b-54-remain-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedPropertyCompoundAssignMatchesLegacyCanonicalTrace" -Label wave-b-54-remain-prop -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace" -Label wave-b-54-remain-temp -TimeoutMs 300000
```

Expected: Property CANONICAL RunLocal not 42. Temp `got=0` and/or Fatal AV. Run **one method at a time** so a temp Fatal does not hide Property.

`RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after any impl.

### Task 2: Minimal CodeGen GREEN

Modify only `as_bytecode_codegen.cpp`.

Required invariants after the fix:

1. Every non-void script function copies the returned primitive/handle/ref-address into `returnSlot` **before** `DestroyLiveObjects`.
2. `DestroyLiveObjects` must not destroy `returnSlot`.
3. Generated getters must use the same returnSlot path (no early `LoadReturn` that the epilogue then overwrites).
4. VALUE temp ctor once, dtor once, result 42, Trace `"1,2"`.
5. IsolatedProperty CANONICAL `RunLocal` result 42, Trace `"2,3"`. `RunMake` still `"1,2,3"`.
6. Index mutation methods still GREEN.

Likely patch sites:

- `EmitGeneratedAccessor` Get `:688-696` — CopyVar into returnSlot instead of LoadReturn.
- `STMT_RETURN` `:2308-2326` — keep CopyVar; if `value` is an object/handle that is also in `objects[]` and the return type is a primitive, that is H2 (copy the loaded dest).
- `Emit()` epilogue `:378-383` — keep LoadReturn(returnSlot) after Destroy.

Do **not** remove returnSlot. Do **not** skip DestroyLiveObjects for VALUE temps.

### Task 3: Verify (after impl, always rebuild first)

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-remain -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedPropertyCompoundAssignMatchesLegacyCanonicalTrace" -Label wave-b-54-remain-prop-g -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace" -Label wave-b-54-remain-temp-g -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.Isolated" -Label wave-b-54-remain-iso -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-54-remain-sem -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-remain-sema -TimeoutMs 600000
```

CanonicalAST prefix JSON export has previously crashed after all Success (`wave-b-54-opaque-canonical`) — harness, not a test fail. Prefer Semantics + SemaAuthority + Isolated prefix over a full CanonicalAST JSON export unless needed.

Compiler JSON may `succeededWithWarnings` (TypedSemanticIR SourceProvenance). Do not write pure `N/N PASS` if a warning exists.

**Did not check 5.4 / 13.2 / 9.5 / 4.2.** Did not flip default CANONICAL. Did not CANONICAL `CompileFunction`.

---

## Hard nos

- Second UBT in `D:\as-cta`. New worktree. Archive. Commit unless asked.
- Check 5.4 from Isolated GREEN. Spec still includes compiler-generated values and full mutation chains. Box stays `[ ]`.
- Weaken asserts (`got=0` accepted, skip dtor Trace, drop publisher checks).
- Change Isolated source to avoid `return v.Stored` / user `~FValue`. That is the lock.
- LEGACY `.Value` in the shared IsolatedProperty source (`propertyAccessorMode==0`).
- Mutable script globals as Trace counters. Script `funcdef` / `@` / `is`. `class` as VALUE.
- Default `canonicalCompilerPipeline = true`. CANONICAL `CompileFunction`.
- Clang/LLVM link. Unreal types in fork frontend files.
- Mix leftover FromNode / 4.2 / 5.5 / ninth-pass F1–F2 exact binding / F6 into this bite.
- Globally change `FindExistingExpr` to full-span.
- `EmitDeclRef` literal fallback. Stmt-level cleanup-plan POD.
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`. Always `-NoXGE`.
- Treat CAEngine `UE4Editor` / `MSBuild` / `link` on this machine as this worktree’s lock.

---

## Done means

- IsolatedProperty: LEGACY and CANONICAL, `RunMake` `"1,2,3"` result 1, `RunLocal` `"2,3"` result 42, publishers `COMPILER` vs `CANONICAL_CODEGEN`.
- IsolatedValueTemporary: both engines result 42, Trace `"1,2"`, no AV.
- IsolatedLogical / IsolatedConditional / index mutation methods still GREEN.
- Semantics prefix green after rebuild. SemaAuthority not regressed.
- **5.4 stays `[ ]`.**
