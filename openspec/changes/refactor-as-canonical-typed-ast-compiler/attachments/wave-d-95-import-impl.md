# Wave D 9.5 — exclusive UBT: production import CALLBND

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. If Build/execute is unexpected, use superpowers:systematic-debugging before guessing. Do not claim PASS without `Saved\Tests` evidence.

**Goal:** CANONICAL `asCModule::Build()` of a two-module import consumer publishes `int F()` from `asCBytecodeCodeGen`, binds the import slot, executes `42`, and emits `asBC_CALLBND`.

**Architecture:** Sema already seals `asAST_DECL_IMPORT` with `origin` and `route=import`. CodeGen currently never installs `bindInformations` and `EmitCall` miss-paths to `FailAt(..., asNO_MODULE)`. Install the import slot during `Generate()`, bind the decl id to the `asFUNC_IMPORTED` signature, and emit `CALLBND` with the import id (`id & FUNC_IMPORTED`). Never CALL the provider `asFUNC_SCRIPT` id at emit time.

**Tech stack:** maintained AngelScript fork (`as_bytecode_codegen.cpp`, `as_module.cpp` APIs already exist), Native SDK CQTest ProductionCodeGen prefix, `FNativeTestEngine` / `FScopedNativeModule` / `CompileNativeModule`.

## Global Constraints

- Worktree: `D:\as-cta` only. `Set-Location D:\as-cta` before every command.
- Dual-repo: plugin submodule `Plugins/Angelscript` first if you commit (do **not** commit unless asked).
- Commands: only `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1`. Always `-NoXGE` after new tests.
- One UBT mutex. Do not start a second build.
- Default pipeline stays `LEGACY`. `Ready()` stays a binary capability.
- No Unreal types in frontend fork files. No Clang/LLVM link.
- No script `funcdef` / `@` / `is`. No `dictionary`.
- Never CALL-without-callee. Missing slot → `FailAt(..., asNO_MODULE | asNO_FUNCTION | asNOT_SUPPORTED)`.
- Do **not** check `tasks.md` 9.5 / 9.1 / 13.2 / 13.3 / 13.6 / 10.2 / 10.4.
- Do not start accessors / dtor / list factory / F1 empty-module / CompileFunction CANONICAL / Wave E–G.
- Do not archive.

---

## Files

- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` — add `CanonicalImportCallBuildPublishesCodeGenAndExecutes` after the array method.
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` — install `asAST_DECL_IMPORT` slots; `EmitCall` `asFUNC_IMPORTED` → `asBC_CALLBND`.
- Read: `attachments/wave-d-95-import-next.md` (fixture + false greens).
- Read: existing helpers `FScopedNativeModule` (`AngelscriptNativeCoreTestSupport.h:631`), `CompileNativeModule`, `CanonicalExecuteInt`, `ContainsOpcode`.
- Do not edit `as_compiler.cpp` to “fix” this. LEGACY already emits `CALLBND` at `as_compiler.cpp:22240`.
- Optional note only: prepend `attachments/wave-d-95-results.md`; patch `async-dispatch.md` landed row. Leave 9.5 `[ ]`.

## Interfaces

- Consumes: `asCModule::GetNextImportedFunctionId()`, `AddImportedFunction(...)`, `BindImportedFunction` (test-side), `FUNC_IMPORTED = 0x40000000`.
- Consumes: sealed `asCDecl` `kind=asAST_DECL_IMPORT`, `name`, `origin` (module string without quotes), `type` return, `children` `DECL_PARAM`.
- Produces: consumer `bindInformations` length 1; CodeGen `binds[]` maps import decl id → `asFUNC_IMPORTED` signature; `F()` bytecode `asBC_CALLBND`.

---

### Task 1: Write the failing production test <!-- TDD -->

**Files:** ProductionCodeGen tests only.

- [ ] **Step 1: Add `CanonicalImportCallBuildPublishesCodeGenAndExecutes`**

Use the exact method in `wave-d-95-import-next.md` (lines 99–164). Constraints:

- Same class `FCanonicalASTProductionCodeGenTests`. Tabs.
- Assert default pipeline LEGACY, then `SetCompilerPipeline(CANONICAL)` **before** the provider.
- Provider: `FScopedNativeModule` `"ProdImportProvider"` / `int SharedValue() { return 41; }`.
- Consumer: `CompileNativeModule` `"ProdImportConsumer"` — **not** `FScopedNativeModule` (that helper hides publisher).
- Assert `GetImportedFunctionCount()==1`, `BindImportedFunction(0, provider SharedValue)`, execute `F()==42`, publisher `CANONICAL_CODEGEN`, opcode `asBC_CALLBND`.
- Host `Register*`: **none**.
- Do not copy SemaAuthority `LocalValue`/`Entry`/`return 77`.
- Keep the existing 16 methods untouched.

```cpp
	TEST_METHOD(CanonicalImportCallBuildPublishesCodeGenAndExecutes)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("production default must stay LEGACY until Wave G")));
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("import fixture selects CANONICAL")));

		FScopedNativeModule Provider(
			*TestRunner,
			Engine,
			"ProdImportProvider",
			ASTEST_AS_ANSI(R"AS(
				int SharedValue()
				{
					return 41;
				}
			)AS"));
		ASSERT_THAT(IsTrue(Provider.IsValid(), TEXT("CANONICAL import provider must compile")));

		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			import int SharedValue() from "ProdImportProvider";

			int F()
			{
				return SharedValue() + 1;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, CompileNativeModule(
			Engine.Get(),
			"ProdImportConsumer",
			ScriptSource.c_str(),
			Module),
			TEXT("CANONICAL import consumer Build must succeed from CodeGen")));
		asIScriptFunction* const Published = GetNativeFunctionByDecl(Module, "int F()");
		ASSERT_THAT(IsNotNull(
			Published,
			*FString::Printf(
				TEXT("CANONICAL import consumer must publish int F(); have {%s}"),
				*CollectFunctionDeclarations(Module))));
		ASSERT_THAT(AreEqual(1u, Module->GetImportedFunctionCount(),
			TEXT("consumer must install one asFUNC_IMPORTED slot, not skip DECL_IMPORT")));
		asIScriptFunction* const Shared = Provider->GetFunctionByDecl("int SharedValue()");
		ASSERT_THAT(IsNotNull(Shared, TEXT("provider must expose int SharedValue()")));
		ASSERT_THAT(AreEqual(0, Module->BindImportedFunction(0, Shared),
			TEXT("imported function must bind to the provider")));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 42,
			TEXT("CANONICAL import F() must execute SharedValue()+1 from CodeGen")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("CANONICAL import Build must not record asCCompiler")));
		ASSERT_THAT(IsTrue(
			AngelscriptCompilerBytecodeTestSupport::ContainsOpcode(Published, asBC_CALLBND),
			TEXT("F() must emit CALLBND, not CALL/CallPtr without an import slot")));
	}
```

