# Wave B Clang break/continue shape — control-stack mapping

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. Read-only shape reference. No UBT. No `Plugins/` edits. Do **not** collide with `wave-b-control-jump-next.md` (exclusive UBT plan) or `async-work.md` / `async-dispatch.md`.

LLVM/Clang is a **shape reference only**. Do not link Clang/LLVM. Do not copy Clang `Scope*` / `LabelDecl*` into this fork. AngelScript has **no labeled break**. Do **not** check `tasks.md` 13.2 / 5.6.

Planned dedicated intern lives in `attachments/wave-b-control-jump-next.md`. This file only maps Clang Sema control-jump **actions** onto this fork's Sema `controlStack`. Builder ≠ intern.

---

## 1. Clang: Parser does not intern Break

Parser `ParseBreakOrContinueStatement` (`clang/lib/Parse/ParseStmt.cpp` ~2307) consumes `break` / `continue`, optionally a C2y named-loop identifier, then **hands the keyword location plus the current scope** to Sema. It never allocates `BreakStmt` / `ContinueStmt`.

```text
ParseBreakStatement()
  → ParseBreakOrContinueStatement(/*IsContinue=*/false)
       → Actions.ActOnBreakStmt(KwLoc, getCurScope(), Target, LabelLoc)

ParseContinueStatement()
  → ParseBreakOrContinueStatement(/*IsContinue=*/true)
       → Actions.ActOnContinueStmt(KwLoc, getCurScope(), Target, LabelLoc)
```

Sema declarations (`clang/include/clang/Sema/Sema.h` ~11098):

```cpp
StmtResult ActOnContinueStmt(SourceLocation ContinueLoc, Scope *CurScope,
                             LabelDecl *Label, SourceLocation LabelLoc);
StmtResult ActOnBreakStmt(SourceLocation BreakLoc, Scope *CurScope,
                          LabelDecl *Label, SourceLocation LabelLoc);
```

`ActOnBreakStmt` (`SemaStmt.cpp` ~3366) asks **the scope**, not the parser tree, for the parent:

- unlabeled: `S = CurScope->getBreakParent()`
- missing parent → `err_break_not_in_loop_or_switch` (C99 6.8.6.3: break only in switch/loop body)
- then `new BreakStmt(BreakLoc, LabelLoc, Target)`

`ActOnContinueStmt` (`SemaStmt.cpp` ~3328) is the same shape with **loop-only** parent:

- unlabeled: `S = CurScope->getContinueParent()`
- missing parent → `err_continue_not_in_loop` (C99 6.8.6.2: continue only in a loop body)
- then `new ContinueStmt(ContinueLoc, LabelLoc, Target)`

`Scope::getBreakParent` / `getContinueParent` (`clang/include/clang/Sema/Scope.h` ~204, ~299, ~320) are cached links set when a scope is created or flagged (`Scope.cpp` `setFlags` / `AddFlags`):

| Scope flag | Who sets it | Parent used by |
| --- | --- | --- |
| `BreakScope` | while / do / for (`ParseStmt.cpp` ~1739, ~2154) **and** switch (after condition, ~1692 `AddFlags(BreakScope)`) | `getBreakParent` |
| `ContinueScope` | while / do / for only | `getContinueParent` |
| `SwitchScope` | switch start (~1651) | not a continue parent; `isLoopScope()` is BreakScope **without** SwitchScope |

So Clang's unlabeled `getBreakParent` ≈ nearest loop **or** switch. Unlabeled `getContinueParent` ≈ nearest **loop**, skipping switch.

Labeled break/continue exist in Clang (`FindLabeledBreakContinueScope`, `LabelDecl *Target`, C2y `NamedLoops`). OpenMP (`isOpenMPLoopScope` rejects `break`), OpenACC (compute-construct branch-out), and SEH (`CheckJumpOutOfSEHFinallyOrDefer`, `ActOnSEHLeaveStmt`) are extra. **None of those map into this fork.**

Clang C++ `[[fallthrough]]` is an `AttributedStmt`, not `ActOnBreakStmt`. There is no Clang `ActOnFallthroughStmt`.

---

## 2. This fork: `controlStack` is the break/continue parent

No labeled break. No `Scope*`. No `LabelDecl`. The analogue of Clang's cached break/continue parent is Sema's `controlStack` plus file-static `NearestControl`.

| Clang | This fork |
| --- | --- |
| `Scope::BreakParent` / `ContinueParent` | `asCSema::controlStack` (`as_sema.h`) |
| `getBreakParent()` | `NearestControl(context, controlStack, /*loopsOnly=*/false)` |
| `getContinueParent()` | `NearestControl(context, controlStack, /*loopsOnly=*/true)` |
| Parser `getCurScope()` argument | **not** a parameter; dedicated intern reads `controlStack` |
| `LabelDecl *` / `LabelLoc` | **absent** — do not add |

