# Wave D sixth-pass F4 execute — exclusive UBT (sibling IIFE `A+B=42`)

Worktree: `D:\as-cta`. Exclusive UBT package **D-sixth-f4-exec**.
Change: `refactor-as-canonical-typed-ast-compiler`.

**REQUIRED SUB-SKILLS:** `superpowers:systematic-debugging` first, then `superpowers:test-driven-development`, then `superpowers:verification-before-completion`.

Do **not** check `tasks.md` 9.5 / 13.2 / 13.3 / 10.2 / 9.1 / 13.6.
Do **not** archive. Do **not** commit unless the user asks.
Do **not** spawn a second UBT. Do **not** run UBT against `D:\Workspace\AngelscriptProject` (main).
Do **not** implement F5 LEGACY lambda, F1 remainder, F6, Wave E–G, or CANONICAL `CompileFunction`.

Default pipeline stays LEGACY. This fixture **SetCompilerPipeline(CANONICAL)**. Publisher must stay `CANONICAL_CODEGEN`.
No Clang/LLVM link. No Unreal types in fork frontend files.
No script `funcdef` / `@` / `is`. `nullptr` = `ttNull`. Mutable globals intern then reject.

---

## Goal

Sibling capturing IIFEs that both capture enclosing `X=21` must execute `A+B=42`.

Uniquing is **already in source**. Intern counts already PASS. The remaining failure is execute **13732**.

## Why uniquing is not the remaining bug

Sixth-pass F4 (`reviews/implementation-rereview-2026-08-22-sixth-pass.md`):

- Module-global `AddUniqueCapture` from index 0 dropped the second lambda’s capture of the same `X`.
- Capture collector is CodeGen-owned (Sema boundary; do not close 13.2 from this slice).

Landed:

- `as_bytecode_codegen.cpp` `AddUniqueCapture(captures, begin, id)` scans `[begin, end)` only.
- `CollectLambdaCaptures` snapshots `begin = captures.GetLength()` then walks with that begin.
- `as_sema_expr.cpp` `ActOnPostfixCallExpr`: if `resolvedDecl` has `asAST_TRAIT_LAMBDA`, `ActOnCall` that decl (do not re-resolve `"<lambda>"`).

RED that already exists — keep it as the gate; do not rewrite it away:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
`TEST_METHOD(CanonicalSiblingLambdasEachCaptureTheSameEnclosingX)` (~1853).

```angelscript
int F() {
  int X = 21;
  int A = function() { return X; }();
  int B = function() { return X; }();
  return A + B;
}
```

Asserts:

1. two `"<lambda>"` functions
2. each `parameterTypes.GetLength() == 1`
3. `CanonicalExecuteInt` → 42
4. publisher `CANONICAL_CODEGEN`

Evidence already on disk: `D:\as-cta\Saved\Tests\wave-d-f4-prod2\20260822_093552_194_0829c0a2`

```text
32/33  intern PASS  execute=true value=13732
```

GREEN control: `CanonicalCapturingLambdaBuildPublishesCodeGenAndExecutes`

```angelscript
int F() {
  int X = 41;
  return function() { return X + 1; }();
}
```

still 42 on the same report.

## Files

- Modify only if diagnosis requires:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`
    (`EmitCall` capture inject ~1998–2052, `BindParameters` capture slots ~822–833, `STMT_DECL`/`STMT_EXPR` ~2114–2145)
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` (`ActOnPostfixCallExpr`)
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` (`ActOnLambdaFromNode` / `FindExistingFunctionLike`)
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp` (`EmitLocalDeclStmts` / nested block)
- Test: existing sibling method. Diagnostic-only extra asserts (bytecode CALL ids, dump) may be added **in that method or a clearly named sibling diagnostic**. Restore the original A+B script as the pass gate.
- Attachment after GREEN: patch `attachments/async-work.md` / `async-dispatch.md` / `sixth-pass-verified.md` with report paths. **Do not check tasks.md boxes.**

## Phase 1 — root cause (mandatory before any “fix”)

Iron law: no extra uniquing/refactor without evidence of **where 13732 is born**.

