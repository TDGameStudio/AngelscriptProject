// Theme: Language.Casting. NegativeDiagnostic: bare UObject handle as a condition.
// C++: AngelscriptCoverageTypeConversionTests.cpp::ConversionNegativeCompile AssertFailsToCompile
// Expected compile failure: "bare UObject handle conditions should remain unsupported without an explicit bool-producing expression".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor Actor)
{
	if (Actor)
	{
	}
}
