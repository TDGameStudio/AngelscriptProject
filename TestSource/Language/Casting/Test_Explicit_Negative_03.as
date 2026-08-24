// Theme: Language.Casting. NegativeDiagnostic: cast to void.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
// Expected compile failure: "Cast to void should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 5;
	void(X);
}
