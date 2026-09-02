# Wave D 9.5 results (2026-08-22)

Do **not** check `tasks.md` 9.5 / 9.1 / 13.2 / 13.3 / 13.6 / 10.2 / 10.4.

## ProductionCodeGen `d95-capture-green` — capturing IIFE GREEN

Prefix **24/24 PASS**. Cutover **5/5** (`d95-capture-cutover`). `CanonicalCapturingLambdaBuildPublishesCodeGenAndExecutes` (`int X = 41; return function() { return X + 1; }();`) executes 42 + `CANONICAL_CODEGEN`. Existing 0-capture IIFE `function(int X){ return X+1; }(41)` stays green.

RED at `d95-capture-red`: **23/24**. Assert `CANONICAL capturing lambda Build must succeed from CodeGen`. Generate `asNOT_SUPPORTED` (-7) at `EmitDeclRef` `FindSlot` miss (`as_bytecode_codegen.cpp:978`): lambda body `X` is `F`'s `DECL_VAR`, not a lambda slot. The 2440 `asNOT_SUPPORTED` in the same log is the already-GREEN enum-only fail-closed preflight, not this fixture.

GREEN path: walk `TRAIT_LAMBDA` body for enclosing-function `VAR`/`PARAM` refs; append them as hidden formals; caller IIFE `CALL` pushes those slots; callee `BindSlot`s them as extra parameters. Not a stored/funcdef closure object. Fail-closed remains if the caller frame has no slot (non-IIFE invoke).

Summaries: `D:\as-cta\Saved\Tests\d95-capture-green\20260822_050126_060_226bf449\Summary.json`, `D:\as-cta\Saved\Tests\d95-capture-cutover\20260822_050204_149_9d5ceea2\Summary.json`.

**Not 9.5.** Remaining spec sentence: stored capturing closures, exception/cleanup tables, and the rest of full-language CodeGen. Next exclusive UBT: F4 LEGACY lambda-to-host-funcdef (`wave-d-95-f4-next.md`).

---

## ProductionCodeGen `d95-f1` — F1 empty-decl preflight GREEN

Prefix **23/23 PASS**. Cutover **5/5** (`d95-f1-cutover`). Added `CanonicalConstGlobalOnlyBuildInstallsOrFailsClosed` (empty `functionDecls`, `G==41`), `CanonicalValueObjectCtorIsOwnedAndNotGlobal` (ctor `objectType` set, not on `globalFunctionList`), and `CanonicalEnumOnlyBuildInstallsOrFailsClosed` (enum-only must install or fail-closed).

RED at `d95-f1-red`: **22/23**. Const-global-only and ctor-owner were already GREEN regressions. Enum-only `Build()==0` without `EProd` (silent skip).

GREEN path: `Generate()` fail-closes `asNOT_SUPPORTED` for decl kinds CodeGen does not install (`ENUM` / `INTERFACE` / `FUNCDEF` / `TYPEDEF` / `MIXIN` / …) before mutating types. Supported kinds stay TU/namespace/class/function/method/ctor/dtor/var/param/property/import.

Summary: `D:\as-cta\Saved\Tests\d95-f1\20260822_044523_230_9952856a\Summary.json`.

**Not 9.5.** Remaining spec sentence: capturing closures. Enum is fail-closed, not installed.

---

## ProductionCodeGen `d95-listfactory3` — list factory GREEN

Prefix **20/20 PASS**. Cutover **5/5** (`d95-listfactory-cutover`). `CanonicalListFactoryBuildPublishesCodeGenAndExecutes` (`FSemaListBox Box = {41}; return Box.Marker + 1`) executes 42 + `CANONICAL_CODEGEN`. Factory reads the list buffer (`count` then first `int`) and sets `Marker`. `F()` `CALLSYS`s the registered `asBEHAVE_LIST_FACTORY` id.

RED at `d95-listfactory-red`: **19/20**. Build failed (`asNO_FUNCTION`) because list-pattern CONSTRUCT was typed `int` and assign inserted a conversion.

GREEN path: Sema `ActOnAssign` retargets `literal=list-pattern` to the lhs type instead of converting. CodeGen `EmitListFactoryInto` uses `beh.listFactory` (never a 0-arg factory), `AllocMem`+`SetListSize`+`PshListElmnt`/`WRTV4`, `CALLSYS`, `STOREOBJ`. Handle member load uses `PshVPtr` not `PSF`.

