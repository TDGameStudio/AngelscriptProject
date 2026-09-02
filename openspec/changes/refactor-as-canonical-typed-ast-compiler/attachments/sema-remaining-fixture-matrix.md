# Sema remaining fixture matrix (R02 / 4.2–4.6 / 5.2–5.9 / 13.2)

Worktree: `D:\as-cta`. Attachment-only inventory after SemaAuthority **22/22** (`wave-b-sema-lang-final`).

**Do not** treat SemaAuthority 22/22 as 5.9 / 13.2 / 4.x complete. Those twenty-two dumps prove named forms on a sealed (or parse-sealed) graph. They do not replace `asCScriptNode` with a Sema environment, and production `Build()` still publishes Bytecode from `asCCompiler`.

Fork dialect (authoritative here):

- no script `funcdef` / `@` / `is` tokens (`ttIs` / `ttNotIs` commented out; `nullptr` → `ttNull`);
- mixin **functions**, not mixin classes;
- mutable script globals rejected (`const` only);
- source spelling `float` stays `float` under `asEP_FLOAT_IS_FLOAT64` (`ActOnQualTypeFromNode` interns `"float"` as `ttFloat` before token-width rewrite);
- hidden / WorldContext-style args exist on **native** bindings (`hiddenArgumentIndex`), not as a script keyword;
- named arguments (`Name: expr`) are accepted by Parser/`asCCompiler` and now by Sema `ReorderNamedArguments`;
- host `RegisterFuncdef` is allowed; script `funcdef` is not.

Dump surface today (`as_ast_dump.cpp`):

- DECL: `key=` / `type=` / `quals=` / `traits=` / `origin=` / `default=` / `deps=` / `bases=`;
- STMT: `kind=` and `target=` when `stmt->target` is valid (Continue / Break / Case);
- EXPR Call/Construct: `literal=` / `callee=` / `nargs=` / `args=` (child **literals**, not child ids) / `route=import` when the resolved decl is `kind=Import`;
- other EXPR: `literal=` / `callee=` only (no children). Conversion dest type ids are not dumped.

`ActOnCall` now stores children **reverse-formal** (`for i = length; i > 0; --i PushLast(args[i-1])`) and labels `…:reverse-formal`. Isolated CodeGen may reverse again on emit. That is a CodeGen double-reverse, **not** a reason to uncheck the Sema dump.

Parser is still `asCScriptNode` + incremental `NotifySema`, not Clang-style action-only Sema. `ParseScript` builds the syntax tree; each completed top-level decl calls `NotifySema` → `ActOnParsedDeclaration`. If `semaDeclActions == 0` after a full parse, `ActOnParsedScript` walks the tree. `as_sema_decl.cpp` / `as_sema_expr.cpp` / `as_sema_stmt.cpp` still `#include as_scriptnode.h` and recurse.

Status legend: `covered-green` / `covered-dump-only` / `missing-test` / `fork-rejected`.

`covered-dump-only` means a SemaAuthority dump token exists but production backends still rerun `asCCompiler`, or the fact is fixture-limited (example: `array<int>` parse→seal because a native array factory could not register for `Build()`).

## SemaAuthority 22 methods (current file)

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