- [ ] **Step 2: Rebuild and prove RED**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-import-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-import-red -TimeoutMs 600000
```

Expected: **16/17** (or 16 PASS + 1 FAIL). Honest RED:

- `CompileNativeModule != 0` with publisher ≠ `COMPILER` (today `EmitCall` `FailAt` `asNO_MODULE` at `as_bytecode_codegen.cpp:1567`), **or**
- Build succeeds with `GetImportedFunctionCount()==0` / no `CALLBND` / execute ≠ 42.

If Build fails, **do not execute**. Do **not** rewrite the method into a reject fixture. Do not drop execute 42.

If the new method is already GREEN: stop and write why (that would mean someone already installed imports — verify `CALLBND` and slot count before claiming).

---

### Task 2: Install import slots in `Generate()` <!-- TDD -->

**Files:** `as_bytecode_codegen.cpp` `Generate()` after TU-direct globals (`~2307`), before function emit.

- [ ] **Step 3: Walk `asAST_DECL_IMPORT` and call `AddImportedFunction`**

For every decl with `kind == asAST_DECL_IMPORT` (walk `GetDeclCount()`, not only TU-direct children if nested — but the fixture is TU-direct):

1. Missing `origin` → `FailAt` / `error = asNO_MODULE`, Abandon, return. Never succeed with an empty origin.
2. `id = module->GetNextImportedFunctionId()`.
3. Resolve return type from `decl->type` via `bridge.Resolve`. Invalid → `asINVALID_TYPE` / `asNO_FUNCTION`.
4. Collect `DECL_PARAM` children into `parameterTypes` / `inOutFlags` / empty defaultArgs (same loop as `FillFunctionSignature`).
5. `module->AddImportedFunction(id, decl->name, returnType, params, inOutFlags, defaultArgs, module->defaultNamespace, decl->origin)`.
6. Bind `asSCodeGenFuncBind { decl->id, module->GetImportedFunction(module->GetImportedFunctionCount()-1) }` into `binds` so `FindFunc(resolvedDecl)` hits the **imported signature**, not a consumer global and not the provider script function.

Do **not** push the imported signature onto `artifact.functions` (`Commit()` would treat it as a script function).

Do **not** collect IMPORT into `functionDecls` (no body to emit).

- [ ] **Step 4: Rebuild/re-run.** RED may move from Build-fail to `GetImportedFunctionCount()==1` but execute `TXT_UNBOUND_FUNCTION` or missing `CALLBND` if `EmitCall` still CALLs/CallPtrs. That is progress. Keep execute 42.

---

### Task 3: `EmitCall` emits `asBC_CALLBND` <!-- TDD -->

**Files:** `as_bytecode_codegen.cpp` `EmitCall` around `1632–1642`.

- [ ] **Step 5: Branch on `asFUNC_IMPORTED` before `CALL`/`CALLSYS`**

Today:

```cpp
if( callee )
{
    if( callee->funcType == asFUNC_SYSTEM )
        bc.Call(asBC_CALLSYS, callee->id, pop);
    else
        bc.Call(asBC_CALL, callee->id, pop);
}
```

Required:

```cpp
if( callee )
{
    if( callee->funcType == asFUNC_IMPORTED )
        bc.Call(asBC_CALLBND, callee->id, pop);
    else if( callee->funcType == asFUNC_SYSTEM )
        bc.Call(asBC_CALLSYS, callee->id, pop);
    else
        bc.Call(asBC_CALL, callee->id, pop);
}
```

`callee->id` from `GetNextImportedFunctionId()` already has `FUNC_IMPORTED`. VM reads `importedFunctions[i & ~FUNC_IMPORTED]->boundFunctionId` (`as_context.cpp:2604`).

If `resolvedDecl.kind == asAST_DECL_IMPORT` but `FindFunc` missed: keep `FailAt(..., asNO_MODULE)`. Never `bc.Call(asBC_CALL, 0, ...)`.

Reverse-formal argument order stays as today. Import `SharedValue()` has zero formals.

- [ ] **Step 6: Rebuild and prove GREEN**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-import
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-import -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label d95-import-cutover -TimeoutMs 600000
```

Expected: ProductionCodeGen **17/17**, Cutover **5/5**. Quote `Saved\Tests\d95-import\...\Summary.json`.

If execute ≠ 42 after `CALLBND`: check bind index 0, origin string `ProdImportProvider` (quotes stripped), signature match (`int`/`int` no params). Do not skip `BindImportedFunction`.

---

### Task 4: Record, do not close 9.5

- [ ] **Step 7: Prepend `wave-d-95-results.md`** with 17/17 GREEN + remaining 9.5 rows (accessors/dtor/list factory/F1).
- [ ] **Step 8: Patch `async-dispatch.md`** D-95-import row to **landed**. Next exclusive UBT: generated accessors (`wave-d-95-lifecycle-next.md`). Use live count 17, ignore that file’s stale “15 methods”.
- [ ] **Step 9: Patch `tasks.md` 9.5 why-open** to mention 17/17 import GREEN if that is true. Box stays `[ ]`.
- [ ] **Step 10: Do not commit. Do not archive. Do not flip default CANONICAL.**

---

## False greens (reject these)

- Dump `route=import` / SemaAuthority 128/128.
- `CALL` of provider `asFUNC_SCRIPT` id (skips the bind table; execute 42 is still a lie for this row).
- `CallPtr` without an import slot.
- Consumer global named `SharedValue`.
- Dropping execute 42 or `GetImportedFunctionCount`.
- Checking 9.5.

## Hard no

CALL-without-callee. Wave G default CANONICAL. Script `funcdef` / `@` / `is`. Second UBT in `D:\as-cta`. Editing main workspace `D:\Workspace\AngelscriptProject` instead of `D:\as-cta`.
