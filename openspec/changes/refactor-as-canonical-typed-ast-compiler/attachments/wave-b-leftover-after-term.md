# Wave B leftover intern after snExprTerm peel

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 stays `[ ]`.** Do not check 4.2 / 9.5 / 13.3 / 5.4 / 5.6 / 5.9.

Supersedes the leftover intern table in `wave-b-leftover-after-param.md` for `snExprTerm`. That file’s Term row is **stale**: `InternParsedExprTerm` is the **intended intern of Term**. Identity GREEN **208/208** `wave-b-term-sema2` after dropping whole-term CALL FindExisting (`wave-b-term-fix-next.md`). This map treats Term intern as landed.

Live file:line is this worktree (2026-08-22). LLVM/Clang is a shape reference only.

## Landed intern of language meaning (do not list as leftover intern of the parent kind)

Child extraction may still read `asCScriptNode`. That is leftover **extract**, not leftover intern of the parent.

| Slice | Intern authority | Live evidence |
| --- | --- | --- |
| Dedicated Call … postfix / sequence | dedicated `ActOn*` | SemaAuthority through **206/206** `wave-b-call-sema` |
| ctor / dtor / mixin / list-pattern / Term ++/-- | dedicated wrappers | landed |
| function / method / lambda **body attach** | `AttachParsedFunctionBody`; `ActOnReturnStmt` does **not** `SetBody` | **189/189** |
| nested If then/else, loop bodies, switch cases | `InternParsedChildStmt` | **194/194** |
| Sema-owned captures | `asCDecl::captures` / `ActOnLambdaCapture` | CodeGen reads sealed list |
| Clang For/If named dump phases | observer `init=`/`then=`/`else=` | Not 5.6 |
| Param intern-after-name + identity | `ActOnStartParamDecl` + in-flight `FindExistingFunctionLike` | **202/202** `wave-b-param-sema2` |
| Enumerator intern | `ActOnStartEnumeratorDecl` | **203/203** |
| DeclRef peel | `InternParsedDeclRef` → `ActOnDeclRefExpr` | **205/205** |
| Call peel | `InternParsedCall` → `ActOnCallExpr` | **206/206** |
| **Term peel** | `InternParsedExprTerm` extract then `ActOnUnary` / `InternParsedCall` / `ActOnMember` / `ActOnIndex` / `ActOnPostfixCall` / `ActOnSequence`. No whole-term CALL FindExisting. `ActOnParsedExpr` `snExprTerm` does **not** whole-node FromNode | Identity GREEN **208/208** `wave-b-term-sema2` — **not** leftover intern of Term |

`WalkParameterList` / `WalkParameterSequence` still **fill-extract** Param for lambda / import / rejected `snFuncDef`. That is leftover **extract** of Param, not leftover intern of Param.

Term child extract still `ActOnExprFromNode` for pre-op inner, index child, postfix args, and non-op children. That is leftover **extract** of those children, not leftover intern of Term.

## Remaining leftover that still carries language meaning via FromNode / WalkOne extract

| Row | Current path | Dedicated ActOn already? | Next peel? | Blocks 13.2? |
| --- | --- | --- | --- | --- |
| leftover `ActOnParsedExpr` `default` | `ActOnExprFromNode` for unknown kinds (`as_sema_decl.cpp` ActOnParsedExpr default) | Known kinds listed (Call / DeclRef / Term / Cast / Construct / Assign / Expression / Condition / InitList / literals) | Keep as recovery for unknown / rejected. Do **not** intern `try`/`catch` / script `funcdef` / `@` / `is` as language | **No** (rejected/unknown) |
| local-init still `ActOnExprFromNode`; keep flat sibling `STMT_EXPR` | `InternParsedCompoundStmt` init children FromNode; `EmitLocalDeclStmts` DECL + sibling EXPR assign | LocalDecl intern dedicated | Do **not** nest inits. **F4 trap:** intern ASSIGN/DECL_REF at the **declaration** range | **Partial** (construction/lifetime input). Not leftover intern of LocalDecl |
| `ActOnParsedStmt` `default` | `ActOnStmtFromNode`. Known kinds listed | Return / If / loops / Switch / LocalDecl / ExprStmt / Case / jumps / Compound | Keep as recovery | **No** |
| QualType FromNode extract | `ActOnQualTypeFromNode` → `ActOnQualType` | QualType intern dedicated | Keep as **recovery extract**. Not an intern peel | **Partial** (canonical types input) |
| WalkOne global/member init | `ActOnExprFromNode` on Var init | Var intern dedicated (`ActOnStartVarDecl`) | Leftover **extract** of init, not intern of Var | **Partial** |
| default-arg text | `CanonicalNodeText` + `SetDefaultArg` on Param | Param intern dedicated | Leftover **extract** of default-arg meaning | **Partial** (5.3 call-plan input) |

`snArgList` / named args / pre-op / post-op / scope / `snExprValue` / `snUndefined` / script `funcdef` / `@` / `is` / try-catch stay **recovery or rejected**. Do not intern as language.

## What this map is not

- **Not 13.2 close.** Task 13.2 is a Sema **environment** so backends do not rerun Sema. Dedicated leftover intern peels and dump `callee=` are **not** that environment.
- **LEGACY still `asCCompiler`** (default pipeline still reruns Sema).
- Term identity GREEN is leftover intern of Term, **not** 13.2. Do not revert `InternParsedExprTerm`.
- Not F1 remainder / F6 / Wave E–G. Not 5.4 / 5.6 implement (those have their own TDD briefs). `IndexCompoundAssignEvaluatesBaseOnce` is a **weak** count lock for 5.4, not the OpaqueValue plan.

## Suggested intern order after `B-term-fix` GREEN

**B-term-fix landed** (SemaAuthority **208/208**). **B-54 dump landed. B-56 dump+oracles landed. Next exclusive UBT is `B-56-body-owner`.** **Do not check 13.2 / 4.2 / 9.5 / 5.4 / 5.6.**

1. **Do not** start another FromNode intern peel unless a dump still intern-creates inside `ActOnParsedExpr` `default`. Recovery stays recovery.
2. **Do not** nest local-init. Keep flat sibling `STMT_EXPR` (F4 trap). Keep stmt `default` and QualType FromNode as recovery.
3. **B-54-single-eval dump landed** (`wave-b-54-sema3` **212/212**). Generate still fail-closes `Make()[0] += 1` (`EmitDeclRef` dangling). Not 5.4 close.
4. **B-56-safepoint dump+oracles landed** (SemaAuthority **213/213**, Verifier **16/16**). Frontend Seal **82/85** `decl-body` — `wave-b-56-body-owner-next.md`. Named For/If phases already dump — do not redo.
5. **No Wave E–G.**

`WalkParameterList` may stay as lambda/import fill extract after Param intern. Do not re-intern Param from WalkOne as a new language kind.