| # | TEST_METHOD | Path | Dump tokens asserted |
| --- | --- | --- | --- |
| 1 | `CallSelectsExactIntOverloadNotFirstName` | CANONICAL `Build()` + retain | `key=F(int)`, `key=F(float)`, `callee=F(int)`, not `callee=F(float)` |
| 2 | `IntArgumentToFloatParamRecordsConversionNode` | `Build()` | `kind=Conversion`, `callee=G(float)` |
| 3 | `ConstructorOverloadsSelectExactCtorNotFirstName` | `Build()` | `key=T::T()`, `key=T::T(int)`, `key=T::~T()`, `callee=T::T(int)` |
| 4 | `MixinFunctionKeepsMixinKindAndSignature` | `Build()` | `kind=Mixin`, `key=MixHelper(int)` |
| 5 | `MultipleLambdasKeepDistinctStableKeys` | Parser `SetSema` + `Seal` (no `Build()`) | two `name=<lambda>` keys with `(int)`, distinct `@offset` |
| 6 | `ValueTemporaryRecordsMaterializeAndCleanup` | `Build()` | `kind=MaterializeTemporary`, `kind=Cleanup`, `callee=FValue::FValue()` |
| 7 | `NamespaceOverloadSelectsScopedFunctionNotGlobal` | `Build()` | `key=Game::F(int)`, `key=F(int)`, `callee=Game::F(int)`, not `callee=F(int)` |
| 8 | `OperatorPlusSelectsOpAddNotBuiltinBinary` | `Build()` | `key=T::opAdd(int)`, `callee=T::opAdd(int)` |
| 9 | `DefaultArgumentIsRecordedOnCallPlan` | `Build()` | `default=7`, `callee=F(int,int)`, `literal=default:7`, `nargs=2`, `reverse-formal` |
| 10 | `ContinueTargetsEnclosingWhileOnCompileSealPath` | `Build()` | `kind=While`, `kind=Continue`, `target=` Atoi `> 0` |
| 11 | `NamedArgumentReordersIntoFormalSlots` | `Build()` | `callee=F(int,int)`, `nargs=2`, `args=named:b=2,named:a=1` (formal then reverse-formal) |
| 12 | `MixinCallBindsReceiverNotFreeGlobal` | `Build()` | `kind=Mixin`, `key=MixHelper(T,int)`, `callee=MixHelper(T,int)`, `nargs=2` (no `receiver=` token) |
| 13 | `PropertyReadWriteRewritesToAccessors` | `Build()` | `callee=T::GetValue()`, `callee=T::SetValue(int)` |
| 14 | `BreakTargetsNearestSwitchNotOuterLoop` | `Build()` | Break `target=` equals Switch id, not While id |
| 15 | `ReverseFormalChildrenMatchStoredOrder` | `Build()` | `callee=F(int,int)`, `nargs=2`, `args=2,1`, not `args=1,2` |
| 16 | `DestructorCallSiteRecordsCallee` | `Build()` | `key=T::~T()`, `kind=Cleanup`, `callee=T::~T()` |
| 17 | `FloatArgumentToIntParamRecordsConversionNode` | `Build()` | `kind=Conversion`, `callee=G(int)` |
| 18 | `TemplateContainerTypeKeyIsArrayIntNotBareArray` | Parser `SetSema` + `Seal` after `RegisterObjectType("array<class T>")` | `type=array<int>`, not `type=array ` |
| 19 | `ImportCallKeepsImportRouteDistinctFromGlobal` | `Build()` | `kind=Import`, `origin=CanonicalASTSemaImportProvider`, `callee=SharedValue()`, `route=import`, not `callee=LocalValue()` |
| 20 | `ListPatternRecordsStructuredNodes` | `Build()` + native `{repeat int}` list factory | `literal=list-pattern`, `args=1,2` |
| 21 | `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` | `Build()` | `kind=Method name=GetValue`, `name=SetValue`, `callee=T::GetValue()`, GetValue line `traits=256` (`asAST_TRAIT_GENERATED`) |
| 22 | `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails` | `ParseScript` fail (no `Build()` / no `Seal`) | `kind=Function name=First`, not `name=Second` |

## Matrix

