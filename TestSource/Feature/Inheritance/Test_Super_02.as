// Theme: Feature.Inheritance. Isolated compile/analyze-fail After of Super.
// C++: AngelscriptInheritanceFunctionalTests.cpp::Super AnalyzeReloadFromMemory.
// Expected: bAnalyzed false; ReloadRequirement stays Error.
// Diagnostic meaning: TestCase script-to-script Super calls remain unsupported
// (derived inherits ATestCaseInheritanceSuperBase, not ATestInheritanceSuperBase).
// DiagnosticOnly. Do not add declarations that would compile the After program away.

UCLASS()
class ATestInheritanceSuperBase : AActor
{
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 10;
	}
}

UCLASS()
class ATestInheritanceSuperDerived : ATestCaseInheritanceSuperBase
{
	UFUNCTION()
	int GetTestCaseValue()
	{
		return Super::GetTestCaseValue() + 5;
	}
}
