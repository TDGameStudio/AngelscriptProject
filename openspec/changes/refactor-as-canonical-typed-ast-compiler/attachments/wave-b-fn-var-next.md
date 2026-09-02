# Next exclusive UBT — B-fn-var

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
**Leave 13.2 / 13.3 / 10.2 / 9.5 / 5.6 `[ ]`.** One UBT. TDD. LLVM/Clang shape only (no link).

Companion: `async-work.md`, `async-dispatch.md`, `wave-b-leftover-after-local.md` (header stale vs named-decl intern; leftover function/var/postfix rows still live).

## Why this slice, not postfix / F4 / Wave G

Named-decl parent intern is now dedicated through namespace / class / enum / interface / typedef / import (`wave-b-decl-rest-sema` **173/173**). Remaining WalkOne intern that still **creates** language decls is:

1. `snFunction` function / method / mixin / ctor / dtor (`ActOnFunctionLike` `as_sema_decl.cpp:768`, WalkOne `:1180-1207`)
2. global / member `snDeclaration` (`WalkOne` `:1212-1256` still `ActOnVarDecl` after QualTypeFromNode)
3. `snListPattern` generated `ActOnVarDecl` name `list-pattern`

`snExprTerm` leftover postfix `()` still decides call vs construct inside FromNode (`as_sema_expr.cpp:1400-1446` uses builder `ActOnCall`, not `ActOnCallExpr`). That is the **next** intern after this slice, not this UBT.

F4 LEGACY lambda, stored closures, Wave E–G, default CANONICAL: forbidden now.

## Dedicated intern (must prove)

Clang-shaped wrappers around existing builders. Builder presence ≠ intern.

```cpp
asASTDeclId ActOnStartFunctionDecl(asASTDeclId parent, const char* name, const asCQualType& returnType, const asCSourceRange& range);
asASTDeclId ActOnStartMethodDecl(asASTDeclId parent, const char* name, const asCQualType& returnType, const asCSourceRange& range);
asASTDeclId ActOnStartVarDecl(asASTDeclId parent, const char* name, const asCQualType& type, const asCSourceRange& range);
```

Must prove (TDD, no-script-node):

1. `ActOnStartFunctionDecl(Tu, "Entry", intType, range)` dumps `kind=Function name=Entry`
2. After `ActOnStartClassDecl(Tu, "T", range)`, `ActOnStartMethodDecl(cls, "M", intType, range)` dumps `kind=Method name=M`
3. `ActOnStartVarDecl(Tu, "SharedCount", intType, range)` dumps `kind=Var name=SharedCount`

WalkOne extract-then-dedicated:

- `snFunction` non-lambda: `FindExistingFunctionLike` first (overloads must **not** collapse by name). If missing, extract name/returnType/parent kind then `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` / existing ctor/dtor/mixin builders. Body still `ActOnStmtFromNode` → already-dedicated `ActOnCompoundStmt` (do **not** merge body-attach into this slice).
- Lambda expr stays `ActOnLambdaFromNode` → `ActOnLambdaExpr`. Do not intern `"function"` as a parameter (F4).
- global `snDeclaration`: extract name+QualType then `ActOnStartVarDecl`. Mutable globals stay intern-then-reject.
- `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` must **not** `FindExistingNamedDecl` by name only (that reuses `F(int)` for `F(float)`).
- `ActOnStartVarDecl` **may** `FindExistingNamedDecl` by name+`VAR` (vars do not overload).

Do not: intern script `funcdef`; flip default CANONICAL; check 13.2; start postfix `()`; nest LocalDecl init in a Block; CALL-without-callee.

Expected after GREEN: SemaAuthority **176/176**, CanonicalAST **216/216**, Compiler **404/404** (173+3) unless live count differs.

## Commands (from `D:\as-cta` only)

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-fn-var-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-fn-var-impl
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-fn-var-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-fn-var-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-fn-var-compiler -TimeoutMs 600000
```

`RunTests.ps1` does **not** UBT. Always `RunBuild.ps1` after impl.

Copy each `Summary.json` under the label dir. Append `B-fn-var` to `wave-b-results.md`. Patch `tasks.md` 13.2 **progress notes only**.
