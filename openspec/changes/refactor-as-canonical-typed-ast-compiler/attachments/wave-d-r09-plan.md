# Wave D R09 Implementation Plan — detached CodeGen transaction, then production `Build()` routing

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Do **not** check `openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md` boxes from this work. Dual-repo: commit `Plugins/Angelscript` first, then the parent gitlink.

**Goal:** Make `asCBytecodeCodeGen::Generate` a detached install transaction that rolls back functions, globals, funcdefs, and types on failure; only then route CANONICAL `asCModule::Build()` onto `Generate()` and flip `IsCanonicalBytecodeCodeGenReady()` once that production path actually publishes `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`.

**Architecture:** Isolated `Generate()` today mutates the live `asCModule` / `asCScriptEngine` before every body succeeds (`AllocateGlobalProperty` first, then `asNEW` + `engine->AddScriptFunction` for every function, then emit). Failure `DiscardPending` drops pending functions (bytecode wiped since R11) but leaves globals, and does not prove funcdef/type/engine-slot equality. R09 emits into a detached artifact, commits once, and destroys half-created objects with `DestroyHalfCreated`-style bytecode wipe so `ReleaseReferences` never runs without a matching `AddReferences`. Production routing is a later task in this same plan: CANONICAL `Build()` skips `asCCompiler` / `BuildCompileCode`, seals the attached AST, calls `Generate`, and sets publisher only on full success. LEGACY `Build()` is unchanged. Default pipeline stays `LEGACY` until Wave G.

**Tech Stack:** Maintained AngelScript fork under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source`, Native SDK CQTest under `AngelscriptTest/AngelScriptSDK/`, Standalone CTest `AngelscriptStandaloneCanonicalASTTests.cpp`. Commands only from `D:\as-cta` via `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1`. Exclusive UBT. No Clang/LLVM. No Unreal types in `as_ast_*`, `as_sema*`, `as_bytecode_codegen*`, `as_source_manager*`.

## Global Constraints

- Worktree: `D:\as-cta` (junction to `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`). Never run UBT from the long path.
- OpenSpec change: `refactor-as-canonical-typed-ast-compiler`. Do not archive. Do not rewrite remaining `tasks.md` boxes down.
- **First tasks are isolated `Generate()` rollback tests.** Do not edit `asCModule::Build` or `asCBuilder::BuildCompileCode` until Task 7. Do not edit `IsCanonicalBytecodeCodeGenReady()` until Task 10.
- **Do not grow CodeGen language coverage in Tasks 1–7.** Reuse the existing isolated subset (integer returns, globals, registered funcdef/`Callback` Conversion, `ActOnConstruct` of an unresolved `FValue` as the fail-closed body). Do not add script structs, containers, imports, exception tables, or new opcodes.
- **Do not mark `tasks.md` 9.5 / 13.6 / 10.4 from isolated `Generate` greens.** Those boxes are a rereview of production CodeGen authority, not a prefix count. 9.1 stays `[ ]` until rereview even after transaction tests pass.
- `ep.canonicalCompilerPipeline` stays `false` (LEGACY default) until Wave G. Do not flip it in this plan.
- `IsCanonicalBytecodeCodeGenReady()` stays `return false` until Task 10, after CANONICAL `Build()` publishes `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Isolated `Generate()` setting that publisher on a test module must **not** flip Ready.
- No Compiler fallback on CANONICAL module `Build()`. Unsupported AST fails closed (`asNOT_SUPPORTED` / existing CodeGen error). Silent `asCCompiler` success under CANONICAL is the 虚标.
- `asCCompiler` remains for LEGACY `Build()` and for `CompileFunction` in this plan (Wave E owns CompileFunction snapshot completeness). Do not delete `asCCompiler`.
- No `llvm::`, `clangAST`, Clang/LLVM link, or `asCOMPILER_PIPELINE_DUAL`.
- No Unreal types (`TArray`, `FString`, `UObject`, `TMap`, …) in new or edited `as_bytecode_codegen*` / `as_ast_*` / `as_sema*` / `as_source_manager*` files. Tests may use UE helpers.
- No new virtuals in the middle of `asIScriptModule`.
- Do not start Wave E snapshot ABI, Wave F Cache DTO, or Wave C construction-API remainder in this plan.
- One UBT user. Force a full Runtime rebuild if adaptive-skip leaves a stale DLL (`-NoXGE`).
- Commit format: `[<Scope>] <Type>: <description>` from `Documents/Rules/GitCommitRule.md`. Dual-repo: plugin submodule first.
- Inline AngelScript in C++ tests uses `ASTEST_AS_ANSI(R"AS( ... )AS")` per `Documents/Rules/ASInlineFormattingRule.md`.

---

## Checkbox discipline (read before any green)

| After this plan's evidence | May check in `tasks.md`? |
| --- | --- |
| Isolated transaction tests green, `Build()` still `asCCompiler` | **No.** Not 9.1, 9.5, 10.4, 13.6, 13.1. |
| Production CANONICAL `Build()` publishes `CANONICAL_CODEGEN` + Ready true + default still LEGACY | **Still no from this implementer.** Leave 13.6 / 9.1 / 10.4 / 13.1 `[ ]` for rereview. Record counts in `attachments/wave-d-r09-results.md`. |
| Value objects / containers / full SDK corpus | **No.** That is 9.5 / 9.7, out of this plan. |
| Default `canonicalCompilerPipeline = true` | **No.** Wave G. |

Isolated `GetFunctionCount()==0` after an unsealed Generate is **not** atomic install. Existing `CodeGenFailureLeavesNoPartialModuleState` and `CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` stay as regression, not as the R09 gate.

---

## Current production facts (re-grep if lines moved)

| Location | Function | What is wrong for R09 |
| --- | --- | --- |
| `Fork/as_bytecode_codegen.h:17` | comment | Claims failure must not mutate module **functions**. Body already mutates **globals** (and will mutate funcdefs/types if install grows). |
| `Fork/as_bytecode_codegen.cpp:1461` | `Generate` | Sealed-only gates, then `module->AllocateGlobalProperty` (`:1518`) **before** any body succeeds. Empty `functionDecls` returns OK and **skips globals**. |
| `Fork/as_bytecode_codegen.cpp:1532-1557` | pending loop | `asNEW` + `FillFunctionSignature` + `engine->AddScriptFunction` for **all** functions before any `Emit`. |
| `Fork/as_bytecode_codegen.cpp:1559-1569` | emit loop | On `Emit` fail, `DiscardPending` then return. **Globals stay.** Publisher stays `NONE` (OK). |
| `Fork/as_bytecode_codegen.cpp:1400-1416` | `DiscardPending` | Reverse `RemoveScriptFunction` + wipe `byteCode` + `ReleaseInternal`. Does not roll globals, funcdefs, types, or `varAddressMap`. |
| `Fork/as_bytecode_codegen.cpp:1572-1583` | success | `AddReferences` + `module->scriptFunctions.PushLast` + **extra** `AddRefInternal` + global function lists + publisher `CANONICAL_CODEGEN`. Extra ref vs legacy new-global `AddScriptFunction(int…)`. |
| `Fork/as_module.cpp:406` | `asCModule::Build` | Always `builder->BuildCompileCode()` (`asCCompiler`). Never `Generate`. |
| `Fork/as_builder.cpp:863` | `BuildCompileCode` | Instantiates `asCCompiler` for factories, then `CompileFunctions`. |
| `Fork/as_builder.cpp:652` | `AttachCanonicalSemaIfNeeded` | Silent return on Context/Sema OOM. CANONICAL production must fail closed. |
| `Fork/as_scriptengine.h:249` | `IsCanonicalBytecodeCodeGenReady` | Unconditional `return false`. Correct until Task 10. |
| `Fork/as_scriptengine.cpp:787` | engine properties | `ep.canonicalCompilerPipeline = false`. Must stay false. |
| `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp:180` | `CodeGenFailureLeavesNoPartialModuleState` | Unsealed gate 1. No globals, no engine slots. |
| `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp:220` | `CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` | Fail-after-`AddScriptFunction`. Asserts only `GetFunctionCount()==0`. |
| R11 CodeGen prefix | 24/24 | Success-path Discard+Destroy. Not R09 failure rollback. Do not regress. |

`Generate` does **not** call `module->AddFuncDef` today (lookup-only via `engine->funcDefs` / `registeredFuncDefs`). Tests must still snapshot funcdef tables: a later atomic install may create them, and success-path `AddReferences` already touches funcdef / `$func` (`functionBehaviours`) refs.

---

## What “atomic install” rolls back

Snapshot **before** `Generate`. On any failure (`asNOT_SUPPORTED`, `asINVALID_TYPE`, `asINVALID_DECLARATION`, `asOUT_OF_MEMORY`, unsealed, no module), the same module + engine must compare equal, then `Module->Discard()` + `Engine.Destroy()` without AV.

Use `asCModule` / `asCScriptEngine` internals (tests already include them). `GetFunctionCount()==0` alone is **not** proof.

