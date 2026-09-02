# Wave B leftover intern after F5 / 1070 (after OpaqueValue)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **This is not 4.2 close.** Do not check 4.2 / 13.2 / 5.4 / 5.6 / 9.5.

Live 梳理: `attachments/async-work.md` §3 “Where 4.2 actually is”. Exclusive UBT now is **B-54-opaque** (`wave-b-54-opaque-next.md`). This map is leftover intern **after** that bite. Do **not** mix OpaqueValue. Do **not** globally full-span `FindExistingExpr`.

Live file:line is this worktree (2026-08-22). LLVM/Clang is a shape reference only.

**Headline:** `ActOnParsedExpr` `default` is recovery-only. **Dump intern-creates in that default today: no.** After OpaqueValue there is **no leftover intern UBT**. Recovery stays recovery. The next Wave B leftover is **not** FromNode.

---

## 1. Dump intern-creates in `ActOnParsedExpr` default today? **No**

`ActOnParsedExpr` default (`as_sema_decl.cpp:1936-1938`) is:

```text
default:
    ActOnExprFromNode(node, script, parsedFile, owner);
    return;
```

`ActOnExprFromNode` default (`as_sema_expr.cpp:1923-1928`) only recurses `firstChild` (wrapper recovery). It does not intern a new parent kind.

Parser `ActOnParsedExpr` roots are **only listed kinds**. None of these sites send an unlisted `nodeType`:

| Parser site | Node created | `ActOnParsedExpr` file:line |
| --- | --- | --- |
| `ParseCast` | `snCast` `as_parser.cpp:1504` | `:1551`, `:1563`, `:1571` |
| `ParseFunctionCall` | `snFunctionCall` `:1844` | `:1864` (`notifySema`; member postfix uses `false`) |
| `ParseVariableAccess` | `snVariableAccess` `:1873` | `:1883` |
| `ParseConstructCall` | `snConstructCall` `:1892` | `:1901` |
| `ParseAssignment` | `snAssignment` `:2060` | `:2080` (RHS error), `:2086` (success) |
| `ParseCondition` | `snCondition` `:2096` | `:2115`, `:2127`, `:2137`, `:2143` (only when `?`) |
| `ParseExpression` | `snExpression` `:2164` | `:2188` (has `snExprOperator`), `:2204` (RHS error) |
| `ParseExprTerm` | `snExprTerm` `:2215` | `:2236` (typed init-list), `:2248` (anonymous `{...}`), `:2276` (pre-op error), `:2300` (pre/post-op), `:2313` (post-op error) |

Matching dedicated arms in `ActOnParsedExpr` (`as_sema_decl.cpp:1771-1935`): `snFunctionCall` → `InternParsedCall`; `snCast`; `snConstructCall`; `snAssignment`; `snExpression`; `snVariableAccess` → `InternParsedDeclRef`; `snInitList`; `snExprTerm` → `InternParsedExprTerm`; `snConstant`; `snCondition`.

Parser **never** calls `ActOnParsedExpr` as the root for: `snExprValue`, `snArgList`, `snNamedArgument`, `snFunction` (lambda), `snConstant`, `snInitList`, `snExprPreOp`, `snExprPostOp`, `snExprOperator`, `snScope`, `snDataType`, `snIdentifier`.

- Lambda: `ParseLambda` `CreateNode(snFunction)` `as_parser.cpp:1735` then `NotifySema` `:1810` → `ActOnParsedDeclaration` → `WalkOne`, **not** `ActOnParsedExpr`.
- `ParseExprValue` (`:1578`) never `ActOnParsedExpr`s the wrapper.
- `ParseArgList` (`:1908`) never `ActOnParsedExpr`s.
- `ParseConstant` (`:1679`) never `ActOnParsedExpr`s; constants intern via parent extract.
- Tests do not call `ActOnParsedExpr` (only assert interned CALL in `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`).
- `ParseScript` fallback `ActOnParsedScript` when `semaDeclActions == 0` (`as_parser.cpp:2542-2544`) walks **declarations**, not expr default.

`snInitList` / `snConstant` arms exist in `ActOnParsedExpr` but Parser does not use them as roots. Init-list intern is `ParseExprTerm` → `snExprTerm` → `InternParsedExprTerm` → child `ActOnExprFromNode` `snInitList` (`as_sema_expr.cpp:1914-1921`). That is listed extract, **not** default.

