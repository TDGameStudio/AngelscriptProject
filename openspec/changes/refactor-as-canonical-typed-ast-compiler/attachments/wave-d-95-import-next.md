# Wave D 9.5 — next ProductionCodeGen fixture (imports)

Worktree: `D:\as-cta`. Read-only package **D-95-import-next**.
Did not edit `Plugins/`, tests, `tasks.md`, `async-work.md`, or `async-dispatch.md`.
Did not run UBT / `RunBuild` / `RunTests`. Did not check `tasks.md` 9.5.

Exclusive UBT is adding `array<T>` now (`CanonicalArrayIntBuildPublishesCodeGenAndExecutes`). Do **not** start this method until that array fixture is GREEN.

Live ProductionCodeGen file: **15 methods**, all GREEN (`d95-funcdef`). Landed — do not redo: handle, generated default ctor, host funcdef, `&in`/`&out`, `SUSPEND`, lambda, value object, const global, try/catch reject, mutable-global reject, script `funcdef` reject, integer routing, LEGACY control.

Even 17/17 (array + this) does **not** close `tasks.md` 9.5.
Default pipeline stays LEGACY. No script `funcdef` / `@` / `is`. No `dictionary`.

---

## Chosen next method

**`CanonicalImportCallBuildPublishesCodeGenAndExecutes`**

Honest language is **execute `42` + `CANONICAL_CODEGEN`**, not fail-closed. Import is not dialect-rejected (`try`/`catch`, mutable globals, script `funcdef` are). LEGACY already executes the same bind table (`asBC_CALLBND`). Sema already seals `route=import`. Current CodeGen `FailAt(..., asNO_MODULE)` is the TDD RED, not a GREEN bar.

Provider:

```angelscript
int SharedValue()
{
	return 41;
}
```

Consumer:

```angelscript
import int SharedValue() from "ProdImportProvider";

int F()
{
	return SharedValue() + 1;
}
```

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`

---

## Two-module setup (match live helpers)

Same helpers as Sema dump and Module import tests:

- Provider: `FScopedNativeModule` (`AngelscriptNativeCoreTestSupport.h:631`) — same shape as `ImportCallKeepsImportRouteDistinctFromGlobal` (`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:852`) and `BindImportedFunctionExecutesProvider` (`AngelscriptNativeModuleImportTests.cpp:104`).
- Consumer: `CompileNativeModule` (`AngelscriptNativeCoreTestSupport.h:399`) like every other ProductionCodeGen method, not `FScopedNativeModule` (that helper treats `Build()<0` as “invalid module” without a publisher assert).
- Bind: `Consumer->BindImportedFunction(0, Provider->GetFunctionByDecl("int SharedValue()"))` (`as_module.cpp:1649`). Do not skip bind and hope emit looked up the provider `asFUNC_SCRIPT` id.
- Execute: `CanonicalExecuteInt(..., "int F()", Value)` then `Value == 42`.

`SetCompilerPipeline(CANONICAL)` **before** the provider so both modules use CodeGen. `int SharedValue() { return 41; }` is already the integer ProductionCodeGen slice.

Do **not** copy SemaAuthority `LocalValue()` / `Entry()` / `return 77`. That dump is seal-only (`DumpSealedCanonicalAst` at `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:66` calls `Module->Build()` and dumps even when Generate fails). Do **not** copy VM-matrix `CleanupDestructionExceptionsImportsAndGlobals` (`AngelscriptNativeCanonicalASTVmMatrixTests.cpp:285`): default pipeline LEGACY, execute `81`, not this prefix.

---

## Why this is not 9.5 close

`tasks.md` 9.5 still needs generated accessors / dtor / list factory (and capturing closures / F1 remainder). This row only covers **imported call execute + publisher**.

SemaAuthority `ImportCallKeepsImportRouteDistinctFromGlobal` (`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:842`) proves dump `kind=Import`, `origin=CanonicalASTSemaImportProvider`, `callee=SharedValue()`, `route=import` (`as_ast_dump.cpp:214`). It is not execute-42 and not `CANONICAL_CODEGEN`.

9.4 “import call lowering” is isolated / sealed, not this production gate.

---

## What CodeGen must FailAt vs emit (no CALL-without-callee)

Today:

- CANONICAL `asCModule::Build()` (`as_module.cpp:397`) parse/seal → `Generate()` and **never** `RegisterNonTypesFromScript` / `RegisterImportedFunction` (`as_builder.cpp:1465`, `6271`). `bindInformations` stays empty (`GetImportedFunctionCount` at `as_module.cpp:986` is that array).
- `CanonicalDeclIsFunctionLike` (`as_bytecode_codegen.cpp:30`) is FUNCTION/METHOD/CTOR/DTOR only — **not** `asAST_DECL_IMPORT`.
- Collect (`as_bytecode_codegen.cpp:2059`) therefore never installs an import slot. `Commit()` (`as_bytecode_codegen.cpp:1995`) only `scriptFunctions` / `globalFunctions` + publisher; no `AddImportedFunction` (`as_module.cpp:1548`).
- `FindFunc` (`as_bytecode_codegen.cpp:454`) walks CodeGen `binds` only.
- `EmitCall` (`as_bytecode_codegen.cpp:1359`): miss → generated-Get property path, else `FindSlot`, else **`FailAt(__LINE__, asNO_MODULE)`** (`as_bytecode_codegen.cpp:1403`). No `asBC_CALLBND`. If `callee` is non-null it emits `CALL` / `CALLSYS` (`as_bytecode_codegen.cpp:1442`); if only a slot, `CallPtr`. There is **no** `asFUNC_IMPORTED` branch (legacy does `asBC_CALLBND` at `as_compiler.cpp:22240`; VM reads `importedFunctions[i & ~FUNC_IMPORTED]->boundFunctionId` at `as_context.cpp:2604`; slot ids from `GetNextImportedFunctionId` at `as_module.cpp:1436`, `FUNC_IMPORTED = 0x40000000` in `as_module.h:56`).
- Import-only module (no `F()`): empty `functionDecls`, still `artifact.Commit` + `return asAST_VERIFY_OK` (`as_bytecode_codegen.cpp:2160`). Fifth-pass F1 empty-Commit-OK. **Not this method** (this method has `int F()` so emit hits `EmitCall`).

GREEN emit:

1. For each TU `asAST_DECL_IMPORT`, `AddImportedFunction(GetNextImportedFunctionId(), name, signature, origin)` so `GetImportedFunctionCount()==1` and `GetImportedFunctionSourceModule(0)=="ProdImportProvider"`.
2. Bind that import decl id so `FindFunc` (or a dedicated import lookup) returns the `asFUNC_IMPORTED` signature, **not** a same-module global.
3. `EmitCall` on `resolvedDecl.kind == asAST_DECL_IMPORT` emits **`asBC_CALLBND` with the import id** (`id & FUNC_IMPORTED`). Arguments still reverse-formal.
4. Missing import slot / missing origin / `FindFunc` miss: **`FailAt(..., asNO_MODULE)` or `asNOT_SUPPORTED` or `asNO_FUNCTION`**. Never `bc.Call(asBC_CALL, 0, ...)`. Never CALL the provider `asFUNC_SCRIPT` id at emit time (that skips the bind table). Never treat `SharedValue` as a consumer global.

If `CompileNativeModule != 0`: valid **RED** only if publisher ≠ `COMPILER`. Do not execute. Do not rewrite the test into a reject fixture.

If Build succeeds but `GetImportedFunctionCount()==0`, no `CALLBND`, or execute ≠ 42 (unbound → `TXT_UNBOUND_FUNCTION`, or CallPtr/CALL-without-callee): language RED. Do not drop execute 42. Do not drop `BindImportedFunction`.

---

## Exact TEST_METHOD constraints

Add after `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` (in-flight array row). If that method is not in the file yet, wait — do not land import ahead of array. Still inside `FCanonicalASTProductionCodeGenTests`. Tabs. `FNativeTestEngine`. Default pipeline assert LEGACY, then `SetCompilerPipeline(CANONICAL)`. `ASTEST_AS_ANSI`. `CanonicalExecuteInt`. Publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Keep “`int F()` is actually published”.

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

Host `Register*`: **none**.

Later F1 (not this package): import-only module with no `F()` must not `Build()==0` with `GetImportedFunctionCount()==0`.

---

## Later commands (from `D:\as-cta`)

New `TEST_METHOD` requires a rebuild. Always `-NoXGE` after touching tests or codegen.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-import
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-import -TimeoutMs 600000
```

Expect **17 methods** once array is in the file. Do not mark `tasks.md` 9.5.

do not check tasks.md 9.5.
