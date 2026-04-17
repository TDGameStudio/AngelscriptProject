#include "Angelscript/AngelscriptTestSupport.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "Misc/AutomationTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_builder.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptBuilderTests_Private
{
	asCModule* CreateBuilderModule(asCScriptEngine* ScriptEngine, const char* ModuleName)
	{
		return static_cast<asCModule*>(ScriptEngine->GetModule(ModuleName, asGM_ALWAYS_CREATE));
	}
}

using namespace AngelscriptTest_Internals_AngelscriptBuilderTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBuilderSingleModulePipelineTest,
	"Angelscript.TestModule.Internals.Builder.SingleModulePipeline",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBuilderCompileErrorCollectionTest,
	"Angelscript.TestModule.Internals.Builder.CompileErrors",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBuilderRebuildModuleTest,
	"Angelscript.TestModule.Internals.Builder.RebuildModule",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBuilderImportBindingTest,
	"Angelscript.TestModule.Internals.Builder.ImportBinding",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBuilderSingleModulePipelineTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"BuilderSinglePipeline",
		TEXT("int Entry() { return 42; }"));
	if (!TestNotNull(TEXT("Builder single-module test should create a backing module"), Module))
	{
		return false;
	}
	asIScriptFunction* Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (!TestNotNull(TEXT("Builder single-module pipeline should expose the compiled function"), Function))
	{
		return false;
	}

	int32 Result = 0;
	if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("Builder single-module pipeline should execute the compiled function"), Result, 42);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptBuilderCompileErrorCollectionTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
	asCModule* Module = CreateBuilderModule(ScriptEngine, "BuilderCompileErrors");
	if (!TestNotNull(TEXT("Builder compile-error test should create a backing module"), Module))
	{
		return false;
	}

	asCBuilder Builder(ScriptEngine, Module);
	Builder.silent = true;
	asCScriptFunction* Function = nullptr;
	const int32 BuildResult = Builder.CompileFunction("BuilderCompileErrors", "int Entry( { return 42; }", 0, 0, &Function);
	TestTrue(TEXT("Builder should report invalid syntax as a build failure"), BuildResult < 0);
	TestEqual(TEXT("Builder compile-error test should not return a compiled function on failure"), Function, static_cast<asCScriptFunction*>(nullptr));
	bPassed = BuildResult < 0;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptBuilderRebuildModuleTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* ModuleV1 = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"BuilderRebuild",
		TEXT("int Entry() { return 1; }"));
	if (!TestNotNull(TEXT("Builder rebuild test should create the initial backing module"), ModuleV1))
	{
		return false;
	}
	asIScriptFunction* FunctionV1 = AngelscriptTestSupport::GetFunctionByDecl(*this, *ModuleV1, TEXT("int Entry()"));
	if (!TestNotNull(TEXT("Initial builder rebuild compile should expose Entry()"), FunctionV1))
	{
		return false;
	}

	int32 FirstResult = 0;
	if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *FunctionV1, FirstResult))
	{
		return false;
	}
	TestEqual(TEXT("Initial builder rebuild function should return the first version"), FirstResult, 1);

	asIScriptModule* ModuleV2 = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"BuilderRebuild",
		TEXT("int Entry() { return 2; }"));
	if (!TestNotNull(TEXT("Builder rebuild test should create the rebuilt module"), ModuleV2))
	{
		return false;
	}
	asIScriptFunction* FunctionV2 = AngelscriptTestSupport::GetFunctionByDecl(*this, *ModuleV2, TEXT("int Entry()"));
	if (!TestNotNull(TEXT("Rebuilt builder module should expose Entry()"), FunctionV2))
	{
		return false;
	}

	int32 SecondResult = 0;
	if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *FunctionV2, SecondResult))
	{
		return false;
	}
	TestEqual(TEXT("Rebuilt builder module should execute the latest function body"), SecondResult, 2);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptBuilderImportBindingTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	asIScriptModule* SourceModule = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"BuilderImportSource",
		TEXT("int SharedValue() { return 77; }"));
	asIScriptModule* ConsumerModule = AngelscriptTestSupport::BuildModule(
		*this,
		Engine,
		"BuilderImportConsumer",
		TEXT("import int SharedValue() from \"BuilderImportSource\"; int Entry() { return SharedValue(); }"));
	if (!TestNotNull(TEXT("Builder import test should create the source module"), SourceModule) ||
		!TestNotNull(TEXT("Builder import test should create the consumer module"), ConsumerModule))
	{
		return false;
	}

	TestEqual(TEXT("Consumer module should expose one imported function before binding"), static_cast<int32>(ConsumerModule->GetImportedFunctionCount()), 1);
	TestEqual(TEXT("Imported function should point to the expected source module"), FString(UTF8_TO_TCHAR(ConsumerModule->GetImportedFunctionSourceModule(0))), FString(TEXT("BuilderImportSource")));

	asIScriptFunction* SourceFunction = SourceModule->GetFunctionByDecl("int SharedValue()");
	if (!TestNotNull(TEXT("Builder import test should expose the source function for binding"), SourceFunction))
	{
		return false;
	}

	if (!TestEqual(TEXT("BindImportedFunction should resolve the imported function"), ConsumerModule->BindImportedFunction(0, SourceFunction), static_cast<int32>(asSUCCESS)))
	{
		return false;
	}

	asIScriptFunction* EntryFunction = AngelscriptTestSupport::GetFunctionByDecl(*this, *ConsumerModule, TEXT("int Entry()"));
	if (!TestNotNull(TEXT("Consumer module should expose Entry() after import binding"), EntryFunction))
	{
		return false;
	}

	int32 Result = 0;
	if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	TestEqual(TEXT("Imported function binding should let the consumer execute the source function"), Result, 77);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
