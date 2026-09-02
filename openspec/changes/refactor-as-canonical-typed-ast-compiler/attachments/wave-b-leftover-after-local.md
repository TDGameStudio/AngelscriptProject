# Wave B leftover intern after LocalDecl / InitList

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 stays `[ ]`.** Do not check 13.3 / 4.2 / 5.9 / 5.6 from this map.

**Goal:** After dedicated intern for LocalDecl / InitList (and the earlier Call … Member / Index / Unary / QualType / DeclRef peels), list every `asCScriptNode` kind that **still intern meaning** through `ActOnExprFromNode` / `ActOnStmtFromNode` / `WalkOne` / leftover FromNode wrappers. Then mark which of those remain leftover intern **after** exclusive UBT `B-control-jump` peels `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt`. Propose the **next** exclusive-UBT slice.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM. Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null` (`as_tokendef.h:291` maps `"nullptr"` → `ttNull`). **F4 LEGACY lambda is not this inventory.**

Live file:line is this worktree (2026-08-22). Historical companions (do not collide; do not treat as current intern):

- `wave-b-leftover-after-dfl.md` — leftover after DFL; **stale** vs members / QualType / DeclRef / LocalDecl / InitList
- `wave-b-fromnode-inventory.md` — 51-kind historical map
- `async-work.md` — current 梳理; leftover list there is the dispatch snapshot
- `wave-b-control-jump-next.md` — exclusive UBT plan for Break / Continue / Fallthrough
- `wave-b-clang-break-shape.md` — Clang `ActOnBreakStmt` shape only

`eScriptNode` has **49** enumerators (`as_scriptnode.h:47-99`).

## 13.2 stays `[ ]`

Task 13.2 is a Sema **environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets) so CANONICAL backends do not rerun Sema. Dedicated LocalDecl / InitList intern, SemaAuthority prefix greens, dump `type=` / `callee=` / `target=`, and a later Break peel do **not** close it. Incomplete 4.2–5.9 keeps the box `[ ]`.

## Two snapshots

| Snapshot | What it is | Break / Continue / Fallthrough |
| --- | --- | --- |
| **After LocalDecl / InitList** | Dedicated intern already landed for Call … LocalDecl / InitList. Control jumps still intern through FromNode builders. | Leftover intern of those **parent** kinds |
| **After assumed `B-control-jump`** | Dedicated `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt`. FromNode / `ActOnParsedStmt` extract then dedicated. Child extraction may still FromNode leftover children. | **Not** leftover intern of the parent kind |

This worktree’s live `as_sema.h` already declares the three `ActOn*Stmt` intern APIs (`as_sema.h:75-83`) and live `ActOnParsedStmt` already dispatches them (`as_sema_decl.cpp:1756-1773`). Treat that as the **after control-jump** intern path. The **after local** intern of those three is the pre-peel FromNode → builders `ActOnBreak` / `ActOnContinue` / `ActOnFallthrough` (`as_sema.cpp:824-857`; builder ≠ intern). `async-work.md` recorded the pre-peel `ActOnParsedStmt` leftover arm grouping `snExpressionStatement` / `snBreak` / `snContinue` / `snFallthrough` into FromNode.

## Dedicated intern after LocalDecl / InitList (do not list as leftover intern of the parent kind)

Child extraction may still read `asCScriptNode` and still call leftover FromNode for **children**. That is leftover children, not leftover intern of the parent kind.

| Kind | Dedicated intern | Extract wrapper may still read `asCScriptNode` |
| --- | --- | --- |
| `snFunctionCall` | `ActOnCallExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1462-1464` still whole-node FromNode extract; FromNode `as_sema_expr.cpp:1207-1273` then `ActOnCallExpr` |
| `snCast` | `ActOnCastExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1465-1484`; FromNode `as_sema_expr.cpp:1300-1316` |
| `snConstructCall` | `ActOnConstruct` | `ActOnParsedExpr` `as_sema_decl.cpp:1485-1500`; FromNode `as_sema_expr.cpp:1275-1298` |
| `snAssignment` | `ActOnAssignExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1502-1522`; FromNode `as_sema_expr.cpp:1494-1511` |
| `snExpression` | `ActOnBinaryExpr` / `ActOnLogicalExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1524-1552`; FromNode `as_sema_expr.cpp:1447-1474` still spells `ttIs` / `ttNotIs` — script `is` stays rejected |
| `snVariableAccess` | `ActOnDeclRefExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1554-1556` still whole-node FromNode extract; FromNode `as_sema_expr.cpp:1183-1205` then `ActOnDeclRefExpr` |
| `snInitList` | `ActOnInitList` | `ActOnParsedExpr` `as_sema_decl.cpp:1557-1566` extracts children then dedicated; FromNode `as_sema_expr.cpp:1515-1522` |
| `snReturn` | `ActOnReturnStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1612-1629`; value child may FromNode |
| `snIf` | `ActOnIfStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1631-1642`; then/else children may FromNode |
| `snWhile` | `ActOnWhileStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1644-1650`; body/cond children may FromNode |
| `snFor` | `ActOnForStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1652-1669` |
| `snSwitch` | `ActOnSwitchStmt` + `FinishSwitchStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1671-1688`; **case children still StmtFromNode** |
| `snDoWhile` | `ActOnDoWhileStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1690-1696` |
| `snForEach` | `ActOnForeachStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1698-1716`; var children may FromNode |
| `snDeclaration` **local** | `ActOnLocalDeclStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1718-1751`; FromNode `as_sema_stmt.cpp:508-539`. Global / member `snDeclaration` remains WalkOne leftover |
| `snDataType` | `ActOnQualType` `as_sema_decl.cpp:287` | `ActOnQualTypeFromNode` `as_sema_decl.cpp:372-387` is leftover extract; then `ActOnQualType` |
| Member / Index / Unary (not unique enumerators) | `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` | FromNode `snExprTerm` extract `as_sema_expr.cpp:1340-1375`. `snExprTerm` itself remains leftover intern for sequence / postfix `()` / leftover children |
| `snFunction` as **lambda expr** | `ActOnLambdaExpr` | `ActOnLambdaFromNode` `as_sema_decl.cpp:1007-1046` is **not** dedicated. Body still `ActOnStmtFromNode` `:1042`. Parser `ParseLambda` `NotifySema` `as_parser.cpp:1799`. **`snFunction` decl / method / body remains leftover** |

`B-control-jump` adds (do not list as leftover intern of the parent **after** that peel):

| Kind | Dedicated intern after control-jump | Extract wrapper |
| --- | --- | --- |
| `snBreak` | `ActOnBreakStmt` `as_sema_stmt.cpp:396-404` → builder `ActOnBreak` + `NearestControl(..., false)` | Live `ActOnParsedStmt` `as_sema_decl.cpp:1756-1761`; FromNode `as_sema_stmt.cpp:720-721` extract-then-dedicated |
| `snContinue` | `ActOnContinueStmt` `as_sema_stmt.cpp:406-414` → `NearestControl(..., true)` | `as_sema_decl.cpp:1762-1767`; FromNode `as_sema_stmt.cpp:722-723` |
| `snFallthrough` | `ActOnFallthroughStmt` `as_sema_stmt.cpp:416-424` | `as_sema_decl.cpp:1768-1773`; FromNode `as_sema_stmt.cpp:724-725`. `target=` still `FinishSwitchStmt` → `WireFallthroughTargets` `as_sema_stmt.cpp:99`, `:366-368` (5.6-open) |

Before that peel, `ActOnParsedStmt` interned those three through `ActOnStmtFromNode` → builders. Builder presence ≠ intern.

Dedicated unique **enumerators** after local: **15** (`snFunctionCall` `snCast` `snConstructCall` `snReturn` `snAssignment` `snExpression` `snIf` `snWhile` `snFor` `snSwitch` `snDoWhile` `snForEach` `snVariableAccess` `snInitList` `snDataType`). After control-jump: **18** (+ `snBreak` `snContinue` `snFallthrough`).

## How to read the leftover table

- **Current intern path:** function that **creates** the AST node after LocalDecl / InitList (not the Parser recovery tree).
- **After control-jump?:** whether this kind’s **parent intern** peels with `B-control-jump`. `stays leftover` means still leftover intern of the parent kind.
- **Existing dedicated ActOn\*:** builder on `as_sema.h` vs intern authority. Builder presence ≠ intern.
- **Parser already NotifySema?:** incremental `NotifySema` → `ActOnParsedDeclaration` (`as_parser.cpp:132`) or `ActOnParsedExpr` / `ActOnParsedStmt` / `BeginParsedControl`.
- **Dump facts already locked?:** SemaAuthority `ParserActOn*` / compile→seal dumps. Dump-green ≠ dedicated intern.
- **Blocks 13.2?:** whether this kind still carries lookup / overload / conversion / call / lifetime / control that backends must not re-decide. `No` means true leftover recovery is allowed for 13.2 *authority* (the box still stays `[ ]` for other reasons).

---

## Expr leftover intern

| Node kind | Current intern path | After control-jump? | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `snCondition` | `ActOnParsedExpr` leftover `as_sema_decl.cpp:1568-1570` whole-node FromNode. FromNode `as_sema_expr.cpp:1476-1492` → builder `ActOnConditional` with hardcoded `intType`. Missing-arm recovery recurses firstChild | **stays leftover** | Builder `ActOnConditional` `as_sema.h:43` `as_sema.cpp:489`. **Missing intern:** `ActOnConditionalExpr` | **Yes** when `?` present: `ParseCondition` `as_parser.cpp:2102`, `2114`, `2124`, `2130`. Bare EXPR does **not** ActOn the wrapper. Tests: `ParserActOnConditionalBeforeElseCloseFails`, `ParserActOnConditionalRecordsTernaryOnSuccessfulParse` | ternary `kind=Conditional` + `callee=F(int)` not `F(float)` | **Next exclusive UBT:** `ActOnConditionalExpr`. Clang shape: `Sema::ActOnConditionalOp` (`SemaExpr.cpp:9045`). No GNU `x ?: y`. Keep FromNode recovery for missing arms | **Partial** — control-like expr, conversion of arms. Not a jump target |
| `snConstant` | FromNode `as_sema_expr.cpp:1151-1181`. int/bool → `ActOnIntegerLiteral` / `ActOnBoolLiteral`. float/double → `CreateExpr(FLOAT_LITERAL)` `:1161-1170`. `ttNull` → `CreateExpr(NULL_LITERAL)` `:1173-1174`. else string → `CreateExpr(STRING_LITERAL)` `:1176-1181`. `ActOnParsedExpr` `default` `as_sema_decl.cpp:1572-1574` | **stays leftover** | Builders `ActOnIntegerLiteral` `as_sema.h:33`, `ActOnBoolLiteral` `:34`. **Missing:** `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral`. Fork: intern `nullptr`, not script `null` as a language feature | **No** on `ParseConstant` `as_parser.cpp:1669` / `ParseStringConstant` `1811`. Intern as child of assignment/return/call/term extract | int/bool via many ParserActOn + no-script-node Call tests. compile→seal `StringLiteralAndNullLiteralKeepKindsOnCompileSeal` locks `kind=NullLiteral` / `kind=StringLiteral` **through FromNode**. Float **not** interned-key locked | After Conditional: `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral`. Keep `nullptr` | **Partial** — canonical types (5.2 remainder). Not the next slice |
| `snExprTerm` | FromNode `as_sema_expr.cpp:1318-1445`. Member / Index / Unary already dedicated extract (`ActOnMemberExpr` `:1357`, `ActOnIndexExpr` `:1374`, `ActOnUnaryExpr` `:1343`). **Leftover intern of this parent:** postfix `()` still `ActOnCall` builder / `ConstructFromCallee` `:1376-1427`; sequence `ActOnSequence` `:1441-1443`; other children recurse FromNode (literals / leftover expr) | **stays leftover** (not leftover intern of Member/Index/Unary) | Builders `ActOnSequence` `as_sema.h:50`, `ActOnCall` `:46`. No `ActOnSequenceExpr` / postfix-call intern | **Yes** when init-list / pre-op / post-op: `ParseExprTerm` `as_parser.cpp:2223`, `2235`, `2263`, `2287`, `2300` | Member/index/unary dumps lock dedicated intern. Sequence / postfix `()` **not** a no-script-node intern lock | Later: postfix `()` should reuse landed `ActOnCallExpr`; sequence is recovery-or-small peel. **Not next** | **Partial** — postfix `()` still decides call/construct inside FromNode |
| `snExprValue` | Shared FromNode arm with `snExprTerm` `as_sema_expr.cpp:1318`. Wrapper walks children | **stays leftover recovery** | None on the wrapper. Children: dedicated Call/Cast/Construct/DeclRef/Lambda/InitList + leftover Constant/Condition | **No** on wrapper. Children NotifySema themselves | Indirect via children | Keep as recovery wrapper | **No** (wrapper) once children dedicated |
| `snArgList` | No AST intern. Call/Construct extract walks `firstChild` `as_sema_expr.cpp:1252`, `1292` | recovery | None | No `ParseArgList` `as_parser.cpp:1895` | nargs/reverse-formal locked on Call | Keep as Parser recovery tree | **No** |
| `snNamedArgument` | Call FromNode extract reads ident + `lastChild` `as_sema_expr.cpp:1257-1264` | recovery | None. `ActOnCallExpr` already reorders names | No `as_parser.cpp:1962` | named/default args on compile→seal Call dumps | Keep extract inside Call peel | **No** once Call extract stays dedicated |
| `snExprPreOp` / `snExprPostOp` / `snExprOperator` | Syntax children of Term/Expression. Term FromNode switches on pre/post `as_sema_expr.cpp:1340`, `1346`. Operator token on Expression `as_sema_expr.cpp:1453`. `ParseExprPreOp` `as_parser.cpp:2309`, `ParseExprPostOp` `2330`, `ParseExprOperator` `2387`, `ParseAssignOperator` `2407` | recovery | None | No on the op node; parent Term/Expression ActOn | Unary / binary / index via parent tests | Keep as recovery tokens. `@` pre-op stays rejected dialect | **No** (recovery child) |
| `snScope` | Call/VarAccess FromNode `ResolveScopeOwner` (`as_sema_expr.cpp:1194`, `1214`). `ParseOptionalScope` `as_parser.cpp:322` | recovery | None. `LookupCandidatesFrom` `as_sema.h:100` exists | No | `callee=Game::F(int)` compile→seal | Pass scope owner into Call/DeclRef actions | **Partial** (symbols). Not its own intern kind |

`snFunctionCall` / `snCast` / `snConstructCall` / `snAssignment` / `snExpression` / `snVariableAccess` / `snInitList` are **not** leftover intern of those parent kinds (extract wrappers only).

---

## Stmt leftover intern

| Node kind | Current intern path | After control-jump? | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `snBreak` | **After local:** FromNode → builder `ActOnBreak(NearestControl)`. **Live after peel:** `ActOnBreakStmt` `as_sema_stmt.cpp:396`; `ActOnParsedStmt` `as_sema_decl.cpp:1756`; FromNode `as_sema_stmt.cpp:720` extract-then-dedicated | **peels** — not leftover intern of Break | Builder `ActOnBreak` `as_sema.h:74`. Intern after peel: `ActOnBreakStmt` `:75` | **Yes** missing `;` `as_parser.cpp:5476`; success `5484`. `ParserActOnBreak*` + while/switch target tests interned **through FromNode** until peel; no-script-node `SemaBreakStmtActionRecordsWhileTargetWithoutScriptNode` is the intern lock | `kind=Break`; `target=` matches While/Switch id | Control-jump owns. Do not redo after GREEN | **Yes** — control targets. After peel, still not 13.2 close |
| `snContinue` | **After local:** FromNode → `ActOnContinue`. **Live after peel:** `ActOnContinueStmt` `as_sema_stmt.cpp:406`; `ActOnParsedStmt` `as_sema_decl.cpp:1762`; FromNode `as_sema_stmt.cpp:722` | **peels** | Builder `ActOnContinue` `as_sema.h:76`. Intern: `ActOnContinueStmt` `:77` | **Yes** `as_parser.cpp:5514` / `5522`. `ParserActOnContinue*` | `kind=Continue` `target=` For id | Same control-jump slice as Break | **Yes** — control targets |
| `snFallthrough` | **After local:** FromNode → `ActOnFallthrough`. **Live after peel:** `ActOnFallthroughStmt` `as_sema_stmt.cpp:416`; `ActOnParsedStmt` `as_sema_decl.cpp:1768`; FromNode `as_sema_stmt.cpp:724`. Target wired later `FinishSwitchStmt` → `WireFallthroughTargets` `as_sema_stmt.cpp:99`, `:366` | **peels intern**; `target=` stays 5.6-open | Builder `ActOnFallthrough` `as_sema.h:82`. Intern: `ActOnFallthroughStmt` `:83` | **Yes** `as_parser.cpp:4836` / `4844`. `ParserActOnFallthrough*` | `kind=Fallthrough` (no-dup once). `target=` still 5.6-open | Peel intern in control-jump. Do **not** require `target=` on the no-script-node test | **Yes** (5.6 control). After Case peel |
| `snExpressionStatement` | FromNode `as_sema_stmt.cpp:541-548` → `ActOnExprStmt(ActOnExprFromNode(firstChild))`. `ActOnParsedStmt` leftover `as_sema_decl.cpp:1753-1755` still whole-node FromNode | **stays leftover** | Builder `ActOnExprStmt` `as_sema.h:62`. **Missing intern dispatch:** `ActOnParsedStmt` → `ActOnExprStmt(owner, dedicatedExpr)` without StmtFromNode intern | **Yes** missing `;` `as_parser.cpp:4659`; success `4667`. `ParserActOnExprStmtSuccessBeforeFunctionCloseFails`, `ParserActOnExprStmtDoesNotDuplicateOnSuccessfulParse` | `kind=ExprStmt` / inner Call | After Conditional + literals: ExprStmt dispatch | **No** once child expr is dedicated |
| `snCase` | FromNode `as_sema_stmt.cpp:689-718` → builder `ActOnCase` + inner `ActOnStmtFromNode`. **Not listed** in `ActOnParsedStmt` → `default` `as_sema_decl.cpp:1774` | **stays leftover** | Builder `ActOnCase` `as_sema.h:81`. **Missing intern:** `ActOnCaseStmt` | **No.** `ParseCase` `as_parser.cpp:4851-4906` never `ActOnParsedStmt`. Intern when parent switch extract walks children | Switch-body tests intern cases via parent Switch | After Conditional: `ActOnCaseStmt` from Parser after `:`; parent Switch extract attaches cases without StmtFromNode intern of the case node | **Partial** (control). Switch already dedicated |
| `snStatementBlock` | `ActOnStmtFromNode` `as_sema_stmt.cpp:438-506` → locals `EmitLocalDeclStmts` + leftover children FromNode + `ActOnBlock`. Nested-block comment `:504-505`: must not steal function body. WalkOne function body still `ActOnStmtFromNode(body)` `as_sema_decl.cpp:1231`. Lambda body `:1042` | **stays leftover** | Builder `ActOnBlock` `as_sema.h:61`. **Missing intern:** `ActOnCompoundStmt` that only attaches already-interned children | **No** ActOn on the block. `ParseStatementBlock` `as_parser.cpp:4261` only `NotifySema`s local `snDeclaration` `as_parser.cpp:4303` | Nested block must not steal function body | WalkOne / Lambda body attach-only **after** leftover stmt kinds intern dedicated | **Partial** (scopes). Wrapper OK if children dedicated |
| `snDeclaration` (local) | Dedicated `ActOnLocalDeclStmt` — **not leftover intern of LocalDecl**. Block arm still extracts then `EmitLocalDeclStmts` `as_sema_stmt.cpp:443-493` | dedicated parent intern | `ActOnLocalDeclStmt` `as_sema.h:63` | Success-path locals `NotifySema` `as_parser.cpp:4303` → **WalkOne** (global path) vs `ActOnParsedStmt` init-list `as_parser.cpp:4557` | `kind=Var name=` | Do not redo LocalDecl. Keep locals **flat** (sibling `STMT_EXPR` init; do not nest in Block) | Landed intern; global WalkOne still leftover |
| `try` / `catch` (no enumerator) | Stmt FromNode `default` `as_sema_stmt.cpp:726-735` diagnostic `try-catch-rejected` | recovery | None. Stay rejected | No | Rejection diagnostic | Keep FromNode/default recovery | **No** (rejected) |

---

## Decl / type leftover intern

Decl intern is **`ActOnParsedDeclaration` → `WalkOne`** (`as_sema_decl.cpp:1391`, `:1425`, `WalkOne` `:1048`). Builders exist; WalkOne is still the syntax walk 13.2 names. Lambda **expr** intern is dedicated; WalkOne `snFunction` remaining is function/method/mixin **decl** + body attach.

`ActOnQualTypeFromNode` is leftover extract, not leftover intern of QualType.

| Node kind | Current intern path | After control-jump? | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `snFunction` (decl / method / mixin function) | WalkOne `as_sema_decl.cpp:1208-1235` → `FindExistingFunctionLike` / `ActOnFunctionLike` + **`ActOnStmtFromNode(body)` `:1231`**. Mixin: parser never `CreateNode(snMixin)`; `ParseMixin` `as_parser.cpp:3879` returns `ParseFunction` | **stays leftover** (body attach) | Builders `ActOnFunctionDecl` `as_sema.h:22`, `ActOnMethodDecl` `:23`, `ActOnConstructorDecl` `:24`, `ActOnParamDecl` `:26`, `ActOnMixinDecl` `:29`. Body intern is still StmtFromNode | **Yes** after name+params before body `as_parser.cpp:3692`; interface methods `3742`. Mixin tests: `ParserActOnMixinFunctionDeclBeforeBodyFails` | `key=Broken(int)`; mixin `MixHelper` | Decl extract already ActOn builders via WalkOne. Body must stop being StmtFromNode for 13.2 (compound + leftover stmts). Lambda intern is dedicated, not this row | **Yes** — function body still syntax walk; lookup/control of body children |
| `snDeclaration` (global / member) | WalkOne `as_sema_decl.cpp:1240-1284` → `ActOnQualTypeFromNode` + `ActOnVarDecl`; mutable global diagnostic | **stays leftover** | `ActOnVarDecl` | Success `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704` | global `kind=Var`; `mutable-global-rejected` | `ActOnVarDecl` after dedicated QualType extract. Mutable globals stay intern-then-reject | **Partial** (4.2 symbols). Mutable-global is rejected dialect |
| `snNamespace` | WalkOne `as_sema_decl.cpp:1061` → `ActOnNamespaceDecl` | **stays leftover** | Builder `ActOnNamespaceDecl` `as_sema.h:17` | **Yes** after identifier `as_parser.cpp:2791` + `PushLastActed` | `kind=Namespace name=` | Parser extract → `ActOnNamespaceDecl` without WalkOne intern; WalkOne FindExisting only | **Partial** (scopes). 4.2 remainder |
| `snClass` | WalkOne `as_sema_decl.cpp:1074` → `ActOnClassDecl` + bases + generated lifecycle/accessors | **stays leftover** | `ActOnClassDecl`, `ActOnConstructorDecl`, `ActOnDestructorDecl` | **Yes** after identifier `as_parser.cpp:3953` | `kind=Class`; ctors `T::T()` / `T::T(int)` / `T::~T()` | Extract name → `ActOnClassDecl` | **Partial** (4.2/4.5 generated accessors still 5.9) |
| `snInterface` | WalkOne `as_sema_decl.cpp:1090` → `ActOnInterfaceDecl` | **stays leftover** | `ActOnInterfaceDecl` `as_sema.h:30` | **Yes** `as_parser.cpp:3805` | `kind=Interface` | Extract → dedicated | **Partial** (4.2) |
| `snEnum` | WalkOne `as_sema_decl.cpp:1104` → `ActOnEnumDecl` + enumerator `ActOnVarDecl` | **stays leftover** | `ActOnEnumDecl`, `ActOnVarDecl` | **Yes** after name `as_parser.cpp:2937`; each enumerator ident `2986` | `kind=Enum` + enumerator vars | Extract → dedicated | **Partial** (4.2) |
| `snTypedef` | WalkOne `as_sema_decl.cpp:1134` → `ActOnTypedefDecl` | **stays leftover** | `ActOnTypedefDecl` `as_sema.h:28` | **Yes** after identifier before `;` `as_parser.cpp:5569` | `kind=Typedef` | Extract → dedicated | **Partial**. Script `funcdef` stays rejected; typedef is allowed |
| `snImport` | WalkOne `as_sema_decl.cpp:1154` → `ActOnImportDecl` + origin + `ActOnQualTypeFromNode` + params | **stays leftover** | `ActOnImportDecl` `as_sema.h:20` | **Yes** after name+params before `from` `as_parser.cpp:2587`; again after module string `2626` | `kind=Import` `route=import` | Extract → dedicated; origin after `from` | **Partial** (5.9 import CodeGen still open) |
| `snListPattern` | WalkOne `as_sema_decl.cpp:1286` → dependency string + generated `ActOnVarDecl` name `list-pattern` | **stays leftover** | None dedicated | `ParseListPattern` `as_parser.cpp:1309` **has no NotifySema**. Intern on parent function WalkOne. **Different from expr `snInitList` `{1,2`.** | Incomplete `{1,2` lock is **InitList**, not this node | `ActOnListPatternDecl` when factory decls matter (5.9). Do not merge with InitList | **Partial** (5.9). Not next expr slice |
| `snIdentifier` (enumerator) | WalkOne `as_sema_decl.cpp:1317` under enum; also `NotifySema(ident)` `as_parser.cpp:2986` | **stays leftover** as WalkOne child | `ActOnVarDecl` | **Yes** `as_parser.cpp:2986` | enumerator names | Covered by Enum action | **No** as standalone intern kind |
| `snParameterList` | `WalkParameterList` from WalkOne function/import/funcdef | **stays leftover** | Builder `ActOnParamDecl` `as_sema.h:26` | No ActOn on the list; function NotifySema walks params | `ByVal(int)` vs `ByRef(const int&in)` | `ActOnParam` during function ActOn | **Partial** (4.4 signatures) |
| `snScript` | `ActOnParsedScript` `as_sema_decl.cpp:1780` walks children `ActOnParsedDeclaration`. Fallback if `semaDeclActions == 0`: `as_parser.cpp:2529` | container | `ActOnTranslationUnit` `as_sema.h:16` | Fallback only | TU `kind=TranslationUnit` | Keep. Not an expression intern | **No** (container) |
| `snFuncDef` | WalkOne `as_sema_decl.cpp:1146` → `ActOnFuncDefDecl` | recovery (rejected dialect) | `ActOnFuncDefDecl` `as_sema.h:31` | **No** inside `ParseFuncDef` `as_parser.cpp:3523-3571`. Only successful `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704` if the token parses. Script `funcdef` is **fork-rejected**. Host `RegisterFuncdef` allowed | Host funcdef call `callee=` | Do not add script `funcdef`. Leave WalkOne as recovery if token ever appears | **No** (rejected dialect). 4.2/5.9 stay open partly because of this |
| `snMixin` | **Parser never `CreateNode(snMixin)`** (repo grep empty). Mixin functions intern as `snFunction` | recovery | `ActOnMixinDecl` exists `as_sema.h:29` | Mixin keyword → `ParseFunction` NotifySema as function | mixin function keys | Do not invent `snMixin` intern. Use `ActOnMixinDecl` only if a real mixin-class node appears | **No** as a node kind today |
| `snVirtualProperty` | Parser `ParseVirtualPropertyDecl` errors `TXT_VIRTUAL_PROPERTY_REMOVED` `as_parser.cpp:3767` returns 0 | recovery | `ActOnPropertyDecl` exists `as_sema.h:27` | No | None | Stay rejected. Do not intern | **No** |
| `snAccessDeclaration` | Parser `ParseAccessDecl` `as_parser.cpp:3055`. WalkOne `default` `as_sema_decl.cpp:1336` | recovery | None | **No** NotifySema in `ParseAccessDecl` | None found | Recovery WalkOne until a dump exists | **No** today |
| `snClassDefaultStatement` | Parser `as_parser.cpp:3214`. WalkOne default | recovery | None | **No** NotifySema in `ParseClassDefaultStatement` | None found | Recovery | **No** today |
| `snUndefined` | Init-list hole nodes; Expr FromNode `default` firstChild recurse `as_sema_expr.cpp:1524` | recovery | None | No | None | Keep default recovery | **No** |

---

## Row / leftover counts

| Group | After LocalDecl / InitList | After assumed `B-control-jump` |
| --- | --- | --- |
| Expr leftover intern kinds | 3 (`snCondition`, `snConstant`, `snExprTerm`) + recovery wrappers | **same 3** — control-jump does not peel expr |
| Stmt leftover intern kinds | 6 (`snBreak`, `snContinue`, `snFallthrough`, `snExpressionStatement`, `snCase`, `snStatementBlock`) | **3** (`snExpressionStatement`, `snCase`, `snStatementBlock`) |
| Decl / type leftover intern kinds | 12 (`snFunction` decl/body, global `snDeclaration`, `snNamespace`, `snClass`, `snInterface`, `snEnum`, `snTypedef`, `snImport`, `snListPattern`, `snIdentifier`, `snParameterList`, `snScript`) | **same 12** |
| True leftover recovery enumerators | 13 + try/catch token (no enumerator) | **same 13** |
| Remaining intern that still carries language meaning | **21** (3 + 6 + 12) | **18** (3 + 3 + 12) |
| **Unique leftover `eScriptNode` kinds** | **34** (49 − 15 dedicated parent enumerators) | **31** (49 − 18) |

`snDeclaration` is one enumerator with two intern paths (local dedicated `ActOnLocalDeclStmt` + global WalkOne leftover). `snFunction` is one enumerator: lambda expr intern dedicated; decl/method/body leftover. Member / Index / Unary do not consume unique enumerators; `snExprTerm` remains leftover intern of sequence / postfix `()` / leftover children.

---

## True leftover recovery (allowed as FromNode after 13.2 intern peels)

Syntax-only children, rejected dialect, unused parser nodes. **Not** allowed as “recovery” while they still intern lookup/overload/conversion/call/lifetime/control on the canonical language path.

| Kind | Why recovery is honest |
| --- | --- |
| `snArgList` | Parser grouping only; Call/Construct extract children |
| `snNamedArgument` | Name token for already-dedicated Call reorder |
| `snExprPreOp` / `snExprPostOp` / `snExprOperator` | Operator tokens; parent Term/Expression intern. `@` pre-op stays rejected |
| `snScope` | Prefix tokens for Call/DeclRef lookup owner |
| `snExprValue` | Wrapper; intern children |
| `snUndefined` | Holes / unknown firstChild recurse |
| `snFuncDef` | Script `funcdef` fork-rejected; host `RegisterFuncdef` remains legal |
| `snMixin` | Unused parser node (never created) |
| `snVirtualProperty` | Parser errors and returns 0 |
| `snAccessDeclaration` | No NotifySema, no dump |
| `snClassDefaultStatement` | No NotifySema, no dump |
| `try` / `catch` | Stmt default `try-catch-rejected`; source `try`/`catch` stays rejected |
| Script `is` / `@` | Rejected dialect. Dedicated Binary extract still spells `ttIs`/`ttNotIs`; do not intern as language |

**Not recovery** after LocalDecl / InitList (must peel before 13.2 intern-authority can be claimed): `snCondition`, `snConstant` float/string/`nullptr`, `snExprTerm` sequence / postfix `()`, `snExpressionStatement` dispatch, `snCase` peel, `snBreak` / `snContinue` / `snFallthrough` (until control-jump), `snStatementBlock` / WalkOne function **body** StmtFromNode, WalkOne named decls.

After control-jump, Break / Continue / Fallthrough intern is dedicated. **Still not recovery:** Conditional, leftover literals, ExprStmt dispatch, Case peel, WalkOne body attach, named-decl WalkOne, `snExprTerm` leftover forms.

---

## Suggested exclusive-UBT order after control-jump GREEN

Do not start these while `B-control-jump` holds `as_sema*` / SemaAuthority. F4 LEGACY lambda stays queued (`wave-d-95-f4-next.md`). No second UBT in `D:\as-cta`.

### 1. Next exclusive UBT — `B-conditional-expr` (recommended first)

`snCondition` → **`ActOnConditionalExpr`**.

Why first, not literals / ExprStmt / Case / WalkOne:

- After control-jump, Break / Continue intern no longer decide control **targets** inside FromNode. The remaining expression intern that still **decides conversion / common type of a language form** inside FromNode is ternary: FromNode `as_sema_expr.cpp:1485-1490` calls builder `ActOnConditional` with hardcoded `intType`.
- 13.2 names conversions next to control. Parser dumps already lock `kind=Conditional` + `callee=F(int)` **through FromNode** (`ParserActOnConditionalBeforeElseCloseFails`). Dedicated intern is the remaining peel.
- Float/string/`nullptr` are leftover canonical-type intern, but they do not rank conversions of two arms. ExprStmt is a dispatch wrapper. Case is control **structure** under an already-dedicated Switch. WalkOne body attach is blocked while leftover stmt/expr kinds still intern through FromNode.
- Clang shape only: `Sema::ActOnConditionalOp(QuestionLoc, ColonLoc, Cond, LHS, RHS)`. This fork has no GNU `x ?: y`, no labeled expressions, no `is`. Do not link Clang.

Must prove (TDD, not this writer):

1. No-script-node intern: `ActOnConditionalExpr(cond, thenExpr, elseExpr, range)` dumps `kind=Conditional` and preserves already-selected arm calls (`callee=F(int)` not `F(float)`).
2. `ActOnParsedExpr` `snCondition` extracts then calls the dedicated action. FromNode leftover for the kind is extract-then-dedicated, with FindExisting so bodies are not interned twice.
3. Missing then/else arms stay FromNode recovery. Do not intern GNU `?:`.
4. SemaAuthority + CanonicalAST + Compiler GREEN. **Do not check 13.2 / 13.3 / 4.2 / 5.9.**
5. Fork: no `@` / `is`; `nullptr` not `null`.

Must not: treat builder `ActOnConditional` as dedicated intern; start F4; flip default CANONICAL; check 13.2; merge Case / WalkOne into this RED/GREEN.

Suggested signature (shape, implementer owns the test text):

```cpp
asASTExprId ActOnConditionalExpr(asASTExprId cond, asASTExprId thenExpr, asASTExprId elseExpr, const asCSourceRange& range);
```

### 2. Then `B-literal-rest`

`ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral`. Intern `nullptr` (`ttNull` token spelling is `nullptr`). int/bool already have `ActOnIntegerLiteral` / `ActOnBoolLiteral`; Parser still intern those through FromNode until `ActOnParsedExpr` `default` / `snConstant` extract uses the dedicated APIs.

Do not merge with Conditional unless Conditional is already GREEN and the implementer keeps one intern peel. Prefer a separate RED/GREEN: Conditional is conversion ranking; literals are token → typed literal.

### 3. Then `B-exprstmt-case-body` (not the next UBT)

| Peel | Contents | Gate |
| --- | --- | --- |
| ExprStmt dispatch | `ActOnParsedStmt` `snExpressionStatement` → `ActOnExprStmt(owner, dedicatedExpr)` without StmtFromNode intern | After Conditional + leftover literals so the child is dedicated |
| Case peel | `ActOnCaseStmt`; Parser `ParseCase` NotifySema after `:`; Switch extract attaches without StmtFromNode intern of the case node | After control-jump (Switch already dedicated) |
| WalkOne body attach | Function / lambda body becomes `ActOnCompoundStmt` attach-only (`as_sema_decl.cpp:1231`, `:1042`) | After leftover stmt kinds intern dedicated |

Do not start a body-only UBT while Conditional / leftover literals / ExprStmt / Case still FromNode intern.

### 4. Later (not next)

| Package | Gate |
| --- | --- |
| `B-walkone-decl` | WalkOne named decl extract (namespace/class/enum/…). Not the 13.2 first bottleneck after control-jump |
| `snExprTerm` postfix `()` / sequence | Reuse landed `ActOnCallExpr`; sequence is small. After Conditional |
| F4 LEGACY lambda | `wave-d-95-f4-next.md`. After Wave B dedicated dispatch is honest enough |
| Wave E–G | Forbidden now |

---

## 13.2 close criteria (repeat)

Task text (`tasks.md` 13.2):

> R02 Sema authority: replace the `asCScriptNode` syntax walk with a Sema environment (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets). Sealed dumps/views must show those facts so backends do not rerun Sema.

**This leftover map does not close 13.2.** Checking the box from LocalDecl / InitList greens, SemaAuthority prefix greens, control-jump greens, or later Conditional / literal greens would be 虚标.

What must be true to check 13.2 (all of them):

1. **Dedicated intern path** for lookup, overload, conversion, call, lifetime, and control. `ActOnParsed*` dispatches those known kinds to `ActOnCallExpr` / `ActOnCastExpr` / `ActOnConstruct` / `ActOnReturnStmt` / `ActOnAssignExpr` / `ActOnBinaryExpr` / `ActOnLogicalExpr` / `ActOnIfStmt` / `ActOnWhileStmt` / `ActOnForStmt` / `ActOnSwitchStmt` / `ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr` / `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` / `ActOnQualType` / `ActOnDeclRefExpr` / `ActOnLocalDeclStmt` / `ActOnInitList` / `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnFallthroughStmt` / Conditional / leftover literals / … **without** `ActOn*FromNode` as the intern. Child extraction may still read `asCScriptNode` as Parser recovery input.
2. **FromNode is true leftover recovery**, not the implementation for listed kinds. Allowed recovery: syntax-only children (`snArgList`, pre/post/op tokens, `snScope`, `snExprValue` wrapper, `snUndefined`), `default` unknown nodes, rejected dialect (`try`/`catch`, script `funcdef`, `@`, `is`, virtual property), unused parser nodes (`snMixin`, `snAccessDeclaration`, `snClassDefaultStatement`) until a dump exists.
3. **Not allowed as “recovery”:** Conditional, leftover float/string/`nullptr` literals, ExprStmt intern, Case peel, WalkOne named decls, function body syntax walk, `snExprTerm` postfix `()` that still decides call/construct — once those are on the canonical language path.
4. **Sealed dumps/views** already print interned `type=` / `dest=` / `src=` / `callee=` / control `target=` for landed fixtures. That is **not** sufficient.
5. **CANONICAL backends do not re-decide** those facts (do not re-select overloads, re-rank conversions, or re-infer control targets). Isolated `Generate()` for the ProductionCodeGen integer/overload subset consumes sealed CALL decl ids. That is a slice, not 13.2.
6. **4.2–5.9 language coverage is still incomplete**, and the task says those cannot complete without the Sema environment. Incomplete 4.2–5.9 **keeps 13.2 `[ ]` even after dedicated dispatch**. Honest holes: script `funcdef` rejected; stored capturing closures not Sema facts; exception tables rejected; generated accessors/list factories (5.9); fallthrough targets (5.6); production identity (13.3).

**LEGACY `asCCompiler` is the default opt-out.** That is not itself the 13.2 definition, and deleting `asCCompiler` is not the close. It does prove the **default production pipeline** still reruns Sema. 13.2 is Sema authority on the **canonical** path so backends consume sealed facts. Wave G default CANONICAL is a later flip.

Parser may keep building `asCScriptNode` as recovery input. 13.2 is not “Parser stops allocating nodes.” 13.2 is “Sema environment is the authority; syntax walk is not.”

**Leave 13.2 / 13.3 / 4.2 / 5.9 / 5.6 `[ ]` after every slice this leftover map describes.**