### Functions

| Field | Must match pre-Generate |
| --- | --- |
| `module->GetFunctionCount()` | yes (`globalFunctionList` length) |
| `module->scriptFunctions.GetLength()` | yes |
| `module->globalFunctionList.GetLength()` | yes |
| `engine->scriptFunctions.GetLength()` | yes |
| occupied non-null `engine->scriptFunctions[i]` count | yes |
| `engine->freeScriptFunctionIds.GetLength()` | yes |
| `GetLastBytecodePublisher()` | `asBYTECODE_PUBLISHER_NONE` (or the pre-value; isolated empty module is `NONE`) |

On failure, no pending `asCScriptFunction` may remain in `engine->scriptFunctions`. Destroy with `DestroyHalfCreated` (or equivalent: `scriptData->byteCode.SetLength(0)` **before** any `ReleaseReferences` / destructor path) so bytecode that held `FuncPtr` / `REFCPY` / `FREE` / `CALL` does not extra-release `functionBehaviours` or host `Callback`.

### Globals

| Field | Must match pre-Generate |
| --- | --- |
| `module->GetGlobalVarCount()` | yes |
| `module->scriptGlobalsList.GetLength()` | yes |
| occupied non-null `engine->globalProperties[i]` count | yes (`GetGlobalPropertyCount()` is **registered** props only — do not use it) |
| `engine->freeGlobalPropertyIds.GetLength()` | yes |
| `engine->varAddressMap` occupancy | yes (no leftover `AllocateMemory` addresses) |

Today `module->AllocateGlobalProperty` does `engine->AllocateGlobalProperty` + `varAddressMap.Add` + `scriptGlobals` / `scriptGlobalsList` + `prop->AddRef()`. Failure after a later `asNOT_SUPPORTED` **leaves G**. That is the first RED.

### Funcdefs

| Field | Must match pre-Generate |
| --- | --- |
| `module->funcDefs.GetLength()` | yes |
| `engine->funcDefs.GetLength()` | yes |
| `engine->GetFuncdefCount()` (`registeredFuncDefs`) | yes |
| `engine->functionBehaviours.GetInternalReferenceCountForTesting()` | yes |

Lookup-only emit must not `FindMatchingFuncdef(..., module)` (that **creates** funcdefs) and must not `CreateType($func)` as a new type. If commit later creates a module funcdef, failure must remove it from both module and engine tables and drop its refs.

Host `RegisterFuncdef("int Callback(int)")` **before** the snapshot is a pre-existing registered funcdef; rollback compares against that baseline, not against zero.

### Types

| Field | Must match pre-Generate |
| --- | --- |
| `module->GetObjectTypeCount()` | yes |
| `module->classTypes.GetLength()` | yes |
| `module->enumTypes.GetLength()` | yes |
| `module->typeDefs.GetLength()` | yes |
| `module->allLocalTypes` occupancy if asserted | yes |

Isolated `Generate` must not register script classes/enums/typedefs in Tasks 1–7. Snapshot them anyway so a later install that grows types cannot silently leak. Do not invent script-struct lowering to make a type-rollback fixture.

### Not in the R09 rollback contract

- `engine->scriptSectionNames` intern (`GetScriptSectionNameIndex`) is engine-lifetime. Prefer not interning until commit. Do **not** fail the transaction test solely on interned section-name growth in v1; record it if it still grows.
- Sealed AST dumps must stay unchanged (already covered by `CodeGenLeavesAstDumpUnchanged`).
- Ready() / default pipeline / `asCCompiler` publisher on LEGACY `Build()`.

### Commit (success only)

One install of **already-complete** objects:

1. Attach globals to the module with the same refcount as legacy `AllocateGlobalProperty` (engine slot + module list + one `AddRef`).
2. Publish functions with **legacy new-global refcount**: ctor internal 1, `engine->AddScriptFunction` (table pointer, not a ref), `module->scriptFunctions.PushLast` **without** the extra `AddRefInternal` currently at `as_bytecode_codegen.cpp:1577`, `globalFunctions` / `globalFunctionList` for globals.
3. Exactly one `func->AddReferences()` per published function (after bytecode is complete).
4. `module->SetLastBytecodePublisher(asBYTECODE_PUBLISHER_CANONICAL_CODEGEN)` **last**.
5. Nothing is visible on `asCModule` function/global/funcdef/type lists until this commit. Preferred: nothing is visible in `engine->scriptFunctions` / `engine->globalProperties` either until commit. If CALL ids require a reservation, reserve without module publication and still roll the reservation on failure so the post-failure snapshot matches.

---

## File map

Path aliases:

| Alias | Path from `D:\as-cta` |
| --- | --- |
| `Fork/` | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` |
| `SDK/FrontendAST/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/` |
| `SDK/CanonicalAST/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/` |
| `SDK/Support/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Support/` |
| `Standalone/` | `Plugins/Angelscript/Standalone/` |

### Create

| File | Responsibility |
| --- | --- |
| `Fork/as_bytecode_codegen_artifact.h` | Header-only detached install record. Standard C++ only (`asCArray`). Included solely by `as_bytecode_codegen.cpp`. Tests must **not** include it; they observe `Generate` through module/engine tables. |
| `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp` | Isolated `Generate` rollback / retry / table-equality tests. Prefix `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction`. |
| `SDK/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` | Production CANONICAL `Build()` provenance. Prefix `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`. **Do not create or compile this file until Task 8.** |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-d-r09-results.md` | Implementer evidence after greens. Not a checkbox. |

### Modify (Tasks 1–7 — isolated transaction only)

| File | What changes |
| --- | --- |
| `Fork/as_bytecode_codegen.h` | Comment: failure must not mutate functions, globals, funcdefs, or types. Signature stays `int Generate(const asCASTContext& context, asCModule* module)`. |
| `Fork/as_bytecode_codegen.cpp` | `Generate` fills the artifact; `Commit` / `Abandon` ; replace live `AllocateGlobalProperty` + success extra `AddRefInternal`. Do not add emitters. |

### Modify (Tasks 8–12 — production routing only, after isolated greens)

| File | What changes |
| --- | --- |
| `Fork/as_module.cpp` `Build()` | CANONICAL: parse + fail-closed Sema attach + seal + `Generate`. Skip `BuildCompileCode`. LEGACY: existing path. Do not fabricate an empty TU snapshot on CANONICAL success (`PublishCanonicalASTSnapshot` `:2088-2096` stays Wave E; D must not add a new fabricate). |
| `Fork/as_builder.cpp` / `as_builder.h` | `AttachCanonicalSemaIfNeeded` fails the build on OOM when pipeline is CANONICAL. Optional `BuildCanonicalCodeGen()` used only from `asCModule::Build`. `BuildCompileCode` / `CompileFunctions` remain LEGACY-only. |
| `Fork/as_scriptengine.h` | `IsCanonicalBytecodeCodeGenReady()` returns true **only after** CANONICAL `Build()` calls `Generate`. Comment: default is still LEGACY. |
| `SDK/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp` | Primary/HotReload/generation-like `Build()` publisher `CANONICAL_CODEGEN`. Ready true. Default still LEGACY. Value-object CANONICAL `Build` must **not** publish `COMPILER` (fail closed). `CompileFunction` may stay `COMPILER` (document in the test message). |
| `SDK/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp` | Ready true; CANONICAL `int F() { return 7; }` publisher `CANONICAL_CODEGEN`. |
| `Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp` | Default LEGACY. Ready true after Task 10. Add explicit CANONICAL subset `Build` publisher check. Existing discard/retain default-LEGACY Builds stay `COMPILER`. |
| `Documents/Guides/AngelscriptCanonicalAST.md` | Honesty only: Ready true because CANONICAL `Build` uses `Generate`; default still LEGACY; subset fail-closed; full language still LEGACY `asCCompiler`. Do not claim 9.5. |

### Do not touch in this plan

- `as_sema*`, verifier, arena, `Core/angelscript.h` vtable, Cache sidecar, StaticJIT, `as_compiler.cpp` except that CANONICAL `Build` must not reach it.
- `as_scriptengine.cpp` `ep.canonicalCompilerPipeline` initializer.
- Language-coverage tests in `AngelscriptNativeCanonicalASTCodeGenTests.cpp` except if a transaction change breaks R11 teardown — then **fix ownership**, do not expand emitters.
- `tasks.md` checkboxes.
- CMake / `AngelscriptStandaloneArchitectureTests.cpp` unless a new `.cpp` is added. Prefer header-only artifact (no CMake change).

### Collision warning

`as_module.cpp` and `as_builder.cpp` are Wave D writers. Do not overlap Wave E snapshot protocol or Wave F `WriteError*`. Isolated Tasks 1–7 must **not** take those files.

---

## Interfaces later tasks rely on

