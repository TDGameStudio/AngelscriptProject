// Theme: Language.Casting. NegativeDiagnostic: implicit FString to int.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
// Expected compile failure: "Implicit string to int should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	FString S = "5";
	int X = S;
}
