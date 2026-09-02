# Wave B remaining Parser Sema action (B-parser-foreach)

> **LANDED (header + complete body).** Do not redo. Header: SemaAuthority **75/75**, CanonicalAST **90/90**. Complete body: SemaAuthority **77/77**, CanonicalAST **92/92**. Next exclusive UBT is `attachments/wave-b-parser-control-body.md`. **13.2 stays `[ ]`.**

> **For later exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild.ps1 -NoXGE` then the SemaAuthority prefix **before** filling `as_parser.cpp` / `as_sema*`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2.

**Goal:** Clang-shaped Parser `ActOnParsedStmt` for `foreach` so an incomplete `foreach (int x :` still interns the loop and the loop variable. This is **not** 13.2 close and **not** production `Build()` routing.

**Prerequisite (do not redo):** B-parser-for and B-sema-identity are green (SemaAuthority **73/73**, Compiler CanonicalAST **88/88**).

**Architecture today:** `ParseForeach` has no incremental ActOn. Complete WalkOne of `snForEach` is still missing (`as_sema_stmt.cpp` has no `snForEach` case). Error-path-only ActOn so complete WalkOne owns the body, same as for/do-while.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-parser-foreach** |
| Mode now | **Attachment only.** Do not edit fork sources. Do not run UBT. Do not mark `tasks.md`. |
| Mode later | Exclusive UBT **after D-r09-2-7**, or when no `as_bytecode_codegen.cpp` writer. **Do not mark 13.2.** |
| UBT mutex | One UBT user in `D:\as-cta`. `-NoXGE`. |

---

## TDD map

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

1. `ParserActOnForeachBeforeColonFails` — incomplete `foreach (int x :` must dump `kind=For` or the dump token used for foreach, plus `kind=Var name=x`. Confirm dump token first (`StmtKindName` has no ForEach today; may intern as For or need a dump name).
2. `ParserActOnForeachDoesNotDuplicateOnSuccessfulParse` — one foreach stmt on a complete `foreach (int x : Range)`.

RED: incomplete method fails for missing ActOn. Duplicate may already pass if WalkOne of `snForEach` is added in the same GREEN (today there is **no** `snForEach` case — duplicate may also fail).

GREEN (minimal):

- `ParseForeach`: `ActOnParsedStmt` on missing `:` / missing `)` error path only.
- `as_sema_stmt.cpp`: `snForEach` WalkOne + `FindExistingStmt`. Do not invent a new stmt kind unless dumps already have one.
- Do not re-enable script `funcdef` / `@` / `is`.

Verify:

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-parser-foreach-red
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-foreach-red
# after GREEN:
Tools\RunBuild.ps1 -NoXGE -Label wave-b-parser-foreach-green
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-foreach-green
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-parser-foreach-canonical
```

Leave **13.2 / 4.2 / 5.9 `[ ]`**.