| Form | Spec/task | Existing test | Dump already shows? | Fork-dialect / fixture note | Status |
| --- | --- | --- | --- | --- | --- |
| Exact overload select (int vs float) | R02, 5.2, 5.3, 13.2 | `CallSelectsExactIntOverloadNotFirstName` | `key=F(int)`, `key=F(float)`, `callee=F(int)` | `float` spelling stays `float` | `covered-green` |
| Implicit int→float conversion | R02, 5.2, 13.2 | `IntArgumentToFloatParamRecordsConversionNode` | `kind=Conversion`, `callee=G(float)` | Same float spelling | `covered-green` |
| Float→int conversion | 5.2, 13.2 | `FloatArgumentToIntParamRecordsConversionNode` | `kind=Conversion`, `callee=G(int)` | `RankArgument` scores float→int `0` (below int→float `1`) | `covered-green` |
| Ctor overload `T v(3)` + dtor identity key | R02, 5.2, 5.7 | `ConstructorOverloadsSelectExactCtorNotFirstName` | `key=T::T()`, `key=T::T(int)`, `key=T::~T()`, `callee=T::T(int)` | Struct value object | `covered-green` |
| Mixin **decl** kind + signature | 4.4, 5.9 | `MixinFunctionKeepsMixinKindAndSignature` | `kind=Mixin`, `key=MixHelper(int)` | Mixin **function**, not class | `covered-green` |
| Mixin **call** with class receiver | R02, 5.3, 5.9 | `MixinCallBindsReceiverNotFreeGlobal` | `callee=MixHelper(T,int)`, `nargs=2` | Implicit receiver prepended then reverse-formal; dump has **no** `receiver=` field | `covered-green` |
| Lambda distinct stable keys | 4.4, 5.9 | `MultipleLambdasKeepDistinctStableKeys` | two `<lambda>(int)@offset` keys | Parse→seal, `Parser.SetSema`; no `funcdef`/`@` | `covered-dump-only` |
| Value temporary materialize + cleanup + `T()` | 5.4, 5.7, 5.8 | `ValueTemporaryRecordsMaterializeAndCleanup` | `MaterializeTemporary`, `Cleanup`, `callee=FValue::FValue()` | `T()` temporary vs `T v(3)` both needed | `covered-green` |
| Namespace-scoped overload vs global | R02, 5.3, 13.2 | `NamespaceOverloadSelectsScopedFunctionNotGlobal` | `callee=Game::F(int)`, not `callee=F(int)` | `snScope` → `ResolveScopeOwner` | `covered-green` |
| Operator `+` → `opAdd` call | R02, 5.2, 5.3 | `OperatorPlusSelectsOpAddNotBuiltinBinary` | `callee=T::opAdd(int)` | Only `ttPlus` rewrites; no `is`/`!is` | `covered-green` |
| Default argument on call plan | R02, 5.3, 4.4 | `DefaultArgumentIsRecordedOnCallPlan` | `default=7`, `literal=default:7`, `nargs=2`, `callee=F(int,int)`, `reverse-formal` | Trailing defaults; synthesized via `strtoul` | `covered-green` |
| Continue → enclosing while target | R02, 5.5, 5.6 | `ContinueTargetsEnclosingWhileOnCompileSealPath` | `STMT … kind=Continue target=<id>` | `NearestControl(loopsOnly=true)` | `covered-green` |
| Break nearest switch vs outer loop | 5.5, 5.6 | `BreakTargetsNearestSwitchNotOuterLoop` | Break `target=` = Switch id, not While | `NearestControl(loopsOnly=false)` | `covered-green` |
| Named arguments | R02, 5.3, 4.4 | `NamedArgumentReordersIntoFormalSlots` | `args=named:b=2,named:a=1`, `nargs=2` | Formal-slot then reverse-formal store | `covered-green` |
| Reverse-formal **stored** children | 5.3, 9.4 | `ReverseFormalChildrenMatchStoredOrder` | `args=2,1`, not `args=1,2` | Stored in `ActOnCall`; CodeGen may double-reverse — CodeGen issue, do not uncheck this dump | `covered-green` |
| Property get/set rewrite | R02, 5.3, 5.4 | `PropertyReadWriteRewritesToAccessors` | `callee=T::GetValue()`, `callee=T::SetValue(int)` | Looks up `Get`/`Set` + name; no `rewrite=` token | `covered-green` |
| Generated accessors / lifecycle | 4.5, 5.9 | `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` | `GetValue`/`SetValue` methods, `traits=256`, `callee=T::GetValue()` | Empty-class field synthesizes accessors; ctor/dtor generation is separate (`EnsureGeneratedLifecycle`) | `covered-green` |
| Destructor call-site `T::~T()` | R02, 5.7, 5.8 | `DestructorCallSiteRecordsCallee` | `callee=T::~T()` on Cleanup | `ActOnCleanup` binds destructor by parent type name | `covered-green` |
| Import vs global | 4.2, 4.5, 5.3, 5.9 | `ImportCallKeepsImportRouteDistinctFromGlobal` | `kind=Import`, `origin=…`, `route=import`, `callee=SharedValue()` | Import is a callee kind in `FindBestCallee` | `covered-green` |
| List pattern | 4.4, 5.9 | `ListPatternRecordsStructuredNodes` | `literal=list-pattern`, `args=1,2` | `snInitList` → Construct; `snListPattern` still also records `origin=` / generated var | `covered-green` |
| Parser incremental Sema on later syntax error | 4.2, 13.2 | `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails` | `kind=Function name=First`, not `Second` | `NotifySema` during parse; still `asCScriptNode`; no `Seal`/`Build()` | `covered-dump-only` |
| Template / `array<int>` type key | 4.3, 5.9 | `TemplateContainerTypeKeyIsArrayIntNotBareArray` | `type=array<int>` | Parse→seal only: native array factory could not register for `Build()` | `covered-dump-only` |
| Hidden / injected args (WorldContext-like) | R02, 5.3, 7.4 | HIR `HiddenArgument`; **no SemaAuthority** | No `origin=hidden`; no `hiddenArgumentIndex` in Sema | Host trait, not script syntax | `missing-test` |
| Index + mutation single-evaluation | R02, 5.4 | VM `RunSingleEval` is member `+=`; **no SemaAuthority `opIndex`** | `ActOnIndex` can emit `kind=Index`; no Sequence / once-only base / `opIndex` callee | Indexed native properties ≠ script `opIndex` | `missing-test` |
| `this` / effective receiver dump | R02, 5.3 | Mixin call uses implicit first arg; **no `this` SemaAuthority** | No `receiver=` dump field | Mixin formal-0 ≠ dumped receiver metadata | `missing-test` |
| Const global (mutable forbidden) | 4.5, 5.9 | VM rejects `int Mutable = 1`; **no SemaAuthority const-trait** | Var dump possible; const/mutable trait not proven | Mutable script globals **forbidden** | `missing-test` |
| Delegate / script `funcdef` | 5.9 | AST kind `FuncDef` exists; CodeGen host `RegisterFuncdef` isolated | Script `funcdef` not a sealed source fact | Host `RegisterFuncdef` allowed; script `funcdef` **fork-rejected** | `fork-rejected` |
| Lambda call-through | 5.9, 5.3 | Identity keys dump-only; **no SemaAuthority invoke** | Keys only; no Call through lambda value | No `@` handle syntax | `missing-test` |
| Switch fallthrough target | 5.5, 5.6 | `ActOnFallthrough` creates stmt **without** target; **no SemaAuthority** | `kind=Fallthrough` possible; no `target=` | Explicit stmt kind; edge not stored | `missing-test` |
| Conversions beyond int↔float / `cast<T>` dest key | 5.2, 13.2 | int↔float SemaAuthority only; `snCast` → Conversion | Dest type key not dumped | `RankArgument` is exact type-id, int→float, or float→int | `missing-test` |
| Native call route / ABI | 5.3, 7.4 | **no SemaAuthority** | No `route=native` | Hidden args share this gap | `missing-test` |
| Operators besides `opAdd` (`opIndex` / `opAssign` / …) | 5.2, 5.3 | Only `ttPlus` rewrites to `opAdd` | Index stays structural | No `is`/`!is` rewrite | `missing-test` |
| Short-circuit / conditional sequencing nodes | 5.4 | `ActOnLogical` / `ActOnConditional` exist; **no SemaAuthority** | No Sequence/single-eval dump test | Side-effect traces today are `asCCompiler` | `missing-test` |
| Control phases (for init/cond/incr, do, if/else) | 5.5, 5.6 | Stmt kinds exist; **no SemaAuthority phase dump** | Continue/break targets only | Safe-point roles absent | `missing-test` |
| Handles / refs / deferred out / return transfer cleanup | 5.7, 5.8 | Temporary Cleanup only | No live-only reverse plan ids | Exceptional cleanup still `asCCompiler` | `missing-test` |
| `try`/`catch` | 5.7 | Stmt walk emits diagnostic `try-catch-rejected` | No dump requirement | Currently rejected; not a covered form | `missing-test` |
| Suspend / safe-point metadata | 5.9 | **no SemaAuthority** | No AST fact | 5.9 complete-language remainder | `missing-test` |
| Typedef / enum / interface / access specifiers / inheritance | 4.2, 4.4, 4.5 | Decl walk can create kinds; **no SemaAuthority** | `bases=` dump exists unused | Not in the 22 | `missing-test` |
| Qualifier / ref / handle ranking | 4.3, 5.2 | `CollectQuals` + `quals=` dump; **no ranking test** | Named types still interned as value/ref by handle bit | Template intern uses `asAST_TYPE_TEMPLATE` when key has `<` | `missing-test` |
| Shadow mismatch gate | 4.6 | Frontend `asCASTShadowDiff`; **no SemaAuthority** | N/A | Production still publishes builder/`asCCompiler` | `missing-test` |
| Sema environment (scopes/symbols/candidates) replacing `asCScriptNode` walk | 13.2, 4.2 | `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails` only proves incremental NotifySema | IDs/`callee=`/`target=` are conversion facts | **This is 13.2.** Dump-green ≠ environment | `missing-test` |
| Script `funcdef` / `@` / `is` | 4.2, 5.9 | Baseline / tokendef / ASSDK fork guide | N/A | `fork-rejected` | `fork-rejected` |
| Constructor `T v(3)` vs `T()` temporary | 5.2, 5.7 | Split across ctor-overload + ValueTemporary (both green) | Both present | Keep both | `covered-green` |

