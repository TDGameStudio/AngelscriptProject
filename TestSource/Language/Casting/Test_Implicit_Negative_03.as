// Theme: Language.Casting. NegativeDiagnostic: implicit base-to-derived argument conversion.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
// Expected compile failure: "Implicit base to derived should fail".
// Isolate the failing program. DiagnosticOnly.

void TakePawn(APawn P)
{
}

void Test(AActor A)
{
	TakePawn(A);
}
