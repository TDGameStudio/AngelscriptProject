// Theme: Language.Literals.FString. NegativeDiagnostic: FString multiplication is not defined.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 3 AssertFailsToCompile.
// sha256=550991be7a7193e61797b19fadfebe64b487fb60a47f21184e29a85bab4a3651; lines 136-138.
// Expected diagnostic: no operator* for FString and int.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString S = "abc" * 3;
}
