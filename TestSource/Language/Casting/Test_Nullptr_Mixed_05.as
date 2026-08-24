// Theme: Language.Casting. NegativeDiagnostic: assign nullptr to float.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertFailsToCompile
// CSV SourceShape Positive is wrong; C++ is compile-fail.
// Expected compile failure: "Assign nullptr to float should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	float X = nullptr;
}
