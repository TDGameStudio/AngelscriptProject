// Theme: Language.Literals.FString. NegativeDiagnostic: FString subtraction is not defined.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 2 AssertFailsToCompile.
// sha256=7ed9617cac9e8ce7ac16be388fe3247be94ad61f42c7327bcb662f249f1ee1bb; lines 128-130.
// Expected diagnostic: no operator- for FString.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString A = "Hello";
	FString B = A - "lo";
}