**Therefore: no dump intern-creates inside `ActOnParsedExpr` `default` today.** Keep the arm as recovery for unknown / rejected. Do **not** intern `try`/`catch` / script `funcdef` / `@` / `is` as language.

---

## 2. Leftover intern-creates vs recovery-only

Child extraction may still read `asCScriptNode`. That is leftover **extract**, not leftover intern of the parent kind. Parser still `CreateNode`s `asCScriptNode` as **recovery input** (`as_parser.cpp:175-178`; ParseFunction comment `:3682-3684`). Allowed.

### Landed intern of language meaning (do not list as leftover intern of the parent)

| Slice | Intern authority | Live evidence |
| --- | --- | --- |
| Dedicated Call / Cast / Construct / Assign / Binary / Logical / If / While / For / Switch / DoWhile / Foreach / Lambda / Member / Index / Unary / QualType / DeclRef / LocalDecl / InitList / Break / Continue / Fallthrough / Conditional / literals / ExprStmt / Case / Compound / Namespace / Class / Enum / Interface / Typedef / Import / Function / Method / Var / PostfixCall / Sequence / Constructor / Destructor / Mixin / ListPattern / Term `++`/`--` | dedicated `ActOn*` | SemaAuthority **236/236** F5 + 1070 |
| function / method / lambda **body attach** | `AttachParsedFunctionBody` `as_sema_decl.cpp:1232-1236` | Not leftover intern of Function |
| nested If then/else, loop bodies, switch cases | `InternParsedChildStmt` `as_sema_stmt.cpp:536` | Not leftover intern of If/loops |
| Sema-owned captures | `asCDecl::captures` / `ActOnLambdaCapture` | CodeGen reads sealed list |
| Clang For/If named dump phases | observer `init=`/`then=`/`else=` | Not 5.6 |
| Param intern-after-name + F5 range identity | `ParseFunction` `NotifySema` after name `as_parser.cpp:3688` then `ActOnParsedParam` `:878` → `ActOnStartParamDecl` same owner + same range `as_sema.cpp:395-432` | F5 **236/236**. Not 4.2 close |
| Enumerator intern + F5 range identity | `ActOnParsedEnumerator` `as_parser.cpp:2999` → `ActOnStartEnumeratorDecl` `as_sema.cpp:435-470` | F5. Not 4.2 close |
| DeclRef peel + 1070 intern-order bind | `InternParsedDeclRef` `as_sema_expr.cpp:1544`; skip reuse of invalid `resolvedDecl` `:1551-1558` | 1070 `Build()==0`. Not leftover intern of DeclRef |
| Call peel + F2 full-span CALL reuse | `InternParsedCall` `:1578` + `FindExistingCallByFullRange` `:55` | F2. `FindExistingExpr` still kind+begin |
| Term peel | `InternParsedExprTerm` `:1641`. No whole-term CALL FindExisting `:1663-1665` | Not leftover intern of Term |
| 5.4 dump OpaqueValue / Sequence / Logical / Conditional named parts | dump plan landed | Generate memo / write-through is **B-54-opaque**, not leftover intern |
| 5.6 dump + verifier oracles | `safepoint=` + skipped-nearer / default-order / fallthrough-target | Not 5.6 close |
| B-56-body-owner BLOCK reuse | `InternParsedCompoundStmt` owner==fn `:603-614` | Not leftover intern |
| F1 member postfix delay | `ParseFunctionCall(false)` `as_parser.cpp:1862-1864` | Do not redo |
| F3 `QualTypeFromClassDecl` | class REF+handle / struct VALUE | Do not redo |
| F4 fail-closed intern + native instantiate | script same-arity deleted; `insertLast` | Do not redo |

### Table: leftover intern-creates vs recovery-only

