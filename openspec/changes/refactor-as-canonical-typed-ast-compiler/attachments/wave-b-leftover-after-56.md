# Wave B leftover intern after B-56 dump+oracles

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 / 4.2 / 5.4 / 5.6 / 9.5 stay `[ ]`.**

Supersedes the leftover intern table in `wave-b-leftover-after-term.md` for **post-B-56**. That file’s Term row stays landed. This map treats as **LANDED intern** (do not list as leftover intern of the parent kind): dedicated `ActOn*` through Term peel, body attach, nested extract, param intern, enumerator, DeclRef, Call, 5.4 dump OpaqueValue/Sequence/Logical/Conditional named parts, 5.6 safepoint dump + verifier oracles.

Assume exclusive UBT **B-56-body-owner** restores Frontend Seal (`decl-body`). This attachment is leftover intern / extract after that intent. **It is not a 13.2 close.**

Live file:line is this worktree (2026-08-22). LLVM/Clang is a shape reference only.

## Landed intern of language meaning (do not list as leftover intern of the parent kind)

Child extraction may still read `asCScriptNode`. That is leftover **extract**, not leftover intern of the parent.

| Slice | Intern authority | Live evidence |
| --- | --- | --- |
| Dedicated Call … postfix / sequence | dedicated `ActOn*` | SemaAuthority through **206/206** `wave-b-call-sema` |
| ctor / dtor / mixin / list-pattern / Term `++`/`--` | dedicated wrappers | landed |
| function / method / lambda **body attach** | `AttachParsedFunctionBody` `as_sema_decl.cpp:1190`; `SetBody` + `FUNCTION_ENTRY`; `ActOnReturnStmt` does **not** `SetBody` | **189/189**. Body-owner steal is **B-56-body-owner**, not leftover intern of Function |
| nested If then/else, loop bodies, switch cases | `InternParsedChildStmt` `as_sema_stmt.cpp:532` | **194/194** |
| Sema-owned captures | `asCDecl::captures` / `ActOnLambdaCapture` `as_sema.cpp:290` | CodeGen reads sealed list |
| Clang For/If named dump phases | observer `init=`/`then=`/`else=` | Not 5.6 |
| Param intern-after-name + identity | `ActOnStartParamDecl` + in-flight `FindExistingFunctionLike` | **202/202** `wave-b-param-sema2` |
| Enumerator intern | `ActOnStartEnumeratorDecl` / `ActOnParsedEnumerator` | **203/203** |
| DeclRef peel | `InternParsedDeclRef` → `ActOnDeclRefExpr` `as_sema_expr.cpp:1416` | **205/205** |
| Call peel | `InternParsedCall` → `ActOnCallExpr` `as_sema_expr.cpp:1446` | **206/206** |
| **Term peel** | `InternParsedExprTerm` `as_sema_expr.cpp:1520` extract then `ActOnUnary` / `InternParsedCall` / `ActOnMember` / `ActOnIndex` / `ActOnPostfixCall` / `ActOnSequence`. No whole-term CALL FindExisting. `ActOnParsedExpr` `snExprTerm` does **not** whole-node FromNode | **208/208** `wave-b-term-sema2` |
| **5.4 dump** OpaqueValue + Sequence `literal=opaque`; Logical `lhs=`/`rhs=`; Conditional `cond=`/`then=`/`else=` | `ActOnOpaqueValueExpr` `as_sema.cpp:819`; `ActOnAssignExpr` `+=` rewrite `as_sema_expr.cpp:666` | **212/212** `wave-b-54-sema3`. Generate/VM is a **separate** package |
| **5.6 dump + verifier oracles** | `asEASTSafePointRole` + `safepoint=` on compile→seal; skipped-nearer / default-order / fallthrough-target | SemaAuthority **213/213** `wave-b-56-sema`. Verifier **16/16**. Not 5.6 close |

`WalkParameterList` / `WalkParameterSequence` still **fill-extract** Param for lambda / import / rejected `snFuncDef`. That is leftover **extract** of Param, not leftover intern of Param.

Term child extract still `ActOnExprFromNode` for pre-op inner, index child, postfix args, and non-op children. That is leftover **extract** of those children, not leftover intern of Term.

## Remaining leftover that still carries language meaning via FromNode / WalkOne extract