## 1. What lookup / overload still cannot do after the 22 dumps

Read from current `as_sema_expr.cpp` / `as_sema.cpp` / `as_sema_stmt.cpp` / `as_sema_decl.cpp`. Dump-green does not mean these are gone:

1. **Hidden / WorldContext injection** — no `hiddenArgumentIndex` synthesis into the stored call.
2. **Default-arg conversions** — fill uses `strtoul` integer literals; conversion loop runs only after fill if types mismatch; no general default-expr Sema.
3. **`receiver=` / `this` metadata** — mixin/method calls prepend an implicit expr into `args` then reverse-formal store; dump has no `receiver=` field.
4. **`opIndex` / operators other than `+`** — Index is structural (`ActOnIndex`); only `ttPlus` rewrites to `opAdd`.
5. **Ambiguity rejection** — best `RankArgument` score wins; on total miss, **`FindNamedDecl` first-same-name fallback** still returns a wrong Decl.
6. **`FindNamedDecl` itself** — still first child with matching `name` walking parents; no type/const/import filtering of its own.
7. **`RankArgument` width** — exact type-id, int→float (`1`), float→int (`0`); no ref/handle/qualifier ranking.
8. **`SelectConstructor` arity** — still exact param count; does not share default-arg fill with `FindBestCallee`.
9. **Lambda / delegate invoke** — no call-through of a function-valued expr; script `funcdef` remains fork-rejected.
10. **Fallthrough edges** — `ActOnFallthrough` creates a stmt and does not set `target`.
11. **Cleanup plans** — `ActOnCleanup` binds one destructor by parent name; no live-only reverse plan, no exceptional path, no handle/ref/out transfer.
12. **Template / container execution** — `array<int>` is interned as `asAST_TYPE_TEMPLATE` on parse→seal; `Build()` path was not achieved.
13. **Production consumption** — every CANONICAL `Build()` still emits Bytecode from `asCCompiler`. Backends do not read these call plans.