Working comparison: single capturing IIFE in `return` is GREEN. Broken: two sibling IIFEs assigned into `A`/`B` then `A+B`.

### Isolation steps (one variable at a time)

Keep the original method as the gate. Use a **temporary** diagnostic method or a commented-out alt source only long enough to gather one fact, then restore.

1. **Shape:** `return function(){ return X; }() + function(){ return X; }();` with `int X=21;` and **no** `A`/`B`.
   - If this executes 42: the bug is local-init / nested BLOCK / slot alias, not two-lambda CALL identity.
   - If this is still garbage: the bug is two CALL sites / capture inject / callee identity.

2. **Callee identity:** after Build, record each `"<lambda>"` `GetId()` and assert `F()` bytecode contains **two distinct** `asBC_CALL` targets (or dump `callee=` on both CALL expr). If both CALL ids equal one lambda, intern count 2 is not two live callees.

3. **Capture inject:** at each CALL, `FindSlot(X)` in F must be X’s slot, not `A`/`B`. Hidden formals are appended after user params (`asTM_NONE`). `paramCount` includes them. `userParamCount = paramCount - captureCount`.

4. **Lambda body slot:** `BindParameters` binds `captureDecls[captureBegin+c]` (the **enclosing VAR id**) to the hidden param stack position in the **lambda** emitter. `FindSlot` is first-match. A second `BindSlot` of the same decl id would not change FindSlot, but a **wrong begin** would bind the other lambda’s capture row.

Relevant code (live line numbers, 2026-08-22):

| Location | What |
| --- | --- |
| `as_bytecode_codegen.cpp:86-156` | uniquing `[begin,end)` — already landed |
| `as_bytecode_codegen.cpp:798-833` | BindParameters + capture BindSlot |
| `as_bytecode_codegen.cpp:1998-2075` | EmitCall hidden capture PushValue + CALL |
| `as_bytecode_codegen.cpp:2114-2145` | STMT_DECL allocates only; init is STMT_EXPR |
| `as_sema_stmt.cpp:209-246` | EmitLocalDeclStmts; init → sibling assign; `ActOnLocalDeclStmt` wraps in Block when init present |
| `as_sema_expr.cpp:559-622` | postfix IIFE `ActOnCall` of TRAIT_LAMBDA |
| `as_sema_decl.cpp:1007-1046` | `ActOnLambdaFromNode`; `FindExistingFunctionLike` reuse + `SetBody` |

`13732` is not a known encoding of 21 or 42. Treat it as stack/uninit/wrong-slot garbage until a dump shows otherwise.

### Pattern

Single GREEN path: one local `X`, one CALL in `return`, one hidden capture, one `"<lambda>"`.
Broken path: three inited locals (`X`,`A`,`B`), two CALLs, two `"<lambda>"`.

## Phase 2 — implement the proven cause only

One change at a time. No “while I’m here” intern peels. No moving capture plan into Sema in this UBT (that is a later 13.2 slice). Short-term CodeGen/Sema call-site correctness is enough for execute 42.

Do not “fix” F4 by:

- `SetCompilerPipeline` removal or flipping default CANONICAL
- merging the two IIFEs into one lambda
- weakening the execute assert
- counting captures without execute 42
- implementing F5 LEGACY `ImplicitConvLambdaToFunc` here

## Phase 3 — verify

`RunTests.ps1` does **not** UBT. After any impl:

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-d-f4-exec
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-d-f4-prod3 -TimeoutMs 600000
```

Expected: ProductionCodeGen **all pass**, including sibling execute 42 and single capturing IIFE 42.

Then:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-d-f4-compiler -TimeoutMs 600000
```

Expected: Compiler prefix all pass (last F3 green was **413/413**; this slice may add 0 tests if the sibling method already existed).

Write report paths into `attachments/sixth-pass-verified.md` F4 row. **Leave 9.5 / 13.2 `[ ]`.**

## Hard nos

- Second UBT in `D:\as-cta`
- Building main `D:\Workspace\AngelscriptProject`
- Checking 9.5 / 13.2
- Wave E–G, archive, commit
- Script `funcdef` / `@` / `is`
- CANONICAL CompileFunction
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`. Always `-NoXGE`.
