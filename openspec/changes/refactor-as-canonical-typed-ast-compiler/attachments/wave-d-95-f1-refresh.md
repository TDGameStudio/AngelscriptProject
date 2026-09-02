# Wave D 9.5 — F1 remainder refresh (after array\<T\> ProductionCodeGen 16/16)

Worktree: `D:\as-cta`. Read-only package **D-95-f1-refresh**.
Do **not** edit `Plugins/`, tests, `tasks.md`, `async-work.md`, `async-dispatch.md`, or `wave-d-95-results.md`.
Do **not** run UBT / `RunBuild` / `RunTests` in this package.
Do **not** add `TEST_METHOD` now.
Do **not** check `tasks.md` 9.5 / 9.1 / 13.6 / 13.2 / 13.3 / 10.2 / 10.4.
Default pipeline stays LEGACY. No Clang/LLVM. No Unreal types in the fork. No script `funcdef` / `@` / `is`.

This file **replaces line numbers and counts** in stale `wave-d-95-f1-next.md` (that file still talks about **8 methods**, collect `2004–2018`, empty-list `2112`, `Commit` `1944–1955`, and expected **10** methods after the pair). Do not implement from those numbers.

Companions: fifth-pass F1 (`reviews/implementation-rereview-2026-08-22-fifth-pass.md`); `async-work.md` §3 / §5; exclusive UBT this wave is **imports**, not F1.

---

## Why F1 is still open after ProductionCodeGen 16/16

Fifth-pass F1: CANONICAL `asCModule::Build()` skips legacy type/function/layout/global/compile stages and requires `asCBytecodeCodeGen::Generate()` to install the full declaration surface or fail-closed. Silent success with missing or mis-owned declarations is the finding.

Live ProductionCodeGen file (`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`): **16** `TEST_METHOD`s. Saved run `d95-array-rdr4` is **16/16**. That does **not** close F1, 9.5, 9.1, or 13.6.

| Live 16/16 method | What it proves | What F1 still needs |
| --- | --- | --- |
| `CanonicalModuleBuildPublishesCodeGenForIntegerReturn` | Non-empty `functionDecls` + CodeGen publisher | Not a declaration-preflight test |
| `LegacyModuleBuildStillPublishesCompiler` | Default stays Compiler | Unrelated |
| `CanonicalConstGlobalBuildPublishesCodeGenAndExecutes` | `const int G = 41;` **plus** `int F()` | `functionDecls` is **not** empty. Does not prove a global-only module |
| `CanonicalValueObjectBuildPublishesCodeGenAndExecutes` | Named `FValue Object;` execute **42** + CodeGen | No `objectType`, no `globalFunctionList` exclusion, no unique `int F()` |
| `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes` | Generated 0-arg ctor write + execute 42 | Different fixture (`int Value = 41;` / no user ctor). Not the user-ctor owner pair |
| `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` | `array<int>` execute 42 | Unrelated to empty-list / ctor-not-global |
| Lambda / temporary / try-catch / mutable-global / `&in` / `&out` / while / handle / host funcdef / script funcdef reject | Other 9.5 slice rows | Not empty-module install; not user-ctor owner |

`tasks.md` 9.5 is the full-language CodeGen sentence. Two extra registry tests are **F1 remainder**, not a 9.5 close.

Import-only module with no `F()` is a **later** F1 method. It is **not** the exclusive UBT import execute-42 row (`CanonicalImportCallBuildPublishesCodeGenAndExecutes` in `wave-d-95-import-impl.md` / `async-work.md` §5). Do not fold import-only into this pair.

---

## Live `Generate()` / `Commit()` (quote today, not fifth-pass / not f1-next)

Fifth-pass claimed collect at `1558–1567` and an empty-list return **before** globals/types. `wave-d-95-f1-next.md` already moved those to ~2004 / 2112 / 1944. Array\<T\> emission grew the file again.

