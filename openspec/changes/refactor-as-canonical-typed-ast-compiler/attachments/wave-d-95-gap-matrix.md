# Wave D 9.5 gap matrix

Worktree: `D:\as-cta`. Read-only research package **D-95-gap-matrix**.
Did not run UBT / `RunBuild` / `RunTests`. Did not edit `Plugins/`.

## Why this file exists

`tasks.md` 9.5 is still `[ ]`:

> Implement value-object/temporary lifetime, handles/references, containers/templates, delegates/funcdefs, lambdas/closures, globals/imports, generated lifecycle/default/accessor/list factory bodies, and current exception/suspend semantics from canonical AST.

The live production gate is `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` — **8 methods**. Integer `F()` and LEGACY publisher are not 9.5 language coverage. The other six are a TDD slice (value object, temporary, lambda IIFE, const global, try/catch reject, mutable-global reject). **Do not check 9.5 from those 8 going green.** Do not flip default CANONICAL (Wave G). Do not invent CALL-without-callee.

## Hard rules

- 9.5 stays `[ ]` until every row below has a **production** `asCModule::Build()` under `asCOMPILER_PIPELINE_CANONICAL` that either executes with publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` or fail-closes **without** `asBYTECODE_PUBLISHER_COMPILER`.
- Isolated `asCBytecodeCodeGen::Generate()` (Frontend `CanonicalAST.CodeGen`) is not that gate.
- SemaAuthority / VM-matrix CANONICAL `Build()` dump or LEGACY-default execute tests are not that gate.
- Cutover `CanonicalSelectionPublishesValueObjectsFromCodeGen` is the value-object publisher twin of ProductionCodeGen; it does not close the rest of 9.5.
- Default `ep.canonicalCompilerPipeline` stays LEGACY. Wave G is out of this package.

## Live ProductionCodeGen 8 (not a 9.5 close)

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`

| Method | 9.5 fragment? | Script |
| --- | --- | --- |
| `CanonicalModuleBuildPublishesCodeGenForIntegerReturn` | No (9.2 routing) | `int F() { return 7; }` |
| `LegacyModuleBuildStillPublishesCompiler` | No (LEGACY control) | same under default pipeline |
| `CanonicalValueObjectBuildPublishesCodeGenAndExecutes` | Yes (slice) | script `struct FValue` local + ctor `Value = 41` + `Object.Value + 1` |
| `CanonicalConstGlobalBuildPublishesCodeGenAndExecutes` | Yes (slice) | `const int G = 41;` + `F()` |
| `CanonicalLambdaBuildPublishesCodeGenAndExecutes` | Yes (slice) | non-capturing `function(int X){ return X + 1; }(41)` |
| `CanonicalTemporaryConstructPublishesCodeGenAndExecutes` | Yes (slice) | `return FValue().Value + 1;` |
| `CanonicalTryCatchRejectedDoesNotPublishCompiler` | Yes (current exception = reject) | source `try`/`catch` |
| `CanonicalMutableGlobalRejectedDoesNotPublishCompiler` | Yes (mutable globals = reject) | `int G = 1;` |

`tasks.md` 9.5 Why: GREEN is in progress (`RegisterCanonicalScriptTypes` + ctor bind); compile currently fails `C3861 CastToObjectType` at `FillFunctionSignature`. Handles/refs, templates, funcdefs, imports, suspend are **not** in this file.

Related Cutover (not one of the 8): `CanonicalSelectionPublishesValueObjectsFromCodeGen` — same `struct FValue` script, execute 42 + `CANONICAL_CODEGEN`.

## Fifth-pass F1 (must not be laundered by greens)

`reviews/implementation-rereview-2026-08-22-fifth-pass.md` **F1**:

1. **Empty `functionDecls` skip.** `asCBytecodeCodeGen::Generate` (`as_bytecode_codegen.cpp` ~1752) collects FUNCTION/METHOD/CONSTRUCTOR/DESTRUCTOR (body, or ctor/dtor). If the list is empty it returns `asAST_VERIFY_OK` **before** globals / types / imports / funcdefs. A global-only, type-only, import-only, or funcdef-only module can `Build()` success with nothing installed.
2. **Methods published as globals.** `CanonicalDeclIsFunctionLike` includes METHOD/CTOR/DTOR. `FillFunctionSignature` now tries `objectType` + `beh.construct` / `methods` (~1576–1603) but still uses `engine->GetTypeInfoByName` → `asITypeInfo*` (`C3861` vs `CastToObjectType`). `Commit()` (~1679–1688) **unconditionally** `globalFunctions.Add` / `globalFunctionList.PushLast` for every emitted function. A green value-object execute does not prove methods are not also globals.

