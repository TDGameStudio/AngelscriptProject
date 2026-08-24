// Theme: Language.Literals.FString. NegativeDiagnostic: FString bitwise AND is not defined.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 10 AssertFailsToCompile.
// sha256=83cc26bdd989278db105cdc08a939d513caeca7f645688c8ec611f7ec736b130; lines 196-198.
// Expected diagnostic: no operator& for FString.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString A = "Hello";
	auto X = A & "World";
}
