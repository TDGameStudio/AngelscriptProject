# Wave C results — 2026-08-21

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Do **not** mark `tasks.md` 2.4 / 2.8 / 13.4 / 13.5. Default remains `LEGACY`. Production `Build()` is still `asCCompiler`.

## Commands

| Label | Prefix | Result |
| --- | --- | --- |
| `wave-c-verifier-red2` | `...CanonicalAST.Verifier` | **3/8** (5 new cases RED as intended) |
| `wave-c-verifier-green` | `...CanonicalAST.Verifier` | **8/8** |
| `wave-c-frontend-canonical2` | `...Frontend.CanonicalAST` | **56/56** (includes Type/Context/BodySema/CodeGen/Dump/SemaAuthority) |
| `wave-c-hotreload-snapshot2` | `...HotReload.CanonicalAST` | **5/5** |

Snapshot `GetContext` static_assert RED: `wave-c` build `20260821_155516` C2338 `'asCASTSnapshot::GetContext must be const-only'`.

## Landed (R07 / R08 slices)

- Expr table-index mismatch (`expr-id`).
- Decl parent/child bidirectional (`decl-parent-child`) and parent-chain `decl-cycle`.
- Break/continue target must be an ancestor (`break-ancestor` / `continue-ancestor`).
- Non-error expr must have interned type and a legal value category.
- Expr operand dangling / arity / invalid child kind (`expr-operand`).
- Qualifier intern: unknown bits, direction-without-reference, auto-handle-without-handle, illegal void quals. **`void` + handle stays valid** (nullptr encoding).
- `asCASTSnapshot::GetContext()` is const-only.
- Snapshot public `GetDecl`/`GetStmt`/`GetExpr` walk the **const** context (sealed non-const `Get*` return null).
- Shadow comparison no longer mutates after `Seal()`.

## Construction APIs (2026-08-21 later)

Public `GetDecl` / `GetStmt` / `GetExpr` / `GetSourceManager` are const-only. Writes go through `SetBody` / `AddDeclChild` / `SetTarget` / `AddSourceSection` / … implemented with private `MutableDecl` / `MutableStmt` / `MutableExpr` / `MutableSourceManager`. Sema members and `as_sema_decl.cpp` / `as_sema_expr.cpp` free helpers no longer write POD through raw pointers.

| Label | Prefix | Result |
| --- | --- | --- |
| `wave-c-construction-frontend` | `...Frontend.CanonicalAST` | **58/58** |
| `wave-c-construction-hotreload` | `...HotReload.CanonicalAST` | **5/5** |
| `wave-c-construction-cutover` | `...Compiler.CanonicalAST.Cutover` | **5/5** LEGACY, Ready false |
| `wave-c-construction-sema-authority` | `...SemaAuthority` | **22/22** (not 13.2/5.9) |

`tasks.md` **2.4 / 13.4** closed. **2.8 / 13.5** closed 2026-08-21 (`wave-c-28-green` Verifier 13/13, Frontend CanonicalAST 63/63, Compiler CanonicalAST 37/37).

## 2.8 / 13.5 remainder (closed 2026-08-21)

| Label | Prefix | Result |
| --- | --- | --- |
| `wave-c-28-red` | `...CanonicalAST.Verifier` | **8/13** (5 new cases RED as intended) |
| `wave-c-28-green` | `...CanonicalAST.Verifier` | **13/13** |
| `wave-c-28-frontend` | `...Frontend.CanonicalAST` | **63/63** (BodySema/CodeGen still seal; no CALL-without-callee) |
| `wave-c-28-compiler` | `...Compiler.CanonicalAST` | **37/37** Cutover LEGACY + SemaAuthority 22 + VM matrix |

Landed: stmt-multi-owner, stmt-cycle, fallthrough-switch, CLEANUP dtor-when-set, `asCASTVerifyPublication` → `unsealed-publication`. `asCASTVerify` still accepts unsealed graphs.

## Still open (later waves)

| Spec meaning | Remaining hole |
| --- | --- |
| 2.4 / 13.4 / 2.8 / 13.5 | **Closed.** |
| 2.6 type authority | **Closed** (`wave-c-26-green` Type 13/13). ENUM/FUNCDEF/TEMPLATE/VALUE/REF intern via bridge; QualType has no engine pointer. Sema named-kind invention is 4.3. |
| Wave D R09 | Isolated Generate **Task 1** global rollback is green (`r09-txn-green2` Transaction 3/3). Detached artifact, FuncPtr fail-after-emit, retry, and production `Build()` are still open. Do **not** mark 9.1 / 9.5 / 13.6 / 10.4. |

Next exclusive UBT: Wave D remaining isolated transaction (Tasks 2–7), then production `Build()`. Do not mark 13.2 / 5.9 / 9.5 / 13.6 / section 10.

## UBT blocked — C-28 remainder 2026-08-21 (Wave C 2.8/13.5)

Mutex check before any `RunBuild.ps1` / `RunTests.ps1` found live processes; **no second build started**.

| Process | PID | Notes |
| --- | --- | --- |
| `UE4Editor.exe` | 101532 | `W:\CA0917\CAEngine\Engine\Binaries\Win64\UE4Editor.exe` `UAGame.uproject` `-skipcompile` (started 12:29) |
| `MSBuild.exe` | 23732 | `C:\Users\scottmei\AppData\Local\Temp\Lohobiv.proj` (started 2026-08-11) |
| `MSBuild.exe` | 32320 | `C:\Users\scottmei\AppData\Local\Temp\Zudicex.proj` (started 2026-08-19) |
| `link.exe` | 99004 | `LINK /LIB` UnrealHeaderTool TraceLog (started 2026-08-06) |
| `cl.exe` | 3188 | compiling `D:\OB0917\DailyBuild\CAGame\...Module.UAGame.4_of_19.cpp` (started 16:39) |

**Done (RED tests only):** appended `RejectsStmtMultiOwner`, `RejectsStmtCycle`, `RejectsFallthroughOutsideSwitch`, `RejectsUnsealedPublication`, `RejectsCleanupResolvedDeclNotDestructor` to `AngelscriptNativeCanonicalASTVerifierTests.cpp`. Did **not** add `RejectsCallWithoutResolvedDecl`.

**Not done:** no `as_ast_verifier.cpp` / `as_ast_verifier.h` edits; no `asCASTVerifyPublication` declaration; no CodeGen gate change; no `RunBuild` / `RunTests`. First RED is therefore unproven (compile fail on missing `asCASTVerifyPublication` is the planned acceptable RED once UBT is idle).

`tasks.md` **2.8 / 13.5** stay `[ ]`. Re-run exclusive UBT from `D:\as-cta` when idle: `wave-c-28-red` then implement verifier, then `wave-c-28-green` + `wave-c-28-frontend`.