Isolated `GenerateCanonicalFromSource` calls `Context.Seal()` only. Production `Build()` also runs `asCBuilder::SealCanonicalAST()`, which fail-closes when Sema diagnostics exist (`as_builder.cpp` ~690). That is why isolated mutable `int G` can lower while production mutable globals must reject.

## Dialect (do not violate)

- No script `funcdef` keyword (`ttFuncDef` token commented out in `as_tokendef.h`).
- No `@` handles. REF types use implicit handle.
- `struct` = VALUE script object. `class` = REF implicit handle. `RegisterCanonicalScriptTypes` currently forces **every** `DECL_CLASS` to `asOBJ_VALUE | asOBJ_SCRIPT_OBJECT | asOBJ_NOINHERIT` (~1523) — a `class` fixture would be mis-registered as VALUE unless that changes.
- Const primitive globals intern; mutable primitive globals Sema-diagnostic `mutable-global-rejected`.
- Source `try`/`catch` Sema-diagnostic `try-catch-rejected` (`as_sema_stmt.cpp` ~578).
- `&in` / `&out` / `&inout` **are** dialect (SemaAuthority compile-seal keys).
- Native CanonicalAST tests register `array<class T>` as `asOBJ_REF | asOBJ_TEMPLATE | asOBJ_NOCOUNT`. **No `dictionary` registration** in `AngelscriptTest`.

## Matrix

