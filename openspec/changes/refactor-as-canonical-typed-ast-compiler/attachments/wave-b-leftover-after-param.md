# Wave B leftover intern after 4.2 param intern

> **Stale on `snExprTerm` (2026-08-22).** DeclRef + Call peels landed. `InternParsedExprTerm` is implemented; identity is RED **200/208**. Live leftover map: `wave-b-leftover-after-term.md`. Live exclusive UBT: `wave-b-term-fix-next.md`.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 stays `[ ]`.** Do not check 4.2 / 9.5 / 13.3 / 5.4 / 5.6 / 5.9.

Supersedes the leftover intern table in `wave-b-leftover-after-nested.md`. That file’s `snParameterList` row is **stale**: param intern-after-name + `ActOnParsedParam` is the **intended intern of Param**. Identity of that intern is still RED (`ConstructorOverloadsSelectExactCtorNotFirstName`, `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails`) and belongs to exclusive UBT `B-param-identity` (`wave-b-param-identity-next.md`). This map treats Param intern as landed-as-intern anyway.

Live file:line is this worktree (2026-08-22). LLVM/Clang is a shape reference only.

## Landed intern of language meaning (do not list as leftover intern of the parent kind)

Child extraction may still read `asCScriptNode`. That is leftover **extract**, not leftover intern of the parent.

| Slice | Intern authority | Live evidence |
| --- | --- | --- |
| Dedicated Call … postfix / sequence | dedicated `ActOn*` (`ActOnCallExpr` / Cast / Construct / Assign / Binary / Logical / Member / Index / Unary / PostfixCall / Sequence) | SemaAuthority through **186/186**. `ActOnParsedExpr` may still whole-node FromNode for Call / VarAccess / `snExprTerm` — leftover **extract**, not leftover intern of those parent kinds |
| ctor / dtor / mixin | `ActOnStartConstructorDecl` / Destructor / Mixin | `wave-b-ctor-sema` |
| `snListPattern` | `ActOnListPatternDecl` generated VAR + origin (`as_sema_decl.cpp:1594`) | Not InitList `{1,2}` |
| leftover Term `++`/`--` | `ActOnUnaryExpr(..., postfix)` → `opPreInc` / `opPostInc` / `opPreDec` / `opPostDec` | `wave-b-inc-sema` |
| function / method / lambda **body attach** | `AttachParsedFunctionBody` (`as_sema_decl.cpp:1142`): FindExisting BLOCK or `InternParsedCompoundStmt`, then `SetBody`. `ActOnReturnStmt` does **not** `SetBody` | `wave-b-body-sema` **189/189** |
| nested If then/else, loop bodies, switch cases | `InternParsedChildStmt` FindExisting + dedicated `ActOn*Stmt`. ParseCase incremental ActOn. Switch does **not** `ClearStmtChildren` | `wave-b-nested-sema4` **194/194** |
| Sema-owned captures | `asCDecl::captures` / `ActOnLambdaCapture` (`as_sema.cpp:290`). `RecordLambdaCaptures` after body attach (`as_sema_decl.cpp:1132`, `:1155`) | CodeGen reads the sealed list. Not a complete capture/lifetime plan |
| Clang For/If named dump phases | observer `as_ast_dump.cpp:221` `init=`/`body=`/`incr=`; `:228` `then=`/`else=` | Compile→seal dumps. Not 5.6 |
| **Param intern-after-name** | `ParseFunction` `NotifySema` after name (`as_parser.cpp:3680`) then `ParseParameterList` `ActOnParsedParam` after each complete param (`as_parser.cpp:876` → `as_sema_decl.cpp:592` → `ActOnStartParamDecl` FindExisting parent+name `as_sema.cpp:395`). Incomplete `int F(int A, float` keeps Function F + Param A | Three param tests PASS. Identity still RED — **not** leftover intern of Param |

`WalkParameterList` / `WalkParameterSequence` (`as_sema_decl.cpp:527`, `:583`) still **fill-extract** Param for lambda (`ParseLambda` never calls `ActOnParsedParam`; `ActOnLambdaFromNode:1182`), import (`WalkOne` when `CountDeclParams==0` `:1324`), rejected `snFuncDef` (`:1277`), and `ActOnFunctionLike` intern-create (`:868`). `ActOnStartParamDecl` FindExisting by name must not duplicate. That is leftover **extract** of Param, not leftover intern of Param.

## Remaining leftover that still carries language meaning via FromNode / WalkOne extract

