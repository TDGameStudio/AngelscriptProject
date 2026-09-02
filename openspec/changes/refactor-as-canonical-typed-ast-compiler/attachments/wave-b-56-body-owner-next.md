# Wave B exclusive UBT — Frontend Seal `decl-body` after B-56 (B-56-body-owner)

> **For the exclusive-UBT worker:** REQUIRED SUB-SKILLS: `superpowers:systematic-debugging` then `superpowers:test-driven-development`. **NO FIXES WITHOUT a named DECL+STMT dump of `body.owner != decl`.** Do **not** check `tasks.md` 5.6 / 5.4 / 13.2 / 4.2 / 9.5.

**Goal:** Close the B-56 dump slice on Frontend: the three Parser-driven Sema dump tests must `Seal()` again. Keep dump `safepoint=` and verifier oracles. Do not claim 5.6.

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode (recovery)
  → NotifySema after function name (body child often missing)
  → ParseStatementBlock → ActOnParsedStmt intern BLOCK (owner = CurrentDeclContext)
  → ActOnParsedScript WalkOne snFunction → AttachParsedFunctionBody
        FindExistingStmt(BLOCK, begin.offset) → SetBody(fn, block)
        SetStmtSafePointRole(block, FUNCTION_ENTRY)     // B-56
  → SetBody does not write stmt->owner
  → asCASTVerify: if decl->body valid and body->owner != decl id → INVALID_CHILD "decl-body"
  → CANONICAL Build fail-closes on Sema / Seal; LEGACY still asCCompiler
```

LLVM/Clang is a **shape reference only**. Do not link Clang/LLVM.

This is **not** 5.6 close and **not** 13.2 close. Named For/If phases and B-56 dump/verifier oracles are **already landed** — do not redo them.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-56-body-owner** (`attachments/async-work.md` §7) |
| Mode | Exclusive UBT. Systematic-debug first. One UBT user. Always `-NoXGE`. |
| Evidence now | SemaAuthority **213/213** `wave-b-56-sema`. Verifier **16/16** `wave-b-56-ver`. Frontend **82/85** `wave-b-56-frontend`. Diag `wave-b-56-diag-decl` `status=6 detail=decl-body`. |
| Do not mark | 5.6 / 5.4 / 13.2 / 13.3 / 5.9 / 4.2 / 9.5 |
| 2.8 firewall | **CLOSED.** Do not reopen CALL-without-callee. `asCASTVerify` must still succeed on unsealed graphs. |

---

## Global constraints

- Fork dialect unchanged: no script `funcdef` / `@` / `is`; `nullptr` = `ttNull`; mixin **functions**; mutable script globals intern then reject; host `RegisterFuncdef` legal; source `try` / `catch` stays rejected. No C labeled break.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE`. `RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after impl.
- **Hard no:** CALL-without-callee as a seal/verifier firewall. Default `canonicalCompilerPipeline = true`. CANONICAL `CompileFunction`. Check 5.6 / 13.2 / 5.4 from prefix green. Second UBT in `D:\as-cta`. Weaken `decl-body`. Require `safepoint=` in `asCASTVerify`. Globally change `FindExistingStmt` / `FindExistingExpr` to full-span. Redo For/If named phases. Invent stmt-level cleanup-plan POD.
- Temporary diagnostic in `AngelscriptNativeCanonicalASTSemaTests.cpp` (`asCASTVerify` + `#include "source/as_ast_verifier.h"` in `DeclarationDumpCoversTask13Families`) **must be reverted after GREEN**.

---

## 1. Honest landed vs remaining

### Already landed (do not redo)

