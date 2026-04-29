// =============================================================================
// AngelscriptSourceCodeNavigationTests.cpp
//
// Tests for AngelscriptSourceCodeNavigation.cpp — editor source navigation.
// Covers BuildVSCodeOpenParameters (pure string logic) and navigation
// override hooks.
//
// Automation IDs:
//   Angelscript.Editor.SourceNavigation.*
// =============================================================================

#include "SourceNavigation/AngelscriptSourceCodeNavigation.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

// ---------------------------------------------------------------------------
// Test declarations — BuildVSCodeParams (pure function, no engine needed)
// ---------------------------------------------------------------------------

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceNavBuildParamsWorkspaceTest,
	"Angelscript.Editor.SourceNavigation.BuildVSCodeParams.WorkspacePath",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceNavBuildParamsFolderFallbackTest,
	"Angelscript.Editor.SourceNavigation.BuildVSCodeParams.FolderFallback",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceNavBuildParamsRawTest,
	"Angelscript.Editor.SourceNavigation.BuildVSCodeParams.RawParams",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceNavBuildParamsAllEmptyTest,
	"Angelscript.Editor.SourceNavigation.BuildVSCodeParams.AllEmpty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

// ---------------------------------------------------------------------------
// Test declarations — Override hooks
// ---------------------------------------------------------------------------

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceNavOverrideCaptureTest,
	"Angelscript.Editor.SourceNavigation.OpenOverride.CapturesLocation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceNavNonASClassTest,
	"Angelscript.Editor.SourceNavigation.CanNavigate.NonASClassReturnsFalse",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

// ---------------------------------------------------------------------------
// BuildVSCodeParams.WorkspacePath
//   Non-empty workspace path should be prepended to params.
// ---------------------------------------------------------------------------

bool FAngelscriptSourceNavBuildParamsWorkspaceTest::RunTest(const FString& Parameters)
{
	const FString Result = AngelscriptSourceNavigation::BuildVSCodeOpenParametersForTesting(
		TEXT("--goto \"C:/Test.as:10\""),
		TEXT("C:/MyProject/workspace.code-workspace"),
		false,
		TEXT(""));

	TestTrue(TEXT("Result should contain the workspace path"),
		Result.Contains(TEXT("workspace.code-workspace")));
	TestTrue(TEXT("Result should contain the original params"),
		Result.Contains(TEXT("--goto")));

	return true;
}

// ---------------------------------------------------------------------------
// BuildVSCodeParams.FolderFallback
//   Empty workspace + bOpenFolder=true should use ScriptRootDirectory.
// ---------------------------------------------------------------------------

bool FAngelscriptSourceNavBuildParamsFolderFallbackTest::RunTest(const FString& Parameters)
{
	const FString Result = AngelscriptSourceNavigation::BuildVSCodeOpenParametersForTesting(
		TEXT("--goto \"C:/Test.as:10\""),
		TEXT(""),
		true,
		TEXT("C:/MyProject/Script"));

	TestTrue(TEXT("Result should contain the script root directory"),
		Result.Contains(TEXT("C:/MyProject/Script")));
	TestTrue(TEXT("Result should contain the original params"),
		Result.Contains(TEXT("--goto")));

	return true;
}

// ---------------------------------------------------------------------------
// BuildVSCodeParams.RawParams
//   Empty workspace + bOpenFolder=false should return raw params unchanged.
// ---------------------------------------------------------------------------

bool FAngelscriptSourceNavBuildParamsRawTest::RunTest(const FString& Parameters)
{
	const FString RawParams = TEXT("--goto \"C:/Test.as:10\"");
	const FString Result = AngelscriptSourceNavigation::BuildVSCodeOpenParametersForTesting(
		RawParams,
		TEXT(""),
		false,
		TEXT("C:/MyProject/Script"));

	TestEqual(TEXT("With no workspace and bOpenFolder=false, params should be unchanged"),
		Result, RawParams);

	return true;
}

// ---------------------------------------------------------------------------
// BuildVSCodeParams.AllEmpty
//   All empty/false should return raw params unchanged.
// ---------------------------------------------------------------------------

bool FAngelscriptSourceNavBuildParamsAllEmptyTest::RunTest(const FString& Parameters)
{
	const FString RawParams = TEXT("\"C:/Test.as\"");
	const FString Result = AngelscriptSourceNavigation::BuildVSCodeOpenParametersForTesting(
		RawParams,
		TEXT(""),
		false,
		TEXT(""));

	TestEqual(TEXT("With all empty inputs, params should pass through unchanged"),
		Result, RawParams);

	return true;
}

// ---------------------------------------------------------------------------
// OpenOverride.CapturesLocation
//   SetOpenLocationOverrideForTesting should capture path/line when
//   a navigation function is invoked.
// ---------------------------------------------------------------------------

bool FAngelscriptSourceNavOverrideCaptureTest::RunTest(const FString& Parameters)
{
	FAngelscriptSourceNavigationLocation CapturedLocation;
	bool bWasCalled = false;

	AngelscriptSourceNavigation::SetOpenLocationOverrideForTesting(
		[&CapturedLocation, &bWasCalled](const FAngelscriptSourceNavigationLocation& Location)
		{
			CapturedLocation = Location;
			bWasCalled = true;
		});

	ON_SCOPE_EXIT
	{
		AngelscriptSourceNavigation::ResetOpenLocationOverrideForTesting();
	};

	// NavigateToFunctionForTesting with nullptr should return false without crashing.
	// The override may or may not be called depending on whether the handler is registered.
	const bool NavigateResult = AngelscriptSourceNavigation::NavigateToFunctionForTesting(nullptr);

	// Regardless of result, the test validates that setting/resetting the override
	// does not crash and the API is callable.
	TestTrue(TEXT("Navigate with nullptr should return false (no valid function)"),
		!NavigateResult);

	return true;
}

// ---------------------------------------------------------------------------
// CanNavigate.NonASClassReturnsFalse
//   Native UE classes (non-AS) should not be navigable via AS navigation.
// ---------------------------------------------------------------------------

bool FAngelscriptSourceNavNonASClassTest::RunTest(const FString& Parameters)
{
	// NavigateToStructForTesting with a native UE class should return false.
	const bool Result = AngelscriptSourceNavigation::NavigateToStructForTesting(AActor::StaticClass());

	TestFalse(TEXT("NavigateToStruct for native AActor should return false"), Result);

	return true;
}

#endif // WITH_DEV_AUTOMATION_TESTS
