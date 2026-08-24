// Theme: Language.Operators.Arithmetic. NegativeDiagnostic: FString + int is not an int.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative block 1 AssertFailsToCompile.
// sha256=3ae1c001f1510d0abae01b46a63cf59f59361de905988ab058779f0fda7bab5e; lines 98-100.
// Expected diagnostic: string + int type mismatch.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	int X = "hello" + 1;
}
