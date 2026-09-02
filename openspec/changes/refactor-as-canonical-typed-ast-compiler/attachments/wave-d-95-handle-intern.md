# Wave D-95 — isolated vs production intern of host REF handle

Read-only intern comparison for exclusive UBT package **D-95-handle**. Goal: tell **intern-hole vs emit-hole** before touching emitters. Do not treat this note as GREEN.

Worktree: `D:\as-cta`. Live line numbers quoted below have drifted vs `reviews/implementation-rereview-2026-08-22-fifth-pass.md`.

## 1. Measured facts (quoted; not re-run)

Isolated **GREEN**: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp` method `CodeGenEmitsHandleParameterNullCheck`. Helper `GenerateCanonicalFromSource` does `Parser.ParseScript` → `Context.Seal()` (**not** `asCBuilder::SealCanonicalAST`) → `CodeGen.Generate`. Script: `bool IsNull(CObj Obj) { return Obj == nullptr; }`. Host: `RegisterObjectType("CObj", 0, asOBJ_REF)` + empty ADDREF/RELEASE.

Production **RED**: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` method `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes`. Uses `CompileNativeModule` → `asCModule::Build()` on that run. Script: `int F() { CObj Obj = null; if (Obj == nullptr) return 42; return 0; }`. Same host `CObj`. `Build()==0` but `CollectFunctionDeclarations` = `{<no functions>}`.

Log: `D:\as-cta\Saved\Tests\d95-handle\20260822_022814_275_a001cdc2`.

Quoted log text:

```
CANONICAL handle module must publish int F(); have {<no functions>}
[D:\as-cta\Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\Compiler\CanonicalAST\AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp(491)]
```

`Summary.json` on that run: `Total=1`, `Passed=0`, `Failed=1`, `ExitCode=255`. No `Canonical CodeGen failed` / `Canonical Seal failed` / `Canonical Sema diagnostic` in that log (searched the saved directory).

That assert line **491** is the measured snapshot. Live test file has since grown a retain+dump around the same method (see §3); the saved log does **not** include `scriptFunctions` / `asCASTDump`. Do not invent those fields from the 022814 run.

Dialect (must not ignore): `as_tokendef.h` maps token string `"nullptr"` to `ttNull`. There is no `"null"` token. Sema `as_sema_expr.cpp` creates `asAST_EXPR_NULL_LITERAL` only when `node->tokenType == ttNull`.

## 2. Isolated GREEN intern path (live)

`GenerateCanonicalFromSource` (`AngelscriptNativeCanonicalASTCodeGenTests.cpp` **22–74**):

1. Throwaway `asCBuilder Builder(ScriptEngine, Module); Builder.silent = true;` — **not** `module->builder`.
2. `asCScriptCode::SetCode` + local `asCASTContext Context` + local `asCSema Sema(ScriptEngine, Context)`.
3. `Parser.SetSema(&Sema)` then `Parser.ParseScript(&Code)` (**37**).
4. `Context.Seal()` only (**47**). Fail dumps `canonical seal failed` + AST. **Does not** call `SealCanonicalAST`, so Sema `diagnostics` are **not** fail-closed here.
5. `asCBytecodeCodeGen::Generate(Context, Module)` (**62–63**). Fail dumps `canonical Generate failed`.
6. **Does not** call `asCModule::Build()`, **does not** `InternalReset` the production way, **does not** `PublishCanonicalASTSnapshot`.

`CodeGenEmitsHandleParameterNullCheck` (**728–771**):

- Registers host `CObj` REF + empty generic ADDREF/RELEASE (**735–739**).
- `CreateBuilderModule` = `GetModule(..., asGM_ALWAYS_CREATE)` only (`AngelscriptNativeBuilderTestSupport.h` **20–25**). No `AddScriptSection` / `Build()`.
- Source **exactly** `"bool IsNull(CObj Obj) { return Obj == nullptr; }"` (**747**) — dialect-honest `nullptr` (`ttNull`). `CObj` is a **parameter**, not a local initializer.
- Function lookup is **not** `GetNativeFunctionByDecl`. It tries `bool IsNull(CObj@+)`, then `CObj@`, then `CObj`, then **`GetFunctionByIndex(0)` if `GetFunctionCount() > 0`** (**750–762**). Isolated GREEN proves **some** global was committed; it does **not** prove the public decl string. Production must not copy this fallback.

## 3. Production RED intern path (live)