| Fact | Evidence |
| --- | --- |
| `asEASTSafePointRole` on stmt/expr; dump `safepoint=` when `!= NONE` | SemaAuthority `LoopReturnCallAndTransferRecordSafePointRolesOnCompileSealPath` PASS |
| Sema sets FunctionEntry / LoopEntry / LoopBackedge / Call / Transfer / Return | `AttachParsedFunctionBody` / `ApplyLoopSafePoints` / `ActOnCall` / break/continue/return |
| Verifier skipped-nearer / default-order / fallthrough-target | Verifier **16/16** |
| Named For/If phases, nearest Continue/Break/Fallthrough | pre-B-56 dump tests |
| Term identity, 5.4 OpaqueValue dump | SemaAuthority 208 then 212 |

### Remaining this package

Frontend CanonicalAST three Seal failures, all `decl-body`. Not the new 5.6 tokens.

---

## 2. File map

| Path | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTSemaTests.cpp` | Keep diagnostic assert **only** until the dump names the decl; then revert `asCASTVerify` / extra include to the pre-diag form (`Seal()` only) |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` | `AttachParsedFunctionBody`: reuse BLOCK iff `existing->owner == fn`; else intern |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_context.h/.cpp` | Optional `SetStmtOwner` if `SetBody` should retarget the published body |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp` | Only if intern of compound must not FindExisting a foreign-owned BLOCK when used as a function body |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-b-results.md` | Append `## B-56-body-owner` with `Summary.json` paths |
| `tasks.md` 5.6 | **progress note only**. Box stays `[ ]` |

Do **not** edit `as_ast_verifier.cpp` to drop `decl-body`. Do **not** touch `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, or `as_bytecode_codegen.cpp`. Do not flip Wave G.

---

## 3. Tasks

### Task 1 — prove the decl (systematic-debug; no production fix yet)

**Files:** the Sema dump test file (diagnostic already present).

The live assert is:

```text
declaration dump graph should verify status=6 detail=decl-body
AngelscriptNativeCanonicalASTSemaTests.cpp(104)
```

- [ ] **Step 1: Name the decl.** In `DeclarationDumpCoversTask13Families`, when `VerifyStatus != 0`, loop `GetDeclCount()` and print every decl with `body.IsValid()` where `GetStmt(body)->owner != decl->id`. Print: decl id, kind, name, traits, body id, body kind, body owner, body range begin offset. Do the same for the other two tests if needed (or a tiny shared helper in that cpp only).

Do **not** add this loop as a permanent test. It is instrumentation. After the fix, revert to `Seal()` only.

- [ ] **Step 2: Build + one-test run**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-56-body-diag -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Sema.FCanonicalASTSemaTests.DeclarationDumpCoversTask13Families" -Label wave-b-56-body-diag -TimeoutMs 600000
```

If `-TestFilter` is rejected by `RunTests.ps1`, use `-TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Sema"` instead.

Expected: still fail `decl-body`, but the log names **which** function-like decl and **which** stmt owner. Copy that line into `wave-b-results.md`.

- [ ] **Step 3: Pick one hypothesis** from `async-work.md` §4. Do not implement two fixes.

Likely production fix once H1/H2 hold:

```cpp
static void AttachParsedFunctionBody(asCSema* sema, asASTDeclId fn, asCScriptNode* body, asCScriptCode* script, asASTFileID file)
{
	if( body == 0 || !fn.IsValid() )
	{
		return;
	}
	const asCSourceRange range = RangeOf(sema->GetContext().GetSourceManager(), file, body);
	asASTStmtId block = sema->FindExistingStmt(asAST_STMT_BLOCK, range);
	if( block.IsValid() )
	{
		const asCStmt* existing = sema->GetContext().GetStmt(block);
		if( existing == 0 || existing->owner != fn )
		{
			block = asASTStmtId();
		}
	}
	if( !block.IsValid() )
	{
		block = sema->InternParsedCompoundStmt(body, script, file, fn);
	}
	sema->GetContext().SetBody(fn, block);
	sema->GetContext().SetStmtSafePointRole(block, asAST_SAFEPOINT_FUNCTION_ENTRY);
	RecordLambdaCaptures(sema, fn);
}
```

