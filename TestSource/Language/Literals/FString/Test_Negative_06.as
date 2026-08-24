// Theme: Language.Literals.FString. NegativeDiagnostic: comparing FString with int.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 6 AssertFailsToCompile.
// sha256=0d37a4a42befb5a303067b58ad9ef2619a708696dd99ef46057ac3aebe7e3268; lines 162-164.
// Expected diagnostic: no operator== between FString and int.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString S = "5";
	bool B = (S == 5);
}
