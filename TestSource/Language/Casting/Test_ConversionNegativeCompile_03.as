// Theme: Language.Casting. NegativeDiagnostic: implicit FString to int.
// C++: AngelscriptCoverageTypeConversionTests.cpp::ConversionNegativeCompile AssertFailsToCompile
// Expected compile failure: "implicit FString to int should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	FString Text = "42";
	int Value = Text;
}