Named args, default fill, import callee kind, mixin implicit receiver, property Get/Set rewrite, reverse-formal **storage**, destructor cleanup callee, and namespace `snScope` lookup **did** land in Sema (that is why the old `test-exists-red` / `missing-test` rows for those forms are stale).

## 2. Forms that make checking 13.2 or 5.9 a 虚标 even after 22/22

Checking 13.2 / 5.9 / 4.x from SemaAuthority 22/22 would still be fiction for at least:

1. **Parser is still `asCScriptNode` + incremental `NotifySema`**, not a Clang-style action-only Sema environment (13.2’s actual requirement). Method 22 proves First survives a later syntax error; it does not remove the syntax tree.
2. **Production Bytecode still reruns `asCCompiler`.** Dumps are shadow facts. 13.2 requires backends not to rerun Sema.
3. Hidden / WorldContext injection on sealed Calls.
4. Index rewrite, `opIndex`, and mutation **single-evaluation** nodes.
5. Effective `this` / `receiver=` dump (mixin `nargs=2` is not receiver metadata).
6. Native call route / ABI; full qualifier/ref/handle ranking.
7. Lambda **call-through**; closures; script delegates/`funcdef`/`@`/`is` (fork-rejected — must not be marked covered; host `RegisterFuncdef` is a different surface).
8. Switch **fallthrough** edges; for/do/if phases; safe-point / suspend metadata.
9. Const-global facts (mutable still rejected at Builder, not proven as a Sema trait).
10. Containers/templates with a `Build()` factory (the `array<int>` row is parse→seal fixture-limited).
11. Generated accessor **bodies**, defaults, list factories, and complete cleanup plans beyond Get/Set decls + one get Call + one destructor Cleanup.
12. Conversions other than int↔float; dest type keys; explicit `cast<T>` dump.
13. Verifier-enforced control-graph rules (5.6) and shadow mismatch (4.6).
14. Isolated CodeGen reverse-formal: Sema now stores reverse children. If `CodeGenEmitsCallInReverseFormalOrder` fails, that is a **CodeGen double-reverse**, not a Sema dump miss, and also **not** a reason to check 13.2.