| Fragment | Live production test? | Isolated Generate coverage? | CodeGen emitter today | Fail-closed vs silent Compiler | Next TDD fixture (one minimal script) |
| --- | --- | --- | --- | --- | --- |
| Value-object local + ctor `this.member` | **Yes (slice):** `CanonicalValueObjectBuildPublishesCodeGenAndExecutes` + Cutover value-object twin. Not a 9.5 close by itself. | **Partial:** `CodeGenEmitsValueObjectConstructMemberAndCleanup` uses **host** `FNativeCaseValue`, not script `struct`. Isolated differential corpus is primitives/control only. | `RegisterCanonicalScriptTypes` VALUE layout; `EmitConstructInto` VALUE `PSF`+`CALL` ctor; `FindThisProperty` + `PSF`/`ADDSi`/`WRTV4` for `Value = 41`. `STMT_DECL` locals use `AllocDwords(SizeDwords)` not `AllocTyped` — construct depends on CONSTRUCT/assign, not decl slot. F1: ctor/method still `Commit` onto `globalFunctions`. | CANONICAL `Build()` does **not** call `asCCompiler` (`as_module.cpp` ~396–410). Failure should `InternalReset` without `COMPILER` publisher. Silent risk is **success with wrong owner** (F1), not Compiler laundering. | Keep the live script (do not weaken). After GREEN, add owner asserts (`objectType`, ctor **not** in `globalFunctionList`) — still not 9.5 close. `struct FValue { int Value; FValue() { Value = 41; } } int F() { FValue Object; return Object.Value + 1; }` |
| Temporary construct | **Yes (slice):** `CanonicalTemporaryConstructPublishesCodeGenAndExecutes`. | **No** dedicated temporary. Isolated value-object is a named local of a **native** type. | `asAST_EXPR_CONSTRUCT` → `EmitConstruct` (`AllocTyped` + ctor). `MATERIALIZE_TEMPORARY` / `CLEANUP` unwrap first child or `asNOT_SUPPORTED`. No separate temp lifetime table beyond reverse `DestroyLiveObjects`. | Same as value-object: CodeGen path, not Compiler. Incomplete temp cleanup is wrong bytecode, not `COMPILER`. | Live: `struct FValue { int Value; FValue() { Value = 41; } } int F() { return FValue().Value + 1; }` |
| Handles (implicit; **no `@`**) | **No.** | **Partial:** `CodeGenEmitsHandleParameterNullCheck` — host `RegisterObjectType("CObj", 0, asOBJ_REF)` + empty ADDREF/RELEASE; `bool IsNull(CObj Obj) { return Obj == nullptr; }`. | Handle locals: `ClrVPtr` / `FREE`. Null compare: `CmpPtrNull`. REF construct: `asBC_ALLOC`. Script `class` is **not** registered as REF (always VALUE). No production implicit-handle class. | Unsupported handle/class can `asNOT_SUPPORTED` inside Generate, or F1 skip if no function-like body. Must not fall back to Compiler on CANONICAL. Empty type-only module can silent-success (F1). | Host REF + production Build: register `CObj` as isolated does, then `bool IsNull(CObj Obj) { return Obj == nullptr; }`. Script-class follow-up only after types are REF implicit-handle: `class CRef { int Value; CRef() { Value = 41; } } int F() { CRef Object; return Object.Value + 1; }` — not the current VALUE registrar. |
| References (`&in` / `&out`) | **No** ProductionCodeGen. SemaAuthority `InOutParamOverloadsKeepDistinctStableKeysOnCompileSeal` / `ByRef(const int &in)` are dump/`Build()==0` only — not execute + publisher. | **No.** Isolated calls are by-value ints (`CodeGenEmitsCallInReverseFormalOrder`). | `InOutFromQuals` fills `inOutFlags`. `PushValue` always `PshV4`/`PshV8` — no address-of / ref-slot lowering. `EmitCall` has no `&out` write-back. | Sema currently accepts `&in`/`&out`. If Generate ignores quals and still `Commit`s, that is **silent wrong ABI**, not Compiler. Production tests must execute, not only dump keys. | `int InF(int &in x) { return x; } int F() { return InF(41) + 1; }` — execute 42 + `CANONICAL_CODEGEN`. Follow-up: `int OutF(int &out x) { x = 41; return 1; } int F() { int v = 0; OutF(v); return v + 1; }` |
| Containers / templates (`array`; dictionary N/A) | **No.** | **No CodeGen emit.** Type intern: `AngelscriptNativeCanonicalASTTypeTests` `array<int>`. Sema parse/seal: SemaAuthority array fixture. Isolated differential does not include templates. | No template instance install. `EmitConstruct` needs `GetTypeInfo()`. `opIndex` helper exists (`CALLSYS`/`CALL` `opIndex`) but no `array<T>` factory/insert/length emit. `dictionary` is **not registered** in native tests — do not invent it. | CANONICAL Build of `array<int>` without a type info is `asNOT_SUPPORTED` / invalid type, or F1 skip. Must not Compiler-publish. | After the same `array<class T>` register as TypeTests **plus** the factory/index/length stubs required to execute (do not CALL an unregistered callee): `int F() { array<int> Values; Values.insertLast(41); return Values[0] + 1; }`. Dictionary: **out of native coverage** until array production exists. |
| Delegates / host funcdef (script `funcdef` **rejected**) | **No.** | **Yes (host funcdef):** `CodeGenEmitsFuncdefCallAndLambda`, conversion dump, four teardown methods. All `RegisterFuncdef("int Callback(int)")`. | `EmitFuncPtr` / `REFCPY` / `CallPtr`. Looks up `engine->registeredFuncDefs`. Artifact `funcdefs` array is cleared on Commit and **never filled**. Script `funcdef` token is disabled — production must **reject** `funcdef int Cb(int);`, not enable syntax. | Host-funcdef holes: missing callee → `FailAt(..., asNO_FUNCTION / asNO_MODULE)` (existing FindFunc/FindSlot; **no** CALL-without-callee). Script `funcdef` must fail parse/Sema, not Compiler Bytecode. | Host: `RegisterFuncdef("int Callback(int)")` then `int Double(int X) { return X + X; } int Invoke(Callback Cb, int X) { return Cb(X); } int F() { return Invoke(Double, 21); }`. Script keyword: `funcdef int Cb(int); int F() { return 1; }` must `Build() < 0` and publisher ≠ `COMPILER`. |
| Lambdas / closures | **Partial:** non-capturing IIFE only (`CanonicalLambdaBuildPublishesCodeGenAndExecutes`). No capture / no store-to-funcdef. | **Partial:** lambda stored in host `Callback` (`CodeGenEmitsFuncdefCallAndLambda`, `CodeGenLambdaTeardownSurvivesEngineDestroy`). No capture. Isolated differential has no lambda. | Collects function-like decls with body, including TRAIT_LAMBDA. Direct IIFE needs CALL callee in `binds`. Store-to-funcdef needs host funcdef (isolated). Capture of enclosing locals: no slot/env emit. F1: lambda may land on `globalFunctions`. | Fail-closed is **wrong** for the live IIFE (must execute 42 + CODEGEN). Capture/unknown callee must fail Generate, not Compiler. | Keep live: `int F() { return function(int X) { return X + 1; }(41); }`. Next (not a substitute): `RegisterFuncdef("int Callback(int)")` + `int F() { Callback L = function(int X) { return X + 1; }; return L(41); }`. Do not treat a capturing closure as GREEN without a new RED. |
| Const globals | **Yes (slice):** `CanonicalConstGlobalBuildPublishesCodeGenAndExecutes`. | **Different shape:** `CodeGenEmitsGlobalIntReadWrite` is **mutable** `int G` via isolated Seal (Sema diagnostic not applied the production way). | TU-direct `DECL_VAR` only (~1756). Integer `atoi(defaultArg)` into `AllocateGlobalProperty`. No general init expr / `$init` bytecode. Nested namespace globals ignored. **F1:** `const int G = 41;` **without** `F()` hits `functionDecls == 0` and returns OK without installing `G`. | Production mutable vs const is Seal, not Compiler. Const-global-only module can silent-success empty (F1). | Keep live: `const int G = 41; int F() { return G + 1; }`. Extra RED (F1): `const int G = 41;` with **no functions** must not `Build()==0` unless `G` is actually installed and readable. |
| Mutable globals (must reject) | **Yes (slice):** `CanonicalMutableGlobalRejectedDoesNotPublishCompiler`. | Isolated **emits** mutable `int G` (`CodeGenEmitsGlobalIntReadWrite`) — opposite of production language gate. | Emitter will allocate/write globals if Seal never runs. Production `SealCanonicalAST` fail-closes on `mutable-global-rejected`. | Must stay **fail-closed**. Success + CODEGEN or COMPILER is a 9.5 regression. Isolated Generate is not permission to accept writable script globals. | Keep live: `int G = 1; int F() { return G; }` → `Build() < 0`, publisher ≠ `COMPILER`. |
| Imports | **No.** SemaAuthority import dump + VM-matrix import execute are not ProductionCodeGen publisher tests. | **No.** | No `asAST_DECL_IMPORT` commit. `FindFunc` only sees CodeGen `binds`. Import call → `asNO_MODULE` / `asNOT_SUPPORTED` if a function body exists; import-only module → F1 empty success. | Must fail-closed or bind `route=import` from AST — **not** Compiler. F1 silent success is the import-only trap. | Two-module: provider `int SharedValue() { return 41; }` then consumer `import int SharedValue() from "ProdImportProvider"; int F() { return SharedValue() + 1; }` + `CANONICAL_CODEGEN`. |
| Generated default ctor | **No** (live value-object uses a **user** ctor body). Sema `GeneratedLifecycleImportOriginAndDuplicateParam` dumps generated ctor on empty `class` — parse/seal only. | **No** generated script default. Isolated value-object uses **native** ctor. | Function-like collection includes ctor **without** body. `Emit` of empty generated ctor is not proven. `RegisterCanonicalScriptTypes` does not synthesize `beh.construct` unless a ctor decl is emitted and `FillFunctionSignature` binds it. | Missing default construct must `asNOT_SUPPORTED`, not Compiler. Silent: local left unconstructed then member-read. | `struct FValue { int Value = 41; } int F() { FValue Object; return Object.Value + 1; }` — no user `FValue()`. |
| Generated destructor | **No.** Isolated native `FNativeCaseValue` dtor is host `CALLSYS`, not generated script `~T`. | **Partial host dtor** on native value object (`CodeGenEmitsValueObjectConstructMemberAndCleanup`). | `DestroyObject` CALLs `beh.destruct` if set. Script dtor bind in `FillFunctionSignature`. Generated empty dtor body not production-tested. | Cleanup skip is a leak/wrong VM, not Compiler. | `struct FValue { int Value; FValue() { Value = 41; } } int F() { FValue Object; return Object.Value + 1; }` plus live-object/dtor counters once a script dtor is observable (or empty `class FBase {}` after REF layout is honest). |
| Generated accessor bodies | **No** ProductionCodeGen. SemaAuthority `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` / `PropertyReadWriteRewritesToAccessors` dump `GetValue`/`SetValue` on CANONICAL `Build()` — not execute 42 + publisher. VM-matrix accessor execute is not this prefix. | **No.** | Member load/store via `ADDSi`/`RDR4`/`WRTV4` on VALUE properties. Generated `GetValue`/`SetValue` method bodies are extra decls; F1 may publish them as globals. Property rewrite CALLs those methods only if `FindFunc` binds them. | Dump `Build()==0` can hide F1. 9.5 needs execute + `CANONICAL_CODEGEN` + methods not-as-globals. | `struct FValue { int Value; } int F() { FValue Object; Object.Value = 41; return Object.Value + 1; }` (generated get/set, no user accessors). |
| List factory | **No.** SemaAuthority `ListPatternRecordsStructuredNodes` registers `asBEHAVE_LIST_FACTORY` `{repeat int}` and dumps `literal=list-pattern` — not CodeGen execute. | **No.** | No list-pattern / `asBEHAVE_LIST_FACTORY` emit. Unknown expr kind → `asCONTEXT_NOT_FINISHED` / `asNOT_SUPPORTED`. | List init must fail-closed or call the registered factory. Silent Compiler forbidden. | Same host as SemaAuthority (`FSemaListBox` + list factory), then `int F() { FSemaListBox Box = {41}; return 42; }` only if factory/observable member is defined; otherwise fail-closed — do not CALL a missing factory. |
| Exception (source `try`/`catch` **currently rejected**) | **Yes (slice):** `CanonicalTryCatchRejectedDoesNotPublishCompiler`. | **No** try/catch emit (and must not grow one). | `EmitStmt` has no TRY/CATCH; default `asCONTEXT_NOT_FINISHED`. Production never reaches emit if Sema rejects. | **Keep reject.** Implementing handlers would expand past “current” semantics. Must not Compiler-compile `try`. | Keep live: `int F() { try { return 1; } catch { return 0; } }` → `Build() < 0`, ≠ `COMPILER`. |
| Suspend (loop safe-point; **not** mixin) | **No** ProductionCodeGen. Mixin is **9.4**, not in the 9.5 sentence — omitted as a 9.5 row. | **Partial:** `CodeGenEmitsLoopSuspendAndIndex` — `while` emits `asBC_SUSPEND` and `Count(3)==3`. Isolated differential `While` does not assert the opcode. | `EmitWhile` inserts `SUSPEND` + `JitEntry` after the condition (~1370). `EmitDoWhile` / `EmitFor` do **not**. No coroutine/yield. | Integer `while` under CANONICAL already goes through Generate; missing SUSPEND is a metadata hole (also 9.6), not Compiler. Production must assert opcode + execute + publisher. | `int F() { int Y = 0; while (Y < 42) { Y = Y + 1; } return Y; }` — execute 42, `CANONICAL_CODEGEN`, bytecode contains `asBC_SUSPEND`. |

## What would still be open if the 8 go green

Still missing production publisher (or fail-closed) coverage:

- handles (implicit REF / script `class`)
- `&in` / `&out` execute
- `array<T>` (dictionary not even registered)
- host funcdef + script `funcdef` reject
- capturing closures / lambda stored in funcdef
- imports
- generated default ctor, dtor, accessor, list factory
- loop `SUSPEND` on the production publisher
- F1: empty `functionDecls` skip; methods/ctors on `globalFunctions`

9.1 / 13.6 detached artifact, 9.6 debug/coverage metadata, 9.7 SDK corpus, 10.1–10.4 cutover, and Wave G remain separately open. Integer ProductionCodeGen 2/8 (integer + LEGACY) is already routing, not 9.5.

## Next implementer note (not this package)

`attachments/wave-d-95-plan.md` may GREEN the six live 9.5 slices. After that, add **one new ProductionCodeGen method per remaining row** (minimal script in the table). Do not mark `tasks.md` 9.5. Do not start Wave G. Do not add CALL with an empty callee.