| Row | Current path (file:line) | Dedicated ActOn already? | Next peel? | Blocks 13.2? |
| --- | --- | --- | --- | --- |
| leftover `ActOnParsedExpr` `default` | `as_sema_decl.cpp:1903` → `ActOnExprFromNode`. Parser `ActOnParsedExpr` roots are only listed kinds: `snCast` `as_parser.cpp:1551`, `snFunctionCall` `:1862`, `snVariableAccess` `:1881`, `snConstructCall` `:1899`, `snAssignment` `:2078`, `snCondition` `:2113`, `snExpression` `:2186`, `snExprTerm` `:2234`. No Parser path sends `snExprValue` / `snArgList` / `snNamedArgument` / `snFunction` / `snConstant` / `snInitList` as the ActOn root | Known kinds listed (Call / DeclRef / Term / Cast / Construct / Assign / Expression / Condition / InitList / literals) | **Keep as recovery** for unknown / rejected. **No dump intern-creates inside this default today.** Do **not** intern `try`/`catch` / script `funcdef` / `@` / `is` as language | **No** (rejected/unknown) |
| QualType FromNode recovery | `ActOnQualTypeFromNode` `as_sema_decl.cpp:372` (`CollectQuals` `:166` + `FormatTypeKey` `:232`) → `ActOnQualType` `:287`. Used by Param / Cast / Construct / LocalDecl / WalkOne Var / import / `FindExistingFunctionLike` `:1084` | QualType intern dedicated | Keep as **recovery extract**. Not an intern peel. 4.3 stays `[ ]` (template instance / namespace still Builder) | **Partial** (canonical types input) |
| local-init still `ActOnExprFromNode`; keep flat sibling `STMT_EXPR` | `InternParsedCompoundStmt` `as_sema_stmt.cpp:608`–`:661` (ArgList/ConstructCall → `ActOnConstruct` `:654`; else `ActOnExprFromNode` `:658`); `EmitLocalDeclStmts` `:223` DECL + sibling EXPR assign; `ActOnParsedStmt` `snDeclaration` `as_sema_decl.cpp:2072`; `ActOnStmtFromNode` `:737`–`:743`; `ActOnLocalDeclStmt` `:251` wraps **two** children in `ActOnBlock` at the **declaration** range | LocalDecl intern dedicated | Do **not** nest inits. **F4 trap:** `asAST_STMT_DECL` only allocates; init assign is sibling `STMT_EXPR`; intern ASSIGN/DECL_REF at the **declaration** range, not the enclosing block. For-init LocalDecl: prefer wrapping BLOCK over inner DECL (`stmt-multi-owner`) | **Partial** (construction/lifetime input). Not leftover intern of LocalDecl |
| `WalkParameterList` fill-extract for lambda/import | `WalkParameterSequence` `as_sema_decl.cpp:527`; `WalkParameterList` `:583`. Lambda: `ParseLambda` `NotifySema` `as_parser.cpp:1810` **never** `ActOnParsedParam`; `ActOnLambdaFromNode` `:1231`. Import: WalkOne when `CountDeclParams==0` `:1376`. Intern-create function: `ActOnFunctionLike` `:895`. Rejected `snFuncDef` `:1331` | Param intern dedicated (`ActOnParsedParam` `as_parser.cpp:878` → `as_sema_decl.cpp:592` → `ActOnStartParamDecl`) | Keep as lambda/import **fill extract**. Do not re-intern Param from WalkOne as a new language kind. Do **not** intern script `funcdef` | **Partial** (signatures). Not leftover intern of Param |
| default-arg text extract | `ActOnParsedParam` `as_sema_decl.cpp:614` `CanonicalNodeText` + `SetDefaultArg`; same in `WalkParameterSequence` `:568`. Parser stores `SuperficiallyParseExpression` `as_parser.cpp:869`. Call intern `AppendDefaultArguments` `as_sema_expr.cpp:1263` synthesizes `ActOnIntegerLiteral` from that **text** (`default:` / `hidden:`) | Param intern dedicated | Leftover **extract** of default-arg meaning. Not intern of an owned default-arg expr. Not 5.3 close | **Partial** (5.3 call-plan input) |
| `ActOnParsedStmt` `default` | `as_sema_decl.cpp:2144` → `ActOnStmtFromNode`. FromNode `default` `as_sema_stmt.cpp:926` `try-catch-rejected` or recurse `firstChild` `:939`. `snFunction` as stmt is listed in FromNode `:747` → `ActOnLambdaFromNode`, so lambda-as-stmt hits this default then the listed arm | Return / If / loops / Switch / LocalDecl / ExprStmt / Case / jumps / Compound listed | Keep as recovery | **No** |
| WalkOne global/member init | WalkOne `snDeclaration` `as_sema_decl.cpp:1411`: global `ActOnExprFromNode` `:1454` + `ActOnGlobalVarInit`; member `IntegerInitText` + `SetDefaultArg` `:1459`. ParseStatementBlock also `NotifySema`s local `snDeclaration` `as_parser.cpp:4323` → WalkOne Var, then compound FindExisting | Var intern dedicated (`ActOnStartVarDecl`) | Leftover **extract** of init, not intern of Var. Mutable non-const primitive global stays diagnostic `mutable-global-rejected` `:1429` — do **not** intern as language | **Partial** |
| Child extract still `ActOnExprFromNode` (not leftover intern of parent) | Term: pre-op inner `as_sema_expr.cpp:1552`, index `:1583`, postfix args `:1594`, non-op `:1615`. Call args `:1509` (named `snNamedArgument` `:1501`). Cast/Construct/Assign/Expression/Condition/InitList children `as_sema_decl.cpp:1760`–`:1893`. Control cond / incr / return value `ActOnParsedStmt` `:1949`–`:2036`. `ActOnExprFromNode` itself still intern-creates those **landed** kinds when used as extract (`as_sema_expr.cpp:1626`) | Parent intern dedicated | **No parent-kind peel.** Not a next exclusive UBT unless a dump intern-creates inside `ActOnParsedExpr` `default` | **Partial** (lookup/overload still run during child extract of already-dedicated kinds) |
| `ActOnLambdaFromNode` still FromNode extract | `as_sema_decl.cpp:1207` → `ActOnLambdaExpr` `:1226` + `WalkParameterList` `:1231` + `AttachParsedFunctionBody` `:1239`. WalkOne `:1392`. `ActOnExprFromNode` `snFunction` `as_sema_expr.cpp:1781`. `ActOnStmtFromNode` `snFunction` `as_sema_stmt.cpp:747` | `ActOnLambdaExpr` dedicated | Leftover **extract** of lambda params/body. Not leftover intern of Lambda. Do not peel Lambda again | **Partial** (5.9 closures). Not next peel |
| WalkOne named-decl fill | `ActOnParsedDeclaration` → `WalkOne` `as_sema_decl.cpp:1243` (namespace/class/enum/function/import/var). `WalkReturnConstants` `:454` / WalkOne `snReturn` `:1408` FindExisting then intern integer Return | Dedicated `ActOnStart*` for named decls; `ActOnReturnStmt` dedicated | Leftover **extract** of the syntax walk (4.2). Not leftover intern of Class/Function/Return. Builder remains production decl authority | **Partial** (4.2). Not 4.2 close |