```cpp
// Unchanged public CodeGen API (Fork/as_bytecode_codegen.h)
int asCBytecodeCodeGen::Generate(const asCASTContext& context, asCModule* module);

// Artifact (Fork/as_bytecode_codegen_artifact.h), not public SDK
struct asSBytecodeCodeGenArtifact
{
	asCArray<asCScriptFunction*> functions;
	asCArray<asCGlobalProperty*> globals;
	asCArray<asCFuncdefType*> funcdefs;
	asCArray<asCTypeInfo*> types;
	void Abandon(asCScriptEngine* engine);   // DestroyHalfCreated + RemoveGlobalProperty; no AddReferences
	int  Commit(asCModule* module);          // lists + one AddReferences + publisher last
};

// Ready after Task 10 only (Fork/as_scriptengine.h)
bool asCScriptEngine::IsCanonicalBytecodeCodeGenReady() const; // true => CANONICAL asCModule::Build calls Generate
```

`Generate` consumes `const asCASTContext&` (sealed). It must not mutate AST nodes.

---

## Task 0: Preflight — do not implement R09 yet

**Files:** none.

**Why:** R11 teardown AV intercepts production routing. Wave C remaining construction APIs are a different exclusive-UBT track.

- [ ] **Step 1: Confirm R11 CodeGen prefix still 24/24**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label r09-preflight-codegen -TimeoutMs 600000
```

Expected: `passed` equals `total`, `failed=0`, `skipped=0`. Includes `CodeGenEmitsFuncdefCallAndLambda` and the four teardown methods. If red, **stop** and fix R11. Do not start Task 1.

- [ ] **Step 2: Confirm Cutover honesty (Ready false, LEGACY default, CANONICAL Build still COMPILER)**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label r09-preflight-cutover -TimeoutMs 600000
```

Expected: 5/5. `DefaultPipelineIsLegacyReadyIsFalseAndRejectsDual` still sees `IsCanonicalBytecodeCodeGenReady()==false`. `SourceBuildPurposesSelectCanonicalAndExecute` still sees publisher `asBYTECODE_PUBLISHER_COMPILER`.

- [ ] **Step 3: Stop if preflight fails**

If either prefix is red, write the failure report path into the session log and do not create the transaction test file.

No commit.

---

## Task 1: Isolated table-snapshot helper + fail-after-global tests (RED)

**Files:**
- Create: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`
- Test prefix: `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction`

**Interfaces:**
- Consumes: `asCBytecodeCodeGen::Generate`, `asCSema` ActOn* APIs, `FNativeTestEngine`, `CreateBuilderModule`
- Produces: `FCodeGenTableSnapshot` + `CaptureCodeGenTables` + `AssertCodeGenTablesEqual` used by every later isolated test

Do **not** edit fork sources in this task.

- [ ] **Step 1: Write the failing tests**

Create the file with the snapshot helper and the three methods below. Keep `GenerateCanonicalFromSource` **out** of the failure fixtures (it dumps Generate errors as test errors). Construct AST with ActOn* / optional parse-then-ActOn, call `Generate` directly, then compare tables.

```cpp
#include "AngelscriptTestMacros.h"
#include "../../Support/AngelscriptNativeCanonicalASTTestSupport.h"
#include "../../Support/AngelscriptNativeBuilderTestSupport.h"

#include "CQTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_bytecode_codegen.h"
#include "source/as_module.h"
#include "source/as_objecttype.h"
#include "source/as_parser.h"
#include "source/as_scriptcode.h"
#include "source/as_scriptengine.h"
#include "source/as_scriptfunction.h"
#include "source/as_sema.h"
#include "EndAngelscriptHeaders.h"

#if WITH_ANGELSCRIPT_UNITTESTS

namespace
{
	struct FCodeGenTableSnapshot
	{
		asUINT ModuleFunctionCount = 0;
		asUINT ModuleScriptFunctions = 0;
		asUINT ModuleGlobalFunctionList = 0;
		asUINT ModuleGlobalVars = 0;
		asUINT ModuleScriptGlobalsList = 0;
		asUINT ModuleFuncDefs = 0;
		asUINT ModuleClassTypes = 0;
		asUINT ModuleEnumTypes = 0;
		asUINT ModuleTypeDefs = 0;
		asUINT EngineScriptFunctions = 0;
		asUINT EngineScriptFunctionOccupied = 0;
		asUINT EngineFreeScriptFunctionIds = 0;
		asUINT EngineFuncDefs = 0;
		asUINT EngineRegisteredFuncDefs = 0;
		asUINT EngineGlobalProperties = 0;
		asUINT EngineGlobalPropertiesOccupied = 0;
		asUINT EngineFreeGlobalPropertyIds = 0;
		asUINT EngineVarAddressMap = 0;
		asDWORD FunctionBehavioursInternalRefs = 0;
		asEBytecodePublisher Publisher = asBYTECODE_PUBLISHER_NONE;
	};

	asUINT OccupiedPointers(const asCArray<asCScriptFunction*>& Values)
	{
		asUINT Count = 0;
		for (asUINT Index = 0; Index < Values.GetLength(); ++Index)
		{
			if (Values[Index] != nullptr)
			{
				++Count;
			}
		}
		return Count;
	}

	asUINT OccupiedGlobals(const asCArray<asCGlobalProperty*>& Values)
	{
		asUINT Count = 0;
		for (asUINT Index = 0; Index < Values.GetLength(); ++Index)
		{
			if (Values[Index] != nullptr)
			{
				++Count;
			}
		}
		return Count;
	}

	FCodeGenTableSnapshot CaptureCodeGenTables(asCScriptEngine* Engine, asCModule* Module)
	{
		FCodeGenTableSnapshot Snapshot;
		if (Module != nullptr)
		{
			Snapshot.ModuleFunctionCount = Module->GetFunctionCount();
			Snapshot.ModuleScriptFunctions = Module->scriptFunctions.GetLength();
			Snapshot.ModuleGlobalFunctionList = Module->globalFunctionList.GetLength();
			Snapshot.ModuleGlobalVars = Module->GetGlobalVarCount();
			Snapshot.ModuleScriptGlobalsList = Module->scriptGlobalsList.GetLength();
			Snapshot.ModuleFuncDefs = Module->funcDefs.GetLength();
			Snapshot.ModuleClassTypes = Module->classTypes.GetLength();
			Snapshot.ModuleEnumTypes = Module->enumTypes.GetLength();
			Snapshot.ModuleTypeDefs = Module->typeDefs.GetLength();
			Snapshot.Publisher = Module->GetLastBytecodePublisher();
		}
		if (Engine != nullptr)
		{
			Snapshot.EngineScriptFunctions = Engine->scriptFunctions.GetLength();
			Snapshot.EngineScriptFunctionOccupied = OccupiedPointers(Engine->scriptFunctions);
			Snapshot.EngineFreeScriptFunctionIds = Engine->freeScriptFunctionIds.GetLength();
			Snapshot.EngineFuncDefs = Engine->funcDefs.GetLength();
			Snapshot.EngineRegisteredFuncDefs = Engine->GetFuncdefCount();
			Snapshot.EngineGlobalProperties = Engine->globalProperties.GetLength();
			Snapshot.EngineGlobalPropertiesOccupied = OccupiedGlobals(Engine->globalProperties);
			Snapshot.EngineFreeGlobalPropertyIds = Engine->freeGlobalPropertyIds.GetLength();
			Snapshot.EngineVarAddressMap = static_cast<asUINT>(Engine->varAddressMap.Num());
			Snapshot.FunctionBehavioursInternalRefs =
				Engine->functionBehaviours.GetInternalReferenceCountForTesting();
		}
		return Snapshot;
	}

