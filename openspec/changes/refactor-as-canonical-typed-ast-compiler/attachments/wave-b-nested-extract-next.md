# Wave B nested extract intern — LANDED (Frontend CodeGen two fails still open)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
**Landed.** SemaAuthority **194/194** `wave-b-nested-sema4`. CanonicalAST **242/242** `wave-b-nested-canonical2`.
Frontend CanonicalAST **80/82** — exclusive UBT now is `wave-b-frontend-codegen-next.md`, not a nested-extract redo.
**Leave 13.2 / 9.5 `[ ]` after this slice too.**

## Gate

`attachments/wave-b-body-attach-next.md` GREEN: `ActOnReturnStmt` no longer `SetBody`; function body is Block; Parser `ActOnParsedStmt` nested statements + closed block; WalkOne/Lambda attach-only Compound.

## What this slice is

Dedicated parents already intern: If / While / For / Switch / DoWhile / Foreach / Case.

Leftover is **child extract**, not leftover intern of those parent kinds:

| Parent | Leftover child path |
| --- | --- |
| If | `ActOnStmtFromNode` then/else `as_sema_decl.cpp:1775-1779` |
| While | body FromNode `:1764` |
| For | init/body FromNode |
| Switch | case children FromNode |
| DoWhile | body FromNode |
| Foreach | vars/body FromNode |
| Case | inner stmts FromNode `:1925` |
| LocalDecl in a block arm | inlined `EmitLocalDeclStmts` instead of `ActOnLocalDeclStmt` (`as_sema_stmt.cpp:523`) — keep **flat** sibling `STMT_EXPR` |

## Must prove

1. Incomplete `if (1) return 1` (or missing then-close) intern If + Return without duplicating on successful parse (FindExisting).
2. Then/else / loop body / case inners intern through dedicated `ActOn*Stmt` or FindExisting of Parser `ActOnParsedStmt` children — **zero** `ActOnStmtFromNode` as intern of those children.
3. Nested blocks still do not steal the function body.
4. LocalDecl stay flat. Do not reintroduce F4 block-range ASSIGN collapse.
5. SemaAuthority + CanonicalAST + Compiler GREEN.
6. **Did not check 13.2 / 9.5.** Capture plan still CodeGen-owned.

## Must not

- Start before body attach GREEN
- Redo If/While/For parent intern
- `NotifySema` (WalkOne) instead of `ActOnParsedStmt`
- Wave E–G, default CANONICAL, script `funcdef` / `@`