`ActOnExprFromNode` `default` `as_sema_expr.cpp:1792` only recurses `firstChild` (wrapper recovery). After the rows above, **no remaining parent-kind intern-create inside FromNode is language meaning** except recovery/rejected and the listed extracts.

`snArgList` / named args / pre-op / post-op / scope / `snExprValue` / `snUndefined` / `snAccessDeclaration` / `snClassDefaultStatement` / `snVirtualProperty` stay **recovery**. Do **not** intern as language: script `funcdef` / `@` / `is` / try-catch / dictionary / mutable globals as language / C labeled break.

`@` in `ParseExprPreOp` BNF (`as_parser.cpp:2319`) must not become dedicated unary intern. `ttIs` / `ttNotIs` still spelled in `ActOnExprFromNode` `snExpression` `as_sema_expr.cpp:1725` — keep rejected. Handle `@` in QualType keys (`as_sema.cpp:208`) is a **type qualifier spelling**, not script `@` as an expression.

Materialize/Cleanup wrapping inside `ActOnCallExpr` / `ActOnConstruct` (`as_sema_expr.cpp:553`, `as_sema.cpp:1019`) is leftover **lifetime intern** (5.7/5.8), not a FromNode peel. Do not start it as the next intern.

## What this map is not

- **Not 13.2 close.** Task 13.2 is a Sema **environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets) so backends do not rerun Sema. Dedicated leftover intern peels and dump `callee=` / `safepoint=` / `literal=opaque` are **not** that environment.
- **Not 4.2 close.** Builder is still production declaration authority. Parser is not action-only for the language.
- **Not 5.4 close.** Dump plan landed. Generate still fail-closes `Make()[0] += 1` (`EmitDeclRef` dangling). OpaqueValue emit is passthrough. Isolated AST-driven VM traces do not exist. See `wave-b-54-generate-remaining.md` (separate package). Do not rewrite the dump brief.
- **Not 5.6 close.** Dump roles + verifier oracles landed. Backends still rerun Sema. Frontend Seal restore is **B-56-body-owner**, not this map.
- **Not 9.5 close.** Named production rows + F1–F5 slices are landed; the spec sentence is full-language CodeGen.
- **LEGACY still `asCCompiler`** (default pipeline still reruns Sema).
- Not F1 remainder / F6 / Wave E–G.
- Not a second FromNode intern peel of Call / DeclRef / Term / OpaqueValue / safepoint.

## Suggested intern order AFTER `B-56-body-owner` GREEN

**B-56 dump+oracles landed** (SemaAuthority **213/213**, Verifier **16/16**). **Next exclusive UBT in this worktree is `B-56-body-owner`**, then this leftover map applies. **Do not check 13.2 / 4.2 / 5.4 / 5.6 / 9.5.**

1. **Do not** start another FromNode intern peel unless a dump still intern-creates inside `ActOnParsedExpr` `default`. Recovery stays recovery. Parser ActOn roots are already listed kinds.
2. **Do not** nest local-init. Keep flat sibling `STMT_EXPR` (F4 trap). Keep stmt `default` and QualType FromNode as recovery.
3. `WalkParameterList` may stay as lambda/import fill extract after Param intern. Do not re-intern Param. Do not intern script `funcdef`.
4. Default-arg stays text extract until a later 5.3 call-plan slice. Not this intern peel.
5. **5.4 Generate / VM** is a **separate** package after `wave-b-54-generate-remaining.md` + body-owner GREEN. Dump already landed. Not leftover intern.
6. **No Wave E–G.**

Leave `tasks.md` **13.2 / 4.2 / 5.4 / 5.6 / 9.5 `[ ]`.**
