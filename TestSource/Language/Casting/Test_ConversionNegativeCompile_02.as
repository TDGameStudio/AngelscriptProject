// Theme: Language.Casting. NegativeDiagnostic: implicit base-to-derived object conversion.
// C++: AngelscriptCoverageTypeConversionTests.cpp::ConversionNegativeCompile AssertFailsToCompile
// Expected compile failure: "implicit base-to-derived object conversion should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor Actor)
{
	APawn Pawn = Actor;
}
