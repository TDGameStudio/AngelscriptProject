// Theme: Language.Casting. NegativeDiagnostic: explicit cast with the wrong arity.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
// Expected compile failure: "Explicit cast with wrong number of args should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = int(1, 2, 3);
}