| Row | Live path (file:line) | Intern-create or recovery-only? | Dump intern-creates in `ActOnParsedExpr` default? |
| --- | --- | --- | --- |
| `ActOnParsedExpr` `default` | `as_sema_decl.cpp:1936-1938` → `ActOnExprFromNode` | **Recovery-only.** Parser never sends an unlisted root | **No** |
| `ActOnExprFromNode` `default` | `as_sema_expr.cpp:1923-1928` recurse `firstChild` | **Recovery-only** wrapper | No (not the Parser ActOn default) |
| `ActOnParsedStmt` `default` | `as_sema_decl.cpp:2177-2178` → `ActOnStmtFromNode` | **Recovery-only.** Known stmts listed `:1976-2176` including `snForEach` `:2055` | No |
| `ActOnStmtFromNode` `default` | `as_sema_stmt.cpp:938-952` `try-catch-rejected` or recurse `firstChild` | **Recovery-only** / rejected. Do not intern `try`/`catch` | No |
| QualType FromNode | `ActOnQualTypeFromNode` `as_sema_decl.cpp:372-387` (`CollectQuals` `:166` + `FormatTypeKey` `:232`) → `ActOnQualType` `:287` (Engine bridge `:333-360` then named VALUE/REF). Callers: Param `:565`/`:611`; `FindExistingFunctionLike` `:1107`; Cast/Construct `as_sema_decl.cpp:1792`/`:1802`; LocalDecl `:2101`; WalkOne Var `:1452`; import `:1407`; lambda `:1254`; `ActOnFunctionLike` `:845` | **Recovery extract.** Dedicated intern is `ActOnQualType`. Still intern-creates a QualType from node spelling. **Not** a parent-kind FromNode peel | No |
| `WalkParameterList` fill-extract | `WalkParameterSequence` `as_sema_decl.cpp:527`; `WalkParameterList` `:583`. Lambda: `ParseLambda` never `ActOnParsedParam`; `ActOnLambdaFromNode` `:1264`. Import: WalkOne when `CountDeclParams==0` `:1409-1411`. Intern-create function: `ActOnFunctionLike` `:895`. Rejected `snFuncDef` `:1364`. Ordinary functions use `ActOnParsedParam` `as_parser.cpp:878` | **Leftover extract** of Param (intern-creates via `ActOnStartParamDecl` when Parser did not). **Not** leftover intern of Param as a language kind. F5 identity already landed | No |
| local-init children still `ActOnExprFromNode` | `InternParsedCompoundStmt` `as_sema_stmt.cpp:645-670` (ArgList/ConstructCall → `ActOnConstruct` `:666`; else FromNode `:670`); `ActOnParsedStmt` `snDeclaration` `as_sema_decl.cpp:2101-2107`; `ActOnStmtFromNode` `:749-755`. Keep flat sibling `STMT_EXPR` (`EmitLocalDeclStmts`) | **Leftover extract** of init. LocalDecl intern dedicated. Do **not** nest inits (F4 trap: intern ASSIGN/DECL_REF at the **declaration** range) | No |
| WalkOne named-decl fill | `ActOnParsedDeclaration` → `WalkOne` `as_sema_decl.cpp:1702-1736`. Parser `NotifySema` `as_parser.cpp:132-138` is still that walk | **Leftover extract** of the syntax walk (4.2). Intern of Class/Function/… is dedicated `ActOnStart*`. Builder remains production decl authority | No |
| WalkOne global/member init | WalkOne `snDeclaration` `as_sema_decl.cpp:1444`: global `ActOnExprFromNode` `:1487` + `ActOnGlobalVarInit`; member `IntegerInitText` + `SetDefaultArg` `:1492`. Mutable non-const primitive global diagnostic `mutable-global-rejected` `:1462` | **Leftover extract** of init, not intern of Var. Do **not** intern mutable globals as language | No |
| default-arg text | `ActOnParsedParam` `as_sema_decl.cpp:614-617` `CanonicalNodeText` + `SetDefaultArg`; same in `WalkParameterSequence` `:568-571`. Parser `SuperficiallyParseExpression` `as_parser.cpp:869` | **Leftover extract** of default-arg **text**. Not intern of an owned default-arg expr. Not 5.3 close | No |
| Child extract still `ActOnExprFromNode` | Term pre-op inner `as_sema_expr.cpp:1673`; index `:1714`; postfix args `:1725`; non-op `:1746`. Call args `:1630` (named `snNamedArgument` `:1622`). Cast/Construct/Assign/Expression/Condition/InitList children. Control cond/incr/return value `ActOnParsedStmt` `:1982-2113` | **Leftover extract** of children of **already-dedicated** parents. Not a next exclusive intern UBT | No |
| `ActOnLambdaFromNode` still FromNode extract | `as_sema_decl.cpp:1240` → `ActOnLambdaExpr` `:1259` + `WalkParameterList` `:1264` + `AttachParsedFunctionBody` `:1272`. WalkOne `:1425`. `ActOnExprFromNode` `snFunction` `as_sema_expr.cpp:1912`. `ActOnStmtFromNode` `snFunction` `as_sema_stmt.cpp:759` | **Leftover extract** of lambda params/body. Not leftover intern of Lambda | No |
| `WalkReturnConstants` | `as_sema_decl.cpp:454` from WalkOne `snReturn` `:1441` | **Leftover extract** of integer Return during WalkOne. `ActOnReturnStmt` dedicated | No |
| WalkOne `default` | `as_sema_decl.cpp:1543-1545` `WalkDecls` `firstChild`. `snVirtualProperty` / `snAccessDeclaration` / `snClassDefaultStatement` / `snMixin` have **no** WalkOne arm | **Recovery.** Do not intern those as language kinds | No |
| `snArgList` / named args / pre-op / post-op / scope / `snExprValue` / `snUndefined` | Parser recovery tree; FromNode default firstChild | **Recovery.** Do not intern as language | No |
| script `funcdef` / `@` / `is` / try-catch / dictionary / mutable globals as language / C labeled break | WalkOne `snFuncDef` still `ActOnFuncDefDecl` `:1359-1365` (keep rejected); `ttIs`/`ttNotIs` still spelled in `ActOnExprFromNode` `snExpression` `as_sema_expr.cpp:1856-1862`; `@` in `ParseExprPreOp` BNF `as_parser.cpp:2321` | **Rejected.** Do **not** intern as language. Handle `@` in QualType keys (`as_sema.cpp:208`) is a type qualifier spelling, not script `@` as an expression | No |

