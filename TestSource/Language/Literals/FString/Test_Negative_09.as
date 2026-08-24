// Theme: Language.Literals.FString. NegativeDiagnostic: FString division is not defined.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 9 AssertFailsToCompile.
// sha256=c72698b3f4b3182c486b0b99b4b4747d66bfc468a5b981334ec931dcba2658a2; lines 188-190.
// Expected diagnostic: no operator/ for FString.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString A = "Hello";
	FString B = A / "World";
}