	bool AssertCodeGenTablesEqual(
		FAutomationTestBase& Test,
		const TCHAR* Label,
		const FCodeGenTableSnapshot& Before,
		const FCodeGenTableSnapshot& After)
	{
		bool bOk = true;
		auto CheckUInt = [&](const TCHAR* Name, asUINT Left, asUINT Right)
		{
			if (Left != Right)
			{
				Test.AddError(FString::Printf(
					TEXT("%s: %s before=%u after=%u (GetFunctionCount==0 is not a transaction proof)"),
					Label, Name, Left, Right));
				bOk = false;
			}
		};
		CheckUInt(TEXT("ModuleFunctionCount"), Before.ModuleFunctionCount, After.ModuleFunctionCount);
		CheckUInt(TEXT("ModuleScriptFunctions"), Before.ModuleScriptFunctions, After.ModuleScriptFunctions);
		CheckUInt(TEXT("ModuleGlobalFunctionList"), Before.ModuleGlobalFunctionList, After.ModuleGlobalFunctionList);
		CheckUInt(TEXT("ModuleGlobalVars"), Before.ModuleGlobalVars, After.ModuleGlobalVars);
		CheckUInt(TEXT("ModuleScriptGlobalsList"), Before.ModuleScriptGlobalsList, After.ModuleScriptGlobalsList);
		CheckUInt(TEXT("ModuleFuncDefs"), Before.ModuleFuncDefs, After.ModuleFuncDefs);
		CheckUInt(TEXT("ModuleClassTypes"), Before.ModuleClassTypes, After.ModuleClassTypes);
		CheckUInt(TEXT("ModuleEnumTypes"), Before.ModuleEnumTypes, After.ModuleEnumTypes);
		CheckUInt(TEXT("ModuleTypeDefs"), Before.ModuleTypeDefs, After.ModuleTypeDefs);
		CheckUInt(TEXT("EngineScriptFunctions"), Before.EngineScriptFunctions, After.EngineScriptFunctions);
		CheckUInt(TEXT("EngineScriptFunctionOccupied"), Before.EngineScriptFunctionOccupied, After.EngineScriptFunctionOccupied);
		CheckUInt(TEXT("EngineFreeScriptFunctionIds"), Before.EngineFreeScriptFunctionIds, After.EngineFreeScriptFunctionIds);
		CheckUInt(TEXT("EngineFuncDefs"), Before.EngineFuncDefs, After.EngineFuncDefs);
		CheckUInt(TEXT("EngineRegisteredFuncDefs"), Before.EngineRegisteredFuncDefs, After.EngineRegisteredFuncDefs);
		CheckUInt(TEXT("EngineGlobalPropertiesOccupied"), Before.EngineGlobalPropertiesOccupied, After.EngineGlobalPropertiesOccupied);
		CheckUInt(TEXT("EngineFreeGlobalPropertyIds"), Before.EngineFreeGlobalPropertyIds, After.EngineFreeGlobalPropertyIds);
		CheckUInt(TEXT("EngineVarAddressMap"), Before.EngineVarAddressMap, After.EngineVarAddressMap);
		CheckUInt(TEXT("FunctionBehavioursInternalRefs"), Before.FunctionBehavioursInternalRefs, After.FunctionBehavioursInternalRefs);
		if (Before.Publisher != After.Publisher)
		{
			Test.AddError(FString::Printf(
				TEXT("%s: publisher before=%d after=%d"),
				Label, static_cast<int32>(Before.Publisher), static_cast<int32>(After.Publisher)));
			bOk = false;
		}
		return bOk;
	}
}

TEST_CLASS_WITH_FLAGS(FCanonicalASTCodeGenTransactionTests,
	"Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
public:
	TEST_METHOD(CodeGenUnsealedFailureLeavesTablesUnchanged)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "TxnUnsealed");
		ASSERT_THAT(IsNotNull(Module, TEXT("unsealed transaction test needs a module")));

		const FCodeGenTableSnapshot Before = CaptureCodeGenTables(ScriptEngine, Module);
		asCASTContext Open;
		asCSema Sema(nullptr, Open);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("TxnUnsealed");
		const asCQualType IntType = Open.InternPrimitive(ttInt, 0);
		const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, asCSourceRange());
		Sema.ActOnReturnStmt(Fn, Sema.ActOnIntegerLiteral(7, asCSourceRange()), asCSourceRange());

		asCBytecodeCodeGen CodeGen;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_UNSEALED_PUBLICATION, CodeGen.Generate(Open, Module),
			TEXT("unsealed Generate must fail before install")));
		ASSERT_THAT(IsTrue(
			AssertCodeGenTablesEqual(*TestRunner, TEXT("unsealed"), Before, CaptureCodeGenTables(ScriptEngine, Module)),
			TEXT("unsealed failure must not mutate functions/globals/funcdefs/types")));
		Module->Discard();
	}

	TEST_METHOD(CodeGenFailureAfterGlobalAllocateRollsBackGlobalAndFunctions)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "TxnGlobal");
		ASSERT_THAT(IsNotNull(Module, TEXT("global rollback test needs a module")));

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("TxnGlobal");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		Sema.ActOnVarDecl(Tu, "G", IntType, asCSourceRange());
		const asASTDeclId OkFn = Sema.ActOnFunctionDecl(Tu, "F", IntType, asCSourceRange());
		Sema.ActOnReturnStmt(OkFn, Sema.ActOnIntegerLiteral(7, asCSourceRange()), asCSourceRange());
		const asCQualType Obj = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0);
		const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Make", Obj, asCSourceRange());
		asCArray<asASTExprId> Args;
		Sema.ActOnReturnStmt(BadFn, Sema.ActOnConstruct(Obj, Args, asCSourceRange()), asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("global+unsupported graph should still verify")));

		const FCodeGenTableSnapshot Before = CaptureCodeGenTables(ScriptEngine, Module);
		asCBytecodeCodeGen CodeGen;
		ASSERT_THAT(IsTrue(CodeGen.Generate(Context, Module) < 0,
			TEXT("unsupported construct after a global must fail closed")));
		ASSERT_THAT(IsTrue(
			AssertCodeGenTablesEqual(*TestRunner, TEXT("global+unsupported"), Before, CaptureCodeGenTables(ScriptEngine, Module)),
			TEXT("failure after AllocateGlobalProperty must roll back the global, not only GetFunctionCount")));
		Module->Discard();
	}

	TEST_METHOD(CodeGenFillSignatureFailureAfterGlobalAndPriorFunctionRollsBack)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "TxnSig");
		ASSERT_THAT(IsNotNull(Module, TEXT("signature rollback test needs a module")));

		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		const asASTDeclId Tu = Sema.ActOnTranslationUnit("TxnSig");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		Sema.ActOnVarDecl(Tu, "G", IntType, asCSourceRange());
		const asASTDeclId OkFn = Sema.ActOnFunctionDecl(Tu, "F", IntType, asCSourceRange());
		Sema.ActOnReturnStmt(OkFn, Sema.ActOnIntegerLiteral(1, asCSourceRange()), asCSourceRange());
		const asCQualType Missing = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "NoSuchType", 0);
		const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Bad", IntType, asCSourceRange());
		Sema.ActOnParamDecl(BadFn, "X", Missing, asCSourceRange());
		Sema.ActOnReturnStmt(BadFn, Sema.ActOnIntegerLiteral(0, asCSourceRange()), asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("missing-param-type graph should still verify")));

		const FCodeGenTableSnapshot Before = CaptureCodeGenTables(ScriptEngine, Module);
		asCBytecodeCodeGen CodeGen;
		ASSERT_THAT(IsTrue(CodeGen.Generate(Context, Module) < 0,
			TEXT("FillFunctionSignature failure must fail closed")));
		ASSERT_THAT(IsTrue(
			AssertCodeGenTablesEqual(*TestRunner, TEXT("signature"), Before, CaptureCodeGenTables(ScriptEngine, Module)),
			TEXT("FillFunctionSignature fail after a global and a prior function must restore engine slots and globals")));
		Module->Discard();
	}
};

#endif
```

If `varAddressMap.Num()` does not compile (`TMap` API on the engine), use `Engine->varAddressMap.GetNum()` or iterate; do not drop the occupancy check.

- [ ] **Step 2: Build Editor (exclusive UBT)**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-txn-red -TimeoutMs 1800000 -NoXGE
```

Expected: exit 0. If UBT adaptive-skips Runtime, force a rebuild of `AngelscriptRuntime` / `AngelscriptTest` by touching the new cpp only after a clean compile of the test module.

- [ ] **Step 3: Run the new prefix and prove RED**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label r09-txn-red -TimeoutMs 600000
```

Expected: `CodeGenUnsealedFailureLeavesTablesUnchanged` may already PASS (gate 1, no mutations). **`CodeGenFailureAfterGlobalAllocateRollsBackGlobalAndFunctions` MUST FAIL** with `ModuleGlobalVars before=0 after=1` (or occupied `engine->globalProperties` / `varAddressMap` growth). `CodeGenFillSignatureFailureAfterGlobalAndPriorFunctionRollsBack` MUST FAIL on leftover global and/or leftover `engine->scriptFunctions` occupancy.

If all three pass on current `Generate`, the fixture did not hit `AllocateGlobalProperty` — fix the AST so `asAST_DECL_VAR` is a TU child **and** at least one function-like decl with a body exists (current `Generate` skips globals when `functionDecls` is empty).

- [ ] **Step 4: Commit tests only (plugin submodule)**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp
git commit -m "[AngelscriptTest] Test: add isolated CodeGen table-rollback fixtures that fail on leftover globals"
```

Do not update the parent gitlink until a later paired commit. Do not edit fork sources yet.

---

## Task 2: Isolated fail-after-emit with FuncPtr/REFCPY + retry (RED)

**Files:**
- Modify: `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`

**Interfaces:**
- Consumes: `FCodeGenTableSnapshot` from Task 1, `RegisterFuncdef("int Callback(int)")`, `asCParser` + `ActOnConstruct`
- Produces: `CodeGenUnsupportedBodyAfterFuncdefStoreRollsBackRefs` and `CodeGenRetryGenerateOnSameModuleSeesNoLeftoverIds`

Still no fork edits. Still no `Build()` routing. Do not add new emitters; first body must be the **existing** Conversion/store subset from R11.

- [ ] **Step 1: Add the two failing methods**

Append inside the same `TEST_CLASS_WITH_FLAGS`:

