// Theme: Language.Literals.FString. NegativeDiagnostic: f-string with unclosed interpolation brace.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 4 AssertFailsToCompile (currently #if 0, preprocessor-permissive).
// sha256=f470a6a5d66997257a111ac145a10ea5e5547c9b8227e8c455cd31ae40160832; lines 145-147.
// Expected diagnostic: unclosed f-string brace.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	int X = 5;
	FString S = f"Value is {X";
}
