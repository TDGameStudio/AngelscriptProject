// Theme: Language.Casting. NegativeDiagnostic: explicit bool to FString.
// C++: AngelscriptSyntaxCastingTests.cpp::Explicit_Negative AssertFailsToCompile
// Expected compile failure: "Explicit bool to FString cast should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	bool B = true;
	FString S = FString(B);
}