If the dump shows H3 (generated ctor body is the class block), also stop publishing `SetBody` onto a class-owned compound; intern a ctor-owned block (empty or FillGenerated stmts).

If `InternParsedCompoundStmt` itself `FindExistingStmt(BLOCK)` returns a foreign-owned block and skips CreateStmt, that FindExisting at the **top** of `InternParsedCompoundStmt` must also refuse `existing->owner != owner` when attaching a function body. Do not change FindExisting globally for If/While/Return.

Do **not** add `SetStmtOwner(block, fn)` as the *only* fix if that would make one BLOCK the body of two functions (verifier would then pass while children are shared). Stolen blocks must be **not reused**.

### Task 2 — RED still holds without the production fix? skip if Task 1 dump already exists

The three tests are already RED. Do not add a fourth method. Do not assert `safepoint=` here.

### Task 3 — minimal implementation (GREEN)

- [ ] **Step 1: implement the single chosen fix in `as_sema_decl.cpp` (and `InternParsedCompoundStmt` only if Task 1 proved it returns foreign-owned BLOCKs).**

- [ ] **Step 2: revert the temporary `asCASTVerify` / extra include in `DeclarationDumpCoversTask13Families`. Restore `ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("declaration dump graph should verify")));`**

- [ ] **Step 3: Build then prefixes**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-56-body -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-56-frontend2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-56-sema2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-56-ver2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-56-canonical -TimeoutMs 600000
```

| Prefix | Expect |
| --- | --- |
| Frontend CanonicalAST | previous 85 all PASS (`wave-b-56-frontend2`) |
| SemaAuthority | **213/213** (or live total) |
| Verifier | **16/16** |
| Compiler CanonicalAST | previous green after 5.4 (**260** + 5.6 dump method; live total) |

Then Compiler prefix only if CanonicalAST is green.

Copy each `Summary.json` under the label dir. Append `## B-56-body-owner` to `attachments/wave-b-results.md`. Patch `tasks.md` 5.6 **progress notes only**.

Done when: the three tests Seal; dump `safepoint=` still holds; verifier three methods still hold; `RejectsUnsealedPublication` still has `asCASTVerify` OK on the unsealed Return graph; diagnostic assert gone; **5.6 and 13.2 still `[ ]`**.

Not done: backends consuming roles; 5.4 Generate/VM; leftover `ActOnParsedExpr` default; Wave E–G.

---

## 4. Hard nos (this package)

- CALL-without-callee as a seal/verifier firewall.
- Reopen Wave C 2.8.
- Default CANONICAL. CANONICAL `CompileFunction`.
- Check 5.6 / 13.2 / 5.4 / 5.9 / 4.2 / 9.5 from prefix green.
- Weaken `decl-body`. Require `safepoint=` presence in `asCASTVerify`.
- Redo named For/If phases or nearest Continue/Break/Fallthrough dump tests.
- Globally change `FindExistingStmt` to full-span.
- Script `funcdef` / `@` / `is`. Invent `dictionary`. Re-enable mutable globals as language. C labeled break. Source `try`/`catch`.
- Second UBT in `D:\as-cta`. Archive. Commit unless asked. Clang/LLVM link. Unreal types in fork frontend files.
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`. Skip `-NoXGE`. Run tests against a failed build.

---

## 5. Gate

1. B-56 dump + verifier oracles already GREEN on SemaAuthority / Verifier. This package is **Frontend Seal only**.
2. Do not start 5.4 Generate while this UBT holds `as_sema_decl.cpp`.
3. Named For/If phases already dump — do not touch them.

---

## Self-review

| Item | Task |
| --- | --- |
| Prove `decl-body` victim | Task 1 dump |
| Fix intern, not verifier | Task 3 H1/H2/H3 |
| Revert diagnostic | Task 3 step 2 |
| Keep 5.6 dump/oracles | Task 3 prefixes |
| not 5.6 / not 13.2 check | Header + Task 3 |

No placeholders. Implementer uses this file as the exclusive-UBT plan.