`NearestControl` (`as_sema_stmt.cpp` ~375): walk the stack from the top. While / DoWhile / For / Foreach always match. Switch matches only when `loopsOnly == false`. That is the Clang split: break accepts loop or switch; continue skips switch.

### When the stack is live

`BeginParsedControl` (`as_sema_stmt.cpp` ~132) already stubs the loop/switch and **`PushControl` at the header**, before the body is parsed. Parser call sites after `)` (and do-while after `do`):

- `ParseSwitch` `as_parser.cpp:4748`
- `ParseFor` `:5070`
- `ParseForeach` `:5220`
- `ParseWhile` `:5285`
- `ParseDoWhile` `:5323`

That is why existing Parser dump locks intern a target during an incomplete body (`ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails`, `ParserActOnContinueRecordsForTargetBeforeBodyCloseFails`, `ParserActOnBreakRecordsSwitchTargetOnSuccessfulParse`). Those still intern **through FromNode** today. Do not rewrite them.

Parser `ParseBreak` / `ParseContinue` / `ParseFallthrough` (`as_parser.cpp` ~5453 / ~5491 / ~4813) do **not** intern the jump themselves. They `ActOnParsedStmt(node, script)` on missing `;` and on success — same Clang split: Parser notifies, Sema interns. Today `ActOnParsedStmt` still groups `snBreak` / `snContinue` / `snFallthrough` with `snExpressionStatement` and calls `ActOnStmtFromNode` (`as_sema_decl.cpp` ~1753).

FromNode leftover (`as_sema_stmt.cpp` ~690):

```text
snBreak       → ActOnBreak(owner, NearestControl(..., false), range)
snContinue    → ActOnContinue(owner, NearestControl(..., true), range)
snFallthrough → ActOnFallthrough(owner, range)    // no NearestControl
```

Builders (`as_sema.cpp` ~824–857) stay builders: `ActOnBreak` / `ActOnContinue` take an explicit `target` and `SetTarget`; `ActOnFallthrough` creates `asAST_STMT_FALLTHROUGH` with **no** target.

### Dedicated `ActOnWhileStmt` Push then Pop

`ActOnWhileStmt` / `ActOnForStmt` / `ActOnDoWhileStmt` / `ActOnForeachStmt` (`as_sema_stmt.cpp` ~258–345): if the filled loop is created in this call (no prior stub), they `PushControl(loop)` then **`PopControl()` before return**. If a stub from `BeginParsedControl` is filled, they `PopControl()` after fill.

Consequence: after `ActOnWhileStmt` / `ActOnForStmt` returns, `NearestControl` does **not** see that loop. No-script-node tests **must** `PushControl` the filled loop again before `ActOnBreakStmt` / `ActOnContinueStmt`. That is already the contract in `wave-b-control-jump-next.md`. Do not keep the loop on the stack inside dedicated While/For to “help” those tests — that would change Parser fill/pop pairing.

`ActOnSwitchStmt` is the exception: a newly created switch **stays** on `controlStack` until `FinishSwitchStmt` pops it (after `WireFallthroughTargets`).

---

## 3. Fallthrough is not an `ActOnBreakStmt` analogue

This dialect has a statement `fallthrough;` (`snFallthrough`). It is **not** Clang `break`, not labeled break, and not `[[fallthrough]]`.

| Step | Owner | What is recorded |
| --- | --- | --- |
| Intern | builder `ActOnFallthrough` / planned `ActOnFallthroughStmt` | `kind=Fallthrough`, no `target=` |
| Wire | `FinishSwitchStmt` → `WireFallthroughTargets` (`as_sema_stmt.cpp` ~99, ~366) | `SetTarget` to the **next case** stmt, if any |
| Dump | `as_ast_dump.cpp` ~169 | `target=%u` only when `stmt->target.IsValid()` |

Dedicated intern dump lock is `kind=Fallthrough` only (`SemaFallthroughStmtActionRecordsKindWithoutScriptNode`). Parser already locks one `kind=Fallthrough` on success (`ParserActOnFallthroughDoesNotDuplicateOnSuccessfulParse`). **Do not claim 5.6 `target=` close from intern alone.** Wiring stays `FinishSwitchStmt`. Do not check 5.6.

Verifier today allows Break/Continue without a target; when a target is present it must be a loop (continue) or loop/switch (break) and an ancestor (`as_ast_verifier.cpp` ~265). Fallthrough only requires an owner at intern; next-case `target=` is a later switch-finish fact.

