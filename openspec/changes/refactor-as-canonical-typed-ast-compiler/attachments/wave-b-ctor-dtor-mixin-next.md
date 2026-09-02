# Wave B leftover intern — exclusive UBT after F5 (`B-ctor-dtor-mixin`)

Worktree: `D:\as-cta`. Queued exclusive UBT package **B-ctor-dtor-mixin**.
Change: `refactor-as-canonical-typed-ast-compiler`.

**Do not start while `D-sixth-f5-exec` holds UBT.** Gate: F5 1-arg execute GREEN (`wave-d-f5-exec-next.md`).

**REQUIRED SUB-SKILLS (when this package takes UBT):** `superpowers:test-driven-development`, then `superpowers:verification-before-completion`.

Do **not** check `tasks.md` 13.2 / 13.3 / 4.2 / 5.9 / 9.5 / 10.2.
Do **not** archive. Do **not** commit unless the user asks.
Do **not** spawn a second UBT. Do **not** start Wave E–G.
Do **not** peel function-body `ActOnStmtFromNode`. Do **not** merge list-pattern into this RED/GREEN.

Default pipeline stays LEGACY. No Clang/LLVM link. No Unreal types in fork frontend files.
No script `funcdef` / `@` / `is`. `nullptr` = `ttNull`. Parser never `CreateNode(snMixin)` — mixin functions stay `snFunction`.

Inventory authority: `attachments/wave-b-leftover-after-postfix.md`. This file is the implementer brief.

---

## Goal

`snFunction` leftover forms **ctor / dtor / mixin** intern through dedicated `ActOnStart*` instead of classifying kind by walking tokens inside `ActOnFunctionLike`.

Builders `ActOnConstructorDecl` / `ActOnDestructorDecl` / `ActOnMixinDecl` already exist (`as_sema.h:32,33,38`). Builder presence ≠ intern. Generated lifecycle already calls those builders **with no script node**. User-written `T::T(int)` / `~T` / `mixin MixHelper` still intern by walking `ttBitNot` / name-equals-class / `ttMixin` in `ActOnFunctionLike` (`as_sema_decl.cpp:768-838`).

## Why this, not body / list-pattern / leftover `++`

- Function/method intern already has `ActOnStartFunctionDecl` / `ActOnStartMethodDecl`. `wave-b-fn-var-next.md` deferred ctor/dtor/mixin.
- Parser already NotifySema after name+params (`ParseFunction` `as_parser.cpp:3692`). Mixin uses that path.
- List-pattern is a different enumerator / 5.9 factory shape. Body attach is blocked until Parser incremental stmt ActOn (see leftover map).
- 13.2 names construction / lifetime next to call plans. This peel does **not** close 13.2.

## Suggested signatures

```cpp
asASTDeclId ActOnStartConstructorDecl(asASTDeclId parent, const char* name, const asCSourceRange& range);
asASTDeclId ActOnStartDestructorDecl(asASTDeclId parent, const char* name, const asCSourceRange& range);
asASTDeclId ActOnStartMixinDecl(asASTDeclId parent, const char* name, const asCSourceRange& range);
```

`FindExistingFunctionLike` first (do **not** collapse overloads by name). `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` must **not** absorb ctor/dtor (`T` is both class and ctor).

## Must prove (TDD)

1. No-script-node intern: `ActOnStartConstructorDecl(cls, "T", range)` dumps `kind=Constructor` (or current dump spelling `key=T::T()`). Same for destructor and mixin (`kind=Mixin name=MixHelper`). Overloads `T::T()` vs `T::T(int)` must **not** collapse.
2. WalkOne / `ActOnFunctionLike` extract-then-dedicated. Mixin stays `snFunction` + mixin prefix; do not `CreateNode(snMixin)`.
3. Generated lifecycle still uses builders without script node. Do not double-intern generated + user ctor.
4. **Body still `ActOnStmtFromNode` in this slice.**
5. SemaAuthority + CanonicalAST + Compiler GREEN.
6. Fork: no `@` / `is`; `nullptr` not `null`. Do not intern script `funcdef`.

Must not: treat builders as dedicated intern; start F5 (already a different package); flip default CANONICAL; check 13.2; merge list-pattern or body; CALL-without-callee.

## Verification (when this package owns UBT)

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-ctor-dtor-mixin
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-ctor-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-ctor-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-ctor-compiler -TimeoutMs 600000
```

**Leave 13.2 / 13.3 / 4.2 / 5.9 / 9.5 `[ ]`.**