`CompileNativeModule` (`AngelscriptNativeCoreTestSupport.h` **399–420**) is `GetModule(asGM_ALWAYS_CREATE)` + `AddScriptSection` + `Module->Build()`. The measured 022814 run used that helper. Live method `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes` (**458–545**) now inlines the same `Build()` and already calls `SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)` (**474–475**) plus `scriptFunctions` / `asCASTDump` on the `{<no functions>}` assert (**494–531**). That dump was **not** on the measured log (assert was still at **491** with only `CollectFunctionDeclarations`).

CANONICAL `asCModule::Build()` (`as_module.cpp` **356–440**):

1. `InternalReset()` (**388**) — clears `globalFunctions` / `globalFunctionList` / publisher (**783–793**). Happens **before** parse, not after a successful Generate.
2. `builder->BuildParallelParseScripts()` (**396**): `Reset()` then `AttachCanonicalSemaIfNeeded()` then per section `parser->SetSema(canonicalSema)` then `ParseScript` (`as_builder.cpp` **716–745**).
3. `AttachCanonicalSemaIfNeeded` (**653–682**) allocates `canonicalAST` + `canonicalSema` and **`ActOnTranslationUnit(module name)`** before parse. Isolated helper never calls this.
4. `SealCanonicalAST()` (**401**, impl **685–713**): if `canonicalSema->GetDiagnostics().GetLength() > 0` → printf `Canonical Sema diagnostic:` and `return asINVALID_DECLARATION` (fail-closed). Else `canonicalAST->Seal()`. Isolated uses `Context.Seal()` without the diagnostic gate.
5. `TakeCanonicalAST()` (**407**, impl **457–467**) deletes Sema, returns the context pointer.
6. `asCBytecodeCodeGen::Generate(*pending, this)` (**414–415**). Fail prints `Canonical CodeGen failed code=%d line=%d` (**418–421**) and `InternalReset()` (**429**). Measured run had **neither** print, so this Generate returned **≥ 0**.
7. `AdoptPendingCanonicalAST` then `PublishCanonicalASTSnapshot()` (**424–437**). Default module policy is `asAST_DISCARD_AFTER_CODEGEN` (`as_module.cpp` **71**). Unless `asAST_RETAIN_SNAPSHOT`, `PublishCanonicalASTSnapshot` **deletes** the AST (**2117–2131**). Retention does **not** install globals; it only keeps the graph for dump.

Production script (live **477–485**, same as measured):

```angelscript
int F()
{
    CObj Obj = null;
    if (Obj == nullptr)
    {
        return 42;
    }
    return 0;
}
```

Host registration matches isolated (**466–469**). `CObj` is a **local**. Initializer is identifier `null`, not `ttNull`. Compare uses `nullptr`.

Working production cousins on the same prefix (integer `F()`, named VALUE local, `&in`/`&out`, while-SUSPEND) prove CANONICAL `Build()` **can** intern `int F()` and Commit it as a global. The hole is unique to this host-REF local script, not to the routing itself.

## 4. Dialect: `nullptr` vs `null`

`as_tokendef.h` **171** comments `ttNull` as `// null`. The **token string** is only:

```
asTokenDef("nullptr"   , ttNull),   // line 291
```

There is no `asTokenDef("null", ...)`. `"null"` lexes as `ttIdentifier`.

`as_sema_expr.cpp` **769–771**: `snConstant` + `tokenType == ttNull` → `asAST_EXPR_NULL_LITERAL`. Identifier `null` takes `snVariableAccess` (**780–822**): `FindNamedDecl(..., "null")`, then `ActOnDeclRef(target, type)`. Missing symbol does **not** `AddDiagnostic`. Type defaults to interned `int` when the target decl has no type (**809**). `ActOnDeclRef` of an invalid id still creates `EXPR_DECL_REF` (`as_sema.cpp` **412–420**).

Emit of that node is **not** silent: `EmitDeclRef` (`as_bytecode_codegen.cpp` **782–788**) `FailAt(..., asAST_VERIFY_DANGLING_ID)` when `GetDecl(resolvedDecl)` is null. A collected `F` whose body contains unresolved `null` would print `Canonical CodeGen failed` and `Build() < 0`. Measured run did **not**. So H3 can explain `{<no functions>}` **only if** `null` also prevented collect (H1) or F was committed as a method (H2) **without** emitting that dangling ref — not as a successful global emit of a poisoned body.

Isolated cousin never writes `null`; it only compares `== nullptr`.

## 5. Collect / Commit (live; drifted vs fifth-pass)

