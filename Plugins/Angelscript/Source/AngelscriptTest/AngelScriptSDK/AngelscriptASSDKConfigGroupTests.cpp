// AngelscriptASSDKConfigGroupTests.cpp
// Tests for as_configgroup.cpp - type registration group management.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.ConfigGroup.*

#include "AngelscriptNativeTestSupport.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKConfigGroupBeginEndTest,
	"Angelscript.TestModule.AngelScriptSDK.ConfigGroup.BeginEnd",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKConfigGroupRemoveTest,
	"Angelscript.TestModule.AngelScriptSDK.ConfigGroup.RemoveCleansTypes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKConfigGroupNestedErrorTest,
	"Angelscript.TestModule.AngelScriptSDK.ConfigGroup.NestedError",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASSDKConfigGroupBeginEndTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

	int R = SE->BeginConfigGroup("TestGroup");
	TestTrue(TEXT("BeginConfigGroup should succeed"), R >= 0);

	R = SE->RegisterGlobalFunction("int TestGroupFunc()", asFUNCTION(+[]() -> int { return 99; }), asCALL_CDECL);
	TestTrue(TEXT("Register in group should succeed"), R >= 0);

	R = SE->EndConfigGroup();
	TestTrue(TEXT("EndConfigGroup should succeed"), R >= 0);

	// Verify function is accessible
	asIScriptModule* M = BuildNativeModule(SE, "CfgGroupTest", "int Entry() { return TestGroupFunc(); }\n");
	TestNotNull(TEXT("Module using group function should compile"), M);

	return true;
}

bool FAngelscriptASSDKConfigGroupRemoveTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

	SE->BeginConfigGroup("RemovableGroup");
	SE->RegisterGlobalFunction("int RemovableFunc()", asFUNCTION(+[]() -> int { return 1; }), asCALL_CDECL);
	SE->EndConfigGroup();

	int R = SE->RemoveConfigGroup("RemovableGroup");
	TestTrue(TEXT("RemoveConfigGroup should succeed"), R >= 0);

	// After removal, function should not be available
	Messages.Reset();
	asIScriptModule* M = BuildNativeModule(SE, "AfterRemove", "int Entry() { return RemovableFunc(); }\n");
	TestNull(TEXT("Module using removed group function should fail to compile"), M);

	return true;
}

bool FAngelscriptASSDKConfigGroupNestedErrorTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

	int R1 = SE->BeginConfigGroup("Outer");
	TestTrue(TEXT("First BeginConfigGroup should succeed"), R1 >= 0);

	// Nested begin should fail
	int R2 = SE->BeginConfigGroup("Inner");
	TestTrue(TEXT("Nested BeginConfigGroup should fail"), R2 < 0);

	SE->EndConfigGroup();
	return true;
}

#endif // WITH_DEV_AUTOMATION_TESTS
