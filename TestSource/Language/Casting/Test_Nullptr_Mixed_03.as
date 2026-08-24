// Theme: Language.Casting. NegativeDiagnostic: assign nullptr to a primitive.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertFailsToCompile
// CSV SourceShape Positive is wrong; C++ is compile-fail.
// Expected compile failure: "Assign nullptr to primitive should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int X = nullptr;
}
