# Wave B exclusive UBT — sealed control-target consume (EmitSwitch + no innermost-loop fallback)

## LANDED 2026-08-22 (exclusive UBT)

- `EmitSwitch` + `PushLoop(switchId, end, /*continue*/ -1)`. `FindBreakLabel` / `FindContinueLabel`: sealed `stmt->target` scan only; miss → `-1`. No `loops[last]` fallback.
- ProductionCodeGen RED `wave-b-sealed-env-prod` **45/47** (`CanonicalSwitchBreakExitsSwitchNotOuterWhile` + `CanonicalSwitchBreakContinuesAfterSwitchInWhile`, Build != 0 on `STMT_SWITCH`) → GREEN **47/47**, `Entry()==21` and after-switch `7`.
- SemaAuthority **248/248** `wave-b-sealed-env-sema`. CanonicalAST **318/318** `wave-b-sealed-env-canonicalast` (was 316). Compiler **508/508** `wave-b-sealed-env-compiler` (`succeeded=507`, `succeededWithWarnings=1`). Isolated traces + Semantics covered inside CanonicalAST.
- Do **not** mark **13.2 / 13.3 / 10.2 / 9.5 / 4.2 / 5.4 / 5.5 / 5.6 / 9.1 / 13.1**. Leave 9.3 `[x]` (虚标). Packed execute 1934 not this bite.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-sealed-env**. **This mutex.** One UBT. `-NoXGE`.

Companions: `attachments/async-work.md` §4; `attachments/async-dispatch.md`.
This bite is **not** a 13.2 / 5.4 / 5.5 / 5.6 / 5.9 / 4.2 / 9.5 / 9.3 close. Do not check those boxes. Do **not** uncheck 9.3 (虚标 stays `[x]` until rereview).

LLVM/Clang is **shape only**. Do not link. No Unreal types in frontend fork files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Exclusive UBT TDD. One bite. Control-target consume |
| Gate | SemaAuthority **248/248**, CanonicalAST **316/316**, Compiler **506/506** (`succeededWithWarnings=1`). Isolated **4/4**. Semantics **12/12** |
| Do not mark | **any remaining OpenSpec box** |
| Skills | `superpowers:test-driven-development` then `superpowers:verification-before-completion` |

---

## 0. Already true — do not redo / do not restore

- InitPlan execute 42. MemberRef execute 42. Native 0-arg intern. Dummy CONSTRUCT **deleted**.
- `GetFirstProperty` **gone** from `as_bytecode_codegen.cpp`. Do not restore.
- `FindConstructorId` / `FindFactoryId` **definitions may remain**. **Call sites must stay gone.**
- FindExistingExpr: kind + begin; **when request end nonzero, also match end**. Do **not** globally full-span.
- ObjectTypeFromExpr: unwrap then **only** `bridge->Resolve`.
- `LayoutScriptClassFields()` before Seal. Native + script `byteOffset` interned. Packed **opcode** WRTV1 locked.
- Dump `BreakTargetsNearestSwitchNotOuterLoop` already GREEN (`target=` = Switch id). **Dump is not execute.** `DumpSealedCanonicalAst` ignores `Build()` return.
- `PushLoop` today: `EmitWhile` / `EmitDoWhile` / `EmitFor` only (`as_bytecode_codegen.cpp:2860`, `:2882`, `:2904`). **No `EmitSwitch`. No `asAST_STMT_SWITCH` in `EmitStmt`.** Switch hits `default: FailAt(__LINE__, asCONTEXT_NOT_FINISHED)` (`:2734-2736`).
- `FindBreakLabel` (`:2755-2767`) / `FindContinueLabel` (`:2808-2820`): match `loops[i].stmt == target`, else **last loop**. That fallback is the re-Sema this bite deletes.

Must-stay-green: SemaAuthority 248, CanonicalAST 316 (will grow), Compiler 506 (will grow), Isolated 4/4, Semantics 12/12, ProductionCodeGen named rows including InitPlan 42, MemberRef 42, packed **opcode** (do **not** add packed execute 1934 here).

---

## 1. Goal

CodeGen must **consume** Sema's sealed `stmt->target` for `break` / `continue`. A `break` inside `switch` inside `while` must exit the **switch**, not the while. Clang shape: switch is a break parent (`BreakScope`), not a continue parent (`ContinueScope`). This fork: `PushLoop(switchId, endLabel, /*continueLabel*/ -1)`.

Criterion for this bite GREEN (still **not** 13.2):

1. New ProductionCodeGen execute oracle is GREEN.
2. `FindBreakLabel` / `FindContinueLabel` have **no** `loops[last]` fallback. Miss → `FailAt` / return -1 (already fail-closed at the `STMT_BREAK` / `STMT_CONTINUE` call site).
3. `EmitStmt` handles `asAST_STMT_SWITCH` (and its CASE children). No `asCONTEXT_NOT_FINISHED` on the fixture.

Do **not** fold DeclContext `LookupInScope` or global unique-bind into this mutex. Those are queued (`async-dispatch.md`).

