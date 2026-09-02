# Wave B FromNode inventory (post Call; next after Cast/Construct/Return)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. Read-only research. No UBT. No `Plugins/` edits. **13.2 / 13.3 / 4.2 / 5.9 stay `[ ]`.**

**Status 2026-08-22 after B-control-stmt:** Call / Cast / Construct / Return / Assign / Binary / Logical / If / While / For / Switch dedicated intern is **landed** (SemaAuthority **146/146**). The tables below still say “in progress” for Cast/Construct/Return and “highest leftover” for Assign — treat those rows as **historical**. Live leftover intern: **do-while / foreach / lambda** (exclusive UBT `wave-b-dfl-next.md`), then members/index/unary (`snExprTerm`), QualType, local decl, init-list, Break/Continue/Fallthrough. Refresh of that leftover list lives in `wave-b-leftover-after-dfl.md` (parallel attachment; do not collide).

**Goal:** Map every `asCScriptNode` kind that still intern meaning through `ActOnExprFromNode` / `ActOnStmtFromNode` / `WalkOne` / `ActOnQualTypeFromNode` / `ActOnLambdaFromNode`, so later exclusive-UBT slices replace generic `ActOnParsedExpr` / `ActOnParsedStmt` FromNode with Clang-shaped dedicated `ActOn*` without redoing Call or the live Cast/Construct/Return slice.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM. Fork frontend files stay free of Unreal types. Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` not `null`.

## Do not redo (current exclusive UBT + landed)

| Kind | Status | Intern today | Dedicated action | Parser NotifySema / ActOn | Dump locks | Next agent |
| --- | --- | --- | --- | --- | --- | --- |
| `snFunctionCall` | **Landed** SemaAuthority **135/135** `wave-b-call-expr-green` | `ActOnExprFromNode` extracts ident/args/scope then **returns `ActOnCallExpr`** (`as_sema_expr.cpp` ~982–1048) | `ActOnCallExpr` (no script node). Tests: `SemaCallExprActionSelectsIntOverloadWithoutScriptNode`, `SemaCallExprActionInsertsNamedConversionWithoutScriptNode` | Yes: `ParseFunctionCall` `ActOnParsedExpr` `as_parser.cpp:1851` | `callee=F(int)` `type=int`; Conversion `dest=float` `src=int` | Do not redo. Thin extract-then-`ActOnCallExpr` may stay. `ActOnParsedExpr` `case snFunctionCall` still calls FromNode as the extract wrapper. |
| `snCast` | **In progress** (`wave-b-dedicated-actions-next.md`) | `ActOnExprFromNode` → `ActOnConversion` (`as_sema_expr.cpp` ~1075–1096) | Planned `ActOnCastExpr` (new). Builder `ActOnConversion` already exists | Yes: `ParseCast` `ActOnParsedExpr` on error and success `as_parser.cpp:1540`, `1552`, `1560`. Tests: `ParserActOnCastBeforeCloseParenFails`, `ParserActOnCastRecordsConversionOnSuccessfulParse`, `ParserActOnConversionBeforeArgListCloseFails` | `kind=Conversion` `dest=float` `src=int` | Exclusive UBT owns. Do not start a second Cast slice. |
| `snConstructCall` | **In progress** | `ActOnExprFromNode` → `ActOnConstruct` (`as_sema_expr.cpp` ~1050–1073) | `ActOnConstruct` already exists; tests will lock ctor select `T::T(int)` without FromNode | Yes: `ParseConstructCall` `ActOnParsedExpr` `as_parser.cpp:1888`. Tests: `ParserActOnConstructCallBeforeArgListCloseFails`, `ParserActOnConstructTemporaryBeforeArgListCloseFails` | `kind=Construct` | Exclusive UBT owns. |
| `snReturn` | **In progress** | `ActOnStmtFromNode` → `ActOnCleanup?` + `ActOnReturnStmt` (`as_sema_stmt.cpp` ~387–403) | `ActOnReturnStmt` already exists; TDD without script node | Yes: `ParseReturn` `ActOnParsedStmt` `as_parser.cpp:5424`, `5436`. Tests: `ParserActOnReturnStmtBeforeSemicolonFails`, `ParserActOnReturnDoesNotDuplicateOnSuccessfulParse`, `ParserActOnBareReturnBeforeFunctionCloseFails` | `kind=Return` | Exclusive UBT owns. Child value extract may still FromNode. |

Incomplete-parse locks already true (do not redo the tests): member `v.Get(3` → `T::Get(int)` (`ParserActOnMemberOverloadCallBeforeArgListCloseFails`); binary `v - 3` → `T::opSub(int)` (`ParserActOnBinaryOverloadBeforeFunctionCloseFails`); list `{1, 2` → `literal=list-pattern` (`ParserActOnListPatternBeforeBlockCloseFails`). Those intern **through FromNode** today; the dumps are locks, not dedicated-action close.

`ActOnParsedExpr` / `ActOnParsedStmt` kind switches (`as_sema_decl.cpp:1411–1479`) still **all** call FromNode (listed kinds and `default`). Listing a kind in the switch is a label, not dedicated dispatch.

## How to read the table

- **Current intern path:** the function that actually creates the AST node.
- **Existing dedicated ActOn\*:** builder already on `as_sema.h`. Presence of a builder ≠ intern authority.
- **Parser already NotifySema?:** incremental `NotifySema` → `ActOnParsedDeclaration` (`as_parser.cpp:132`) or `ActOnParsedExpr` / `ActOnParsedStmt` / `BeginParsedControl`. If unsure, file:line is given.
- **Dump facts already locked?:** SemaAuthority `ParserActOn*` / compile→seal dumps. Dump-green ≠ dedicated intern.
- **Blocks 13.2?:** whether this kind still carries lookup / overload / conversion / call / lifetime / control that backends must not re-decide. `No` means leftover FromNode recovery is allowed for 13.2 *authority* (the box still stays `[ ]` for other reasons).

---

## Expr

| Node kind | Current intern path | Existing dedicated ActOn* | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2? |
| --- | --- | --- | --- | --- | --- | --- |
| `snConstant` | `ActOnExprFromNode` `as_sema_expr.cpp:906` → `ActOnIntegerLiteral` / `ActOnBoolLiteral` / CreateExpr float/string/null | `ActOnIntegerLiteral`, `ActOnBoolLiteral`. No `ActOnFloatLiteral` / `ActOnStringLiteral` / `ActOnNullLiteral` | **No** dedicated Parser ActOn on the constant node. Intern as child of assignment/return/call FromNode. | int/bool via many ParserActOn + no-script-node Call tests. Float/string/null **not** interned-key locked (5.2 still notes non-int constants) | `ActOnFloatLiteral` / `ActOnStringLiteral` after Cast slice; keep `nullptr` not `null` | Partial (canonical types). Not the next slice. |
| `snVariableAccess` | FromNode `as_sema_expr.cpp:938` → `ActOnDeclRef` + scope `ResolveScopeOwner` | `ActOnDeclRef`. No `ActOnDeclRefExpr(name, owner)` lookup action | **Yes** `ParseVariableAccess` `ActOnParsedExpr` `as_parser.cpp:1870`. Tests: `ParserActOnVariableAccessBeforeFunctionCloseFails` | `kind=DeclRef` via assign/variable tests | `ActOnDeclRefExpr(owner, name, range)` using `LookupCandidates` | Yes (symbols). After Assign/Call peel. |
| `snFunctionCall` | FromNode extract → **`ActOnCallExpr`** | `ActOnCallExpr`, `ActOnCall` | Yes `as_parser.cpp:1851` | `callee=F(int)` `type=int` | Landed. Do not redo | Landed intern; extract still node-shaped |
| `snConstructCall` | FromNode → `ActOnConstruct` | `ActOnConstruct` | Yes `as_parser.cpp:1888` | `kind=Construct` | Exclusive UBT `ActOnConstruct` dispatch | Yes (construction) — in progress |
| `snCast` | FromNode → `ActOnConversion` | `ActOnConversion`; planned `ActOnCastExpr` | Yes `as_parser.cpp:1540+` | `kind=Conversion` `dest=` `src=` | Exclusive UBT | Yes (conversions) — in progress |
| `snExprValue` | FromNode `as_sema_expr.cpp:1098` (shared with `snExprTerm`) walks children | None. Children use Call/Construct/DeclRef/Lambda/Cast | **No** ActOn on `snExprValue` itself. `ParseExprValue` `as_parser.cpp:1567` has no `ActOnParsedExpr` | Indirect via children | Keep as recovery wrapper; intern children via dedicated actions | No (wrapper) |
| `snExprTerm` | FromNode `as_sema_expr.cpp:1098`: pre-op `ActOnUnary` / method unary `ActOnCall`; post-op dot member `ActOnMemberRef` / property Get rewrite / member call `ActOnExprFromNode(..., implicitReceiver)` → CallExpr; `[]` `ActOnIndex` + `opIndex`; `()` `ActOnCall` / Construct; sequence `ActOnSequence` | `ActOnUnary`, `ActOnMemberRef`, `ActOnIndex`, `ActOnSequence`, `ActOnCall`. No `ActOnMemberExpr` / `ActOnIndexExpr` / `ActOnUnaryExpr` that lookup without a script node | **Yes** when pre/post-op present: `ParseExprTerm` `as_parser.cpp:2223`, `2235`, `2263`, `2287`, `2300`. Unary-minus lock: `ParserActOnUnaryMinusBeforeFunctionCloseFails`. Member incomplete: `ParserActOnMemberOverloadCallBeforeArgListCloseFails`. Index: `ParserActOnIndexBeforeCloseBracketFails`, `ParserActOnIndexRecordsOpIndexOnSuccessfulParse` | Unary minus; `callee=T::Get(int)`; `opIndex` on success | **High:** `ActOnUnaryExpr`, `ActOnMemberExpr`, `ActOnIndexExpr` (implicit receiver into `ActOnCallExpr`) | Yes (overload, index single-eval, property Get) |
| `snExpression` | FromNode `as_sema_expr.cpp:1280`: `ActOnLogical` / binary method `ActOnCall` + `ActOnConversion` / `ActOnBinary`. `ttIs` / `ttNotIs` still spelled in FromNode — script `is` stays rejected | `ActOnLogical`, `ActOnBinary`, `ActOnCall`, `ActOnConversion`. No `ActOnBinaryExpr` / `ActOnLogicalExpr` | **Yes** when an operator child exists: `as_parser.cpp:2175` (success) and `2191` (RHS error). Incomplete: `ParserActOnBinaryOverloadBeforeFunctionCloseFails`, `ParserActOnLogicalBeforeRhsCloseFails`, `ParserActOnLogicalRecordsShortCircuitOnSuccessfulParse` | `callee=T::opSub(int)` not `kind=Binary literal=-`; short-circuit Logical | **High:** `ActOnBinaryExpr` / `ActOnLogicalExpr` (operator method select like CallExpr) | Yes (overload, conversions, short-circuit) |
| `snCondition` | FromNode `as_sema_expr.cpp:1372` → `ActOnConditional` | `ActOnConditional` | **Yes** `ParseCondition` `as_parser.cpp:2102`, `2114`, `2124`, `2130`. Tests: `ParserActOnConditionalBeforeElseCloseFails`, `ParserActOnConditionalRecordsTernaryOnSuccessfulParse` | ternary `kind=Conditional` | `ActOnConditionalExpr` dispatch from `ActOnParsedExpr`; keep FromNode recovery for missing arms | Partial (control-like expr). After binary. |
| `snAssignment` | FromNode `as_sema_expr.cpp:1390` → property Set rewrite or `ActOnAssign` | `ActOnAssign` | **Yes** `ParseAssignment` `as_parser.cpp:2067`, `2073`. Tests: `ParserActOnAssignBeforeSemicolonFails`, `ParserActOnAssignDoesNotDuplicateOnSuccessfulParse`, `ParserActOnAssignSuccessBeforeFunctionCloseFails` | `kind=Assign` | **Highest leftover after Cast/Construct/Return:** `ActOnAssignExpr` (lookup + property Set + conversion) without FromNode intern | Yes (assignability, property Set, conversions) |
| `snInitList` | FromNode `as_sema_expr.cpp:1412` CreateExpr `CONSTRUCT` + `literal=list-pattern` (not `ActOnConstruct`) | None for list-pattern. `ActOnConstruct` is TYPE ARGLIST | **Indirect:** `ParseExprTerm` ActOn of parent `snExprTerm` `as_parser.cpp:2223`/`2235` after `ParseInitList`. `ParseInitList` `as_parser.cpp:4349` itself has **no** `ActOnParsedExpr`. Local decl `{...}`: `ParseDeclaration` `ActOnParsedStmt` `as_parser.cpp:4557` | `literal=list-pattern` `args=1,2` | `ActOnInitList` / list-factory construct; do not confuse with decl `snListPattern` | Yes (5.9 list factory). After Assign. |
| `snArgList` | No AST intern. Children walked by Call/Construct FromNode | None | No | nargs/reverse-formal locked on Call | Keep as Parser recovery tree | No (recovery child) |
| `snNamedArgument` | FromNode Call arm reads ident + lastChild (`as_sema_expr.cpp:1032`) | None. CallExpr already reorders names | No | named/default args on compile→seal Call dumps | Keep extract inside Call peel | No once Call extract is dedicated |
| `snExprPreOp` / `snExprPostOp` / `snExprOperator` | Syntax children of Term/Expression FromNode | None | No on the op node; parent Term/Expression ActOn | Unary / binary / index via parent tests | Keep as recovery tokens | No (recovery child) |
| `snScope` | FromNode Call/VarAccess `ResolveScopeOwner` | None. `LookupCandidatesFrom` exists | No | `callee=Game::F(int)` compile→seal | Scope owner into Call/DeclRef actions | Partial (symbols). Not its own intern kind. |

---

## Stmt

| Node kind | Current intern path | Existing dedicated ActOn* | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2? |
| --- | --- | --- | --- | --- | --- | --- |
| `snStatementBlock` | `ActOnStmtFromNode` `as_sema_stmt.cpp:242` → `ActOnBlock` (locals `ActOnVarDecl` + init FromNode / `ActOnConstruct`) | `ActOnBlock`, `ActOnVarDecl`, `ActOnExprStmt` | **No** ActOn on the block. `ParseStatementBlock` `as_parser.cpp:4261` only `NotifySema`s **local `snDeclaration`** `as_parser.cpp:4303`. Function body intern is WalkOne `snFunction` → `ActOnStmtFromNode(body)` `as_sema_decl.cpp:1182` | Nested block must not steal function body (comment `as_sema_stmt.cpp:321`) | `ActOnCompoundStmt` after local-decl ActOn; WalkOne body becomes attach-only | Partial (scopes). Wrapper recovery OK if children dedicated |
| `snDeclaration` (local) | Stmt FromNode `as_sema_stmt.cpp:325` and block arm `247` | `ActOnVarDecl`, `ActOnDeclRef`, `ActOnAssign`, `ActOnConstruct` | **Yes** success path local decls `as_parser.cpp:4303` (`NotifySema` = `ActOnParsedDeclaration` → **WalkOne**, not `ActOnParsedStmt`). Init-list assign also `ActOnParsedStmt` `as_parser.cpp:4557`. `ActOnParsedStmt` lists `snDeclaration` `as_sema_decl.cpp:1466` | `kind=Var name=` on for/foreach/if-body tests | `ActOnLocalDeclStmt` using `ActOnQualType` + init dedicated expr | Yes (symbols, construction). After QualType |
| `snExpressionStatement` | FromNode `as_sema_stmt.cpp:376` → `ActOnExprStmt` | `ActOnExprStmt` | **Yes** `ParseExpressionStatement` `as_parser.cpp:4659` (missing `;`) and `4667` (success). Tests: `ParserActOnExprStmtSuccessBeforeFunctionCloseFails`, `ParserActOnExprStmtDoesNotDuplicateOnSuccessfulParse` | `kind=ExprStmt` / inner Call | Dispatch `ActOnExprStmt(owner, dedicatedExpr)` | No once child expr is dedicated |
| `snIf` | FromNode `as_sema_stmt.cpp:405` → `ActOnIf` (FindExisting skip fill) | `ActOnIf` | **Yes** `ParseIf` `as_parser.cpp:4944` (missing `)`), `4954` (then error), `4966` (no else), `4976`/`4982` (else). **No** `BeginParsedControl` for if (only loops/switch `as_sema_stmt.cpp:166–204`). Tests: `ParserActOnIfBeforeCloseParenFails`, `ParserActOnIfDoesNotDuplicateOnSuccessfulParse`, `ParserActOnIfBodyBeforeBlockCloseFails`, `ParserActOnIfBodyRecordsSelectedCallOnSuccessfulParse` | `kind=If` + `callee=F(int)` on incomplete body | **High:** `ActOnIfStmt` fill/create without StmtFromNode intern | Yes (control targets) |
| `snWhile` | FromNode `as_sema_stmt.cpp:421`: FindExisting / `ActOnWhile` stub + `PushControl` + fill cond/body | `ActOnWhile` | **Yes** missing `)` `as_parser.cpp:5278`; **`BeginParsedControl` after `)`** `5285`; body error `5293`; success `5299`. Tests: `ParserActOnWhileBeforeCloseParenFails`, `ParserActOnWhileBody*` | `kind=While`; Break target on header stub `ParserActOnBreakRecordsWhileTargetBeforeBodyCloseFails` | Same control slice as If: `ActOnWhileStmt` | Yes |
| `snDoWhile` | FromNode `as_sema_stmt.cpp:441` | `ActOnDoWhile` | **Yes** `BeginParsedControl` **before body** `as_parser.cpp:5323`; ActOn on body/while/`(`/cond/`)`/`;` errors and success `5331`–`5396`. Tests: `ParserActOnDoWhileBeforeCloseParenFails`, `ParserActOnDoWhileBody*` | `kind=DoWhile` | Control slice | Yes |
| `snFor` | FromNode `as_sema_stmt.cpp:461` | `ActOnFor` | **Yes** cond error `as_parser.cpp:5023`; incr errors `5044`/`5061`; **`BeginParsedControl` after `)`** `5070`; body `5078`/`5084`. Tests: `ParserActOnForBeforeConditionCloseFails`, `ParserActOnForBody*`, `ParserActOnContinueRecordsForTargetBeforeBodyCloseFails` | `kind=For` + `kind=Var name=i` | Control slice | Yes |
| `snForEach` | FromNode `as_sema_stmt.cpp:497` | `ActOnForeach` | **Yes** `as_parser.cpp:5160`–`5237` + `BeginParsedControl` `5220`. Tests: `ParserActOnForeachBeforeColonFails`, `ParserActOnForeachBody*`. **`ActOnParsedStmt` switch does not list `snForEach`** (`as_sema_decl.cpp:1463`); intern is **`default` → `ActOnStmtFromNode`**. Unsure if that omission is intentional — file:line is the evidence. | `kind=ForEach` `kind=Var name=x` | Control slice + add listed case so default is true leftover recovery | Yes |
| `snSwitch` | FromNode `as_sema_stmt.cpp:534` + `WireFallthroughTargets` | `ActOnSwitch` | **Yes** missing `)` `as_parser.cpp:4741`; **`BeginParsedControl` after `)`** `4748`; `{`/case/body/`}` `4758`–`4808`. Tests: `ParserActOnSwitchBeforeCloseParenFails`, `ParserActOnSwitchBody*`, `ParserActOnBreakRecordsSwitchTargetOnSuccessfulParse` | `kind=Switch`; Break `target=` switch id | Control slice | Yes |
| `snCase` | FromNode `as_sema_stmt.cpp:560` → `ActOnCase` + inner `ActOnStmtFromNode` | `ActOnCase` | **No.** `ParseCase` `as_parser.cpp:4852`–`4906` never calls `ActOnParsedStmt`. Intern only when parent switch FromNode walks children, or when switch ActOn walks cases. Unsure of incomplete-case-only intern without parent ActOn. | Switch-body tests intern cases via parent | `ActOnCaseStmt` from Parser after `:` | Partial (control). After Switch dedicated |
| `snReturn` | FromNode → `ActOnReturnStmt` | `ActOnReturnStmt` | Yes `as_parser.cpp:5424+` | `kind=Return` | Exclusive UBT | Yes — in progress |
| `snBreak` | FromNode `as_sema_stmt.cpp:591` → `ActOnBreak(NearestControl)` | `ActOnBreak` | **Yes** missing `;` `as_parser.cpp:5476`; success `5484`. Tests: `ParserActOnBreakBeforeFunctionCloseFails`, `ParserActOnBreakBeforeSemicolonFails`, `ParserActOnBreakDoesNotDuplicateOnSuccessfulParse`, while/switch target tests | `kind=Break` `target=` | `ActOnBreakStmt` using control stack (header stub already `PushControl`) | Yes (control targets) |
| `snContinue` | FromNode `as_sema_stmt.cpp:600` → `ActOnContinue` | `ActOnContinue` | **Yes** `as_parser.cpp:5514`/`5522`. Tests: `ParserActOnContinue*` | `kind=Continue` `target=` for | Same control-jump slice as Break | Yes |
| `snFallthrough` | FromNode `as_sema_stmt.cpp:609` → `ActOnFallthrough` (target wired later on switch) | `ActOnFallthrough` | **Yes** `as_parser.cpp:4836`/`4844`. Tests: `ParserActOnFallthrough*` | `kind=Fallthrough`; compile→seal Continue/Break dumps; fallthrough `target=` still 5.6-open | Wire target in dedicated Switch/Case, not a new FromNode | Yes (5.6). After Switch |
| `try`/`catch` | Stmt FromNode `default` `as_sema_stmt.cpp:618` diagnostic `try-catch-rejected` | None. Stay rejected | No | Rejection diagnostic | Keep FromNode/default recovery | No (rejected) |

---

## Decl / type

Decl intern is **`ActOnParsedDeclaration` → `WalkOne`** (`as_sema_decl.cpp:1342`, `1376`, `WalkOne` `1012`). Builders `ActOnClassDecl` / `ActOnFunctionDecl` / … exist; WalkOne is still the syntax walk 13.2 names.

| Node kind | Current intern path | Existing dedicated ActOn* | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2? |
| --- | --- | --- | --- | --- | --- | --- |
| `snScript` | `ActOnParsedScript` `as_sema_decl.cpp:1483` walks children `ActOnParsedDeclaration` | `ActOnTranslationUnit` | Fallback only if `semaDeclActions == 0`: `as_parser.cpp:2531` | TU `kind=TranslationUnit` | Keep. Not an expression intern | No (container) |
| `snNamespace` | WalkOne `as_sema_decl.cpp:1025` → `ActOnNamespaceDecl` | `ActOnNamespaceDecl` | **Yes** after identifier `as_parser.cpp:2791` + `PushLastActed`. Nested: same. Tests: `ParserActOnNamespaceDeclBeforeInnerBodyFails`, `ParserActOnNestedNamespaceDeclBeforeInnerBodyFails` | `kind=Namespace name=` | Parser extract → `ActOnNamespaceDecl` without WalkOne; WalkOne FindExisting only | Partial (scopes). 4.2 remainder |
| `snClass` | WalkOne `1038` → `ActOnClassDecl` + bases + generated lifecycle/accessors | `ActOnClassDecl`, `ActOnConstructorDecl`, `ActOnDestructorDecl` | **Yes** after identifier `as_parser.cpp:3953`. Tests: `ParserActOnClassAndMethodDeclBeforeMemberBodyFails` | `kind=Class`; ctors `T::T()` / `T::T(int)` / `T::~T()` | Same: extract name → `ActOnClassDecl` | Partial (4.2/4.5 generated accessors still 5.9) |
| `snInterface` | WalkOne `1054` → `ActOnInterfaceDecl` | `ActOnInterfaceDecl` | **Yes** `as_parser.cpp:3805`. Tests: `ParserActOnInterfaceAndMethodDeclBeforeSignatureFails` | `kind=Interface` | Extract → dedicated | Partial (4.2) |
| `snEnum` | WalkOne `1068` → `ActOnEnumDecl` + enumerator `ActOnVarDecl` | `ActOnEnumDecl`, `ActOnVarDecl` | **Yes** after name `as_parser.cpp:2937`; each enumerator ident `2986`. Tests: `ParserActOnEnumDeclAndEnumeratorBeforeListCloseFails` | `kind=Enum` + enumerator vars | Extract → dedicated | Partial (4.2) |
| `snTypedef` | WalkOne `1098` → `ActOnTypedefDecl` | `ActOnTypedefDecl` | **Yes** after identifier before `;` `as_parser.cpp:5569`. Tests: `ParserActOnTypedef*` | `kind=Typedef` | Extract → dedicated | Partial. Script `funcdef` stays rejected; typedef is allowed |
| `snImport` | WalkOne `1118` → `ActOnImportDecl` + origin + `ActOnQualTypeFromNode` + params | `ActOnImportDecl` | **Yes** after name+params before `from` `as_parser.cpp:2587`; again after module string `2626`. Tests: `ParserActOnImportDeclBeforeFromFails` | `kind=Import` `route=import` | Extract → dedicated; origin after `from` | Partial (5.9 import CodeGen still open) |
| `snFunction` (decl / method / mixin function) | WalkOne `1172` → `FindExistingFunctionLike` / `ActOnFunctionLike` + **`ActOnStmtFromNode(body)`** | `ActOnFunctionDecl`, `ActOnMethodDecl`, `ActOnConstructorDecl`, `ActOnParamDecl` | **Yes** after name+params before body `as_parser.cpp:3692` (`notifySemaAfterParams`). Interface methods `3742`. Mixin: `ParseMixin` returns `ParseFunction` (snFunction, **not** `snMixin`) `as_parser.cpp:3881`. Tests: `ParserActOnFunctionDeclBeforeBodyParseFails`, `ParserActOnMixinFunctionDeclBeforeBodyFails` | `key=Broken(int)`; mixin `MixHelper` | Decl extract already ActOn builders via WalkOne. Body must stop being StmtFromNode for 13.2 | Yes (body still syntax walk) |
| `snFuncDef` | WalkOne `1110` → `ActOnFuncDefDecl` | `ActOnFuncDefDecl` | **No** inside `ParseFuncDef` `as_parser.cpp:3523`–`3569`. Only successful `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704` if the token parses. Script `funcdef` is **fork-rejected**. Host `RegisterFuncdef` allowed. Tests `ParserActOnFuncdef*` are host/local-call dumps, not script `funcdef` intern | Host funcdef call `callee=` | Do not add script `funcdef`. Leave WalkOne as recovery if token ever appears | No (rejected dialect). 4.2/5.9 stay open partly because of this |
| `snMixin` | WalkOne has a case in older maps; **parser never `CreateNode(snMixin)`** (grep empty). Mixin functions intern as `snFunction` | `ActOnMixinDecl` exists on `as_sema.h:29` | Mixin keyword → `ParseFunction` NotifySema as function | mixin function keys | Do not invent `snMixin` intern. Use `ActOnMixinDecl` only if a real mixin-class node appears | No as a node kind today |
| `snDeclaration` (global / member) | WalkOne `1191` → `ActOnQualTypeFromNode` + `ActOnVarDecl`; mutable global diagnostic | `ActOnVarDecl` | Success `ParseScript` `NotifySema(decl)` `as_parser.cpp:2704`. Local path is stmt (above) | global `kind=Var`; `mutable-global-rejected` | `ActOnVarDecl` after dedicated QualType | Partial (4.2) |
| `snListPattern` | WalkOne `1237` → dependency string + generated `ActOnVarDecl` name `list-pattern` | None dedicated | `ParseListPattern` `as_parser.cpp:1311` **has no NotifySema**. Intern on parent function WalkOne. **Different from expr `snInitList` `{1,2`.** | Incomplete `{1,2` lock is **InitList**, not this node | `ActOnListPatternDecl` when factory decls matter (5.9). Do not merge with InitList | Partial (5.9). Not next expr slice |
| `snIdentifier` (enumerator) | WalkOne `1268` under enum | `ActOnVarDecl` | **Yes** `as_parser.cpp:2986` | enumerator names | Covered by Enum action | No as standalone |
| `snDataType` / type mods | **`ActOnQualTypeFromNode`** `as_sema_decl.cpp:286` (node walk + `FormatTypeKey` + Engine `GetTypeInfoByDecl`) | **No** `ActOnQualType(name, quals)`. Only FromNode | No ActOn on the type node; consumed by decl/cast/construct FromNode | interned `type=int` / `dest=float` / `src=int` on dumps | `ActOnQualType` from token/key/quals; keep FromNode as recovery | Yes (canonical types, 4.3). After Cast uses it |
| `snParameterList` | `WalkParameterList` from WalkOne function/import/funcdef | `ActOnParamDecl` | No ActOn on the list; function NotifySema walks params | `ByVal(int)` vs `ByRef(const int&in)` | `ActOnParam` during function ActOn | Partial (4.4 signatures) |
| `snVirtualProperty` | Parser `ParseVirtualPropertyDecl` errors `TXT_VIRTUAL_PROPERTY_REMOVED` `as_parser.cpp:3767` returns 0 | `ActOnPropertyDecl` exists | No | None | Stay rejected. Do not intern | No |
| `snAccessDeclaration` | Parser `ParseAccessDecl` `as_parser.cpp:3055`. WalkOne `default` `WalkDecls` `as_sema_decl.cpp:1287` | None | **No** NotifySema in `ParseAccessDecl` (unsure if class body ever NotifySema this child except parent class WalkOne). file:line `3055` | None found | Recovery WalkOne until a dump exists | No today |
| `snClassDefaultStatement` | Parser `as_parser.cpp:3214`. WalkOne default | None | **No** NotifySema in `ParseClassDefaultStatement` | None found | Recovery | No today |
| `snUndefined` | Init-list hole nodes; Expr FromNode `default` firstChild recurse `as_sema_expr.cpp:1438` | None | No | None | Keep default recovery | No |

---

## Lambda

| Node kind | Current intern path | Existing dedicated ActOn* | Parser already NotifySema? | Dump facts already locked? | Suggested next dedicated action | Blocks 13.2? |
| --- | --- | --- | --- | --- | --- | --- |
| `snFunction` as lambda expr | **`ActOnLambdaFromNode`** `as_sema_decl.cpp:994` → FindExisting / `ActOnFunctionLike` + **`ActOnStmtFromNode(body)`** + `ActOnDeclRef`. Expr FromNode `snFunction` `as_sema_expr.cpp:1410`; stmt `snFunction` as expr-stmt `as_sema_stmt.cpp:385` | No node-free `ActOnLambdaExpr`. Function builders exist | **Yes** `ParseLambda` `NotifySema` after params before body `as_parser.cpp:1799`. Tests: `ParserActOnLambdaDeclBeforeBodyParseFails`, `ParserActOnLambdaDoesNotDuplicateOnSuccessfulParse`, `ParserActOnLambdaCallThroughRecordsCallee` | distinct `<lambda>(int)@offset`; call-through callee | `ActOnLambdaExpr(params, body)` that does not take `asCScriptNode`; body via dedicated stmts | Yes (4.2/5.9 closures). F4 LEGACY lambda is **not** this Wave B intern; do not start F4 from this inventory |

`ActOnLambdaFromNode` is itself a FromNode. Treating it as dedicated would be a 虚标.

---

## Row count

| Group | Rows in tables above |
| --- | --- |
| Do-not-redo (Call + Cast/Construct/Return) | 4 (also appear in expr/stmt where they still extract via FromNode) |
| Expr | 16 |
| Stmt | 16 |
| Decl / type | 18 |
| Lambda | 1 |
| **Inventory rows (expr+stmt+decl+lambda, unique kinds)** | **51** |
| Syntax-only / rejected / unused (`snArgList`, ops, `snScope`, `snFuncDef` rejected, `snMixin` unused, `snVirtualProperty`, `snAccessDeclaration`, `snClassDefaultStatement`, `snUndefined`) | included in 51 |

`eScriptNode` has 47 enumerators including `snUndefined`. Every enumerator is covered. Extra rows split `snFunction` decl vs lambda and note `snDeclaration` local vs global on one kind.

---

## Suggested exclusive-UBT order after Cast/Construct/Return

Do not start these while the Cast/Construct/Return UBT holds `as_sema*`.

1. **`snAssignment` → `ActOnAssignExpr`** — Parser already ActOn; `ActOnAssign` exists; property Set still FromNode; 13.2 assignability/conversion.
2. **`snExpression` → `ActOnBinaryExpr` / `ActOnLogicalExpr`** — incomplete `T::opSub(int)` already dump-locked through FromNode; remaining overload intern.
3. **`snIf` then the loop/switch family (`snWhile` / `snFor` / `snDoWhile` / `snSwitch` / `snForEach`) → dedicated `ActOn*Stmt` dispatch** — 13.2 control targets; `BeginParsedControl` stubs already exist; Break/Continue can follow on the same stack.

Then: `snExprTerm` member/index/unary; `ActOnQualType`; local `snDeclaration`; lambda `ActOnLambdaExpr`; InitList vs ListPattern.

Fork files: no Unreal types. No Clang/LLVM link. No script `funcdef` / `@` / `is`.

---

## 13.2 close criteria

Task text (`tasks.md` 13.2):

> R02 Sema authority: replace the `asCScriptNode` syntax walk with a Sema environment (scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetimes, control targets). Sealed dumps/views must show those facts so backends do not rerun Sema.

**This inventory does not close 13.2.** Checking the box from dedicated-action greens, SemaAuthority **135/135**, or later 138/138 would be 虚标.

What must be true to check 13.2 (all of them):

1. **Dedicated intern path** for lookup, overload, conversion, call, lifetime, and control. `ActOnParsed*` dispatches those known kinds to `ActOnCallExpr` / `ActOnCastExpr` / `ActOnConstruct` / `ActOnReturnStmt` / assign / control / … **without** `ActOn*FromNode` as the intern. Child extraction may still read `asCScriptNode` as Parser recovery input.
2. **FromNode is true leftover recovery**, not the implementation for listed kinds. Allowed recovery: syntax-only children (`snArgList`, pre/post/op tokens, `snScope`), `default` unknown nodes, rejected dialect (`try`/`catch`, script `funcdef`, `@`, `is`, virtual property), unused parser nodes (`snAccessDeclaration`, `snClassDefaultStatement`) until a dump exists.
3. **Not allowed as “recovery”:** assignment, if/loops/switch/foreach, lambda, QualType, member/index/logical/conditional, init-list/list-pattern, variable lookup — once those are on the canonical language path. Those still FromNode today.
4. **Sealed dumps/views** already print interned `type=` / `dest=` / `src=` / `callee=` / control `target=`. That part is largely true for the Call/conversion/control fixtures; it is **not** sufficient.
5. **Backends on the canonical path do not rerun Sema** (do not re-select overloads, re-rank conversions, or re-infer control targets). Isolated `Generate()` for the ProductionCodeGen integer/overload subset consumes sealed CALL decl ids. That is a slice, not 13.2.
6. **4.2–5.9 language coverage is still incomplete**, and the task says those cannot complete without the Sema environment. Incomplete 4.2–5.9 **keeps 13.2 `[ ]` even after dedicated dispatch**. Honest holes: script `funcdef` rejected; stored capturing closures not Sema facts; exception tables rejected; QualType still node-shaped (4.3); generated accessors/list factories (5.9); fallthrough targets (5.6); production identity (13.3).

**LEGACY `asCCompiler` is the default opt-out.** That is not itself the 13.2 definition, and deleting `asCCompiler` is not the close. It does prove the **default production pipeline** still reruns Sema. 13.2 is Sema authority on the **canonical** path so backends consume sealed facts. Wave G default CANONICAL is a later flip; do not treat LEGACY remaining as “therefore never 13.2”, and do not treat LEGACY remaining as “therefore 13.2 is only about deleting the old compiler.”

Parser may keep building `asCScriptNode` as recovery input. 13.2 is not “Parser stops allocating nodes.” 13.2 is “Sema environment is the authority; syntax walk is not.”

**Leave 13.2 / 13.3 / 4.2 / 5.9 `[ ]` after every slice this inventory describes.**
