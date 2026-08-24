// Theme: Language.Casting. NegativeDiagnostic: implicit int to bool.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
// Expected compile failure: "Implicit int to bool should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = 1;
	bool B = X;
}
