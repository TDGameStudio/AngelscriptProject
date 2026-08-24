// Theme: Language.Casting. NegativeDiagnostic: implicit conversion between unrelated structs.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Negative AssertFailsToCompile
// Expected compile failure: "Implicit conversion between unrelated structs should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	FVector V = FVector(1, 0, 0);
	FRotator R = V;
}
