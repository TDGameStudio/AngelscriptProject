#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGlobalInitContextHotReloadNameFunctionLibraryTest,
	"Angelscript.TestModule.FunctionLibraries.GlobalInitContextHotReloadName",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptScriptFunctionLibraryTests_Private
{
	static const FName ScriptFunctionLibraryModuleName(TEXT("ASGlobalInitContext_HotReload_42"));
	static const FString ScriptFunctionLibraryFilename(TEXT("ASGlobalInitContext_HotReload_42.as"));
	static const FString DirectScriptFunctionLibraryModuleName(TEXT("ASGlobalInitContext_Stable"));
	static const FString ScriptFunctionLibraryNamespace(TEXT("ScopedContext"));
	static const FString HotReloadMarker(TEXT("_NEW_"));

	template <typename TValue>
	bool ReadReturnValue(FAutomationTestBase& Test, asIScriptContext& Context, TValue& OutValue)
	{
		void* ReturnValueAddress = Context.GetAddressOfReturnValue();
		return Test.TestNotNull(
				TEXT("Script function library global-init test should expose return value storage"),
				ReturnValueAddress)
			&& (OutValue = *static_cast<TValue*>(ReturnValueAddress), true);
	}

	template <typename TValue>
	bool ExecuteValueFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const FString& FunctionDecl,
		TValue& OutValue)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(
				TEXT("Script function library global-init test should create an execution context"),
				Context))
		{
			return false;
		}

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
				TEXT("Script function library global-init test should prepare the target function"),
				PrepareResult,
				asSUCCESS))
		{
			Context->Release();
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
				TEXT("Script function library global-init test should execute the target function"),
				ExecuteResult,
				asEXECUTION_FINISHED))
		{
			if (ExecuteResult == asEXECUTION_EXCEPTION && Context->GetExceptionString() != nullptr)
			{
				Test.AddError(FString::Printf(
					TEXT("Script function library global-init test saw a script exception: %s"),
					UTF8_TO_TCHAR(Context->GetExceptionString())));
			}

			Context->Release();
			return false;
		}

		const bool bReadReturnValue = ReadReturnValue(Test, *Context, OutValue);
		Context->Release();
		return bReadReturnValue;
	}

	asIScriptModule* GetCompiledModule(FAutomationTestBase& Test, FAngelscriptEngine& Engine)
	{
		TSharedPtr<FAngelscriptModuleDesc> ModuleDesc = Engine.GetModule(ScriptFunctionLibraryModuleName.ToString());
		if (!Test.TestTrue(
				TEXT("Script function library global-init test should keep the module registered after compile"),
				ModuleDesc.IsValid()))
		{
			return nullptr;
		}

		asIScriptModule* Module = ModuleDesc.IsValid() ? ModuleDesc->ScriptModule : nullptr;
		if (!Test.TestNotNull(
				TEXT("Script function library global-init test should expose the backing asIScriptModule"),
				Module))
		{
			return nullptr;
		}

		return Module;
	}

	FString BuildScriptSource(const int32 Version)
	{
		return FString::Printf(TEXT(R"(
const FString PlainNameCapture = Script::GetNameOfGlobalVariableBeingInitialized();
const FString PlainNamespaceCapture = Script::GetNamespaceOfGlobalVariableBeingInitialized();
const FString PlainModuleCapture = Script::GetModuleNameOfGlobalVariableBeingInitialized();

namespace %s
{
	const FString ScopedNameCapture = Script::GetNameOfGlobalVariableBeingInitialized();
	const FString ScopedNamespaceCapture = Script::GetNamespaceOfGlobalVariableBeingInitialized();
	const FString ScopedModuleCapture = Script::GetModuleNameOfGlobalVariableBeingInitialized();
}

FString GetPlainNameCapture() { return PlainNameCapture; }
FString GetPlainNamespaceCapture() { return PlainNamespaceCapture; }
FString GetPlainModuleCapture() { return PlainModuleCapture; }

FString GetScopedNameCapture() { return %s::ScopedNameCapture; }
FString GetScopedNamespaceCapture() { return %s::ScopedNamespaceCapture; }
FString GetScopedModuleCapture() { return %s::ScopedModuleCapture; }

FString GetOutsideInitName() { return Script::GetNameOfGlobalVariableBeingInitialized(); }
FString GetOutsideInitNamespace() { return Script::GetNamespaceOfGlobalVariableBeingInitialized(); }
FString GetOutsideInitModule() { return Script::GetModuleNameOfGlobalVariableBeingInitialized(); }

int GetVersion() { return %d; }
)"),
			*ScriptFunctionLibraryNamespace,
			*ScriptFunctionLibraryNamespace,
			*ScriptFunctionLibraryNamespace,
			*ScriptFunctionLibraryNamespace,
			Version);
	}

	FString BuildDirectContextScriptSource()
	{
		return FString::Printf(TEXT(R"(
const FString PlainNameCapture = Script::GetNameOfGlobalVariableBeingInitialized();
const FString PlainNamespaceCapture = Script::GetNamespaceOfGlobalVariableBeingInitialized();
const FString PlainModuleCapture = Script::GetModuleNameOfGlobalVariableBeingInitialized();

namespace %s
{
	const FString ScopedNameCapture = Script::GetNameOfGlobalVariableBeingInitialized();
	const FString ScopedNamespaceCapture = Script::GetNamespaceOfGlobalVariableBeingInitialized();
	const FString ScopedModuleCapture = Script::GetModuleNameOfGlobalVariableBeingInitialized();
}

FString GetPlainNameCapture() { return PlainNameCapture; }
FString GetPlainNamespaceCapture() { return PlainNamespaceCapture; }
FString GetPlainModuleCapture() { return PlainModuleCapture; }

FString GetScopedNameCapture() { return %s::ScopedNameCapture; }
FString GetScopedNamespaceCapture() { return %s::ScopedNamespaceCapture; }
FString GetScopedModuleCapture() { return %s::ScopedModuleCapture; }

FString GetOutsideInitName() { return Script::GetNameOfGlobalVariableBeingInitialized(); }
FString GetOutsideInitNamespace() { return Script::GetNamespaceOfGlobalVariableBeingInitialized(); }
FString GetOutsideInitModule() { return Script::GetModuleNameOfGlobalVariableBeingInitialized(); }
)"),
			*ScriptFunctionLibraryNamespace,
			*ScriptFunctionLibraryNamespace,
			*ScriptFunctionLibraryNamespace,
			*ScriptFunctionLibraryNamespace);
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptScriptFunctionLibraryTests_Private;

bool FAngelscriptGlobalInitContextHotReloadNameFunctionLibraryTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ScriptFunctionLibraryModuleName.ToString());
	};

	ECompileResult InitialCompileResult = ECompileResult::Error;
	if (!CompileModuleWithResult(
			&Engine,
			ECompileType::Initial,
			ScriptFunctionLibraryModuleName,
			ScriptFunctionLibraryFilename,
			BuildScriptSource(1),
			InitialCompileResult))
	{
		return false;
	}

	int32 InitialVersion = 0;
	if (!ExecuteIntFunction(&Engine, ScriptFunctionLibraryModuleName, TEXT("int GetVersion()"), InitialVersion))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Script function library global-init test should load the initial module before hot reload"),
		InitialVersion,
		1);

	ECompileResult ReloadCompileResult = ECompileResult::Error;
	if (!CompileModuleWithResult(
			&Engine,
			ECompileType::FullReload,
			ScriptFunctionLibraryModuleName,
			ScriptFunctionLibraryFilename,
			BuildScriptSource(2),
			ReloadCompileResult))
	{
		return false;
	}

	asIScriptModule* Module = GetCompiledModule(*this, Engine);
	if (Module == nullptr)
	{
		return false;
	}

	int32 ReloadedVersion = 0;
	if (!ExecuteIntFunction(&Engine, ScriptFunctionLibraryModuleName, TEXT("int GetVersion()"), ReloadedVersion))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Script function library global-init test should expose the reloaded module version"),
		ReloadedVersion,
		2);

	FString PlainNameCapture;
	FString PlainNamespaceCapture;
	FString PlainModuleCapture;
	FString ScopedNameCapture;
	FString ScopedNamespaceCapture;
	FString ScopedModuleCapture;
	FString OutsideInitName;
	FString OutsideInitNamespace;
	FString OutsideInitModule;

	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetPlainNameCapture()"), PlainNameCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetPlainNamespaceCapture()"), PlainNamespaceCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetPlainModuleCapture()"), PlainModuleCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetScopedNameCapture()"), ScopedNameCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetScopedNamespaceCapture()"), ScopedNamespaceCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetScopedModuleCapture()"), ScopedModuleCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetOutsideInitName()"), OutsideInitName);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetOutsideInitNamespace()"), OutsideInitNamespace);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetOutsideInitModule()"), OutsideInitModule);

	const FString ExpectedHotReloadPrefix = ScriptFunctionLibraryModuleName.ToString() + HotReloadMarker;

	bPassed &= TestEqual(
		TEXT("Plain global variable init should report the current variable name"),
		PlainNameCapture,
		TEXT("PlainNameCapture"));
	bPassed &= TestEqual(
		TEXT("Plain global variable init should report an empty namespace"),
		PlainNamespaceCapture,
		TEXT(""));
	bPassed &= TestEqual(
		TEXT("Namespaced global variable init should report the current variable name"),
		ScopedNameCapture,
		TEXT("ScopedNameCapture"));
	bPassed &= TestEqual(
		TEXT("Namespaced global variable init should report its namespace"),
		ScopedNamespaceCapture,
		ScriptFunctionLibraryNamespace);
	bPassed &= TestEqual(
		TEXT("Plain and namespaced module captures should agree on the active reload module name"),
		ScopedModuleCapture,
		PlainModuleCapture);
	bPassed &= TestTrue(
		TEXT("Global init module capture should preserve the hot-reload temporary module suffix"),
		PlainModuleCapture.StartsWith(ExpectedHotReloadPrefix));
	bPassed &= TestTrue(
		TEXT("Global init module capture should keep the explicit user suffix when the reload temporary name is reported"),
		PlainModuleCapture.Contains(TEXT("_HotReload_42_NEW_")));
	bPassed &= TestEqual(
		TEXT("Outside initialization the global-name helper should return an empty string"),
		OutsideInitName,
		TEXT(""));
	bPassed &= TestEqual(
		TEXT("Outside initialization the namespace helper should return an empty string"),
		OutsideInitNamespace,
		TEXT(""));
	bPassed &= TestEqual(
		TEXT("Outside initialization the module helper should return an empty string"),
		OutsideInitModule,
		TEXT(""));

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGlobalInitContextFunctionLibraryTest,
	"Angelscript.TestModule.FunctionLibraries.GlobalInitContext",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGlobalInitContextFunctionLibraryTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	asIScriptModule* Module = nullptr;
	ASTEST_BUILD_MODULE(
		Engine,
		"ASGlobalInitContext_Stable",
		BuildDirectContextScriptSource(),
		Module);

	FString PlainNameCapture;
	FString PlainNamespaceCapture;
	FString PlainModuleCapture;
	FString ScopedNameCapture;
	FString ScopedNamespaceCapture;
	FString ScopedModuleCapture;
	FString OutsideInitName;
	FString OutsideInitNamespace;
	FString OutsideInitModule;

	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetPlainNameCapture()"), PlainNameCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetPlainNamespaceCapture()"), PlainNamespaceCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetPlainModuleCapture()"), PlainModuleCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetScopedNameCapture()"), ScopedNameCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetScopedNamespaceCapture()"), ScopedNamespaceCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetScopedModuleCapture()"), ScopedModuleCapture);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetOutsideInitName()"), OutsideInitName);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetOutsideInitNamespace()"), OutsideInitNamespace);
	bPassed &= ExecuteValueFunction(*this, Engine, *Module, TEXT("FString GetOutsideInitModule()"), OutsideInitModule);

	bPassed &= TestEqual(
		TEXT("Plain global variable init should report the current variable name"),
		PlainNameCapture,
		TEXT("PlainNameCapture"));
	bPassed &= TestEqual(
		TEXT("Plain global variable init should report an empty namespace"),
		PlainNamespaceCapture,
		TEXT(""));
	bPassed &= TestEqual(
		TEXT("Plain global variable init should report the direct module name"),
		PlainModuleCapture,
		DirectScriptFunctionLibraryModuleName);
	bPassed &= TestEqual(
		TEXT("Namespaced global variable init should report the current variable name"),
		ScopedNameCapture,
		TEXT("ScopedNameCapture"));
	bPassed &= TestEqual(
		TEXT("Namespaced global variable init should report its namespace"),
		ScopedNamespaceCapture,
		ScriptFunctionLibraryNamespace);
	bPassed &= TestEqual(
		TEXT("Namespaced global variable init should report the direct module name"),
		ScopedModuleCapture,
		DirectScriptFunctionLibraryModuleName);
	bPassed &= TestEqual(
		TEXT("Plain and namespaced global variable init should agree on the direct module name"),
		ScopedModuleCapture,
		PlainModuleCapture);
	bPassed &= TestEqual(
		TEXT("Outside initialization the global-name helper should return an empty string"),
		OutsideInitName,
		TEXT(""));
	bPassed &= TestEqual(
		TEXT("Outside initialization the namespace helper should return an empty string"),
		OutsideInitNamespace,
		TEXT(""));
	bPassed &= TestEqual(
		TEXT("Outside initialization the module helper should return an empty string"),
		OutsideInitModule,
		TEXT(""));

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