Do **not** implement packed int8 execute 1934. Do **not** implement 12-byte `asBC_COPY`. Do **not** implement fallthrough tables beyond what the fixture needs.

---

## 2. Why the existing dump fixture is a bad execute oracle

`BreakTargetsNearestSwitchNotOuterLoop` source:

```angelscript
int Entry()
{
    int i = 0;
    while (i < 1)
    {
        switch (i)
        {
        case 0:
            i = 1;
            break;
        }
    }
    return i;
}
```

After `i = 1`, **both** “break switch” and “break while” return `1`. Dump `target=` can be GREEN while Generate fail-closes or jumps the wrong label. **Do not reuse this script as the execute test.**

---

## 3. Exact TDD bite (ONE bite)

### 3.1 Test A — ProductionCodeGen execute (required)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`

New method: `CanonicalSwitchBreakExitsSwitchNotOuterWhile`

Pattern: copy `CanonicalWhileSuspendBuildPublishesCodeGenAndExecutes` / `CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody`: CANONICAL Engine, `CompileNativeModule`, publisher `CANONICAL_CODEGEN`, `CanonicalExecuteInt`.

Inline AS (`ASTEST_AS_ANSI`, Allman, `Documents/Rules/ASInlineFormattingRule.md`). No `@`. No script `funcdef`. No `array`. VALUE `struct` only if needed — **not needed**; primitives only.

```angelscript
int Entry()
{
    int n = 0;
    int i = 0;
    while (i < 3)
    {
        switch (i)
        {
        case 0:
            n = n + 1;
            break;
        default:
            n = n + 10;
            break;
        }
        i = i + 1;
    }
    return n;
}
```

Oracles:

| Check | LEGACY (if you dual-run) | CANONICAL today (RED) | GREEN |
| --- | --- | --- | --- |
| `Build()` | 0 | likely `!= 0` (`asCONTEXT_NOT_FINISHED` on `STMT_SWITCH`) or wrong jump | 0 |
| Publisher | `COMPILER` | — | `CANONICAL_CODEGEN` |
| `Entry()` | **21** (`1+10+10`) | `Build` fail, or **1** if fallback breaks the while after `n+=1` | **21** |

Do **not** rewrite `break` to labeled form (fork has no labeled break).

Optional same method: dump still `kind=Break` `target=` = Switch id (prove Sema fact survived Generate). Not a substitute for execute 21.

### 3.2 Test B — CanonicalAST fail-closed fallback (required, same bite)

Same ProductionCodeGen file **or** SemaAuthority only if you keep it dump+Build==0.

