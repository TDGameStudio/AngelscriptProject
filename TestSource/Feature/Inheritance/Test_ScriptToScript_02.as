// Theme: Feature.Inheritance. Isolated compile/analyze-fail After of ScriptToScript.
// C++: AngelscriptInheritanceFunctionalTests.cpp::ScriptToScript AnalyzeReloadFromMemory.
// Expected: bAnalyzed false; ReloadRequirement stays Error.
// Diagnostic meaning: TestCase script-to-script actor inheritance with overridden
// UFUNCTIONs remains unsupported (derived inherits ATestCaseInheritanceBase, not ATestInheritanceBase).
// DiagnosticOnly. Do not add declarations that would compile the After program away.

UCLASS()
class ATestInheritanceBase : AActor
{
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 1;
	}
}

UCLASS()
class ATestInheritanceDerived : ATestCaseInheritanceBase
{
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 2;
	}
}