Summary: `D:\as-cta\Saved\Tests\d95-listfactory3\20260822_043742_221_6574cdf0\Summary.json`.

**Not 9.5.** Remaining: F1 empty-`functionDecls`, capturing closures.

---

## ProductionCodeGen `d95-gendtor` — generated destructor GREEN

Prefix **19/19 PASS**. Cutover **5/5** (`d95-gendtor-cutover`). `CanonicalGeneratedDestructorBuildPublishesCodeGenAndExecutes` (`struct FValue { int Value; FValue() { Value = 41; } }` / omit `~FValue`) executes 42 + `CANONICAL_CODEGEN`. `asBEHAVE_DESTRUCT` installed, `objectType == FValue`, not on `globalFunctionList`. `int F()` CALLs that destructor id (`asBC_CALL`, not host `CALLSYS`).

RED at `d95-gendtor-red`: **18/19**. Execute 42 already (false green). Assert `generated ~FValue must be installed as asBEHAVE_DESTRUCT, not omitted as POD`. Collect skipped `TRAIT_GENERATED` `DECL_DESTRUCTOR`; `RegisterCanonicalScriptTypes` zeros `beh.destruct`.

GREEN path: collect every `DECL_DESTRUCTOR` (including generated). Empty body is JitEntry+RET. `FillFunctionSignature` sets `beh.destruct`. `DestroyLiveObjects` CALLs it after `return` jumps to label 0.

Summary: `D:\as-cta\Saved\Tests\d95-gendtor\20260822_042648_564_9a183d12\Summary.json`.

**Not 9.5.** Remaining production rows: list factory, F1 empty-`functionDecls`.

---

## ProductionCodeGen `d95-genacc-mt` — generated accessors GREEN

Prefix **18/18 PASS**. Cutover **5/5** (`d95-genacc-cutover`). `CanonicalGeneratedAccessorBuildPublishesCodeGenAndExecutes` (`struct FValue { int Value; }` / `Object.Value = 41; return Object.Value + 1`) executes 42 + `CANONICAL_CODEGEN`. `GetValue`/`SetValue` owned by `FValue`, not on `globalFunctionList`. Getter `asBC_RDR4`, setter `asBC_WRTV4`. `int F()` CALLs both method ids (not inline `ADDSi` on `F()`).

RED at `d95-genacc-red`: **17/18**. Assert `CANONICAL generated accessor Build must succeed from CodeGen` (`SetValue` `EmitCall` miss). Intermediate `d95-genacc` **17/18**: Build/execute 42 already, but `GetMethodByName("GetValue")` null because CodeGen only `methods.PushLast` and never `methodTable.Add`.

GREEN path: collect `TRAIT_GENERATED` METHOD even without a body; `EmitGeneratedAccessor` synthesizes Get (`PushThis`/`ADDSi`/`RDR4`/`LoadReturn`) and Set (`WRTV4` from param); `FillFunctionSignature` also `methodTable.Add`. Sema already rewrites `Object.Value` to Get/Set calls.

Summary: `D:\as-cta\Saved\Tests\d95-genacc-mt\20260822_042125_807_cdd11529\Summary.json`.

**Not 9.5.** Remaining production rows: generated dtor / list factory, F1 empty-`functionDecls`.

---

## ProductionCodeGen `d95-import` — import CALLBND GREEN

Prefix **17/17 PASS**. Cutover **5/5** (`d95-import-cutover`). `CanonicalImportCallBuildPublishesCodeGenAndExecutes` (provider `int SharedValue() { return 41; }`, consumer `import int SharedValue() from "ProdImportProvider"; return SharedValue() + 1`) executes 42 + `CANONICAL_CODEGEN` + `asBC_CALLBND`. Slot count 1; `BindImportedFunction(0, provider SharedValue)`.

RED at `d95-import-red`: **16/17**. `CompileNativeModule != 0`; Automation: `Canonical CodeGen failed code=-15 line=1567` (`EmitCall` `FailAt` `asNO_MODULE`); assert `CANONICAL import consumer Build must succeed from CodeGen`. Publisher ≠ `COMPILER` (Generate miss, no `Commit`). Summary: `D:\as-cta\Saved\Tests\d95-import-red\20260822_040918_072_83a57451\Summary.json`.