Preferred: in Test A after execute, also compile a nested-while `break` that **must** hit the inner loop even if someone reintroduces last-loop fallback — actually nested while already works **with** fallback (both are PushLoop'd). The switch fixture is the one that distinguishes.

Add a **comment in FindBreakLabel** is not a test. The execute 21 vs 1 **is** the test that fails if fallback remains and switch is PushLoop'd incorrectly as “use last loop”.

If you implement `EmitSwitch`+`PushLoop` but **leave the fallback**, and switch is in `loops[]`, `FindBreakLabel` finds the switch by id — execute would still be 21. So Test A GREEN does **not** by itself prove the fallback is gone.

**Required code assertion for the fallback delete:** after impl, `FindBreakLabel` / `FindContinueLabel` must look like:

```text
if target valid: scan loops for stmt == target; if found return that label
return -1
```

No `if (loops.GetLength()) return loops[last]`.

Add a second execute fixture that **would be wrong under fallback** even with switch in the table:

```angelscript
int Entry()
{
    int n = 0;
    int i = 0;
    while (i < 1)
    {
        i = 1;
        switch (0)
        {
        case 0:
            break;
        }
        n = 7;
    }
    return n;
}
```

- Switch-break (correct): fall through to `n = 7`, while cond fails, return **7**.
- While-break (fallback if switch **not** in `loops[]`): skip `n = 7`, return **0**.

If switch **is** in `loops[]`, fallback is unused for this break. Combined:

1. Test A (`21`) proves switch emit + break-from-switch.
2. Grep/`read_file` after impl: no last-loop return. The implementer **must delete those two `if (loops.GetLength()) return last` blocks**. Reviewer checks the diff.

Do not add a source-scan automation test for the helper text.

### 3.3 Expected RED today

No UBT in the 梳理 session. RED from live `EmitStmt` switch miss:

| Method | Likely RED |
| --- | --- |
| `CanonicalSwitchBreakExitsSwitchNotOuterWhile` | `CompileNativeModule != 0` (`Canonical CodeGen failed code=… line=` `EmitStmt` default). If someone later emits switch without PushLoop, execute **1** (fallback breaks while) |

TDD: add Test A **first**, `RunBuild.ps1` then ProductionCodeGen prefix, confirm RED, **then** implement.

---

## 4. GREEN production change (only this)

File: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`.

### 4.1 `EmitSwitch`

Handle `asAST_STMT_SWITCH` in `EmitStmt`. Sealed shape (`as_sema.cpp:1195-1208`, dump tests `SwitchDefaultCaseIsLastAndHasNoExprOnCompileSealPath`):

- Switch stmt: `stmt->expr` = selector. `stmt->children[]` = CASE stmts.
- CASE: `kind=Case`. `expr` valid = case value; **no expr** = default. Body = that case's `children`. `target` = switch id.

Clang/LEGACY shape (do not copy `asCCompiler` or Clang):

1. Allocate `end` label. `PushLoop(stmt->id, end, /*continueLabel*/ -1)`. Switch is a **break** parent, not continue.
2. `selector = EmitExpr(stmt->expr)` — integral; fail-closed if not (LEGACY rejects non-integral).
3. For each CASE child with a value: compare selector to case expr, `JNZ`/`JZ` to that case's body label (use existing `EmitBoolJump` / integer compare already used by `if`).
4. If a default CASE exists, jump there when no value matches; else jump `end`.
5. Emit each CASE body. `STMT_BREAK` inside uses `FindBreakLabel(switch id)` → `end`.
6. `Label(end)`. `PopLoop()`.

Do **not** require fallthrough between cases for this fixture (both cases `break`). If a CASE has no trailing break, falling into the next CASE body is language-correct; do not invent extra JMPs that would break later fallthrough tests.

Look at `EmitIf` / `EmitWhile` for label/`SUSPEND` style. Loop headers emit `SUSPEND`+`JitEntry`; switch dispatch does **not** need a new suspend unless an existing switch dump/safepoint test requires it. Prefer matching `EmitIf` (no extra suspend on the compare).

`asAST_STMT_CASE` must not hit `EmitStmt` default if Generate walks them as standalone (they are switch children). Either:

- only `EmitSwitch` walks CASE children, and `EmitStmt(CASE)` is a no-op / fail-closed if reached from a BLOCK, or
- `EmitStmt(CASE)` emits the case body only.

Prefer: `EmitSwitch` owns CASE children; `EmitStmt` `case asAST_STMT_CASE: break;` (no-op) so a misplaced CASE does not `CONTEXT_NOT_FINISHED`. Do **not** silently execute a CASE as a BLOCK (would run case bodies twice).

### 4.2 Delete innermost-loop fallback

```2755:2767:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		int FindBreakLabel(asASTStmtId target) const
		{
			if( target.IsValid() )
			{
				for( asUINT i = 0; i < loops.GetLength(); ++i )
				{
					if( loops[i].stmt == target )
						return loops[i].breakLabel;
				}
			}
			if( loops.GetLength() )
				return loops[loops.GetLength() - 1].breakLabel;
			return -1;
		}
```

Delete the `if( loops.GetLength() ) return last;` (both Break and Continue). `STMT_BREAK` already `FailAt` when label `< 0`.

If `continueLabel == -1` (switch frame), `FindContinueLabel(switchId)` must return -1, not a parent loop. Continue's sealed `target` is the enclosing **while/for/do**, which is already in `loops[]`.

### 4.3 What not to change

- `HasConstructAssignTo`, `PropertyFromFieldDecl`, `FindRegisteredGlobalFunction`, `LookupInScope`.
- Packed execute. ABI helpers.
- `FindExistingStmt` kind+begin (control stub fill).
- Default pipeline. `CompileFunction`. Wave E–G.

---

## 5. Commands

Only from `D:\as-cta`. Always `-NoXGE` on build. `RunTests.ps1` does **not** UBT — `RunBuild.ps1` first after impl. Never All. Never `UnrealEditor-Cmd` direct.

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-sealed-env -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-sealed-env-prod -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-sealed-env-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-sealed-env-canonicalast -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-sealed-env-compiler -TimeoutMs 600000
```

TDD order:

1. Add Test A only. Build. ProductionCodeGen RED (`Build != 0` or not 21).
2. `EmitSwitch` + `PushLoop(switch)` + delete last-loop fallback. Build. Test A `21`. ProductionCodeGen all previous GREEN.
3. SemaAuthority 248+ / CanonicalAST 316+ / Compiler 506+ (`succeededWithWarnings=1` ok). Isolated 4/4 and Semantics 12/12 if those prefixes stay cheap; otherwise CanonicalAST covers them.

If UBT says up to date while `as_bytecode_codegen.cpp` changed (often plugin git `??`): delete Runtime DLL + `Module.AngelscriptRuntime.44.cpp.obj`, then rebuild.

One UBT user in `D:\as-cta`. Do not start while another agent holds the mutex.

---

## 6. Stay-unchecked

Leave `[ ]`: **13.2 / 13.3 / 10.2 / 9.5 / 4.2 / 5.4 / 5.5 / 5.6 / 9.1 / 13.1**.

Leave already-checked 虚标 **9.3** as `[x]` — this bite implements **one** switch fixture, not the full structured-control sentence (foreach, fallthrough matrix, HIR migration).

Do not archive. Do not commit unless asked. Default pipeline stays LEGACY.