---

## 4. Confirmed dedicated signatures

Already specified in `wave-b-control-jump-next.md`. Confirm; do not invent labeled-break APIs; do **not** add an explicit target parameter (that would rename builder `ActOnBreak`).

```cpp
asASTStmtId ActOnBreakStmt(asASTDeclId owner, const asCSourceRange& range);
asASTStmtId ActOnContinueStmt(asASTDeclId owner, const asCSourceRange& range);
asASTStmtId ActOnFallthroughStmt(asASTDeclId owner, const asCSourceRange& range);
```

| Action | Parent | Builder used |
| --- | --- | --- |
| `ActOnBreakStmt(owner, range)` | `NearestControl(..., false)` — loop or switch | `ActOnBreak(owner, target, range)` |
| `ActOnContinueStmt(owner, range)` | `NearestControl(..., true)` — loops only | `ActOnContinue(owner, target, range)` |
| `ActOnFallthroughStmt(owner, range)` | none at intern | `ActOnFallthrough(owner, range)` |

`FindExistingStmt` stays inside the dedicated APIs so Parser ActOn + WalkOne do not intern twice.

Rejected Clang-shaped extras (do not declare):

- `ActOnBreakStmt(..., LabelDecl*)` / labeled `break L;`
- `Scope *CurScope` parameter
- OpenMP / OpenACC / SEH leave
- `ActOnFallthroughStmt` setting `target=` (would steal `WireFallthroughTargets`)

---

## 5. Mapping table (Clang API → fork API)

| # | Clang API | This fork |
| --- | --- | --- |
| 1 | Parser `ParseBreakStatement` / `ParseContinueStatement` | `ParseBreak` / `ParseContinue` → `ActOnParsedStmt`; Parser does not intern |
| 2 | `Sema::ActOnBreakStmt(BreakLoc, CurScope, Label, LabelLoc)` | `ActOnBreakStmt(owner, range)` — no scope, no label |
| 3 | `CurScope->getBreakParent()` | `NearestControl(context, controlStack, false)` |
| 4 | `Sema::ActOnContinueStmt(ContinueLoc, CurScope, Label, LabelLoc)` | `ActOnContinueStmt(owner, range)` |
| 5 | `CurScope->getContinueParent()` | `NearestControl(context, controlStack, true)` |
| 6 | Parser `ParseScope(..., BreakScope \| ContinueScope)` at loop header | `BeginParsedControl` stubs + `PushControl` after `)` / at `do` |
| 7 | Switch `AddFlags(BreakScope)` only (not ContinueScope) | switch on `controlStack`; continue `loopsOnly` skips `asAST_STMT_SWITCH` |
| 8 | `ActOnStartOfSwitchStmt` / `ActOnFinishSwitchStmt` | `ActOnSwitchStmt` (stays pushed) / `FinishSwitchStmt` (wire + pop) |
| 9 | `new BreakStmt` / `new ContinueStmt` | builders `ActOnBreak` / `ActOnContinue` (`SetTarget`); dedicated `ActOn*Stmt` is the intern |
| 10 | C++ `[[fallthrough]]` `AttributedStmt` (not `ActOnBreakStmt`) | `ActOnFallthroughStmt` intern; `WireFallthroughTargets` in `FinishSwitchStmt` |

Dump (`as_ast_dump.cpp` ~171): STMT lines emit `target=%u` only when the target id is valid.

- Dedicated break: `kind=Break` + `target=` matching the `PushControl` While/Switch id.
- Dedicated continue: `kind=Continue` + `target=` matching the `PushControl` For/While id.
- Dedicated fallthrough: `kind=Fallthrough` — **no** `target=` required at intern.

---

## 6. Hard nos

- Do not link Clang/LLVM. Shape reference only.
- Do not add labeled break / continue, `LabelDecl`, or a `Scope*` parameter.
- Do not add OpenMP / OpenACC / SEH leave.
- Do not re-enable script `funcdef` / `@` / `is`.
- Do not add an explicit target parameter on `ActOnBreakStmt` / `ActOnContinueStmt`.
- Do not wire fallthrough `target=` inside `ActOnFallthroughStmt`.
- Do not check `tasks.md` 13.2 or 5.6. Do not claim 5.6 close from intern dumps.
- Do not rewrite existing Parser FromNode dump locks.
- Do not edit `Plugins/`. Do not run UBT from this attachment.

---

## 7. What this file is not

- Not the exclusive UBT plan (`wave-b-control-jump-next.md` owns TDD + FromNode extract-then-dedicated).
- Not 13.2 close. FromNode remains recovery for leftover kinds.
- Not a dump of Clang classes into `as_sema.h`.