| Row | Current path | Dedicated ActOn already? | Next peel? | Blocks 13.2? |
| --- | --- | --- | --- | --- |
| enumerator `snIdentifier` under enum | Parser `NotifySema(ident)` `as_parser.cpp:2997` → `ActOnParsedDeclaration` → WalkOne `snIdentifier` `as_sema_decl.cpp:1443` `ActOnVarDecl` const-int. WalkOne `snEnum` also intern-creates children `:1239`. Init `SuperficiallyParseVarInit` (`as_parser.cpp:3002`) is **not** interned as expr | Enum parent intern dedicated (`ActOnStartEnumDecl`). No `ActOnEnumeratorDecl`. FindExisting named VAR already | **Yes — next intern peel after identity GREEN.** Weak `B-enumerator`. Keep dump `kind=Var name=Red` `quals=1` (`ParserActOnEnumDeclAndEnumeratorBeforeListCloseFails`) | **No** as standalone kind |
| leftover `ActOnParsedExpr` whole-node FromNode arms | `snVariableAccess` **peeled** (`InternParsedDeclRef`). `snFunctionCall` **peeled**: `InternParsedCall` extract ident/args/scope then `ActOnCallExpr`. Still whole-node FromNode: `snExprTerm`, `default`. Call **args** still FromNode extract | `InternParsedCall` dedicated. `snExprTerm` still FromNode intern-create | Next peel: `snExprTerm` only if a dump still intern-creates inside FromNode | **Partial** (`snExprTerm` leftover extract) |
| local-init still `ActOnExprFromNode`; keep flat sibling `STMT_EXPR` | `InternParsedCompoundStmt` `as_sema_stmt.cpp:614` init children `ActOnExprFromNode` (ArgList/ConstructCall → `ActOnConstruct`); then **inlined** `EmitLocalDeclStmts` `:637` (`:221` DECL + sibling EXPR assign). `ActOnParsedStmt` `snDeclaration` `:2022` also `ActOnExprFromNode` then `ActOnLocalDeclStmt` | LocalDecl intern dedicated. `EmitLocalDeclStmts` **must** stay flat sibling `STMT_EXPR` | Do **not** nest inits. **F4 trap:** `asAST_STMT_DECL` only allocates; init assign is sibling `STMT_EXPR`; intern ASSIGN/DECL_REF at the **declaration** range, not the enclosing block | **Partial** (construction/lifetime input). Not leftover intern of LocalDecl |
| `ActOnParsedStmt` `default` | `ActOnStmtFromNode` `as_sema_decl.cpp:2094`. FromNode `default` `as_sema_stmt.cpp:902` `try-catch-rejected` or recurse firstChild | Known kinds listed (Return / If / loops / Switch / LocalDecl / ExprStmt / Case / jumps / Compound) | Keep as recovery for unknown / rejected. Do **not** intern `try`/`catch` as language | **No** (rejected/unknown) |
| QualType FromNode extract | `ActOnQualTypeFromNode` `as_sema_decl.cpp:372` → `ActOnQualType`. Used by Param / Cast / Construct / LocalDecl / WalkOne Var / import | QualType intern dedicated | Keep as **recovery extract**. Not an intern peel | **Partial** (canonical types input) |

`snArgList` / named args / pre-op / post-op / scope / `snExprValue` / `snUndefined` / script `funcdef` / `@` / `is` / try-catch stay **recovery or rejected**. Do not intern as language.

Default-arg text `CanonicalNodeText` + `SetDefaultArg` (`ActOnParsedParam` `as_sema_decl.cpp:614`, `WalkParameterSequence` `:568`) is leftover **extract** of default-arg meaning, not leftover intern of Param.

WalkOne global/member init `ActOnExprFromNode` (`as_sema_decl.cpp:1400`) is leftover **extract** of Var init, not leftover intern of Var (`ActOnStartVarDecl`).

## What this map is not

- **Not 13.2 close.** Task 13.2 is a Sema **environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets) so backends do not rerun Sema. Dedicated leftover intern peels, dump `type=` / `callee=` / `captures=` / `init=`, and Param intern tests are **not** that environment.
- **LEGACY still `asCCompiler`** (default pipeline still reruns Sema). Leftover intern after Param is **not** 13.2.
- Identity RED on intern-after-name is **not** leftover intern of Param. Do not revert intern-after-name from this map.
- Not F1 remainder / F6 / Wave E–G. Not 5.4 / 5.6 implement (those have their own TDD briefs).

## Suggested intern order after `B-param-identity` GREEN

Identity stays the other exclusive UBT. Do **not** start these while identity is RED. **Do not check 13.2 / 4.2 / 9.5.**

1. **`B-enumerator` (weak).** WalkOne `snIdentifier` under enum already intern-creates via `ActOnVarDecl` + FindExisting named VAR. Parser already `NotifySema(ident)`. Optional dedicated enumerator intern; keep `kind=Var` dumps. **Not 13.2.**
2. **One `ActOnParsedExpr` whole-node FromNode peel:** `snVariableAccess` → extract ident/scope then `ActOnDeclRefExpr` without whole-node FromNode (`as_sema_decl.cpp:1784`). Do not treat leftover Call/`snExprTerm` wrappers as 13.2.
3. Later optional: Call `ActOnParsedExpr` extract-then-`ActOnCallExpr`; then `snExprTerm` only if a dump still intern-creates inside FromNode.
4. **Do not** nest local-init. Keep flat sibling `STMT_EXPR` (F4 trap). Keep stmt `default` and QualType FromNode as recovery.
5. **No Wave E–G.** 5.4 OpaqueValue/Sequence and 5.6 safe-point are not leftover intern peels.

`WalkParameterList` may stay as lambda/import fill extract after Param intern. Do not re-intern Param from WalkOne as a new language kind.