`FindExistingExpr` is still kind + `begin.offset`, skip offset 0 (`as_sema_expr.cpp:35-52`). F2 only specialized CALL via `FindExistingCallByFullRange` (`:55`). Sequence steal of postfix `literal=seq` when creating `literal=opaque` is **B-54-opaque**, not leftover intern. Do **not** globally full-span `FindExistingExpr`.

Materialize/Cleanup wrapping inside `ActOnCallExpr` / `ActOnConstruct` is leftover **lifetime intern** (5.7/5.8), not a FromNode peel. Do not start it as leftover intern after OpaqueValue.

---

## 3. Next exclusive leftover intern bite after OpaqueValue

**None.**

Dump intern-creates in `ActOnParsedExpr` `default` today: **no** (section 1). Remaining FromNode / WalkOne rows are **recovery or extract**, not a parent-kind intern peel.

- Recovery stays recovery.
- The next Wave B leftover is **not** FromNode.
- Do **not** peel QualType FromNode, `WalkParameterList`, local-init, WalkOne named decls, or child `ActOnExprFromNode` as the next intern UBT.
- Do **not** nest local-init. Keep sibling `STMT_EXPR`.
- `WalkParameterList` may stay as lambda/import fill extract. Do not re-intern Param. Do not intern script `funcdef`.
- Default-arg stays text extract until a later 5.3 call-plan slice.
- Remaining 4.2 work is **Parser action-only + Builder no longer production decl authority**, not a FromNode intern bite. That is a later package and is **not** 4.2 close from this map.
- Isolated Logical/Conditional/`struct FValue` traces are Generate/Trace, not leftover intern (`wave-b-54-traces-already-green.md`).

---

## 4. Why 4.2 is still open

4.2 text (`tasks.md`): Parser dedicated Sema actions for translation unit, namespace, typedef, enum, funcdef, interface, class, function, method, constructor/destructor, variable, property, import, and parameter declarations. Initially shadow current `asCBuilder` registration and compare results.

Live (`async-work.md` §3): Parser dedicated Sema actions for the language's declarations, initially shadowing Builder. Builder remains production declaration authority until backends stop rerunning Sema.

**Do not check 4.2.** F5 is range-identity. 1070 is DeclRef intern-order. Dedicated intern of named kinds is **not** action-only Parser and **not** Builder retirement.

Evidence Builder is still production decl authority:

- Default pipeline LEGACY: `ep.canonicalCompilerPipeline = false` (`as_scriptengine.cpp:787`).
- `asCBuilder::BuildCompileCode` still constructs `asCCompiler` (`as_builder.cpp:928`) for factories; `CompileFunctions()` `:939` is the production function compile path.
- Canonical Sema attaches only when snapshot retention or CANONICAL pipeline (`AttachCanonicalSemaIfNeeded` `as_builder.cpp:653-657`). Opt-in, not production default.

