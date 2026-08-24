// Theme: Language.Casting. NegativeDiagnostic: assign nullptr to bool.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertFailsToCompile
// CSV SourceShape Positive is wrong; C++ is compile-fail.
// Expected compile failure: "Assign nullptr to bool should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	bool B = nullptr;
}