```cpp
	TEST_METHOD(CodeGenUnsupportedBodyAfterFuncdefStoreRollsBackRefs)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->RegisterFuncdef("int Callback(int)") >= 0,
			TEXT("funcdef-store rollback needs host Callback")));
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "TxnFuncPtr");
		ASSERT_THAT(IsNotNull(Module, TEXT("funcdef-store rollback needs a module")));

		asCBuilder Builder(ScriptEngine, Module);
		Builder.silent = true;
		asCScriptCode Code;
		const char* Source = ASTEST_AS_ANSI(R"AS(
			int Double(int X)
			{
				return X + X;
			}

			int Store()
			{
				Callback L = Double;
				return L(1);
			}
			)AS");
		Code.SetCode("TxnFuncPtr", Source, true);
		asCASTContext Context;
		asCSema Sema(ScriptEngine, Context);
		asCParser Parser(&Builder);
		Parser.SetSema(&Sema);
		ASSERT_THAT(AreEqual(0, Parser.ParseScript(&Code), TEXT("Double+Store should parse")));

		const asASTDeclId Tu = Context.GetTranslationUnit();
		const asCQualType Obj = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0);
		const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Make", Obj, asCSourceRange());
		asCArray<asASTExprId> Args;
		Sema.ActOnReturnStmt(BadFn, Sema.ActOnConstruct(Obj, Args, asCSourceRange()), asCSourceRange());
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("funcptr store + unsupported Make should still verify")));

		const FCodeGenTableSnapshot Before = CaptureCodeGenTables(ScriptEngine, Module);
		asCBytecodeCodeGen CodeGen;
		ASSERT_THAT(IsTrue(CodeGen.Generate(Context, Module) < 0,
			TEXT("unsupported Make after a FuncPtr/REFCPY body must fail closed")));
		ASSERT_THAT(IsTrue(
			AssertCodeGenTablesEqual(*TestRunner, TEXT("funcptr+unsupported"), Before, CaptureCodeGenTables(ScriptEngine, Module)),
			TEXT("discarded FuncPtr/REFCPY bytecode must not extra-release Callback or $func")));
		Module->Discard();
	}

	TEST_METHOD(CodeGenRetryGenerateOnSameModuleSeesNoLeftoverIds)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		asCModule* const Module = AngelscriptBuilderTestSupport::CreateBuilderModule(ScriptEngine, "TxnRetry");
		ASSERT_THAT(IsNotNull(Module, TEXT("retry test needs a module")));

		auto SealUnsupportedWithGlobal = [&](asCASTContext& Context)
		{
			asCSema Sema(ScriptEngine, Context);
			const asASTDeclId Tu = Sema.ActOnTranslationUnit("TxnRetry");
			const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
			Sema.ActOnVarDecl(Tu, "G", IntType, asCSourceRange());
			const asASTDeclId OkFn = Sema.ActOnFunctionDecl(Tu, "F", IntType, asCSourceRange());
			Sema.ActOnReturnStmt(OkFn, Sema.ActOnIntegerLiteral(7, asCSourceRange()), asCSourceRange());
			const asCQualType Obj = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0);
			const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Make", Obj, asCSourceRange());
			asCArray<asASTExprId> Args;
			Sema.ActOnReturnStmt(BadFn, Sema.ActOnConstruct(Obj, Args, asCSourceRange()), asCSourceRange());
			return Context.Seal();
		};

		asCASTContext First;
		ASSERT_THAT(AreEqual(0, SealUnsupportedWithGlobal(First), TEXT("first unsupported graph should seal")));
		const FCodeGenTableSnapshot Baseline = CaptureCodeGenTables(ScriptEngine, Module);
		asCBytecodeCodeGen FirstGen;
		ASSERT_THAT(IsTrue(FirstGen.Generate(First, Module) < 0, TEXT("first Generate must fail")));
		ASSERT_THAT(IsTrue(
			AssertCodeGenTablesEqual(*TestRunner, TEXT("retry-after-fail"), Baseline, CaptureCodeGenTables(ScriptEngine, Module)),
			TEXT("first failure must leave the module retry-safe")));

		asCASTContext Success;
		asCSema SuccessSema(ScriptEngine, Success);
		const asASTDeclId Tu = SuccessSema.ActOnTranslationUnit("TxnRetry");
		const asCQualType IntType = Success.InternPrimitive(ttInt, 0);
		const asASTDeclId Fn = SuccessSema.ActOnFunctionDecl(Tu, "F", IntType, asCSourceRange());
		SuccessSema.ActOnReturnStmt(Fn, SuccessSema.ActOnIntegerLiteral(7, asCSourceRange()), asCSourceRange());
		ASSERT_THAT(AreEqual(0, Success.Seal(), TEXT("retry success graph should seal")));
		asCBytecodeCodeGen SecondGen;
		ASSERT_THAT(AreEqual(0, SecondGen.Generate(Success, Module),
			TEXT("retry Generate on the same module must succeed without leftover names/ids")));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptNativeTestSupport::CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 7,
			TEXT("retry success must execute F()==7")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			Module->GetLastBytecodePublisher(),
			TEXT("isolated success still records CodeGen publisher; Ready must stay false until production Build")));
		ASSERT_THAT(IsFalse(ScriptEngine->IsCanonicalBytecodeCodeGenReady(),
			TEXT("isolated Generate must not flip IsCanonicalBytecodeCodeGenReady")));
		Module->Discard();
	}
```

`ASTEST_AS_ANSI` must wrap the snippet; keep Allman braces and indent with the surrounding C++.

If parse of `Callback L = Double` fails without a script-level `funcdef` because only `RegisterFuncdef` exists, that is the intended host-funcdef fixture (same as R11). If Seal fails, dump `asCASTDump` in the assertion message.

- [ ] **Step 2: Run RED (no production prefixes)**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-txn-funcptr-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label r09-txn-funcptr-red -TimeoutMs 600000
```

Expected: `CodeGenUnsupportedBodyAfterFuncdefStoreRollsBackRefs` fails on `FunctionBehavioursInternalRefs` and/or `EngineFuncDefs` / occupied scriptFunctions if Discard extra-releases, **or** on leftover module functions/globals if Discard is incomplete. `CodeGenRetryGenerateOnSameModuleSeesNoLeftoverIds` fails on leftover `G` / function ids from the first Generate (retry may then collide or publish two `F`s).

The Ready assertion in the retry test must **pass** (`false`) throughout Tasks 1–7. If someone flips Ready early, this test becomes the tripwire.

- [ ] **Step 3: Commit tests**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp
git commit -m "[AngelscriptTest] Test: add CodeGen fail-after-FuncPtr and same-module retry rollback fixtures"
```

---

## Task 3: Detached artifact + `Generate` transaction (GREEN isolated)

**Files:**
- Create: `Fork/as_bytecode_codegen_artifact.h`
- Modify: `Fork/as_bytecode_codegen.h` (comment only + keep API)
- Modify: `Fork/as_bytecode_codegen.cpp` (`Generate`, `DiscardPending` replacement)

**Interfaces:**
- Consumes: `asCScriptFunction::DestroyHalfCreated`, `asCScriptEngine::RemoveScriptFunction`, `asCScriptEngine::RemoveGlobalProperty`, existing `FillFunctionSignature` / `asCCanonicalFunctionEmitter`
- Produces: `asSBytecodeCodeGenArtifact::Abandon` / `Commit` as used by `Generate`

Hard no: no new opcodes, no Clang/LLVM, no Unreal types in these files, no `Build()` edits, no Ready flip.

- [ ] **Step 1: Add the header-only artifact**

`Fork/as_bytecode_codegen_artifact.h`:

```cpp
#ifndef AS_BYTECODE_CODEGEN_ARTIFACT_H
#define AS_BYTECODE_CODEGEN_ARTIFACT_H

#include "as_array.h"
#include "as_config.h"

BEGIN_AS_NAMESPACE

class asCScriptEngine;
class asCScriptFunction;
class asCGlobalProperty;
class asCFuncdefType;
class asCTypeInfo;
class asCModule;

struct asSBytecodeCodeGenArtifact
{
	asCArray<asCScriptFunction*> functions;
	asCArray<asCGlobalProperty*> globals;
	asCArray<asCFuncdefType*> funcdefs;
	asCArray<asCTypeInfo*> types;

	void Abandon(asCScriptEngine* engine);
	int Commit(asCModule* module);
};

END_AS_NAMESPACE

#endif
```

Implement `Abandon` / `Commit` in `as_bytecode_codegen.cpp` (anonymous namespace or as methods) so Standalone CMake does not need a new `.cpp`.

**Abandon rules (order matters):**