Evidence Parser is not action-only for the language:

- Parser still `CreateNode`s a complete `asCScriptNode` recovery tree (`as_parser.cpp:175` and every `Parse*`).
- Incremental decl entry is `NotifySema` → `ActOnParsedDeclaration` → `WalkOne` (`as_parser.cpp:132-138`, `as_sema_decl.cpp:1702-1736`). Clang-shaped `ActOnStart*` exist, but the Parser does not call them without the syntax node.
- `ParseFunction` still builds the function node, `NotifySema`s after the name, then parses params into that node (`as_parser.cpp:3679-3692`). Comment: “`asCScriptNode` stays recovery.”
- Lambda/import/funcdef still fill-extract through `WalkParameterList` of that recovery tree.
- LEGACY Bytecode still reruns `asCCompiler` (default pipeline still reruns Sema).

4.2 stays `[ ]` until **both**: Parser is action-only for the language **and** Builder is not production decl authority.

---

## 5. TDD for the next leftover intern bite

**No leftover intern UBT until a dump intern-creates in `ActOnParsedExpr` `default`.**

Do not invent a FromNode peel. Do not UBT QualType / WalkParameterList / local-init / WalkOne as intern.

If a **future** dump intern-creates in that default (Parser `ActOnParsedExpr` with a `nodeType` not listed in `as_sema_decl.cpp:1771-1935`), the leftover intern UBT is **only** that kind:

1. **RED:** add a SemaAuthority dump lock on the compile→seal path for that Parser-root kind. Assert the dedicated `ActOn*` fact (`kind=` / `callee=` / `type=`) and that intern does **not** go through `ActOnParsedExpr` `default` → `ActOnExprFromNode` whole-node. Expected RED: dump missing or intern still created in default.
2. **GREEN:** list the kind in `ActOnParsedExpr` (extract-then-dedicated `ActOn*`). Leave `default` as firstChild/unknown recovery. Do **not** globally full-span `FindExistingExpr`. Do **not** mix OpaqueValue. Do **not** nest local-init. Do **not** intern rejected dialect.
3. Prefix: SemaAuthority + CanonicalAST green. **Did not check 4.2 / 13.2 / 5.4 / 9.5.** Did not flip default CANONICAL.

Today that RED does not exist. Do not start the UBT.

---

## 6. Hard nos

- Do **not** globally change `FindExistingExpr` to full-span match. CALL already has `FindExistingCallByFullRange`. OpaqueValue Sequence steal (if dump shows postfix `literal=seq` retagged `opaque`) is **B-54-opaque** only: do not FindExisting `literal=seq` when creating `literal=opaque`.
- Do **not** mix OpaqueValue memo / Index write-through / mutation traces into leftover intern.
- Do **not** check 4.2 / 13.2 (or 5.4 / 5.6 / 9.5) from this map, F5 GREEN, 1070 GREEN, or OpaqueValue GREEN.
- Do **not** intern script `funcdef` / `@` / `is` / try-catch / dictionary / mutable globals as language / C labeled break.
- Do **not** nest local-init. Keep sibling `STMT_EXPR`. For-init LocalDecl: prefer wrapping BLOCK over inner DECL (`stmt-multi-owner`).
- Do **not** `NotifySema` nested statements (`ActOnParsedDeclaration` → `WalkOne` leftover steal). Incremental stmt intern is `ActOnParsedStmt`.
- Do **not** start Wave E–G. Do not flip `canonicalCompilerPipeline`. Do not CANONICAL `CompileFunction`.

---

## What this map is not

- **Not 4.2 close.** Parser is not action-only. Builder is still production decl authority.
- **Not 13.2 close.** Dedicated leftover intern peels and dump tokens are not a Sema environment. LEGACY still `asCCompiler`.
- **Not 5.4 close.** OpaqueValue Generate is a separate exclusive UBT. This map assumes that bite; it does not implement it.
- **Not 5.3 / 5.6 / 5.7 / 5.8 / 5.9 / 9.5 close.**
- Not a second peel of Call / DeclRef / Term / Param / Enumerator / 1070 intern-order.
- Not F1 remainder ABI / F6 / Wave E–G.