Live file: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`.

### Collect `functionDecls` (2255–2270)

Function-like decls (`CanonicalDeclIsFunctionLike` at 30–36: `FUNCTION` / `METHOD` / `CONSTRUCTOR` / `DESTRUCTOR`) with a body, **every** `FUNCTION` even without a body, every constructor, and non-generated destructors:

```text
2255:	asCArray<const asCDecl*> functionDecls;
2256:	for( asUINT i = 1; i <= context.GetDeclCount(); ++i )
2257:	{
2258:		const asCDecl* decl = context.GetDecl(asASTDeclId(i));
2259:		if( decl == 0 || !CanonicalDeclIsFunctionLike(decl->kind) )
2260:		{
2261:			continue;
2262:		}
2263:		if( decl->body.IsValid()
2264:			|| decl->kind == asAST_DECL_FUNCTION
2265:			|| decl->kind == asAST_DECL_CONSTRUCTOR
2266:			|| (decl->kind == asAST_DECL_DESTRUCTOR && (decl->traits & asAST_TRAIT_GENERATED) == 0) )
2267:		{
2268:			functionDecls.PushLast(decl);
2269:		}
2270:	}
```

Drift vs `wave-d-95-f1-next.md`: collect now also pushes `asAST_DECL_FUNCTION` with **no** body. That does not change a global-only module (`const int G = 41;` has no function-like decl).

### Empty-list path still `Commit` OK after types/globals

There is still **no** `if (functionDecls.GetLength()==0) return asAST_VERIFY_OK` before install. Order today:

1. **2216–2240** — unsealed / `GetDeclCount()==0` / missing module → fail.
2. **2247–2253** — `RegisterCanonicalScriptTypes` (TU-direct `DECL_CLASS` only, 1985–2068) **before** collect.
3. **2255–2270** — collect `functionDecls`.
4. **No** empty-list early return.
5. **2272–2307** — TU-direct `DECL_VAR` → `AllocateGlobalProperty` (`as_module.cpp` 1851–1870 pushes `scriptGlobals` / `scriptGlobalsList`); integer `defaultArg` `atoi` + `isPureConstant = true` (same walk even when `functionDecls` is empty).
6. **2311–2354** — function create/emit loops are **no-ops** when the list is empty.
7. **2356–2364** — `artifact.Commit(module)` then **`return asAST_VERIFY_OK`**.

```text
2356:	const int commit = artifact.Commit(module);
2357:	if( commit < 0 )
2358:	{
2359:		failed = true;
2360:		error = commit;
2361:		DiscardAllocatedGlobals(module, globals);
2362:		return error;
2363:	}
2364:	return asAST_VERIFY_OK;
```

Empty `functionDecls` still succeeds, but **after** TU-direct types/globals, not before. F1 silent-success remains if:

- Build reports 0 with nothing observable (lookup/init miss, `CallInit` zeroing a non-`isPureConstant`, or a module whose only decls are **not** TU-direct `DECL_VAR`/`DECL_CLASS`); or
- unsupported decls (import / funcdef / nested namespace / type-only without a TU-direct class child) are skipped and the module still succeeds.

Production `Build()` (`as_module.cpp` 397–444): CANONICAL parse/seal → `Generate(*pending, this)` → on success `PublishCanonicalASTSnapshot()` then `ResetGlobalVars`. `CallInit` (`as_module.cpp` 530–531 / 545–546) **skips** `isPureConstant`. A poked const that never got `isPureConstant` can still be zeroed after a “successful” Generate.

### `Commit()` skip when `objectType != 0` (2191–2214, skip 2202–2206)

```text
2191:int asSBytecodeCodeGenArtifact::Commit(asCModule* module)
2192:{
2193:	if( module == 0 || module->engine == 0 )
2194:		return asNO_MODULE;
2195:	for( asUINT i = 0; i < functions.GetLength(); ++i )
2196:	{
2197:		asCScriptFunction* func = functions[i];
2198:		if( func == 0 )
2199:			continue;
2200:		func->AddReferences();
2201:		module->scriptFunctions.PushLast(func);
2202:		if( func->objectType == 0 )
2203:		{
2204:			module->globalFunctions.Add(func);
2205:			module->globalFunctionList.PushLast(func);
2206:		}
2207:	}
2208:	module->SetLastBytecodePublisher(asBYTECODE_PUBLISHER_CANONICAL_CODEGEN);
```

Owner bind is **before** Commit, in `FillFunctionSignature` **2115–2148**: METHOD/CTOR/DTOR whose parent is `DECL_CLASS` get `func->objectType`, `beh.construct` / `beh.destruct` / `methods`. If bind misses, `objectType` stays 0 and Commit still publishes the function as a global.

`Commit` with an **empty** `functions` array still sets `CANONICAL_CODEGEN` and returns `asAST_VERIFY_OK`. That is why a global-only module can report CodeGen success without any function.

---

## Two later methods (do not add in this package)

Same class: `FCanonicalASTProductionCodeGenTests`.
File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`.

Keep the live **16** methods. Append these **two**. Expected discovered count **after** the add: **18** (16 current + 2). Do **not** add them now.

Do not weaken `CanonicalValueObjectBuildPublishesCodeGenAndExecutes` execute `42` + `CANONICAL_CODEGEN`.

### 1. `CanonicalConstGlobalOnlyBuildInstallsOrFailsClosed`

Global-only `const int G = 41;` with **no** `F()`. `Build()==0` is allowed only if `G` is installed and readable as `41`. Fail-closed is allowed. Silent success with nothing installed is not.

**Honest prediction on today's codegen: GREEN.**

Why: `functionDecls` is empty, but TU-direct `DECL_VAR` still runs (2272–2307). `AllocateGlobalProperty` pushes `scriptGlobalsList`, so `GetGlobalVarIndexByName("G")` can hit. Integer `defaultArg` is `atoi`’d to 41 and `isPureConstant = true`. `CallInit` skips that poke. Empty `Commit()` still stamps `CANONICAL_CODEGEN`. The existing 16/16 method `CanonicalConstGlobalBuildPublishesCodeGenAndExecutes` already proves the same install **with** `int F()`; this method only removes `F()`.

Keep it as an F1 **regression** either way. GREEN here closes empty-skip-before-globals **only** for TU-direct `const int G`. It does **not** close whole-module preflight for import / funcdef / type-only / nested namespace.

```cpp
	TEST_METHOD(CanonicalConstGlobalOnlyBuildInstallsOrFailsClosed)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("production default must stay LEGACY until Wave G")));
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("global-only F1 fixture selects CANONICAL")));

		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			const int G = 41;
			)AS");
		const int BuildResult = AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdConstGlobalOnly",
			ScriptSource.c_str(),
			Module);

		bool bGReadable = false;
		if (BuildResult == 0 && Module != nullptr)
		{
			const int Index = Module->GetGlobalVarIndexByName("G");
			if (Index >= 0)
			{
				int* const Address = static_cast<int*>(Module->GetAddressOfGlobalVar(static_cast<asUINT>(Index)));
				bGReadable = Address != nullptr && *Address == 41;
			}
			ASSERT_THAT(IsTrue(bGReadable,
				TEXT("CANONICAL global-only Build()==0 is forbidden unless G is installed and readable as 41")));
			ASSERT_THAT(AreEqual(
				asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
				static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
				TEXT("successful global-only install must be CodeGen, not asCCompiler")));
		}
		else
		{
			ASSERT_THAT(IsTrue(BuildResult < 0,
				TEXT("fail-closed is allowed when G cannot be installed")));
			if (Module != nullptr)
			{
				ASSERT_THAT(IsTrue(
					static_cast<asCModule*>(Module)->GetLastBytecodePublisher() != asBYTECODE_PUBLISHER_COMPILER,
					TEXT("rejected global-only module must not claim asCCompiler publication")));
			}
		}
	}
```

Exact script:

```as
const int G = 41;
```

Exact asserts:

- Default engine pipeline is still `asCOMPILER_PIPELINE_LEGACY`.
- `BuildResult == 0` **implies** `GetGlobalVarIndexByName("G") >= 0` and `*GetAddressOfGlobalVar == 41` and publisher `CANONICAL_CODEGEN`.
- `BuildResult < 0` is allowed; if `Module != nullptr`, publisher ≠ `COMPILER`.
- Do **not** assert `BuildResult == 0` unconditionally (that would forbid honest fail-closed).
- Do **not** add `int F()`.

### 2. `CanonicalValueObjectCtorIsOwnedAndNotGlobal`

Same live `FValue` fixture as `CanonicalValueObjectBuildPublishesCodeGenAndExecutes`. Keep execute `42`. Add owner/registry asserts fifth-pass F1 required and 16/16 still omit on the **user-ctor** module.

**Honest prediction on today's codegen: GREEN.**

Why: `FillFunctionSignature` 2115–2148 binds the user ctor `objectType` to TU-direct `FValue` from `RegisterCanonicalScriptTypes`. `Commit` 2202–2206 then **skips** `globalFunctions` / `globalFunctionList`. Live 16/16 already executes this exact script as 42 via CodeGen; `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes` already asserts a ctor behaviour on `FValue` for the **generated** case. Bind miss would still publish the ctor as a global (F1 corruption); that miss is not expected on this TU-direct user ctor.

Keep execute 42. Do **not** replace this method with fail-closed. Keep it as an F1 **regression** either way. GREEN here covers `Commit()` owner skip for this ctor only.

```cpp
	TEST_METHOD(CanonicalValueObjectCtorIsOwnedAndNotGlobal)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("production default must stay LEGACY until Wave G")));
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("value-object owner fixture selects CANONICAL")));

		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			struct FValue
			{
				int Value;
				FValue()
				{
					Value = 41;
				}
			}

			int F()
			{
				FValue Object;
				return Object.Value + 1;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdValueOwner",
			ScriptSource.c_str(),
			Module),
			TEXT("CANONICAL value-object Build must succeed from CodeGen, not fail closed")));

		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptNativeTestSupport::CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 42,
			TEXT("do not weaken FValue Object execute 42")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("CANONICAL value-object Build must not record asCCompiler")));

		asCModule* const ScriptModule = static_cast<asCModule*>(Module);
		asIScriptFunction* const GlobalF = Module->GetFunctionByDecl("int F()");
		ASSERT_THAT(IsTrue(GlobalF != nullptr,
			TEXT("int F() must be the unique global lookup")));
		int32 FMatches = 0;
		for (asUINT Index = 0; Index < ScriptModule->globalFunctionList.GetLength(); ++Index)
		{
			asCScriptFunction* const Func = ScriptModule->globalFunctionList[Index];
			if (Func != nullptr && Func->name == "F"
				&& Func->objectType == 0
				&& Func->parameterTypes.GetLength() == 0)
			{
				++FMatches;
			}
		}
		ASSERT_THAT(AreEqual(1, FMatches,
			TEXT("GetFunctionByDecl(\"int F()\") must be unique on the global list")));
		ASSERT_THAT(IsTrue(static_cast<asCScriptFunction*>(GlobalF)->objectType == 0,
			TEXT("int F() stays a module global, not a member")));

		asCObjectType* ObjectType = nullptr;
		for (asUINT Index = 0; Index < ScriptModule->classTypes.GetLength(); ++Index)
		{
			asCObjectType* const Candidate = ScriptModule->classTypes[Index];
			if (Candidate != nullptr && Candidate->name == "FValue")
			{
				ObjectType = Candidate;
				break;
			}
		}
		ASSERT_THAT(IsTrue(ObjectType != nullptr,
			TEXT("FValue must be installed as a module class type")));

		asCScriptFunction* Ctor = nullptr;
		if (ObjectType->beh.construct > 0
			&& static_cast<asUINT>(ObjectType->beh.construct) < ScriptEngine->scriptFunctions.GetLength())
		{
			Ctor = ScriptEngine->scriptFunctions[ObjectType->beh.construct];
		}
		ASSERT_THAT(IsTrue(Ctor != nullptr,
			TEXT("FValue 0-arg ctor must be bound on objectType->beh.construct")));
		ASSERT_THAT(IsTrue(Ctor->objectType == ObjectType,
			TEXT("ctor objectType must be FValue, not null / default namespace global")));

		bool bCtorOnGlobalList = false;
		for (asUINT Index = 0; Index < ScriptModule->globalFunctionList.GetLength(); ++Index)
		{
			if (ScriptModule->globalFunctionList[Index] == Ctor)
			{
				bCtorOnGlobalList = true;
				break;
			}
		}
		ASSERT_THAT(IsFalse(bCtorOnGlobalList,
			TEXT("ctor must not appear in module globalFunctionList")));
	}
```

Exact script (same as the live FValue fixture; do not drop the local or the `+ 1`):

```as
struct FValue
{
	int Value;
	FValue()
	{
		Value = 41;
	}
}

int F()
{
	FValue Object;
	return Object.Value + 1;
}
```

Exact asserts:

- Execute `F()==42` and publisher `CANONICAL_CODEGEN` (do **not** weaken).
- `GetFunctionByDecl("int F()")` non-null; exactly one `name=="F"` with `objectType==0` and no parameters on `globalFunctionList`.
- `FValue` in `classTypes`; ctor `objectType` set to that type via `beh.construct`.
- That ctor pointer is **not** in `globalFunctionList`.

Do not assert generated `GetValue` as a global (out of this minimal pair). Includes: existing `as_module.h` / `as_scriptengine.h` already pull `asCObjectType` / `asCScriptFunction`. If a later compile needs `as_objecttype.h`, add that include in the test file only — not Unreal types in the fork.

---

## What is still fail-open vs already installed

Already installed (do not redo as CodeGen work for this pair):

- TU-direct const integer VAR: allocate + `atoi` + `isPureConstant` even when `functionDecls` is empty.
- TU-direct `DECL_CLASS` type register before collect.
- METHOD/CTOR/DTOR `objectType` bind + `Commit` skip when `objectType != 0`.
- Empty-list no longer returns OK **before** types/globals (fifth-pass line numbers are dead).

Still fail-open (F1 not closed):

- No whole-module declaration preflight. Unsupported kinds can be skipped.
- Empty `functionDecls` still **Commit OK** (2356–2364) after the TU-direct walks.
- Nested namespace / import-only / funcdef-only / type-only without TU-direct class child have no production install-or-fail tests.
- Bind miss still publishes members as globals.
- Artifact still mutates Engine/module during emit (9.1 / 13.6).
- Live 16/16 never asserts user-ctor ownership or “not a global”.

Adding these two tests later, whether GREEN or RED, **does not close 9.5 / 9.1 / 13.6**.

---

## Later verification (not this package)

From `D:\as-cta` only, after the two methods are added. Always `-NoXGE` after touching tests. Timeout ≤ `600000`.

If both methods behave as predicted GREEN, label **`d95-f1`**. If either is RED, label **`d95-f1-red`**.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-f1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-f1 -TimeoutMs 600000
```

RED-if-needed twin (same prefix; use only if a method fails):

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-f1-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-f1-red -TimeoutMs 600000
```

Expect **18** discovered methods (16 current + 2). Predicted: existing 16 PASS + these 2 PASS. If method 1 is RED, TU-direct const VAR install or `CallInit` skip is broken for empty `functionDecls`. If method 2 is RED, `objectType` bind or `Commit` skip missed this ctor. Either GREEN still leaves **9.5 / 9.1 / 13.6 `[ ]`**.

Do not start this add while exclusive UBT owns ProductionCodeGen + `as_bytecode_codegen.cpp` for imports (`async-work.md` §5 / `async-dispatch.md`). Import-only module without `F()` stays a later F1 method, not the import execute-42 row.

Fix order if RED exists: keep `objectType` bind + `Commit` skip; do not publish methods/ctors as globals; do not flip default CANONICAL. Whole-module preflight remains a later F1 slice even if both tests are GREEN.

---

## Hard constraints

- Leave `tasks.md` **9.5 / 9.1 / 13.6** (and 13.2 / 13.3 / 10.2 / 10.4) unchecked. Do not mark 9.5 from these tests existing or going green.
- Default `ep.canonicalCompilerPipeline` stays LEGACY (Wave G forbidden).
- No Clang/LLVM link.
- No Unreal types in `as_bytecode_codegen*` / `as_sema*` / `as_ast_*`.
- No script `funcdef` / `@` / `is`.
- `CompileFunction` may stay `COMPILER` (F2; not this pair).
- Do not start handles / `&in` / `array<T>` / host funcdef / imports / suspend in this F1 pair (already in 16/16 or queued elsewhere).
- This attachment is not an implementation license to edit the fork.
- F1 is **not** closed. 9.5 is **not** closed.
