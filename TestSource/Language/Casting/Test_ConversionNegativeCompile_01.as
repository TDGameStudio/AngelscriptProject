// Theme: Language.Casting. NegativeDiagnostic: Cast<T> on a primitive.
// C++: AngelscriptCoverageTypeConversionTests.cpp::ConversionNegativeCompile AssertFailsToCompile
// Expected compile failure: "Cast<T> on primitive should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int Value = 5;
	auto Actor = Cast<AActor>(Value);
}