`covered-green` in the table means the dump fixture exists and matches. It does not mean R02 authority.

## Recommended next dump tests (remaining gaps)

1. **HiddenArgumentInjectedOnNativeCallee** — host hidden fixture; sealed Call `nargs=` includes hidden; `origin=hidden` (or equivalent).
2. **IndexCompoundAssignEvaluatesBaseOnce** — `Make()[i] += 1` / script `opIndex` → Sequence/single-eval + callee; one base Materialize.
3. **ThisOrReceiverMetadataOnMethodCall** — dump `receiver=` (requires dump field) or an equivalent sealed fact, not only `nargs+=1`.
4. **FallthroughTargetsNextCase** — `kind=Fallthrough target=<nextCaseId>` (or verifier-rejected dangling).
5. **ConstGlobalTraitAndMutableReject** — `kind=Var` const quals; mutable script global fails as language gate.
6. **LambdaCallThroughUsesStableKey** — invoke dumps `callee=<lambda>(int)@offset`.
7. **AmbiguousOverloadIsRejectedNotFirstName** — two same-score callees must not bind via `FindNamedDecl` fallback.
8. **ArrayIntBuildPathOrDocumentedFactoryGap** — either `Build()` `array<int>` or keep the parse→seal limitation explicit (do not promote to 5.9).

Do not start these as CodeGen language growth while R11 teardown AV is red. Dump TDD on `as_sema*` is allowed after R11 without checking 13.2.

## Counts

| Metric | Value |
| --- | --- |
| SemaAuthority `TEST_METHOD`s | **22** |
| Matrix rows | **43** |
| `covered-green` | **20** (19 `Build()` methods; ctor `T v(3)` vs `T()` is a combined row over tests 3+6) |
| `covered-dump-only` | **3** (lambda keys parse→seal; `array<int>` parse→seal; Parser incremental NotifySema without Seal/Build) |
| `missing-test` | **18** |
| `fork-rejected` | **2** (script delegate/`funcdef`; `@`/`is` row) |

Path: `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/sema-remaining-fixture-matrix.md`