Fifth-pass F1 said: empty `functionDecls` early-returns **before** globals; `Commit` **unconditionally** pushes every function onto `globalFunctions`. **Live code is different.**

`CanonicalDeclIsFunctionLike` (**30–36**): `FUNCTION` | `METHOD` | `CONSTRUCTOR` | `DESTRUCTOR`.

`Generate` collect (**2054–2068**) walks **all** decls by id `1..GetDeclCount()`:

- include if `body.IsValid()`, **or** `kind == asAST_DECL_FUNCTION` (even without body), **or** constructor, **or** non-generated destructor.
- **METHOD without body is skipped.**

Empty `functionDecls` no longer returns before the rest of Generate. `GetDeclCount()==0` **does** fail (`asAST_VERIFY_DANGLING_ID`, **2027–2031**). A TU-only graph (`GetDeclCount()>=1`, no function-like rows) still reaches `artifact.Commit` and returns `asAST_VERIFY_OK` (**2155–2163**). That is the live F1 empty-install: **Build==0, publisher CANONICAL_CODEGEN, no globals.**

`Commit` (**1990–2012**):

```
module->scriptFunctions.PushLast(func);
if( func->objectType == 0 )
{
    module->globalFunctions.Add(func);
    module->globalFunctionList.PushLast(func);
}
```

`objectType` is set only for `METHOD` / `CONSTRUCTOR` / `DESTRUCTOR` whose parent is `DECL_CLASS` (`FillFunctionSignature` **1914–1946**). `DECL_FUNCTION` stays `objectType == 0`.

`CollectFunctionDeclarations` (`AngelscriptNativeCoreTestSupport.h` **120–145**) walks **only** `Module->GetFunctionCount()` → `GetFunctionByIndex` → `globalFunctionList` (`as_module.cpp` **503–508**, **1033–1036**). It never sees `scriptFunctions` methods.

`GetNativeFunctionByDecl` (**760–803**) is exact-decl only. Comment forbids name / sole-function fallback. Production RED is this lookup plus empty `CollectFunctionDeclarations`. Isolated GREEN used `GetFunctionByIndex(0)`.

Parser intern of a global function: `ParseFunction` default `notifySemaAfterParams = true` (`as_parser.h` **140**). After params, **before body**, `NotifySema` (`as_parser.cpp` **3679–3685**). `WalkOne` `snFunction` (`as_sema_decl.cpp` **1134–1148**) `ActOnFunctionLike` → `ActOnFunctionDecl` (`as_sema.cpp` **262–268**, kind `asAST_DECL_FUNCTION`) then `SetBody` if a statement block exists. Body syntax errors are documented as not dropping the declaration (`as_parser.cpp` **3679–3680**).

Therefore: if parse reached `int F()`, a sealed dump **should** show `DECL kind=Function name=F` even when the body is poisoned — unless intern never ran, parent was CLASS (method), or the decl was never in the context Generate saw.

Host `CObj` intern: `ActOnQualTypeFromNode` (`as_sema_decl.cpp` **337–365**) `engine->GetTypeInfoByName("CObj")` then `asCRuntimeTypeBridge::FromDataType`. REF flags → `asAST_TYPE_REFERENCE_OBJECT` (`as_runtime_type_bridge.cpp` **154–176**). That creates a **type**, not a `DECL_CLASS`, and does not `PushDeclContext`. Isolated parameter `CObj` uses the same helper.

`RegisterCanonicalScriptTypes` (**1790–1867**) still forces every **script** `DECL_CLASS` to `asOBJ_VALUE | asOBJ_SCRIPT_OBJECT | asOBJ_NOINHERIT`. It does not re-register host `CObj`. Dummy-constructing the REF local as VALUE would be a lie.

## 6. Every difference that can yield `Build==0` + empty globals

