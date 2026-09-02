# Wave D 9.5 — F1 remainder RED (after named VALUE local GREEN)

Worktree: `D:\as-cta`. Read-only package **D-95-f1-next**.
Do **not** edit `Plugins/`, tests, `tasks.md`, or fork source.
Do **not** run UBT / `RunBuild` / `RunTests` in this package.
Do **not** check `tasks.md` 9.5 / 9.1 / 13.2 / 13.3 / 10.2 (or 13.6 / 10.4).
Default pipeline stays LEGACY. No Clang/LLVM. No Unreal types in the fork. No script `funcdef` / `@` / `is`.

Later implementer: add the two methods below to
`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
Do not weaken `CanonicalValueObjectBuildPublishesCodeGenAndExecutes` execute `42` + `CANONICAL_CODEGEN`.
Do not mark 9.5 from these RED tests existing, from 8/8, or from these two later going green.

---

## Why F1 is still open after ProductionCodeGen 8/8

Fifth-pass F1 (`reviews/implementation-rereview-2026-08-22-fifth-pass.md`): CANONICAL `asCModule::Build()` skips legacy type/function/layout/global/compile stages and requires `asCBytecodeCodeGen::Generate()` to install the full declaration surface or fail-closed. Silent success with missing or mis-owned declarations is the finding.

Live file: **8 methods**. `d95-green9` was **7/8** (named `FValue Object;` execute hole). Named-local GREEN makes that execute-42 slice 8/8. That still does not close F1:

| 8/8 method | What it proves | What F1 still needs |
| --- | --- | --- |
| Integer `int F() { return 7; }` | Non-empty `functionDecls` + CodeGen publisher | Not a declaration-preflight test |
| LEGACY control | Default stays Compiler | Unrelated |
| `CanonicalConstGlobalBuildPublishesCodeGenAndExecutes` | `const int G = 41;` **plus** `int F()` | `functionDecls` is **not** empty. Does not prove a global-only module |
| Value-object / temporary | Execute 42 + CodeGen publisher | No `objectType`, no `globalFunctionList` exclusion, no unique `int F()` |
| Lambda IIFE / try-catch / mutable-global | Other 9.5 slice rows | Not empty-module install; not ctor owner |

`tasks.md` 9.5 is the full-language CodeGen sentence (handles/refs, templates, delegates/funcdefs, lambdas/closures, globals/**imports**, generated lifecycle/accessors/list factory, exception/suspend). Two extra registry tests are F1 remainder, **not** a 9.5 close.

Partly landed (do not redo as the exclusive named-local slice):

- `FillFunctionSignature` binds METHOD/CTOR/DTOR `func->objectType` and `beh.construct` / `methods` (`as_bytecode_codegen.cpp` 1864–1897).
- `Commit()` skips `globalFunctions` / `globalFunctionList` when `func->objectType != 0` (1944–1955).

Still open:

- No whole-module declaration preflight.
- Empty `functionDecls` still **succeeds** (`Generate` returns `asAST_VERIFY_OK` at 2112).
- Nested namespace / import / funcdef / type-only / generated-lifecycle still have no production install-or-fail tests.
- Artifact still mutates Engine/module during emit (9.1 / 13.6).
- Live tests never assert ctor ownership or “not a global”.

---

## Current `Generate()` / `Commit()` (quote live lines, not fifth-pass numbers)

Fifth-pass claimed collect at `1558–1567` and an empty-list return **before** globals/types. Those line numbers have drifted. Live `as_bytecode_codegen.cpp`:

**Collect** (2004–2018) — function-like decls with a body, every constructor, and non-generated destructors:

```text
asCArray<const asCDecl*> functionDecls;
for( asUINT i = 1; i <= context.GetDeclCount(); ++i )
{
    const asCDecl* decl = context.GetDecl(asASTDeclId(i));
    if( decl == 0 || !CanonicalDeclIsFunctionLike(decl->kind) )
        continue;
    if( decl->body.IsValid()
        || decl->kind == asAST_DECL_CONSTRUCTOR
        || (decl->kind == asAST_DECL_DESTRUCTOR && (decl->traits & asAST_TRAIT_GENERATED) == 0) )
    {
        functionDecls.PushLast(decl);
    }
}
```

`CanonicalDeclIsFunctionLike` (30–36): `FUNCTION` / `METHOD` / `CONSTRUCTOR` / `DESTRUCTOR`.

**Empty `functionDecls` does not early-return OK before installing globals/types.** Order is:

1. 1971–1988 — unsealed / `GetDeclCount()==0` / missing module → fail.
2. 1996–2002 — `RegisterCanonicalScriptTypes` (TU-direct `DECL_CLASS` only) **before** collect.
3. 2004–2018 — collect `functionDecls`.
4. **No** `if (functionDecls.GetLength()==0) return asAST_VERIFY_OK`.
5. 2020–2055 — TU-direct `DECL_VAR` → `AllocateGlobalProperty`; integer `defaultArg` `atoi` + `isPureConstant` (same walk even when `functionDecls` is empty).
6. 2059–2102 — function loops are no-ops when the list is empty.
7. 2104–2112 — `artifact.Commit(module)` then **`return asAST_VERIFY_OK`**.

So empty `functionDecls` still returns OK, but **after** TU-direct types/globals, not before. F1 silent-success remains if:

- Build reports 0 with nothing observable (lookup/init miss, `CallInit` zeroing a non-`isPureConstant`, or a module whose only decls are not TU-direct `DECL_VAR`/`DECL_CLASS`); or
- unsupported decls (import / funcdef / nested namespace / type-only without class child) are skipped and the module still succeeds.

**`Commit()`** (1944–1955) — F1 owner-install **partly** landed:

```text
func->AddReferences();
module->scriptFunctions.PushLast(func);
if( func->objectType == 0 )
{
    module->globalFunctions.Add(func);
    module->globalFunctionList.PushLast(func);
}
```

If `objectType` is 0 (bind miss), the method/ctor is still a global. 8/8 never asserts this.

Production `Build()` (`as_module.cpp` 397–440): CANONICAL parse/seal → `Generate(*pending, this)` → on success `PublishCanonicalASTSnapshot()` then `ResetGlobalVars`. `ResetGlobalVars`/`CallInit` skips `isPureConstant`; a poked const that never got `isPureConstant` can be zeroed after a “successful” Generate.

---

## Two RED methods to add later (do not add in this package)

Same class: `FCanonicalASTProductionCodeGenTests`.
Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`.
Keep existing 8 methods. Append these two.

