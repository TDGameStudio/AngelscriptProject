// =============================================================================
// AngelscriptThirdPartyLibTests.cpp
//
// Tests for AngelscriptThirdPartyLib.cpp - validates the SDK integration layer.
// Automation IDs: Angelscript.TestModule.CppTests.ThirdPartyLib.*
// =============================================================================

#include "Misc/AutomationTest.h"
#include "AngelscriptInclude.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptThirdPartyLibVersionTest,
	"Angelscript.TestModule.CppTests.ThirdPartyLib.VersionString",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptThirdPartyLibCreateReleaseTest,
	"Angelscript.TestModule.CppTests.ThirdPartyLib.CreateAndRelease",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptThirdPartyLibEnginePropertyTest,
	"Angelscript.TestModule.CppTests.ThirdPartyLib.EngineProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

// ---------------------------------------------------------------------------
// VersionString - asGetLibraryVersion returns non-empty string
// ---------------------------------------------------------------------------

bool FAngelscriptThirdPartyLibVersionTest::RunTest(const FString& Parameters)
{
	const char* Version = asGetLibraryVersion();
	TestNotNull(TEXT("asGetLibraryVersion should return non-null"), Version);
	if (Version != nullptr)
	{
		const FString VersionStr = UTF8_TO_TCHAR(Version);
		TestFalse(TEXT("Version string should not be empty"), VersionStr.IsEmpty());
		AddInfo(FString::Printf(TEXT("AngelScript SDK version: %s"), *VersionStr));
	}
	return true;
}

// ---------------------------------------------------------------------------
// CreateAndRelease - engine create/shutdown cycle without leaks
// ---------------------------------------------------------------------------

bool FAngelscriptThirdPartyLibCreateReleaseTest::RunTest(const FString& Parameters)
{
	asIScriptEngine* Engine = asCreateScriptEngine(ANGELSCRIPT_VERSION);
	TestNotNull(TEXT("asCreateScriptEngine should return non-null"), Engine);

	if (Engine != nullptr)
	{
		// Verify we can query basic properties
		const int EngineVersion = Engine->GetEngineProperty(asEP_OPTIMIZE_BYTECODE);
		TestTrue(TEXT("GetEngineProperty should return a valid value"),
			EngineVersion >= 0);

		Engine->ShutDownAndRelease();
	}

	return true;
}

// ---------------------------------------------------------------------------
// EngineProperty - SetEngineProperty returns asSUCCESS
// ---------------------------------------------------------------------------

bool FAngelscriptThirdPartyLibEnginePropertyTest::RunTest(const FString& Parameters)
{
	asIScriptEngine* Engine = asCreateScriptEngine(ANGELSCRIPT_VERSION);
	if (!TestNotNull(TEXT("Should create engine"), Engine))
	{
		return false;
	}

	const int Result1 = Engine->SetEngineProperty(asEP_ALLOW_UNSAFE_REFERENCES, 1);
	TestEqual(TEXT("SetEngineProperty(ALLOW_UNSAFE_REFERENCES) should succeed"),
		Result1, static_cast<int>(asSUCCESS));

	const int Result2 = Engine->SetEngineProperty(asEP_USE_CHARACTER_LITERALS, 1);
	TestEqual(TEXT("SetEngineProperty(USE_CHARACTER_LITERALS) should succeed"),
		Result2, static_cast<int>(asSUCCESS));

	const int Result3 = Engine->SetEngineProperty(asEP_ALLOW_MULTILINE_STRINGS, 1);
	TestEqual(TEXT("SetEngineProperty(ALLOW_MULTILINE_STRINGS) should succeed"),
		Result3, static_cast<int>(asSUCCESS));

	// Verify the property was actually set
	const asPWORD Value = Engine->GetEngineProperty(asEP_ALLOW_UNSAFE_REFERENCES);
	TestEqual(TEXT("GetEngineProperty should return the set value"),
		static_cast<int32>(Value), 1);

	Engine->ShutDownAndRelease();
	return true;
}

#endif // WITH_DEV_AUTOMATION_TESTS
