// =============================================================================
// AngelscriptStateDumpTests.cpp
//
// Tests for FAngelscriptStateDump — validates dump utility functions.
// Automation IDs: Angelscript.TestModule.CppTests.StateDump.*
// =============================================================================

#include "Misc/AutomationTest.h"
#include "Dump/AngelscriptStateDump.h"
// TODO: "Shared/AngelscriptTestMacros.h" does not exist in AngelscriptRuntime module.
//       This test was likely written for AngelscriptTest module but misplaced. Disabled.
// #include "Shared/AngelscriptTestMacros.h"

#if 0 // WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

// -----------------------------------------------------------------------------
// Test: DumpAll produces non-empty result with a valid engine
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptStateDumpAll,
	"Angelscript.TestModule.CppTests.StateDump.DumpAllReturnsPath",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptStateDumpAll::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();

	FString TempDir = FPaths::ProjectSavedDir() / TEXT("Tests") / TEXT("StateDumpTest");
	FString Result = FAngelscriptStateDump::DumpAll(Engine, TempDir);
	TestTrue(TEXT("DumpAll returns non-empty path"), !Result.IsEmpty());

	// Cleanup
	IFileManager::Get().DeleteDirectory(*TempDir, false, true);
	return true;
}

// -----------------------------------------------------------------------------
// Test: DumpAll with empty output dir uses default (doesn't crash)
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptStateDumpDefaultDir,
	"Angelscript.TestModule.CppTests.StateDump.DumpAllDefaultDirNoCrash",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptStateDumpDefaultDir::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
	// Empty string should use internal default — no crash
	FString Result = FAngelscriptStateDump::DumpAll(Engine, TEXT(""));
	TestTrue(TEXT("DumpAll with empty dir returns non-empty path"), !Result.IsEmpty());
	return true;
}

// -----------------------------------------------------------------------------
// Test: OnDumpExtensions delegate can be bound without crash
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptStateDumpExtensionsDelegate,
	"Angelscript.TestModule.CppTests.StateDump.ExtensionsDelegateBind",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptStateDumpExtensionsDelegate::RunTest(const FString& Parameters)
{
	bool bCalled = false;
	FDelegateHandle Handle = FAngelscriptStateDump::OnDumpExtensions.AddLambda(
		[&bCalled](const FString& OutputDir)
		{
			bCalled = true;
		});

	FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();
	FString TempDir = FPaths::ProjectSavedDir() / TEXT("Tests") / TEXT("StateDumpExtTest");
	FAngelscriptStateDump::DumpAll(Engine, TempDir);

	TestTrue(TEXT("Extension delegate was called during DumpAll"), bCalled);

	FAngelscriptStateDump::OnDumpExtensions.Remove(Handle);
	IFileManager::Get().DeleteDirectory(*TempDir, false, true);
	return true;
}

#endif