GREEN path: `Generate()` walks `asAST_DECL_IMPORT`, `AddImportedFunction(GetNextImportedFunctionId(), name, type, params, origin)` (quotes already stripped by Sema `SetOrigin`). Binds decl id → `asFUNC_IMPORTED` signature in CodeGen `binds`; does **not** push onto `artifact.functions`. `EmitCall`: `funcType == asFUNC_IMPORTED` → `asBC_CALLBND` with import id (`FUNC_IMPORTED` bit) before CALL/CALLSYS. Miss still `FailAt(..., asNO_MODULE)`. Never CALL the provider `asFUNC_SCRIPT` id.

Summaries: `D:\as-cta\Saved\Tests\d95-import\20260822_041123_927_a4423acd\Summary.json`, `D:\as-cta\Saved\Tests\d95-import-cutover\20260822_041204_966_6a764426\Summary.json`.

**Not 9.5.** Remaining production rows: generated accessors / dtor / list factory (`wave-d-95-lifecycle-next.md`; live count **17**, ignore that file's stale 15), F1 empty-`functionDecls`.

---

## ProductionCodeGen `d95-array-rdr4` — array\<T\> GREEN

Prefix **16/16 PASS**. Cutover **5/5** (`d95-array-cutover`). `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` (`array<int> Values; insertLast(41); return Values[0]+1`) executes 42 + `CANONICAL_CODEGEN`.

GREEN path: factory `"array<T> f(int&in)"` without `@` + `asOBJ_IMPLICIT_HANDLE`; factory objectRegister → `asBC_STOREOBJ`; host method `this` last on stack (`CallGeneric`); `opIndex` `T&` → `asBC_RDR4`. Intern: `InternNativeMethods` + `FindMethodUntil` + `literalBits` receiver.

**Not 9.5.** Remaining production rows: imports (`CALLBND`), generated accessors / dtor / list factory, F1 empty-`functionDecls`.

---

## ProductionCodeGen `d95-array-green7` — array\<T\> RED (Build yes, live handle no)

Prefix **15/16**. New method `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` (`array<int> Values; insertLast(41); return Values[0]+1`) publishes from CodeGen (`publisher=0` was the first RED; later runs Build==0) then execute `Null pointer access` at F() line 5 (`Values.insertLast`). Host register uses implicit-handle factory without `@`. Dump (`d95-array-dump`) shows interned `array<int>::insertLast(const T&in)` plus an orphan `call:reverse-formal` CALL. Remaining hole: factory CALLSYS does not leave a non-null handle in the local. **Not 9.5.**

---


## ProductionCodeGen `d95-funcdef` — host funcdef + script keyword reject

Prefix **15/15 PASS**. Host `RegisterFuncdef("int Callback(int)")` + `Invoke(Double, 21)` executes 42 with `CANONICAL_CODEGEN` and `asBC_CallPtr` on `Invoke`. Script `funcdef int Cb(int);` stays rejected (`Build() < 0`, publisher ≠ `COMPILER`). Isolated Generate already lowered this shape; this is the production publisher gate.

Wave B prefixes after dump-seal helper: Compiler CanonicalAST **156/156** (`wave-b-canonicalast2`), Compiler **344/344** (`wave-b-compiler`). Dump tests no longer require CodeGen success.

---

## ProductionCodeGen `d95-gendefctor2` — generated default ctor GREEN

Prefix **13/13 PASS**. Cutover **5/5** (`d95-gendefctor-cutover`). RED at `d95-gendefctor-red` was execute != 42 (empty generated ctor). Parser `NotifySema`s the class after the identifier, before members, so the first `EnsureGeneratedLifecycle` created a `TRAIT_GENERATED` ctor with no field inits; the later complete-class walk saw `hasCtor` and skipped refill.

GREEN: after WalkDecls, refill the generated ctor body from member `defaultArg` (`Value = 41` → `ActOnAssign` + `SetBody`). `EmitConstructInto` prefers `FindFunc(resolvedDecl)` and FailAt `asNO_FUNCTION` instead of CALL with an empty callee. Execute 42 + `CANONICAL_CODEGEN` + ctor `asBC_WRTV4`.

---

## ProductionCodeGen `d95-handle-null` — host REF GREEN

Prefix **12/12 PASS**. Cutover **5/5** (`d95-handle-cutover`).

`CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes`: host `CObj` REF + `int F() { CObj Obj = nullptr; if (Obj == nullptr) return 42; return 0; }` publishes `int F()`, execute 42, `CANONICAL_CODEGEN`, `asBC_CmpPtrNull`.

Dump at `d95-handle-dump` falsified intern-empty and owner-skip: sealed AST already had `DECL_FUNCTION F` + body; `scriptFunctions` empty. `CObj Obj = null` interned `DeclRef literal=null callee=` (dialect `ttNull` is `nullptr`, not `null`). EmitDeclRef of unresolved `null` FailAt `asAST_VERIFY_DANGLING_ID` (=1). `asCModule::Build()` only treated `r < 0` as failure, so Generate error 1 looked like success and committed nothing. Fixture now uses `nullptr`; Build maps Generate `r != 0` (positive verifier codes → `asERROR`) as fail-closed.

---

## ProductionCodeGen `d95-suspend`

Prefix: **11/11 PASS**. `CanonicalWhileSuspendBuildPublishesCodeGenAndExecutes` execute 42 + `CANONICAL_CODEGEN` + `asBC_SUSPEND`. Existing `EmitWhile` already emitted the opcode; this is the production publisher gate. Cutover after `&out` codegen: **5/5** (`d95-outref-cutover`).

---

## ProductionCodeGen `d95-outref`

Prefix `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`: **10/10 PASS**.

`CanonicalOutRefBuildPublishesCodeGenAndExecutes` (`int OutF(int &out x) { x = 41; return 1; } int F() { int v = 0; OutF(v); return v + 1; }`) RED at `d95-outref-red` (`Value != 42`, no write-back), GREEN with `CANONICAL_CODEGEN`, caller `asBC_PSF`, callee `asBC_WRTV4`.

CodeGen: `EmitAssign` of a reference `DECL_REF` store-through (`PshVPtr` + `PopRPtr` + `WRTV4`).

---

## ProductionCodeGen `d95-inref`

Prefix `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`: **9/9 PASS**.

`CanonicalInRefBuildPublishesCodeGenAndExecutes` (`int InF(int &in x); return InF(41)+1`) executes 42 + `CANONICAL_CODEGEN`, caller bytecode contains `asBC_PSF`, callee contains `asBC_RDR4`. First execute-only assert was a false green (by-value `PshV*`); ABI asserts made RED, then GREEN.

CodeGen: `EmitCall` `PSF`s reference formals; `EmitDeclRef` load-through (`PshVPtr` + `PopRPtr` + `RDR4`) for non-handle references.

---


## Build

`Tools\RunBuild.ps1 -NoXGE -Label d95-green10` from `D:\as-cta`: **exit 0**. Compiled `Module.AngelscriptRuntime.49.cpp` (Sema default-construct VALUE locals).

## ProductionCodeGen `d95-green10`

Prefix `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`: **8/8 PASS**, failed=0.

| Method | Result |
| --- | --- |
| Integer `F()==7` CODEGEN | PASS |
| LEGACY COMPILER | PASS |
| Lambda IIFE execute 42 CODEGEN | PASS |
| Mutable global fail-closed | PASS |
| try/catch fail-closed | PASS |
| Const global execute 42 | PASS |
| Temporary `FValue().Value` execute 42 | PASS |
| Named VALUE local `FValue Object;` execute 42 | PASS (~1ms; was ~300ms at `d95-green9`) |

Named-local GREEN: Sema interned a 0-arg `ActOnConstruct` assign for VALUE locals **without** initializer (`as_sema_stmt.cpp`). CodeGen then hits the same `EmitAssign` → `EmitConstructInto` path as `FNativeCaseValue V(7)`. Did **not** dummy-construct bound `STMT_DECL` slots (that would double-construct initializer forms).

## Cutover `d95-cutover` then `d95-inref-cutover`

Prefix `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover`: **5/5 PASS**, failed=0. Re-run after `&in` GREEN: still **5/5**.

`CanonicalSelectionPublishesValueObjectsFromCodeGen` PASS with `CANONICAL_CODEGEN` (not Compiler).

## Still open (leave `[ ]`)

- 9.5 spec remainder: handles/refs, templates, funcdefs, imports, generated lifecycle, suspend. Next fixture sketch: `attachments/wave-d-95-next-fixture.md` (`&in` execute 42).
- Fifth-pass F1 remainder: empty `functionDecls` still `Build()` success; owner asserts not in live tests. Sketches: `attachments/wave-d-95-f1-next.md`.
- 9.1 / 13.6 detached artifact. 13.2 / 13.3 Sema/identity. 10.2 default CANONICAL. `CompileFunction` stays COMPILER.

## Boxes

9.5 / 13.2 / 13.3 / 10.2 remain `[ ]`.
