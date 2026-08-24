// Theme: Language.Casting. NegativeDiagnostic: Cast without an argument.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast without argument should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	auto X = Cast<AActor>();
}
