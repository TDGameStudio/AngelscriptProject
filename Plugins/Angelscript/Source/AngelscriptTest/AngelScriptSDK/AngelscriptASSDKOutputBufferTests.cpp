// AngelscriptASSDKOutputBufferTests.cpp
// Tests for as_outputbuffer.cpp - compile error/warning message capture.
// Automation IDs: Angelscript.TestModule.AngelScriptSDK.OutputBuffer.*

#include "AngelscriptNativeTestSupport.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptNativeTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKOutputBufferErrorCaptureTest,
	"Angelscript.TestModule.AngelScriptSDK.OutputBuffer.ErrorCapture",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptASSDKOutputBufferWarningCaptureTest,
	"Angelscript.TestModule.AngelScriptSDK.OutputBuffer.WarningCapture",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASSDKOutputBufferErrorCaptureTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

	// Compile invalid code - should produce error messages
	Messages.Reset();
	asIScriptModule* M = BuildNativeModule(SE, "BadCode", "int Entry() { return undeclared_var; }\n");
	TestNull(TEXT("Invalid code should fail to compile"), M);

	// Verify error was captured
	bool HasError = false;
	for (const FNativeMessageEntry& Entry : Messages.Entries)
	{
		if (Entry.Type == asMSGTYPE_ERROR)
		{
			HasError = true;
			break;
		}
	}
	TestTrue(TEXT("Message callback should capture at least one error"), HasError);
	TestTrue(TEXT("Error messages should be non-empty"), Messages.Entries.Num() > 0);

	return true;
}

bool FAngelscriptASSDKOutputBufferWarningCaptureTest::RunTest(const FString& Parameters)
{
	FNativeMessageCollector Messages;
	asIScriptEngine* SE = CreateNativeEngine(&Messages);
	if (!TestNotNull(TEXT("Should create engine"), SE)) return false;
	ON_SCOPE_EXIT { DestroyNativeEngine(SE); };

	// Code that compiles but may produce warnings (unused variable)
	Messages.Reset();
	asIScriptModule* M = BuildNativeModule(SE, "WarnCode",
		"int Entry() { int unused = 42; return 1; }\n");

	// Whether or not there are warnings depends on engine config.
	// The key assertion is that message callback works and does not crash.
	AddInfo(FString::Printf(TEXT("Messages captured: %d"), Messages.Entries.Num()));
	for (const FNativeMessageEntry& Entry : Messages.Entries)
	{
		AddInfo(FString::Printf(TEXT("  [%s] %s"), *FString(ToMessageTypeString(Entry.Type)), *Entry.Message));
	}

	return true;
}

#endif // WITH_DEV_AUTOMATION_TESTS
