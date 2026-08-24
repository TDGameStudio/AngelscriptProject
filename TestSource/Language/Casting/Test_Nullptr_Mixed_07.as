// Theme: Language.Casting. NegativeDiagnostic: arithmetic with nullptr.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertFailsToCompile
// CSV SourceShape Positive is wrong; C++ is compile-fail.
// Expected compile failure: "Arithmetic with nullptr should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = nullptr + 1;
}