| # | Difference | Isolated | Production | Can it yield the measured symptom? |
| --- | --- | --- | --- | --- |
| 1 | Entry | local `GenerateCanonicalFromSource` | `AddScriptSection` + `Build()` | Production-only collect/Commit/F1. |
| 2 | Sema attach | local `asCSema` on local `Context`; **no** `ActOnTranslationUnit` up front (`ActOnParsedDeclaration` creates TU on demand, `as_sema_decl.cpp` **1326–1330**) | `AttachCanonicalSemaIfNeeded` + `ActOnTranslationUnit` before parse | Missing TU would fail `GetDeclCount()==0`. Measured Generate succeeded ⇒ at least TU exists. |
| 3 | Seal gate | `Context.Seal()` only | `SealCanonicalAST` fail-closes on Sema diagnostics | Diagnostics would print and `Build()<0`. **Not** this run. Isolated/production gate is **not** the measured hole. |
| 4 | `InternalReset` | never in this helper | start of `Build()`; again only if Generate/Seal fail | Start-of-build reset cannot wipe a later Commit. Fail-path reset would make `Build()<0`. |
| 5 | Snapshot policy | no publish | default **deletes** AST unless `asAST_RETAIN_SNAPSHOT` | Does **not** empty `globalFunctionList`. Explains missing AST on the 022814 log, not empty globals. |
| 6 | Collect empty / F1 | isolated GREEN published **a** global | TU-only or METHOD-without-body ⇒ Commit of nothing, return OK | **Yes (H1 / H4-METHOD-skip).** Matches `Build==0` + no CodeGen print. |
| 7 | `Commit` `objectType != 0` | isolated IsNull was a global (`GetFunctionCount()>0`) | methods skipped from `globalFunctionList` | **Yes (H2).** `scriptFunctions` would still list `F`. Measured log did not dump that array. |
| 8 | `CollectFunctionDeclarations` vs `scriptFunctions` | isolated used index 0 | production globals-only | Empty globals with methods in `scriptFunctions` looks identical to H1 on the 022814 assert. |
| 9 | Script shape | param `CObj Obj`, compare `nullptr` | local `CObj Obj = null` **and** `== nullptr` | **Yes (H3).** `null` is identifier. If F were collected, emit of unresolved `DeclRef` should **fail** Generate — not observed. H3 therefore needs H1 (no collect) or H2 (method, body not emitted that way). |
| 10 | Param vs local | handle param + `CmpPtrNull` emit exists (`as_bytecode_codegen.cpp` **1176–1182**) | local decl + assign (`as_sema_stmt.cpp` **316–355**) | Emit-hole for locals would `Canonical CodeGen failed`. Measured did not. Prefers intern/collect over CmpPtrNull emit. |
| 11 | Function lookup | `@+` / `@` / index 0 | exact `int F()` only | Isolated GREEN is not permission to `GetFunctionByName("F")`. Does not create empty globals. |
| 12 | Host type registrar | same `asOBJ_REF` + empty ADDREF/RELEASE | same | Not a registration mismatch. |
| 13 | Script `class` VALUE lie | N/A (host type) | `RegisterCanonicalScriptTypes` VALUE-only | Do not “fix” by treating `CObj` as VALUE. Not this fixture’s type. |
| 14 | First handle script (history) | N/A | earlier `IsNull(null) ? 42 : 0` Generate `code=-15 line=1387` (`asNO_MODULE`, CALL without callee) | **Not** this narrowed script. Measured has no CodeGen fail. Do not re-open CALL-without-callee. |

`Build==0` + no Seal/CodeGen print **rules out**: Generate fail, Seal fail, `GetDeclCount()==0`, Compiler fallback (CANONICAL does not call `BuildCompileCode`). It **leaves**: empty collect (H1), Commit skip (H2), or a dialect intern that never produced a collectable `DECL_FUNCTION` (H3→H1).

## 7. Ranked hypotheses

**H1 intern — sealed AST has no `DECL_FUNCTION` (highest rank for the measured pair).**  
Generate collect is a no-op; `Commit()` of nothing returns OK (live F1). Matches `Build==0`, `{<no functions>}`, no CodeGen/Seal print. Needs dump: no `DECL kind=Function name=F` (and no Method/Ctor). Tension: `ParseFunction` NotifySema-after-params should intern `F` before the body. If the dump shows Function anyway, **downgrade H1**.

**H3 dialect `null` identifier vs `nullptr` `ttNull` (highest-rank *script* difference; mechanism still intern).**  
Production initializer `CObj Obj = null` cannot become `EXPR_NULL_LITERAL`. Isolated never uses that token. Unresolved `DeclRef` would fail **emit** if `F` were collected — contradicting this run — so H3 is not a standalone emit-hole here. Honest one-variable experiment: initializer `CObj Obj = nullptr;` (keep `CmpPtrNull` / execute 42). If that alone publishes `int F()`, intern was poisoned by `null`. If still `{<no functions>}`, stop blaming the token.

**H2 owner — `F` emitted as method (`objectType != 0`).**  
`Commit` skips `globalFunctions`; `CollectFunctionDeclarations` stays empty; Generate still succeeds. Live `FillFunctionSignature` only sets `objectType` for METHOD/CTOR/DTOR under `DECL_CLASS`. First script decl `int F()` with TU parent should be `DECL_FUNCTION`. Host `CObj` intern does not push a class context. Rank **below** H1/H3 unless dump shows `kind=Method` or `scriptFunctions` `objectType=CObj`. Native ADDREF/RELEASE are **not** `scriptFunctions` rows.