### 1. `CanonicalConstGlobalOnlyBuildInstallsOrFailsClosed`

Global-only `const int G = 41;` with **no** `F()`. `Build()==0` is allowed only if `G` is installed and readable as `41`. Fail-closed is allowed. Silent success with nothing installed is not.

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

If this method is already GREEN after named-local 8/8, keep it as F1 regression: TU-direct const VAR now installs even when `functionDecls` is empty. That does **not** close F1 preflight for import/funcdef/type-only/nested namespace, and does **not** check 9.5.

### 2. `CanonicalValueObjectCtorIsOwnedAndNotGlobal`

Same live `FValue` fixture as `CanonicalValueObjectBuildPublishesCodeGenAndExecutes`. Keep execute `42`. Add owner/registry asserts fifth-pass F1 required and 8/8 omitted.

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

Do not replace execute-42 with fail-closed. Do not assert generated `GetValue` as a global (out of this minimal pair). Includes: existing `as_module.h` / `as_scriptengine.h` already pull `asCObjectType` / `asCScriptFunction`. If a later compile needs `as_objecttype.h`, add that include in the test file only — not Unreal types in the fork.

---

## Later verification (not this package)

From `D:\as-cta`, after the two methods are added. Label **`d95-f1-red`**. Always `-NoXGE` after touching tests. Timeout ≤ `600000`.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-f1-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-f1-red -TimeoutMs 600000
```

Expect **10** discovered methods. Honest RED: existing 8 PASS, these 2 FAIL. If method 1 already PASS, F1 empty-skip-before-globals is closed **only** for TU-direct `const int G`; keep the test. If method 2 already PASS, `Commit()` owner skip is covered for this ctor; keep the test. Either GREEN still leaves 9.5 / 9.1 / 13.2 / 13.3 / 10.2 `[ ]`.

Fix order after RED exists: whole-module preflight or install-or-fail-closed for empty `functionDecls`; keep `objectType` bind + `Commit` skip; do not publish methods/ctors as globals. Do not flip default CANONICAL.

---

## Hard constraints

- Leave `tasks.md` **9.5 / 9.1 / 13.2 / 13.3 / 10.2** unchecked. Do not mark 9.5 from these RED tests existing.
- Default `ep.canonicalCompilerPipeline` stays LEGACY (Wave G forbidden).
- No Clang/LLVM link.
- No Unreal types in `as_bytecode_codegen*` / `as_sema*` / `as_ast_*`.
- No script `funcdef` / `@` / `is`.
- `CompileFunction` may stay `COMPILER`.
- Do not start handles / `&in` / `array<T>` / host funcdef / imports / suspend in this F1 pair (gap matrix is a later fixture).
- This attachment is not an implementation license to edit the fork.
