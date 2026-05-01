// =============================================================================
// AngelscriptPerformanceStatsTests.cpp
//
// Tests for FAngelscriptPerformanceStats — validates scope name registry.
// Automation IDs: Angelscript.TestModule.CppTests.PerformanceStats.*
// =============================================================================

#include "Misc/AutomationTest.h"
#include "Core/AngelscriptPerformanceStats.h"

#if WITH_DEV_AUTOMATION_TESTS

// -----------------------------------------------------------------------------
// Test: Known scope names array is non-empty
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptPerfStatsKnownScopesNonEmpty,
	"Angelscript.TestModule.CppTests.PerformanceStats.KnownScopesNonEmpty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPerfStatsKnownScopesNonEmpty::RunTest(const FString& Parameters)
{
	TArray<FName> Scopes = FAngelscriptPerformanceStats::GetKnownScopeNamesForTesting();
	TestTrue(TEXT("Known scopes array is not empty"), Scopes.Num() > 0);
	return true;
}

// -----------------------------------------------------------------------------
// Test: At least one scope contains "Startup"
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptPerfStatsContainsStartup,
	"Angelscript.TestModule.CppTests.PerformanceStats.ContainsStartupScope",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPerfStatsContainsStartup::RunTest(const FString& Parameters)
{
	TArray<FName> Scopes = FAngelscriptPerformanceStats::GetKnownScopeNamesForTesting();
	bool bFoundStartup = false;
	for (const FName& Scope : Scopes)
	{
		if (Scope.ToString().Contains(TEXT("Startup")))
		{
			bFoundStartup = true;
			break;
		}
	}
	TestTrue(TEXT("At least one scope contains 'Startup'"), bFoundStartup);
	return true;
}

// -----------------------------------------------------------------------------
// Test: No duplicate scope names
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptPerfStatsNoDuplicates,
	"Angelscript.TestModule.CppTests.PerformanceStats.NoDuplicateScopes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPerfStatsNoDuplicates::RunTest(const FString& Parameters)
{
	TArray<FName> Scopes = FAngelscriptPerformanceStats::GetKnownScopeNamesForTesting();
	TSet<FName> UniqueScopes;
	for (const FName& Scope : Scopes)
	{
		UniqueScopes.Add(Scope);
	}
	TestEqual(TEXT("No duplicate scope names"), UniqueScopes.Num(), Scopes.Num());
	return true;
}

// -----------------------------------------------------------------------------
// Test: Public GetKnownScopeNames returns same data as testing variant
// -----------------------------------------------------------------------------
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptPerfStatsPublicMatchesTesting,
	"Angelscript.TestModule.CppTests.PerformanceStats.PublicMatchesTestingAPI",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPerfStatsPublicMatchesTesting::RunTest(const FString& Parameters)
{
	const TArray<FName>& PublicScopes = FAngelscriptPerformanceStats::GetKnownScopeNames();
	TArray<FName> TestingScopes = FAngelscriptPerformanceStats::GetKnownScopeNamesForTesting();
	TestEqual(TEXT("Public and testing APIs return same count"), PublicScopes.Num(), TestingScopes.Num());
	return true;
}

#endif
