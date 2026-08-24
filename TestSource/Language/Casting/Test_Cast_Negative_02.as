// Theme: Language.Casting. NegativeDiagnostic: Cast without a template argument.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Negative AssertFailsToCompile
// Expected compile failure: "Cast without template argument should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	auto X = Cast(A);
}
