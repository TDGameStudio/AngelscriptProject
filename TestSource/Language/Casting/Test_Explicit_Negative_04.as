// Theme: Language.Casting. NegativeDiagnostic: explicit object to int.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
// Expected compile failure: "Explicit object to int cast should fail".
// Isolate the failing program. DiagnosticOnly.

void Test(AActor A)
{
	int X = int(A);
}
