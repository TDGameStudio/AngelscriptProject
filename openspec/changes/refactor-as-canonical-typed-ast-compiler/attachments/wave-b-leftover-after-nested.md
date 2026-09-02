# Wave B leftover intern after body attach + nested extract

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Read-only research. No UBT. No `Plugins/` edits. **13.2 stays `[ ]`.**

Supersedes the “must wait / queued nested extract” rows in `wave-b-leftover-after-postfix.md`. That file’s ctor / list-pattern / ++/-- / body-attach / nested-extract status is **stale**.

`B-frontend-codegen` **landed** (Frontend **82/82**, CanonicalAST **242/242**). `snParameterList` intern is the live exclusive UBT **B-param-identity** (`wave-b-param-identity-next.md`): three Param tests PASS, SemaAuthority **200/202**. This map’s param row is **in progress**, not leftover. **13.2 stays `[ ]`.**

## Landed intern of language meaning (do not list as leftover intern of the parent kind)

| Slice | Intern authority | Evidence |
| --- | --- | --- |
| Dedicated Call … postfix / sequence | dedicated `ActOn*` | SemaAuthority through **186/186** |
| ctor / dtor / mixin | `ActOnStartConstructorDecl` / Destructor / Mixin | `wave-b-ctor-sema` |
| `snListPattern` | `ActOnListPatternDecl` generated VAR + origin | Not InitList `{1,2}` |
| leftover Term `++`/`--` | `ActOnUnaryExpr(..., postfix)` → `opPreInc`/`opPostInc` | `wave-b-inc-sema` |
| function / method / lambda **body attach** | `AttachParsedFunctionBody`: FindExisting BLOCK or `InternParsedCompoundStmt`, then `SetBody`. `ActOnReturnStmt` does **not** `SetBody` | `wave-b-body-sema` **189/189** |
| nested If then/else, loop bodies, switch cases | `InternParsedChildStmt` FindExisting + dedicated `ActOn*Stmt`. ParseCase incremental ActOn. Switch does **not** `ClearStmtChildren` | `wave-b-nested-sema4` **194/194** |

Child extraction may still read `asCScriptNode`. That is leftover **extract**, not leftover intern of If / Compound / Function.

## Remaining leftover that still carries language meaning

| Row | Current path | Dedicated ActOn already? | Next peel? | Blocks 13.2? |
| --- | --- | --- | --- | --- |
| `snParameterList` | `WalkParameterList` → `WalkParameterSequence` → `ActOnQualTypeFromNode` + `ActOnParamDecl` | Builder `ActOnParamDecl` exists. **Missing intern:** Parser-dispatched `ActOnStartParamDecl` | Weak 4.4. After Frontend GREEN | Partial (signatures) |
| enumerator `snIdentifier` under enum | WalkOne `ActOnVarDecl` | Enum parent intern dedicated | Weak. After Frontend GREEN | No as standalone kind |
| leftover `ActOnParsedExpr` whole-node FromNode | `as_sema_decl.cpp` Call/VarAccess/`snExprTerm` arms still FromNode extract then dedicated `ActOn*` | Parent intern dedicated | Small peel after inventory names one kind | Partial (lookup/overload still inside FromNode extract) |
| local-init in `InternParsedCompoundStmt` | still `ActOnExprFromNode` for init children; `EmitLocalDeclStmts` inlined instead of `ActOnLocalDeclStmt` | LocalDecl intern dedicated. Keep **flat** sibling `STMT_EXPR` | Do **not** nest inits. F4 trap | Partial |
| `ActOnParsedStmt` `default` | `ActOnStmtFromNode` (`as_sema_decl.cpp:1963`) | Known kinds listed above | Recovery for unknown / try-catch-rejected | No (rejected/unknown) |
| Capture plan | **Sema-owned** `ActOnLambdaCapture` / `decl->captures`. CodeGen reads the sealed list | `ActOnLambdaCapture` | Landed this slice. Not 13.2 close | Partial (one 13.2 hole). LEGACY still `asCCompiler` |
| QualType FromNode extract | `ActOnQualTypeFromNode` then `ActOnQualType` | QualType intern dedicated | Keep as recovery extract | Partial (canonical types input) |

`snArgList` / named args / pre-op / post-op / scope / `snExprValue` / `snUndefined` / script `funcdef` / `@` / `is` / try-catch stay **recovery or rejected**. Do not intern as language.

## What this map is not

- Not 13.2 close. A Sema environment (scopes, symbols, overload candidates, conversions, call plans, lifetimes, control targets) is still missing. LEGACY still `asCCompiler`.
- Not 13.2 close. Frontend Generate two fails **landed**; leftover param/enumerator intern is still extract, not a Sema environment.
- Not F1 remainder / F6 / Wave E–G.

## Suggested intern order after Frontend GREEN

1. `B-frontend-codegen` released `as_bytecode_codegen.cpp`. One UBT user still.
2. Optional small intern: `WalkParameterList` → Parser incremental param ActOn + FindExisting (weak).
3. Optional smaller: enumerator WalkOne FindExisting only (already `ActOnVarDecl`).
4. Do **not** treat leftover expr FromNode wrappers as 13.2. Peel one kind if a dump still intern-creates inside FromNode.
5. Capture plan is Sema-owned (`decl->captures`). Remaining 13.2 is still the Sema environment (scopes, overload, conversions, full call/lifetime plans) plus LEGACY `asCCompiler`. Do not invent script `funcdef`.
