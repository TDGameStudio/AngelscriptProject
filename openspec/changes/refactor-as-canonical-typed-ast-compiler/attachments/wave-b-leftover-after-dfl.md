# Wave B leftover intern after DFL (DoWhile / Foreach / Lambda)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 stays `[ ]`.** Do not check 13.3 / 4.2 / 5.9 from this map.

**Goal:** After exclusive UBT `B-dowhile-foreach-lambda` lands dedicated intern (`ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr`), list every `asCScriptNode` kind that **still intern meaning** through `ActOnExprFromNode` / `ActOnStmtFromNode` / `WalkOne` / `ActOnQualTypeFromNode`. Map each leftover to an existing builder or a missing Clang-shaped intern `ActOn*`. Propose the **next** exclusive-UBT slice.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM. Fork frontend files stay free of Unreal types. Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null`. **F4 LEGACY lambda is not this inventory.**

Live file:line below is from this worktree (2026-08-22). `wave-b-fromnode-inventory.md` Cast/Assign rows and post-control leftover list are historical; this file is the leftover authority after DFL.

## 13.2 stays `[ ]`

Task 13.2 is a Sema **environment** (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets) so CANONICAL backends do not rerun Sema. Dedicated DFL intern, SemaAuthority prefix greens, and dump `type=` / `callee=` / `target=` do **not** close it. Incomplete 4.2–5.9 keeps the box `[ ]`.

## Assumed DFL intern (do not list as leftover intern)

Dedicated intern already landed, plus DFL (assume GREEN):

| Kind | Dedicated intern | Extract wrapper may still read `asCScriptNode` |
| --- | --- | --- |
| `snFunctionCall` | `ActOnCallExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1414` still calls FromNode extract; FromNode `as_sema_expr.cpp:1131` then `ActOnCallExpr` |
| `snCast` | `ActOnCastExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1417`; FromNode `as_sema_expr.cpp:1224` |
| `snConstructCall` | `ActOnConstruct` | `ActOnParsedExpr` `as_sema_decl.cpp:1437`; FromNode `as_sema_expr.cpp:1199` |
| `snAssignment` | `ActOnAssignExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1454`; FromNode `as_sema_expr.cpp:1471` |
| `snExpression` | `ActOnBinaryExpr` / `ActOnLogicalExpr` | `ActOnParsedExpr` `as_sema_decl.cpp:1476`; FromNode `as_sema_expr.cpp:1424` still spells `ttIs` / `ttNotIs` — script `is` stays rejected |
| `snReturn` | `ActOnReturnStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1552`; FromNode `as_sema_stmt.cpp:471` |
| `snIf` | `ActOnIfStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1571`; FromNode `as_sema_stmt.cpp:489` |
| `snWhile` | `ActOnWhileStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1584`; FromNode `as_sema_stmt.cpp:505` |
| `snFor` | `ActOnForStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1592`; FromNode `as_sema_stmt.cpp:541` |
| `snSwitch` | `ActOnSwitchStmt` + `FinishSwitchStmt` | `ActOnParsedStmt` `as_sema_decl.cpp:1611`; FromNode `as_sema_stmt.cpp:605` |
| `snDoWhile` | **`ActOnDoWhileStmt` (DFL)** | Live intern is still FromNode fill `as_sema_stmt.cpp:521`. After DFL: extract then dedicated; early-return filled do-while |
| `snForEach` | **`ActOnForeachStmt` (DFL)** | Live intern is still FromNode fill `as_sema_stmt.cpp:568`. `ActOnParsedStmt` does **not** list `snForEach` today (`as_sema_decl.cpp:1630` → `default` `1638`). After DFL: listed dedicated case |
| `snFunction` as **lambda expr** | **`ActOnLambdaExpr` (DFL)** | Live intern is `ActOnLambdaFromNode` `as_sema_decl.cpp:995` (FromNode). After DFL: extract-then-`ActOnLambdaExpr`. **`ActOnLambdaFromNode` is not dedicated.** Parser `ParseLambda` `NotifySema` `as_parser.cpp:1799` |

Child extraction for those kinds may still call leftover FromNode for members / QualType / locals / literals. That is leftover **children**, not leftover intern of the parent kind.

`eScriptNode` has **49** enumerators (`as_scriptnode.h:47`). Dedicated intern after DFL covers **12** node kinds (`snFunctionCall` `snCast` `snConstructCall` `snReturn` `snAssignment` `snExpression` `snIf` `snWhile` `snFor` `snSwitch` `snDoWhile` `snForEach`). Lambda intern is dedicated but `snFunction` remains leftover for decl/method/body. **37 leftover kinds** still intern through FromNode / WalkOne / QualTypeFromNode.

---

## How to read the leftover table

- **Current intern path:** function that **creates** the AST node after DFL (not the Parser recovery tree).
- **Existing dedicated ActOn\*:** builder on `as_sema.h` vs intern authority. Builder presence ≠ intern.
- **Parser already NotifySema?:** incremental `NotifySema` → `ActOnParsedDeclaration` (`as_parser.cpp:132`) or `ActOnParsedExpr` / `ActOnParsedStmt` / `BeginParsedControl`.
- **Dump facts already locked?:** SemaAuthority `ParserActOn*` / compile→seal dumps. Dump-green ≠ dedicated intern.
- **Blocks 13.2?:** whether this kind still carries lookup / overload / conversion / call / lifetime / control that backends must not re-decide. `No` means true leftover recovery is allowed for 13.2 *authority* (the box still stays `[ ]` for other reasons).

---

## Expr leftover intern

| Node kind | Current intern path | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- |
| `snExprTerm` | `ActOnExprFromNode` `as_sema_expr.cpp:1242` (shared with `snExprValue`): pre-op `ActOnUnary` / method unary `ActOnCall`; post-op `.` `ActOnMemberRef` / `TryRewritePropertyGet` `as_sema_expr.cpp:141` / member call FromNode with `implicitReceiver`; `[]` `ActOnIndex` + `opIndex` `FindBestCallee`; `()` `ActOnCall` / construct; sequence `ActOnSequence`. `ActOnParsedExpr` leftover arm `as_sema_decl.cpp:1508` | Builders: `ActOnUnary` `as_sema.h:36`, `ActOnMemberRef` `:50`, `ActOnIndex` `:49`, `ActOnSequence` `:48`, `ActOnCall` `:44`. **Missing intern:** `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` (lookup + overload without a script node) | **Yes** when init-list / pre-op / post-op: `ParseExprTerm` `as_parser.cpp:2223`, `2235`, `2263`, `2287`, `2300`. Unary: `ParserActOnUnaryMinusBeforeFunctionCloseFails`. Member incomplete: `ParserActOnMemberOverloadCallBeforeArgListCloseFails`. Index: `ParserActOnIndexBeforeCloseBracketFails`, `ParserActOnIndexRecordsOpIndexOnSuccessfulParse` | Unary `kind=Unary` `literal=-` or `callee=opNeg`; member `callee=T::Get(int)` not `T::Get(float)`; index `kind=Index` + success `callee=T::opIndex(int)` once | **Next exclusive UBT:** `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr`; implicit receiver into already-landed `ActOnCallExpr`; property Get stays in the member action, not FromNode | **Yes** — overload, call, property Get, index single-eval |
| `snVariableAccess` | FromNode `as_sema_expr.cpp:1087` → `ResolveScopeOwner` + `ActOnDeclRef`. `ActOnParsedExpr` leftover `as_sema_decl.cpp:1506` | Builder `ActOnDeclRef` `as_sema.h:35`. **Missing intern:** `ActOnDeclRefExpr(owner, name, range)` using `LookupCandidates` / `LookupCandidatesFrom` | **Yes** `ParseVariableAccess` `as_parser.cpp:1870`. `ParserActOnVariableAccessBeforeFunctionCloseFails` | `kind=DeclRef` + `kind=Param name=i` | `ActOnDeclRefExpr` after members (or helper inside member UBT if snExprTerm needs named lookup). Do not redo Call | **Yes** — symbols / lookup |
| `snCondition` | FromNode `as_sema_expr.cpp:1453` → `ActOnConditional`. `ActOnParsedExpr` leftover `as_sema_decl.cpp:1509` | Builder `ActOnConditional` `as_sema.h:41`. **Missing intern:** `ActOnConditionalExpr` | **Yes** when `?` present: `ParseCondition` `as_parser.cpp:2102`, `2114`, `2124`, `2130`. Bare EXPR does **not** ActOn the wrapper. Tests: `ParserActOnConditionalBeforeElseCloseFails`, `ParserActOnConditionalRecordsTernaryOnSuccessfulParse` | ternary `kind=Conditional` + `callee=F(int)` not `F(float)` | `ActOnConditionalExpr` after members/binary; keep FromNode recovery for missing arms | **Partial** — control-like expr, conversion of arms |
| `snInitList` | FromNode `as_sema_expr.cpp:1492` `CreateExpr(CONSTRUCT)` + `literal=list-pattern` (not `ActOnConstruct`). `ActOnParsedExpr` leftover `as_sema_decl.cpp:1507` | **None** for list-pattern. `ActOnConstruct` is TYPE ARGLIST | **No** on `ParseInitList` `as_parser.cpp:4349`. Indirect: parent `snExprTerm` ActOn `as_parser.cpp:2223`/`2235`. Local `{...}`: `ParseDeclaration` `ActOnParsedStmt` `as_parser.cpp:4557` | `literal=list-pattern` `args=1,2` (`ParserActOnListPatternBeforeBlockCloseFails` — this lock is **InitList**, not decl `snListPattern`) | `ActOnInitList` / list-factory construct after QualType + local decl. Do not merge with `snListPattern` | **Yes** — 5.9 list factory / construction / lifetime |
| `snConstant` | FromNode `as_sema_expr.cpp:1055` → `ActOnIntegerLiteral` / `ActOnBoolLiteral` / `CreateExpr` float/string/`ttNull` | Builders `ActOnIntegerLiteral` `as_sema.h:33`, `ActOnBoolLiteral` `:34`. **Missing:** `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral`. Fork: intern `nullptr`, not script `null` as a language feature | **No** on `ParseConstant` `as_parser.cpp:1665` / `ParseStringConstant` `1811`. Intern as child of assignment/return/call extract | int/bool via many ParserActOn + no-script-node Call tests. Float/string/null **not** interned-key locked (5.2 remainder) | `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral` after QualType; keep `nullptr` | **Partial** — canonical types. Not the next slice |
| `snExprValue` | FromNode `as_sema_expr.cpp:1242` walks children (Call/Construct/DeclRef/Lambda/Cast/literal) | None on the wrapper. Children use dedicated Call/Cast/Construct/Lambda-after-DFL + leftover VarAccess/Constant | **No** on wrapper `ParseExprValue` `as_parser.cpp:1567`. Children NotifySema themselves | Indirect via children | Keep as recovery wrapper; intern children via dedicated actions | **No** (wrapper) once children dedicated |
| `snArgList` | No AST intern. Call/Construct extract walks `firstChild` `as_sema_expr.cpp:1175`, `1215` | None | No `ParseArgList` `as_parser.cpp:1895` | nargs/reverse-formal locked on Call | Keep as Parser recovery tree | **No** |
| `snNamedArgument` | Call FromNode extract reads ident + `lastChild` `as_sema_expr.cpp:1181` | None. `ActOnCallExpr` already reorders names | No `as_parser.cpp:1962` | named/default args on compile→seal Call dumps | Keep extract inside Call peel | **No** once Call extract stays dedicated |
| `snExprPreOp` / `snExprPostOp` / `snExprOperator` | Syntax children of Term/Expression. Term FromNode switches on pre/post `as_sema_expr.cpp:1264`, `1303`. Operator token on Expression `as_sema_expr.cpp:1429`. `ParseExprPreOp` `as_parser.cpp:2309`, `ParseExprPostOp` `2330`, `ParseExprOperator` `2387`, `ParseAssignOperator` `2407` | None | No on the op node; parent Term/Expression ActOn | Unary / binary / index via parent tests | Keep as recovery tokens. `@` pre-op stays rejected dialect | **No** (recovery child) |
| `snScope` | Call/VarAccess FromNode `ResolveScopeOwner` (`as_sema_expr.cpp:1108`, `1193`). `ParseOptionalScope` `as_parser.cpp:322` | None. `LookupCandidatesFrom` `as_sema.h:91` exists | No | `callee=Game::F(int)` compile→seal | Pass scope owner into Call/DeclRef actions | **Partial** (symbols). Not its own intern kind |

---

## Stmt leftover intern

| Node kind | Current intern path | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- |
| `snStatementBlock` | `ActOnStmtFromNode` `as_sema_stmt.cpp:326` → local decls inline + `ActOnBlock`. Nested-block comment `as_sema_stmt.cpp:405`: must not steal function body. WalkOne function body still `ActOnStmtFromNode(body)` `as_sema_decl.cpp:1183` | Builder `ActOnBlock` `as_sema.h:55`. **Missing intern:** `ActOnCompoundStmt` that only attaches already-interned children | **No** ActOn on the block. `ParseStatementBlock` `as_parser.cpp:4261` only `NotifySema`s local `snDeclaration` `as_parser.cpp:4303` | Nested block must not steal function body | `ActOnCompoundStmt` after local-decl intern; WalkOne/Lambda body becomes attach-only | **Partial** (scopes). Wrapper OK if children dedicated |
| `snDeclaration` (local) | Stmt FromNode `as_sema_stmt.cpp:409` and block arm `as_sema_stmt.cpp:331`: `ActOnQualTypeFromNode` + `ActOnVarDecl` + init FromNode / `ActOnConstruct` / default construct. `ActOnParsedStmt` leftover `as_sema_decl.cpp:1631` | Builders `ActOnVarDecl` `as_sema.h:21`, `ActOnDeclRef`, `ActOnAssign`, `ActOnConstruct`. **Missing intern:** `ActOnLocalDeclStmt` | **Yes** success-path locals `as_parser.cpp:4303` (`NotifySema` = `ActOnParsedDeclaration` → **WalkOne**, not `ActOnParsedStmt`). Init-list assign `ActOnParsedStmt` `as_parser.cpp:4557` | `kind=Var name=x` incomplete local-in-body; `kind=Var name=i` for-header tests | `ActOnLocalDeclStmt` using `ActOnQualType` + dedicated init expr. After QualType | **Yes** — symbols, construction, lifetime |
| `snExpressionStatement` | FromNode `as_sema_stmt.cpp:460` → `ActOnExprStmt(ActOnExprFromNode(firstChild))`. `ActOnParsedStmt` leftover `as_sema_decl.cpp:1630` | Builder `ActOnExprStmt` `as_sema.h:56` | **Yes** missing `;` `as_parser.cpp:4659`; success `4667`. `ParserActOnExprStmtSuccessBeforeFunctionCloseFails`, `ParserActOnExprStmtDoesNotDuplicateOnSuccessfulParse` | `kind=ExprStmt` / inner Call | Dispatch `ActOnExprStmt(owner, dedicatedExpr)` without StmtFromNode intern | **No** once child expr is dedicated |
| `snCase` | FromNode `as_sema_stmt.cpp:621` → `ActOnCase` + inner `ActOnStmtFromNode`. Not listed in `ActOnParsedStmt` → `default` `as_sema_decl.cpp:1638` | Builder `ActOnCase` `as_sema.h:70` | **No.** `ParseCase` `as_parser.cpp:4851`–`4906` never `ActOnParsedStmt`. Intern when parent switch extract walks children | Switch-body tests intern cases via parent Switch | `ActOnCaseStmt` from Parser after `:`; parent Switch extract attaches cases without StmtFromNode intern of the case node | **Partial** (control). After Switch dedicated (already landed) |
| `snBreak` | FromNode `as_sema_stmt.cpp:652` → `ActOnBreak(NearestControl)`. `ActOnParsedStmt` leftover `as_sema_decl.cpp:1632` | Builder `ActOnBreak` `as_sema.h:65`. **Missing intern:** `ActOnBreakStmt` dispatch that is not FromNode | **Yes** missing `;` `as_parser.cpp:5476`; success `5484`. `ParserActOnBreak*` + while/switch target tests | `kind=Break`; `target=` matches While/Switch id | `ActOnBreakStmt` using control stack (`BeginParsedControl` already `PushControl` `as_sema_stmt.cpp:206`) | **Yes** — control targets |
| `snContinue` | FromNode `as_sema_stmt.cpp:661` → `ActOnContinue`. `ActOnParsedStmt` leftover `as_sema_decl.cpp:1633` | Builder `ActOnContinue` `as_sema.h:66` | **Yes** `as_parser.cpp:5514` / `5522`. `ParserActOnContinue*` | `kind=Continue` `target=` For id | Same control-jump slice as Break | **Yes** — control targets |
| `snFallthrough` | FromNode `as_sema_stmt.cpp:670` → `ActOnFallthrough`. Target wired later `FinishSwitchStmt` → `WireFallthroughTargets` `as_sema_stmt.cpp:99`, `327`. `ActOnParsedStmt` leftover `as_sema_decl.cpp:1635` | Builder `ActOnFallthrough` `as_sema.h:71` | **Yes** `as_parser.cpp:4836` / `4844`. `ParserActOnFallthrough*` | `kind=Fallthrough` (no-dup once). `target=` still 5.6-open | Wire target in dedicated Switch/Case extract, not a new FromNode intern | **Yes** (5.6 control). After Case peel |
| `try` / `catch` (no enumerator) | Stmt FromNode `default` `as_sema_stmt.cpp:679` diagnostic `try-catch-rejected` | None. Stay rejected | No | Rejection diagnostic (`AngelscriptNativeCanonicalASTBodySemaTests.cpp`) | Keep FromNode/default recovery | **No** (rejected) |

---

## Decl / type leftover intern

Decl intern is **`ActOnParsedDeclaration` → `WalkOne`** (`as_sema_decl.cpp:1343`, `1377`, `WalkOne` `1013`). Builders exist; WalkOne is still the syntax walk 13.2 names. After DFL, `snFunction` **lambda intern** is dedicated; WalkOne `snFunction` remaining is function/method/mixin **decl** + body attach.

| Node kind | Current intern path | Existing dedicated ActOn* (builder vs intern) | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2 lookup/overload/conversion/call/lifetime/control? |
| --- | --- | --- | --- | --- | --- | --- |
| `snDataType` / type mods | **`ActOnQualTypeFromNode`** `as_sema_decl.cpp:287` (node walk + `FormatTypeKey` + Engine `GetTypeInfoByDecl`). Consumed by WalkOne decls, Cast/Construct extract, local decl FromNode, `ActOnFunctionLike` `as_sema_decl.cpp:767` | **No** `ActOnQualType(name, quals)`. Only FromNode `as_sema.h:72` | No ActOn on the type node. `ParseDataType` `as_parser.cpp:682`, `ParseTypeMod` `426` | interned `type=int` / `dest=float` / `src=int` on dumps | **`ActOnQualType`** from token/key/quals; keep FromNode as recovery. Second exclusive UBT after members | **Yes** — canonical types, conversions (4.3) |
| `snFunction` (decl / method / mixin function) | WalkOne `as_sema_decl.cpp:1173` → `FindExistingFunctionLike` / `ActOnFunctionLike` + **`ActOnStmtFromNode(body)`** `1183`. Mixin: parser never `CreateNode(snMixin)`; `ParseMixin` `as_parser.cpp:3879` returns `ParseFunction` | Builders `ActOnFunctionDecl` `as_sema.h:22`, `ActOnMethodDecl` `:23`, `ActOnConstructorDecl` `:24`, `ActOnParamDecl` `:26`, `ActOnMixinDecl` `:29`. Body intern is still StmtFromNode | **Yes** after name+params before body `as_parser.cpp:3692`; interface methods `3742`. Mixin tests: `ParserActOnMixinFunctionDeclBeforeBodyFails` | `key=Broken(int)`; mixin `MixHelper` | Decl extract already ActOn builders via WalkOne. Body must stop being StmtFromNode for 13.2 (compound + leftover stmts). Lambda intern is DFL, not this row | **Yes** — function body still syntax walk; lookup/control of body children |
| `snDeclaration` (global / member) | WalkOne `as_sema_decl.cpp:1192` → `ActOnQualTypeFromNode` + `ActOnVarDecl`; mutable global diagnostic | `ActOnVarDecl` | Success `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704` | global `kind=Var`; `mutable-global-rejected` | `ActOnVarDecl` after dedicated QualType. Mutable globals stay intern-then-reject | **Partial** (4.2 symbols). Mutable-global is rejected dialect |
| `snNamespace` | WalkOne `as_sema_decl.cpp:1026` → `ActOnNamespaceDecl` | Builder `ActOnNamespaceDecl` `as_sema.h:17` | **Yes** after identifier `as_parser.cpp:2791` + `PushLastActed` | `kind=Namespace name=` | Parser extract → `ActOnNamespaceDecl` without WalkOne intern; WalkOne FindExisting only | **Partial** (scopes). 4.2 remainder |
| `snClass` | WalkOne `as_sema_decl.cpp:1039` → `ActOnClassDecl` + bases + generated lifecycle/accessors | `ActOnClassDecl`, `ActOnConstructorDecl`, `ActOnDestructorDecl` | **Yes** after identifier `as_parser.cpp:3953` | `kind=Class`; ctors `T::T()` / `T::T(int)` / `T::~T()` | Extract name → `ActOnClassDecl` | **Partial** (4.2/4.5 generated accessors still 5.9) |
| `snInterface` | WalkOne `as_sema_decl.cpp:1055` → `ActOnInterfaceDecl` | `ActOnInterfaceDecl` `as_sema.h:30` | **Yes** `as_parser.cpp:3805` | `kind=Interface` | Extract → dedicated | **Partial** (4.2) |
| `snEnum` | WalkOne `as_sema_decl.cpp:1069` → `ActOnEnumDecl` + enumerator `ActOnVarDecl` | `ActOnEnumDecl`, `ActOnVarDecl` | **Yes** after name `as_parser.cpp:2937`; each enumerator ident `2986` | `kind=Enum` + enumerator vars | Extract → dedicated | **Partial** (4.2) |
| `snTypedef` | WalkOne `as_sema_decl.cpp:1098` → `ActOnTypedefDecl` | `ActOnTypedefDecl` `as_sema.h:28` | **Yes** after identifier before `;` `as_parser.cpp:5569` | `kind=Typedef` | Extract → dedicated | **Partial**. Script `funcdef` stays rejected; typedef is allowed |
| `snImport` | WalkOne `as_sema_decl.cpp:1119` → `ActOnImportDecl` + origin + `ActOnQualTypeFromNode` + params | `ActOnImportDecl` `as_sema.h:20` | **Yes** after name+params before `from` `as_parser.cpp:2587`; again after module string `2626` | `kind=Import` `route=import` | Extract → dedicated; origin after `from` | **Partial** (5.9 import CodeGen still open) |
| `snListPattern` | WalkOne `as_sema_decl.cpp:1238` → dependency string + generated `ActOnVarDecl` name `list-pattern` | None dedicated | `ParseListPattern` `as_parser.cpp:1309` **has no NotifySema**. Intern on parent function WalkOne. **Different from expr `snInitList` `{1,2`.** | Incomplete `{1,2` lock is **InitList**, not this node | `ActOnListPatternDecl` when factory decls matter (5.9). Do not merge with InitList | **Partial** (5.9). Not next expr slice |
| `snIdentifier` (enumerator) | WalkOne `as_sema_decl.cpp:1269` under enum; also `NotifySema(ident)` `as_parser.cpp:2986` | `ActOnVarDecl` | **Yes** `as_parser.cpp:2986` | enumerator names | Covered by Enum action | **No** as standalone intern kind |
| `snParameterList` | `WalkParameterList` `as_sema_decl.cpp:566` from WalkOne function/import/funcdef | Builder `ActOnParamDecl` `as_sema.h:26` | No ActOn on the list; function NotifySema walks params | `ByVal(int)` vs `ByRef(const int&in)` | `ActOnParam` during function ActOn | **Partial** (4.4 signatures) |
| `snScript` | `ActOnParsedScript` `as_sema_decl.cpp:1644` walks children `ActOnParsedDeclaration`. Fallback if `semaDeclActions == 0`: `as_parser.cpp:2529` | `ActOnTranslationUnit` `as_sema.h:16` | Fallback only | TU `kind=TranslationUnit` | Keep. Not an expression intern | **No** (container) |
| `snFuncDef` | WalkOne `as_sema_decl.cpp:1111` → `ActOnFuncDefDecl` | `ActOnFuncDefDecl` `as_sema.h:31` | **No** inside `ParseFuncDef` `as_parser.cpp:3523`–`3571`. Only successful `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704` if the token parses. Script `funcdef` is **fork-rejected**. Host `RegisterFuncdef` allowed. `ParserActOnFuncdef*` are host/local-call dumps | Host funcdef call `callee=` | Do not add script `funcdef`. Leave WalkOne as recovery if token ever appears | **No** (rejected dialect). 4.2/5.9 stay open partly because of this |
| `snMixin` | **Parser never `CreateNode(snMixin)`** (repo grep empty). Mixin functions intern as `snFunction` | `ActOnMixinDecl` exists `as_sema.h:29` | Mixin keyword → `ParseFunction` NotifySema as function | mixin function keys | Do not invent `snMixin` intern. Use `ActOnMixinDecl` only if a real mixin-class node appears | **No** as a node kind today |
| `snVirtualProperty` | Parser `ParseVirtualPropertyDecl` errors `TXT_VIRTUAL_PROPERTY_REMOVED` `as_parser.cpp:3760` returns 0 | `ActOnPropertyDecl` exists `as_sema.h:27` | No | None | Stay rejected. Do not intern | **No** |
| `snAccessDeclaration` | Parser `ParseAccessDecl` `as_parser.cpp:3055`. WalkOne `default` `as_sema_decl.cpp:1288` | None | **No** NotifySema in `ParseAccessDecl` | None found | Recovery WalkOne until a dump exists | **No** today |
| `snClassDefaultStatement` | Parser `as_parser.cpp:3214`. WalkOne default | None | **No** NotifySema in `ParseClassDefaultStatement` | None found | Recovery | **No** today |
| `snUndefined` | Init-list hole nodes; Expr FromNode `default` firstChild recurse `as_sema_expr.cpp:1518` | None | No | None | Keep default recovery | **No** |

---

## Row / leftover counts

| Group | Leftover intern kinds (after DFL) |
| --- | --- |
| Expr | 10 rows (`snExprTerm`, `snVariableAccess`, `snCondition`, `snInitList`, `snConstant`, `snExprValue`, `snArgList`, `snNamedArgument`, pre/post/op, `snScope`) covering **12** enumerators |
| Stmt | 7 rows + try/catch covering **7** enumerators (`snStatementBlock`, `snDeclaration` local, `snExpressionStatement`, `snCase`, `snBreak`, `snContinue`, `snFallthrough`) |
| Decl / type | 18 rows covering `snFunction` decl + types + unused/rejected |
| **Unique leftover `eScriptNode` kinds** | **37** (49 − 12 dedicated intern kinds) |
| True leftover recovery (section below) | **13** enumerators + try/catch token (no enumerator) |
| Remaining intern that still carries language meaning | **24** kinds (37 − 13 recovery) |

`snDeclaration` is one enumerator with two intern paths (local StmtFromNode + global WalkOne). `snFunction` is one enumerator: lambda intern dedicated after DFL; decl/method/body leftover.

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

**Not recovery** (must peel before 13.2 intern-authority can be claimed): `snExprTerm` member/index/unary, `snVariableAccess`, `snCondition`, `snInitList`, `snConstant` (types), local `snDeclaration`, `snCase`, `snBreak` / `snContinue` / `snFallthrough`, `ActOnQualTypeFromNode`, WalkOne named decls, function **body** StmtFromNode.

---

## Suggested exclusive-UBT order after DFL GREEN

Do not start these while `B-dowhile-foreach-lambda` holds `as_sema*` / SemaAuthority. F4 LEGACY lambda stays queued (`wave-d-95-f4-next.md`). No second UBT in `D:\as-cta`.

### 1. Next exclusive UBT — `B-member-index-unary` (recommended first)

`snExprTerm` → **`ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr`**.

Why first, not QualType:

- After DFL, `snExprTerm` is the largest remaining **expression intern** that still **decides overload** inside FromNode: property Get rewrite, `opIndex` `FindBestCallee`, unary method `ActOnCall`, member call with `implicitReceiver` into Call.
- 13.2 names lookup / overload / call. Members/index/unary are that remaining expr blob. Incomplete-parse dumps already lock `callee=T::Get(int)`, `callee=T::opIndex(int)`, unary minus — through FromNode, not dedicated intern.
- `ActOnQualType` is the second bottleneck (canonical types, 4.3) and is already **consumed** by landed Cast/Construct extract. Peeling QualType while members still intern via FromNode would not remove the biggest leftover overload walk.
- Combining members + QualType in one UBT is allowed by dispatch *only if DFL is already recorded green*, but `snExprTerm` intern is wide (pre/post/index/member/property/call). Keep QualType a separate RED/GREEN.

Must prove (shape, not this implementer):

1. No-script-node intern dumps for member / index / unary (reuse ParserActOn locks; add Sema*Action tests like DFL).
2. `ActOnParsedExpr` `snExprTerm` extracts then calls the dedicated actions. FromNode leftover for the kind is extract-then-dedicated, with FindExisting so bodies are not interned twice.
3. Implicit receiver goes into landed `ActOnCallExpr`. Do not reimplement Call.
4. Fork: no `@` intern; `nullptr` not `null`.

Must not: treat `ActOnUnary` / `ActOnMemberRef` / `ActOnIndex` builders as dedicated intern; start F4; flip default CANONICAL; check 13.2.

### 2. Then `B-qualtype`

`ActOnQualType(name, quals)` replacing `ActOnQualTypeFromNode` as intern. Keep FromNode as recovery. Cast/Construct/local-decl/import extract call the dedicated API.

### 3. Then (not this next UBT)

| Package | Contents | Gate |
| --- | --- | --- |
| `B-declref-conditional` | `ActOnDeclRefExpr` + `ActOnConditionalExpr` | After members (lookup helper may appear inside member UBT if required) |
| `B-local-initlist` | `ActOnLocalDeclStmt` + `ActOnInitList` | After QualType |
| `B-control-jump` | `ActOnBreakStmt` / `ActOnContinueStmt` / `ActOnCaseStmt` + fallthrough `target=` | After DFL control stack; Switch already dedicated |
| `B-walkone-decl` | WalkOne named decl extract (namespace/class/enum/…) | Not the 13.2 first bottleneck |
| F4 LEGACY lambda | `wave-d-95-f4-next.md` | After Wave B dedicated dispatch is honest enough |

Function **body** `ActOnStmtFromNode` (`as_sema_decl.cpp:1183`) becomes attach-only once leftover stmts/exprs intern dedicated (`ActOnCompoundStmt`). Do not start a body-only UBT while members/QualType still FromNode.

---

## 13.2 close criteria (repeat)

Task text (`tasks.md` 13.2):

> R02 Sema authority: replace the `asCScriptNode` syntax walk with a Sema environment (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets). Sealed dumps/views must show those facts so backends do not rerun Sema.

**This leftover map does not close 13.2.** Checking the box from DFL greens, SemaAuthority **146/146** / expected **149/149**, or later member/QualType greens would be 虚标.

What must be true to check 13.2 (all of them):

1. **Dedicated intern path** for lookup, overload, conversion, call, lifetime, and control. `ActOnParsed*` dispatches those known kinds to `ActOnCallExpr` / `ActOnCastExpr` / `ActOnConstruct` / `ActOnReturnStmt` / `ActOnAssignExpr` / `ActOnBinaryExpr` / `ActOnLogicalExpr` / `ActOnIfStmt` / `ActOnWhileStmt` / `ActOnForStmt` / `ActOnSwitchStmt` / `ActOnDoWhileStmt` / `ActOnForeachStmt` / `ActOnLambdaExpr` / member/index/unary / QualType / … **without** `ActOn*FromNode` as the intern. Child extraction may still read `asCScriptNode` as Parser recovery input.
2. **FromNode is true leftover recovery**, not the implementation for listed kinds. Allowed recovery: syntax-only children (`snArgList`, pre/post/op tokens, `snScope`, `snExprValue` wrapper, `snUndefined`), `default` unknown nodes, rejected dialect (`try`/`catch`, script `funcdef`, `@`, `is`, virtual property), unused parser nodes (`snMixin`, `snAccessDeclaration`, `snClassDefaultStatement`) until a dump exists.
3. **Not allowed as “recovery”:** member/index/unary, variable lookup, QualType, local decl, init-list/list-pattern, conditional, Break/Continue/Fallthrough/Case, WalkOne named decls, function body syntax walk — once those are on the canonical language path. Those still FromNode/WalkOne after DFL.
4. **Sealed dumps/views** already print interned `type=` / `dest=` / `src=` / `callee=` / control `target=` for landed fixtures. That is **not** sufficient.
5. **CANONICAL backends do not re-decide** those facts (do not re-select overloads, re-rank conversions, or re-infer control targets). Isolated `Generate()` for the ProductionCodeGen integer/overload subset consumes sealed CALL decl ids. That is a slice, not 13.2.
6. **4.2–5.9 language coverage is still incomplete**, and the task says those cannot complete without the Sema environment. Incomplete 4.2–5.9 **keeps 13.2 `[ ]` even after dedicated dispatch**. Honest holes: script `funcdef` rejected; stored capturing closures not Sema facts; exception tables rejected; QualType still node-shaped (4.3); generated accessors/list factories (5.9); fallthrough targets (5.6); production identity (13.3).

**LEGACY `asCCompiler` is the default opt-out.** That is not itself the 13.2 definition, and deleting `asCCompiler` is not the close. It does prove the **default production pipeline** still reruns Sema. 13.2 is Sema authority on the **canonical** path so backends consume sealed facts. Wave G default CANONICAL is a later flip.

Parser may keep building `asCScriptNode` as recovery input. 13.2 is not “Parser stops allocating nodes.” 13.2 is “Sema environment is the authority; syntax walk is not.”

**Leave 13.2 / 13.3 / 4.2 / 5.9 `[ ]` after every slice this leftover map describes.**
