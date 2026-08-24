// Theme: Language.Casting. NegativeDiagnostic: explicit FString to int cast.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
// Expected compile failure: "Explicit string to int cast should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	FString S = "hello";
	int X = int(S);
}
