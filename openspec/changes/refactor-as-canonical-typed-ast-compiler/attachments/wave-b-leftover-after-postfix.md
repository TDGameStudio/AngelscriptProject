# Wave B leftover intern after PostfixCall / Sequence

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 stays `[ ]`.** Do not check 13.3 / 9.5 / 4.2 / 5.9 / 5.6 from this map.

**Status 2026-08-22 post nested extract:** ctor/dtor/mixin, `snListPattern`, leftover Term `++`/`--`, body attach, and nested extract are **landed**. This file’s “must wait / queued nested extract” rows are **stale**. Live leftover map: `wave-b-leftover-after-nested.md`. Exclusive UBT now: `wave-b-frontend-codegen-next.md`. Live 梳理: `async-work.md`.

**Goal (historical):** After dedicated intern through Call … Function / Method / Var **and** `ActOnPostfixCallExpr` / `ActOnSequenceExpr`, list leftover intern kinds. That peel order is finished through ctor / list-pattern / ++/-- / body attach / nested extract. **Do not execute this file as the live intern queue.** Use `wave-b-leftover-after-nested.md` and `wave-b-frontend-codegen-next.md`.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM. Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null` (`as_tokendef.h` maps `"nullptr"` → `ttNull`). **F5 LEGACY lambda (`wave-d-95-f4-next.md`) is not this inventory.**

Live file:line is this worktree (2026-08-22). Historical companions (do not collide; do not treat as current intern):

- `wave-b-leftover-after-local.md` — leftover after LocalDecl / InitList; **stale** vs Break … Function / Method / Var / Postfix / Sequence
- `wave-b-fromnode-inventory.md` — 51-kind historical map (Cast/Assign still “in progress” there)
- `async-work.md` — current 梳理; leftover list there is the dispatch snapshot this file refreshes
- `wave-d-f4-exec-next.md` — exclusive UBT now (CodeGen execute 42). Not an intern peel
- `wave-d-95-f4-next.md` — F5 LEGACY lambda node-layout; **queued, not this inventory**

`eScriptNode` has **49** enumerators (`as_scriptnode.h:47-99`).

## 13.2 stays `[ ]`

Task 13.2 is a Sema **environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets) so CANONICAL backends do not rerun Sema. Dedicated postfix / sequence intern, SemaAuthority prefix greens, dump `type=` / `callee=` / `target=`, F4 uniquing, and a later ctor / list-pattern / body peel do **not** close it. Incomplete 4.2–5.9 keeps the box `[ ]`. Dedicated leftover peels do not close it.

## Dedicated intern after postfix (do not list as leftover intern of the parent kind)

Child extraction may still read `asCScriptNode` and still call leftover FromNode for **children**. That is leftover children, not leftover intern of the parent kind. Builder presence ≠ intern.

| Kind | Dedicated intern | Extract wrapper may still read `asCScriptNode` |
| --- | --- | --- |
| `snFunctionCall` | `ActOnCallExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1527-1529` still whole-node FromNode extract; FromNode `as_sema_expr.cpp:1348-1415` then `ActOnCallExpr` |
| `snCast` | `ActOnCastExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1530-1548`; FromNode `as_sema_expr.cpp:1441-1458` |
| `snConstructCall` | `ActOnConstruct` | `ActOnParsedExpr` `as_sema_decl.cpp:1550-1565`; FromNode `as_sema_expr.cpp:1416-1439` |
| `snAssignment` | `ActOnAssignExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1567-1587`; FromNode `as_sema_expr.cpp:1601-1618` |
| `snExpression` | `ActOnBinaryExpr` / `ActOnLogicalExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1589-1617`; FromNode `as_sema_expr.cpp:1556-1583` still spells `ttIs` / `ttNotIs` — script `is` stays rejected |
| `snVariableAccess` | `ActOnDeclRefExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1619-1621` still whole-node FromNode; FromNode `as_sema_expr.cpp:1324-1346` |
| `snInitList` | `ActOnInitList` | `ActOnParsedExpr` `as_sema_decl.cpp:1622-1631`; FromNode `as_sema_expr.cpp:1622-1629`. **Not** decl `snListPattern` |
| `snCondition` | `ActOnConditionalExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1670-1686`; FromNode `as_sema_expr.cpp:1585-1599`. Missing-arm recovery recurses firstChild |
| `snConstant` | `ActOnIntegerLiteral` / `ActOnBoolLiteral` / `ActOnFloatLiteral` / `ActOnDoubleLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral` | `ActOnParsedExpr` `as_sema_decl.cpp:1636-1668` dedicated token switch; FromNode `as_sema_expr.cpp:1296-1323`. Fork intern `nullptr` (`ttNull`), not script `null` |
| `snReturn` | `ActOnReturnStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1728-1745`; value child may FromNode |
| `snIf` | `ActOnIfStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1747-1758`; then/else still `ActOnStmtFromNode` |
| `snWhile` | `ActOnWhileStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1760-1766` |
| `snFor` | `ActOnForStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1768-1785` |
| `snSwitch` | `ActOnSwitchStmt` + `FinishSwitchStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1787-1804`; case children still StmtFromNode |
| `snDoWhile` | `ActOnDoWhileStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1806-1812` |
| `snForEach` | `ActOnForeachStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1814-1832` |
| `snDeclaration` **local** | `ActOnLocalDeclStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1834-1867`; FromNode `as_sema_stmt.cpp:538-569`. Global / member uses dedicated `ActOnStartVarDecl` via WalkOne extract |
| `snExpressionStatement` | `ActOnExpressionStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1869-1873`; child expr may FromNode |
| `snCase` | `ActOnCaseStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1875-1904`; inner stmts still StmtFromNode. `ParseCase` still has **no** NotifySema |
| `snBreak` | `ActOnBreakStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1906-1910`; FromNode `as_sema_stmt.cpp:742-743` |
| `snContinue` | `ActOnContinueStmt` | `as_sema_decl.cpp:1912-1916`; FromNode `as_sema_stmt.cpp:744-745` |
| `snFallthrough` | `ActOnFallthroughStmt` | `as_sema_decl.cpp:1918-1922`; FromNode `as_sema_stmt.cpp:746-747`. `target=` still `FinishSwitchStmt` → `WireFallthroughTargets` (5.6-open) |
| `snStatementBlock` as **Compound** | `ActOnCompoundStmt` | FromNode `as_sema_stmt.cpp:468-536` still **walks children** then `ActOnCompoundStmt`. `ActOnParsedStmt` has **no** listed case → `default` `as_sema_decl.cpp:1924` whole-node FromNode. Nested-block comment `:534-535`: must not steal the function body |
| `snDataType` | `ActOnQualType` `as_sema.h:104` | `ActOnQualTypeFromNode` `as_sema_decl.cpp:372-387` is leftover **extract**; then `ActOnQualType` |
| Member / Index / Unary / Postfix `()` / Sequence (not unique enumerators) | `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` / `ActOnPostfixCallExpr` / `ActOnSequenceExpr` | FromNode `snExprTerm` extract `as_sema_expr.cpp:1459-1554`. `ActOnParsedExpr` `snExprTerm` `as_sema_decl.cpp:1633-1635` still whole-node FromNode. **`snExprTerm` leftover intern** is remaining postfix that is not `.` / `[]` / `()` (builder `ActOnUnary` `:1535`, `:1540`) |
| `snFunction` as **lambda expr** | `ActOnLambdaExpr` | `ActOnLambdaFromNode` `as_sema_decl.cpp:1007-1046` is **not** dedicated intern. Body still `ActOnStmtFromNode` `:1042`. Parser `ParseLambda` `NotifySema` `as_parser.cpp:1799` |
| `snNamespace` | `ActOnStartNamespaceDecl` | WalkOne `as_sema_decl.cpp:1061-1067` extract-then-dedicated |
| `snClass` | `ActOnStartClassDecl` | WalkOne `as_sema_decl.cpp:1069-1082` + bases + `EnsureGeneratedLifecycle` / `EnsureGeneratedAccessors` |
| `snEnum` | `ActOnStartEnumDecl` | WalkOne `as_sema_decl.cpp:1093-1117`; enumerator children still `ActOnVarDecl` |
| `snInterface` | `ActOnStartInterfaceDecl` | WalkOne `as_sema_decl.cpp:1084-1091` |
| `snTypedef` | `ActOnStartTypedefDecl` | WalkOne `as_sema_decl.cpp:1119-1124` |
| `snImport` | `ActOnStartImportDecl` | WalkOne `as_sema_decl.cpp:1134-1182`; origin + `ActOnQualTypeFromNode` + `WalkParameterList` |
| `snFunction` as **function / method** | `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` | WalkOne `as_sema_decl.cpp:1184-1211` `FindExistingFunctionLike` then `ActOnFunctionLike` `as_sema_decl.cpp:768`. **Ctor / dtor / mixin still classified inside `ActOnFunctionLike` (leftover intern of those decl kinds).** Body still `ActOnStmtFromNode` `:1207` |
| `snDeclaration` **global / member** | `ActOnStartVarDecl` | WalkOne `as_sema_decl.cpp:1216-1272`; init may `ActOnExprFromNode` `:1259`. Mutable globals intern-then-reject |

Dedicated unique **enumerators** after postfix: **31** (`snFunctionCall` `snCast` `snConstructCall` `snReturn` `snAssignment` `snExpression` `snIf` `snWhile` `snFor` `snSwitch` `snDoWhile` `snForEach` `snVariableAccess` `snInitList` `snDataType` `snBreak` `snContinue` `snFallthrough` `snCondition` `snConstant` `snExpressionStatement` `snCase` `snStatementBlock` `snNamespace` `snClass` `snEnum` `snInterface` `snTypedef` `snImport` `snFunction` `snDeclaration`). Member / Index / Unary / PostfixCall / Sequence do **not** consume unique enumerators; `snExprTerm` remains leftover intern of leftover postfix and the wrapper.

`snFunction` is one enumerator: function / method / lambda-expr intern dedicated; **ctor / dtor / mixin intern leftover**; **body attach leftover**. `snDeclaration` is one enumerator: local + global intern dedicated.

## How to read the leftover table

- **Current intern path:** function that **creates** the AST node after postfix intern (not the Parser recovery tree).
- **Existing dedicated ActOn\*:** builder on `as_sema.h` vs intern authority. Builder presence ≠ intern.
- **Parser already NotifySema?:** incremental `NotifySema` → `ActOnParsedDeclaration` (`as_parser.cpp:132`) or `ActOnParsedExpr` / `ActOnParsedStmt` / `BeginParsedControl`.
- **Dump facts already locked?:** SemaAuthority `ParserActOn*` / compile→seal dumps. Dump-green ≠ dedicated intern.
- **Blocks 13.2?:** whether this kind still carries lookup / overload / conversion / call / lifetime / control that backends must not re-decide. `No` means true leftover recovery is allowed for 13.2 *authority* (the box still stays `[ ]` for other reasons).

---

## Expr leftover intern

| Node kind | Current intern path | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- |
| `snExprTerm` leftover postfix (`++` / `--` / other non-`.`/`[]`/`()`) | FromNode `as_sema_expr.cpp:1459-1554`. Dedicated extract: unary `:1483` `ActOnUnaryExpr`; `.` member `:1498` `ActOnMemberExpr`; `.` call `:1493` Call FromNode + implicitReceiver; `[]` `:1515` `ActOnIndexExpr`; `()` `:1528` `ActOnPostfixCallExpr`; sequence `:1552` `ActOnSequenceExpr`. **Leftover intern of this parent:** other post-op still builder `ActOnUnary` `:1535`, `:1540` (hardcoded `intType`). `ActOnParsedExpr` leftover whole-node FromNode `as_sema_decl.cpp:1633-1635` | Builders `ActOnUnary` `as_sema.h:51`, `ActOnSequence` `:66`, `ActOnCall` `:61`. Intern landed: `ActOnUnaryExpr` `:52`, `ActOnPostfixCallExpr` `:63`, `ActOnSequenceExpr` `:67`. **Missing intern:** leftover postfix `++`/`--` through `ActOnUnaryExpr` (or a dedicated postfix-inc action) | **Yes** when init-list / pre-op / post-op: `ParseExprTerm` `as_parser.cpp:2223`, `2235`, `2263`, `2287`, `2300` | Postfix `()` / sequence locked on SemaAuthority **178/178** (`wave-b-postfix-sema`). Leftover `++`/`--` **not** a no-script-node intern lock | Later small peel: leftover post-op → `ActOnUnaryExpr`. **Not next** (not construction / 5.9 factory / body attach) | **Partial** — leftover `++`/`--` still decides unary inside FromNode. Call/construct of `()` is dedicated |
| `snExprValue` | Shared FromNode arm with `snExprTerm` `as_sema_expr.cpp:1459`. Wrapper walks children | None on the wrapper | **No** on wrapper `ParseExprValue` | Indirect via children | Keep as recovery wrapper | **No** (wrapper) once children dedicated |
| `snArgList` | No AST intern. Call/Construct/Postfix extract walks `firstChild` `as_sema_expr.cpp:1393`, `1432`, `1520` | None | No `ParseArgList` `as_parser.cpp:1895` | nargs/reverse-formal locked on Call | Keep as Parser recovery tree | **No** |
| `snNamedArgument` | Call FromNode extract reads ident + `lastChild` `as_sema_expr.cpp:1398-1405` | None. `ActOnCallExpr` already reorders names | No `as_parser.cpp:1962` | named/default args on compile→seal Call dumps | Keep extract inside Call peel | **No** once Call extract stays dedicated |
| `snExprPreOp` / `snExprPostOp` / `snExprOperator` | Syntax children of Term/Expression. Term FromNode switches on pre/post `as_sema_expr.cpp:1481`, `1487`. Operator token on Expression `as_sema_expr.cpp:1563`. `ParseExprPreOp` `as_parser.cpp:2309`, `ParseExprPostOp` `2330`, `ParseExprOperator` `2387` | None | No on the op node; parent Term/Expression ActOn | Unary / binary / index / postfix via parent tests | Keep as recovery tokens. `@` pre-op stays rejected dialect | **No** (recovery child) except leftover `++`/`--` intern is the **parent** Term leftover above |
| `snScope` | Call/VarAccess FromNode `ResolveScopeOwner` (`as_sema_expr.cpp:1345`, `1410`). `ParseOptionalScope` `as_parser.cpp:322` | None. `LookupCandidatesFrom` `as_sema.h:124` exists | No | `callee=Game::F(int)` compile→seal | Pass scope owner into Call/DeclRef actions | **Partial** (symbols). Not its own intern kind |

`snFunctionCall` / `snCast` / `snConstructCall` / `snAssignment` / `snExpression` / `snVariableAccess` / `snInitList` / `snCondition` / `snConstant` / postfix `()` / sequence are **not** leftover intern of those parent kinds (extract wrappers only).

Lambda **expr** intern is dedicated `ActOnLambdaExpr`. `ActOnLambdaFromNode` remains a FromNode wrapper; treating it as dedicated would be a 虚标. Its leftover meaning is **body attach**, listed under stmt/decl.

---

## Stmt leftover intern

Dedicated If / While / For / Switch / DoWhile / Foreach / Return / Break / Continue / Fallthrough / ExprStmt / Case / Compound / LocalDecl intern is landed. Leftover is **not** intern of those parent kinds. Leftover is the remaining **body / nested-child syntax walk**.

| Node kind | Current intern path | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- |
| Function / method / lambda **body attach** (`snStatementBlock` walk) | WalkOne `snFunction` `as_sema_decl.cpp:1204-1208` `ActOnStmtFromNode(body)` then `SetBody`. Lambda `ActOnLambdaFromNode` `:1039-1043` same. Compound FromNode `as_sema_stmt.cpp:468-536` walks every child (locals `EmitLocalDeclStmts`; else recursive StmtFromNode) then `ActOnCompoundStmt`. `ActOnParsedStmt` `default` `as_sema_decl.cpp:1924` intern the block through FromNode | Builder `ActOnBlock` `as_sema.h:78`. Intern of Compound: `ActOnCompoundStmt` `:79`. **Missing intern:** attach-only body that does **not** walk `asCScriptNode`. Contrast: generated ctor body is already attach-only `FillGeneratedConstructorDefaults` `as_sema_decl.cpp:617` `SetBody(ActOnBlock(...))` with **no** StmtFromNode | **No** ActOn on the block. `ParseStatementBlock` `as_parser.cpp:4261` only `NotifySema`s local `snDeclaration` `:4301-4304`. Comment `:4300`: non-decl NotifySema would steal the body. `ParseFunction` NotifySema is the **decl** after name+params `:3692`, not the body | Nested block must not steal function body. F4 sibling IIFE intern counts already PASS through this FromNode walk; execute 42 is CodeGen, not this intern | **Must wait** (see next-slice section). Do not peel body while Parser still never ActOn nested statements | **Yes** — function body is still a syntax walk of leftover children. After ctor/list-pattern, still not 13.2 close |
| Nested then / else / loop body / switch cases (extract of dedicated parents) | `ActOnParsedStmt` / FromNode still `ActOnStmtFromNode` for If then/else `as_sema_decl.cpp:1751-1756`, While body `:1764`, For init/body `:1772` `:1783`, Switch cases `:1801`, DoWhile body `:1809`, Foreach vars/body `:1821` `:1830`, Case inners `:1901`. Same in FromNode `as_sema_stmt.cpp:600-737` | Parent intern dedicated. Nested extract is leftover children | Parent NotifySema yes; nested statements **no** (block only NotifySema locals) | Control dumps lock parent `kind=` / `target=` | Same gate as body attach: Parser incremental stmt ActOn, then attach-only Compound | **Partial** — leftover children of dedicated control. Not a new parent intern kind |
| `snFunction` as expr-stmt | FromNode `as_sema_stmt.cpp:573-574` → `ActOnExprStmt(ActOnLambdaFromNode(...))` | Lambda intern dedicated; wrapper leftover | Lambda `ParseLambda` NotifySema `as_parser.cpp:1799` | lambda keys / call-through | Keep extract-then-`ActOnLambdaExpr`. Body attach is the leftover | **Yes** only for body attach |
| `try` / `catch` (no enumerator) | Stmt FromNode `default` `as_sema_stmt.cpp:748-762` diagnostic `try-catch-rejected` | None. Stay rejected | No | Rejection diagnostic | Keep FromNode/default recovery | **No** (rejected) |

`snExpressionStatement` / `snCase` / `snStatementBlock` **parent intern** is dedicated. Do not redo Compound / ExprStmt / Case as if they were leftover intern of those kinds.

LocalDecl in a block arm still **inlines** `EmitLocalDeclStmts` (`as_sema_stmt.cpp:523`) instead of calling `ActOnLocalDeclStmt`. That is leftover extract of an already-dedicated kind. Keep locals **flat** (sibling `STMT_EXPR` init; do not nest in Block) — F4's failing fixture uses three inited locals.

---

## Decl leftover intern

Decl intern is still **`ActOnParsedDeclaration` → `WalkOne`** (`as_sema_decl.cpp:1456`, `:1490`, `WalkOne` `:1048`). Named-decl **parent** intern through namespace / class / enum / interface / typedef / import / function / method / var is dedicated extract-then-`ActOnStart*`. WalkOne remains the syntax walk that **classifies leftover decl kinds** and **attaches bodies**.

| Node kind | Current intern path | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- |
| `snFunction` **ctor / dtor / mixin** | `ActOnFunctionLike` `as_sema_decl.cpp:768-838`: `NodeHasToken(ttBitNot)` → `ActOnDestructorDecl` `:807`; parent CLASS/INTERFACE + name equals owner → `ActOnConstructorDecl` `:811`; `ttMixin` / ident `"mixin"` → `ActOnMixinDecl` `:800`; else `ActOnStartMethodDecl` / `ActOnStartFunctionDecl`. WalkOne `:1199-1203` `FindExistingFunctionLike` then that helper. Parser never `CreateNode(snMixin)` (repo grep empty). `ParseMixin` `as_parser.cpp:3879-3885` returns `ParseFunction(false, true, tokenNode)` — intern is `snFunction` | Builders `ActOnConstructorDecl` `as_sema.h:32` `as_sema.cpp:312`, `ActOnDestructorDecl` `:33` `:320`, `ActOnMixinDecl` `:38` `:370`. **Missing intern:** `ActOnStartConstructorDecl` / `ActOnStartDestructorDecl` / `ActOnStartMixinDecl`. `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` must **not** absorb ctor/dtor (overloads must not collapse; name `T` is both class and ctor). Generated lifecycle already calls the builders with **no** script node (`EnsureGeneratedLifecycle` `as_sema_decl.cpp:620-665`) | **Yes.** `ParseFunction` default `notifySemaAfterParams=true` (`as_parser.h:140`) after name+params `as_parser.cpp:3692`. Mixin uses that path. Class methods `ParseFunction(true)` `as_parser.cpp:4002` also NotifySema. Interface methods `3742`. Mixin tests: `ParserActOnMixinFunctionDeclBeforeBodyFails`, `ParserActOnMixinDoesNotDuplicateOnSuccessfulParse` | mixin `kind=Mixin name=MixHelper` `key=MixHelper(int)`; user ctor `key=T::T()` / `T::T(int)` / `T::~T()`; `callee=T::T(int)` construct dumps. No-script-node lock exists for **builders** (`ActOnConstructorDecl` select `T::T(int)` ~2451) **not** for `ActOnStartConstructorDecl` intern | **Next exclusive intern UBT after F4 releases:** extract ident / `~` / mixin prefix / parent kind then dedicated `ActOnStart*` without `ActOnFunctionLike` as the intern. `FindExistingFunctionLike` first (do not collapse overloads by name). Body still StmtFromNode in this slice | **Yes** — construction / lifetime / mixin identity. User `T::T(int)` still interned by walking node tokens. Generated ctor/dtor intern is already builder-without-node |
| `snListPattern` | WalkOne `as_sema_decl.cpp:1274-1303` → dependency string from child texts / `FormatTypeKey` + generated `ActOnVarDecl` name `"list-pattern"` + `SetOrigin` + `asAST_TRAIT_GENERATED` + `WalkDecls` children | **None** dedicated. Do **not** confuse with expr `ActOnInitList` (`literal=list-pattern` on `{1,2}`) | `ParseListPattern` `as_parser.cpp:1309` **has no NotifySema**. Host `ParseFunctionDefinition(..., in_expectListPattern)` `as_parser.cpp:142-154` appends the node as a child of `snFunction`. Import embeds `ParseFunctionDefinition()` `as_parser.cpp:2581` (no list-pattern flag). Intern when parent function/import WalkOne walks the child | Incomplete `{1, 2` lock `ParserActOnListPatternBeforeBlockCloseFails` is **InitList** (`literal=list-pattern` `args=1,2`), not this node. `ListPatternRecordsStructuredNodes` / host `{repeat int}` list-factory registration is this node. `SemaInitListActionRecordsListPatternWithoutScriptNode` locks **InitList**, not `snListPattern` | **Second intern peel:** `ActOnListPatternDecl` (or `ActOnStartListPatternDecl`) from structured children. Do not merge with InitList. Do not intern script `{1,2}` twice | **Partial** (5.9 list factory / lifetime). Not ordinary script construction of `T::T`. Not next if ctor intern is the remaining snFunction leftover |
| `snParameterList` | `WalkParameterList` `as_sema_decl.cpp:578-587` → `WalkParameterSequence` `:522-576` → `ActOnQualTypeFromNode` + `ActOnParamDecl`. Called from `ActOnFunctionLike` `:829`, lambda FromNode `:1031`, WalkOne import `:1178`, WalkOne `snFuncDef` `:1131` | Builder `ActOnParamDecl` `as_sema.h:34`. **Missing intern:** `ActOnParam` / `ActOnStartParamDecl` dispatched from Parser, not a syntax walk | No ActOn on the list. Function NotifySema walks params inside WalkOne / `ActOnFunctionLike` | `ByVal(int)` vs `ByRef(const int&in)`; mixin param `kind=Param name=a` | Fold into ctor/mixin intern extract (params already walked there). Do not make params the next exclusive UBT | **Partial** (4.4 signatures). Leftover extract of an existing builder |
| `snIdentifier` (enumerator) | WalkOne `as_sema_decl.cpp:1305-1322` under enum; also enum arm `:1099-1114` `ActOnVarDecl`. Parser `NotifySema(ident)` `as_parser.cpp:2986` | `ActOnVarDecl` / `ActOnStartVarDecl` | **Yes** `as_parser.cpp:2986` | enumerator names on enum dumps | Covered by already-dedicated Enum extract. Keep WalkOne FindExisting | **No** as standalone intern kind |
| `ActOnQualTypeFromNode` leftover extract (`snDataType`) | `as_sema_decl.cpp:372-387` `CollectQuals` + `FormatTypeKey` then `ActOnQualType`. Still the type intern **input** for Cast / Construct / LocalDecl / FunctionLike / Import / params | Intern `ActOnQualType` landed. FromNode is leftover extract | No ActOn on the type node | interned `type=int` / `dest=float` / `src=int` | Keep as recovery extract. Do not redo QualType intern | **Partial** (canonical types). Extract leftover, not leftover intern of QualType |
| Generated lifecycle / accessors (no enumerator) | Class WalkOne after members: `EnsureGeneratedLifecycle` `as_sema_decl.cpp:1080` → missing ctor/dtor `ActOnConstructorDecl` / `ActOnDestructorDecl` + `asAST_TRAIT_GENERATED`; `FillGeneratedConstructorDefaults` `:591-617` attach-only body. `EnsureGeneratedAccessors` `:1081` synthesizes Get/Set methods **without bodies** | Builders already used **without** script node | N/A (Sema synthesis) | `T::T()` / `T::~T()` generated keys; accessor dumps `traits=256` | Do not intern generated ctor through FromNode. Accessor **bodies** are 5.9 / CodeGen (`wave-d-95-lifecycle-next.md`), not this intern map | **Partial** (5.9). Generated ctor intern is already dedicated; user ctor intern is the leftover snFunction form |
| `snScript` | `ActOnParsedScript` `as_sema_decl.cpp:1930-1944` walks children `ActOnParsedDeclaration`. Fallback if `semaDeclActions == 0`: `as_parser.cpp:2529` | `ActOnTranslationUnit` `as_sema.h:16` | Fallback only | TU `kind=TranslationUnit` | Keep. Not an intern peel | **No** (container) |
| `snFuncDef` | WalkOne `as_sema_decl.cpp:1126-1132` → `ActOnFuncDefDecl` + `WalkParameterList` | `ActOnFuncDefDecl` `as_sema.h:41` | **No** inside `ParseFuncDef` `as_parser.cpp:3523-3571`. Only successful `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704` if the token parses. Script `funcdef` is **fork-rejected**. Host `RegisterFuncdef` allowed | Host funcdef call `callee=` | Do not add script `funcdef`. Leave WalkOne as recovery if the token ever appears | **No** (rejected dialect). 4.2/5.9 stay open partly because of this |
| `snMixin` | **Parser never `CreateNode(snMixin)`**. Mixin functions intern as `snFunction` (row above) | `ActOnMixinDecl` exists | Mixin keyword → `ParseFunction` NotifySema as function | mixin function keys | Do not invent `snMixin` intern. Dedicated mixin intern is the `snFunction` leftover form | **No** as a node kind today |
| `snVirtualProperty` | Parser `ParseVirtualPropertyDecl` errors `TXT_VIRTUAL_PROPERTY_REMOVED` `as_parser.cpp:3767` returns 0 | `ActOnPropertyDecl` exists `as_sema.h:35` | No | None | Stay rejected. Do not intern | **No** |
| `snAccessDeclaration` | Parser `ParseAccessDecl` `as_parser.cpp:3055`. WalkOne `default` `as_sema_decl.cpp:1324` | None | **No** NotifySema in `ParseAccessDecl` | None found | Recovery WalkOne until a dump exists | **No** today |
| `snClassDefaultStatement` | Parser `as_parser.cpp:3214`. WalkOne default | None | **No** NotifySema in `ParseClassDefaultStatement` | None found | Recovery | **No** today |
| `snUndefined` | Init-list hole nodes; Expr FromNode `default` firstChild recurse `as_sema_expr.cpp:1631-1635` | None | No | None | Keep default recovery | **No** |

---

## Row / leftover counts

| Group | After postfix intern |
| --- | --- |
| Dedicated unique parent enumerators | **31** (49 − 18 leftover enumerators) |
| Expr leftover intern kinds | **1** leftover parent (`snExprTerm` leftover `++`/`--` / wrapper) + recovery wrappers |
| Stmt leftover intern | **0** leftover parent intern of dedicated stmt kinds. **Body attach** is leftover meaning on already-dedicated Compound / Function / Lambda |
| Decl leftover intern kinds | **4** that still intern language meaning: `snFunction` ctor/dtor/mixin, `snListPattern`, `snParameterList`, `snIdentifier` enumerators. Plus QualType leftover extract, generated lifecycle (no enumerator), `snScript` container |
| True leftover recovery enumerators | **13** + try/catch token (no enumerator) |
| Unique leftover `eScriptNode` kinds | **18** (49 − 31) |
| Remaining intern that still carries language meaning | **6** rows: leftover Term `++`/`--`; ctor/dtor/mixin; list-pattern; parameter list; enumerator ident; function/method/lambda **body attach** |

`snDeclaration` is one enumerator with two intern paths (local dedicated `ActOnLocalDeclStmt` + global dedicated `ActOnStartVarDecl`). `snFunction` is one enumerator: function/method/lambda-expr intern dedicated; ctor/dtor/mixin leftover; body leftover. Member / Index / Unary / PostfixCall / Sequence do not consume unique enumerators.

---

## True leftover recovery (allowed as FromNode after 13.2 intern peels)

Syntax-only children, rejected dialect, unused parser nodes. **Not** allowed as “recovery” while they still intern lookup/overload/conversion/call/lifetime/control on the canonical language path.

| Kind | Why recovery is honest |
| --- | --- |
| `snArgList` | Parser grouping only; Call/Construct/Postfix extract children |
| `snNamedArgument` | Name token for already-dedicated Call reorder |
| `snExprPreOp` / `snExprPostOp` / `snExprOperator` | Operator tokens; parent Term/Expression intern. `@` pre-op stays rejected |
| `snScope` | Prefix tokens for Call/DeclRef lookup owner |
| `snExprValue` | Wrapper; intern children |
| `snUndefined` | Holes / unknown firstChild recurse |
| `snFuncDef` | Script `funcdef` fork-rejected; host `RegisterFuncdef` remains legal |
| `snMixin` | Unused parser node (never created). Mixin **functions** are `snFunction` leftover intern, not this enumerator |
| `snVirtualProperty` | Parser errors and returns 0 |
| `snAccessDeclaration` | No NotifySema, no dump |
| `snClassDefaultStatement` | No NotifySema, no dump |
| `try` / `catch` | Stmt default `try-catch-rejected`; source `try`/`catch` stays rejected |
| Script `is` / `@` | Rejected dialect. Dedicated Binary extract still spells `ttIs`/`ttNotIs`; do not intern as language |

**Not recovery** after postfix (must peel before 13.2 intern-authority can be claimed): user ctor / dtor / mixin intern inside `ActOnFunctionLike`, `snListPattern` generated VAR, function/method/lambda **body** StmtFromNode walk, leftover Term `++`/`--`, `WalkParameterList` as the intern of params, enumerator WalkOne (weak). Nested extract of already-dedicated stmt/expr kinds may stay as Parser recovery **input** once those parents intern dedicated — that is leftover children, not leftover intern of If/Call/Compound.

---

## Suggested exclusive-UBT intern order after `D-sixth-f4-exec` releases

Do **not** start these while `D-sixth-f4-exec` holds `as_bytecode_codegen.cpp` / ProductionCodeGen / (if diagnosis requires) `as_sema_expr.cpp` `ActOnPostfixCallExpr`, `as_sema_decl.cpp` `ActOnLambdaFromNode`, `as_sema_stmt.cpp` `EmitLocalDeclStmts`. F4 is **execute 42**, not intern. F5 LEGACY lambda stays queued (`wave-d-95-f4-next.md`). No second UBT in `D:\as-cta`. No Wave E–G. No default CANONICAL.

### Body attach is **not** the next intern peel (must wait)

Function / method / lambda body is still `ActOnStmtFromNode`. That is leftover meaning. It must **not** be the next exclusive intern UBT.

Why wait:

1. **Compound intern already landed.** WalkOne/Lambda leftover is `SetBody(ActOnStmtFromNode(snStatementBlock))`, not missing `ActOnCompoundStmt`. A rename that still walks the node is not intern authority.
2. **Parser never ActOn the block or nested statements.** `ParseStatementBlock` `as_parser.cpp:4301-4304` NotifySema **only** local `snDeclaration` (comment: non-decl ActOn would steal the body). Incremental stmt intern of `return` / `if` / expr-stmt inside a function does not exist. Body peel without Parser incremental `ActOnParsedStmt` per child still FromNode-walks the tree.
3. **Nested extract of dedicated parents still StmtFromNode.** If / While / For / Switch / Case / DoWhile / Foreach `ActOnParsedStmt` arms still intern then/else/body/cases through `ActOnStmtFromNode`. Attach-only Compound cannot be honest while those children intern by walking `asCScriptNode`.
4. **Generated ctor body is the contrast, not the template for user bodies.** `FillGeneratedConstructorDefaults` already `SetBody(ActOnBlock)` with no script node. User bodies still need the statement tree. Closing that gap is Parser+Sema, not a one-file WalkOne patch.
5. **F4 execute is CodeGen of already-interned IIFE bodies.** Intern counts for two `"<lambda>"` already PASS. Peeling body intern will not make `A+B=42` and would collide with F4's nested-block / slot hypotheses if started now.
6. **Ctor / mixin / list-pattern decls are still classified by walking nodes.** Body attach-only is blocked while leftover **decl** intern still creates CONSTRUCTOR / MIXIN / list-pattern through WalkOne. Peel those decls first so bodies attach to dedicated owners.

When body **may** peel (later, not next): Parser NotifySema each non-decl statement (or an equivalent incremental ActOn that does not steal the function body), leftover nested extract becomes FindExisting + dedicated `ActOn*Stmt` only, WalkOne/Lambda `SetBody(ActOnCompoundStmt(already-interned children))` with **zero** `ActOnStmtFromNode`. Keep nested blocks from stealing the function body. Keep LocalDecl init as sibling `STMT_EXPR`.

### 1. Next exclusive intern UBT — `B-ctor-dtor-mixin` (recommended first)

`snFunction` leftover forms → **`ActOnStartConstructorDecl` / `ActOnStartDestructorDecl` / `ActOnStartMixinDecl`**.

Why first, not list-pattern / body / leftover `++`:

- Function/method intern already has `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` (`as_sema.h:29-31`; no-script-node dumps `kind=Function name=Entry` / `kind=Method name=M`). `wave-b-fn-var-next.md` **explicitly deferred** ctor/dtor/mixin to existing builders inside `ActOnFunctionLike`. That is leftover intern of CONSTRUCTOR / DESTRUCTOR / MIXIN, not leftover intern of FUNCTION / METHOD.
- Parser already NotifySema after name+params. Mixin dumps `kind=Mixin name=MixHelper` and construct dumps `callee=T::T(int)` are locked **through WalkOne**. Dedicated intern is the remaining peel.
- Generated ctor/dtor already intern via builders with no script node. User-written `T::T(int)` / `~T` / `mixin MixHelper` still decide kind by walking `ttBitNot` / name-equals-class / `ttMixin` inside `ActOnFunctionLike` `as_sema_decl.cpp:794-816`.
- 13.2 names construction / lifetime next to call plans. List-pattern is host `{repeat int}` factory shape (5.9). Body attach is blocked (above). Leftover Term `++` does not intern a decl kind.
- Clang shape only: `Sema::ActOnStartCXXMemberDeclarator` / constructor declarator. This fork has no GNU `?:`, no labeled expressions, no script `funcdef` / `@` / `is`. Do not link Clang. Do not invent `snMixin` nodes.

Must prove (TDD, not this writer):

1. No-script-node intern: `ActOnStartConstructorDecl(cls, "T", range)` dumps `kind=Constructor` (or current dump spelling `key=T::T()`). Same for destructor and mixin (`kind=Mixin name=MixHelper`). Overloads `T::T()` vs `T::T(int)` must **not** collapse by name (`FindExistingFunctionLike` / param-count+types, same rule as `ActOnStartFunctionDecl`).
2. WalkOne / `ActOnFunctionLike` extract-then-dedicated. FromNode leftover for the kind is extract-then-dedicated. Mixin stays `snFunction` + mixin prefix; do not `CreateNode(snMixin)`.
3. Generated lifecycle still uses builders without script node. Do not double-intern generated + user ctor.
4. **Body still `ActOnStmtFromNode` in this slice.** Do not merge body attach.
5. SemaAuthority + CanonicalAST + Compiler GREEN. **Do not check 13.2 / 13.3 / 4.2 / 5.9 / 9.5.**
6. Fork: no `@` / `is`; `nullptr` not `null`. Do not intern script `funcdef`.

Must not: treat builders `ActOnConstructorDecl` / `ActOnDestructorDecl` / `ActOnMixinDecl` as dedicated intern; start F5; flip default CANONICAL; check 13.2; merge list-pattern or body into this RED/GREEN; CALL-without-callee.

Suggested signatures (shape, implementer owns the test text):

```cpp
asASTDeclId ActOnStartConstructorDecl(asASTDeclId parent, const char* name, const asCSourceRange& range);
asASTDeclId ActOnStartDestructorDecl(asASTDeclId parent, const char* name, const asCSourceRange& range);
asASTDeclId ActOnStartMixinDecl(asASTDeclId parent, const char* name, const asCSourceRange& range);
```

### 2. Then `B-list-pattern` (not next if ctor intern is still open)

`snListPattern` → **`ActOnListPatternDecl`**.

Why second, not first:

- Unique leftover **enumerator** that still intern meaning through WalkOne generated `ActOnVarDecl` name `"list-pattern"`.
- Script `{1,2}` is already dedicated `ActOnInitList`. Merging those two would be a 虚标. Incomplete-parse `literal=list-pattern` is InitList.
- Host `ParseFunctionDefinition` + `{repeat int}` list factory is 5.9. It does not unblock user `T::T(int)` intern.
- `ParseListPattern` has no NotifySema; intern today is parent WalkOne. A dedicated action can stay extract-from-parent until a host NotifySema exists.

Do not start list-pattern while ctor/mixin intern still classifies `snFunction` by walking tokens, unless ctor intern is already GREEN and the implementer keeps one intern peel. Prefer a separate RED/GREEN: ctor is construction identity; list-pattern is factory-decl shape.

### 3. Later (not next)

| Package | Gate |
| --- | --- |
| Body attach-only | After Parser incremental stmt ActOn **or** nested extract is honestly leftover recovery of dedicated stmt kinds. After ctor/list-pattern so owners are dedicated |
| Leftover Term `++`/`--` | Small. After ctor. Reuse `ActOnUnaryExpr` |
| `WalkParameterList` → `ActOnParam` | Fold into ctor/mixin extract; not its own UBT |
| F5 LEGACY lambda | `wave-d-95-f4-next.md`. After F4 execute GREEN. **Not this intern map** |
| Capture plan in Sema | After F4 execute; 13.2 hole; research first |
| Wave E–G | Forbidden now |

---

## 13.2 close criteria (repeat)

Task text (`tasks.md` 13.2):

> R02 Sema authority: replace the `asCScriptNode` syntax walk with a Sema environment (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets). Sealed dumps/views must show those facts so backends do not rerun Sema.

**This leftover map does not close 13.2.** Checking the box from postfix greens, SemaAuthority **178/178**, F4 execute, ctor intern greens, or list-pattern greens would be 虚标.

What must be true to check 13.2 (all of them):

1. **Dedicated intern path** for lookup, overload, conversion, call, lifetime, and control. `ActOnParsed*` dispatches those known kinds to `ActOnCallExpr` / `ActOnCastExpr` / `ActOnConstruct` / `ActOnReturnStmt` / `ActOnAssignExpr` / `ActOnBinaryExpr` / `ActOnLogicalExpr` / `ActOnIfStmt` / `ActOnWhileStmt` / `ActOnForStmt` / `ActOnSwitchStmt` / `ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr` / `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` / `ActOnQualType` / `ActOnDeclRefExpr` / `ActOnLocalDeclStmt` / `ActOnInitList` / `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt` / `ActOnConditionalExpr` / leftover literals / `ActOnExpressionStmt` / `ActOnCaseStmt` / `ActOnCompoundStmt` / `ActOnStartNamespaceDecl` / … / `ActOnStartFunctionDecl` / `ActOnStartMethodDecl` / `ActOnStartVarDecl` / `ActOnPostfixCallExpr` / `ActOnSequenceExpr` / ctor-dtor-mixin intern / list-pattern / **body attach-only** **without** `ActOn*FromNode` as the intern. Child extraction may still read `asCScriptNode` as Parser recovery input.
2. **FromNode is true leftover recovery**, not the implementation for listed kinds. Allowed recovery: syntax-only children (`snArgList`, pre/post/op tokens, `snScope`, `snExprValue` wrapper, `snUndefined`), `default` unknown nodes, rejected dialect (`try`/`catch`, script `funcdef`, `@`, `is`, virtual property), unused parser nodes (`snMixin` enumerator, `snAccessDeclaration`, `snClassDefaultStatement`) until a dump exists.
3. **Not allowed as “recovery”:** user ctor/dtor/mixin intern, `snListPattern` generated VAR, function/method/lambda body syntax walk, leftover Term `++`/`--` — once those are on the canonical language path.
4. **Sealed dumps/views** already print interned `type=` / `dest=` / `src=` / `callee=` / control `target=` for landed fixtures. That is **not** sufficient.
5. **CANONICAL backends do not re-decide** those facts (do not re-select overloads, re-rank conversions, or re-infer control targets). Isolated `Generate()` for the ProductionCodeGen integer/overload subset consumes sealed CALL decl ids. Capture **plan is still CodeGen-owned** (`CollectLambdaCaptures`). That is a 13.2 hole even after F4 uniquing.
6. **4.2–5.9 language coverage is still incomplete**, and the task says those cannot complete without the Sema environment. Incomplete 4.2–5.9 **keeps 13.2 `[ ]` even after dedicated dispatch**. Honest holes: script `funcdef` rejected; stored capturing closures not Sema facts; exception tables rejected; generated accessor **bodies** (5.9); fallthrough targets (5.6); production identity (13.3); default pipeline still LEGACY `asCCompiler`.

**LEGACY `asCCompiler` is the default opt-out.** That is not itself the 13.2 definition, and deleting `asCCompiler` is not the close. It does prove the **default production pipeline** still reruns Sema. 13.2 is Sema authority on the **canonical** path so backends consume sealed facts. Wave G default CANONICAL is a later flip.

Parser may keep building `asCScriptNode` as recovery input. 13.2 is not “Parser stops allocating nodes.” 13.2 is “Sema environment is the authority; syntax walk is not.”

**Leave 13.2 / 13.3 / 4.2 / 5.9 / 5.6 `[ ]` after every slice this leftover map describes.**