1. For each function reverse: if `scriptData` exists, `byteCode.SetLength(0)` **before** any `ReleaseReferences`. Then `engine->RemoveScriptFunction(func)` if it was inserted, then `DestroyHalfCreated()` (preferred) or `ReleaseInternal()` after the wipe. Never `AddReferences` on the abandon path.
2. For each global reverse: `engine->RemoveGlobalProperty(prop)` (clears `varAddressMap` + slot). Do not leave it on `module->scriptGlobalsList` — it must never have been added there.
3. For each funcdef reverse: remove from `module->funcDefs` **and** `engine->funcDefs` if this artifact created it. Do not `ReleaseInternal` a host `Callback` that the snapshot already owned.
4. For each type reverse: remove from `module->classTypes` / `enumTypes` / `typeDefs` / `allLocalTypes` if this artifact created it. Tasks 1–7 should keep `types` empty.
5. `functions` / `globals` / `funcdefs` / `types` `SetLength(0)`.
6. Do not set publisher.

**Commit rules:**

1. Assert every function already has complete `scriptData->byteCode` (emit succeeded).
2. Install globals through the same refcount as `asCModule::AllocateGlobalProperty` **once** (engine property already allocated in the artifact **or** allocate at commit — pick one and keep Abandon symmetric). Preferred: allocate engine properties only at commit. If emit needs `GetAddressOfValue()` during lowering, allocate engine-side without module lists, and Abandon must `RemoveGlobalProperty`.
3. `func->AddReferences()` once.
4. `module->scriptFunctions.PushLast(func)` **without** extra `AddRefInternal`.
5. `module->globalFunctions.Add(func)` + `globalFunctionList.PushLast(func)` for global functions.
6. Publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` last.
7. Do not call `FindMatchingFuncdef(func, module)` to “make types exist”.

**Generate control flow after this task:**

```text
gates (unsealed / no decls / no module) -> return, no artifact
collect functionDecls (unchanged)
if functionDecls empty: do not skip TU globals if you still allocate them — either emit globals too or leave the skip; Tasks 1–7 always include a function body
build artifact (signatures + emit) without module list publication
any fail -> Abandon -> return error (publisher unchanged)
Commit -> return asAST_VERIFY_OK
```

Keep the local `asCBuilder builder(engine, module); builder.silent = true;` — it must **not** replace `module->builder`.

Do not intern section names until Commit if `EmitLine` currently calls `GetScriptSectionNameIndex` during emit; if that requires threading a flag, intern during emit is allowed only as documented non-rollback cache.

- [ ] **Step 2: Run isolated transaction tests GREEN**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-txn-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label r09-txn-green -TimeoutMs 600000
```

Expected: all Transaction methods PASS. Ready still false (retry test asserts it).

- [ ] **Step 3: Run existing isolated CodeGen prefix (R11 must stay green)**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label r09-txn-codegen-regress -TimeoutMs 600000
```

Expected: previous 24 plus the new Transaction methods all PASS (the CodeGen prefix is a parent of `.CodeGen.Transaction`). Teardown methods must still `Discard` + `Engine.Destroy()` without AV. Success-path `int F() { return 7; }` still executes.

If extra `AddRefInternal` removal breaks R11 teardown, **fix commit refcount to match legacy new-global**, do not restore the extra ref, and do not skip destructor to go green.

- [ ] **Step 4: Confirm Cutover still honest (Ready false, publisher COMPILER)**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label r09-txn-cutover-still-legacy -TimeoutMs 600000
```

Expected: still 5/5 with Ready **false** and CANONICAL `Build` publisher **COMPILER**. If Ready became true, revert `as_scriptengine.h`. Isolated greens must not look like production cutover.

- [ ] **Step 5: Commit fork + tests (plugin), then parent gitlink**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.h
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen_artifact.h
git add Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp
git commit -m "[Angelscript] Fix: make asCBytecodeCodeGen::Generate a detached rollback transaction"
Set-Location D:\as-cta
git add Plugins/Angelscript
git commit -m "[Angelscript] Chore: update plugin gitlink for CodeGen transaction"
```

**Do not check 9.1 / 9.5 / 10.4 / 13.6.** Record in the session: isolated transaction is green; production `Build` is still `asCCompiler`.

---

## Task 4: Empty-functionDecls global skip (optional isolated RED/GREEN)

**Files:**
- Modify: `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`
- Modify: `Fork/as_bytecode_codegen.cpp` only if the test is red for the right reason

Current `Generate` returns `asAST_VERIFY_OK` when there are no function bodies **even if the TU has `asAST_DECL_VAR`**, skipping globals. That is a transaction hole for a later install that emits globals without functions.

- [ ] **Step 1: Add `CodeGenGlobalOnlyDeclDoesNotLeavePartialGlobals`**

Graph: sealed TU with `ActOnVarDecl("G", int)` and **no** function body. Snapshot, `Generate`, require return code that is either a documented no-op **with tables unchanged** or a real global commit. **Tables must not grow on a path that does not set publisher.** Preferred R09 behavior: no-op success, **no** `AllocateGlobalProperty`.

- [ ] **Step 2: Run Transaction prefix**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label r09-txn-global-only -TimeoutMs 600000
```

- [ ] **Step 3: Minimal fix if RED, then commit**

If current code already leaves tables unchanged (returns OK before the global loop), the test PASSES without a fork edit — keep the test as a lock. If it allocates then returns OK without publisher, that is a success-path leak: Abandon or skip.

Do not grow global-init bytecode here (`9.5` / `9.6`).

---

## Task 5: Freeze isolated R09 — Ready still false

**Files:** none new.

- [ ] **Step 1: Re-run the honesty pair**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label r09-isolated-freeze-codegen -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label r09-isolated-freeze-cutover -TimeoutMs 600000
```

Expected: CodeGen prefix green (R11 + Transaction). Cutover 5/5 with **Ready false** and **publisher COMPILER** on CANONICAL `Build()`.

- [ ] **Step 2: Write the isolated-freeze note** (optional session log only)

Do **not** create `wave-d-r09-results.md` yet if production routing is still pending; or create it with a section “Isolated Generate transaction green; Ready false; 9.5/13.6/10.4 not marked.”

**Stop condition:** If the user asked only for the transaction, execution may pause here. This plan continues to production routing because R09’s restored 13.6 is `Generate` as the canonical `Build()` backend.

---

## Task 6: Production provenance tests (RED) — still no `Build()` implementation

**Files:**
- Create: `SDK/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`

Do not modify `as_module.cpp` / Ready yet. These tests encode the Task 8–10 contract.

**Interfaces:**
- Consumes: `CompileNativeModule`, `GetLastBytecodePublisher`, `IsCanonicalBytecodeCodeGenReady`, `SetCompilerPipeline`
- Produces: production gate that fails while publisher is `COMPILER`

- [ ] **Step 1: Write the failing production tests**

```cpp
#include "AngelscriptTestMacros.h"
#include "../../Support/AngelscriptNativeCanonicalASTTestSupport.h"
#include "../../Support/AngelscriptNativeCoreTestSupport.h"

#include "CQTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_ANGELSCRIPT_UNITTESTS

TEST_CLASS_WITH_FLAGS(FCanonicalASTProductionCodeGenTests,
	"Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
public:
	TEST_METHOD(CanonicalModuleBuildPublishesCodeGenForIntegerReturn)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("production default must stay LEGACY until Wave G")));
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("CANONICAL selection must remain available")));
		ASSERT_THAT(IsTrue(ScriptEngine->IsCanonicalBytecodeCodeGenReady(),
			TEXT("Ready is true only because CANONICAL Build() calls Generate")));

		asIScriptModule* Module = nullptr;
		ASSERT_THAT(AreEqual(0, AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdInt",
			ASTEST_AS_ANSI(R"AS(
				int F()
				{
					return 7;
				}
				)AS"),
			Module)));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptNativeTestSupport::CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 7,
			TEXT("CANONICAL module Build must execute F()==7 from CodeGen")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("CANONICAL Build of int F() must not record asCCompiler")));
	}

	TEST_METHOD(LegacyModuleBuildStillPublishesCompiler)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("new engines stay LEGACY")));
		asIScriptModule* Module = nullptr;
		ASSERT_THAT(AreEqual(0, AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdLegacy",
			ASTEST_AS_ANSI(R"AS(
				int F()
				{
					return 7;
				}
				)AS"),
			Module)));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_COMPILER,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("LEGACY Build must keep asCCompiler")));
	}

	TEST_METHOD(CanonicalValueObjectBuildDoesNotPublishCompiler)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("value-object fixture selects CANONICAL")));
		asIScriptModule* Module = nullptr;
		const int BuildResult = AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdValue",
			ASTEST_AS_ANSI(R"AS(
				class FValue
				{
					int Value = 41;
				}

				int F()
				{
					FValue Object;
					return Object.Value + 1;
				}
				)AS"),
			Module);
		ASSERT_THAT(IsTrue(BuildResult < 0,
			TEXT("R09 must fail closed on script value objects rather than silently use asCCompiler")));
		if (Module != nullptr)
		{
			ASSERT_THAT(AreNotEqual(
				asBYTECODE_PUBLISHER_COMPILER,
				static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
				TEXT("failed CANONICAL Build must not claim asCCompiler publication")));
		}
	}
};