**H4 other (named):**

1. **F1 METHOD-without-body skip** — `DECL kind=Method name=F` with invalid `body` is **not** collected (live **2062–2067**). Looks like H1 in globals; dump distinguishes Method vs missing.
2. **Isolated lookup fallback** — explains why isolated GREEN is weaker evidence, not why production globals are empty.
3. **Snapshot discard** — AST gone after default publish; globals unaffected.
4. **SealCanonicalAST vs `Context.Seal` diagnostics** — would `Build()<0`. Not this run.
5. **CALL-without-callee / `asNO_MODULE`** — previous handle script only. Forbidden as the next “fix”.
6. **VALUE dummy-construct of REF local** — would hide intern; must not do.

## 8. Dump fields that distinguish H1 / H2 / H3

Retain snapshot (`asAST_RETAIN_SNAPSHOT`) **before** `Build()` so `GetCanonicalASTContext()` survives publish. Live test already does this (**474–475**); the 022814 log did not. On the existing `{<no functions>}` assert, require:

From `asCASTDump` (`as_ast_dump.cpp` **78–137**, **179–300**):

| Field | H1 intern | H2 owner | H3 dialect `null` |
| --- | --- | --- | --- |
| `DECL ... kind=Function name=F` | **absent** | may be absent; look for `kind=Method name=F` | usually **present** (NotifySema-after-params) if parse reached `int F()` |
| `DECL ... kind=Method name=F parent=<class>` | absent | **present** | absent |
| `EXPR ... kind=NullLiteral` | optional | optional | **missing** for the initializer; compare `== nullptr` may still dump NullLiteral |
| `EXPR ... kind=DeclRef ... literal=null` (no valid callee / unresolved id) | may be absent if F never interned | possible | **present** if intern reached the assign |
| `DECL ... kind=Var name=Obj key/type=CObj` (handle quals) | absent if function missing | possible as member | present under `F` if local interned |

From module tables (live test already formats `scriptFunctions` **496–516**):

| Table | H1 | H2 | H3 (F collected) |
| --- | --- | --- | --- |
| `CollectFunctionDeclarations` / `GetFunctionCount()` | `<no functions>` | `<no functions>` | would be `int F()` if emit+Commit as global — **not** measured |
| `asCModule::scriptFunctions` | `<no scriptFunctions>` | `int F() objectType=CObj` (or other owner ≠ `<global>`) | `int F() objectType=<global>` **and** Generate should have failed on dangling `null` — contradiction ⇒ H3 cannot be “emit succeeded” |
| Host `CObj` method count | native ADDREF/RELEASE only | do not count these as `F` | same |

Generate printf **only** when `functionDecls.GetLength()==0`: list every decl id/kind/name/`body.IsValid()`. Empty list + dump without Function = **H1**. Method F without body = **H4-METHOD-skip**. Non-empty collect + `scriptFunctions` owner = **H2**. Function F + `DeclRef literal=null` + Generate fail = **H3 emit**, which is **not** the 022814 symptom.

Form **one** hypothesis from that dump, then one matching fix. Do not patch CmpPtrNull until the dump names an emit-hole.

## 9. Exclusive implementer must NOT

- **No CALL-without-callee** verifier requirement; no inventing a callee to make Generate return 0.
- **No Wave G.** Default `ep.canonicalCompilerPipeline` stays false (LEGACY). Do not make CANONICAL the engine default.
- **No 9.5 checkbox.** Even 12/12 ProductionCodeGen is a slice. Leave `tasks.md` 9.5 / 9.1 / 13.2 / 13.3 / 13.6 / 10.4 `[ ]`.
- **No `GetFunctionByName("F")` (or index-0 / sole-function) as GREEN.** Isolated `GetFunctionByIndex(0)` is not the production contract. GREEN is `GetNativeFunctionByDecl(..., "int F()")`, execute `F()==42`, publisher `CANONICAL_CODEGEN`, bytecode `asBC_CmpPtrNull`.
- Do not weaken those asserts. Do not delete the RED method. Do not dummy-construct REF locals as VALUE. Do not re-enable `@` / `is` / script `funcdef`. Do not treat `nullptr` spelling change as GREEN unless the four asserts hold. Do not edit this comparison into an emitter tweak before the dump.
)
