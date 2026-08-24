// Theme: Language.Literals.FString. NegativeDiagnostic: f-string nested braces.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 7 AssertFailsToCompile (currently #if 0, preprocessor-permissive).
// sha256=5a326a7fb1bf8aec5d01220352520373cad69ef0f2a2982ccc8564e380fd2878; lines 171-173.
// Expected diagnostic: nested braces in f-string.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	int X = 5;
	FString S = f"Value is {{X}}";
}