#endif
```

Use `AreNotEqual` if the CQTest matcher exists; otherwise `IsTrue(publisher != asBYTECODE_PUBLISHER_COMPILER)`. Failed `Build` after `InternalReset` should leave publisher `NONE`.

Do **not** implement script-class lowering to make `ProdValue` execute. That is 9.5.

- [ ] **Step 2: Build + run RED**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-prod-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label r09-prod-red -TimeoutMs 600000
```

Expected: `CanonicalModuleBuildPublishesCodeGenForIntegerReturn` FAIL (`Ready==false` and/or publisher `COMPILER`). `LegacyModuleBuildStillPublishesCompiler` PASS. `CanonicalValueObjectBuildDoesNotPublishCompiler` FAIL because today’s CANONICAL `Build` **succeeds through `asCCompiler`** and publisher is `COMPILER` (this is the 虚标 the test is designed to catch).

- [ ] **Step 3: Commit tests only**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp
git commit -m "[AngelscriptTest] Test: require CANONICAL module Build to publish CodeGen and fail closed on script value objects"
```

---

## Task 7: CANONICAL `asCModule::Build` routes to `Generate` (still Ready false)

**Files:**
- Modify: `Fork/as_module.cpp` `asCModule::Build` (`:354-443`)
- Modify: `Fork/as_builder.cpp` `AttachCanonicalSemaIfNeeded` (`:652`)
- Modify: `Fork/as_builder.h` only if adding `BuildCanonicalCodeGen`

Keep `IsCanonicalBytecodeCodeGenReady()` **false** until Task 10 so Cutover does not flip in the same commit as routing (makes the Ready tripwire explicit). Production tests from Task 6 will still fail on Ready until Task 10; publisher assertions should go green here.

**CANONICAL `Build()` sequence (exact):**

```text
existing guards (external refs, RequestBuild, PrepareEngine, configFailed)
astRetentionFrozen = true
InternalReset()
if !builder -> BuildCompleted, success
r = builder->BuildParallelParseScripts()
if pipeline == CANONICAL:
    if builder has no canonicalAST or Sema attach failed -> r = asOUT_OF_MEMORY / asINVALID_CONFIGURATION, fail closed
    Seal pending AST if needed; Seal != OK -> r = that error
    r = asCBytecodeCodeGen().Generate(*sealedContext, this)
    AdoptPendingCanonicalAST(builder->TakeCanonicalAST())
    asDELETE builder; builder = 0
    if r < 0: InternalReset(); BuildCompleted; return r
    JITCompile / PrepareEngine / BuildCompleted / PublishCanonicalASTSnapshot / ResetGlobalVars
    return r
else:
    existing BuildGenerateTypes … BuildCompileCode path
```

Do **not** call `BuildCompileCode` / `CompileFunctions` / factory `asCCompiler` on the CANONICAL path. No fallback.

Do **not** run `BuildGenerateFunctions` + `AllocateGlobalProperty` and then `Generate` on the same module — that double-installs globals/functions. Isolated `Generate` is the installer for functions/globals/funcdefs it emits. Builder type registration (`BuildGenerateTypes` / `CompileClasses`) is **out of the R09 integer subset**; skip it on CANONICAL `Build` in this plan. Script classes therefore fail closed (Task 6 value-object test).

`AttachCanonicalSemaIfNeeded`: when `GetCompilerPipeline()==CANONICAL` and `asNEW` of Context or Sema fails, do not return void-success. Surface an error the parse/build can see (`numErrors++` or return code). Silent continue is forbidden.

`CompileFunction` (`as_builder.cpp:1015`): leave `asCCompiler`. Ready in Task 10 means **module Build**, not CompileFunction.

`PublishCanonicalASTSnapshot`: do not add a new empty-TU fabricate on CANONICAL success. If retain policy is on and Context is missing, fail closed rather than publish a fake graph.

- [ ] **Step 1: Implement the CANONICAL branch in `Build()`**

Include `as_bytecode_codegen.h` from `as_module.cpp` only if that is the production caller (allowed; `as_module.cpp` is already host-contaminated). Do not include `as_compiler.h` from `as_bytecode_codegen.cpp`.

- [ ] **Step 2: Run ProductionCodeGen (Ready still false)**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-prod-route -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label r09-prod-route -TimeoutMs 600000
```

Expected after this task: `CanonicalModuleBuildPublishesCodeGenForIntegerReturn` still FAIL on **Ready false**, but publisher should already be `CANONICAL_CODEGEN` if you temporarily comment Ready — **do not comment it**. Split the Ready assert into Task 10 if you need a green publisher-only run; otherwise accept Ready-red until Task 10.

Implementer option (preferred): in Task 6’s first method, keep both asserts; Task 7 commit may leave that method red; Task 10 turns Ready green in the same Production prefix.

`CanonicalValueObjectBuildDoesNotPublishCompiler` should PASS once CANONICAL `Build` no longer uses Compiler (script class fail closed, publisher `NONE` after `InternalReset`).

`LegacyModuleBuildStillPublishesCompiler` PASS.

- [ ] **Step 3: Transaction + CodeGen prefixes must stay green**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label r09-prod-route-codegen -TimeoutMs 600000
```

- [ ] **Step 4: Commit routing without Ready**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.cpp
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h
git commit -m "[Angelscript] Feat: route CANONICAL module Build through asCBytecodeCodeGen::Generate"
```

Ready still false. Default still LEGACY.

---

## Task 8: Flip Cutover tests that would lock COMPILER after routing

**Files:**
- Modify: `SDK/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`

Routing without updating Cutover will make `SourceBuildPurposesSelectCanonicalAndExecute` fail (it currently requires publisher `COMPILER`). Update **after** Task 7 so the old Cutover was still a valid honesty lock during isolated work.

- [ ] **Step 1: Change publisher expectations for module `Build` purposes**

In `SourceBuildPurposesSelectCanonicalAndExecute`:

- Keep selecting CANONICAL explicitly.
- For purposes that call `CompileNativeModule` / `Module->Build()` (`primary`, `Hot Reload`, `generation`, `commandlet`, `Standalone`): assert `GetLastBytecodePublisher() == asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`.
- For `single-function compile` (`CompileFunction`): keep `asBYTECODE_PUBLISHER_COMPILER` and state in the message that R09 Ready is module-`Build` only.
- Leave Ready asserts until Task 10 (still `false` here), **or** flip Ready in the same Task 10 commit as `as_scriptengine.h`.

`CompileFunctionDoesNotReplaceRetainedModuleSnapshot`: Build publisher becomes `CANONICAL_CODEGEN`; CompileFunction extra still Compiler. Snapshot generation-key lock is Wave E — do not “fix” completeness here.

`CanonicalSelectionStillPublishesValueObjectsThroughCompiler`: **replace**. New contract: CANONICAL `Build` of the script struct fixture fails closed; publisher is not `COMPILER`. Rename the method to `CanonicalSelectionFailsClosedOnScriptValueObjects` so the name cannot launder Compiler success.

`DefaultPipelineIsLegacyReadyIsFalseAndRejectsDual`: default LEGACY + dual reject stay. Ready stays false until Task 10.

`ProductionDefaultDoesNotCaptureHirAndHasNoDualOrLlvm`: unchanged scan. Confirm `as_bytecode_codegen*` still has no `#include "as_compiler.h"`.

- [ ] **Step 2: Run Cutover (Ready still false)**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-cutover-publisher -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label r09-cutover-publisher -TimeoutMs 600000
```

Expected: 5/5 with default LEGACY, Ready false, module-Build publisher CodeGen, value objects fail closed, CompileFunction still Compiler.

- [ ] **Step 3: Commit**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp
git commit -m "[AngelscriptTest] Test: lock CANONICAL module Build publisher to CodeGen without flipping Ready"
```

---

## Task 9: Differential test Ready/publisher (still Ready false in product)

**Files:**
- Modify: `SDK/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp`

`CanonicalSelectionBuildsAndExecutes` currently asserts Ready **false**. After Task 7 it still compiles; after Task 10 Ready must be true. **Do not flip the product Ready here.** Either:

- Wait until Task 10 to edit this file, or
- Split: keep Ready false assert until Task 10, add publisher `CANONICAL_CODEGEN` now.

Preferred: add publisher assert now, keep Ready false until Task 10.

```cpp
ASSERT_THAT(AreEqual(
	asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
	static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
	TEXT("CANONICAL Build of int F() must publish CodeGen")));
```

Include `as_module.h`.

- [ ] **Step 1: Edit + run**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Differential" -Label r09-differential-publisher -TimeoutMs 600000
```

- [ ] **Step 2: Commit with the Cutover commit if uncommitted, else its own commit**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp
git commit -m "[AngelscriptTest] Test: require CANONICAL differential Build publisher CodeGen"
```

---

## Task 10: `IsCanonicalBytecodeCodeGenReady()` true because `Build` publishes CodeGen

**Files:**
- Modify: `Fork/as_scriptengine.h:249-252`
- Modify: Cutover `DefaultPipelineIsLegacyReadyIsFalseAndRejectsDual` and `SourceBuildPurposesSelectCanonicalAndExecute` Ready asserts
- Modify: Differential Ready assert
- Modify: Production `CanonicalModuleBuildPublishesCodeGenForIntegerReturn` (now fully green)
- Modify: `Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp`
- Modify: `Documents/Guides/AngelscriptCanonicalAST.md` (honesty sentences only)

**Ready meaning (copy this comment into the header):**

```cpp
bool IsCanonicalBytecodeCodeGenReady() const
{
	// True because CANONICAL asCModule::Build() calls asCBytecodeCodeGen::Generate().
	// Default pipeline remains LEGACY until Wave G. Isolated Generate() never flipped this.
	return true;
}
```

Not “the class exists”. Not `GetCompilerPipeline()==CANONICAL` (LEGACY engines must still report Ready true as a **binary capability**, so default-LEGACY Cutover can assert Ready true + pipeline LEGACY together).

If you instead make Ready follow the selected pipeline, then default-LEGACY engines stay Ready false and Task 6’s first method (Ready true after `SetCompilerPipeline(CANONICAL)`) still works — **but** Cutover’s default test would keep Ready false forever, which hides whether routing exists. **Use unconditional `return true` after routing exists**, plus default pipeline LEGACY.

- [ ] **Step 1: Flip Ready and the tests that legally required false**

Cutover default method: rename to `DefaultPipelineIsLegacyReadyIsTrueAndRejectsDual` (or keep the name and change the Ready assert only). Assert:

- `GetCompilerPipeline()==LEGACY`
- `IsCanonicalBytecodeCodeGenReady()==true`
- dual reject

SourceBuildPurposes: Ready **true** after CANONICAL select.

Differential: Ready **true**.

Standalone `main`: Ready **true**; default pipeline **LEGACY**; add:

```cpp
bPassed &= Require(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
	"standalone must select CANONICAL");
asIScriptModule* CodeGenModule = Engine->GetModule("canonical-codegen", asGM_ALWAYS_CREATE);
bPassed &= Require(
	CodeGenModule->AddScriptSection("canonical-codegen.as", "int main() { return 42; }") >= 0
		&& CodeGenModule->Build() >= 0,
	"CANONICAL standalone subset Build failed");
bPassed &= Require(
	static_cast<asCModule*>(CodeGenModule)->GetLastBytecodePublisher()
		== asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
	"CANONICAL standalone Build must publish CodeGen");
bPassed &= Require(ExecuteInt(Engine, CodeGenModule, "int main()") == 42,
	"CANONICAL standalone CodeGen returned the wrong result");
```

Keep the existing default-LEGACY discard/retain Builds; they must remain publisher `COMPILER`.

Docs: Ready true; default LEGACY; CANONICAL `Build` is CodeGen for the isolated subset and fail-closed outside it; full language remains LEGACY `asCCompiler`; LLVM non-goal.

- [ ] **Step 2: Run production + Cutover + Differential + Transaction**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-ready -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label r09-ready-txn -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label r09-ready-codegen -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label r09-ready-prod -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label r09-ready-cutover -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Differential" -Label r09-ready-diff -TimeoutMs 600000
```

Expected: all listed prefixes PASS. Transaction retry test’s Ready assert was `IsFalse` — **change it in this task** to `IsTrue` with message `Ready is binary capability after CANONICAL Build routes to Generate; default stays LEGACY`. Do that in the same commit as `as_scriptengine.h`.

- [ ] **Step 3: Standalone**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix r09-ready-standalone -TimeoutMs 600000
```

Expected: Standalone CTest still all pass (current Debug count is independent; do not treat it as UE Automation). CanonicalAST standalone test must see Ready true + default LEGACY + CANONICAL subset publisher CodeGen.

- [ ] **Step 4: Commit plugin then parent**

```powershell
Set-Location D:\as-cta\Plugins\Angelscript
git add Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h
git add Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp
git add Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp
git add Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp
git add Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp
git add Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp
git commit -m "[Angelscript] Feat: report CodeGen Ready after CANONICAL module Build uses Generate"
Set-Location D:\as-cta
git add Plugins/Angelscript
git add Documents/Guides/AngelscriptCanonicalAST.md
git commit -m "[Angelscript] Docs: Ready means CANONICAL Build publishes CodeGen; default stays LEGACY"
```

If `AngelscriptCanonicalAST.md` lives only in the parent, the docs commit is parent-only. If it lives in the plugin README, keep it in the plugin commit. Do not claim 9.5 or default CANONICAL.

---

## Task 11: Wider CanonicalAST regression (not All, not 9.5)

**Files:** none unless a test still asserts Ready false / publisher COMPILER for CANONICAL module `Build`.

- [ ] **Step 1: Compiler.CanonicalAST then Frontend.CanonicalAST**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label r09-canonical-ast -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label r09-frontend-canonical -TimeoutMs 600000
```

Expected: zero failures. Fix only tests that still treat CANONICAL `Build` as Compiler **for the integer subset**. Do not expand CodeGen to satisfy 9.5 fixtures. Isolated differential corpus methods that only call `Generate()` stay isolated.

- [ ] **Step 2: Confirm default pipeline source**

Grep `ep.canonicalCompilerPipeline = false` in `Fork/as_scriptengine.cpp`. Must still be false.

- [ ] **Step 3: Confirm no Compiler fallback**

Grep `asCCompiler` in the new CANONICAL `Build` branch. There must be none. `BuildCompileCode` remains on the LEGACY branch only.

Do **not** run:

```powershell
# FORBIDDEN as an R09 / Wave D gate
Tools\RunTestSuite.ps1 -Suite All
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler"
```

A green Compiler prefix under LEGACY default is not CodeGen evidence. 9.7 / 10.9 / 12.4 stay later waves.

---

## Task 12: Record results — still do not check 9.5 / 13.6 / 10.4

**Files:**
- Create: `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-d-r09-results.md`

- [ ] **Step 1: Write the evidence file**

Include: worktree `D:\as-cta`, command labels, `total/passed/failed/skipped` for Transaction, CodeGen, ProductionCodeGen, Cutover, Differential, Frontend CanonicalAST, Compiler CanonicalAST, Standalone. Quote Ready true, default LEGACY, CANONICAL `int F()` publisher `CANONICAL_CODEGEN`, value-object CANONICAL `Build` fail closed, CompileFunction still `COMPILER`. Explicit sentence: **did not check `tasks.md` 9.1 / 9.5 / 9.6 / 9.7 / 10.4 / 13.1 / 13.6**.

- [ ] **Step 2: Parent commit for the attachment**

```powershell
Set-Location D:\as-cta
git add openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-d-r09-results.md
git commit -m "[OpenSpec] Docs: record Wave D R09 isolated transaction and production Build routing evidence"
```

---

## Exact command sheet (always `Set-Location D:\as-cta` first)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label <label> -TimeoutMs 1800000 -NoXGE

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Differential" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label <label> -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix <label> -TimeoutMs 600000
```

`ProjectFile` / `EngineRoot` come from `D:\as-cta\AgentConfig.ini`. Do not invoke `UnrealEditor-Cmd.exe` or `Build.bat` directly.

---

## Out of scope (hard no)

- Clang, LLVM, `llvm::`, `clangAST`, linking either library.
- Unreal types in `as_bytecode_codegen*`, `as_ast_*`, `as_sema*`, `as_source_manager*`.
- Growing CodeGen language coverage in Tasks 1–7 (no script structs, no new containers, no import lowering, no exception/debug metadata program).
- Default `canonicalCompilerPipeline = true` (Wave G).
- Deleting `asCCompiler`.
- Marking `tasks.md` 9.5 / 13.6 / 10.4 / 13.1 / 9.1 from isolated or even production greens (rereview only).
- Wave E mid-vtable / `structSize` / atomic snapshot swap.
- Wave F sidecar DTO / ExactStartup.
- Remaining Wave C construction APIs (`AddDeclChild` / private builders).
- `CompileFunction` CodeGen routing (not Ready’s definition in this plan).
- All-suite / full SDK Compiler/Runtime/Language prefixes as an R09 gate (9.7).

---

## Self-review

1. **Spec coverage:** R09 detached artifact, atomic install, rollback of functions/globals/funcdefs/types, production `Build` → `Generate`, Ready only after that publisher, LEGACY default — each has a task. 9.5 language growth intentionally absent.
2. **Placeholder scan:** no TBD / “handle edge cases” / “similar to Task N” without the actual fixture.
3. **Type consistency:** `Generate(const asCASTContext&, asCModule*)` never changes. Artifact is `asSBytecodeCodeGenArtifact`. Publisher enum values unchanged. Ready is `bool` on `asCScriptEngine`.
4. **Order:** Tasks 1–5 isolated Generate only; Tasks 6–12 production. Ready false until Task 10.
5. **Honesty:** isolated greens do not flip Cutover; value objects fail closed rather than Compiler-under-CANONICAL.

Plan complete. Execution starts at Task 0 preflight from `D:\as-cta`.
